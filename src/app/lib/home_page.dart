import 'dart:async';

import 'package:actnow/pages/map_page/map_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  dynamic screens;
  late Map<String, dynamic>? userInfo;
  bool swtichStatus = false;
  int _selectedIndex = 0;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  Timer? timer;

  List getScreens(dynamic currLoc) {
    return [
      MapPage(
          userCreds: widget.userCreds,
          userLocation: currLoc,
          onUpdateLocation: (newLoc) => onRefresh(newLoc)),
      ExplorePage(userCreds: widget.userCreds, userLocation: currLoc),
      const SavedPage(),
      ProfilePage(
          userCreds: widget.userCreds,
          onSignOut: widget.onSignOut,
          onUpdateProfile: (publicSwitch) => locationTimer(publicSwitch))
    ];
  }

  void getSwitchStatus() {
    users.doc(widget.userCreds!.uid).get().then((value) => {
          setState(() {
            userInfo = value.data() as Map<String, dynamic>?;
            swtichStatus = userInfo!["isSwitched"];
            if (swtichStatus) {
              _getCurrentLocation().then((value) => updateLocation());
            }
          })
        });
  }

  void updateLocation() {
    DocumentReference ref = users.doc(widget.userCreds!.uid);

    ref.update({'longitude': (currentLocation as LocationData).longitude});

    ref.update({'latitude': (currentLocation as LocationData).latitude});
  }

  void removeLocation() {
    DocumentReference ref = users.doc(widget.userCreds!.uid);

    ref.update({'longitude': FieldValue.delete()});

    ref.update({'latitude': FieldValue.delete()});
  }

  void locationTimer(bool publicSwitch) {
    if (publicSwitch && timer == null) {
      timer = Timer.periodic(const Duration(minutes: 5), (timer) {
        _getCurrentLocation().then((value) => updateLocation());
      });
    } else {
      if (timer != null) {
        timer!.cancel();
      }
      removeLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    var rawLocation = Location();
    var serviceEnabled = await rawLocation.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await rawLocation.requestService();
      if (!serviceEnabled) {
        currentLocation = null;
        setState(() {
          screens = getScreens(currentLocation);
        });
        return;
      }
    }

    var permissionGranted = await rawLocation.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await rawLocation.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        currentLocation = null;
        setState(() {
          screens = getScreens(currentLocation);
        });
        return;
      }
    }

    try {
      var newLocation = await rawLocation.getLocation();
      currentLocation = newLocation;
      setState(() {
        screens = getScreens(newLocation);
      });
    } catch (e) {
      currentLocation = null;
      setState(() {
        screens = getScreens(currentLocation);
      });
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
        ProfilePage(
            userCreds: widget.userCreds,
            onSignOut: widget.onSignOut,
            onUpdateProfile: (publicSwitch) => locationTimer(publicSwitch))
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    getSwitchStatus();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    double widthVariable = MediaQuery.of(context).size.width;
    double heightVariable = MediaQuery.of(context).size.height;

    if (screens == null) {
      return Scaffold(
          body: SizedBox(
        height: heightVariable,
        width: widthVariable,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ));
    }
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
