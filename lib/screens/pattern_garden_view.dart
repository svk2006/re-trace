import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';

class PatternGardenView extends StatefulWidget {
  const PatternGardenView({super.key});

  @override
  State<PatternGardenView> createState() => _PatternGardenViewState();
}

class _GardenObject {
  const _GardenObject(this.icon, this.color);
  final IconData icon;
  final Color color;
}

class _PatternGardenViewState extends State<PatternGardenView> {
  static const _objects = [
    _GardenObject(Icons.local_florist_rounded, Color(0xFFB5A7D9)),
    _GardenObject(Icons.eco_rounded, Color(0xFF7FB8B1)),
    _GardenObject(Icons.diamond_rounded, Color(0xFFD4B07A)),
    _GardenObject(Icons.star_rounded, Color(0xFF8FBEA8)),
    _GardenObject(Icons.filter_vintage_rounded, Color(0xFF7CC3D0)),
    _GardenObject(Icons.spa_rounded, Color(0xFFB4A9D8)),
    _GardenObject(Icons.park_rounded, Color(0xFF6F9F86)),
  ];

  List<int> _pattern = [];
  List<int> _selection = [];
  int _level = 1;
  int _activeIndex = -1;
  int _patternStepIndex = 0;
  bool _showingPattern = false;
  bool _sessionComplete = false;
  String _feedback = 'Watch the pattern...';
  Timer? _patternTimer;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _patternTimer?.cancel();
    super.dispose();
  }

  int get _objectCount => math.min(4 + ((_level - 1) ~/ 2), 7);
  int get _patternLength => math.min(3 + (_level - 1), _objectCount);

  void _startRound() {
    if (!mounted) return;
    _patternTimer?.cancel();
    final random = math.Random();
    final pattern = List.generate(_patternLength, (_) => random.nextInt(_objectCount));
    setState(() {
      _pattern = pattern;
      _selection = [];
      _feedback = 'Watch the pattern...';
      _showingPattern = true;
      _activeIndex = -1;
      _patternStepIndex = 0;
    });
    _showNextPatternStep();
  }

  void _showNextPatternStep() {
    if (!mounted) return;
    if (_patternStepIndex >= _pattern.length) {
      setState(() {
        _showingPattern = false;
        _feedback = 'Memorize the sequence';
      });
      return;
    }
    setState(() => _activeIndex = _pattern[_patternStepIndex]);
    _patternTimer = Timer(const Duration(milliseconds: 620), () {
      if (!mounted) return;
      setState(() => _activeIndex = -1);
      _patternStepIndex++;
      _patternTimer = Timer(const Duration(milliseconds: 220), () {
        if (!mounted) return;
        _showNextPatternStep();
      });
    });
  }

  void _handleSelection(int index) {
    if (_showingPattern || _sessionComplete) return;
    AppSession.maybeOf(context)?.tapFeedback();
    setState(() {
      _activeIndex = index;
      _selection = [..._selection, index];
    });
    final expected = _pattern[_selection.length - 1];
    if (index != expected) {
      setState(() {
        _feedback = 'Take your time.';
        _selection = [];
      });
      _patternTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _activeIndex = -1);
        _startRound();
      });
      return;
    }
    if (_selection.length == _pattern.length) {
      if (_level >= 4) {
        setState(() {
          _feedback = 'Nice focus.';
          _sessionComplete = true;
        });
        return;
      }
      setState(() => _feedback = 'You\'re getting it.');
      _patternTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _activeIndex = -1;
          _level++;
        });
        _startRound();
      });
      return;
    }
    setState(() => _feedback = 'Nice focus.');
    _patternTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() => _activeIndex = -1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/atmosphere/garden.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(color: palette.overlay.withValues(alpha: 0.45)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _sessionComplete ? _done(palette) : _play(palette),
            ),
          ),
        ],
      ),
    );
  }

  Widget _play(ReTracePalette palette) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            Expanded(
              child: Text('Pattern Garden', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: ReTraceMotion.of(context, ReTraceMotion.short),
          child: Text(
            _feedback,
            key: ValueKey(_feedback),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(_objectCount, (index) {
            final object = _objects[index];
            final active = _activeIndex == index;
            return Pressable(
              onTap: () => _handleSelection(index),
              child: AnimatedContainer(
                duration: ReTraceMotion.of(context, ReTraceMotion.short),
                width: active ? 86 : 76,
                height: active ? 86 : 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: object.color.withValues(alpha: active ? 0.95 : 0.55),
                  boxShadow: active
                      ? [BoxShadow(color: object.color.withValues(alpha: 0.5), blurRadius: 24)]
                      : null,
                ),
                child: Icon(object.icon, color: Colors.white, size: 32),
              ),
            );
          }),
        ),
        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: _level / 4,
            minHeight: 8,
            backgroundColor: Colors.white24,
            color: palette.accentGlow,
          ),
        ),
        const SizedBox(height: 8),
        Text('Level $_level of 4', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
      ],
    );
  }

  Widget _done(ReTracePalette palette) {
    return Column(
      children: [
        const Spacer(),
        Text('A little more space.', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 30), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Text('Nice work. Take another moment if you\'d like.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
        const Spacer(),
        GradientCta(
          label: 'Play again',
          onPressed: () {
            setState(() {
              _level = 1;
              _sessionComplete = false;
            });
            _startRound();
          },
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done', style: TextStyle(color: Colors.white))),
      ],
    );
  }
}
