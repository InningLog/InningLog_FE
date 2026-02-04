import 'package:flutter/material.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/feature/community/viewmodel/diary_feed_view_model.dart';
import 'package:inninglog/feature/community/widgets/onlywan/diary_list.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<DiaryFeedViewModel>(
        builder: (context, vm, _) {
          return Container(
            color: AppColors.primary50,
            child: FeedList(
              items: vm.items,
              hasNext: vm.hasNext,
              isLoading: vm.isLoading,
              onLoadMore: vm.loadMore,
            ),
          );
        },
      ),
    );
  }
}
