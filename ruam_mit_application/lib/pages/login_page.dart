import 'package:flutter/material.dart';
import 'package:ruam_mit_application/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonDecode
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'bottomNav.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['url']}/api/login'),
      body: {'username': username, 'password': password},
    );

    final data = json.decode(response.body);

    if (data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('uid', data['uid']); // save the UID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Bottomnav()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ล็อกอินไม่สำเร็จ กรุณาลองอีกครั้ง')),
      );
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<String?> getUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/app_logo_white.png'),
            const SizedBox(height: 20),
            const Text(
              'เข้าสู่ระบบ',
              style: TextStyle(fontFamily: 'Prompt', fontSize: 20),
            ),
            const SizedBox(height: 25),
            buildTextFieldRow('username', _usernameController),
            const SizedBox(height: 25),
            buildTextFieldRow(
              'password',
              _passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () {
                final username = _usernameController.text.trim();
                final password = _passwordController.text.trim();

                if (username.isNotEmpty && password.isNotEmpty) {
                  loginUser(username, password);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กรุณากรอกชื่อผู้ใช้และรหัสผ่าน'),
                    ),
                  );
                }
              },

              child: Image.asset('assets/login_button.png'),
            ),
            const SizedBox(height: 30),
            // Registration prompt
            const Text(
              'ผู้ใช้งานใหม่ ลงทะเบียน',
              style: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 18,
                color: Color(0xFFD63939),
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFieldRow(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontFamily: 'Prompt', fontSize: 20),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 200,
          height: 35,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD63939)),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontFamily: 'Prompt', fontSize: 16),
              obscureText: isPassword,
            ),
          ),
        ),
      ],
    );
  }
}
