import 'package:flutter/material.dart';
import 'package:re_trace/state/app_session.dart';

class ReTraceMotion {
  static const Duration instant = Duration.zero;
  static const Duration micro = Duration(milliseconds: 180);
  static const Duration short = Duration(milliseconds: 280);
  static const Duration medium = Duration(milliseconds: 420);
  static const Duration long = Duration(milliseconds: 640);
  static const Curve spatial = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  static Duration of(BuildContext context, Duration duration) {
    final session = AppSession.maybeOf(context);
    if (session == null) return duration;
    if (session.reducedMotion || session.lowStimulation) {
      return duration > micro ? const Duration(milliseconds: 160) : instant;
    }
    return duration;
  }

  static bool allowAmbient(BuildContext context) {
    final session = AppSession.maybeOf(context);
    return session == null || (!session.reducedMotion && !session.lowStimulation);
  }
}

Route<T> createAppRoute<T>(Widget child, {bool modal = false, bool immersive = false}) {
  return PageRouteBuilder<T>(
    opaque: !immersive,
    barrierColor: immersive ? const Color(0x66000000) : null,
    transitionDuration: const Duration(milliseconds: 480),
    reverseTransitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (_, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, page) {
      final reduced = !ReTraceMotion.allowAmbient(context);
      final curved = CurvedAnimation(parent: animation, curve: ReTraceMotion.spatial);
      if (reduced) {
        return FadeTransition(opacity: curved, child: page);
      }
      final begin = immersive
          ? const Offset(0, 0.04)
          : modal
              ? const Offset(0, 0.08)
              : const Offset(0.06, 0);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: immersive ? 0.97 : 1, end: 1).animate(curved),
            child: page,
          ),
        ),
      );
    },
  );
}
