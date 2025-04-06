import 'package:flutter/material.dart';
import 'package:ruam_mit_application/pages/bottomNav.dart';
import 'package:ruam_mit_application/pages/login_page.dart';
// import 'package:ruam_mit_application/pages/home_page.dart';
// import 'pages/profile_page.dart';
import 'pages/loading_page.dart';
import 'pages/newPost_page.dart';
import 'pages/settings_page.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:http/http.dart' as http;

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
        '/': (context) => Bottomnav(),
        '/loading': (context) => LoadingPage(),
        '/login': (context) => LoginPage(),
        '/newPost': (context) => NewpostPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
  //   @override
  // void initState() {
  //   super.initState();
  //   _initDatabase();
  // }
  //   Future<void> _initDatabase() async {
  //   final conn = await MySQLConnection.createConnection(
  //     host: "192.168.1.54", // ip from ioconfig
  //     port: 3309, // Add the port the server is running on
  //     userName: "mobile_conn", // Your username
  //     password: "ict!!!555", // Your password
  //     databaseName: "mobile_s2_gr2", // Your DataBase name
  //   );

  //   conn.connect();
  // }
}
