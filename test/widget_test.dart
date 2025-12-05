import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eliteworks/main.dart';

void main() {
  testWidgets('App starts with HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const EliteWorksApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
