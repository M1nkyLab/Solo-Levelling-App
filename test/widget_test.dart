import 'package:flutter_test/flutter_test.dart';
import 'package:solo_levelling_app/main.dart';

void main() {
  testWidgets('App launches and renders Todos title',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title 'Todos' is shown.
    expect(find.text('Todos'), findsOneWidget);
  });
}
