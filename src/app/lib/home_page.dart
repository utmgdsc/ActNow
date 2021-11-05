import 'package:actnow/pages/map_page/map_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
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
  dynamic currentLocation;

  void _getCurrentLocation() async {
    var rawLocation = Location();
    var serviceEnabled = await rawLocation.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await rawLocation.requestService();
      if (!serviceEnabled) {
        currentLocation = null;
        return;
      }
    }

    var permissionGranted = await rawLocation.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await rawLocation.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        currentLocation = null;
        return;
      }
    }

    try {
      var newLocation = await rawLocation.getLocation();
      currentLocation = newLocation;
    } catch (e) {
      currentLocation = null;
    }
  }

  onRefresh(newLocation) {
    setState(() {
      screens = [
        MapPage(
            userCreds: widget.userCreds,
            userLocation: newLocation,
            onUpdateLocation: (newLoc) => onRefresh(newLoc)),
        ExplorePage(userCreds: widget.userCreds, userLocation: newLocation),
        const SavedPage(),
        ProfilePage(userCreds: widget.userCreds, onSignOut: widget.onSignOut)
      ];
    });
  }

  dynamic screens;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    screens = [
      MapPage(
          userCreds: widget.userCreds,
          userLocation: currentLocation,
          onUpdateLocation: (newLoc) => onRefresh(newLoc)),
      ExplorePage(userCreds: widget.userCreds, userLocation: currentLocation),
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
