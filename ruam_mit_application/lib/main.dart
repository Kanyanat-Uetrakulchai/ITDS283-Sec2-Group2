import 'package:flutter/material.dart';
import 'package:ruam_mit_application/pages/home_page.dart';
import 'pages/loading_page.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Routes',
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/loading': (context) => LoadingPage(),
      },
    );
  }
}
