import 'package:flutter/material.dart';

class ChangePWPage extends StatefulWidget {
  const ChangePWPage({super.key});

  @override
  State<ChangePWPage> createState() => _ChangePWPageState();
}

class _ChangePWPageState extends State<ChangePWPage> {
  final TextEditingController _oldpasswordController = TextEditingController();
  final TextEditingController _newpasswordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  Future<void> _changePassword() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เปลี่ยนรหัสผ่านสำเร็จ')),
      );
    }
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
              controller: _oldpasswordController,
              obscureText: _obscureOldPassword,
              onToggleVisibility: () => setState(() => _obscureOldPassword = !_obscureOldPassword),
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              label: 'รหัสผ่านใหม่',
              controller: _newpasswordController,
              obscureText: _obscureNewPassword,
              onToggleVisibility: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              label: 'ยืนยันรหัสผ่าน',
              controller: _confirmpasswordController,
              obscureText: _obscureConfirmPassword,
              onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
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
    _oldpasswordController.dispose();
    _newpasswordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }
}