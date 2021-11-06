import 'package:actnow/pages/profile_page/contact_us.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';

import 'personal_info.dart';

class ProfilePage extends StatefulWidget {
  final User? userCreds;
  final Function(User?) onSignOut;
  final dynamic userLocation;
  const ProfilePage(
      {Key? key,
      required this.userCreds,
      required this.onSignOut,
      required this.userLocation})
      : super(key: key);

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    onSignOut(null);
  }

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String? firstName;
  String? lastName;
  String? profileURL;
  late Map<String, dynamic>? userInfo;
  bool isSwitched = false;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  showBox(String? message, String? title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title!),
            content: Text(message!),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    addLocation();
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  void addLocation() {
    DocumentReference ref = users.doc(widget.userCreds!.uid);

    ref.update({'longitude': (widget.userLocation as LocationData).longitude});

    ref.update({'latitude': (widget.userLocation as LocationData).latitude});
  }

  void updateInfo() {
    users.doc(widget.userCreds!.uid).get().then((value) => {
          setState(() {
            userInfo = value.data() as Map<String, dynamic>?;
            userInfo!["email"] = widget.userCreds!.email;
            lastName = userInfo!["lastname"];
            firstName = userInfo!["firstname"];
            profileURL = userInfo!["profile_picture"];
          })
        });
  }

  @override
  void initState() {
    super.initState();
    updateInfo();
  }

  @override
  Widget build(BuildContext context) {
    double widthVariable = MediaQuery.of(context).size.width;
    double heightVariable = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    if (lastName == null && firstName == null) {
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
        body: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(0, statusBarHeight, 0.0, 0.0),
              child: Container(
                color: Colors.blue,
                height: heightVariable / 6,
                width: widthVariable,
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 20.0),
                    CircleAvatar(
                      radius: 44,
                      backgroundImage: NetworkImage(profileURL ??
                          "https://profilepicturemaker.com/wp-content/themes/ppm2021/images/transparent.gif"),
                    ),
                    SizedBox(
                        width: widthVariable / 3,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 0.0, 0.0, 0.0),
                              child: Text(firstName ?? "",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20.0)),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 30.0, 0.0, 0.0),
                              child: Text(lastName ?? "",
                                  style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        )),
                    const SizedBox(width: 30),
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
          SizedBox(
              width: widthVariable,
              child: const Center(
                child: Text(
                  "Settings",
                  style: TextStyle(fontSize: 21),
                ),
              )),
          Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: DataTable(
                decoration: const BoxDecoration(
                    border: Border(
                  top: BorderSide(color: Colors.grey),
                )),
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'ACCOUNT SETTINGS',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
                rows: <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      DataCell(const Text('Personal Information'), onTap: () {
                        Route route = MaterialPageRoute(
                            builder: (context) =>
                                PersonalInfo(userInfo: userInfo));
                        Navigator.push(context, route)
                            .then((value) => updateInfo());
                      })
                    ],
                  ),
                  const DataRow(
                    cells: <DataCell>[DataCell(Text('Notifcations'))],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Row(children: [
                          const Text("Public Account"),
                          Switch(
                            value: isSwitched,
                            onChanged: (value) {
                              setState(() {
                                isSwitched = value;
                                if (isSwitched) {
                                  showBox(
                                      "This will make your location public, are you sure?",
                                      "WARNING");
                                }
                              });
                            },
                            activeColor: Colors.blue,
                          )
                        ]),
                      )
                    ],
                  ),
                ],
              )),
          Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'SUPPORT',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
                rows: <DataRow>[
                  const DataRow(
                    cells: <DataCell>[DataCell(Text('How to use ActNow'))],
                  ),
                  const DataRow(
                    cells: <DataCell>[DataCell(Text('Terms of Service'))],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(const Text('Contact Us'), onTap: () {
                        Route route = MaterialPageRoute(
                            builder: (context) => const ContactUs());
                        Navigator.push(context, route);
                      })
                    ],
                  ),
                ],
              )),
        ],
      ),
    ));
  }
}
