import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  

  @override
  ContactUsState createState() => ContactUsState();
}

class ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.fromLTRB(150.0, 180.0, 0.0, 0.0),
            child: const Text("Contact Us")));
  }
}
