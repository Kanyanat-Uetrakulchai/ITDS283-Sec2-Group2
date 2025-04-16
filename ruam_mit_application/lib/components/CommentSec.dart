import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../components/image_grid.dart';

class CommentSection extends StatefulWidget {
  final int postId;
  final int uid;

  const CommentSection({Key? key, required this.postId, required this.uid})
    : super(key: key);

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _comments = [];

  final url = dotenv.env['url'];
  List<File?> _imageFiles = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && _imageFiles.length < 4) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _fetchComments() async {
    final response = await http.get(
      Uri.parse('$url/api/comment/${widget.postId}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _comments = jsonData['data'] ?? [];
      });
    }
  }

  Future<void> _submitComment() async {
    if (_controller.text.trim().isEmpty && _imageFiles.isEmpty) {
      print('No text or image provided for comment.');
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$url/api/comment'),
      );
      request.fields['postId'] = widget.postId.toString();
      request.fields['uid'] = widget.uid.toString();
      request.fields['message'] = _controller.text.trim();
      request.fields['c_timestamp'] = DateTime.now().toIso8601String();

      for (int i = 0; i < _imageFiles.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _imageFiles[i]!.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        print('Comment submitted successfully');
        _controller.clear();
        setState(() {
          _imageFiles.clear();
        });
        await _fetchComments();
      } else {
        print('Failed to submit comment. Status code: ${response.statusCode}');
        final respStr = await response.stream.bytesToString();
        print('Response: $respStr');
      }
    } catch (e) {
      print('Exception in _submitComment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var c in _comments)
          ListTile(
            leading: CircleAvatar(child: Text(c['username'][0].toUpperCase())),
            title: Text(c['username'], style: TextStyle(fontFamily: 'Prompt')),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c['message'], style: TextStyle(fontFamily: 'Prompt')),
                ImageGrid(
                  post: {
                    'p_p1': c['c_p1'],
                    'p_p2': c['c_p2'],
                    'p_p3': c['c_p3'],
                    'p_p4': c['c_p4'],
                  },
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  border: Border.all(color: Color(0xFFD9D9D9)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'แสดงความคิดเห็น...',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            IconButton(icon: Icon(Icons.photo), onPressed: _pickImage),
            IconButton(icon: Icon(Icons.send), onPressed: _submitComment),
          ],
        ),
        if (_imageFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              spacing: 8,
              children:
                  _imageFiles.map((file) {
                    return Stack(
                      children: [
                        Image.file(file!, height: 100),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _imageFiles.remove(file);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }
}
