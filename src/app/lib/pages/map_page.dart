// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(MapStyle.noLandMarks);
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId("event1"),
          position: LatLng(43.55103829955488, -79.66262838104547),
          infoWindow: InfoWindow(
              title: "Event number 1", snippet: "event number 1 description")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
            onMapCreated: _onMapCreated,
            markers: _markers,
            initialCameraPosition: CameraPosition(
                target: LatLng(43.55103829955488, -79.66262838104547),
                zoom: 15)));
  }
}

class MapStyle {
  static String noLandMarks = '''
  [
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
]
  ''';
}
