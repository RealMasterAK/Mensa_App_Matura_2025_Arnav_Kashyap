import 'package:flutter_test/flutter_test.dart';
import 'package:learnskill/main.dart';
import 'package:learnskill/screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  testWidgets('App starts with home screen', (WidgetTester tester) async {
    // Initialize locale data for the test
    await initializeDateFormatting('de_DE', null);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MensaApp());

    // Verify that our app starts with the home screen
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
