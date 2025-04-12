import 'package:flutter/material.dart';
import 'package:ruam_mit_application/pages/bottomNav.dart';
import 'package:ruam_mit_application/pages/home_page.dart';
import 'package:ruam_mit_application/pages/login_page.dart';
// import 'package:ruam_mit_application/pages/home_page.dart';
// import 'pages/profile_page.dart';
import 'pages/loading_page.dart';
import 'pages/newPost_page.dart';
import 'pages/settings_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async{
  await dotenv.load(fileName: ".env");
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
        '/': (context) => Bottomnav(),
        '/loading': (context) => LoadingPage(),
        '/login': (context) => LoginPage(),
        '/newPost': (context) => NewpostPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
