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
    double heightVariable = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(0, statusBarHeight , 0.0, 0.0),
              child: Container(
                color: Colors.blue,
                height: heightVariable / 6,
                width: widthVariable,
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 20.0),
                    const CircleAvatar(
                      radius: 44,
                      backgroundImage: AssetImage('assets/Logo.png'),
                    ),
                    SizedBox(
                        width: widthVariable / 3,
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
              margin: const EdgeInsets.all(10),
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
                rows: const <DataRow>[
                  DataRow(
                    cells: <DataCell>[DataCell(Text('Personal Information'))],
                  ),
                  DataRow(
                    cells: <DataCell>[DataCell(Text('Notifcations'))],
                  ),
                  DataRow(
                    cells: <DataCell>[DataCell(Text('Public account'))],
                  ),
                ],
              )),
          Container(
              margin: const EdgeInsets.all(10),
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'SUPPORT',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
                rows: const <DataRow>[
                  DataRow(
                    cells: <DataCell>[DataCell(Text('How to use ActNow'))],
                  ),
                  DataRow(
                    cells: <DataCell>[DataCell(Text('Terms of Service'))],
                  ),
                  DataRow(
                    cells: <DataCell>[DataCell(Text('Contact Us'))],
                  ),
                ],
              )),
        ],
      ),
    ));
  }
}
