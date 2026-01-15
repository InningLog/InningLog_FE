import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:inninglog/feature/community/viewmodel/writing_post_view_model.dart';
import 'package:inninglog/feature/community/widgets/writing_post/image_attachment_bar.dart';
import 'package:inninglog/feature/community/widgets/writing_post/writing_post_app_bar.dart';
import 'package:inninglog/feature/community/widgets/writing_post/writing_post_guidelines_footer.dart';
import 'package:inninglog/shared/service/image_pick_service.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:provider/provider.dart';

class WritingPostPage extends StatelessWidget {
  final String teamCode;
  const WritingPostPage({super.key, required this.teamCode});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AppScope>().communityPostRepository;

    return ChangeNotifierProvider<WritingPostViewModel>(
      create:
          (_) => WritingPostViewModel(
            maxImages: 5,
            imagePickService: ImagePickService(),
            repo: repo,
          ),
      child: _WritingPostView(teamCode: teamCode),
    );
  }
}

class _WritingPostView extends StatelessWidget {
  final String teamCode;
  const _WritingPostView({required this.teamCode});

  Future<void> _submit(BuildContext context, WritingPostViewModel vm) async {
    final success = await vm.submit(teamCode: teamCode);
    if (!context.mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글 등록에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WritingPostViewModel>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WritingPostAppBar(
                    teamLabel: kboTeamLabelOf(teamCode),
                    onClose: () => Navigator.of(context).pop(),
                    onSubmit: () => _submit(context, vm),
                    isSubmitEnabled: vm.canSubmit,
                  ),
                  const SizedBox(height: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              vm.isTitleFocused
                                  ? AppColors.gray400
                                  : Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: vm.titleController,
                      focusNode: vm.titleFocusNode,
                      textInputAction: TextInputAction.next,
                      onTapOutside:
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
                      inputFormatters: [LengthLimitingTextInputFormatter(20)],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                        fontFamily: 'Pretendard',
                      ),
                      decoration: const InputDecoration(
                        hintText: '제목을 입력해주세요.',
                        hintStyle: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray600,
                          fontFamily: 'Pretendard',
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => vm.bodyFocusNode.requestFocus(),
                      child: TextField(
                        controller: vm.bodyController,
                        focusNode: vm.bodyFocusNode,
                        onTapOutside:
                            (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                        inputFormatters: [LengthLimitingTextInputFormatter(1500)],
                        expands: true,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gray900,
                          fontFamily: 'Pretendard',
                        ),
                        decoration: const InputDecoration(
                          hintText: '내용을 입력하세요.',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray600,
                            fontFamily: 'Pretendard',
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (bottomInset > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_hide),
                        tooltip: '키보드 내리기',
                        onPressed:
                            () =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                    ),
                  const SizedBox(height: 24),
                  WritingPostGuidelinesFooter(),
                  const SizedBox(height: 24),
                  ImageAttachmentBar(
                    images: vm.images,
                    maxImages: vm.maxImages,
                    onPickImages: vm.canPickMore ? vm.pickFromGallery : null,
                    onRemoveImageAt: vm.removeImageAt,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (vm.isSubmitting) ...[
          const ModalBarrier(dismissible: false, color: Color(0x66000000)),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}
