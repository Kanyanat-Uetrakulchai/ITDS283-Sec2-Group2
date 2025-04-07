import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonDecode
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'post_page.dart';

class PostBytag extends StatefulWidget {
  final String tag;

  const PostBytag({Key? key, required this.tag}) : super(key: key);

  @override
  State<PostBytag> createState() => PostBytagState();
}

class PostBytagState extends State<PostBytag> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = false;
  String _response = '';

  final url = dotenv.env['url'];

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

    try {
      final response = await http.get(
        Uri.parse('$url/api/posts/${widget.tag}'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'];

        final Set<int> seenIds = {};
        final List<Map<String, dynamic>> uniqueList = [];

        for (var item in data) {
          final postId = item['postId'];
          if (!seenIds.contains(postId)) {
            seenIds.add(postId);
            uniqueList.add(item);
          }
        }

        setState(() {
          _posts = uniqueList.cast<Map<String, dynamic>>();
          _response = const JsonEncoder.withIndent('  ').convert(data);
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Posts for #${widget.tag}')),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : _posts.isEmpty
              ? Center(child: Text('No posts found for this tag.'))
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children:
                      _posts.map((post) {
                        return InkWell(
                          onTap: () {
                            print('Post ${post['postId']} clicked!');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        PostPage(postId: post['postId']),
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
                                    title: Text(post['username'] ?? 'Unknown'),
                                    trailing: Text(
                                      post['p_timestamp']?.toString().split(
                                            'T',
                                          )[0] ??
                                          '',
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    post['caption'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
    );
  }
}
