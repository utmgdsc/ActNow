import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Required for form validator

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  // User creds
  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _userPassword = TextEditingController();
  final TextEditingController _userConfirmPassword = TextEditingController();

  // User info
  final TextEditingController _username = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();

  signUpEmailPass() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCreds = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _userEmail.text, password: _userPassword.text);

        DocumentReference ref = users.doc(userCreds.user!.uid);

        ref.set({
          'userid': userCreds.user!.uid,
          'username': _username.text,
          'firstname': _firstName.text,
          'lastname': _lastName.text
        });

        if (userCreds.user != null && !userCreds.user!.emailVerified) {
          showError("Please verify your email", "VERIFY");
          await userCreds.user!.sendEmailVerification();
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == "weak-password") {
          showError("The password provided is too weak.", "ERROR");
        } else if (e.code == "email-already-in-use") {
          showError("The account already exists for that email", "ERROR");
        }
      }
    }
  }

  showError(String? errormessage, String? title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title!),
            content: Text(errormessage!),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (title == "VERIFY") {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 90.0, 0.0, 0.0),
                    child: const Center(
                        child: Text('Let\'s Get Started!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 30.0))),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 130.0, 0.0, 0.0),
                    child: const Center(
                        child: Text('Tell us a little bit about yourself',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15.0))),
                  ),
                ],
              ),
              Container(
                  padding:
                      const EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: (input) {
                              if (input == null || input.isEmpty) {
                                return "Please enter a first name";
                              }
                            },
                            controller: _firstName,
                            decoration: const InputDecoration(
                                labelText: 'First Name',
                                labelStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.green))),
                          ),
                          const SizedBox(height: 10.0),
                          TextFormField(
                            validator: (input) {
                              if (input == null || input.isEmpty) {
                                return "Please enter a lastname";
                              }
                            },
                            controller: _lastName,
                            decoration: const InputDecoration(
                                labelText: 'Last Name',
                                labelStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.green))),
                          ),
                          const SizedBox(height: 10.0),
                          TextFormField(
                            validator: (input) {
                              if (input == null || input.isEmpty) {
                                return "Please enter a username";
                              }
                            },
                            controller: _username,
                            decoration: const InputDecoration(
                                labelText: 'Username ',
                                labelStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.green))),
                          ),
                          const SizedBox(height: 10.0),
                          TextFormField(
                            validator: (input) {
                              if (input == null || input.isEmpty) {
                                return "Enter an email";
                              }
                              bool validEmail = RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(input);
                              if (!validEmail) {
                                return "Enter a valid email";
                              }
                            },
                            controller: _userEmail,
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.green))),
                          ),
                          const SizedBox(height: 10.0),
                          TextFormField(
                            validator: (input) {
                              if (input == null || input.isEmpty) {
                                return "Please enter a password";
                              }
                            },
                            controller: _userPassword,
                            decoration: const InputDecoration(
                                labelText: 'Password ',
                                labelStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.green))),
                            obscureText: true,
                          ),
                          const SizedBox(height: 10.0),
                          TextFormField(
                            validator: (input) {
                              if (input == null || input.isEmpty) {
                                return "Please enter a password";
                              }
                              if (input != _userPassword.text) {
                                return "Passwords do not match";
                              }
                            },
                            controller: _userConfirmPassword,
                            decoration: const InputDecoration(
                                labelText: 'Confirm Password ',
                                labelStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.green))),
                            obscureText: true,
                          ),
                          const SizedBox(height: 50.0),
                          SizedBox(
                              width: 180,
                              height: 40.0,
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                shadowColor: Colors.greenAccent,
                                color: Colors.green,
                                elevation: 7.0,
                                child: ElevatedButton(
                                  onPressed: () {
                                    signUpEmailPass();
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 20.0),
                        ],
                      ))),
              const SizedBox(height: 15.0),
              Container(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Already have an account?',
                      ),
                      const SizedBox(width: 5.0),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Login in',
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  )),
            ])));
  }
}
