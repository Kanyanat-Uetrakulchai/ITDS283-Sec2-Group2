import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search page')),
      body: Center(child: Text('Search page', style: TextStyle(fontSize: 24))),
    );
  }
}
