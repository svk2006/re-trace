import 'package:flutter_test/flutter_test.dart';
import 'package:re_trace/main.dart';

void main() {
  testWidgets('RE:TRACE app loads with splash and onboarding copy', (tester) async {
    await tester.pumpWidget(const ReTraceApp());

    expect(find.text('RE:TRACE'), findsOneWidget);
    expect(find.text('Understand your recovery. One day at a time.'), findsOneWidget);
  });

  testWidgets('Pattern Garden is available from the reset flow', (tester) async {
    await tester.pumpWidget(const ReTraceApp());

    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    final resetButton = find.text('Reset & relax');
    expect(resetButton, findsOneWidget);
    await tester.ensureVisible(resetButton);
    await tester.tap(resetButton);
    await tester.pumpAndSettle();

    final patternGardenButton = find.text('Pattern Garden');
    expect(patternGardenButton, findsOneWidget);
    await tester.tap(patternGardenButton);
    await tester.pumpAndSettle();

    expect(find.text('Pattern Garden'), findsOneWidget);
  });
}
