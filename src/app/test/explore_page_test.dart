import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../lib/pages/explore_page.dart';

const eventsCollection = 'events';
const customEventsDoc = 'docs';
const scrapedEventsDoc = 'scraped_events';
const userDisplayName = 'test_user';
const userUid = 'test_uid';
const userEmail = 'test@gmail.com';

void main() {
  late final User? user;

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

  setUp(() async {
    await signIn();
  });

  test(
      "setup should have retuned correct user information (displayNamm, email, uid)",
      () {
    expect(user?.displayName, userDisplayName);
    expect(user?.email, userEmail);
    expect(user?.uid, userUid);
  });

  testWidgets('show custom and scraped events', (WidgetTester tester) async {
    // Populate the fake database.
    final firestore = FakeFirebaseFirestore();
    await firestore
        .collection(eventsCollection)
        .doc(customEventsDoc)
        .collection("mississauga")
        .add({
      "createdBy": userUid,
      "createdByName": userDisplayName,
    });

    // Render the widget.
    await tester.pumpWidget(MaterialApp(
      title: 'Explore Page',
      home: ExplorePage(
          userCreds: user,
          userLocation: const LatLng(43.55103829955488, -79.66262838104547)),
    ));
    // Let the snapshots stream fire a snapshot.
    await tester.idle();
    // Re-render.
    await tester.pump();
    // // Verify the output.
    // expect(find.text('Hello world!'), findsOneWidget);
    // expect(find.text('Message 1 of 1'), findsOneWidget);
  });
}
