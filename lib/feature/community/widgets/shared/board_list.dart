import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);

class BoardList<T> extends StatefulWidget {
  final List<T> items;
  final ItemBuilder<T> itemBuilder;
  final Future<void> Function()? onLoadMore;
  final bool isLoading;
  final bool hasNext;

  const BoardList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.isLoading = false,
    this.hasNext = false,
  });

  @override
  State<BoardList<T>> createState() => _BoardListState<T>();
}

class _BoardListState<T> extends State<BoardList<T>> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onLoadMore == null) return;
    if (!widget.hasNext || widget.isLoading) return;
    const threshold = 200;
    if (_scrollCtrl.position.pixels + threshold >=
        _scrollCtrl.position.maxScrollExtent) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = List<T>.from(widget.items);
    final showLoader = widget.hasNext || widget.isLoading;

    return ListView.separated(
      controller: _scrollCtrl,
      itemCount: showLoader ? data.length + 1 : data.length,
      separatorBuilder:
          (_, __) => Container(
            width: double.infinity,
            height: 1,
            color: AppColors.gray200,
          ),
      itemBuilder: (context, i) {
        if (showLoader && i >= data.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return widget.itemBuilder(context, data[i]);
      },
    );
  }
}
