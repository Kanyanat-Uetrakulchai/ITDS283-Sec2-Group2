import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfilePage extends StatefulWidget {
  final int uid;

  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  bool _loading = false;
  List<dynamic> _posts = [];
  Map<String, dynamic> _userData = {};
  String _statusMessage = "";
  bool _showFirstTab = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileAndPosts();
  }

  final url = dotenv.env['url'];

  Future<void> _fetchProfileAndPosts() async {
    setState(() {
      _loading = true;
      _posts = [];
      _userData = {};
    });

    try {
      final response = await http.get(
        Uri.parse('$url/api/post/profile/${widget.uid}'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['error'] == false) {
          setState(() {
            _userData = jsonData['user'] ?? (jsonData['data'].isNotEmpty ? jsonData['data'][0] : {});
            _posts = jsonData['data'] ?? [];
          });
        } else {
          setState(() {
            _statusMessage = jsonData['message'] ?? 'Failed to load data';
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Connection error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String formatThaiDate(dynamic timestamp) {
    try {
      DateTime date;
      if (timestamp is int) {
        date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return "ไม่ระบุวันที่";
      }

      const thaiMonths = [
        'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
        'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
        'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
      ];

      String thaiMonth = thaiMonths[date.month - 1];
      return '$thaiMonth ${date.year}';
    } catch (e) {
      return "ไม่ระบุวันที่";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
            // Profile section
            Container(
              transform: Matrix4.translationValues(25.0, -55.0, 0.0),
              child: Column(
                children: [
                  // Profile avatar
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
                            child: _userData.isNotEmpty 
                                ? Text(
                                    _userData['username']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                                    style: TextStyle(fontSize: 24, color: Colors.white),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // User info
                  if (_userData.isNotEmpty) _buildUserInfo(),
                  // Tab and content section
                  SizedBox(height: 10),
                  _buildContentSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _userData['username'] ?? 'Username',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Prompt',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 20),
              Text(
                '#${_userData['uid'] ?? '0000'}',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Prompt',
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เข้าร่วมเมื่อ ${formatThaiDate(_userData['joinDate'])}',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Prompt',
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      children: [
        // Tab selector
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabButton('โพสต์ของฉัน', _showFirstTab),
              _buildTabButton('กำลังติดตาม', !_showFirstTab),
            ],
          ),
        ),
        // Divider
        Container(
          child: Divider(
            color: Color(0xFFACACAC),
            thickness: 1.5,
            endIndent: 60,
            height: 1,
          ),
        ),
        // Content
        Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.5, // Ensure enough space
          ),
          child: _loading
              ? Center(child: CircularProgressIndicator())
              : _posts.isEmpty
                  ? Center(child: Text(_statusMessage))
                  : _showFirstTab
                      ? _buildPostsList()
                      : _buildFollowingContent(),
        ),
      ],
    );
  }

  Widget _buildTabButton(String text, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _showFirstTab = text == 'โพสต์ของฉัน'),
      child: Container(
        transform: Matrix4.translationValues(-25.0, 0.0, 0.0),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Prompt',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
            SizedBox(height: 5),
            if (isActive)
              Container(
                width: 100,
                height: 3,
                color: Color(0xFFD63939),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      shrinkWrap: true, // Important for nested ListView
      physics: NeverScrollableScrollPhysics(), // Disable inner scroll
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Container(
          transform: Matrix4.translationValues(-25.0, 0.0, 0.0),
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFD63939),
                child: Text(
                  post['username']?.toString().substring(0, 1).toUpperCase() ?? '?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(post['username'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(post['caption'] ?? ''),
                  SizedBox(height: 4),
                  Text(
                    post['p_timestamp']?.toString().split('T')[0] ?? '',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              onTap: () {
                // Handle post tap
                print('Post ${post['postId']} tapped');
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowingContent() {
    return Container(
      height: 200, // Give it some height
      child: Center(
        child: Text(
          'กำลังติดตาม content',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}