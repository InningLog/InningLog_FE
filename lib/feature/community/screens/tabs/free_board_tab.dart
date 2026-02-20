import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/feature/community/model/community_post.dart';
import 'package:inninglog/feature/community/screens/teamboard_page.dart';
import 'package:inninglog/feature/community/viewmodel/post_list_view_model.dart';
import 'package:inninglog/feature/community/widgets/post/post_item_card.dart';
import 'package:inninglog/feature/community/widgets/shared/board_list.dart';
import 'package:inninglog/router/route_observer.dart';
import 'package:inninglog/router/app_routes.dart';
import 'package:inninglog/shared/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class FreeBoardTab extends StatefulWidget {
  /// normal 모드에서만 필수. 그 외 모드는 null 가능.
  final String? teamCode;
  final bool isActive;
  final BoardMode mode;

  const FreeBoardTab({
    super.key,
    this.teamCode,
    this.isActive = false,
    this.mode = BoardMode.normal,
  });

  @override
  State<FreeBoardTab> createState() => _FreeBoardTabState();
}

class _FreeBoardTabState extends State<FreeBoardTab> with RouteAware {
  bool _initialized = false;
  NavigatorObserver? _subscribedObserver;
  ModalRoute<dynamic>? _route;
  late final PostListViewModel _vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // 탭 최초 진입 시 한 번만 초기 목록을 불러온다.
      _vm.ensureLoaded();
    }

    // 상세/작성 페이지에서 돌아올 때 pop 이벤트를 받을 수 있도록
    // 현재 네비게이터에 맞는 observer를 구독한다.
    _route ??= ModalRoute.of(context);
    _subscribeRouteObserver();
  }

  @override
  void didUpdateWidget(covariant FreeBoardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 다른 탭에서 자유게시판 탭으로 복귀하면 최신 데이터로 갱신한다.
    if (!oldWidget.isActive && widget.isActive) {
      _vm.refresh();
    }
  }

  @override
  void initState() {
    super.initState();
    final repo = context.read<AppScope>().communityPostRepository;
    final PostFetcher fetcher;
    switch (widget.mode) {
      case BoardMode.normal:
        fetcher = (page, size) => repo.getPostList(
              teamCode: widget.teamCode!,
              page: page,
              size: size,
            );
      case BoardMode.myPosts:
        fetcher = (page, size) => repo.getMyPosts(page: page, size: size);
      case BoardMode.myComments:
        fetcher = (page, size) =>
            repo.getMyCommentedPosts(page: page, size: size);
      case BoardMode.scraps:
        fetcher = (page, size) =>
            repo.getMyScrappedPosts(page: page, size: size);
      case BoardMode.popular:
        fetcher = (page, size) =>
            repo.getPopularPosts(page: page, size: size);
    }
    _vm = PostListViewModel(fetcher: fetcher);
  }

  @override
  void dispose() {
    final route = _route;
    if (route != null && _subscribedObserver != null) {
      if (_subscribedObserver == shellRouteObserver) {
        shellRouteObserver.unsubscribe(this);
      } else if (_subscribedObserver == rootRouteObserver) {
        rootRouteObserver.unsubscribe(this);
      }
    }
    _vm.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    // 상세/작성 화면에서 뒤로가기(pop)로 돌아오면 목록을 새로고침한다.
    _vm.refresh();
  }

  void _subscribeRouteObserver() {
    if (_subscribedObserver != null) return;
    final route = ModalRoute.of(context);
    if (route == null) return;

    final observers =
        route.navigator?.widget.observers ?? const <NavigatorObserver>[];

    if (observers.contains(shellRouteObserver)) {
      // ShellRoute 내부라면 shell observer를 우선 사용한다.
      shellRouteObserver.subscribe(this, route);
      _subscribedObserver = shellRouteObserver;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<PostListViewModel>(
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
                        AppRoutePaths.boardPostDetailLocation(
                          widget.mode == BoardMode.normal
                              ? widget.teamCode!
                              : item.teamCode,
                          item.id,
                        ),
                      ),
                ),
          );
        },
      ),
    );
  }
}
