import 'dart:async';

import 'package:flutter/widgets.dart';

/// Completes once the route of [context] has finished coming in. One-off
/// work that stalls a frame, like a first shader draw or a big render, is
/// put off until then so it does not land in the middle of the transition.
///
/// Reads the route, so it is called from `didChangeDependencies` or later.
Future<void> routeSettled(BuildContext context) {
  final animation = ModalRoute.of(context)?.animation;
  if (animation == null || animation.status != AnimationStatus.forward) {
    return Future.value();
  }
  final settled = Completer<void>();
  void listener(AnimationStatus status) {
    if (status == AnimationStatus.forward) return;
    animation.removeStatusListener(listener);
    settled.complete();
  }

  animation.addStatusListener(listener);
  return settled.future;
}
