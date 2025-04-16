import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordsMatch = true;

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
              _buildUserField(label: 'username', controller: _usernameController),
              const SizedBox(height: 20),
              _buildPasswordField(label: 'password', controller: _passwordController),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'confirm password', 
                controller: _confirmpasswordController,
                isConfirmField: true,
              ),
              if (!_passwordsMatch)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Passwords do not match',
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'Prompt',
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD63939),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Prompt',
                    fontSize: 18,
                  ),
                ),
              ),
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
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
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
    bool isConfirmField = false,
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
              obscureText: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                if (isConfirmField && value != _passwordController.text) {
                  setState(() {
                    _passwordsMatch = false;
                  });
                  return '';
                } else {
                  setState(() {
                    _passwordsMatch = true;
                  });
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate() && _passwordsMatch) {
      final Map<String, dynamic> requestBody = {
        'username': _usernameController.text,
        'password': _passwordController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('${dotenv.env['url']}/api/user/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Registration successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          // Clear form and navigate
          _usernameController.clear();
          _passwordController.clear();
          _confirmpasswordController.clear();
          Navigator.pop(context);
        } else {
          // Registration failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }
}