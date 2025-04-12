import 'package:flutter/material.dart';
import 'package:typewritertext/typewritertext.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    // Delay navigation by 1000ms (1 second)
    Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD63939),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/app_logo.png')),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'loading ',
                  style: TextStyle(color: Colors.white),
                ),
                TypeWriter.text(
                  '. . . . ',
                  style: TextStyle(color: Colors.white),
                  duration: const Duration(milliseconds: 50),
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