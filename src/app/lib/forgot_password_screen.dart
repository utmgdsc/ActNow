import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Required for form validator

  final TextEditingController _userEmail = TextEditingController();

  forgotPassword() async {
    bool hasError = false;

    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _userEmail.text);

        //showError("The account already exists for that email", "ERROR");
      } catch (e) {
        hasError = true;
        showError("Please make sure that the email is valid", "ERROR");
      }

      if (!hasError) {
        showError("Please check your email for further instructions!",
            "Email has been sent");
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
                        child: Text('Forgot your password?',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 30.0))),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 130.0, 0.0, 0.0),
                    child: const Center(
                        child: Text('We can help with that...',
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
                                    forgotPassword();
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Send Email',
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
                        'Remember your password?',
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
