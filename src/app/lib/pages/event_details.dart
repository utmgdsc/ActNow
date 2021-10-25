import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventDetails extends StatefulWidget {
  User? userCreds;
  Map<String, dynamic> userInfo;
  EventDetails({Key? key, required this.userCreds, required this.userInfo})
      : super(key: key);

  @override
  EventDetailsState createState() => EventDetailsState();
}

class EventDetailsState extends State<EventDetails> {
  final String default_img_location =
      "https://static01.nyt.com/images/2019/06/08/sports/08toronto-basketball3/merlin_155853060_bec166c9-17a2-4657-96eb-26da8326e94a-articleLarge.jpg?quality=75&auto=webp&disable=upscale";
  bool userJoined = false;
  bool userCreated = false;
  int numAttendes = 0;

  void checkUserCreated() {
    if (widget.userInfo["createdBy"] == widget.userCreds!.uid.toString()) {
      userCreated = true;
    }
  }

  @override
  void initState() {
    super.initState();
    checkUserCreated();
  }

  Map<String, String> formatDate() {
    var splitDate = widget.userInfo["dateTime"].toString().split(" ");
    var formattedDate = splitDate[0] + " " + splitDate[1] + " " + splitDate[2] + " " + splitDate[3];
    var formattedTime = splitDate[4] + " " + splitDate[5];

    return {"Date": formattedDate, "Time": formattedTime};
  }

  @override
  Widget build(BuildContext context) {
    double widthVariable = MediaQuery.of(context).size.width;

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
                    image: NetworkImage(default_img_location),
                    fit: BoxFit.cover)),
          ),
          Container(
              padding: const EdgeInsets.only(top: 0.0, left: 20.0, right: 20.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 15.0),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.userInfo["title"],
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 36.0, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 30.0),
                  buildInfoRow(
                      Icons.event, formatDate()["Date"]!, formatDate()["Time"]!),
                  const SizedBox(height: 20.0),
                  buildInfoRow(
                      Icons.location_on,
                      "University of Toronto Mississauga",
                      "3359 Mississauga Rd, Mississauga, ON L5L 1C6"),
                  const SizedBox(height: 20.0),
                  buildInfoRow(Icons.person, "Number of people joined:",
                      widget.userInfo["numAttendees"].toString()),
                  const SizedBox(height: 20.0),
                  Container(
                      decoration: const BoxDecoration(
                          border: Border(
                        top: BorderSide(color: Colors.black),
                      )),
                      child: Column(children: const [
                        SizedBox(height: 10.0),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text('About',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 21.0,
                                    fontWeight: FontWeight.bold))),
                        SizedBox(height: 20.0),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'It’s going to be a 3 on 3 with at the RAWC and we have it booked all day. And there’s also gonna be free drinks and food afterwards. Come and play some backetball with your classmates!',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16.0,
                                ))),
                      ])),
                  const SizedBox(height: 40.0),
                  SizedBox(
                      width: widthVariable,
                      height: 40.0,
                      child: Material(
                        borderRadius: BorderRadius.circular(20.0),
                        elevation: 7.0,
                        child: ElevatedButton(
                          style: userJoined
                              ? ElevatedButton.styleFrom(primary: Colors.red)
                              : ElevatedButton.styleFrom(primary: Colors.blue),
                          onPressed: userJoined
                              ? () {
                                  setState(() {
                                    userJoined = false;
                                    numAttendes -= 1;
                                  });
                                }
                              : () {
                                  setState(() {
                                    userJoined = true;
                                    numAttendes += 1;
                                  });
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
