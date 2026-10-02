import 'package:flutter/material.dart';

/// แสดงระหว่างตรวจ session ตอนเปิดแอป
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}