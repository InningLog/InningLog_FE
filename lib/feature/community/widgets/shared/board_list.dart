import 'package:flutter/material.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

typedef ScoreGetter<T> = int Function(T item);
typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);

class BoardList<T> extends StatelessWidget {
  final List<T> items;
  final ItemBuilder<T> itemBuilder;

  const BoardList({super.key, required this.items, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    final data = List<T>.from(items);

    return ListView.separated(
      itemCount: data.length,
      separatorBuilder:
          (_, __) => Container(
            width: double.infinity,
            height: 1,
            color: AppColors.gray200,
          ),
      itemBuilder: (context, i) => itemBuilder(context, data[i]),
    );
  }
}
