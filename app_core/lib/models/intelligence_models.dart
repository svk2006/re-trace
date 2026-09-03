enum RecoveryStatus {
  steady,
  improving,
  elevatedLoad,
  recoveryNeeded,
  variable,
}

enum PatternConfidence {
  strongObservedPattern,
  emergingPattern,
  possiblePattern,
  insufficientData,
}

class RecoveryStateModel {
  final RecoveryStatus status;
  final double confidence;
  final String summary;
  final List<String> factors;

  const RecoveryStateModel({
    required this.status,
    required this.confidence,
    required this.summary,
    required this.factors,
  });
}

class RecoveryLoadModel {
  final String cognitiveLoad;
  final String physicalLoad;
  final String recoveryCapacity;

  const RecoveryLoadModel({
    required this.cognitiveLoad,
    required this.physicalLoad,
    required this.recoveryCapacity,
  });
}

class PatternInsight {
  final String title;
  final String description;
  final PatternConfidence confidence;

  const PatternInsight({
    required this.title,
    required this.description,
    required this.confidence,
  });
}

class TraceContext {
  final RecoveryStateModel recoveryState;
  final String currentCapacity;
  final List<String> recentSymptoms;
  final List<String> recentBaselineDeviations;
  final List<String> recentActivities;
  final List<String> detectedPatterns;
  final String todaysPlan;

  const TraceContext({
    required this.recoveryState,
    required this.currentCapacity,
    required this.recentSymptoms,
    required this.recentBaselineDeviations,
    required this.recentActivities,
    required this.detectedPatterns,
    required this.todaysPlan,
  });
}

class TraceAction {
  final String type;
  final String label;
  final String description;

  const TraceAction({
    required this.type,
    required this.label,
    required this.description,
  });
}
