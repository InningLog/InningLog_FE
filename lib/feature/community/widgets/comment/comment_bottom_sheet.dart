import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/comment.dart';
import 'package:inninglog/feature/community/viewmodel/comment_view_model.dart';
import 'package:inninglog/feature/community/widgets/comment/comment_input_bar.dart';
import 'package:inninglog/feature/community/widgets/comment/comment_list.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';
import 'package:inninglog/shared/widgets/bottom_action_sheet.dart';
import 'package:inninglog/shared/widgets/app_bottom_sheet.dart';
import 'package:provider/provider.dart';

Future<T?> showCommentBottomSheet<T>(
  BuildContext context, {
  required CommentViewModel viewModel,
  void Function(String text)? onSubmitComment,
  void Function(String text, Comment parent)? onSubmitReply,
  void Function(int index)? onTapReply,
  void Function(Comment comment)? onTapMore,
  void Function(Comment reply)? onTapReplyMore,
  void Function(int count)? onCommentCountChanged,
  String title = '댓글',
  bool fetchOnShow = true,
}) {
  if (fetchOnShow) {
    viewModel.fetchComments();
  }

  return showAppBottomSheet<T>(
    context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true,
    builder:
        (_) => ChangeNotifierProvider<CommentViewModel>(
          create: (_) => viewModel,
          child: CommentBottomSheet(
            title: title,
            onSubmitComment: onSubmitComment,
            onSubmitReply: onSubmitReply,
            onTapReply: onTapReply,
            onTapMore: onTapMore,
            onTapReplyMore: onTapReplyMore,
            onCommentCountChanged: onCommentCountChanged,
          ),
        ),
  );
}

class CommentBottomSheet extends StatefulWidget {
  final String title;
  final void Function(String text)? onSubmitComment;
  final void Function(String text, Comment parent)? onSubmitReply;
  final void Function(int index)? onTapReply;
  final void Function(Comment comment)? onTapMore;
  final void Function(Comment reply)? onTapReplyMore;
  final void Function(int count)? onCommentCountChanged;

  const CommentBottomSheet({
    super.key,
    this.title = '댓글',
    this.onSubmitComment,
    this.onSubmitReply,
    this.onTapReply,
    this.onTapMore,
    this.onTapReplyMore,
    this.onCommentCountChanged,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  int? _lastCount;
  final TextEditingController _commentCtrl = TextEditingController();
  final TextEditingController _replyCtrl = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _replyFocusNode = FocusNode();

  @override
  void dispose() {
    _commentCtrl.dispose();
    _replyCtrl.dispose();
    _commentFocusNode.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  void _notifyCount(int count) {
    if (_lastCount == count) return;
    _lastCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onCommentCountChanged?.call(count);
    });
  }

  @override
  Widget build(BuildContext context) {
    double sheetHeight = math.min(
      MediaQuery.of(context).size.height * 0.58,
      530,
    );

    return Consumer<CommentViewModel>(
      builder: (context, vm, _) {
        _notifyCount(vm.totalCount);

        final isReplyMode = vm.isReplyMode;
        final controller = isReplyMode ? _replyCtrl : _commentCtrl;
        final focusNode = isReplyMode ? _replyFocusNode : _commentFocusNode;

        Future<void> showDefaultActions(Comment target) async {
          if (!target.writeByMe || target.isDeleted) return;
          await showBottomActionSheet<bool>(
            context,
            actions: [
              BottomActionSheetAction(
                label: '삭제',
                isDestructive: true,
                onTap: () async {
                  await vm.deleteComment(target);
                  // Navigator.of(context).pop(ok);
                },
              ),
            ],
          );
        }

        return SafeArea(
          top: false,
          bottom: false,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: MediaQuery.of(context).viewInsets.bottom,
                  child: const ColoredBox(color: AppColors.primary50),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AppBottomSheetContainer(
                    safeAreaBottom: true,
                    height: sheetHeight,
                    backgroundColor: AppColors.primary50,
                    child: Column(
                      children: [
                        _CommentSheetHeader(title: widget.title),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              vm.cancelReply();
                            },
                            child: ListView(
                              padding: EdgeInsets.zero,
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              children: [
                                CommentList(
                                  comments: vm.comments,
                                  activeReplyIndex: vm.activeReplyIndex,
                                  repliesFor: vm.repliesFor,
                                  onTapReply: (index) {
                                    widget.onTapReply?.call(index);
                                    vm.startReply(index);
                                    _replyCtrl.clear();
                                    _replyFocusNode.requestFocus();
                                  },
                                  onToggleLike: vm.toggleCommentLike,
                                  onToggleReplyLike:
                                      (reply, index) =>
                                          vm.toggleReplyLike(index, reply),
                                  onTapMore: (comment) {
                                    final handler = widget.onTapMore;
                                    if (handler != null) {
                                      handler(comment);
                                    } else {
                                      showDefaultActions(comment);
                                    }
                                  },
                                  onTapReplyMore: (reply) {
                                    final handler = widget.onTapReplyMore;
                                    if (handler != null) {
                                      handler(reply);
                                    } else {
                                      showDefaultActions(reply);
                                    }
                                  },
                                ),
                                const SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ),
                        CommentInputBar(
                          controller: controller,
                          focusNode: focusNode,
                          isReplyMode: isReplyMode,
                          replyNickname: vm.activeReplyNickname,
                          onPressed: () {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;

                            if (isReplyMode) {
                              final index = vm.activeReplyIndex;
                              if (index != null &&
                                  index >= 0 &&
                                  index < vm.comments.length) {
                                widget.onSubmitReply?.call(
                                  text,
                                  vm.comments[index],
                                );
                              }
                              _replyCtrl.clear();
                              vm.submitReply(text);
                            } else {
                              widget.onSubmitComment?.call(text);
                              _commentCtrl.clear();
                              vm.submitComment(text);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommentSheetHeader extends StatelessWidget {
  final String title;

  const _CommentSheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.primary50,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200, width: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.headHead6B.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
