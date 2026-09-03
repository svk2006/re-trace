import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';
import 'package:re_trace/widgets/recovery_visuals.dart';

class RecoveryView extends StatefulWidget {
  const RecoveryView({super.key});

  @override
  State<RecoveryView> createState() => _RecoveryViewState();
}

class _RecoveryViewState extends State<RecoveryView> {
  int _range = 0;
  String _dimension = 'Energy';
  int _selected = 4;
  SymptomNode? _focused;

  @override
  Widget build(BuildContext context) {
    final session = AppSession.of(context);
    final palette = context.palette;
    final days = session.rhythmDays;
    final selected = days[_selected.clamp(0, days.length - 1)];
    final nodes = session.symptomNodes;
    final focused = _focused ?? nodes[4];

    return AmbientCanvas(
      asset: 'assets/atmosphere/clouds.png',
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text('Recovery', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('Where you are, and how you got here.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: ['7 Days', '14 Days', '30 Days'].asMap().entries.map((entry) {
                final selectedRange = entry.key == _range;
                return Expanded(
                  child: Pressable(
                    onTap: () => setState(() => _range = entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: EdgeInsets.only(right: entry.key < 2 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedRange ? palette.accent : palette.surfaceInteractive,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          entry.value,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: selectedRange ? palette.onAccent : palette.textPrimary,
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Text(selected.dateLabel.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.1, color: palette.textMuted)),
            const SizedBox(height: 6),
            Text(
              '$_dimension  ${selected.metric(_dimension).round()} / 10',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(selected.note, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: palette.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Energy', 'Mood', 'Fatigue', 'Stress'].map((dim) {
                final on = dim == _dimension;
                return ChoiceChip(
                  label: Text(dim),
                  selected: on,
                  onSelected: (_) => setState(() => _dimension = dim),
                );
              }).toList(),
            ),
            RhythmGraph(
              days: days,
              dimension: _dimension,
              selectedIndex: _selected,
              onSelected: (index) => setState(() => _selected = index),
            ),
            if (selected.events.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: selected.events.map((event) {
                  return Chip(
                    label: Text(event.title),
                    color: WidgetStatePropertyAll(palette.surfaceInteractive),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            Text('Symptom landscape', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SymptomLandscape(
              nodes: nodes,
              selected: focused,
              onSelected: (node) => setState(() => _focused = node),
            ),
            const SizedBox(height: 24),
            Text('Recovery journey', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _journey(context, 'Day 1', 'Higher symptoms'),
            _journey(context, 'Day 3', 'Sleep improving'),
            _journey(context, 'Day 7', 'Energy rising'),
            _journey(context, 'Today', session.checkIn == null ? 'Closer to baseline' : 'Updated by today\'s check-in'),
            const SizedBox(height: 24),
            Text('Your baseline', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _base(context, 'Typical sleep', '7h 15m'),
            _base(context, 'Typical energy', '7/10'),
            _base(context, 'Typical activity', '6,200 steps'),
          ],
        ),
      ),
    );
  }

  Widget _journey(BuildContext context, String title, String detail) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: 12),
          Expanded(child: Text(detail, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _base(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
