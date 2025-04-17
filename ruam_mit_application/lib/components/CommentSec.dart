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
  String _responseMessage = "";

  final url = dotenv.env['url'];
  List<XFile> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null) {
        if (images.length <= 4) {
          setState(() {
            _imageFiles = images;
            _responseMessage = "";
          });
        } else {
          setState(() {
            _responseMessage = "ใส่รูปได้สูงสุด 4 รูป";
          });
        }
      }
    } catch (e) {
      setState(() {
        _responseMessage = "เกิดข้อผิดพลาดในการเลือกรูป: $e";
      });
    }
  }

  Future<void> _fetchComments() async {
    try {
      final response = await http.get(
        Uri.parse('$url/api/comment/${widget.postId}'),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _comments = jsonData['data'] ?? [];
        });
      } else {
        setState(() {
          _responseMessage =
              "ไม่สามารถโหลดความคิดเห็นได้: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = "เกิดข้อผิดพลาด: $e";
      });
    }
  }

  Future<void> _submitComment() async {
    if (_controller.text.trim().isEmpty && _imageFiles.isEmpty) {
      setState(() {
        _responseMessage = "กรุณาใส่ข้อความหรือรูปภาพ";
      });
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
          await http.MultipartFile.fromPath('images', _imageFiles[i].path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        setState(() {
          _controller.clear();
          _imageFiles.clear();
          _responseMessage = "";
        });
        await _fetchComments();
      } else {
        final respStr = await response.stream.bytesToString();
        setState(() {
          _responseMessage = "ไม่สามารถโพสต์ความคิดเห็นได้: $respStr";
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = "เกิดข้อผิดพลาด: $e";
      });
    }
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 70,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _imageFiles.length,
          separatorBuilder: (context, index) => SizedBox(width: 10),
          itemBuilder: (context, index) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_imageFiles[index].path),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red, size: 20),
                    onPressed: () {
                      setState(() {
                        _imageFiles.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var comment in _comments)
          Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Color(0xffD63939),
                      child: Text(
                        comment['username']
                                ?.toString()
                                .substring(0, 1)
                                .toUpperCase() ??
                            '?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      comment['username'].toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      comment['c_timestamp']?.toString().split('T')[0] ?? '',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment['message'] ?? '',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        ImageGrid(
                          post: {
                            'p_p1': comment['c_p1'],
                            'p_p2': comment['c_p2'],
                            'p_p3': comment['c_p3'],
                            'p_p4': comment['c_p4'],
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              if (_responseMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _responseMessage,
                    style: TextStyle(color: Colors.red, fontFamily: 'Prompt'),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'แสดงความคิดเห็น...',
                          hintStyle: TextStyle(fontFamily: 'Prompt'),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontFamily: 'Prompt'),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.photo, color: Color(0xffD63939)),
                    onPressed: _pickImages,
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Color(0xffD63939)),
                    onPressed: _submitComment,
                  ),
                ],
              ),
              if (_imageFiles.isNotEmpty) _buildImagePreview(),
            ],
          ),
        ),
      ],
    );
  }
}
