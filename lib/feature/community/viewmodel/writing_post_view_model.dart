import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/dto/create_post_dtos.dart';
import 'package:inninglog/feature/community/repositories/post_repository.dart';
import 'package:inninglog/shared/service/image_pick_service.dart';

class WritingPostViewModel extends ChangeNotifier {
  final int maxImages;
  final ImagePickService imagePickService;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode bodyFocusNode = FocusNode();

  final List<_PendingImage> _images = [];
  List<ImageProvider> get images =>
      List.unmodifiable(_images.map((e) => e.provider));

  bool _isDisposed = false;
  bool _isSubmitting = false;

  final CommunityPostRepository repo;

  bool _isPicking = false;
  bool get isPicking => _isPicking;

  bool _isTitleFocused = false;
  bool get isTitleFocused => _isTitleFocused;

  bool _isFormFilled = false;
  bool get isFormFilled => _isFormFilled;

  bool get canPickMore => _images.length < maxImages;
  bool get canSubmit => _isFormFilled && !_isSubmitting;
  bool get isSubmitting => _isSubmitting;

  WritingPostViewModel({
    required this.imagePickService,
    this.maxImages = 5,
    required this.repo,
  }) {
    titleController.addListener(_handleTextChanged);
    bodyController.addListener(_handleTextChanged);
    titleFocusNode.addListener(_handleTitleFocusChanged);
  }

  Future<void> pickFromGallery() async {
    if (!canPickMore || _isPicking) return;
    _isPicking = true;
    _safeNotify();

    try {
      final remain = maxImages - _images.length;
      final bytesList = await imagePickService.pickMultiBytes(limit: remain);

      final now = DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < bytesList.length; i++) {
        final bytes = bytesList[i];
        final contentType = _detectContentType(bytes);
        final ext = contentType == 'image/png' ? 'png' : 'jpg';
        final fileName = 'community_${now}_${_images.length + i}.$ext';

        _images.add(
          _PendingImage(
            bytes: bytes,
            fileName: fileName,
            contentType: contentType,
          ),
        );
      }
      _safeNotify();
    } finally {
      _isPicking = false;
      _safeNotify();
    }
  }

  Future<void> submit({required String teamCode}) async {
    if (_isDisposed || _isSubmitting) return;

    _isSubmitting = true;
    _safeNotify();
    final title = titleController.text.trim();
    final content = bodyController.text.trim();

    try {
      debugPrint(
        '[WritingPost] submit team=$teamCode titleLen=${title.length} images=${_images.length}',
      );
      final uploadImages =
          _images
              .asMap()
              .entries
              .map(
                (entry) => ImageUploadReqDto(
                  sequence: entry.key + 1,
                  fileName: entry.value.fileName,
                  contentType: entry.value.contentType,
                ),
              )
              .toList();

      List<ImageCreateReqDto> imageKeys = [];

      if (uploadImages.isNotEmpty) {
        final presignedList = await repo.requestImagePresignedUrls(
          images: uploadImages,
        );
        final presignedMap = {
          for (final item in presignedList) item.sequence: item,
        };

        for (final image in uploadImages) {
          final presigned = presignedMap[image.sequence];
          if (presigned == null) {
            throw StateError(
              'Presigned URL missing for sequence ${image.sequence}',
            );
          }

          debugPrint(
            '[WritingPost] upload seq=${image.sequence} url=${presigned.presignedUrl}',
          );
          await repo.uploadToS3(
            target: presigned,
            contentType: image.contentType,
          );
          imageKeys.add(
            ImageCreateReqDto(sequence: presigned.sequence, key: presigned.key),
          );
        }

        imageKeys.sort((a, b) => a.sequence.compareTo(b.sequence));
      }

      debugPrint('[WritingPost] createPost keys=${imageKeys.length}');
      await repo.createPost(
        teamCode: teamCode,
        request: CreatePostRequest(
          title: title,
          content: content,
          imageCreateReqDto: imageKeys,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      // error = e.toString();
    } finally {
      _isSubmitting = false;
      _safeNotify();
    }
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= _images.length) return;
    _images.removeAt(index);
    _safeNotify();
  }

  void _handleTitleFocusChanged() {
    final hasFocus = titleFocusNode.hasFocus;
    if (_isTitleFocused == hasFocus) return;
    _isTitleFocused = hasFocus;
    notifyListeners();
  }

  void _handleTextChanged() {
    final hasTitle = titleController.text.trim().isNotEmpty;
    final hasBody = bodyController.text.trim().isNotEmpty;
    final filled = hasTitle && hasBody;
    if (_isFormFilled == filled) return;
    _isFormFilled = filled;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController
      ..removeListener(_handleTextChanged)
      ..dispose();
    bodyController
      ..removeListener(_handleTextChanged)
      ..dispose();
    titleFocusNode
      ..removeListener(_handleTitleFocusChanged)
      ..dispose();
    bodyFocusNode.dispose();
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (_isDisposed) return;
    notifyListeners();
  }
}

class _PendingImage {
  final Uint8List bytes;
  final String fileName;
  final String contentType;

  const _PendingImage({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  ImageProvider get provider => MemoryImage(bytes);
}

String _detectContentType(Uint8List bytes) {
  if (bytes.length >= 4 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47) {
    return 'image/png';
  }
  if (bytes.length >= 2 && bytes[0] == 0xff && bytes[1] == 0xd8) {
    return 'image/jpeg';
  }
  return 'image/jpeg';
}
