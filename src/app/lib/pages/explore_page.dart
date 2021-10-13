import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  ExplorePageState createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.fromLTRB(150.0, 180.0, 0.0, 0.0),
            child: const Text("Explore Page")));
  }
}
