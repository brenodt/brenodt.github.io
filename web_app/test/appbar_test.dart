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

      final gesture = await tester.startGesture(const Offset(0, 300));
      await gesture.moveBy(const Offset(0, -300));
      await tester.pump();

      expect(find.byType(SliverAppBar), findsNothing);
    });

    testWidgets(
        'Tests if SliverAppBar reappears after scrolling down and rescrolling up.',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      expect(find.byType(SliverAppBar), findsOneWidget);

      final gesture = await tester.startGesture(const Offset(0, 300));
      await gesture.moveBy(const Offset(0, -600));
      await tester.pump();

      expect(find.byType(SliverAppBar), findsNothing);

      await gesture.moveBy(const Offset(0, 300));
      await tester.pump();

      expect(find.byType(SliverAppBar), findsOneWidget);
    });
  });

  group('Tests action buttons of SliverAppBar', () {
    testWidgets('Tests if buttons are visible', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      expect(find.byType(AppbarButton), findsWidgets);
    });

    testWidgets('Tests if home button is active by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      final Finder homeButton = find.byType(AppbarButton).first;

      expect((tester.widget(homeButton) as AppbarButton).active, true);
    });

    testWidgets('Tests if click changes button state',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      final Finder aboutButton = find.byType(AppbarButton).at(1);

      await tester.press(aboutButton);
      await tester.pump();

      expect((tester.widget(aboutButton) as AppbarButton).active, true);
    }, skip: true);
  });
}
