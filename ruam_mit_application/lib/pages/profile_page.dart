import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonDecode
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfilePage extends StatefulWidget {
  final int uid;

  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  // List<Map<String, dynamic>> Post = [];
  bool _loading = false;
  String _response = '';

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  final url = dotenv.env['url'];

  Future<void> _refreshPosts() async {
    setState(() {
      _loading = true;
      // _posts = [];
      _response = '';
    });

    try {
      var response = await http.get(
        Uri.parse('$url/api/user/${widget.uid}'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Page')),
      body: Center(child: Text('Received: ${_response}')),
    );
  }
}