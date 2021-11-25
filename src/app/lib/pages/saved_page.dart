import 'dart:io';
import 'package:actnow/pages/event_details.dart';
import 'package:actnow/pages/explore_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_geocoding/google_geocoding.dart' as google_geocoding;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:actnow/widgets/event_widget.dart';
import 'package:actnow/widgets/search_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SavedPage extends StatefulWidget {
  //will not need userLocation after saved page displays ALL "saved" events
  final User? userCreds;
  final dynamic userLocation;
  const SavedPage(
      {Key? key, required this.userCreds, required this.userLocation})
      : super(key: key);

  @override
  SavedPageState createState() => SavedPageState();
}

class SavedPageState extends State<SavedPage> {
  var currentLocation;
  String query = '';
  late Future<List<LocalEventDetails>> _futureList;
  List<LocalEventDetails>? exploreEvents = null;
  List<LocalEventDetails>? unfilteredEvents = null;

  late bool searchSaved;
  late bool searchJoined;
  late bool searchCreated;

  @override
  void initState() {
    super.initState();

    //will not need to set currentLocation after saved page displays ALL "saved" events
    if (widget.userLocation == null) {
      currentLocation = const LatLng(43.55103829955488, -79.66262838104547);
    } else {
      currentLocation = widget.userLocation;
    }
    _futureList = getEventData();

    searchSaved = searchJoined = searchCreated = false;
  }

  late Map<String, dynamic>? userInfo;
  var saved_list;

  Future<void> updateInfo() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('users')
        .doc(widget.userCreds!.uid)
        .get()
        .then((value) {
      userInfo = value.data();
      userInfo!["email"] = widget.userCreds!.email;
      saved_list = value.data()!["saved_events"];
    });
  }

  Future<List<LocalEventDetails>> getEventData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    //temp code to show only events in users locations in saved tab

    late google_geocoding.GoogleGeocoding googleGeocoding;
    String? city;

    if (Platform.isAndroid) {
      googleGeocoding =
          google_geocoding.GoogleGeocoding(dotenv.env["API_KEY_ANDRIOD"]!);
    } else if (Platform.isIOS) {
      googleGeocoding =
          google_geocoding.GoogleGeocoding(dotenv.env["API_KEY_IOS"]!);
    }
    var result = await googleGeocoding.geocoding.getReverse(
        google_geocoding.LatLon(
            currentLocation!.latitude!, currentLocation.longitude!));

    List<String> splitAddress =
        result!.results![0].formattedAddress!.split(',');

    if (splitAddress.length >= 5) {
      city = splitAddress[2].trim();
    } else if (splitAddress.length == 3) {
      var formatAddress = splitAddress[0].split(" ")[1];
      city = formatAddress.trim();
    } else {
      city = splitAddress[1].trim();
    }

    city = city.toLowerCase();
    //temp code ends

    CollectionReference<Map<String, dynamic>> events =
        firestore.collection('events').doc("custom").collection(city);

    CollectionReference<Map<String, dynamic>> scrapedEvents =
        firestore.collection('events').doc("scraped-events").collection(city);

    await updateInfo();

    List<LocalEventDetails> eventsList = <LocalEventDetails>[];
    await events.get().then((value) => {
          value.docs.forEach((element) async {
            bool is_saved = saved_list.contains(element.id);
            bool is_joined =
                element['attendees'].contains(widget.userCreds!.uid);
            bool is_created = element['createdBy'] == widget.userCreds!.uid;

            bool defaults = (searchSaved == false &&
                    searchJoined == false &&
                    searchCreated == false) &&
                (is_saved || is_joined || is_created);

            if (defaults ||
                (is_saved && searchSaved) ||
                (is_joined && searchJoined) ||
                (is_created && searchCreated)) {
              eventsList.add(LocalEventDetails(
                  title: element['title'],
                  num_attendees: element['numAttendees'],
                  img_location: element['imageUrl'],
                  date_time: element['dateTime'],
                  creator: element['createdByName'],
                  id: element.id,
                  ref: events,
                  saved: is_saved));
            }
          })
        });

    await scrapedEvents.get().then((value) => {
          value.docs.forEach((element) async {
            bool is_saved = saved_list.contains(element.id);
            bool is_joined =
                element['attendees'].contains(widget.userCreds!.uid);

            bool defaults = (searchSaved == false &&
                    searchJoined == false &&
                    searchCreated == false) &&
                (is_saved || is_joined);

            if (defaults ||
                (is_saved && searchSaved) ||
                (is_joined && searchJoined) ||
                (searchCreated)) {
              eventsList.add(LocalEventDetails(
                  title: element['title'],
                  num_attendees: element['numAttendees'],
                  img_location: element['imageUrl'],
                  date_time: element['dateTime'],
                  creator: element['createdByName'],
                  id: element.id,
                  ref: scrapedEvents,
                  saved: is_saved));
            }
          })
        });

    setState(() {
      exploreEvents = eventsList;
      unfilteredEvents = eventsList;
    });
    return eventsList;
  }

  void searchEvent(String query) {
    final filterEvents = unfilteredEvents!.where((element) {
      final eventTitle = element.title!.toLowerCase();
      final searchLower = query.toLowerCase();

      return eventTitle.contains(searchLower);
    }).toList();

    setState(() {
      exploreEvents = filterEvents;
      this.query = query;
    });
  }

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'Search events',
        onChanged: searchEvent,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                buildSearch(),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: 100,
                    height: 30.0,
                    child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      shadowColor: Colors.grey,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: searchSaved ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => searchSaved = !searchSaved);
                          getEventData();
                        },
                        child: const Center(
                          child: Text(
                            'Saved',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  SizedBox(
                    width: 100,
                    height: 30.0,
                    child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      shadowColor: Colors.grey,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: searchJoined ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => searchJoined = !searchJoined);
                          getEventData();
                        },
                        child: const Center(
                          child: Text(
                            'Joined',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  SizedBox(
                    width: 100,
                    height: 30.0,
                    child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      shadowColor: Colors.grey,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: searchCreated ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => searchCreated = !searchCreated);
                          getEventData();
                        },
                        child: const Center(
                          child: Text(
                            'Created',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 10.0),
                Expanded(
                  child: FutureBuilder(
                    initialData: const [],
                    future: _futureList,
                    builder: (context, AsyncSnapshot<List> snapshot) {
                      return ListView.builder(
                          itemCount:
                              exploreEvents != null ? exploreEvents!.length : 0,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) => EventDetails(
                                        userCreds: widget.userCreds,
                                        collectionRef:
                                            exploreEvents![index].ref!,
                                        eventUid: exploreEvents![index].id!));
                                Navigator.push(context, route)
                                    .then((value) => setState(() {
                                          getEventData();
                                        }));
                              },
                              onDoubleTap: () {
                                updated_saved_item(exploreEvents![index].id);
                              },
                              child: EventWidget(
                                title: exploreEvents![index].title,
                                creator: exploreEvents![index].creator,
                                date_time: exploreEvents![index].date_time,
                                num_attendees:
                                    exploreEvents![index].num_attendees,
                                img_location:
                                    exploreEvents![index].img_location,
                                saved: exploreEvents![index].saved,
                              ),
                            );
                          });
                    },
                  ),
                ),
              ],
            )));
  }

  void updated_saved_item(String? event_id) {
    int event_index =
        exploreEvents!.indexWhere((element) => element.id == event_id);

    if (saved_list.contains(event_id)) {
      saved_list.remove(event_id);
      exploreEvents![event_index].saved = false;
    } else {
      saved_list.add(event_id);
      exploreEvents![event_index].saved = true;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userCreds!.uid)
        .update({'saved_events': saved_list});

    setState(() {});
  }
}
