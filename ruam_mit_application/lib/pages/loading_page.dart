import 'package:flutter/material.dart';
import 'package:typewritertext/typewritertext.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'bottomNav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await Future.delayed(const Duration(seconds: 2)); // Optional delay

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Bottomnav()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD63939),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(image: AssetImage('assets/app_logo.png')),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('loading ', style: TextStyle(color: Colors.white)),
                TypeWriter.text(
                  '. . . . ',
                  style: TextStyle(color: Colors.white),
                  duration: Duration(milliseconds: 50),
                  repeat: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
