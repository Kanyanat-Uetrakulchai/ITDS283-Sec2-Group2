import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    );
  }

  AppBar _appBar() {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xffD63939),
      centerTitle: true,
      title: Image.asset(
        'assets/app_logo.png',
        fit: BoxFit.contain,
        height: 45,
      ),
    );
  }
}
