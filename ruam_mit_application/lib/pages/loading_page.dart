import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:typewritertext/typewritertext.dart';


class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      backgroundColor: const Color(0xffD63939),
      body: Center( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/app_logo.png')
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'loading ',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                TypeWriter.text(
                  '. . . . ',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  duration: const Duration(milliseconds: 50),
                  repeat: true,
                )
              ],
              
            )
            
          ],
        )
      ),
    );
  }
}