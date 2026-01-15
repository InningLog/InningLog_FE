import 'package:flutter/material.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:inninglog/feature/community/model/comment.dart';
import 'package:inninglog/feature/community/viewmodel/post_detail_view_model.dart';
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

  final Map<int, List<Comment>> _replies = {};

  int? _activeReplyIndex;
  final _replyCtrl = TextEditingController();

  final _commentCtrl = TextEditingController();

  final List<Comment> comments = List<Comment>.of(dummyComments);

  @override
  void initState() {
    super.initState();
    final repo = context.read<AppScope>().communityPostRepository;
    _vm = PostDetailViewModel(repo: repo, postId: widget.postId)..fetch();
  }

  @override
  void dispose() {
    _vm.dispose();
    _commentCtrl.dispose();
    _replyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailViewModel>.value(
      value: _vm,
      child: Consumer<PostDetailViewModel>(
        builder: (context, vm, _) {
          final post = vm.post;
          final teamCode = post?.teamCode ?? widget.teamCode;
          final teamLabel =
              teamCode == 'ALL' ? 'KBO 전체게시판' : kboTeamLabelOf(teamCode);
          final commentCount =
              vm.commentCount > 0 ? vm.commentCount : comments.length;

          return Scaffold(
            backgroundColor: AppColors.primary50,
            appBar: PostDetailAppBar(
              teamLabel: teamLabel,
              onBack: () => Navigator.pop(context),
              onTapMore: () {
                // TODO: 신고/삭제/공유 bottom sheet 등
              },
            ),
            bottomNavigationBar:
                (_activeReplyIndex == null)
                    ? CommentInputBar(
                      controller: _commentCtrl,
                      onPressed: _submitComment,
                    )
                    : CommentInputBar(
                      controller: _replyCtrl,
                      isReplyMode: true,
                      replyNickname: _activeReplyNickname,
                      onPressed: _submitReply,
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

                if (comments.isEmpty)
                  const EmptyComment()
                else
                  ...comments.map(_commentItem),
                const SizedBox(height: 6),
              ],
            ),
          );
        },
      ),
    );
  }

  String? get _activeReplyNickname {
    final index = _activeReplyIndex;
    if (index == null || index < 0 || index >= comments.length) return null;
    return comments[index].nickName;
  }

  void _submitComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      comments.add(
        Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          nickName: '닉네임',
          content: text,
          createdAt: '방금',
          likedByMe: false,
          likeCount: 0,
        ),
      );
      _commentCtrl.clear();
    });
  }

  void _submitReply() {
    final index = _activeReplyIndex;
    if (index == null || index < 0 || index >= comments.length) return;
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      final cur = List<Comment>.from(_replies[index] ?? const []);
      cur.add(
        Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          nickName: '나나ㅏ나',
          content: text.trim(),
          createdAt: '방금',
          likeCount: 0,
          likedByMe: false,
        ),
      );

      _replies[index] = cur;
      _activeReplyIndex = null;
      _replyCtrl.clear();
    });
  }

  void _toggleCommentLike(int index) {
    final current = comments[index];
    final liked = !current.likedByMe;
    final likeCount = liked ? current.likeCount + 1 : current.likeCount - 1;
    comments[index] = Comment(
      id: current.id,
      nickName: current.nickName,
      content: current.content,
      createdAt: current.createdAt,
      profileUrl: current.profileUrl,
      likeCount: likeCount,
      likedByMe: liked,
    );
  }

  void _toggleReplyLike(int index, Comment reply) {
    final replies = List<Comment>.from(_replies[index] ?? const []);
    final replyIndex = replies.indexOf(reply);
    if (replyIndex == -1) return;

    final current = replies[replyIndex];
    final liked = !current.likedByMe;
    final likeCount = liked ? current.likeCount + 1 : current.likeCount - 1;
    replies[replyIndex] = Comment(
      id: current.id,
      nickName: current.nickName,
      content: current.content,
      createdAt: current.createdAt,
      profileUrl: current.profileUrl,
      likeCount: likeCount,
      likedByMe: liked,
    );

    _replies[index] = replies;
  }

  Widget _commentItem(Comment c) {
    final idx = comments.indexOf(c);
    final bool isReplyingThis = _activeReplyIndex == idx;
    final List<Comment> replies = _replies[idx] ?? const <Comment>[];

    return CommentItem(
      comment: c,
      isReplying: isReplyingThis,
      onTapReply: () {
        setState(() {
          _activeReplyIndex = idx;
          _replyCtrl.clear();
        });
      },
      onToggleLike: () => setState(() => _toggleCommentLike(idx)),
      onTapMore: () {},
      replies: replies,
      onToggleReplyLike:
          (reply) => setState(() => _toggleReplyLike(idx, reply)),
      onTapReplyMore: (_) {},
    );
  }
}
