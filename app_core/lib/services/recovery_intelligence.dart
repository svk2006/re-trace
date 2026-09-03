import 'package:app_core/app_core.dart';

class RecoveryIntelligenceService {
  RecoveryStateModel evaluateRecoveryState({
    double sleepHours = 7.4,
    double energy = 6.0,
    double fatigue = 3.0,
    double cognitiveLoad = 6.0,
    double physicalLoad = 4.0,
  }) {
    final baselineSleep = 7.25;
    final sleepDelta = sleepHours - baselineSleep;
    final energyDelta = energy - 6.0;
    final fatigueDelta = fatigue - 3.0;

    RecoveryStatus status;
    final factors = <String>[];

    if (sleepDelta < -0.75 || fatigueDelta > 2 || cognitiveLoad >= 7) {
      status = RecoveryStatus.recoveryNeeded;
      factors.add('sleep below your usual pattern');
      factors.add('fatigue is elevated');
      if (cognitiveLoad >= 7) {
        factors.add('cognitive load is higher than recent pattern');
      }
    } else if (energyDelta > 1 && sleepDelta > 0.25 && fatigueDelta < 1) {
      status = RecoveryStatus.improving;
      factors.add('sleep is supporting recovery');
      factors.add('energy is moving closer to baseline');
    } else if (sleepDelta.abs() < 0.5 && fatigueDelta.abs() < 1.5 && physicalLoad < 5) {
      status = RecoveryStatus.steady;
      factors.add('sleep is close to baseline');
      factors.add('fatigue remains within a typical range');
    } else if (physicalLoad >= 6 || cognitiveLoad >= 7) {
      status = RecoveryStatus.elevatedLoad;
      factors.add('recent load is elevated');
      factors.add('recovery load is becoming more demanding than normal');
    } else {
      status = RecoveryStatus.variable;
      factors.add('recovery pattern is shifting day to day');
      factors.add('recent demands are uneven');
    }

    final confidence = switch (status) {
      RecoveryStatus.steady => 0.76,
      RecoveryStatus.improving => 0.81,
      RecoveryStatus.elevatedLoad => 0.73,
      RecoveryStatus.recoveryNeeded => 0.82,
      RecoveryStatus.variable => 0.68,
    };

    final summary = switch (status) {
      RecoveryStatus.steady => 'Your recovery is close to your recent baseline.',
      RecoveryStatus.improving => 'Your recovery is trending in a positive direction.',
      RecoveryStatus.elevatedLoad => 'Recent load is above your usual pattern and recovery needs more care.',
      RecoveryStatus.recoveryNeeded => 'Your recent pattern suggests recovery may need a gentler pace.',
      RecoveryStatus.variable => 'Recovery is variable across the last few days.',
    };

    return RecoveryStateModel(
      status: status,
      confidence: confidence,
      summary: summary,
      factors: factors,
    );
  }

  RecoveryLoadModel deriveLoad({
    double cognitiveLoad = 6.0,
    double physicalLoad = 4.0,
    double fatigue = 3.0,
  }) {
    final cognitiveLabel = cognitiveLoad >= 7 ? 'HIGH' : cognitiveLoad >= 4 ? 'MODERATE' : 'LOW';
    final physicalLabel = physicalLoad >= 6 ? 'HIGH' : physicalLoad >= 4 ? 'MODERATE' : 'LOW';
    final recoveryLabel = fatigue >= 6 ? 'LOW' : fatigue >= 4 ? 'MODERATE' : 'GOOD';

    return RecoveryLoadModel(
      cognitiveLoad: cognitiveLabel,
      physicalLoad: physicalLabel,
      recoveryCapacity: recoveryLabel,
    );
  }

  List<PatternInsight> detectPatterns() {
    return const [
      PatternInsight(
        title: 'Fatigue tends to rise after higher-load days',
        description: 'Observed pattern: fatigue appears alongside consecutive demanding days.',
        confidence: PatternConfidence.strongObservedPattern,
      ),
      PatternInsight(
        title: 'Sleep consistency is improving',
        description: 'Your recent sleep is trending closer to your usual pattern.',
        confidence: PatternConfidence.emergingPattern,
      ),
      PatternInsight(
        title: 'Activity is returning toward baseline',
        description: 'Recent activity is moving back toward your usual range.',
        confidence: PatternConfidence.possiblePattern,
      ),
    ];
  }

  TraceContext buildTraceContext() {
    final recoveryState = evaluateRecoveryState();
    final load = deriveLoad();
    final patterns = detectPatterns();

    return TraceContext(
      recoveryState: recoveryState,
      currentCapacity: load.recoveryCapacity,
      recentSymptoms: const ['Fatigue', 'Brain fog'],
      recentBaselineDeviations: const ['Sleep below your recent pattern', 'Cognitive load above usual'],
      recentActivities: const ['Lecture', 'Higher-load study block'],
      detectedPatterns: patterns.map((pattern) => pattern.title).toList(),
      todaysPlan: 'Focus block + recovery break',
    );
  }

  List<TraceAction> recommendedActions() {
    return const [
      TraceAction(
        type: 'adjust_plan',
        label: 'Make afternoon gentler',
        description: 'Reduce cognitive load after a demanding period.',
      ),
      TraceAction(
        type: 'show_pattern',
        label: 'Show why',
        description: 'Review the pattern behind the current load.',
      ),
      TraceAction(
        type: 'keep_plan',
        label: 'Keep my plan',
        description: 'Continue with the current structure.',
      ),
    ];
  }
}
