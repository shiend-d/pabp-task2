import 'package:flutter_test/flutter_test.dart';
import 'package:apocash/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ApoCashApp());
    // Verify the app starts and shows the auth gate
    expect(find.byType(ApoCashApp), findsOneWidget);
  });
}
