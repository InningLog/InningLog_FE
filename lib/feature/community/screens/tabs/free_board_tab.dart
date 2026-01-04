import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/feature/community/model/community_post.dart';
import 'package:inninglog/feature/community/viewmodel/post_list_view_model.dart';
import 'package:inninglog/feature/community/widgets/post/post_item_card.dart';
import 'package:inninglog/feature/community/widgets/shared/board_list.dart';
import 'package:inninglog/router/route_observer.dart';
import 'package:inninglog/shared/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class FreeBoardTab extends StatefulWidget {
  final String teamCode;
  const FreeBoardTab({super.key, required this.teamCode});

  @override
  State<FreeBoardTab> createState() => _FreeBoardTabState();
}

class _FreeBoardTabState extends State<FreeBoardTab> with RouteAware {
  bool _initialized = false;
  NavigatorObserver? _subscribedObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<PostListViewModel>().ensureLoaded();
    }

    _subscribeRouteObserver();
  }

  @override
  void dispose() {
    final route = ModalRoute.of(context);
    if (route != null && _subscribedObserver != null) {
      if (_subscribedObserver == shellRouteObserver) {
        shellRouteObserver.unsubscribe(this);
      } else if (_subscribedObserver == rootRouteObserver) {
        rootRouteObserver.unsubscribe(this);
      }
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    context.read<PostListViewModel>().refresh();
  }

  void _subscribeRouteObserver() {
    if (_subscribedObserver != null) return;
    final route = ModalRoute.of(context);
    if (route == null) return;

    final observers = route.navigator?.widget.observers ?? const <NavigatorObserver>[];

    if (observers.contains(shellRouteObserver)) {
      shellRouteObserver.subscribe(this, route);
      _subscribedObserver = shellRouteObserver;
    } else if (observers.contains(rootRouteObserver)) {
      rootRouteObserver.subscribe(this, route);
      _subscribedObserver = rootRouteObserver;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostListViewModel>(
      builder: (context, vm, _) {
        if (vm.items.isEmpty && !vm.isLoading) {
          return const EmptyState(message: '게시물이 없습니다.');
        }

        return BoardList<CommunityPostItem>(
          items: vm.items,
          hasNext: vm.hasNext,
          isLoading: vm.isLoading,
          onLoadMore: vm.loadMore,
          itemBuilder:
              (context, item) => PostItemCard(
                item: item,
                onTap:
                    () => context.push(
                      '/boards/${widget.teamCode}/post/${item.id}',
                    ),
              ),
        );
      },
    );
  }
}
