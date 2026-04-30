// Shadow Levelling App — widget smoke test
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_levelling_app/main.dart';

void main() {
  testWidgets('App launches and renders dashboard title',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SoloLevellingApp()),
    );
    await tester.pumpAndSettle();
    // The app bar title should be present
    expect(find.text('SHADOW LEVELLING'), findsOneWidget);
  });
}
