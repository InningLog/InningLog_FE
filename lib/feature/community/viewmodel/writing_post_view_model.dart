import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/community_post.dart';
import 'package:inninglog/feature/community/model/dto/post_dtos.dart';
import 'package:inninglog/feature/community/repositories/post_repository.dart';
import 'package:inninglog/shared/service/image_pick_service.dart';

class WritingPostViewModel extends ChangeNotifier {
  final int maxImages;
  final ImagePickService imagePickService;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode bodyFocusNode = FocusNode();

  final List<_EditableImage> _images = [];
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
    CommunityPostItem? initialPost,
  }) {
    titleController.addListener(_handleTextChanged);
    bodyController.addListener(_handleTextChanged);
    titleFocusNode.addListener(_handleTitleFocusChanged);
    if (initialPost != null) {
      _applyInitialPost(initialPost);
    }
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
          _EditableImage.fromBytes(
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

  Future<bool> submit({required String teamCode}) async {
    if (_isDisposed || _isSubmitting) return false;

    _isSubmitting = true;
    _safeNotify();
    final title = titleController.text.trim();
    final content = bodyController.text.trim();
    var success = false;

    try {
      debugPrint(
        '[WritingPost] submit team=$teamCode titleLen=${title.length} images=${_images.length}',
      );
      final pendingBySequence = <int, _EditableImage>{};
      final uploadImages = <ImageUploadReqDto>[];
      for (var i = 0; i < _images.length; i++) {
        final image = _images[i];
        if (!image.isNew) continue;
        final sequence = i + 1;
        pendingBySequence[sequence] = image;
        uploadImages.add(
          ImageUploadReqDto(
            sequence: sequence,
            fileName: image.fileName!,
            contentType: image.contentType!,
          ),
        );
      }

      List<ImageCreateReqDto> imageKeys = [];

      if (uploadImages.isNotEmpty) {
        final presignedList = await repo.requestImagePresignedUrls(
          images: uploadImages,
        );
        final presignedMap = {
          for (final item in presignedList) item.sequence: item,
        };

        final uploadFutures = uploadImages.map((image) async {
          final presigned = presignedMap[image.sequence];
          if (presigned == null) {
            throw StateError(
              'Presigned URL missing for sequence ${image.sequence}',
            );
          }
          final pending = pendingBySequence[image.sequence];
          if (pending == null || pending.bytes == null) {
            throw StateError(
              'Pending image missing for sequence ${image.sequence}',
            );
          }

          debugPrint(
            '[WritingPost] upload seq=${image.sequence} url=${presigned.presignedUrl}',
          );
          await repo.uploadToS3(
            target: presigned,
            contentType: image.contentType,
            bytes: pending.bytes!,
          );
          return ImageCreateReqDto(
            sequence: presigned.sequence,
            key: presigned.key,
          );
        }).toList();

        imageKeys = await Future.wait(uploadFutures);
        imageKeys.sort((a, b) => a.sequence.compareTo(b.sequence));
      }

      debugPrint('[WritingPost] createPost keys=${imageKeys.length}');
      await repo.createPost(
        teamCode: teamCode,
        request: CreatePostRequest(
          title: title,
          content: content,
          imageCreateReqDto: imageKeys,
          imageCount: imageKeys.length,
        ),
      );
      success = true;
    } catch (e) {
      debugPrint(e.toString());
      // error = e.toString();
    } finally {
      _isSubmitting = false;
      _safeNotify();
    }
    return success;
  }

  Future<bool> update({required int postId}) async {
    if (_isDisposed || _isSubmitting) return false;

    _isSubmitting = true;
    _safeNotify();
    final title = titleController.text.trim();
    final content = bodyController.text.trim();
    var success = false;

    try {
      debugPrint(
        '[WritingPost] update postId=$postId titleLen=${title.length} images=${_images.length}',
      );

      final remainImages = <RemainImageReqDto>[];
      final pendingBySequence = <int, _EditableImage>{};
      final uploadImages = <ImageUploadReqDto>[];

      for (var i = 0; i < _images.length; i++) {
        final image = _images[i];
        final sequence = i + 1;
        if (image.isExisting) {
          remainImages.add(
            RemainImageReqDto(
              remainImageId: image.remainImageId!,
              sequence: sequence,
            ),
          );
        } else {
          pendingBySequence[sequence] = image;
          uploadImages.add(
            ImageUploadReqDto(
              sequence: sequence,
              fileName: image.fileName!,
              contentType: image.contentType!,
            ),
          );
        }
      }

      List<NewImageReqDto> newImages = [];
      if (uploadImages.isNotEmpty) {
        final presignedList = await repo.requestImagePresignedUrls(
          images: uploadImages,
        );
        final presignedMap = {
          for (final item in presignedList) item.sequence: item,
        };

        final uploadFutures = uploadImages.map((image) async {
          final presigned = presignedMap[image.sequence];
          if (presigned == null) {
            throw StateError(
              'Presigned URL missing for sequence ${image.sequence}',
            );
          }
          final pending = pendingBySequence[image.sequence];
          if (pending == null || pending.bytes == null) {
            throw StateError(
              'Pending image missing for sequence ${image.sequence}',
            );
          }

          debugPrint(
            '[WritingPost] upload seq=${image.sequence} url=${presigned.presignedUrl}',
          );
          await repo.uploadToS3(
            target: presigned,
            contentType: image.contentType,
            bytes: pending.bytes!,
          );
          return NewImageReqDto(
            sequence: presigned.sequence,
            key: presigned.key,
          );
        }).toList();

        newImages = await Future.wait(uploadFutures);
        newImages.sort((a, b) => a.sequence.compareTo(b.sequence));
      }

      await repo.updatePost(
        postId: postId,
        request: UpdatePostRequest(
          title: title,
          content: content,
          remainImages: remainImages,
          newImages: newImages,
          imageCount: _images.length,
        ),
      );
      success = true;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isSubmitting = false;
      _safeNotify();
    }

    return success;
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

  void _applyInitialPost(CommunityPostItem post) {
    titleController.text = post.title;
    bodyController.text = post.content;

    final sortedImages = [...post.images]
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    for (final image in sortedImages) {
      if (image.url.isEmpty) continue;
      _images.add(
        _EditableImage.fromExisting(
          remainImageId: image.imageId,
          url: image.url,
        ),
      );
    }
    _safeNotify();
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

class _EditableImage {
  final ImageProvider provider;
  final int? remainImageId;
  final Uint8List? bytes;
  final String? fileName;
  final String? contentType;

  bool get isExisting => remainImageId != null;
  bool get isNew => bytes != null;

  _EditableImage._({
    required this.provider,
    this.remainImageId,
    this.bytes,
    this.fileName,
    this.contentType,
  });

  factory _EditableImage.fromExisting({
    required int remainImageId,
    required String url,
  }) {
    return _EditableImage._(
      provider: NetworkImage(url),
      remainImageId: remainImageId,
    );
  }

  factory _EditableImage.fromBytes({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) {
    return _EditableImage._(
      provider: MemoryImage(bytes),
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
    );
  }
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
