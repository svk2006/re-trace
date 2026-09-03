import 'package:app_core/app_core.dart';
import 'package:re_trace/repositories/re_trace_repository.dart';

class MockRepositories extends ReTraceRepository {
  static const UserProfile user = UserProfile(
    name: 'Alex',
    recoveryState: 'Steady',
    capacity: 'Moderate',
  );

  static const RecoverySnapshot currentRecovery = RecoverySnapshot(
    state: 'STEADY',
    summary: 'Your recovery is close to your recent baseline.',
    capacity: 'MODERATE',
    capacitySummary: 'Best suited for focused work with regular breaks.',
    sleep: '7h 24m',
    energy: '6/10',
    fatigue: '3/10',
    stress: '4/10',
    activity: '5,840 steps',
  );

  static const List<TrendPoint> energyTrend = [
    TrendPoint(label: 'M', value: 5),
    TrendPoint(label: 'T', value: 6),
    TrendPoint(label: 'W', value: 7),
    TrendPoint(label: 'T', value: 6),
    TrendPoint(label: 'F', value: 7),
    TrendPoint(label: 'S', value: 6),
    TrendPoint(label: 'S', value: 7),
  ];

  static const List<TrendPoint> sleepTrend = [
    TrendPoint(label: 'M', value: 5),
    TrendPoint(label: 'T', value: 6),
    TrendPoint(label: 'W', value: 4),
    TrendPoint(label: 'T', value: 7),
    TrendPoint(label: 'F', value: 6),
    TrendPoint(label: 'S', value: 7),
    TrendPoint(label: 'S', value: 7),
  ];

  static const List<RhythmDay> weekRhythm = [
    RhythmDay(
      label: 'Mon',
      dateLabel: 'Mon · Aug 24',
      energy: 5,
      mood: 5,
      fatigue: 5,
      stress: 5,
      events: [RecoveryEvent(id: 'e1', title: 'High-load day', kind: 'load', dayIndex: 0)],
      note: 'A heavier study day than usual.',
    ),
    RhythmDay(
      label: 'Tue',
      dateLabel: 'Tue · Aug 25',
      energy: 6,
      mood: 6,
      fatigue: 4,
      stress: 4,
      events: [RecoveryEvent(id: 'e2', title: 'Recovery break', kind: 'recovery', dayIndex: 1)],
      note: 'A little more space after yesterday.',
    ),
    RhythmDay(
      label: 'Wed',
      dateLabel: 'Wed · Aug 26',
      energy: 7,
      mood: 6,
      fatigue: 3,
      stress: 4,
      events: [RecoveryEvent(id: 'e3', title: 'Better sleep', kind: 'sleep', dayIndex: 2)],
      note: 'One of your steadier days this week.',
    ),
    RhythmDay(
      label: 'Thu',
      dateLabel: 'Thu · Aug 27',
      energy: 6,
      mood: 5,
      fatigue: 4,
      stress: 5,
      events: [RecoveryEvent(id: 'e4', title: 'Activity increase', kind: 'activity', dayIndex: 3)],
      note: 'Energy held, with a little more movement.',
    ),
    RhythmDay(
      label: 'Fri',
      dateLabel: 'Fri · Aug 28',
      energy: 7,
      mood: 7,
      fatigue: 3,
      stress: 4,
      events: [RecoveryEvent(id: 'e5', title: 'Check-in', kind: 'checkin', dayIndex: 4)],
      note: 'Above your baseline · a clearer day.',
    ),
    RhythmDay(
      label: 'Sat',
      dateLabel: 'Sat · Aug 29',
      energy: 6,
      mood: 6,
      fatigue: 3,
      stress: 3,
      note: 'Quieter weekend rhythm.',
    ),
    RhythmDay(
      label: 'Sun',
      dateLabel: 'Sun · Aug 30',
      energy: 6,
      mood: 6,
      fatigue: 3,
      stress: 4,
      note: 'Close to your recent pattern.',
    ),
  ];

  static const List<InsightCard> insights = [
    InsightCard(
      title: 'Pattern noticed',
      description: 'Your fatigue tends to increase after consecutive high-load days.',
      type: 'Recovery',
    ),
    InsightCard(
      title: 'Positive trend',
      description: 'Your sleep consistency has improved this week.',
      type: 'Sleep',
    ),
    InsightCard(
      title: 'Recovery signal',
      description: 'Your recent activity is moving closer to your usual baseline.',
      type: 'Activity',
    ),
  ];

  static const List<PlanItem> todaysPlan = [
    PlanItem(time: '09:00', title: 'Focus session', type: 'Focus', complete: false, period: 'Morning'),
    PlanItem(time: '10:00', title: 'Recovery break', type: 'Recovery', complete: false, period: 'Morning'),
    PlanItem(time: '10:30', title: 'Lecture', type: 'Routine', complete: false, period: 'Morning'),
    PlanItem(time: '12:00', title: 'Lunch + rest', type: 'Recovery', complete: true, period: 'Afternoon'),
    PlanItem(time: '14:00', title: 'Light work', type: 'Focus', complete: false, period: 'Afternoon'),
    PlanItem(time: '16:00', title: 'Walk', type: 'Physical', complete: false, period: 'Afternoon'),
    PlanItem(time: '20:00', title: 'Wind down', type: 'Recovery', complete: false, period: 'Evening'),
  ];

  static const List<TraceMessage> traceHistory = [
    TraceMessage(text: 'Hi Alex, how is your recovery looking today?', fromUser: false),
    TraceMessage(text: 'I feel a bit tired after a full day.', fromUser: true),
    TraceMessage(text: 'That tracks with your recent pattern. A gentler afternoon may help.', fromUser: false),
  ];

  static const List<QuoteItem> quotes = [
    QuoteItem(text: 'Rest is part of progress.'),
    QuoteItem(text: 'Small steps still move you forward.'),
    QuoteItem(text: 'You do not have to do everything today.'),
    QuoteItem(text: 'Slow is still moving.'),
  ];

  static const List<BreathingPreset> breathingPresets = [
    BreathingPreset(id: 'calm_01', name: 'Calm', inhale: 4, hold: 2, exhale: 6, rest: 2),
    BreathingPreset(id: 'balanced_01', name: 'Box', inhale: 4, hold: 4, exhale: 4, rest: 2),
    BreathingPreset(id: 'gentle_01', name: 'Gentle', inhale: 3, hold: 1, exhale: 5, rest: 2),
  ];

  static const List<SymptomNode> defaultSymptoms = [
    SymptomNode(label: 'Headache', severity: 2, x: 0.22, y: 0.28, history: 'Usually quieter in the morning.'),
    SymptomNode(label: 'Fatigue', severity: 4, x: 0.52, y: 0.22, history: 'Rises after consecutive high-load days.'),
    SymptomNode(label: 'Sleep', severity: 3, x: 0.74, y: 0.38, history: 'Closer to your recent pattern this week.'),
    SymptomNode(label: 'Dizziness', severity: 2, x: 0.36, y: 0.58, history: 'Mild and intermittent.'),
    SymptomNode(label: 'Brain fog', severity: 5, x: 0.58, y: 0.62, history: 'Higher on days with heavier cognitive load.'),
    SymptomNode(label: 'Mood', severity: 3, x: 0.78, y: 0.70, history: 'Steady with small day-to-day shifts.'),
  ];

  @override
  UserProfile get currentUser => user;

  @override
  RecoverySnapshot get currentRecoveryData => currentRecovery;

  @override
  List<TrendPoint> get energyTrendData => energyTrend;

  @override
  List<TrendPoint> get sleepTrendData => sleepTrend;

  @override
  List<InsightCard> get insightCards => insights;

  @override
  List<PlanItem> get planItems => todaysPlan;

  @override
  List<TraceMessage> get traceMessages => traceHistory;

  @override
  List<QuoteItem> get quoteItems => quotes;

  @override
  List<BreathingPreset> get breathingProfiles => breathingPresets;
}
