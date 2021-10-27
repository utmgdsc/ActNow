import 'package:actnow/pages/map_page/map_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/profile_page/profile_page.dart';
import 'pages/map_page/map_page.dart';
import 'pages/explore_page.dart';
import 'pages/saved_page.dart';

class HomePage extends StatefulWidget {
  final User? userCreds;
  final Function(User?) onSignOut;
  const HomePage({Key? key, required this.userCreds, required this.onSignOut})
      : super(key: key);

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    onSignOut(null);
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic screens;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    screens = [
      MapPage(userCreds: widget.userCreds),
      ExplorePage(userCreds: widget.userCreds),
      const SavedPage(),
      ProfilePage(userCreds: widget.userCreds, onSignOut: widget.onSignOut)
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
