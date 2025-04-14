import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonDecode
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/Likes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostPage extends StatefulWidget {
  final int postId;

  const PostPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  int? _uid;

  @override
  void initState() {
    super.initState();
    _loadUIDAndPosts();
  }

  Future<void> _loadUIDAndPosts() async {
    int? userId = await getUID();
    setState(() {
      _uid = userId;
    });
    await _refreshPosts();
  }

  Future<int?> getUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('uid');
  }

  bool _loading = false;
  String _response = '';

  final url = dotenv.env['url'];

  Future<void> _refreshPosts() async {
    setState(() {
      _loading = true;
      _response = '';
    });

    try {
      var response = await http.get(
        Uri.parse('$url/api/post/${widget.postId}'),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'];

        setState(() {
          // _posts = data.cast<Map<String, dynamic>>();
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Page')),
      body:
          _uid == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Center(child: Text('Received: $_response')),
                  PostReactionButtons(postId: widget.postId, userId: _uid!),
                ],
              ),
    );
  }
}
