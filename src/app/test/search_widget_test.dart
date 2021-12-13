import 'package:actnow/widgets/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockLocalEventDetails {
  final String? title;
  final String? creator;
  final String? date_time;
  final int? num_attendees;
  bool? saved;

  MockLocalEventDetails(
      {this.title,
      this.creator,
      this.date_time,
      this.num_attendees,
      this.saved});
}

late List events = [];
late List filteredEvents = [];
void main() {
  String query = "";

  void setupEvents() {
    events.add(MockLocalEventDetails(
        title: "soccer game",
        num_attendees: 2,
        date_time: "Date",
        creator: "Creator",
        saved: false));

    events.add(MockLocalEventDetails(
        title: "basketball game",
        num_attendees: 2,
        date_time: "Date",
        creator: "Creator",
        saved: false));

    filteredEvents = events;
  }

  void searchEvent(String enteredQuery) {
    final filterEvents = events.where((element) {
      final eventTitle = element.title!.toLowerCase();
      final searchLower = enteredQuery.toLowerCase();

      return eventTitle.contains(searchLower);
    }).toList();

    filteredEvents = filterEvents;
    query = enteredQuery;
  }

  setUp(() async {
    setupEvents();
  });

  testWidgets('show custom event info', (WidgetTester tester) async {
    SearchWidget mySearch = SearchWidget(
      text: query,
      hintText: 'Search events',
      onChanged: searchEvent,
    );
    await tester.pumpWidget(MaterialApp(
        title: "search widget",
        home: Scaffold(
            body: Container(height: 200, width: 200, child: mySearch))));

    //search hint text
    expect(find.text('Search events'), findsOneWidget);

    // tap on search bar
    await tester.ensureVisible(find.byWidget(mySearch));
    await tester.tap(find.byWidget(mySearch));
    await tester.pumpAndSettle();

    // test wrong query
    await tester.enterText(find.byType(TextField), 'football');
    expect(filteredEvents.length, 0);

    //test correct query
    await tester.enterText(find.byType(TextField), 'soccer');
    expect(filteredEvents.length, 1);
    expect(filteredEvents[0].title, "soccer game");

    //test no query
    await tester.enterText(find.byType(TextField), '');
    expect(filteredEvents.length, 2);
    expect(filteredEvents[0].title, "soccer game");
    expect(filteredEvents[1].title, "basketball game");
  });
}
