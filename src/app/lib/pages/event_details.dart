import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_page/add_event.dart';

class EventDetails extends StatefulWidget {
  final User? userCreds;
  final CollectionReference<Map<String, dynamic>> collectionRef;
  final String eventUid;
  const EventDetails(
      {Key? key,
      required this.userCreds,
      required this.collectionRef,
      required this.eventUid})
      : super(key: key);

  @override
  EventDetailsState createState() => EventDetailsState();
}

class EventDetailsState extends State<EventDetails> {
  bool userJoined = false;
  bool userCreated = false;
  Map<String, dynamic>? userInfo;

  void getUserInfo() async {
    await widget.collectionRef.doc(widget.eventUid).get().then((value) => {
          setState(() {
            userInfo = value.data();
          }),
          checkUserCreated(),
          if (!userCreated)
            {
              checkUserJoined(),
            }
        });
  }

  void checkUserCreated() {
    if (userInfo!["createdBy"] == widget.userCreds!.uid.toString()) {
      userCreated = true;
    }
  }

  void checkUserJoined() {
    (userInfo!["attendees"] as List<dynamic>).forEach((element) {
      if (element.toString() == widget.userCreds!.uid) {
        userJoined = true;
        return;
      }
    });
  }

  void joinEvent() async {
    List<dynamic> attendesList = userInfo!["attendees"];
    var numAttendees = userInfo!["numAttendees"];
    numAttendees += 1;
    attendesList.add(widget.userCreds!.uid.toString());

    await widget.collectionRef
        .doc(widget.eventUid)
        .update({"attendees": attendesList, "numAttendees": numAttendees});

    setState(() {
      userJoined = true;
      getUserInfo();
    });
  }

  void cancelEvent() async {
    List<dynamic> attendesList = userInfo!["attendees"];
    var numAttendees = userInfo!["numAttendees"];
    numAttendees -= 1;
    attendesList.remove(widget.userCreds!.uid.toString());

    await widget.collectionRef
        .doc(widget.eventUid)
        .update({"attendees": attendesList, "numAttendees": numAttendees});

    setState(() {
      userJoined = false;
      getUserInfo();
    });
  }

  void deleteEvent() async {
    await widget.collectionRef.doc(widget.eventUid).delete();
    await FirebaseStorage.instance.refFromURL(userInfo!["imageUrl"]).delete();
  }

  void editEvent() {
    var formDetails = {
      'title': userInfo!["title"],
      'location': userInfo!["location"],
      'latitude': userInfo!["latitude"],
      'longitude': userInfo!["longitude"],
      'date': userInfo!["dateTime"],
      'desc': userInfo!["description"],
    };
    Route route = MaterialPageRoute(
        builder: (context) => AddEvent(
              userCreds: widget.userCreds,
              droppedPin: LatLng(userInfo!["latitude"], userInfo!["longitude"]),
              updateEvent: widget.eventUid,
              formDetail: formDetails,
            ));
    Navigator.push(context, route).then((value) => setState(() {
          getUserInfo();
        }));
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
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    deleteEvent();
                    Navigator.of(context).pop(
                        LatLon(userInfo!["latitude"], userInfo!["longitude"]));
                  },
                  child: const Text('Yes'))
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Map<String, String> formatDate() {
    var splitDate = userInfo!["dateTime"].toString().split(" ");
    var formattedDate = splitDate[0] +
        " " +
        splitDate[2] +
        " " +
        splitDate[1] +
        " " +
        splitDate[3];
    var formattedTime = splitDate[4] + " " + splitDate[5];

    return {"Date": formattedDate, "Time": formattedTime};
  }

  Map<String, String> formatLocation() {
    var splitLocation = userInfo!["location"].toString().split(",");
    String formatMainLocation;
    String formatSubLocation;
    if (splitLocation.length < 4) {
      formatMainLocation = splitLocation[0];
      formatSubLocation = splitLocation[0].split(" ")[1] +
          ", " +
          splitLocation[1] +
          ", " +
          splitLocation[2];
    } else {
      formatMainLocation = splitLocation[0];
      formatSubLocation = splitLocation[1].split(" ")[1] +
          ", " +
          splitLocation[2] +
          ", " +
          splitLocation[3];
    }

    return {"Main": formatMainLocation, "Sub": formatSubLocation};
  }

  @override
  Widget build(BuildContext context) {
    double widthVariable = MediaQuery.of(context).size.width;
    double heightVariable = MediaQuery.of(context).size.height;

    Widget buildInfoRow(IconData icon, String upperText, String lowerTest) {
      return Row(
        children: [
          Icon(
            icon,
            size: 35,
            color: Colors.grey,
          ),
          const SizedBox(width: 7),
          Stack(
            children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Text(
                    upperText,
                    style: const TextStyle(fontSize: 15),
                  )),
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                  width: widthVariable * 0.77,
                  child: Text(
                    lowerTest,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  )),
            ],
          )
        ],
      );
    }

    if (userInfo == null) {
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
        appBar: AppBar(
            leading: const BackButton(color: Colors.white),
            backgroundColor: Colors.blue,
            elevation: 0),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          Container(
            width: widthVariable,
            height: 150,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(userInfo!["imageUrl"]),
                    fit: BoxFit.cover)),
          ),
          Container(
              padding: const EdgeInsets.only(top: 0.0, left: 20.0, right: 20.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 15.0),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(userInfo!["title"],
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 36.0, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 30.0),
                  buildInfoRow(Icons.event, formatDate()["Date"]!,
                      formatDate()["Time"]!),
                  const SizedBox(height: 20.0),
                  buildInfoRow(Icons.location_on, formatLocation()["Main"]!,
                      formatLocation()["Sub"]!),
                  const SizedBox(height: 20.0),
                  buildInfoRow(Icons.person, "Number of people joined:",
                      userInfo!["numAttendees"].toString()),
                  const SizedBox(height: 20.0),
                  Container(
                      decoration: const BoxDecoration(
                          border: Border(
                        top: BorderSide(color: Colors.black),
                      )),
                      child: Column(children: [
                        const SizedBox(height: 10.0),
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('About',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 21.0,
                                    fontWeight: FontWeight.bold))),
                        const SizedBox(height: 20.0),
                        SizedBox(
                            height: 100,
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(userInfo!["description"].toString(),
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    )))),
                      ])),
                  const SizedBox(height: 20.0),
                  userCreated
                      ? Column(children: [
                          SizedBox(
                              width: widthVariable,
                              height: 40.0,
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                elevation: 7.0,
                                child: ElevatedButton(
                                  style: userJoined
                                      ? ElevatedButton.styleFrom(
                                          primary: Colors.red)
                                      : ElevatedButton.styleFrom(
                                          primary: Colors.blue),
                                  onPressed: () {
                                    editEvent();
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Edit',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 20.0),
                          SizedBox(
                              width: widthVariable,
                              height: 40.0,
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                elevation: 7.0,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red),
                                  onPressed: () {
                                    showBox(
                                        "Are you sure you want to delete the event?",
                                        "Warning");
                                  },
                                  child: const Center(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ))
                        ])
                      : SizedBox(
                          width: widthVariable,
                          height: 40.0,
                          child: Material(
                            borderRadius: BorderRadius.circular(20.0),
                            elevation: 7.0,
                            child: ElevatedButton(
                              style: userJoined
                                  ? ElevatedButton.styleFrom(
                                      primary: Colors.red)
                                  : ElevatedButton.styleFrom(
                                      primary: Colors.blue),
                              onPressed: userJoined
                                  ? () {
                                      cancelEvent();
                                    }
                                  : () {
                                      joinEvent();
                                    },
                              child: userJoined
                                  ? const Center(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  : const Center(
                                      child: Text(
                                        'Join',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                            ),
                          )),
                  const SizedBox(height: 20.0),
                ],
              )),
        ])));
  }
}
