import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final User? userCreds;
  final Function(User?) onSignOut;
  const ProfilePage(
      {Key? key, required this.userCreds, required this.onSignOut})
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
    double widthVariable = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.fromLTRB(0, 60.0, 0.0, 0.0),
              child: Container(
                color: Colors.blue,
                height: 135,
                width: widthVariable,
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 20.0),
                    const CircleAvatar(
                      radius: 44,
                      backgroundImage: AssetImage('assets/Logo.png'),
                    ),
                    SizedBox(
                        width: 150,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 0.0, 0.0, 0.0),
                              child: const Text('Last Name',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20.0)),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 30.0, 0.0, 0.0),
                              child: const Text('First Name',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        )),
                    const SizedBox(width: 30.0),
                    ElevatedButton(
                        onPressed: () {
                          widget.signOut();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            primary: Colors.white,
                            side: const BorderSide(color: Colors.blue)),
                        child: const Text('Log out',
                            style: TextStyle(color: Colors.blue)))
                  ],
                ),
              )),
          const SizedBox(height: 10.0),
          const Center(
            child: Text(
              "Settings",
              style: TextStyle(fontSize: 21),
            ),
          ),
          Container(
              margin: const EdgeInsets.all(10),
              width: widthVariable,
              decoration: const BoxDecoration(
                  border: Border(
                top: BorderSide(color: Colors.grey),
              )),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: Text("ACCOUNT SETTINGS"),
                  ),
                  Container(
                    width: widthVariable,
                    padding: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
                    decoration: const BoxDecoration(
                        border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    )),
                    child: Text("Personal Information"),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
