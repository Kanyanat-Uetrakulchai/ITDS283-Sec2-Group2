import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffD63939),
        centerTitle: true,
        title: const Text(
          'ลงทะเบียน',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Prompt',
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              _buildUserField(label: 'ชื่อผู้ใช้งาน', controller: _usernameController),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'รหัสผ่าน', 
                controller: _passwordController,
                isPasswordField: true,
                obscureText: _obscurePassword,
                onVisibilityChanged: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'ยืนยันรหัสผ่าน', 
                controller: _confirmPasswordController,
                isConfirmField: true,
                obscureText: _obscureConfirmPassword,
                onVisibilityChanged: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD63939),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'ลงทะเบียน',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Prompt',
                          fontSize: 18,
                        ),
                      ),
              ),
              if (_usernameError != null || _passwordError != null || _confirmPasswordError != null) ...[
                const SizedBox(height: 20),
                if (_usernameError != null)
                  Text(
                    _usernameError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: 'Prompt',
                    ),
                  ),
                if (_passwordError != null)
                  Text(
                    _passwordError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: 'Prompt',
                    ),
                  ),
                if (_confirmPasswordError != null)
                  Text(
                    _confirmPasswordError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: 'Prompt',
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserField({
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD63939)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 15),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null; // We'll handle this in _registerUser
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    bool isPasswordField = false,
    bool isConfirmField = false,
    required bool obscureText,
    required VoidCallback onVisibilityChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD63939)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: onVisibilityChanged,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16,
              ),
              validator: (value) => null, // We'll handle validation in _registerUser
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _registerUser() async {
    // Clear previous errors
    setState(() {
      _usernameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Validate fields
    if (_usernameController.text.isEmpty) {
      setState(() => _usernameError = 'โปรดกรอกชื่อผู้ใช้งาน');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'โปรดกรอกรหัสผ่าน');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร');
      return;
    }

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(_passwordController.text)) {
      setState(() => _passwordError = 'รหัสผ่านต้องมีตัวพิมพ์ใหญ่, ตัวพิมพ์เล็ก และตัวเลข');
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _confirmPasswordError = 'โปรดกรอกยืนยันรหัสผ่าน');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = 'รหัสผ่านไม่ตรงกัน');
      return;
    }

    setState(() => _isLoading = true);

    // Hash the password before sending
    final hashedPassword = _hashPassword(_passwordController.text);

    final Map<String, dynamic> requestBody = {
      'username': _usernameController.text.trim(),
      'password': hashedPassword,
    };

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['url']}/api/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลงทะเบียนสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'การลงทะเบียนล้มเหลว'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}