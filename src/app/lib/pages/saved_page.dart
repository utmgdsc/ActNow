import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({Key? key}) : super(key: key);

  @override
  SavedPageState createState() => SavedPageState();
}

class SavedPageState extends State<SavedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.fromLTRB(150.0, 180.0, 0.0, 0.0),
            child: const Text("Saved Page")));
  }
}
