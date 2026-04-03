import 'package:flutter_test/flutter_test.dart';

import 'package:goat/app.dart';

void main() {
  testWidgets('GoatApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const GoatApp());
    // The splash page should be the initial screen.
    expect(find.text('GOAT'), findsOneWidget);
  });
}
