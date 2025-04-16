import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonDecode
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ruam_mit_application/pages/profile_page.dart';
import 'post_page.dart';
import 'post_bytag.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/image_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  void refreshPosts() {
    _refreshPosts();
    _getPopTags();
  }

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

  _launchURL() async {
    final Uri url = Uri.parse('https://thaipoliceonline.go.th/');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
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
                  InkWell(
                    onTap: () {
                      _launchURL();
                    },
                    child: Image.asset('assets/police_banner.png'),
                  ),
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
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              ProfilePage(uid: post['uid']),
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
                                    post['p_timestamp'].toString().split(
                                      'T',
                                    )[0],
                                  ),
                                ),
                              ),
                              Divider(color: Color(0xFFACACAC)),
                              SizedBox(height: 6),
                              Text(
                                post['caption'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              ImageGrid(post: post),
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
      automaticallyImplyLeading: false,
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
