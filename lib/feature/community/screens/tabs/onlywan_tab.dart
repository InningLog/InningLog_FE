import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/model/comment_domain_type.dart';
import 'package:inninglog/feature/community/viewmodel/comment_view_model.dart';
import 'package:inninglog/feature/community/viewmodel/diary_feed_view_model.dart';
import 'package:inninglog/feature/community/widgets/comment/comment_bottom_sheet.dart';
import 'package:inninglog/feature/community/widgets/onlywan/diary_item.dart';
import 'package:inninglog/feature/community/widgets/shared/board_list.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/widgets/bottom_action_sheet.dart';
import 'package:inninglog/shared/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class OnlyWanTab extends StatefulWidget {
  final String teamCode;
  final bool isActive;

  const OnlyWanTab({super.key, required this.teamCode, this.isActive = false});

  @override
  State<OnlyWanTab> createState() => _OnlyWanTabState();
}

class _OnlyWanTabState extends State<OnlyWanTab> {
  bool _initialized = false;
  late final DiaryFeedViewModel _vm;

  @override
  void initState() {
    super.initState();
    final repo = context.read<AppScope>().diaryRepository;
    _vm = DiaryFeedViewModel(repo: repo, teamCode: widget.teamCode);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _vm.ensureLoaded();
    }
  }

  @override
  void didUpdateWidget(covariant OnlyWanTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _vm.refresh();
    }
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: '게시글 삭제',
      message: '이 게시글을 삭제하시겠어요?',
      okLabel: '삭제',
      cancelLabel: '취소',
      isDestructiveAction: true,
    );

    if (result != OkCancelResult.ok || !mounted) return;
    // TODO(community): 내 직관일지 삭제 API
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<DiaryFeedViewModel>(
        builder: (context, vm, _) {
          final Widget content;
          if (vm.items.isEmpty && !vm.isLoading) {
            content = const EmptyState(message: '게시물이 없습니다.');
          } else {
            content = BoardList<DiaryItemModel>(
              items: vm.items,
              hasNext: vm.hasNext,
              isLoading: vm.isLoading,
              onLoadMore: vm.loadMore,
              itemBuilder:
                  (context, item) => DiaryItem(
                    item: item,
                    onTapMore: () {
                      if (!item.writeByMe) return;
                      showBottomActionSheet(
                        context,
                        actions: [
                          BottomActionSheetAction(
                            label: '수정',
                            onTap: () {
                              // TODO(community): 내 직관일지 수정 플로우 연결
                            },
                          ),
                          BottomActionSheetAction(
                            label: '삭제',
                            isDestructive: true,
                            onTap: () {
                              // TODO(community): 내 직관일지 삭제 API 및 확인 다이얼로그 연결
                              _confirmDelete();
                            },
                          ),
                        ],
                      );
                    },
                    onTapLike: () => vm.toggleLike(journalId: item.journalId),
                    onTapComment: () {
                      final repo = context.read<AppScope>().commentRepository;
                      final commentVm = CommentViewModel(
                        domainType: CommentDomainType.feed,
                        domainId: item.journalId,
                        repo: repo,
                      );
                      showCommentBottomSheet(
                        context,
                        viewModel: commentVm,
                        onCommentCountChanged:
                            (count) => vm.updateCommentCount(
                              journalId: item.journalId,
                              count: count,
                            ),
                      );
                    },
                    onTapScrap: () => vm.toggleScrap(journalId: item.journalId),
                  ),
            );
          }
          return Container(color: AppColors.primary50, child: content);
        },
      ),
    );
  }
}
