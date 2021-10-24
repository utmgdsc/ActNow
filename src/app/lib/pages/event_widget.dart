import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class event_widget extends StatelessWidget {
  final String default_img_location =
      "https://storage.googleapis.com/support-kms-prod/ZAl1gIwyUsvfwxoW9ns47iJFioHXODBbIkrK";

  final String? img_location;
  final String? title;
  final String? creator;
  final DateTime? date_time;
  final int? num_attendees;

  event_widget({
    this.title,
    this.creator,
    this.date_time,
    this.num_attendees,
    this.img_location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(img_location ?? default_img_location),
              fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(10.0)),
      alignment: Alignment.bottomCenter,
      child: Column(
        children: [
          const SizedBox(height: 210.0),
          Container(
              alignment: Alignment.bottomCenter,
              width: double.infinity,
              height: 90,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title ?? ("Error: Missing Title"),
                          style: TextStyle(fontSize: 18.0, color: Colors.black),
                        ),
                        Row(children: [
                          InkResponse(
                            onTap: () {},
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite_border,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20.0),
                        ])
                      ]),
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
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        )
                      ]),
                ],
              ))
        ],
      ),
    );
  }
}

String formatDate(DateTime d) {
  if (d != null) {
    String formattedDate = DateFormat('E, MMM dd, yyyy – kk:mm a').format(d);

    return formattedDate;
  }

  return "Error Missing Date";
}
