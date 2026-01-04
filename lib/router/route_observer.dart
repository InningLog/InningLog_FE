import 'package:flutter/widgets.dart';

/// RouteObserver for the root navigator (outside ShellRoute).
final RouteObserver<ModalRoute<void>> rootRouteObserver =
    RouteObserver<ModalRoute<void>>();

/// RouteObserver for the shell navigator (inside ShellRoute).
final RouteObserver<ModalRoute<void>> shellRouteObserver =
    RouteObserver<ModalRoute<void>>();
