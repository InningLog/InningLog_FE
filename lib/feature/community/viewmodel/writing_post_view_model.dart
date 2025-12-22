import 'package:flutter/material.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/feature/community/model/create_post_request.dart';
import 'package:inninglog/feature/community/repositories/post_repository.dart';
import 'package:inninglog/shared/service/image_pick_service.dart';

class WritingPostViewModel extends ChangeNotifier {
  final int maxImages;
  final ImagePickService imagePickService;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode bodyFocusNode = FocusNode();

  final List<ImageProvider> _images = [];
  List<ImageProvider> get images => List.unmodifiable(_images);

  final CommunityPostRepository repo;

  bool _isPicking = false;
  bool get isPicking => _isPicking;

  bool _isTitleFocused = false;
  bool get isTitleFocused => _isTitleFocused;

  bool _isFormFilled = false;
  bool get isFormFilled => _isFormFilled;

  bool get canPickMore => _images.length < maxImages;
  bool get canSubmit => _isFormFilled;

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
    notifyListeners();

    try {
      final remain = maxImages - _images.length;
      final bytesList = await imagePickService.pickMultiBytes(limit: remain);

      _images.addAll(bytesList.map((b) => MemoryImage(b)));
      notifyListeners();
    } finally {
      _isPicking = false;
      notifyListeners();
    }
  }

  /// 임시 제출/디버그용 로그
  void submitDraft() {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    debugPrint('[WritingPost] submitDraft');
    debugPrint('  title: "$title"');
    debugPrint('  body: "$body"');
    debugPrint('  imageCount: ${_images.length}');
  }

  Future<void> submit({required String teamCode}) async {
    // submitting = true;
    // error = null;
    notifyListeners();
    final title = titleController.text.trim();
    final content = bodyController.text.trim();

    try {
      await repo.createPost(
        teamCode: teamCode,
        request: CreatePostRequest(
          title: title,
          content: content,
          imageCreateReqDto: [],
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      // error = e.toString();
    } finally {
      // submitting = false;
      notifyListeners();
    }
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= _images.length) return;
    _images.removeAt(index);
    notifyListeners();
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
    super.dispose();
  }
}
