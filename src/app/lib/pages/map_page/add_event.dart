import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class AddEvent extends StatefulWidget {
  final User? userCreds;
  final LatLng? droppedPin;
  final Map? formDetail;
  const AddEvent(
      {Key? key,
      required this.userCreds,
      required this.droppedPin,
      this.formDetail})
      : super(key: key);

  @override
  AddEventState createState() => AddEventState();
}

class AddEventState extends State<AddEvent> {
  String? userAddress;
  late TextEditingController dateControl;
  late TextEditingController titleControl;
  late TextEditingController descControl;
  String? streetAddress;
  bool _enableBtn = false;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Required for form validator

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('events');

  TextEditingController? locationControl;

  void checkButtonStatus() {
    if (dateControl.text != "" &&
        titleControl.text != "" &&
        descControl.text != "") {
      _enableBtn = true;
    }
  }

  @override
  void initState() {
    super.initState();
    dateControl = TextEditingController(text: widget.formDetail!["date"] ?? "");
    titleControl =
        TextEditingController(text: widget.formDetail!["title"] ?? "");
    descControl = TextEditingController(text: widget.formDetail!["desc"] ?? "");
    getUserLocation(widget.droppedPin);
    setState(() {
      checkButtonStatus();
    });
  }

  addEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        CollectionReference ref = firestore
            .collection('events')
            .doc("custom")
            .collection(userAddress!);

        await ref.add({
          'title': titleControl.text,
          'location': streetAddress,
          'latitude': widget.droppedPin!.latitude,
          'longitude': widget.droppedPin!.longitude,
          'dateTime': dateControl.text,
          'description': descControl.text,
          'createdBy': widget.userCreds!.uid,
        });

        showBox("Event Added Succesfully", "SUCCESS");
      } catch (e) {
        showBox(e.toString(), "ERROR");
      }
    }
  }

  getUserLocation(LatLng? position) async {
    late GoogleGeocoding googleGeocoding;
    if (Platform.isAndroid) {
      googleGeocoding = GoogleGeocoding(dotenv.env["API_KEY_ANDRIOD"]!);
    } else if (Platform.isIOS) {
      googleGeocoding = GoogleGeocoding(dotenv.env["API_KEY_IOS"]!);
    }
    var result = await googleGeocoding.geocoding
        .getReverse(LatLon(position!.latitude, position.longitude));

    String? locationString;
    List<String> splitAddress =
        result!.results![0].formattedAddress!.split(',');

    if (splitAddress.length >= 5) {
      locationString = splitAddress[0] + splitAddress[1];
      userAddress = splitAddress[2].trim();
    } else if (splitAddress.length == 3) {
      var formatAddress = splitAddress[0].split(" ")[1];
      locationString = formatAddress;
      userAddress = formatAddress.trim();
    } else {
      locationString = splitAddress[0];
      userAddress = splitAddress[1].trim();
    }
    streetAddress = result.results![0].formattedAddress;

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
                    FocusScope.of(context).unfocus();
                    if (title == "SUCCESS") {   
                      Navigator.of(context).pop("Added");
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
                  onChanged: () => setState(() => {checkButtonStatus()}),
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
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Navigator.of(context).pop({
                            "title": titleControl.text,
                            "desc": descControl.text,
                            "date": dateControl.text,
                          });
                        },
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
