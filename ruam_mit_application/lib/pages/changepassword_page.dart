import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart'; // For password hashing

class ChangePWPage extends StatefulWidget {
  const ChangePWPage({super.key});

  @override
  State<ChangePWPage> createState() => _ChangePWPageState();
}

class _ChangePWPageState extends State<ChangePWPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Hash password using SHA-256
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert to UTF-8 bytes
    var digest = sha256.convert(bytes); // Create SHA-256 hash
    return digest.toString(); // Return hex string
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('uid');
  }

  Future<void> _changePassword() async {
    // Validate inputs
    if (_oldPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'กรุณากรอกรหัสผ่านเดิม');
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'กรุณากรอกรหัสผ่านใหม่');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'รหัสผ่านใหม่ไม่ตรงกัน');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      setState(() => _errorMessage = 'รหัสผ่านควรมีความยาวอย่างน้อย 6 ตัวอักษร');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final userId = await _getUserId();
      if (userId == null) {
        _showError('ไม่พบข้อมูลผู้ใช้');
        return;
      }

      // Hash the passwords before sending
      final hashedNewPassword = _hashPassword(_newPasswordController.text);
      final hashedOldPassword = _hashPassword(_oldPasswordController.text);

      final Map<String, dynamic> requestBody = {
        'password': hashedNewPassword, // Send hashed password
        'old_password': hashedOldPassword, // Also send hashed old password for verification
      };

      final response = await http.put(
        Uri.parse('${dotenv.env['url']}/api/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _showSuccess('เปลี่ยนรหัสผ่านสำเร็จ');
        if (mounted) Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'เปลี่ยนรหัสผ่านไม่สำเร็จ';
        _showError(error);
      }
    } catch (e) {
      _showError('เกิดข้อผิดพลาด: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffD63939),
        centerTitle: true,
        title: const Text(
          'แก้ไขรหัสผ่าน',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Prompt',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            _buildPasswordField(
              label: 'รหัสผ่านเดิม',
              controller: _oldPasswordController,
              obscureText: _obscureOldPassword,
              onToggleVisibility: () => setState(() => _obscureOldPassword = !_obscureOldPassword),
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              label: 'รหัสผ่านใหม่',
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              onToggleVisibility: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              label: 'ยืนยันรหัสผ่าน',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontFamily: 'Prompt',
                ),
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD63939),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,

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
              fontSize: 20,
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
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: onToggleVisibility,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}