import 'package:re_trace/models/re_trace_models.dart';
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
    PlanItem(time: '09:00', title: 'Focus session', type: 'Focus', complete: false),
    PlanItem(time: '10:00', title: 'Recovery break', type: 'Recovery', complete: false),
    PlanItem(time: '10:30', title: 'Lecture', type: 'Routine', complete: false),
    PlanItem(time: '12:00', title: 'Lunch + rest', type: 'Recovery', complete: true),
    PlanItem(time: '14:00', title: 'Light work', type: 'Focus', complete: false),
    PlanItem(time: '16:00', title: 'Walk', type: 'Physical', complete: false),
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
    BreathingPreset(id: 'balanced_01', name: 'Balanced', inhale: 4, hold: 4, exhale: 4, rest: 2),
    BreathingPreset(id: 'gentle_01', name: 'Gentle', inhale: 3, hold: 1, exhale: 5, rest: 2),
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
