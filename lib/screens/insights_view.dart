import 'package:flutter/material.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppSession.of(context);
    final palette = context.palette;
    final insights = session.insights;

    return AmbientCanvas(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text('Insights', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('Patterns from your recent rhythm — not a diagnosis.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            ...insights.asMap().entries.map((entry) {
              return Stagger(
                index: entry.key,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.value.type.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.accent, letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      Text(entry.value.title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(entry.value.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: palette.textSecondary)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
