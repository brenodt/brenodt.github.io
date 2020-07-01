import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_app/main.dart';

void main() {
  /// This group of tests require the remainder of the app body to be
  /// sufficiently scrollable to have the SliverAppBar collapsed and reopened.
  group('Tests SliverAppBar behavior', () {
    testWidgets('Tests if SliverAppBar collapses after scrolling.',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      expect(find.byType(SliverAppBar), findsOneWidget);

      final gesture = await tester.startGesture(Offset(0, 300));
      await gesture.moveBy(Offset(0, -300));
      await tester.pump();

      expect(find.byType(SliverAppBar), findsNothing);
    });

    testWidgets(
        'Tests if SliverAppBar reappears after scrolling down and rescrolling up.',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      expect(find.byType(SliverAppBar), findsOneWidget);

      final gesture = await tester.startGesture(Offset(0, 300));
      await gesture.moveBy(Offset(0, -600));
      await tester.pump();

      expect(find.byType(SliverAppBar), findsNothing);

      await gesture.moveBy(Offset(0, 300));
      await tester.pump();

      expect(find.byType(SliverAppBar), findsOneWidget);
    });
  });
}
