import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewpostPage extends StatefulWidget {
  @override
  State<NewpostPage> createState() => _NewpostPageState();
}

class _NewpostPageState extends State<NewpostPage> {
  String? _selectedvalue;
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _orderChannelController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _postContentController = TextEditingController();

  Future<int?> getUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('uid');
  }

  @override
  void initState() {
    super.initState();
  }

  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.length <= 4) {
      setState(() {
        _selectedImages = images;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ใส่รูปได้สูงสุด 4 รูป')));
    }
  }

  String _responseMessage = "";

  Future<void> _createPost() async {
    final caption = _captionController.text;
    final account = _accountNumberController.text;
    final name = _nameController.text;
    final shopname = _shopNameController.text;
    final order = _orderChannelController.text;
    final tag = _tagController.text;
    final post = _postContentController.text;
    final bank = _selectedvalue;
    final uid = await getUID();

    if (caption.isEmpty ||
        account.isEmpty ||
        name.isEmpty ||
        shopname.isEmpty ||
        order.isEmpty ||
        tag.isEmpty ||
        post.isEmpty ||
        bank == null) {
      setState(() {
        _responseMessage = "   กรุณากรอกข้อมูลให้ครบถ้วน";
      });
      return;
    }

    final url = Uri.parse('${dotenv.env['url']}/api/posts');

    var request = http.MultipartRequest('POST', url);
    request.fields['caption'] = caption;
    request.fields['detail'] = post;
    request.fields['mij_bank'] = bank;
    request.fields['mij_bankno'] = account;
    request.fields['mij_name'] = name;
    request.fields['mij_acc'] = shopname;
    request.fields['mij_plat'] = order;
    request.fields['uid'] = uid?.toString() ?? '';

    for (int i = 0; i < _selectedImages.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath('images', _selectedImages[i].path),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        print('response: $responseBody');
        final postId = responseBody['postId'];
        List<String> tags =
            tag
                .split('#')
                .map((t) => t.trim())
                .where((t) => t.isNotEmpty)
                .toList();

        for (String t in tags) {
          final tagUrl = Uri.parse('${dotenv.env['url']}/api/tags');
          // print('$postId $uid $t');
          await http.post(
            tagUrl,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"postId": postId, "uid": uid, "tag": t}),
          );
        }

        setState(() {
          _responseMessage = "โพสต์สำเร็จ:\n${response.body}";
          _selectedImages.clear();
        });
        Navigator.pop(context, postId);
      } else {
        setState(() {
          _responseMessage =
              "เกิดข้อผิดพลาด: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = "ข้อผิดพลาด: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffD63939),
        centerTitle: true,
        title: Text(
          'โพสต์ใหม่',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bankDropdown(),
              SizedBox(height: 15),
              buildTextFieldRow('หมายเลขบัญชี', _accountNumberController),
              SizedBox(height: 15),
              buildTextFieldRow('ชื่อ - นามสกุล', _nameController),
              SizedBox(height: 15),
              buildTextFieldRow('ชื่อร้านค้า', _shopNameController),
              SizedBox(height: 15),
              buildTextFieldRow('ช่องทางการสั่งซื้อ', _orderChannelController),
              SizedBox(height: 15),
              buildTextFieldRow('Tag', _tagController),
              SizedBox(height: 15),
              Divider(color: Color(0xFFACACAC)),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD63939)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  controller: _captionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                    hintText: 'เขียนหัวข้อที่นี่...',
                    hintStyle: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  style: TextStyle(fontFamily: 'Prompt', fontSize: 16),
                ),
              ),
              SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD63939)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  controller: _postContentController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                    hintText: 'เขียนโพสต์ที่นี่...',
                    hintStyle: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  style: TextStyle(fontFamily: 'Prompt', fontSize: 18),
                ),
              ),
              SizedBox(height: 15),
              // 📸 Image picker + preview here
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "เพิ่มรูปภาพ (สูงสุด 4 รูป)",
                  style: TextStyle(fontFamily: 'Prompt', fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
              _addPics(),
              SizedBox(height: 30),
              Center(
                child: Text(
                  _responseMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _createPost,
                  child: Text("โพสต์"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffD63939),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _addPics() {
    return Row(
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.add_a_photo, color: Colors.black54),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              separatorBuilder: (context, index) => SizedBox(width: 10),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_selectedImages[index].path),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Row buildTextFieldRow(String label, TextEditingController controller) {
    return Row(
      children: [
        Container(
          width: 160, // Fixed width for labels
          child: Text(
            label,
            style: TextStyle(fontFamily: 'Prompt', fontSize: 20),
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: 200, // Fixed width for text fields
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFD63939)),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              border: InputBorder.none,
            ),
            style: TextStyle(fontFamily: 'Prompt', fontSize: 16),
          ),
        ),
      ],
    );
  }

  Row bankDropdown() {
    return Row(
      children: [
        Container(
          width: 160, // Same width as other labels
          child: Text(
            'ธนาคาร',
            style: TextStyle(fontFamily: 'Prompt', fontSize: 20),
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: 200, // Same width as other fields
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              icon: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.keyboard_arrow_down),
              ),
              iconSize: 24,
              items:
                  [
                    'ธนาคารกสิกรไทย',
                    'ธนาคารกรุงไทย',
                    'ธนาคารไทยพาณิชย์',
                    'ธนาคารกรุงเทพ',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(
                        child: Text(
                          value,
                          style: TextStyle(fontFamily: 'Prompt', fontSize: 16),
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedvalue = newValue;
                });
              },
              hint: Center(
                child: Text(
                  'เลือกธนาคาร',
                  style: TextStyle(fontFamily: 'Prompt', fontSize: 16),
                ),
              ),
              value: _selectedvalue,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _nameController.dispose();
    _shopNameController.dispose();
    _orderChannelController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
