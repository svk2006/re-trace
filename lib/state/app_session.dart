import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_trace/data/mock_repositories.dart';
import 'package:re_trace/models/intelligence_models.dart';
import 'package:re_trace/models/re_trace_models.dart';
import 'package:re_trace/services/recovery_intelligence.dart';

class AppSession extends InheritedNotifier<AppSessionController> {
  const AppSession({
    super.key,
    required AppSessionController super.notifier,
    required super.child,
  });

  static AppSessionController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppSession>();
    assert(scope != null, 'AppSession not found');
    return scope!.notifier!;
  }

  static AppSessionController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppSession>()?.notifier;
  }
}

class AppSessionController extends ChangeNotifier {
  AppSessionController({
    this.themeMode = ThemeMode.system,
  });

  final RecoveryIntelligenceService intelligence = RecoveryIntelligenceService();

  ThemeMode themeMode;
  bool _reducedMotion = false;
  bool _lowStimulation = false;
  bool _haptics = false;
  bool _checkInReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  DailyCheckInResult? _checkIn;
  List<PlanItem> _planItems = List.of(MockRepositories.todaysPlan);
  bool _planSoftened = false;

  bool get reducedMotion => _reducedMotion;
  bool get lowStimulation => _lowStimulation;
  bool get haptics => _haptics;
  bool get checkInReminder => _checkInReminder;
  TimeOfDay get reminderTime => _reminderTime;
  DailyCheckInResult? get checkIn => _checkIn;
  List<PlanItem> get planItems => _planItems;
  bool get planSoftened => _planSoftened;
  bool get quietMode => _lowStimulation || _reducedMotion;

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  void setReducedMotion(bool value) {
    _reducedMotion = value;
    notifyListeners();
  }

  void setLowStimulation(bool value) {
    _lowStimulation = value;
    notifyListeners();
  }

  void setHaptics(bool value) {
    _haptics = value;
    notifyListeners();
  }

  void setCheckInReminder(bool value) {
    _checkInReminder = value;
    notifyListeners();
  }

  void setReminderTime(TimeOfDay time) {
    _reminderTime = time;
    notifyListeners();
  }

  Future<void> tapFeedback() async {
    if (!_haptics) return;
    await HapticFeedback.selectionClick();
  }

  RecoveryStateModel get recoveryState {
    return intelligence.evaluateRecoveryState(
      energy: (_checkIn?.energy ?? 6).toDouble(),
      fatigue: (_checkIn?.fatigue ?? 3).toDouble(),
      cognitiveLoad: (_checkIn?.mentalLoad ?? _checkIn?.focus ?? 5).toDouble(),
    );
  }

  RecoveryLoadModel get load {
    return intelligence.deriveLoad(
      cognitiveLoad: (_checkIn?.mentalLoad ?? 5).toDouble(),
      fatigue: (_checkIn?.fatigue ?? 3).toDouble(),
    );
  }

  List<RhythmDay> get rhythmDays {
    final days = List<RhythmDay>.from(MockRepositories.weekRhythm);
    final checkIn = _checkIn;
    if (checkIn == null) return days;
    final today = days.last;
    days[days.length - 1] = RhythmDay(
      label: today.label,
      dateLabel: today.dateLabel,
      energy: checkIn.energy.toDouble(),
      mood: (checkIn.mood * 2).clamp(1, 10).toDouble(),
      fatigue: checkIn.fatigue.toDouble(),
      stress: checkIn.mentalLoad.toDouble(),
      events: [
        ...today.events,
        RecoveryEvent(id: 'today-checkin', title: 'Check-in', kind: 'checkin', dayIndex: days.length - 1),
      ],
      note: checkIn.energy <= 4
          ? 'Energy is lower than your recent pattern.'
          : 'Today is now part of your recovery picture.',
    );
    return days;
  }

  List<SymptomNode> get symptomNodes {
    final selected = _checkIn?.symptoms ?? const <String>[];
    return MockRepositories.defaultSymptoms.map((node) {
      final isReported = selected.any((s) => s.toLowerCase() == node.label.toLowerCase());
      final extra = isReported ? 3 : 0;
      return SymptomNode(
        label: node.label,
        severity: (node.severity + extra).clamp(1, 10),
        x: node.x,
        y: node.y,
        history: isReported ? 'Reported in today\'s check-in.' : node.history,
      );
    }).toList();
  }

  List<InsightCard> get insights {
    final checkIn = _checkIn;
    if (checkIn == null) return MockRepositories.insights;
    final extra = <InsightCard>[];
    if (checkIn.energy <= 4) {
      extra.add(const InsightCard(
        title: 'Energy is running lower',
        description: 'Today\'s check-in sits below your recent energy pattern. A gentler afternoon may help.',
        type: 'Today',
      ));
    }
    if (checkIn.symptoms.isNotEmpty) {
      extra.add(InsightCard(
        title: 'Symptoms you noticed',
        description: '${checkIn.symptoms.join(', ')} — these now appear in your Symptom Landscape.',
        type: 'Symptoms',
      ));
    }
    return [...extra, ...MockRepositories.insights];
  }

  void applyCheckIn(DailyCheckInResult result) {
    _checkIn = result;
    final needsGentle = result.energy <= 4 || result.fatigue >= 6 || result.symptoms.contains('Headache');
    if (needsGentle) {
      applyGentlePlan();
    }
    notifyListeners();
  }

  void updatePlan(List<PlanItem> next) {
    _planItems = next;
    notifyListeners();
  }

  void applyGentlePlan() {
    _planSoftened = true;
    _planItems = _planItems.map((item) {
      if (item.title == 'Focus session') {
        return item.copyWith(title: 'Light work', type: 'Recovery');
      }
      if (item.title == 'Lecture') {
        return item.copyWith(title: 'Shorter lecture window', type: 'Routine');
      }
      return item;
    }).toList();
    notifyListeners();
  }

  void keepPlan() {
    _planSoftened = false;
    notifyListeners();
  }
}
