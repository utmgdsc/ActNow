import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:actnow/widgets/event_widget.dart';
import 'mock_network_image.dart';

void main() {
  testWidgets('show event info', (WidgetTester tester) async {
    mockNetworkImages(() async {
      await tester.pumpWidget(MaterialApp(
          title: "search widget",
          home: Scaffold(
              body: Container(
            height: 500,
            width: 300,
            child: MaterialApp(
                title: 'Explore Page',
                home: EventWidget(
                    title: "Test Event",
                    creator: "John",
                    date_time: "Nov 12th, 2021",
                    num_attendees: 10,
                    saved: false)),
          ))));

      // wait until loading stops
      await tester.pump();

      // assert
      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('Nov 12th, 2021'), findsOneWidget);
      expect(find.text("Posted by John"), findsOneWidget);
      expect(find.text("+ 10 attendees"), findsOneWidget);
      expect(
          (tester.firstWidget(find.byType(Icon)) as Icon).color, Colors.black);
    });
  });

  testWidgets('show saving event', (WidgetTester tester) async {
    mockNetworkImages(() async {
      await tester.pumpWidget(MaterialApp(
          title: "search widget",
          home: Scaffold(
              body: Container(
            height: 500,
            width: 300,
            child: MaterialApp(
                title: 'Explore Page',
                home: EventWidget(
                    title: "Test Event",
                    creator: "John",
                    date_time: "Nov 12th, 2021",
                    num_attendees: 10,
                    saved: true)),
          ))));

      // wait until loading stops
      await tester.pump();

      // assert
      expect(
          (tester.firstWidget(find.byType(Icon)) as Icon).color, Colors.red);
    });
  });
}
