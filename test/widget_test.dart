import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile_app/app.dart';

void main() {
  testWidgets('AutoCare App launch smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoCareApp());
    expect(find.text('AutoCare'), findsWidgets);

    // Advance through the splash screen timer into the dashboard
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Your Garage'), findsOneWidget);
  });
}
