import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottomNav.dart';
import 'package:crypto/crypto.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true; // Added for password visibility toggle

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> loginUser(String username, String password) async {
    // Hash the password before sending
    final hashedPassword = _hashPassword(password);

    final response = await http.post(
      Uri.parse('${dotenv.env['url']}/api/login'),
      body: {
        'username': username, 
        'password': hashedPassword
      },
    );

    final data = json.decode(response.body);

    if (data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('uid', data['uid']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Bottomnav()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'ล็อกอินไม่สำเร็จ กรุณาลองอีกครั้ง'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
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
              obscureText: _obscurePassword,
              onVisibilityChanged: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ผู้ใช้งานใหม่',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    'ลงทะเบียน',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 18,
                      color: Color(0xFFD63939),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
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
    bool obscureText = false,
    VoidCallback? onVisibilityChanged,
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
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                isDense: true,
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: onVisibilityChanged,
                      )
                    : null,
              ),
              style: const TextStyle(fontFamily: 'Prompt', fontSize: 16),
              obscureText: isPassword && obscureText,
            ),
          ),
        ),
      ],
    );
  }
}