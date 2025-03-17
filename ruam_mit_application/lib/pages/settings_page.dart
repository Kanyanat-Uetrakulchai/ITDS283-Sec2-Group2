import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings page')),
      body: Center(
        child: Text('Settings page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
