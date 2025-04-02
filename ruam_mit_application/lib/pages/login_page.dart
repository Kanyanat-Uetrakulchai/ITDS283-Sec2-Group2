import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:typewritertext/typewritertext.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: Center( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/app_logo_white.png')
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
              'เข้าสู่ระบบ'
              ),
            )
          ],
        )
      ),
    );
  }
}