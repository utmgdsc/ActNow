import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.fromLTRB(150.0, 180.0, 0.0, 0.0),
            child: const Text("Map Page")));
  }
}
