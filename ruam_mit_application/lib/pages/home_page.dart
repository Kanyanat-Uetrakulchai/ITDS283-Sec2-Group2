import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonDecode

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = false;
  String _response = '';

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _loading = true;
      _posts = [];
      _response = '';
    });

    String url = 'http://192.168.1.54:3031/api/posts';

    try {
      var response = await http.get(Uri.parse(url));
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
                    return Card(
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
                            Text(
                              post['caption'] ?? '',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(post['detail'] ?? ''),
                            SizedBox(height: 8),
                            Text('ชื่อมิจฉาชีพ: ${post['mij_name'] ?? '-'}'),
                            Text('บัญชี: ${post['mij_acc'] ?? '-'}'),
                            Text(
                              'ธนาคาร: ${post['mij_bank']} (${post['mij_bankno']})',
                            ),
                            Text('แพลตฟอร์ม: ${post['mij_plat'] ?? '-'}'),
                            SizedBox(height: 4),
                            Text(
                              'โพสต์เมื่อ: ${post['p_timestamp'] ?? '-'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
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
