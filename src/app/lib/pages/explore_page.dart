import 'package:actnow/pages/event_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'event_details.dart';

class ExplorePage extends StatefulWidget {
  //final User? userCreds;
  //final CollectionReference<Map<String, dynamic>> collectionRef;
  final User? userCreds;
  const ExplorePage({Key? key, required this.userCreds}) : super(key: key);
  //const ExplorePage({Key? key}) : super(key: key);

  @override
  ExplorePageState createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder(
                    initialData: [],
                    future: getEventData(),
                    builder: (context, AsyncSnapshot<List> snapshot) {
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          //itemCount: 2,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) => EventDetails(
                                        userCreds: widget.userCreds,
                                        collectionRef:
                                            snapshot.data![index].ref,
                                        eventUid: snapshot.data![index].id));
                                Navigator.push(context, route)
                                    .then((value) => setState(() {}));
                              },
                              child: EventWidget(
                                title: snapshot.data![index].title,
                                creator: snapshot.data![index].creator,
                                date_time: snapshot.data![index].date_time,
                                num_attendees:
                                    snapshot.data![index].num_attendees,
                                img_location:
                                    snapshot.data![index].img_location,
                              ),
                            );
                          });
                    },
                  ),
                ),
              ],
            )));
  }
}

class LocalEventDetails {
  final String? img_location;
  final String? title;
  final String? creator;
  final String? date_time;
  final int? num_attendees;
  final String? id;
  final CollectionReference? ref;

  LocalEventDetails(
      {this.title,
      this.creator,
      this.date_time,
      this.num_attendees,
      this.img_location,
      this.id,
      this.ref});
}

Future<List<LocalEventDetails>> getEventData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> events =
      firestore.collection('events').doc("custom").collection("Mississauga");

  List<LocalEventDetails> eventsList = <LocalEventDetails>[];
  await events.get().then((value) => {
        value.docs.forEach((element) {
          eventsList.add(LocalEventDetails(
              title: element['title'],
              num_attendees: element['numAttendees'],
              img_location: element['imageUrl'],
              date_time: element['dateTime'],
              creator: element['createdByName'],
              id: element.id,
              ref: events));
        })
      });

  return eventsList;
}
