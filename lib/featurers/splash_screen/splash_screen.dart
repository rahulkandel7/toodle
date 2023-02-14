import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toddle/featurers/auth/presentation/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 2),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: FadeInImage(
        placeholder: AssetImage(
          'assets/images/logo.png',
        ),
        image: AssetImage(
          'assets/images/logo.png',
        ),
      )),
    );
  }
}
