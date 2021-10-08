import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final User? userCreds;
  final Function(User?) onSignOut;
  const ProfilePage({Key? key, required this.userCreds, required this.onSignOut})
      : super(key: key);

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    onSignOut(null);
  }

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.fromLTRB(30.0, 180.0, 0.0, 0.0),
              child: Text(
                "Hello you are Logged in as ${widget.userCreds!.email}",
              )),
          ElevatedButton(
              onPressed: () {
                widget.signOut();
              },
              child:
                  const Text('Signout', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
