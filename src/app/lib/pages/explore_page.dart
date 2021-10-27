import 'package:actnow/pages/event_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  //final User? userCreds;
  //final CollectionReference<Map<String, dynamic>> collectionRef;
  const ExplorePage({Key? key}) : super(key: key);

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
                            return EventWidget(
                              title: snapshot.data![index].title,
                              creator: snapshot.data![index].creator,
                              date_time: snapshot.data![index].date_time,
                              num_attendees:
                                  snapshot.data![index].num_attendees,
                              img_location: snapshot.data![index].img_location,
                            );
                          });
                    },
                  ),
                ),
              ],
            )));
  }
}

class EventDetails {
  final String? img_location;
  final String? title;
  final String? creator;
  final String? date_time;
  final int? num_attendees;

  EventDetails({
    this.title,
    this.creator,
    this.date_time,
    this.num_attendees,
    this.img_location,
  });

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': img_location,
      'title': title,
      'dateTime': date_time,
      'numAttendees': num_attendees
    };
  }
}

Future<List<EventDetails>> getEventData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> events =
      firestore.collection('events').doc("custom").collection("Mississauga");

  List<EventDetails> eventsList = <EventDetails>[];
  await events.get().then((value) => {
        value.docs.forEach((element) {
          eventsList.add(EventDetails(
              title: element['title'],
              num_attendees: element['numAttendees'],
              img_location: element['imageUrl'],
              date_time: element['dateTime'],
              creator: element['createdByName']));
        })
      });

  return eventsList;
}
