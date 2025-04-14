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
                            print('post ${post['postId']} clicked!');
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
                                  SizedBox(height: 6),
                                  Text(
                                    post['caption'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  _buildImageGrid(post),
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
