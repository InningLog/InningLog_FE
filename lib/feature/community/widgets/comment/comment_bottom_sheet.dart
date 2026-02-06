import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/comment.dart';
import 'package:inninglog/feature/community/widgets/comment/comment_input_bar.dart';
import 'package:inninglog/feature/community/widgets/comment/comment_list.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';
import 'package:inninglog/shared/widgets/app_bottom_sheet.dart';

Future<T?> showCommentBottomSheet<T>(
  BuildContext context, {
  required List<Comment> comments,
  void Function(String text)? onSubmitComment,
  void Function(String text, Comment parent)? onSubmitReply,
  void Function(int index)? onTapReply,
  void Function(int index)? onToggleLike,
  void Function(Comment reply, int index)? onToggleReplyLike,
  void Function(Comment comment)? onTapMore,
  void Function(Comment reply)? onTapReplyMore,
  String title = '댓글',
}) {
  return showAppBottomSheet<T>(
    context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true,
    builder:
        (_) => CommentBottomSheet(
          comments: comments,
          title: title,
          onSubmitComment: onSubmitComment,
          onSubmitReply: onSubmitReply,
          onTapReply: onTapReply,
          onToggleLike: onToggleLike,
          onToggleReplyLike: onToggleReplyLike,
          onTapMore: onTapMore,
          onTapReplyMore: onTapReplyMore,
        ),
  );
}

class CommentBottomSheet extends StatefulWidget {
  final List<Comment> comments;
  final String title;
  final void Function(String text)? onSubmitComment;
  final void Function(String text, Comment parent)? onSubmitReply;
  final void Function(int index)? onTapReply;
  final void Function(int index)? onToggleLike;
  final void Function(Comment reply, int index)? onToggleReplyLike;
  final void Function(Comment comment)? onTapMore;
  final void Function(Comment reply)? onTapReplyMore;

  const CommentBottomSheet({
    super.key,
    required this.comments,
    this.title = '댓글',
    this.onSubmitComment,
    this.onSubmitReply,
    this.onTapReply,
    this.onToggleLike,
    this.onToggleReplyLike,
    this.onTapMore,
    this.onTapReplyMore,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentCtrl = TextEditingController();
  final TextEditingController _replyCtrl = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _replyFocusNode = FocusNode();
  int? _activeReplyIndex;

  @override
  void dispose() {
    _commentCtrl.dispose();
    _replyCtrl.dispose();
    _commentFocusNode.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  void _handleTapReply(int index) {
    widget.onTapReply?.call(index);
    setState(() {
      _activeReplyIndex = index;
      _replyCtrl.clear();
    });
    _replyFocusNode.requestFocus();
  }

  void _cancelReply() {
    if (_activeReplyIndex == null) return;
    setState(() {
      _activeReplyIndex = null;
      _replyCtrl.clear();
    });
  }

  void _handleSubmit() {
    if (_activeReplyIndex != null) {
      final text = _replyCtrl.text.trim();
      if (text.isEmpty) return;
      final parent = widget.comments[_activeReplyIndex!];
      widget.onSubmitReply?.call(text, parent);
      _replyCtrl.clear();
      _cancelReply();
      return;
    }

    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    widget.onSubmitComment?.call(text);
    _commentCtrl.clear();
  }

  String? get _replyNickname {
    final index = _activeReplyIndex;
    if (index == null || index < 0 || index >= widget.comments.length) {
      return null;
    }
    return widget.comments[index].nickName;
  }

  List<Comment> _repliesFor(int index) {
    if (index < 0 || index >= widget.comments.length) return const [];
    return widget.comments[index].replies ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    double sheetHeight = math.min(
      MediaQuery.of(context).size.height * 0.58,
      530,
    );

    final isReplyMode = _activeReplyIndex != null;
    final controller = isReplyMode ? _replyCtrl : _commentCtrl;
    final focusNode = isReplyMode ? _replyFocusNode : _commentFocusNode;

    return SafeArea(
      top: false,
      bottom: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Align(
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
                      _cancelReply();
                    },
                    child: ListView(
                      padding: EdgeInsets.zero,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        CommentList(
                          comments: widget.comments,
                          activeReplyIndex: _activeReplyIndex,
                          repliesFor: _repliesFor,
                          onTapReply: _handleTapReply,
                          onToggleLike:
                              (index) => widget.onToggleLike?.call(index),
                          onToggleReplyLike:
                              (reply, index) =>
                                  widget.onToggleReplyLike?.call(reply, index),
                          onTapMore:
                              (comment) => widget.onTapMore?.call(comment),
                          onTapReplyMore:
                              (reply) => widget.onTapReplyMore?.call(reply),
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
                  replyNickname: _replyNickname,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
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
