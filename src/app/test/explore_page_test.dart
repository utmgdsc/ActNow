import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_geocoding/google_geocoding.dart';

import 'package:actnow/pages/explore_page.dart';
import 'mock_network_image.dart';

const eventsCollection = 'events';
const customEventsDoc = 'custom';
const scrapedEventsDoc = 'scraped-events';
const userDisplayName = 'test_user';
const userUid = 'test_uid';
const userEmail = 'test@gmail.com';

class FormattedAddress {
  String formattedAddress =
      "3359 Mississauga Rd, Mississauga, ON L5L 1C6, Canada";
}

class Results {
  List<FormattedAddress> results = [FormattedAddress()];
}

class Geocoding {
  Future<Results> getReverse(LatLon _) async {
    return Results();
  }
}

class MockGoogleGeocoding {
  late Geocoding geocoding;

  MockGoogleGeocoding() {
    geocoding = Geocoding();
  }
}

void main() {
  User? user;
  FirebaseFirestore? firestore;

  signIn() async {
    // Mock sign in with Google.
    final googleSignIn = MockGoogleSignIn();
    final signinAccount = await googleSignIn.signIn();
    final googleAuth = await signinAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Sign in.
    final userInfo = MockUser(
      isAnonymous: false,
      uid: userUid,
      email: userEmail,
      displayName: userDisplayName,
    );
    final auth = MockFirebaseAuth(mockUser: userInfo);
    final result = await auth.signInWithCredential(credential);
    user = result.user;
  }

  setupFirestore() async {
    // Populate the fake database.
    firestore = FakeFirebaseFirestore();

    // user info
    await firestore!.collection("users").doc(userUid).set({
      "firstName": "tester",
      "lastName": "test",
      "isSwtiched": false,
      "saved_events": [],
      "user_id": userUid,
      "username": userDisplayName
    });

    // custom events
    await firestore!
        .collection(eventsCollection)
        .doc(customEventsDoc)
        .collection("mississauga")
        .add({
      "attendees": [],
      "createdBy": userUid,
      "createdByName": "Bob",
      "dateTime": "Sunday, 28 Nov 2021 10:08 PM EST",
      "description": "test custom event description",
      "imageUrl":
          "https://www.pixsy.com/wp-content/uploads/2021/04/ben-sweet-2LowviVHZ-E-unsplash-1.jpeg",
      "latitude": 43.550063228477036,
      "longtitude": -79.66152995824812,
      "numAttendees": 0,
      "title": "test custom event",
      "location": "65 Kimborough Hollow, Brampton, ON L6Y 0Z2, Canada",
    });

    // scraped events
    await firestore!
        .collection(eventsCollection)
        .doc(scrapedEventsDoc)
        .collection("mississauga")
        .add({
      "attendees": [],
      "createdBy": userUid,
      "createdByName": "Dan",
      "dateTime": "Saturday, 27 Nov 2021 10:08 PM EST",
      "description": "test scraped event desecription",
      "imageUrl":
          "https://www.pixsy.com/wp-content/uploads/2021/04/ben-sweet-2LowviVHZ-E-unsplash-1.jpeg",
      "latitude": 43.550063228477036,
      "longtitude": -79.66152995824812,
      "numAttendees": 90,
      "title": "test scraped event",
      "location": "70 Kimborough Hollow, Brampton, ON L6Y 0Z2, Canada",
    });
  }

  setUp(() async {
    await signIn();
    await setupFirestore();
  });

  test("setup should return correct user info (displayNamm, email, uid)", () {
    expect(user?.displayName, userDisplayName);
    expect(user?.email, userEmail);
    expect(user?.uid, userUid);
  });

  testWidgets('show custom event info', (WidgetTester tester) async {
    mockNetworkImages(() async {
      await tester.pumpWidget(
        MaterialApp(
            title: 'Explore Page',
            home: ExplorePage(
              userCreds: user,
              userLocation: const LatLng(43.55103829955488, -79.66262838104547),
              mockFirestore: firestore,
              mockGoogleGeocoding: MockGoogleGeocoding(),
            )),
      );

      // wait until loading stops
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('test custom event'), findsOneWidget);
      expect(find.text('Sunday, 28 Nov 2021 10:08 PM EST'), findsOneWidget);
      expect(find.text("Posted by Bob"), findsOneWidget);
      expect(find.text("+ 0 attendees"), findsOneWidget);
    });
  });

  testWidgets('show scraped event info', (WidgetTester tester) async {
    mockNetworkImages(() async {
      await tester.pumpWidget(
        MaterialApp(
            title: 'Explore Page',
            home: ExplorePage(
              userCreds: user,
              userLocation: const LatLng(43.55103829955488, -79.66262838104547),
              mockFirestore: firestore,
              mockGoogleGeocoding: MockGoogleGeocoding(),
            )),
      );

      // wait until loading stops
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('test scraped event'), findsOneWidget);
      expect(find.text('Saturday, 27 Nov 2021 10:08 PM EST'), findsOneWidget);
      expect(find.text("Posted by Dan"), findsOneWidget);
      expect(find.text("+ 90 attendees"), findsOneWidget);
    });
  });
}
