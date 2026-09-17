import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// One full-canvas (96×96) layer of a tab icon.
class SvgLayer extends StatelessWidget {
  const SvgLayer(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/icons/$name.svg', width: 96, height: 96);
}
