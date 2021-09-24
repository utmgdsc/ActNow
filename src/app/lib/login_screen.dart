import 'package:actnow/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';

class LoginPage extends StatefulWidget {
  final Function(User?) onSignIn;

  const LoginPage({Key? key, required this.onSignIn}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Required for form validator

  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _userPassword = TextEditingController();

  loginEmailPass() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCreds = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _userEmail.text, password: _userPassword.text);

        if (userCreds.user != null && !userCreds.user!.emailVerified) {
          showError("Please verify your email", "VERIFY");
        }
        else {
          widget.onSignIn(userCreds.user);
        }
      } on FirebaseAuthException catch (e) {
        showError(e.message, "ERROR");
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
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(15.0, 115.0, 0.0, 0.0),
                  child: const Text('Welcome to ActNow!',
                      style: TextStyle(
                          fontSize: 30.0, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 155, 0.0, 0.0),
                  child: const Text('Login to continue...',
                      style: TextStyle(fontSize: 15.0)),
                ),
              ],
            ),
            Container(
                padding:
                    const EdgeInsets.only(top: 100.0, left: 20.0, right: 20.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
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
                              labelText: 'EMAIL',
                              labelStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              focusedBorder: UnderlineInputBorder()),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          validator: (input) {
                            if (input == null || input.isEmpty) {
                              return "Enter a password";
                            }
                          },
                          controller: _userPassword,
                          decoration: const InputDecoration(
                              labelText: 'PASSWORD',
                              labelStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              focusedBorder: UnderlineInputBorder()),
                          obscureText: true,
                        ),
                        const SizedBox(height: 5.0),
                        Container(
                          alignment: const Alignment(1.0, 0.0),
                          padding: const EdgeInsets.only(top: 15.0),
                          child: const InkWell(
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        SizedBox(
                          height: 40.0,
                          child: Material(
                            borderRadius: BorderRadius.circular(20.0),
                            shadowColor: Colors.greenAccent,
                            color: Colors.green,
                            elevation: 7.0,
                            child: ElevatedButton(
                              onPressed: () {
                                loginEmailPass();
                              },
                              child: const Center(
                                child: Text(
                                  'LOGIN',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat'),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ))),
            const SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Don\'t have an accout?',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
                const SizedBox(width: 5.0),
                InkWell(
                  onTap: () {
                    Route route = MaterialPageRoute(
                        builder: (context) => const SignupPage());
                    Navigator.push(context, route);
                  },
                  child: const Text('Sign Up',
                      style: TextStyle(
                          color: Colors.blue,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        ));
  }
}
