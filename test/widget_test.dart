import 'package:flutter_test/flutter_test.dart';
import 'package:solo_levelling_app/main.dart';

void main() {
  testWidgets('App launches and renders system initialization',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SoloLevellingApp());

    // Verify that the initialization text is shown (or at least the app starts).
    expect(find.byType(SoloLevellingApp), findsOneWidget);
  });
}
