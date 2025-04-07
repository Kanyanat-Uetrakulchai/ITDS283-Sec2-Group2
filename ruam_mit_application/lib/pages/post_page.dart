import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonDecode
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PostPage extends StatefulWidget {
  final int postId;

  const PostPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Page')),
      body: Center(child: Text('Received: ${_response}')),
    );
  }
}


// ..._posts.map((post) {
//                     return Card(
//                       elevation: 3,
//                       margin: EdgeInsets.symmetric(vertical: 10),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               post['caption'] ?? '',
//                               style: TextStyle(
//                                 fontFamily: 'Prompt',
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 6),
//                             Text(post['detail'] ?? ''),
//                             SizedBox(height: 8),
//                             Text('ชื่อมิจฉาชีพ: ${post['mij_name'] ?? '-'}'),
//                             Text('บัญชี: ${post['mij_acc'] ?? '-'}'),
//                             Text(
//                               'ธนาคาร: ${post['mij_bank']} (${post['mij_bankno']})',
//                             ),
//                             Text('แพลตฟอร์ม: ${post['mij_plat'] ?? '-'}'),
//                             SizedBox(height: 4),
//                             Text(
//                               'โพสต์เมื่อ: ${post['p_timestamp'] ?? '-'}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),