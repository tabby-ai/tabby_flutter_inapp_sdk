// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:tabby_flutter/main.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

void main() {
  testWidgets('MyApp', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    TabbySDK().setup(
      withApiKey: 'pk_test_key', // Put here your Api key
      // environment: Environment.production, // Or use Environment.stage
    );
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('Tabby Flutter SDK demo'), findsOneWidget);
  });
}
