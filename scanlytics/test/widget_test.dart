import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scanlytics/main.dart';

void main() {
  testWidgets('navigates from splash to role selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ScanlyticApp());

    expect(find.text('INGRESIGHT AI'), findsOneWidget);
    expect(find.text('Federated Healthcare System'), findsOneWidget);
    expect(find.byIcon(Icons.hub), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Select Your Role'), findsOneWidget);
    expect(find.text('I AM PATIENT'), findsOneWidget);
    expect(find.text('I AM DOCTOR'), findsOneWidget);
  });
}
