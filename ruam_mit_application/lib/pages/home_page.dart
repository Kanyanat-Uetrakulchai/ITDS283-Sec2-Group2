import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: ListView(
        children: [
          SizedBox(height: 20,),
          Image(image: AssetImage('assets/police_banner.png')),
          Container(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            child: Text(
                'แท็กยอดนิยม',
                style: TextStyle(
                fontFamily: 'Prompt', 
                fontSize: 24, 
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          Divider(
            color: Color(0xFFACACAC),
            indent: 30,
            endIndent: 30,
          ),
          SizedBox(height: 20,),
          Container(
            margin: EdgeInsets.only(left: 30),
            child: Text(
                'โพสต์ใหม่',
                style: TextStyle(
                fontFamily: 'Prompt', 
                fontSize: 24, 
                fontWeight: FontWeight.w600
              ),
            ),
          ),
        ],
      )
    );
  }

  AppBar _appBar() {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xffD63939),
      centerTitle: true,
      title: Image.asset(
        'assets/app_logo.png',
        fit: BoxFit.contain,
        height: 45,
      ),
    );
  }
}
