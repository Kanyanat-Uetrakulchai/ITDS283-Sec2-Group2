import 'package:flutter/material.dart';

class NewpostPage extends StatefulWidget {
  @override
  State<NewpostPage> createState() => _NewpostPageState();
}

class _NewpostPageState extends State<NewpostPage> {
  String? _selectedvalue;

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
          ],
        ),
      ),
    );
  }

  Row bankDropdown() {
    return Row(
            children: [
              Text(
                'ธนาคาร',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 20,
                ),
              ),
              SizedBox(width: 10),
              Expanded( // Ensures the dropdown takes available space
                child: Container(
                  height: 30,
                  margin: EdgeInsets.only(left: 60),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true, // Ensures full width
                      icon: Padding(
                        padding: EdgeInsets.only(left: 10), // Push icon left
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
              ),
            ],
          );
  }
}