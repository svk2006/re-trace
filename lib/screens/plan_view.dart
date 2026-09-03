import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';

class PlanView extends StatelessWidget {
  const PlanView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppSession.of(context);
    final palette = context.palette;
    final items = session.planItems;
    final groups = ['Morning', 'Afternoon', 'Evening'];

    return AmbientCanvas(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('Your Day\'s Plan', style: Theme.of(context).textTheme.headlineMedium),
                ),
                IconButton(
                  tooltip: 'Reset to standard plan',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Plan?'),
                        content: const Text('Restore today\'s plan to the recommended baseline schedule?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                          FilledButton(
                            onPressed: () {
                              session.resetDailyPlan();
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Add activity',
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () => _showAddActivityDialog(context, session),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              session.planSoftened
                  ? 'TRACE softened your afternoon to support recovery.'
                  : 'Structure and balance your daily pacing.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset('assets/atmosphere/morning.png', height: 100, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            for (final group in groups) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(group, style: Theme.of(context).textTheme.titleLarge),
                  TextButton.icon(
                    onPressed: () => _showAddActivityDialog(context, session, defaultPeriod: group),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (items.where((item) => item.period == group).isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('No activities planned for $group.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textMuted)),
                )
              else
                ...items.asMap().entries.where((entry) => entry.value.period == group).map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Stagger(
                    index: index,
                    child: _PlanRow(
                      item: item,
                      onToggle: () {
                        final next = List<PlanItem>.from(items);
                        next[index] = item.copyWith(complete: !item.complete);
                        session.updatePlan(next);
                      },
                      onDelete: () => session.removePlanItem(index),
                    ),
                  );
                }),
              const SizedBox(height: 16),
            ],
            const Divider(height: 32),
            Text('Return to learn pacing', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _line(context, 'Reading & Study', 'Moderate · 25 min blocks'),
            _line(context, 'Screen & Lectures', session.planSoftened ? 'Shorter 15m window' : 'Moderate · Blue filter'),
            _line(context, 'Cognitive Rest', 'Mandatory 10m pause'),
            const SizedBox(height: 16),
            Text('Return to physical activity', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Gentle walking → Light movement → Normal routine (consult clinician if symptomatic).', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context, AppSessionController session, {String defaultPeriod = 'Morning'}) {
    final titleController = TextEditingController();
    final timeController = TextEditingController(text: defaultPeriod == 'Morning' ? '10:00 AM' : defaultPeriod == 'Afternoon' ? '2:30 PM' : '7:00 PM');
    String selectedPeriod = defaultPeriod;
    String selectedType = 'Routine';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Daily Activity'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Activity Name',
                        hintText: 'e.g. Screen-free lunch, Gentle walk',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        hintText: 'e.g. 11:30 AM',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPeriod,
                      decoration: const InputDecoration(labelText: 'Time of Day'),
                      items: ['Morning', 'Afternoon', 'Evening'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setState(() => selectedPeriod = v ?? 'Morning'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ['Routine', 'Recovery', 'Rest', 'Focus'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => selectedType = v ?? 'Routine'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      session.addPlanItem(
                        PlanItem(
                          title: titleController.text.trim(),
                          time: timeController.text.trim().isEmpty ? 'Anytime' : timeController.text.trim(),
                          period: selectedPeriod,
                          type: selectedType,
                          complete: false,
                        ),
                      );
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _line(BuildContext context, String title, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
  const _PlanRow({required this.item, required this.onToggle, required this.onDelete});

  final PlanItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Dismissible(
      key: ValueKey('${item.time}_${item.title}_${item.period}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: palette.attention.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Pressable(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: ReTraceMotion.of(context, ReTraceMotion.short),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: palette.surfaceGlass,
            borderRadius: BorderRadius.circular(16),
          ),
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
                            fontSize: 16,
                            decoration: item.complete ? TextDecoration.lineThrough : null,
                            color: item.complete ? palette.textMuted : palette.textPrimary,
                          ),
                    ),
                    Text(item.type, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, color: palette.textSecondary)),
                  ],
                ),
              ),
              Text(item.time, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.textMuted)),
              IconButton(
                icon: Icon(Icons.close, size: 16, color: palette.textMuted),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
