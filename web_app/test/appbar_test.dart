import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_app/main.dart';

void main() {
  testWidgets('Tests if SliverAppBar collapses after scrolling',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.byType(SliverAppBar), findsOneWidget);

    final gesture = await tester.startGesture(Offset(0, 300));
    await gesture.moveBy(Offset(0, -300));
    await tester.pump();

    expect(find.byType(SliverAppBar), findsNothing);
  });
}
