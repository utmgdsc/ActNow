import 'package:actnow/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'home_page.dart';

class DecisionsTree extends StatefulWidget {
  const DecisionsTree({Key? key}) : super(key: key);

  @override
  _DecisionsTreeState createState() => _DecisionsTreeState();
}

class _DecisionsTreeState extends State<DecisionsTree> {
  User? user;

  @override
  void initState() {
    super.initState();
    onRefresh(FirebaseAuth.instance.currentUser);
  }

  onRefresh(userCreds) {
    setState(() {
      user = userCreds;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return LoginPage(
        onSignIn: (userCreds) => onRefresh(userCreds),
      );
    }
    return HomePage(
      userCreds: user,
      onSignOut: (userCreds) => onRefresh(userCreds),
    );
  }
}
