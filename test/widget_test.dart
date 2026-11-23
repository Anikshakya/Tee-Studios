import 'package:flutter_test/flutter_test.dart';
import 'package:printdesign/main.dart';

void main() {
  testWidgets('MockupStudioApp loads properly', (WidgetTester tester) async {
    await tester.pumpWidget(const MockupStudioApp());
    expect(find.byType(MockupStudioHomePage), findsOneWidget);
  });
}
