import 'package:flutter/material.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';

class RecoverySlider extends StatelessWidget {
  const RecoverySlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.lowLabel,
    required this.highLabel,
    required this.captionFor,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String lowLabel;
  final String highLabel;
  final String Function(int) captionFor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final rounded = value.round();
    return Column(
      children: [
        Text(
          '$rounded / 10',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 42),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: ReTraceMotion.of(context, ReTraceMotion.short),
          child: Text(
            captionFor(rounded),
            key: ValueKey(rounded),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: palette.textSecondary),
          ),
        ),
        const SizedBox(height: 18),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: palette.accent,
            inactiveTrackColor: palette.surfaceInteractive,
            thumbColor: palette.accentGlow,
            overlayColor: palette.accent.withValues(alpha: 0.12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13),
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 10,
            onChanged: (next) {
              AppSession.maybeOf(context)?.tapFeedback();
              onChanged(next);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lowLabel, style: Theme.of(context).textTheme.bodyMedium),
              Text(highLabel, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class MoodPicker extends StatelessWidget {
  const MoodPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  static const moods = [
    (1, '😞', 'Low'),
    (2, '😕', 'Not great'),
    (3, '😐', 'Okay'),
    (4, '🙂', 'Good'),
    (5, '😊', 'Really good'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: moods.map((mood) {
            final selected = mood.$1 == value;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  AppSession.maybeOf(context)?.tapFeedback();
                  onChanged(mood.$1);
                },
                child: AnimatedScale(
                  scale: selected ? 1.12 : 0.92,
                  duration: ReTraceMotion.of(context, ReTraceMotion.short),
                  child: AnimatedContainer(
                    duration: ReTraceMotion.of(context, ReTraceMotion.short),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? palette.accentSoft : Colors.transparent,
                      boxShadow: selected && ReTraceMotion.allowAmbient(context)
                          ? [
                              BoxShadow(
                                color: palette.accent.withValues(alpha: 0.28),
                                blurRadius: 16,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(mood.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: ReTraceMotion.of(context, ReTraceMotion.short),
          child: Text(
            moods.firstWhere((m) => m.$1 == value).$3,
            key: ValueKey(value),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}
