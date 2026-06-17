import 'package:flutter_test/flutter_test.dart';
import 'package:hrms_bb/main.dart';

void main() {
  testWidgets('DeepOcean smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title logo is displayed.
    expect(find.text('DeepOcean'), findsWidgets);

    // Verify that the Home navigation tab is displayed.
    expect(find.text('Home'), findsOneWidget);

    // Verify that the Check-In and Reports navigation tabs are displayed.
    expect(find.text('Check-In'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });
}
