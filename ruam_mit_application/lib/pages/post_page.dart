import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ruam_mit_application/pages/profile_page.dart';
import '../components/Likes.dart';
import '../components/image_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/commentSec.dart';

class PostPage extends StatefulWidget {
  final int postId;

  const PostPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final GlobalKey<PostReactionButtonsState> _reactionKey = GlobalKey();

  int? _uid;
  Map<String, dynamic> _post = {};
  bool isFollowed = false;
  bool _loading = false;
  String _response = '';

  final url = dotenv.env['url'];

  void _refreshPage() {
    _loadUIDAndPosts();
    _fetchFollowStatus();
  }

  @override
  void initState() {
    super.initState();
    _loadUIDAndPosts();
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
      return '${date.day} $thaiMonth ${date.year}';
    } catch (e) {
      return "ไม่ระบุวันที่";
    }
  }

  Future<void> _loadUIDAndPosts() async {
    int? userId = await getUID();
    setState(() {
      _uid = userId;
    });
    await _refreshPosts();
    await _fetchFollowStatus();
  }

  Future<int?> getUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('uid');
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _loading = true;
      _response = '';
    });

    try {
      var response = await http.get(
        Uri.parse('$url/api/post/detail/${widget.postId}'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        setState(() {
          _response = const JsonEncoder.withIndent('  ').convert(jsonData);
          if (jsonData['data'] != null &&
              jsonData['data'] is List &&
              jsonData['data'].isNotEmpty) {
            _post = jsonData['data'][0] is Map ? jsonData['data'][0] : {};
          }
        });
        _reactionKey.currentState?.fetchReaction();
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Exception: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _toggleFollowStatus() async {
    if (_uid == null) return;

    final followUrl = Uri.parse('$url/api/follow');
    final unfollowUrl = Uri.parse('$url/api/unfollow');

    // Optimistically update UI
    setState(() {
      isFollowed = !isFollowed;
    });

    try {
      final response =
          isFollowed
              ? await http.post(
                followUrl,
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  'postId': widget.postId,
                  'uid': _uid,
                  'f_timestamp': DateTime.now().toIso8601String(),
                }),
              )
              : await http.delete(
                unfollowUrl,
                body: {
                  'postId': widget.postId.toString(),
                  'uid': _uid.toString(),
                },
              );

      if ((isFollowed && response.statusCode != 201) ||
          (!isFollowed && response.statusCode != 200)) {
        // If it failed, revert the UI
        setState(() {
          isFollowed = !isFollowed;
        });
        print('Error: ${response.statusCode}, ${response.body}');
      } else {
        //
      }
    } catch (e) {
      // Revert state on error
      setState(() {
        isFollowed = !isFollowed;
      });
      print('Follow toggle exception: $e');
    }
  }

  Future<void> _fetchFollowStatus() async {
    if (_uid == null) return;

    try {
      final response = await http.get(
        Uri.parse('$url/api/follow/status?postId=${widget.postId}&uid=$_uid'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          isFollowed = json['isFollowed'];
        });
      } else {
        print('Failed to fetch follow status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching follow status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _post.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No post data available'),
                    TextButton(onPressed: _refreshPosts, child: Text('Retry')),
                    Text('Response: $_response'),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _refreshPosts, // or any refresh method
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      ownerPostInfo(context),
                      Container(
                        transform: Matrix4.translationValues(0.0, -30.0, 0.0),
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _post['caption'] ?? 'No caption',
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'Prompt',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow('ธนาคาร', _post['mij_bank']),
                            _buildInfoRow('เลขบัญชี', _post['mij_bankno']),
                            _buildInfoRow(
                              'ชื่อนามสกุลมิจฉาชีพ',
                              _post['mij_name'],
                            ),
                            _buildInfoRow(
                              'ชื่อร้าน / บัญชีผู้ใช้',
                              _post['mij_acc'],
                            ),
                            _buildInfoRow(
                              'ช่องทางการสั่งซื้อ',
                              _post['mij_plat'],
                            ),
                            Divider(thickness: 2),
                            SizedBox(height: 5),
                            Text(
                              _post['detail'] ?? 'No details',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Prompt',
                              ),
                            ),
                            SizedBox(height: 5),
                            ImageGrid(post: _post),
                            SizedBox(height: 5),
                            Divider(thickness: 2),
                            if (_uid != null)
                              Container(
                                transform: Matrix4.translationValues(
                                  -10.0,
                                  0.0,
                                  0.0,
                                ),
                                child: PostReactionButtons(
                                  key: _reactionKey,
                                  postId: widget.postId,
                                  userId: _uid!,
                                ),
                              ),
                            Text(
                              'ความคิดเห็น',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 20,
                              ),
                            ),
                            CommentSection(postId: widget.postId, uid: _uid!),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  ListTile ownerPostInfo(BuildContext context) {
    return ListTile(
      minTileHeight: 100,
      leading: CircleAvatar(
        backgroundColor: const Color(0xffD63939),
        radius: 42,
        child: Text(
          _post['username']?.toString().substring(0, 1).toUpperCase() ?? '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        _post['username']?.toString() ?? 'Unknown User',
        style: TextStyle(fontSize: 20, fontFamily: 'Prompt'),
      ),
      trailing: Container(
        margin: EdgeInsets.only(right: 9),
        child: Text(
          formatThaiDate(_post['p_timestamp']), // Removed [0] index access
          style: TextStyle(fontFamily: 'Prompt', fontSize: 16),
        ),
      ),
      onTap: () {
        if (_post['uid'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(uid: _post['uid']),
            ),
          );
        }
      },
    );
  }

  AppBar appBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xffD63939),
      actions: [
        GestureDetector(
          onTap: () async {
            await _toggleFollowStatus();
            _refreshPage();
          },
          child: Container(
            height: 29,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: IntrinsicWidth(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Icon(
                      isFollowed ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xffD63939),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      transform: Matrix4.translationValues(0.0, -4.4, 0.0),
                      child: Text(
                        isFollowed ? 'เลิกติดตาม' : 'ติดตาม',
                        style: const TextStyle(
                          color: Color(0xffD63939),
                          fontFamily: 'Prompt',
                          fontSize: 16.75,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14,
                color: Color(0XFF4F4F4F),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'ไม่ระบุ',
              textAlign: TextAlign.right,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontFamily: 'Prompt',
                fontSize: 14,
                color: Color(0XFF242424),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
