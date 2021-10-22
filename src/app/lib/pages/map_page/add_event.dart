import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class AddEvent extends StatefulWidget {
  final User? userCreds;
  final LatLng? droppedPin;
  const AddEvent({Key? key, required this.userCreds, required this.droppedPin})
      : super(key: key);

  @override
  AddEventState createState() => AddEventState();
}

class AddEventState extends State<AddEvent> {
  final TextEditingController dateControl = TextEditingController();
  final TextEditingController titleControl = TextEditingController();
  final TextEditingController descControl = TextEditingController();
  bool _enableBtn = false;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Required for form validator

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('events');

  TextEditingController? locationControl = null;

  @override
  void initState() {
    super.initState();
    getUserLocation(widget.droppedPin);
  }

  addEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        CollectionReference ref = firestore
            .collection('events')
            .doc("custom")
            .collection("mississauga");

        ref.add({
          'title': titleControl.text,
          'location': locationControl!.text,
          'latitude': widget.droppedPin!.latitude,
          'longitude': widget.droppedPin!.longitude,
          'dateTime': dateControl.text,
          'description': descControl.text,
          'addedBy': widget.userCreds!.uid,
        });

        showBox("Event Added Succesfully", "SUCCESS");
      } catch (e) {
        showBox(e.toString(), "ERROR");
      }
    }
  }

  getUserLocation(LatLng? position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position!.latitude, position.longitude);

    String? locationString = placemarks[0].street!;
    print(placemarks[0]);

    setState(() {
      locationControl = TextEditingController(text: locationString);
    });
  }

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
                    if (title == "SUCCESS") {
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
    double widthVariable = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
            leading: const BackButton(color: Colors.white),
            backgroundColor: Colors.blue,
            elevation: 0),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          Container(
            width: widthVariable,
            height: 150,
            color: Colors.grey[400],
            child: Padding(
              padding: EdgeInsets.fromLTRB(widthVariable / 1.2, 100, 0, 10),
              child: FloatingActionButton(
                heroTag: "btn2",
                mini: true,
                onPressed: () {},
                child: const Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Container(
              padding: const EdgeInsets.only(top: 0.0, left: 20.0, right: 20.0),
              child: Form(
                  key: _formKey,
                  onChanged: () => setState(() => {
                        if (dateControl.text != "" &&
                            titleControl.text != "" &&
                            locationControl!.text != "" &&
                            descControl.text != "")
                          {_enableBtn = true}
                      }),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: titleControl,
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return "Please enter a Title";
                          }
                        },
                        decoration: const InputDecoration(
                            labelText: 'Title ',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: locationControl,
                        onTap: () async {},
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return "Enter a location";
                          }
                        },
                        decoration: const InputDecoration(
                            labelText: 'Location',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: dateControl,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());

                          DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100));

                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          dateControl.text =
                              DateFormat('EEEE, d MMM, yyyy').format(date!) +
                                  " " +
                                  time!.format(context) +
                                  " " +
                                  date.timeZoneName;
                        },
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return "Enter a time and date";
                          }
                        },
                        decoration: const InputDecoration(
                            labelText: 'Time',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: descControl,
                        keyboardType: TextInputType.multiline,
                        minLines: 6,
                        maxLines: null,
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return "";
                          }
                        },
                        decoration: const InputDecoration(
                            alignLabelWithHint: true,
                            labelText: 'Description',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      ),
                      const SizedBox(height: 30.0),
                      SizedBox(
                          width: widthVariable,
                          height: 40.0,
                          child: Material(
                            borderRadius: BorderRadius.circular(20.0),
                            elevation: 7.0,
                            child: ElevatedButton(
                              style: _enableBtn
                                  ? ElevatedButton.styleFrom(
                                      primary: Colors.blue)
                                  : ElevatedButton.styleFrom(
                                      primary: Colors.grey),
                              onPressed: _enableBtn
                                  ? () {
                                      addEvent();
                                    }
                                  : () {},
                              child: const Center(
                                child: Text(
                                  'Save',
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
