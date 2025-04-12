import 'package:flutter/material.dart';
import 'package:ruam_mit_application/pages/home_page.dart';
import 'package:ruam_mit_application/pages/profile_page.dart';
import 'package:ruam_mit_application/pages/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  Future<int?> getUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('uid'); // This gives you the saved UID
  }

  late Future<int?> _uidFuture;

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
  void initState() {
    super.initState();
    _uidFuture = getUID();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _uidFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ), // Show loading indicator while fetching UID
            bottomNavigationBar: buildBottomNavBar(),
            floatingActionButton: buildFloatingActionButton(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
            bottomNavigationBar: buildBottomNavBar(),
            floatingActionButton: buildFloatingActionButton(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        } else if (snapshot.hasData) {
          int? uid = snapshot.data; // Get UID from the Future

          if (uid == null) {
            // Redirect to login if UID is null
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/login');
            });
            return Container(); // Empty container while waiting for navigation
          }

          // Update the profile page with the correct UID
          final _pages = [
            HomePage(),
            SearchPage(),
            HomePage(), // Temporary placeholder for "Add Post" button
            ProfilePage(uid: uid), // Pass the correct UID to ProfilePage
            HomePage(),
          ];

          return Scaffold(
            body: IndexedStack(index: _selected_page, children: _pages),
            bottomNavigationBar: BottomAppBar(
              height: 96,
              color: const Color(0xffD63939), // Red background
              child: BottomNavigationBar(
                fixedColor: Colors.white,
                unselectedItemColor: Colors.white.withAlpha(180),
                type: BottomNavigationBarType.fixed,
                backgroundColor:
                    Colors
                        .transparent, // Keep transparent to show BottomAppBar color
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
            floatingActionButton: buildFloatingActionButton(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        } else {
          return Text("error");
        }
      },
    );
  }

  BottomNavigationBar buildBottomNavBar() {
    return BottomNavigationBar(
      fixedColor: Colors.white,
      unselectedItemColor: Colors.white.withAlpha(180),
      type: BottomNavigationBarType.fixed,
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
        BottomNavigationBarItem(icon: Icon(null), label: ''), // FAB placeholder
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
    );
  }

  Widget buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xffD63939), width: 3),
      ),
      child: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 0,
          onPressed: () {
            Navigator.pushNamed(context, '/newPost');
            print("to new post");
          },
          child: const Icon(Icons.add, color: Color(0xffD63939), size: 40),
        ),
      ),
    );
  }
}
