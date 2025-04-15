import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Navigate to Login Screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffD63939),
        centerTitle: true,
        title: Text(
          'ตั้งค่า',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Prompt',
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'เวอร์ชั่น   v 1.0.0',
              style: TextStyle(fontSize: 20, fontFamily: 'Prompt'),
            ),
            SizedBox(height: 10),
            Divider(color: Color(0xFFACACAC)),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/changepassword');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'แก้ไขรหัสผ่าน',
                    style: TextStyle(fontSize: 20, fontFamily: 'Prompt'),
                  ),
                  Icon(Icons.arrow_forward_ios),
                ],
              ),
            ),
            SizedBox(height: 10),
            Divider(color: Color(0xFFACACAC)),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                width: 500,
                child: Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                    color: Color(0xFFD63939),
                    fontSize: 20,
                    fontFamily: 'Prompt',
                  ),
                ),
              ),
            ),
            Divider(color: Color(0xFFACACAC)),
          ],
        ),
      ),
    );
  }
}
