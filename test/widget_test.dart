import 'package:flutter_test/flutter_test.dart';
import 'package:public_issue_reporter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PublicReporterApp());
  });
}