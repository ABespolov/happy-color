import 'package:flutter/material.dart';

/// Keeps every tab alive and slides between them like a pager.
class TabSwitcher extends StatefulWidget {
  const TabSwitcher({super.key, required this.index, required this.children});

  final int index;
  final List<Widget> children;

  static const _duration = Duration(milliseconds: 320);
  static const _curve = Curves.easeOutCubic;

  @override
  State<TabSwitcher> createState() => _TabSwitcherState();
}

class _TabSwitcherState extends State<TabSwitcher>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(
    vsync: this,
    duration: TabSwitcher._duration,
    value: 1,
  );

  late int _previous = widget.index;
  var _forward = true;

  @override
  void didUpdateWidget(TabSwitcher old) {
    super.didUpdateWidget(old);
    if (old.index == widget.index) return;
    _previous = old.index;
    _forward = widget.index > old.index;
    _animation.forward(from: 0);
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final t = TabSwitcher._curve.transform(_animation.value);
        return Stack(
          children: [
            for (var i = 0; i < widget.children.length; i++)
              _tab(i, t, child: widget.children[i]),
          ],
        );
      },
    );
  }

  Widget _tab(int index, double t, {required Widget child}) {
    final selected = index == widget.index;
    final leaving = index == _previous && !selected && t < 1;
    final shown = selected || leaving;
    final direction = _forward ? 1.0 : -1.0;
    final offset = selected ? direction * (1 - t) : -direction * t;
    // The shape of this wrapping never changes: swapping a widget here
    // would rebuild the tab underneath from scratch.
    return Offstage(
      key: ValueKey(index),
      offstage: !shown,
      child: TickerMode(
        enabled: shown,
        child: IgnorePointer(
          ignoring: !selected,
          child: FractionalTranslation(
            translation: Offset(shown ? offset : 0, 0),
            child: child,
          ),
        ),
      ),
    );
  }
}
