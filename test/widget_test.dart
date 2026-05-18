import 'package:flutter_test/flutter_test.dart';
import 'package:touristique_guid/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TouristiqueApp());
    expect(find.byType(TouristiqueApp), findsOneWidget);
  });
}
