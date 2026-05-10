import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_read/app/app_theme.dart';

void main() {
  testWidgets('Mini Read theme smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Text('Mini Read')),
      ),
    );

    expect(find.text('Mini Read'), findsOneWidget);
  });
}
