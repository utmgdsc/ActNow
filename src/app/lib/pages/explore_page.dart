import 'dart:io';
import 'package:actnow/widgets/event_widget.dart';
import 'package:actnow/widgets/search_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_geocoding/google_geocoding.dart' as google_geocoding;
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'event_details.dart';

class LocalEventDetails {
  final String? img_location;
  final String? title;
  final String? creator;
  final String? date_time;
  final int? num_attendees;
  final String? id;
  final CollectionReference<Map<String, dynamic>>? ref;

  LocalEventDetails(
      {this.title,
      this.creator,
      this.date_time,
      this.num_attendees,
      this.img_location,
      this.id,
      this.ref});
}

class ExplorePage extends StatefulWidget {
  final User? userCreds;
  final dynamic userLocation;
  const ExplorePage(
      {Key? key, required this.userCreds, required this.userLocation})
      : super(key: key);

  @override
  ExplorePageState createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  var currentLocation;
  String query = '';
  LatLng defaultLocation = const LatLng(43.55103829955488, -79.66262838104547);
  late Future<List<LocalEventDetails>> _futureList;
  List<LocalEventDetails>? exploreEvents = null;
  List<LocalEventDetails>? unfilteredEvents = null;

  @override
  void initState() {
    super.initState();
    if (widget.userLocation == null) {
      currentLocation = defaultLocation;
    } else {
      currentLocation = widget.userLocation;
    }
    _futureList = getEventData();
  }

  Future<List<LocalEventDetails>> getEventData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
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

    CollectionReference<Map<String, dynamic>> events =
        firestore.collection('events').doc("custom").collection(city);

    CollectionReference<Map<String, dynamic>> scrapedEvents =
        firestore.collection('events').doc("scraped-events").collection(city);

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

    await scrapedEvents.get().then((value) => {
          value.docs.forEach((element) {
            eventsList.add(LocalEventDetails(
                title: element['title'],
                num_attendees: element['numAttendees'],
                img_location: element['imageUrl'],
                date_time: element['dateTime'],
                creator: element['createdByName'],
                id: element.id,
                ref: scrapedEvents));
          })
        });

    setState(() {
      exploreEvents = eventsList;
      unfilteredEvents = eventsList;
    });
    return eventsList;
  }

  @override
  Widget build(BuildContext context) {
    double widthVariable = MediaQuery.of(context).size.width;
    double heightVariable = MediaQuery.of(context).size.height;

    if (currentLocation == null || exploreEvents == null) {
      return Scaffold(
          body: SizedBox(
        height: heightVariable,
        width: widthVariable,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ));
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

    return Scaffold(
        body: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                buildSearch(),
                Expanded(
                  child: FutureBuilder(
                    initialData: [],
                    future: _futureList,
                    builder: (context, AsyncSnapshot<List> snapshot) {
                      return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: exploreEvents!.length,
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
                              child: EventWidget(
                                title: exploreEvents![index].title,
                                creator: exploreEvents![index].creator,
                                date_time: exploreEvents![index].date_time,
                                num_attendees:
                                    exploreEvents![index].num_attendees,
                                img_location:
                                    exploreEvents![index].img_location,
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
