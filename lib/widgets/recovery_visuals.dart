import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:re_trace/models/re_trace_models.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';

class RhythmGraph extends StatefulWidget {
  const RhythmGraph({
    super.key,
    required this.days,
    required this.dimension,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<RhythmDay> days;
  final String dimension;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<RhythmGraph> createState() => _RhythmGraphState();
}

class _RhythmGraphState extends State<RhythmGraph> with SingleTickerProviderStateMixin {
  late final AnimationController _draw;

  @override
  void initState() {
    super.initState();
    _draw = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _draw.forward();
  }

  @override
  void didUpdateWidget(covariant RhythmGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dimension != widget.dimension) {
      _draw.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  void _selectFrom(Offset local, Size size) {
    if (widget.days.isEmpty) return;
    final t = (local.dx / size.width).clamp(0.0, 1.0);
    final index = (t * (widget.days.length - 1)).round();
    widget.onSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final reduced = !ReTraceMotion.allowAmbient(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: GestureDetector(
            onTapDown: (d) => _selectFrom(d.localPosition, const Size(400, 220)),
            onHorizontalDragUpdate: (d) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              _selectFrom(d.localPosition, box.size);
            },
            child: AnimatedBuilder(
              animation: _draw,
              builder: (context, _) {
                return CustomPaint(
                  painter: _RhythmPainter(
                    days: widget.days,
                    dimension: widget.dimension,
                    selected: widget.selectedIndex,
                    progress: reduced ? 1 : Curves.easeOutCubic.transform(_draw.value),
                    palette: palette,
                    lineColor: widget.dimension == 'Fatigue' || widget.dimension == 'Stress'
                        ? palette.attention
                        : palette.accentGlow,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap and hold on the chart to explore.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textMuted),
        ),
      ],
    );
  }
}

class _RhythmPainter extends CustomPainter {
  _RhythmPainter({
    required this.days,
    required this.dimension,
    required this.selected,
    required this.progress,
    required this.palette,
    required this.lineColor,
  });

  final List<RhythmDay> days;
  final String dimension;
  final int selected;
  final double progress;
  final ReTracePalette palette;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    final path = Path();
    final points = <Offset>[];
    for (var i = 0; i < days.length; i++) {
      final x = size.width * (i / (days.length - 1));
      final y = size.height - (days[i].metric(dimension) / 10) * (size.height - 28) - 12;
      points.add(Offset(x, y));
    }
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final extract = metrics.first.extractPath(0, metrics.first.length * progress);

    final fill = Path.from(extract)
      ..lineTo(points.last.dx * progress + points.first.dx * (1 - progress), size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lineColor.withValues(alpha: 0.28), lineColor.withValues(alpha: 0.0)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      extract,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < points.length; i++) {
      if (i / (points.length - 1) > progress) continue;
      final selectedPoint = i == selected;
      canvas.drawCircle(
        points[i],
        selectedPoint ? 8 : 4,
        Paint()..color = selectedPoint ? lineColor : palette.surfaceElevated,
      );
      canvas.drawCircle(
        points[i],
        selectedPoint ? 8 : 4,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = selectedPoint ? 3 : 1.5,
      );
      for (final event in days[i].events) {
        final color = switch (event.kind) {
          'load' => palette.attention,
          'sleep' => palette.accentGlow,
          'recovery' => palette.success,
          _ => palette.warning,
        };
        canvas.drawCircle(points[i] + const Offset(0, 16), 3.5, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RhythmPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selected != selected ||
        oldDelegate.dimension != dimension ||
        oldDelegate.days != days;
  }
}

class SymptomLandscape extends StatefulWidget {
  const SymptomLandscape({
    super.key,
    required this.nodes,
    required this.selected,
    required this.onSelected,
  });

  final List<SymptomNode> nodes;
  final SymptomNode? selected;
  final ValueChanged<SymptomNode> onSelected;

  @override
  State<SymptomLandscape> createState() => _SymptomLandscapeState();
}

class _SymptomLandscapeState extends State<SymptomLandscape> with SingleTickerProviderStateMixin {
  late final AnimationController _appear;

  @override
  void initState() {
    super.initState();
    _appear = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _appear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selected = widget.selected ?? widget.nodes.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 260,
          child: AnimatedBuilder(
            animation: _appear,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: RadialGradient(
                              colors: [
                                palette.accent.withValues(alpha: 0.18),
                                palette.backgroundSecondary.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ...widget.nodes.asMap().entries.map((entry) {
                        final i = entry.key;
                        final node = entry.value;
                        final t = Curves.easeOutCubic.transform((_appear.value - i * 0.08).clamp(0.0, 1.0));
                        final focused = node.label == selected.label;
                        final size = 56.0 + node.severity * 4.2;
                        return Positioned(
                          left: node.x * (constraints.maxWidth - size),
                          top: node.y * (constraints.maxHeight - size),
                          child: Opacity(
                            opacity: t,
                            child: Transform.scale(
                              scale: t,
                              child: GestureDetector(
                                onTap: () => widget.onSelected(node),
                                child: AnimatedContainer(
                                  duration: ReTraceMotion.of(context, ReTraceMotion.short),
                                  width: focused ? size + 10 : size,
                                  height: focused ? size + 10 : size,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (focused ? palette.accent : palette.accentGlow)
                                        .withValues(alpha: 0.22 + node.severity / 30),
                                    border: Border.all(
                                      color: focused ? palette.accent : palette.border,
                                      width: focused ? 2 : 1,
                                    ),
                                    boxShadow: focused && ReTraceMotion.allowAmbient(context)
                                        ? [
                                            BoxShadow(
                                              color: palette.accent.withValues(alpha: 0.28),
                                              blurRadius: 22,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        '${node.label}\n${node.severity}/10',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, height: 1.2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${selected.label}: ${selected.severity}/10',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(selected.history, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: palette.textSecondary)),
      ],
    );
  }
}

class CapacityRing extends StatelessWidget {
  const CapacityRing({super.key, required this.label, required this.percent});

  final String label;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percent),
      duration: ReTraceMotion.of(context, const Duration(milliseconds: 900)),
      curve: ReTraceMotion.spatial,
      builder: (context, value, _) {
        return CustomPaint(
          painter: _RingPainter(value: value, color: palette.accentGlow, track: palette.surfaceInteractive),
          child: SizedBox(
            width: 92,
            height: 92,
            child: Center(
              child: Text(
                '${(value * 100).round()}%',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.track});
  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;
    canvas.drawCircle(center, radius, Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.value != value;
}
