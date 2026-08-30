import 'package:flutter/material.dart';
import 'package:re_trace/models/re_trace_models.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';

class PlanView extends StatelessWidget {
  const PlanView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppSession.of(context);
    final items = session.planItems;
    final groups = ['Morning', 'Afternoon', 'Evening'];

    return AmbientCanvas(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text('Your day is gently balanced', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            if (session.planSoftened)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'TRACE softened this afternoon after today\'s signals.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset('assets/atmosphere/morning.png', height: 110, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            for (final group in groups) ...[
              Text(group, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...items.where((item) => item.period == group).toList().asMap().entries.map((entry) {
                return Stagger(
                  index: entry.key,
                  child: _PlanRow(
                    item: entry.value,
                    onToggle: () {
                      final next = items.map((item) {
                        if (item.time == entry.value.time && item.title == entry.value.title) {
                          return item.copyWith(complete: !item.complete);
                        }
                        return item;
                      }).toList();
                      session.updatePlan(next);
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
            Text('Return to learn', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _line(context, 'Reading', 'Moderate'),
            _line(context, 'Lecture', session.planSoftened ? 'Shorter window' : 'Moderate'),
            _line(context, 'Assignments', 'High'),
            const SizedBox(height: 16),
            Text('Return to activity', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Everyday → Light → Moderate → Higher (with a clinician).', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, String title, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyLarge)),
          Text(level, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.item, required this.onToggle});

  final PlanItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Pressable(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: ReTraceMotion.of(context, ReTraceMotion.short),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: ReTraceMotion.of(context, ReTraceMotion.short),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.complete ? palette.success : Colors.transparent,
                border: Border.all(color: item.complete ? palette.success : palette.border, width: 2),
              ),
              child: item.complete ? Icon(Icons.check, size: 16, color: palette.onAccent) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 17,
                          decoration: item.complete ? TextDecoration.lineThrough : null,
                        ),
                  ),
                  Text(item.type, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Text(item.time, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.textMuted)),
          ],
        ),
      ),
    );
  }
}
