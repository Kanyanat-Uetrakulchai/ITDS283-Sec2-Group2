import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'post_page.dart';

class ProfilePage extends StatefulWidget {
  final int uid;
  final VoidCallback? onBackToHome;

  const ProfilePage({super.key, required this.uid, this.onBackToHome});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  bool _loading = false;
  List<dynamic> _posts = [];
  Map<String, dynamic> _userData = {};
  String _statusMessage = "";
  bool _showFirstTab = true;
  List<dynamic> _followingPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchPost();
    _fetchFollowingPosts();
  }

  final url = dotenv.env['url'];

  Future<void> _fetchProfile() async {
    setState(() {
      _loading = true;
      _userData = {};
    });

    try {
      final response = await http.get(
        Uri.parse('$url/api/user/${widget.uid}'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['error'] == false) {
          setState(() {
            _userData = (jsonData['data'].isNotEmpty ? jsonData['data'][0] : {});
            print(_userData);
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

  Future<void> _fetchPost() async {
    setState(() {
      _loading = true;
      _posts = [];
    });

    try {
      final response = await http.get(
        Uri.parse('$url/api/profile/post/${widget.uid}'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['error'] == false) {
          setState(() {
            _posts = jsonData['data'] ?? [];
            print(_posts);
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


  Future<void> _fetchFollowingPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$url/api/following/posts/${widget.uid}'),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['error'] == false) {
          setState(() {
            _followingPosts = jsonData['data'] ?? [];
          });
        }
      }
    } catch (e) {
      print('Error loading followed posts: $e');
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
        'มกราคม',
        'กุมภาพันธ์',
        'มีนาคม',
        'เมษายน',
        'พฤษภาคม',
        'มิถุนายน',
        'กรกฎาคม',
        'สิงหาคม',
        'กันยายน',
        'ตุลาคม',
        'พฤศจิกายน',
        'ธันวาคม',
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                                child:
                                    _userData.isNotEmpty
                                        ? Text(
                                          _userData['username']
                                                  ?.toString()
                                                  .substring(0, 1)
                                                  .toUpperCase() ??
                                              'U',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                          ),
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
          // Fixed position back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: IconButton(
                onPressed: () {
                  if (widget.onBackToHome != null) {
                    widget.onBackToHome!();
                  }
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
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
    );
  }

  Widget _buildContentSection() {
    return Column(
      children: [
        // Tab selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabButton('โพสต์ของฉัน', _showFirstTab),
            _buildTabButton('กำลังติดตาม', !_showFirstTab),
          ],
        ),
        // Divider
        Divider(
          color: Color(0xFFACACAC),
          thickness: 1.5,
          endIndent: 46.5,
          height: 1,
        ),
        // Content
        Container(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height * 0.5, // Ensure enough space
          ),
          child:
              _loading
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
              Container(width: 100, height: 3, color: Color(0xFFD63939)),
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
        return InkWell(
          onTap: () {
            print('post ${post['postId']} clicked!');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostPage(postId: post['postId']),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.only(left: 0, right: 46, top: 8, bottom: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(uid: post['uid']),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xffD63939),
                        child: Text(
                          post['username']
                                  ?.toString()
                                  .substring(0, 1)
                                  .toUpperCase() ??
                              '?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      title: Text(post['username'].toString()),
                      trailing: Text(
                        post['p_timestamp'].toString().split('T')[0],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      post['caption'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Divider(color: Color(0xFFACACAC)),
                  SizedBox(height: 10),
                  _buildImageGrid(post),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowingContent() {
    if (_followingPosts.isEmpty) {
      return Center(child: Text('ยังไม่ได้ติดตามโพสต์ใด ๆ'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _followingPosts.length,
      itemBuilder: (context, index) {
        final post = _followingPosts[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostPage(postId: post['postId']),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.only(left: 0, right: 46, top: 8, bottom: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xffD63939),
                      child: Text(
                        post['username']
                                ?.toString()
                                .substring(0, 1)
                                .toUpperCase() ??
                            '?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(post['username'] ?? ''),
                    trailing: Text(
                      post['p_timestamp'].toString().split('T')[0],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      post['caption'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Divider(color: Color(0xFFACACAC)),
                  SizedBox(height: 10),
                  _buildImageGrid(post),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageGrid(Map<String, dynamic> post) {
    List<String> imageFields = ['p_p1', 'p_p2', 'p_p3', 'p_p4'];
    List<String> imageUrls =
        imageFields
            .map((key) => post[key])
            .whereType<String>()
            .where((url) => url.isNotEmpty)
            .toList();

    if (imageUrls.isEmpty) return SizedBox.shrink();

    final baseUrl = dotenv.env['url']?.replaceFirst(RegExp(r'/$'), '') ?? '';

    List<Widget> images =
        imageUrls
            .map(
              (url) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  '$baseUrl$url',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                  errorBuilder:
                      (context, error, stackTrace) => Icon(Icons.broken_image),
                ),
              ),
            )
            .toList();

    switch (images.length) {
      case 1:
        return images[0];
      case 2:
        return Row(
          children:
              images
                  .map(
                    (img) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: img != images.last ? 4 : 0,
                        ),
                        child: img,
                      ),
                    ),
                  )
                  .toList(),
        );
      case 3:
        return Column(
          children: [
            images[0],
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: images[1],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: images[2],
                  ),
                ),
              ],
            ),
          ],
        );
      case 4:
      default:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: images[0],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: images[1],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: images[2],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: images[3],
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}
