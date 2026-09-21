import 'dart:async';

import 'package:flutter/widgets.dart';

/// Completes once the route of [context] is neither coming in nor being
/// uncovered by a route above it going away. One-off work that stalls a
/// frame, like a first shader draw or a big render, is put off until then so
/// it does not land in the middle of a transition.
///
/// Reads the route, so it is called from `didChangeDependencies` or later.
Future<void> routeSettled(BuildContext context) async {
  final route = ModalRoute.of(context);
  if (route == null) return;
  for (final animation in [route.animation, route.secondaryAnimation]) {
    if (animation != null && animation.isAnimating) await _stopped(animation);
  }
}

Future<void> _stopped(Animation<double> animation) {
  final stopped = Completer<void>();
  void listener(AnimationStatus status) {
    if (status.isAnimating) return;
    animation.removeStatusListener(listener);
    stopped.complete();
  }

  animation.addStatusListener(listener);
  return stopped.future;
}
