import 'package:flutter_test/flutter_test.dart';
import 'package:re_trace/main.dart';

void main() {
  testWidgets('RE:TRACE app loads with splash and onboarding copy', (tester) async {
    await tester.pumpWidget(const ReTraceApp());

    expect(find.text('RE:TRACE'), findsOneWidget);
    expect(find.text('Understand your recovery. One day at a time.'), findsOneWidget);
  });
}
