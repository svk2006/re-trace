import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_trace/data/mock_repositories.dart';
import 'package:app_core/app_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:re_trace/services/notification_service.dart';

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
  AppSessionController(this.prefs) {
    _loadState();
  }

  final SharedPreferences prefs;
  final RecoveryIntelligenceService intelligence = RecoveryIntelligenceService();

  ThemeMode themeMode = ThemeMode.system;
  String _userName = 'Friend';
  bool _reducedMotion = false;
  bool _lowStimulation = false;
  bool _haptics = true;
  bool _checkInReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  DailyCheckInResult? _checkIn;
  List<PlanItem> _planItems = List.of(MockRepositories.todaysPlan);
  bool _planSoftened = false;
  List<TraceMessage> _chatHistory = [];

  String get userName => prefs.getString('userName') ?? _userName;
  bool get reducedMotion => _reducedMotion;
  bool get lowStimulation => _lowStimulation;
  bool get haptics => _haptics;
  bool get checkInReminder => _checkInReminder;
  TimeOfDay get reminderTime => _reminderTime;
  DailyCheckInResult? get checkIn => _checkIn;
  List<PlanItem> get planItems => _planItems;
  bool get planSoftened => _planSoftened;
  bool get quietMode => _lowStimulation || _reducedMotion;
  List<TraceMessage> get chatHistory => _chatHistory;

  bool get hasSeenOnboarding => prefs.getBool('hasSeenOnboarding') ?? false;

  void completeOnboarding() {
    prefs.setBool('hasSeenOnboarding', true);
  }

  void setUserName(String name) {
    _userName = name.trim().isEmpty ? 'Friend' : name.trim();
    prefs.setString('userName', _userName);
    notifyListeners();
  }

  void _loadState() {
    final storedName = prefs.getString('userName');
    if (storedName != null && storedName.isNotEmpty) {
      _userName = storedName;
    }
    final themeIndex = prefs.getInt('themeMode');
    if (themeIndex != null) themeMode = ThemeMode.values[themeIndex];
    _reducedMotion = prefs.getBool('reducedMotion') ?? false;
    _lowStimulation = prefs.getBool('lowStimulation') ?? false;
    _haptics = prefs.getBool('haptics') ?? true;
    _checkInReminder = prefs.getBool('checkInReminder') ?? true;
    final rTime = prefs.getString('reminderTime');
    if (rTime != null) {
      final parts = rTime.split(':');
      if (parts.length == 2) {
        _reminderTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts[1]) ?? 0);
      }
    }
    
    final checkInJson = prefs.getString('latestCheckIn');
    if (checkInJson != null) {
      try {
        _checkIn = DailyCheckInResult.fromJson(jsonDecode(checkInJson));
      } catch (e) {
        // Ignore
      }
    }

    final storedPlan = prefs.getStringList('dailyPlan');
    if (storedPlan != null && storedPlan.isNotEmpty) {
      try {
        _planItems = storedPlan.map((e) => PlanItem.fromJson(jsonDecode(e))).toList();
      } catch (e) {
        // Fallback
      }
    }
    
    final chatJson = prefs.getStringList('chatHistory');
    if (chatJson != null) {
      _chatHistory = chatJson.map((e) {
        final map = jsonDecode(e);
        return TraceMessage(text: map['text'], fromUser: map['fromUser']);
      }).toList();
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  void setReducedMotion(bool value) {
    _reducedMotion = value;
    prefs.setBool('reducedMotion', value);
    notifyListeners();
  }

  void setLowStimulation(bool value) {
    _lowStimulation = value;
    prefs.setBool('lowStimulation', value);
    notifyListeners();
  }

  void setHaptics(bool value) {
    _haptics = value;
    prefs.setBool('haptics', value);
    notifyListeners();
  }

  void setCheckInReminder(bool value) {
    _checkInReminder = value;
    prefs.setBool('checkInReminder', value);
    if (value) {
      NotificationService().scheduleDailyReminder(_reminderTime);
    } else {
      NotificationService().cancelReminders();
    }
    notifyListeners();
  }

  void setReminderTime(TimeOfDay time) {
    _reminderTime = time;
    prefs.setString('reminderTime', '${time.hour}:${time.minute}');
    if (_checkInReminder) {
      NotificationService().scheduleDailyReminder(time);
    }
    notifyListeners();
  }

  void addChatMessage(TraceMessage msg) {
    _chatHistory.add(msg);
    if (_chatHistory.length > 20) _chatHistory.removeAt(0);
    prefs.setStringList('chatHistory', _chatHistory.map((e) => jsonEncode({'text': e.text, 'fromUser': e.fromUser})).toList());
  }

  String getChatTranscriptContext() {
    return _chatHistory.map((m) => "${m.fromUser ? 'User' : 'TRACE'}: ${m.text}").join('\n');
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
    prefs.setString('latestCheckIn', jsonEncode(result.toJson()));
    final needsGentle = result.energy <= 4 || result.fatigue >= 6 || result.symptoms.contains('Headache');
    if (needsGentle) {
      applyGentlePlan();
    }
    notifyListeners();
  }

  void _savePlan() {
    prefs.setStringList('dailyPlan', _planItems.map((e) => jsonEncode(e.toJson())).toList());
  }

  void updatePlan(List<PlanItem> next) {
    _planItems = next;
    _savePlan();
    notifyListeners();
  }

  void addPlanItem(PlanItem item) {
    _planItems.add(item);
    _savePlan();
    notifyListeners();
  }

  void removePlanItem(int index) {
    if (index >= 0 && index < _planItems.length) {
      _planItems.removeAt(index);
      _savePlan();
      notifyListeners();
    }
  }

  void resetDailyPlan() {
    _planItems = List.of(MockRepositories.todaysPlan);
    _planSoftened = false;
    _savePlan();
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
    _savePlan();
    notifyListeners();
  }

  void keepPlan() {
    _planSoftened = false;
    _savePlan();
    notifyListeners();
  }
}
