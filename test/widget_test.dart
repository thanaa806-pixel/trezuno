import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trezuno/core/app/app.dart';

void main() {
  testWidgets('Trezuno smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: Trezuno()));

    // Verify that MaterialApp exists.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
