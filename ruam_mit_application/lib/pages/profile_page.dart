import 'package:flutter/material.dart';
// import 'bottomNav.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile page')),
      body: Center(child: Text('Profile page', style: TextStyle(fontSize: 24))),
    );
  }
}
