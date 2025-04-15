import 'package:flutter/material.dart';

class ChangePWPage extends StatelessWidget {
  ChangePWPage({super.key});

  final TextEditingController _oldpasswordController = TextEditingController();
  final TextEditingController _newpasswordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();


  Future<void> _changePassword() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffD63939),
        centerTitle: true,
        title: Text(
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
            Row(
              children: [
                SizedBox(
                  width: 160, // Fixed width for labels
                  child: Text(
                    'รหัสผ่านเดิม',
                    style: TextStyle(fontFamily: 'Prompt', fontSize: 20),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 200, // Fixed width for text fields
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFD63939)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextField(
                    controller: _oldpasswordController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontFamily: 'Prompt', fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                SizedBox(
                  width: 160, // Fixed width for labels
                  child: Text(
                    'รหัสผ่านใหม่',
                    style: TextStyle(fontFamily: 'Prompt', fontSize: 20),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 200, // Fixed width for text fields
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFD63939)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextField(
                    controller: _newpasswordController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontFamily: 'Prompt', fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                SizedBox(
                  width: 160, // Fixed width for labels
                  child: Text(
                    'ยืนยันรหัสผ่านใหม่',
                    style: TextStyle(fontFamily: 'Prompt', fontSize: 20),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 200, // Fixed width for text fields
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFD63939)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextField(
                    controller: _confirmpasswordController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontFamily: 'Prompt', fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            GestureDetector(
              onTap: () {
                _changePassword();
              },
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFFD63939),
                  ),
                  child: Text(
                    'ยืนยัน',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      
    );
  }
}