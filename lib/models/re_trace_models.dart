class RecoverySnapshot {
  final String state;
  final String summary;
  final String capacity;
  final String capacitySummary;
  final String sleep;
  final String energy;
  final String fatigue;
  final String stress;
  final String activity;

  const RecoverySnapshot({
    required this.state,
    required this.summary,
    required this.capacity,
    required this.capacitySummary,
    required this.sleep,
    required this.energy,
    required this.fatigue,
    required this.stress,
    required this.activity,
  });
}

class TrendPoint {
  final String label;
  final double value;

  const TrendPoint({required this.label, required this.value});
}

class InsightCard {
  final String title;
  final String description;
  final String type;

  const InsightCard({required this.title, required this.description, required this.type});
}

class PlanItem {
  final String time;
  final String title;
  final String type;
  final bool complete;

  const PlanItem({
    required this.time,
    required this.title,
    required this.type,
    required this.complete,
  });
}

class TraceMessage {
  final String text;
  final bool fromUser;

  const TraceMessage({required this.text, required this.fromUser});
}

class BreathingPreset {
  final String id;
  final String name;
  final int inhale;
  final int hold;
  final int exhale;
  final int rest;

  const BreathingPreset({
    required this.id,
    required this.name,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.rest,
  });
}

class QuoteItem {
  final String text;

  const QuoteItem({required this.text});
}

class UserProfile {
  final String name;
  final String recoveryState;
  final String capacity;

  const UserProfile({
    required this.name,
    required this.recoveryState,
    required this.capacity,
  });
}
