import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/app/startup.dart';
import 'package:happy_color/core/widgets/page_header.dart';
import 'package:happy_color/l10n/app_localizations.dart';

/// Holds the splash screen until the first pictures are ready.
class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  /// Shown at least this long, so a fast start does not flash.
  static const _minimum = Duration(milliseconds: 500);

  static const _fade = Duration(milliseconds: 450);

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
  var _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _warmUp());
  }

  Future<void> _warmUp() async {
    final startup = ref.read(startupProvider);
    await Future.wait([
      startup.warmUp(context),
      Future<void>.delayed(SplashGate._minimum),
    ]);
    if (!mounted) return;
    setState(() => _ready = true);
    // The other screens are warmed up once the splash has faded out, so the
    // fade does not share its frames with the decoding.
    await Future<void>.delayed(SplashGate._fade);
    if (mounted) await startup.warmUpBehind(context);
  }

  @override
  Widget build(BuildContext context) {
    // The gradient sits behind the switch as well, so nothing black shows
    // through while the splash fades into the app.
    return DecoratedBox(
      decoration: PageHeader.background,
      child: AnimatedSwitcher(
        duration: SplashGate._fade,
        child: _ready ? widget.child : const _Splash(),
      ),
    );
  }
}

class _Splash extends StatefulWidget {
  const _Splash();

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> with SingleTickerProviderStateMixin {
  late final _breathing = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breathing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: PageHeader.background,
      // Without this the text would come with the debug underline that marks
      // text drawn outside a Material.
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          // The title breathes while the pictures are being warmed up.
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.04).animate(
              CurvedAnimation(parent: _breathing, curve: Curves.easeInOutSine),
            ),
            child: Text(
              AppLocalizations.of(context)!.appTitle,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
