import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonDecode
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'post_page.dart';
import 'post_bytag.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _tags = [];
  bool _loading = false;
  String _response = '';

  @override
  void initState() {
    super.initState();
    _refreshPosts();
    _getPopTags();
  }

  // final url = dotenv.env['url'];

  Future<void> _refreshPosts() async {
    setState(() {
      _loading = true;
      _posts = [];
      _response = '';
    });

    try {
      var response = await http.get(
        Uri.parse('${dotenv.env['url']}/api/posts'),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'];

        setState(() {
          _posts = data.cast<Map<String, dynamic>>();
          _response = const JsonEncoder.withIndent('  ').convert(jsonData);
        });
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode}';
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

  Future<void> _getPopTags() async {
    setState(() {
      _loading = true;
      _tags = [];
      _response = '';
    });

    try {
      var response = await http.get(
        Uri.parse('${dotenv.env['url']}/api/pop_tags'),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'];

        setState(() {
          _tags = data.cast<Map<String, dynamic>>();
          _response = const JsonEncoder.withIndent('  ').convert(jsonData);
        });
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Image.asset('assets/police_banner.png'),
                  SizedBox(height: 20),
                  Text(
                    'แท็กยอดนิยม',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _poptags(),
                  Divider(color: Color(0xFFACACAC)),
                  SizedBox(height: 20),
                  Text(
                    'โพสต์ใหม่',
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  ..._posts.map((post) {
                    return InkWell(
                      onTap: () {
                        print('post ${post['postId']} clicked!');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PostPage(postId: post['postId']),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  ),
                                ),
                                title: Text(post['username'].toString()),
                                trailing: Text(
                                  post['p_timestamp'].toString().split('T')[0],
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                post['caption'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
    );
  }

  Wrap _poptags() {
    // return Wrap();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          _tags.map((tag) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffD63939),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostBytag(tag: tag['tag']),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag['tag'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    tag['COUNT(p.postId)'].toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  AppBar _appBar() {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xffD63939),
      centerTitle: true,
      title: Image.asset(
        'assets/app_logo.png',
        fit: BoxFit.contain,
        height: 45,
      ),
    );
  }
}
