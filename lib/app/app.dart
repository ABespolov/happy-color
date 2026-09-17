import 'package:flutter/material.dart';
import 'package:happy_color/app/home_shell.dart';

class HappyColorApp extends StatelessWidget {
  const HappyColorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeShell(),
    );
  }
}
