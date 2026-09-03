import 'package:app_core/app_core.dart';

abstract class UserRepository {
  UserProfile get currentUser;
}

abstract class RecoveryRepository {
  RecoverySnapshot get currentRecoveryData;
  List<TrendPoint> get energyTrendData;
  List<TrendPoint> get sleepTrendData;
}

abstract class BaselineRepository {
  RecoverySnapshot get currentRecoveryData;
}

abstract class InsightRepository {
  List<InsightCard> get insightCards;
}

abstract class DailyPlanRepository {
  List<PlanItem> get planItems;
}

abstract class TraceRepository {
  List<TraceMessage> get traceMessages;
}

abstract class RelaxationRepository {
  List<QuoteItem> get quoteItems;
  List<BreathingPreset> get breathingProfiles;
}

abstract class RecoverySummaryRepository {
  RecoverySnapshot get currentRecoveryData;
}

abstract class ReTraceRepository
    implements
        UserRepository,
        RecoveryRepository,
        BaselineRepository,
        InsightRepository,
        DailyPlanRepository,
        TraceRepository,
        RelaxationRepository,
        RecoverySummaryRepository {}

abstract class HealthDataRepository {}
abstract class WhatIfRepository {}
