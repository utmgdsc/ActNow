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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 64),
            child: Column(
              children: [
                event_widget(
                  title: "test title",
                  creator: "test creator",
                  date_time: DateTime.now(),
                  num_attendees: 23,
                  img: "aaa",
                )
              ],
            )));
  }
}
