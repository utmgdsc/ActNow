import 'dart:async';
import 'dart:io';
import 'package:actnow/pages/event_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_geocoding/google_geocoding.dart' as google_geocoding;
import 'package:location/location.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'add_event.dart';

class MapPage extends StatefulWidget {
  final User? userCreds;
  final dynamic userLocation;
  final Function(dynamic) onUpdateLocation;
  const MapPage(
      {Key? key,
      required this.userCreds,
      required this.userLocation,
      required this.onUpdateLocation})
      : super(key: key);

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  BitmapDescriptor? userIcon;
  bool addedNewEvent = false;
  Map<String, String> formDetails = {};
  bool allEventsRead = false;
  bool allUsersRead = false;
  final List<Marker> _markers = [];
  final Completer<GoogleMapController> _controller = Completer();
  late LatLng droppedIn;
  bool disableAddEvent = false;
  var currentLocation;
  LatLng defaultLocation = const LatLng(43.55103829955488, -79.66262838104547);

  @override
  void initState() {
    super.initState();
    print(widget.userLocation);
    if (widget.userLocation == null) {
      currentLocation = defaultLocation;
    } else {
      currentLocation = widget.userLocation;
    }
    _loadMapData();
    getIcons();
  }

  getIcons() async {
    var icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/Icon.png");
    setState(() {
      userIcon = icon;
    });
  }

  void _loadMapData() async {
    await getAllEvents();
    await getAllUsers();
  }

  Future<void> _getCurrentLocation() async {
    var rawLocation = Location();
    var serviceEnabled = await rawLocation.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await rawLocation.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    var permissionGranted = await rawLocation.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await rawLocation.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    try {
      var newLocation = await rawLocation.getLocation();
      widget.onUpdateLocation(newLocation);
      setState(() {
        currentLocation = newLocation;
      });
    } catch (e) {
      setState(() {
        currentLocation = defaultLocation;
      });
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    if (!_controller.isCompleted) {
      _controller.complete(controller);
    }
    controller.setMapStyle(
        MapStyle.someLandMarks); //TODO: Allow users to choose their theme
  }

  Future<void> getAllUsers() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference<Map<String, dynamic>> ref =
        firestore.collection('users');

    await ref.get().then((value) => {
          value.docs.forEach((element) {
            var pos = LatLng(element["latitude"], element["longitude"]);
            var markerToAdd = Marker(
                icon: userIcon!,
                markerId: MarkerId(pos.toString()),
                position: pos,
                draggable: true,
                onDragEnd: (dragPos) {
                  droppedIn = dragPos;
                });
            if (!_markers.contains(markerToAdd)) {
              _markers.add(markerToAdd);
            }
          }),
          setState(() {
            allUsersRead = true;
          })
        });
  }

  Future<void> getAllEvents() async {
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

    CollectionReference<Map<String, dynamic>> ref =
        firestore.collection('events').doc("custom").collection(city);

    await ref.get().then((value) => {
          value.docs.forEach((element) {
            var pos = LatLng(element["latitude"], element["longitude"]);
            var markerToAdd = Marker(
                markerId: MarkerId(pos.toString()),
                onTap: () {
                  Route route = MaterialPageRoute(
                      builder: (context) => EventDetails(
                          userCreds: widget.userCreds,
                          collectionRef: ref,
                          eventUid: element.id));
                  Navigator.push(context, route).then((value) => setState(() {
                        if (value != null) {
                          _markers.removeWhere((marker) =>
                              marker.markerId.value ==
                              LatLng(value.latitude, value.longitude)
                                  .toString());
                        }
                      }));
                },
                position: pos,
                draggable: true,
                onDragEnd: (dragPos) {
                  droppedIn = dragPos;
                });
            if (!_markers.contains(markerToAdd)) {
              _markers.add(markerToAdd);
            }
          }),
          setState(() {
            allEventsRead = true;
          })
        });
  }

  void _moveToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(currentLocation.latitude ?? defaultLocation.latitude,
            currentLocation.longitude ?? defaultLocation.longitude),
        zoom: 15.0)));
  }

  void addMarker(LatLng tappedPosition) {
    setState(() {
      //here we could maybe loop through all our current events and add to map
      droppedIn = tappedPosition;
      _markers.add(Marker(
          markerId: const MarkerId("New Event"),
          position: tappedPosition,
          draggable: true,
          onDragEnd: (dragPos) {
            droppedIn = dragPos;
          }));

      disableAddEvent = true;
    });
  }

  void handleTap(LatLng tappedPosition) {
    if (addedNewEvent == false) {
      addMarker(tappedPosition);
      addedNewEvent = true;
    } else if (addedNewEvent = true && _markers.remove(_markers.last)) {
      addMarker(tappedPosition);
    }
  }

  void clearAddedMarker() {
    _markers.remove(_markers.last);
    addedNewEvent = false;
    disableAddEvent = false;
  }

  @override
  Widget build(BuildContext context) {
    double widthVariable = MediaQuery.of(context).size.width;
    double heightVariable = MediaQuery.of(context).size.height;

    if (allEventsRead == false ||
        allUsersRead == false ||
        currentLocation == null) {
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
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Visibility(
            visible: disableAddEvent,
            child: FloatingActionButton(
              heroTag: "btn2",
              onPressed: () {
                Route route = MaterialPageRoute(
                    builder: (context) => AddEvent(
                          userCreds: widget.userCreds,
                          droppedPin: droppedIn,
                          updateEvent: null,
                          formDetail: formDetails,
                        ));
                Navigator.push(context, route).then((value) => {
                      if (value == "Added")
                        {
                          formDetails = {},
                          clearAddedMarker(),
                          getAllEvents(),
                        }
                      else if (value != null)
                        {
                          formDetails = value,
                        }
                      else
                        {
                          formDetails = {},
                          if (_markers.remove(_markers.last))
                            {
                              setState(() {
                                addedNewEvent = false;
                                disableAddEvent = false;
                              })
                            }
                        }
                    });
              },
              child: const Icon(
                Icons.add,
                color: Colors.blue,
              ),
              backgroundColor: Colors.white,
            )),
        const SizedBox(height: 15),
        FloatingActionButton(
          onPressed: () async {
            _getCurrentLocation()
                .then((value) => {_loadMapData(), _moveToCurrentLocation()});
          },
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
          ),
          backgroundColor: Colors.white,
        ),
      ]),
      body: GoogleMap(
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: _onMapCreated,
          markers: Set<Marker>.of(_markers),
          onTap: handleTap,
          initialCameraPosition: CameraPosition(
              target:
                  LatLng(currentLocation.latitude, currentLocation.longitude),
              zoom: 15)),
    );
  }
}

class MapStyle {
  static String noLandMarks = '''
  [
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
]
  ''';

  static String someLandMarks = '''
  [
    {
      "featureType": "poi.business",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    }
  ]
  ''';

  static String darkModeNoLandMarks = '''
  [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#757575"
      },
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#181818"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1b1b1b"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#2c2c2c"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8a8a8a"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#373737"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3c3c3c"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#4e4e4e"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#000000"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3d3d3d"
      }
    ]
  }
]
  ''';

  static String darkModeSomeLandMarks = '''
  [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#212121"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.business",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#181818"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1b1b1b"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#2c2c2c"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8a8a8a"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#373737"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3c3c3c"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#4e4e4e"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#000000"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3d3d3d"
      }
    ]
  }
]
  ''';

  static String nightModeNoLandMarks = '''
  [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
  ''';

  static String nightModeSomeLandMarks = '''
  [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.business",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
  ''';
}
