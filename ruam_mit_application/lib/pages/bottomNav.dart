import 'package:flutter/material.dart';
import 'package:ruam_mit_application/pages/home_page.dart';
import 'package:ruam_mit_application/pages/profile_page.dart';
import 'package:ruam_mit_application/pages/search_page.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  final _pages = [
    HomePage(),
    SearchPage(),
    HomePage(), // กันที่ไว้ใส่ปุ่มเพิ่มโพสต์
    ProfilePage(),
    HomePage(),
  ];
  int _selected_page = 0;

  void _onSelected(int index) {
    if (index == 4) {
      Navigator.pushNamed(context, '/settings');
    } else if (index != 2) {
      setState(() {
        _selected_page = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selected_page, children: _pages),

      // BottomAppBar ให้ icon ไม่ขยับเวลาเปลี่ยนหน้า
      bottomNavigationBar: BottomAppBar(
        height: 96,
        color: const Color(0xffD63939),
        child: BottomNavigationBar(
          fixedColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          // ลบพื้นหลังขาวกับเงา
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selected_page,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 30),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 30),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(null),
              label: '',
            ), // FAB placeholder
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 30),
              label: 'Settings',
            ),
          ],
          onTap: _onSelected,
        ),
      ),

      // Center FAB with Border
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xffD63939),
            width: 3,
          ), // Slightly reduced width
        ),
        child: SizedBox(
          height: 65,
          width: 65,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            shape: const CircleBorder(),
            elevation: 0, // No shadow
            onPressed: () {
              Navigator.pushNamed(context, '/newPost');
              print("to new post");
            },
            child: const Icon(Icons.add, color: Color(0xffD63939), size: 40),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
