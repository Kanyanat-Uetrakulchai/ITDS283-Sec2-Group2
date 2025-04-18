import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/posts.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? _selectedBank;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _orderChannelController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  Future<void> _searchPosts() async {
    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['url']}/posts/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bank': _selectedBank,
          'accountNumber': _accountNumberController.text,
          'name': _nameController.text,
          'shopName': _shopNameController.text,
          'orderChannel': _orderChannelController.text,
          'tag': _tagController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data['posts']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching posts: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ค้นหา',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xffD63939),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(15, 15, 15, 10),
          child: Column(
            children: [
              bankDropdown(),
              SizedBox(height: 15),
              buildTextFieldRow(
                'หมายเลขบัญชี',
                _accountNumberController,
                'xxxxxxxxxx',
              ),
              SizedBox(height: 15),
              buildTextFieldRow(
                'ชื่อ - นามสกุล',
                _nameController,
                'ชื่อ นามสกุล',
              ),
              SizedBox(height: 15),
              buildTextFieldRow(
                'ชื่อร้านค้า',
                _shopNameController,
                'ชื่อเพจ/ร้าน',
              ),
              SizedBox(height: 15),
              buildTextFieldRow(
                'ช่องทางการสั่งซื้อ',
                _orderChannelController,
                'เช่น facebook, X, instagram',
              ),
              SizedBox(height: 15),
              buildTextFieldRow('Tag', _tagController, '#แท็ก #แท็ก2'),
              SizedBox(height: 15),
              Divider(color: Color(0xFFACACAC)),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _isLoading ? null : _searchPosts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffD63939),
                  minimumSize: Size(double.infinity, 50),
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'ค้นหา',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Prompt',
                          ),
                        ),
              ),
              SizedBox(height: 20),
              if (_searchResults.isNotEmpty)
                ..._searchResults
                    .map((post) => PostCard(post: post, showDetails: true))
                    .toList(),
              if (_searchResults.isEmpty && !_isLoading)
                Text(
                  'ไม่พบผลลัพธ์',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Row buildTextFieldRow(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Row(
      children: [
        Container(
          width: 160,
          child: Text(
            label,
            style: TextStyle(fontFamily: 'Prompt', fontSize: 20),
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: 200,
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
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 16,
                color: Colors.grey,
              ),
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
          width: 160,
          child: Text(
            'ธนาคาร',
            style: TextStyle(fontFamily: 'Prompt', fontSize: 20),
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: 200,
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
                    'ธนาคารกรุงศรี'
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
                  _selectedBank = newValue;
                });
              },
              hint: Center(
                child: Text(
                  'เลือกธนาคาร',
                  style: TextStyle(fontFamily: 'Prompt', fontSize: 16),
                ),
              ),
              value: _selectedBank,
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
