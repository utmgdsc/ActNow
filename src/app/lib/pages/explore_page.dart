import 'package:actnow/pages/event_widget.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
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
                  child: ListView(
                    children: [
                      EventWidget(
                        title: "test title",
                        creator: "test creator 232",
                        date_time: DateTime.now(),
                        num_attendees: 23,
                      ),
                      EventWidget(
                        title: "test title",
                        creator: "test creator",
                        date_time: DateTime.now(),
                        num_attendees: 223,
                        img_location: 'https://i.imgur.com/jaPAgQH.jpeg',
                      ),
                      EventWidget(
                        title: "test title",
                        creator: "test creator 4251255",
                        date_time: DateTime.now(),
                        num_attendees: 23,
                        img_location:
                            'https://img.bleacherreport.net/img/images/photos/003/813/911/hi-res-76dc39978a7762c48eab1955cb58d65f_crop_north.jpg?1560490545&w=3072&h=2048',
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}
