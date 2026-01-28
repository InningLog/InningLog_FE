import 'package:flutter/material.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:inninglog/feature/community/viewmodel/post_comment_view_model.dart';
import 'package:inninglog/feature/community/viewmodel/post_detail_view_model.dart';
import 'package:inninglog/feature/community/repositories/comment_repository.dart';
import 'package:inninglog/feature/community/repositories/post_repository.dart';
import 'package:inninglog/feature/community/widgets/comment/comment_input_bar.dart';
import 'package:inninglog/feature/community/widgets/comment/comment_list.dart';
import 'package:inninglog/feature/community/widgets/post_detail/post_action_bar.dart';
import 'package:inninglog/feature/community/widgets/post_detail/post_detail_app_bar.dart';
import 'package:inninglog/feature/community/widgets/post_detail/post_header_section.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/widgets/bottom_action_sheet.dart';
import 'package:provider/provider.dart';

class PostDetailPage extends StatefulWidget {
  final String teamCode;
  final int postId;

  const PostDetailPage({
    super.key,
    required this.teamCode,
    required this.postId,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage>
    with WidgetsBindingObserver {
  late final PostDetailViewModel _vm;
  late final CommunityPostRepository _repo;
  late final CommentRepository _commentRepo;
  final ScrollController _scrollController = ScrollController();
  double _lastKeyboardInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final scope = context.read<AppScope>();
    _repo = scope.communityPostRepository;
    _commentRepo = scope.commentRepository;
    _vm = PostDetailViewModel(repo: _repo, postId: widget.postId)..fetch();
  }

  @override
  void dispose() {
    _vm.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final nextInset = view.viewInsets.bottom / view.devicePixelRatio;
    if (nextInset == _lastKeyboardInset) return;
    final delta = nextInset - _lastKeyboardInset;
    _lastKeyboardInset = nextInset;
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final nextOffset = (_scrollController.offset + delta).clamp(0.0, max);
      _scrollController.jumpTo(nextOffset);
    });
  }

  Future<void> _confirmDelete(PostDetailViewModel vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('게시글 삭제'),
            content: const Text('이 게시글을 삭제하시겠어요?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text(
                  '삭제',
                  style: TextStyle(color: AppColors.secondary700),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    final success = await vm.deletePost();
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글 삭제에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PostDetailViewModel>.value(value: _vm),
        ChangeNotifierProvider<PostCommentViewModel>(
          create:
              (_) =>
                  PostCommentViewModel(
                    postId: widget.postId,
                    repo: _commentRepo,
                  )
                    ..fetchComments(),
        ),
      ],
      child: Consumer2<PostDetailViewModel, PostCommentViewModel>(
        builder: (context, vm, commentVm, _) {
          final post = vm.post;
          final teamCode = post?.teamCode ?? widget.teamCode;
          final teamLabel =
              teamCode == 'ALL' ? 'KBO 전체게시판' : kboTeamLabelOf(teamCode);
          final commentCount =
              vm.commentCount > 0 ? vm.commentCount : commentVm.comments.length;

          return Scaffold(
            backgroundColor: AppColors.primary50,
            resizeToAvoidBottomInset: true,
            appBar: PostDetailAppBar(
              teamLabel: teamLabel,
              onBack: () => Navigator.pop(context),
              onTapMore: () {
                final writeByMe = post?.writeByMe ?? false;
                if (writeByMe) {
                  showBottomActionSheet(
                    context,
                    actions: [
                      BottomActionSheetAction(
                        label: '수정',
                        onTap: () {
                          // TODO: 수정 로직 연결
                        },
                      ),
                      BottomActionSheetAction(
                        label: '삭제',
                        isDestructive: true,
                        onTap: () {
                          _confirmDelete(vm);
                        },
                      ),
                    ],
                  );
                  return;
                }
                // TODO: 신고/공유 bottom sheet 등
              },
            ),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        commentVm.cancelReply();
                      },
                      child: ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [
                          PostSection(
                            content: post?.content ?? '',
                            createAt: post?.createdAt ?? '',
                            nickName: post?.nickName ?? '',
                            title: post?.title ?? '',
                            imageUrls:
                                post?.images.map((e) => e.url).toList() ??
                                const [],
                            profileUrl: post?.profileUrl,
                          ),
                          PostActionBar(
                            likeActive: vm.likedByMe,
                            likeCount: vm.likeCount,
                            onTapLike: vm.toggleLike,
                            scrapActive: vm.scrapedByMe,
                            scrapCount: vm.scrapCount,
                            onTapScrap: vm.toggleScrap,
                            commentCount: commentCount,
                          ),
                          Container(height: 8, color: AppColors.gray200),
                          CommentList(
                            comments: commentVm.comments,
                            activeReplyIndex: commentVm.activeReplyIndex,
                            repliesFor: commentVm.repliesFor,
                            onTapReply: commentVm.startReply,
                            onToggleLike: commentVm.toggleCommentLike,
                            onToggleReplyLike:
                                (reply, index) =>
                                    commentVm.toggleReplyLike(index, reply),
                            onTapMore: (_) {},
                            onTapReplyMore: (_) {},
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: CommentInputBar(
                      controller:
                          commentVm.isReplyMode
                              ? commentVm.replyController
                              : commentVm.commentController,
                      focusNode:
                          commentVm.isReplyMode
                              ? commentVm.replyFocusNode
                              : commentVm.commentFocusNode,
                      isReplyMode: commentVm.isReplyMode,
                      replyNickname: commentVm.activeReplyNickname,
                      onPressed:
                          commentVm.isReplyMode
                              ? commentVm.submitReply
                              : commentVm.submitComment,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
