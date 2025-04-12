import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  String _responseMessage = "";

  Future<void> _createPost() async {
    final caption = _captionController.text;
    final account = _accountNumberController.text;
    final name = _nameController.text;
    final shopname = _shopNameController.text;
    final order = _orderChannelController.text;
    final tag = _tagController.text;
    final post = _postContentController.text;
    if (caption.isEmpty ||
        account.isEmpty ||
        name.isEmpty ||
        shopname.isEmpty ||
        order.isEmpty ||
        tag.isEmpty ||
        post.isEmpty) {
      setState(() {
        _responseMessage = "   กรุณากรอกข้อมูลให้ครบถ้วน";
      });
      return;
    }
    final url = Uri.parse('${dotenv.env['url']}/api/posts');

    Map<String, dynamic> product = {
      "caption": caption,
      "CustomerName": account,
      "ContactName": name,
      "Address": shopname,
      "City": order,
      "PostalCode": tag,
      "Country": post,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(product),
      );

      if (response.statusCode == 201) {
        setState(() {
          _responseMessage = "Created Customer:\n${response.body}";
        });
      } else {
        setState(() {
          _responseMessage = "Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = "Exception: $e";
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
      body: Container(
        margin: EdgeInsets.fromLTRB(15, 15, 15, 10),
        child: Column(
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
                maxLines: 2, // Makes the text field taller
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
                maxLines: 8, // Makes the text field taller
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
          ],
        ),
      ),
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
