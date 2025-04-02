import 'package:flutter/material.dart';

class NewpostPage extends StatelessWidget {
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
      body: Column(
        children: [
          Row(
            children: [
              Text(
                'ธนาคาร',
              ),
              Container(
                child: DropdownButton(items: <String>
                ['ธนาคารกสิกรไทย', 'ธนาคารกรุงไทย', 'ธนาคารไทยพาณิชย์', 'ธนาคารกรุงเทพ'].map(toElement), onChanged: ,
              )
            ],
          )
        ],
      ),
    );
  }
}
