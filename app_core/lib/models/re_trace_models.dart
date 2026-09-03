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
  final String period;

  const PlanItem({
    required this.time,
    required this.title,
    required this.type,
    required this.complete,
    this.period = 'Day',
  });

  PlanItem copyWith({
    String? time,
    String? title,
    String? type,
    bool? complete,
    String? period,
  }) {
    return PlanItem(
      time: time ?? this.time,
      title: title ?? this.title,
      type: type ?? this.type,
      complete: complete ?? this.complete,
      period: period ?? this.period,
    );
  }
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

class DailyCheckInResult {
  final int mood;
  final int energy;
  final int fatigue;
  final int focus;
  final int mentalLoad;
  final int discomfort;
  final List<String> symptoms;

  const DailyCheckInResult({
    this.mood = 3,
    this.energy = 6,
    this.fatigue = 3,
    this.focus = 5,
    this.mentalLoad = 5,
    this.discomfort = 3,
    this.symptoms = const [],
  });

  factory DailyCheckInResult.fromJson(Map<String, dynamic> json) {
    return DailyCheckInResult(
      mood: json['mood'] as int? ?? 3,
      energy: json['energy'] as int? ?? 6,
      fatigue: json['fatigue'] as int? ?? 3,
      focus: json['focus'] as int? ?? 5,
      mentalLoad: json['mentalLoad'] as int? ?? 5,
      discomfort: json['discomfort'] as int? ?? 3,
      symptoms: (json['symptoms'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'energy': energy,
      'fatigue': fatigue,
      'focus': focus,
      'mentalLoad': mentalLoad,
      'discomfort': discomfort,
      'symptoms': symptoms,
    };
  }
}

class RecoveryEvent {
  final String id;
  final String title;
  final String kind;
  final int dayIndex;

  const RecoveryEvent({
    required this.id,
    required this.title,
    required this.kind,
    required this.dayIndex,
  });
}

class RhythmDay {
  final String label;
  final String dateLabel;
  final double energy;
  final double mood;
  final double fatigue;
  final double stress;
  final List<RecoveryEvent> events;
  final String note;

  const RhythmDay({
    required this.label,
    required this.dateLabel,
    required this.energy,
    required this.mood,
    required this.fatigue,
    required this.stress,
    this.events = const [],
    this.note = '',
  });

  double metric(String dimension) {
    return switch (dimension) {
      'Mood' => mood,
      'Fatigue' => fatigue,
      'Stress' => stress,
      _ => energy,
    };
  }
}

class SymptomNode {
  final String label;
  final int severity;
  final double x;
  final double y;
  final String history;

  const SymptomNode({
    required this.label,
    required this.severity,
    required this.x,
    required this.y,
    required this.history,
  });
}
