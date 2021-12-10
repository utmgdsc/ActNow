import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  ContactUsState createState() => ContactUsState();
}

class ContactUsState extends State<ContactUs> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Required for form validator

  final TextEditingController _userName = TextEditingController();
  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _userMessage = TextEditingController();

  sendEmail() async {
    if (_formKey.currentState!.validate()) {
      final Email email = Email(
        body: _userMessage.text,
        subject: _userName.text + " Feedback",
        recipients: ['actnowdev.help@gmail.com'],
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            leading: const BackButton(color: Colors.black),
            backgroundColor: Colors.transparent,
            elevation: 0),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          Stack(
            children: const <Widget>[
              Center(
                  child: Text('Contact Us',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30.0))),
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
                        controller: _userName,
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return "Please enter a name";
                          }
                        },
                        decoration: const InputDecoration(
                            labelText: 'Name ',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _userMessage,
                        keyboardType: TextInputType.multiline,
                        minLines: 6,
                        maxLines: null,
                        decoration: const InputDecoration(
                            alignLabelWithHint: true,
                            labelText: 'Message',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      ),
                      const SizedBox(height: 30.0),
                      SizedBox(
                          width: 180,
                          height: 40.0,
                          child: Material(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.green,
                            elevation: 7.0,
                            child: ElevatedButton(
                              onPressed: () {
                                sendEmail();
                              },
                              child: const Center(
                                child: Text(
                                  'Send',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )),
                      const SizedBox(height: 20.0),
                    ],
                  ))),
        ])));
  }
}
