import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/l10n/app_localizations.dart';

/// Builds a sliver once [value] has loaded, with a spinner and an error
/// message until then.
class AsyncSliver<T> extends StatelessWidget {
  const AsyncSliver({
    super.key,
    required this.value,
    required this.builder,
    this.fillRemaining = false,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) builder;

  /// Whether the spinner and the error take the rest of the page.
  final bool fillRemaining;

  @override
  Widget build(BuildContext context) => switch (value) {
    AsyncData(:final value) => builder(value),
    AsyncError(:final error) => _box(
      Center(
        child: Text(AppLocalizations.of(context)!.loadingFailed('$error')),
      ),
    ),
    _ => _box(const Center(child: CircularProgressIndicator())),
  };

  Widget _box(Widget child) => fillRemaining
      ? SliverFillRemaining(hasScrollBody: false, child: child)
      : SliverToBoxAdapter(
          child: Padding(padding: const EdgeInsets.all(32), child: child),
        );
}
