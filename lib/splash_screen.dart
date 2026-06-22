import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';
import 'screens/task_page.dart';

class SplashScreen extends StatefulWidget {
  final String? token;

  const SplashScreen({
    super.key,
    this.token,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            if (widget.token != null) {
              return TaskPage(
                token: widget.token!,
              );
            } else {
              return const LoginPage();
            }
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D47A1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),
            const Text(
              "TASK APP MANAGEMENT",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
