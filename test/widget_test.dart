import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_trace/main.dart';
import 'package:re_trace/screens/reset_view.dart';
import 'package:re_trace/services/recovery_intelligence.dart';

void main() {
  testWidgets('RE:TRACE app loads with splash and onboarding copy', (tester) async {
    await tester.pumpWidget(const ReTraceApp());

    expect(find.text('RE:TRACE'), findsOneWidget);
    expect(find.text('Preparing your recovery space...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Recovery is personal'), findsOneWidget);
  });

  testWidgets('Pattern Garden is available from the reset flow', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ResetView()));

    final patternGardenButton = find.text('Pattern Garden');
    await tester.scrollUntilVisible(patternGardenButton, 48, scrollable: find.byType(Scrollable));
    expect(patternGardenButton, findsOneWidget);

    await tester.tap(patternGardenButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Pattern Garden'), findsWidgets);
  });

  test('Recovery intelligence reports a baseline-aware state and detectable pattern', () {
    final service = RecoveryIntelligenceService();
    final state = service.evaluateRecoveryState();
    final patterns = service.detectPatterns();

    expect(state.status.name, isNotEmpty);
    expect(state.factors, isNotEmpty);
    expect(patterns, isNotEmpty);
    expect(patterns.first.confidence, isNotNull);
  });
}
