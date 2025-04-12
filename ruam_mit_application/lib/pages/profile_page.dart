import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/user_storage.dart';

class ProfilePage extends StatefulWidget {
  final int uid;

  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  bool _loading = false;
  List<dynamic> _user = [];
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  final url = dotenv.env['url'];

  Future<void> _refreshPosts() async {
    setState(() {
      _loading = true;
      _user = [];
    });

    try {
      var response = await http.get(Uri.parse('$url/api/user/${widget.uid}'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'];
        setState(() {
          _user = data;
        });
      } else {
        setState(() {
          _statusMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Exception: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Banner section
          Container(
            height: 180,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/profile_banner.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Profile avatar section
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(25.0, -55.0, 0.0),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFFD63939),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // User posts section
                  Expanded(
                    child: _loading
                        ? Center(child: CircularProgressIndicator())
                        : _user.isEmpty
                            ? Center(child: Text(_statusMessage))
                            : ListView.builder(
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: _user.length,
                                itemBuilder: (context, index) {
                                  return Text(
                                          '${_user[index]}',
                                          style: TextStyle(fontSize: 16),
                                  );    
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
