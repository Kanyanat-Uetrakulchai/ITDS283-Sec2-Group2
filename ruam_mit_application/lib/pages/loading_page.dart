import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:typewritertext/typewritertext.dart';


class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      backgroundColor: const Color(0xffD63939),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/app_logo.jpg'
          ),
          // SvgPicture.asset(
          //   'assets/app_logo.svg',
          //   // width: 65,
          //   // height: 65,
          //   allowDrawingOutsideViewBox: true,
          // ),
          // SizedBox(height: 20,),
          TypeWriter.text(
            'loading . . .',
            style: TextStyle(
              color: Colors.white,
            ),
            duration: const Duration(milliseconds: 50),
            repeat: true,
          )
      ],),
    );
  }
}