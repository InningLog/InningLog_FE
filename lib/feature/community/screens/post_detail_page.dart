import 'package:flutter/material.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:inninglog/feature/community/model/comment.dart';
import 'package:inninglog/feature/community/viewmodel/post_comment_view_model.dart';
import 'package:inninglog/feature/community/viewmodel/post_detail_view_model.dart';
import 'package:inninglog/feature/community/repositories/post_repository.dart';
import 'package:inninglog/feature/community/widgets/comment/comment_input_bar.dart';
import 'package:inninglog/feature/community/widgets/comment/comment_item.dart';
import 'package:inninglog/feature/community/widgets/comment/empty_comment.dart';
import 'package:inninglog/feature/community/widgets/post_detail/post_action_bar.dart';
import 'package:inninglog/feature/community/widgets/post_detail/post_detail_app_bar.dart';
import 'package:inninglog/feature/community/widgets/post_detail/post_header_section.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
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

class _PostDetailPageState extends State<PostDetailPage> {
  late final PostDetailViewModel _vm;
  late final CommunityPostRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = context.read<AppScope>().communityPostRepository;
    _vm = PostDetailViewModel(repo: _repo, postId: widget.postId)..fetch();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PostDetailViewModel>.value(value: _vm),
        ChangeNotifierProvider<PostCommentViewModel>(
          create:
              (_) =>
                  PostCommentViewModel(postId: widget.postId, repo: _repo)
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
            appBar: PostDetailAppBar(
              teamLabel: teamLabel,
              onBack: () => Navigator.pop(context),
              onTapMore: () {
                // TODO: 신고/삭제/공유 bottom sheet 등
              },
            ),
            bottomNavigationBar: CommentInputBar(
              controller:
                  commentVm.isReplyMode
                      ? commentVm.replyController
                      : commentVm.commentController,
              isReplyMode: commentVm.isReplyMode,
              replyNickname: commentVm.activeReplyNickname,
              onPressed:
                  commentVm.isReplyMode
                      ? commentVm.submitReply
                      : commentVm.submitComment,
            ),
            body: ListView(
              children: [
                PostSection(
                  content: post?.content ?? '',
                  createAt: post?.createdAt ?? '',
                  nickName: post?.nickName ?? '',
                  title: post?.title ?? '',
                  imageUrls:
                      post?.images.map((e) => e.url).toList() ?? const [],
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
                const Divider(height: 8, color: AppColors.gray200),
                if (commentVm.comments.isEmpty)
                  const EmptyComment()
                else
                  ...commentVm.comments.map(
                    (comment) => _commentItem(comment, commentVm),
                  ),
                const SizedBox(height: 6),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _commentItem(Comment comment, PostCommentViewModel vm) {
    final idx = vm.comments.indexOf(comment);
    final bool isReplyingThis = vm.activeReplyIndex == idx;
    final List<Comment> replies = vm.repliesFor(idx);
    return CommentItem(
      comment: comment,
      isReplying: isReplyingThis,
      onTapReply: () {
        vm.startReply(idx);
      },
      onToggleLike: () => vm.toggleCommentLike(idx),
      onTapMore: () {},
      replies: replies,
      onToggleReplyLike: (reply) => vm.toggleReplyLike(idx, reply),
      onTapReplyMore: (_) {},
    );
  }
}
