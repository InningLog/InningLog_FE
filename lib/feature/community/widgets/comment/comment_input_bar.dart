import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

class CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback onPressed;
  final ValueChanged<bool>? onFocusChange;
  final bool isReplyMode;
  final String? replyNickname;

  final int maxLines; // 4줄까지 확장

  const CommentInputBar({
    super.key,
    required this.controller,
    this.focusNode,
    required this.onPressed,
    this.onFocusChange,
    this.isReplyMode = false,
    this.replyNickname,
    this.maxLines = 4,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ controller 값 변화에 따라 hasText가 자동 갱신되게 (markNeedsBuild 제거)
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isReplyMode)
                _ReplyTopBar(nickName: replyNickname ?? ''), //대댓글 인 경우
              Container(
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius:
                      !isReplyMode
                          ? BorderRadius.circular(8)
                          : const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Focus(
                        onFocusChange: onFocusChange,
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          cursorColor: AppColors.primary700,
                          minLines: 1,
                          maxLines: maxLines, // ✅ 4줄까지는 높이 증가, 이후는 내부 스크롤
                          keyboardType: TextInputType.multiline,
                          textAlignVertical: TextAlignVertical.top,
                          style: AppTextStyles.bodyBody2Rg.copyWith(
                            color: AppColors.gray800,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: '댓글로 의견을 남겨보세요.',
                            hintStyle: AppTextStyles.bodyBody2Rg.copyWith(
                              color: AppColors.gray600,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    _SendButton(
                      enabled: hasText,
                      onTap:
                          hasText
                              ? () {
                                onPressed();
                                FocusManager.instance.primaryFocus?.unfocus();
                              }
                              : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;

  final VoidCallback? onTap;

  const _SendButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.primary700 : const Color(0xFFC0C0C0),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 22,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/vector_board.svg',
              width: 9.39,
              height: 14.13,
              colorFilter: const ColorFilter.mode(
                AppColors.gray50,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReplyTopBar extends StatelessWidget {
  final String nickName;
  const _ReplyTopBar({required this.nickName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$nickName님에게 대댓글 남기는 중',
              style: AppTextStyles.headHead8M.copyWith(
                color: AppColors.gray500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
