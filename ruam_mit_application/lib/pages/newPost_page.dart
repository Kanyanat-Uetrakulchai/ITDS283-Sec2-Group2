import 'package:flutter/material.dart';

class NewpostPage extends StatefulWidget {
  @override
  State<NewpostPage> createState() => _NewpostPageState();
}

class _NewpostPageState extends State<NewpostPage> {
  String? _selectedvalue;
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _orderChannelController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _postContentController = TextEditingController();

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
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 16,
                  ),
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
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 20,
            ),
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
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 16,
            ),
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
            style: TextStyle(
              fontFamily: 'Prompt',
              fontSize: 20,
            ),
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
              items: [
                'ธนาคารกสิกรไทย',
                'ธนาคารกรุงไทย',
                'ธนาคารไทยพาณิชย์',
                'ธนาคารกรุงเทพ'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 16,
                      ),
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
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 16,
                  ),
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