import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:inninglog/feature/community/viewmodel/writing_post_view_model.dart';
import 'package:inninglog/feature/community/widgets/writing_post/image_attachment_bar.dart';
import 'package:inninglog/feature/community/widgets/writing_post/writing_post_app_bar.dart';
import 'package:inninglog/feature/community/widgets/writing_post/writing_post_guidelines_footer.dart';
import 'package:inninglog/shared/service/image_pick_service.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class WritingPostPage extends StatefulWidget {
  final String teamCode;
  const WritingPostPage({super.key, required this.teamCode});

  @override
  State<WritingPostPage> createState() => _WritingPostPageState();
}

class _WritingPostPageState extends State<WritingPostPage> {
  late final vm = WritingPostViewModel(
    maxImages: 5,
    imagePickService: ImagePickService(),
  );

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  void _submit() {
    vm.submitDraft(); // TODO: 등록 API 연동
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return Scaffold(
          // 키보드 올라오면 body/bottomNavigationBar가 같이 위로 올라가게
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,

          body: SafeArea(
            bottom: false, // bottom은 bottomNavigationBar에서 처리
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  WritingPostAppBar(
                    teamLabel: kboTeamLabelOf(widget.teamCode),
                    onClose: () => Navigator.of(context).pop(),
                    onSubmit: _submit,
                    isSubmitEnabled: vm.canSubmit,
                  ),
                  const SizedBox(height: 12),

                  // 제목 (고정)
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

                  // 본문 (여기만 스크롤)
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
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1500),
                        ],
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

          // 바닥 고정 영역 (가이드라인 + 첨부바)
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
                            () => FocusManager.instance.primaryFocus?.unfocus(),
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
        );
      },
    );
  }
}
