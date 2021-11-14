import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class PersonalInfo extends StatefulWidget {
  final Map<String, dynamic>? userInfo;

  const PersonalInfo({Key? key, required this.userInfo}) : super(key: key);

  @override
  PersonalInfoState createState() => PersonalInfoState();
}

class PersonalInfoState extends State<PersonalInfo> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Required for form validator

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.userInfo!["firstname"]);
    _lastName = TextEditingController(text: widget.userInfo!["lastname"]);
    _email = TextEditingController(text: widget.userInfo!["email"]);
  }

  updateUserInfo(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      DocumentReference ref = users.doc(widget.userInfo!["userid"]);
      if (_firstName.text.isNotEmpty &&
          _firstName.text != widget.userInfo!["firstname"]) {
        ref.update({'firstname': _firstName.text});
      }
      if (_lastName.text.isNotEmpty &&
          _lastName != widget.userInfo!["lastname"]) {
        ref.update({'lastname': _lastName.text});
      }

      if (_image != null) {
        var data = await ref.get();
        var fileRef = firebase_storage.FirebaseStorage.instance
            .ref(const Uuid().v4().toString());
        try {
          await fileRef.putFile(File(_image!.path));
        } catch (e) {
          // e.g, e.code == 'canceled'
        }
        var imageUrl = await fileRef.getDownloadURL();

        var dataMap = data.data() as Map<String, dynamic>;
        if (dataMap.containsKey("profile_picture")) {
          await FirebaseStorage.instance
              .refFromURL(dataMap["profile_picture"])
              .delete();
        }
        ref.update({'profile_picture': imageUrl});
      }

      Navigator.of(context).pop();
    }
  }

  void _imgFromCamera() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  void _imgFromGallery() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: const BackButton(color: Colors.black),
            backgroundColor: Colors.transparent,
            elevation: 0),
        body: Container(
          padding: const EdgeInsets.only(left: 16, top: 0, right: 16),
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                        width: 130,
                        height: 130,
                        child: CircleAvatar(
                          backgroundImage: _image == null
                              ? NetworkImage(widget
                                          .userInfo!["profile_picture"] ??
                                      "https://profilepicturemaker.com/wp-content/themes/ppm2021/images/transparent.gif")
                                  as ImageProvider
                              : FileImage(File(_image!.path)),
                        ),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 4,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(0, 10))
                            ])),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            color: Colors.blue,
                          ),
                          child: GestureDetector(
                              onTap: () {
                                _showPicker(context);
                              },
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              )),
                        )),
                  ],
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(bottom: 35.0),
                          child: TextFormField(
                            controller: _firstName,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 3),
                                labelText: "First Name",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(bottom: 35.0),
                          child: TextFormField(
                            controller: _lastName,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 3),
                                labelText: "Last Name",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                )),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(bottom: 35.0),
                          child: TextFormField(
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
                            controller: _email,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 3),
                                labelText: "Email",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always),
                          )),
                      buildTextField("Location", "Mississauga, ON"),
                    ],
                  )),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
                    height: 40.0,
                    child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      shadowColor: Colors.grey,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            side: const BorderSide(color: Colors.blue)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Center(
                          child: Text(
                            'CANCEL',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    height: 40.0,
                    child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      shadowColor: Colors.grey,
                      child: ElevatedButton(
                        onPressed: () {
                          updateUserInfo(context);
                        },
                        child: const Center(
                          child: Text(
                            'SAVE',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20)
            ],
          ),
        ));
  }

  Widget buildTextField(String labelText, String placeholder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: const TextStyle(
              color: Colors.black,
            )),
      ),
    );
  }
}
