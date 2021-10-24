import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class event_widget extends StatelessWidget {
  final String? img;
  final String? title;
  final String? creator;
  final DateTime? date_time;
  final int? num_attendees;

  event_widget({
    this.title,
    this.creator,
    this.date_time,
    this.num_attendees,
    this.img,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(10.0)),
        alignment: Alignment.bottomCenter,
        child: Container(
            alignment: Alignment.bottomCenter,
            width: double.infinity,
            height: 110,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(10.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? ("Error: Missing Title"),
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                ),
                Text(
                  formatDate(date_time!),
                  style: TextStyle(fontSize: 14.0, color: Colors.blue[800]),
                ),
                const SizedBox(height: 20.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Posted by " + creator!,
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Text(
                        "+ " + num_attendees.toString() + " attendees",
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      )
                    ]),
              ],
            )));
  }
}

String formatDate(DateTime d) {
  if (d != null) {
    String formattedDate = DateFormat('E, MMM dd, yyyy – kk:mm a').format(d);

    return formattedDate;
  }

  return "Error Missing Date";
}
