import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:re_trace/data/mock_repositories.dart';
import 'package:app_core/app_core.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';

class BreatheView extends StatefulWidget {
  const BreatheView({super.key});

  @override
  State<BreatheView> createState() => _BreatheViewState();
}

class _BreatheViewState extends State<BreatheView> with TickerProviderStateMixin {
  late BreathingPreset _preset;
  late AnimationController _breath;
  late AnimationController _session;
  late Animation<double> _scale;
  late Animation<double> _glow;
  final int _selectedDuration = 180;
  bool _completed = false;
  
  late AudioPlayer _audioPlayer;
  bool _isMusicMuted = false;

  @override
  void initState() {
    super.initState();
    _preset = MockRepositories.breathingPresets[1];
    _breath = AnimationController(vsync: this);
    _session = AnimationController(vsync: this);
    
    _audioPlayer = AudioPlayer()
      ..setReleaseMode(ReleaseMode.loop)
      ..setVolume(0.20);
      
    _configureAnimations();
    _session.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _breath.stop();
        _audioPlayer.stop();
        setState(() => _completed = true);
      }
    });
    _start();
  }

  Duration get _cycle => Duration(
        seconds: _preset.inhale + _preset.hold + _preset.exhale + _preset.rest,
      );

  void _configureAnimations() {
    _breath.duration = _cycle;
    final total = _cycle.inMilliseconds.toDouble();
    final inhaleEnd = _preset.inhale * 1000 / total;
    final holdEnd = (_preset.inhale + _preset.hold) * 1000 / total;
    final exhaleEnd = (_preset.inhale + _preset.hold + _preset.exhale) * 1000 / total;

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.82, end: 1.22).chain(CurveTween(curve: Curves.easeInOut)),
        weight: inhaleEnd,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.22, end: 1.18).chain(CurveTween(curve: Curves.easeOut)),
        weight: (holdEnd - inhaleEnd).clamp(0.01, 1),
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.18, end: 0.82).chain(CurveTween(curve: Curves.easeInOut)),
        weight: (exhaleEnd - holdEnd).clamp(0.01, 1),
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.82),
        weight: (1 - exhaleEnd).clamp(0.01, 1),
      ),
    ]).animate(_breath);

    _glow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.35, end: 0.7), weight: inhaleEnd),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.62), weight: (holdEnd - inhaleEnd).clamp(0.01, 1)),
      TweenSequenceItem(tween: Tween(begin: 0.62, end: 0.28), weight: (exhaleEnd - holdEnd).clamp(0.01, 1)),
      TweenSequenceItem(tween: ConstantTween(0.28), weight: (1 - exhaleEnd).clamp(0.01, 1)),
    ]).animate(_breath);

    _session.duration = Duration(seconds: _selectedDuration);
  }

  void _start({bool reset = true}) {
    _completed = false;
    if (reset) {
      _session
        ..duration = Duration(seconds: _selectedDuration)
        ..value = 0;
      _breath.value = 0;
    }
    _breath.repeat();
    _session.forward();
    if (!_isMusicMuted) {
      _audioPlayer.play(AssetSource('audio/ambient-pads-loop.mp3'), volume: 0.20);
    }
    setState(() {});
  }

  void _togglePause() {
    if (_completed) return;
    if (_session.isAnimating) {
      _session.stop();
      _breath.stop();
      _audioPlayer.pause();
    } else {
      _breath.repeat();
      _session.forward();
      if (!_isMusicMuted) {
        _audioPlayer.resume();
      }
    }
    setState(() {});
  }

  void _toggleMusic() {
    setState(() => _isMusicMuted = !_isMusicMuted);
    if (_isMusicMuted) {
      _audioPlayer.pause();
    } else if (_session.isAnimating && !_completed) {
      _audioPlayer.resume();
    }
  }

  String _phaseFor(double t) {
    final elapsed = t * _cycle.inMilliseconds;
    final inhale = _preset.inhale * 1000;
    final hold = inhale + _preset.hold * 1000;
    final exhale = hold + _preset.exhale * 1000;
    if (elapsed < inhale) return 'INHALE';
    if (elapsed < hold) return 'HOLD';
    if (elapsed < exhale) return 'EXHALE';
    return 'REST';
  }

  int _phaseCountdown(double t) {
    final elapsed = t * _cycle.inMilliseconds;
    final inhale = _preset.inhale * 1000.0;
    final hold = inhale + _preset.hold * 1000;
    final exhale = hold + _preset.exhale * 1000;
    final total = _cycle.inMilliseconds.toDouble();
    if (elapsed < inhale) return ((inhale - elapsed) / 1000).ceil().clamp(1, _preset.inhale);
    if (elapsed < hold) return ((hold - elapsed) / 1000).ceil().clamp(1, math.max(1, _preset.hold));
    if (elapsed < exhale) return ((exhale - elapsed) / 1000).ceil().clamp(1, _preset.exhale);
    return ((total - elapsed) / 1000).ceil().clamp(1, math.max(1, _preset.rest));
  }

  String _guidance(String phase) {
    return switch (phase) {
      'INHALE' => 'Slowly breathe in',
      'HOLD' => 'Stay here',
      'EXHALE' => 'Slowly breathe out',
      _ => 'Let go',
    };
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _breath.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final reduced = !ReTraceMotion.allowAmbient(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/atmosphere/breathe.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              color: palette.overlay.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.55 : 0.28),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: _completed ? _completion(palette) : _sessionBody(palette, reduced),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionBody(ReTracePalette palette, bool reduced) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            const Spacer(),
            Text('Breathe', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            IconButton(
              onPressed: _toggleMusic,
              icon: Icon(_isMusicMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded),
              color: _isMusicMuted ? palette.textSecondary : palette.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: MockRepositories.breathingPresets.map((preset) {
            final selected = preset.id == _preset.id;
            return ChoiceChip(
              label: Text(preset.name),
              selected: selected,
              onSelected: (_) {
                _breath.stop();
                _session.stop();
                _audioPlayer.stop();
                setState(() => _preset = preset);
                _configureAnimations();
                _start();
              },
            );
          }).toList(),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: Listenable.merge([_breath, _session]),
            builder: (context, _) {
              final phase = _phaseFor(_breath.value);
              final count = _phaseCountdown(_breath.value);
              final remaining = Duration(milliseconds: ((_session.duration?.inMilliseconds ?? 1) * (1 - _session.value)).round());
              final scale = reduced ? 1.0 : _scale.value;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: ReTraceMotion.of(context, ReTraceMotion.short),
                    child: Text(
                      _guidance(phase),
                      key: ValueKey(phase),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: palette.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            palette.accentGlow.withValues(alpha: 0.85),
                            palette.accent.withValues(alpha: _glow.value),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: reduced
                            ? null
                            : [
                                BoxShadow(
                                  color: palette.accentGlow.withValues(alpha: 0.35),
                                  blurRadius: 48,
                                  spreadRadius: 8,
                                ),
                              ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(phase, style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 6),
                            Text(
                              '$count',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    '${remaining.inMinutes.toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _roundButton(
              _session.isAnimating ? Icons.pause_rounded : Icons.play_arrow_rounded,
              _session.isAnimating ? 'Pause' : 'Resume',
              _togglePause,
            ),
            const SizedBox(width: 18),
            _roundButton(Icons.stop_rounded, 'Stop', () {
              _breath.stop();
              _session.stop();
              _audioPlayer.stop();
              setState(() => _completed = true);
            }),
          ],
        ),
      ],
    );
  }

  Widget _roundButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        Pressable(
          onTap: onTap,
          child: CircleAvatar(
            radius: 26,
            backgroundColor: context.palette.surfaceGlass,
            child: Icon(icon, color: context.palette.textPrimary),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _completion(ReTracePalette palette) {
    return Column(
      children: [
        const Spacer(),
        Text('Nice work.', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 34)),
        const SizedBox(height: 10),
        Text(
          'Take a moment before continuing.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: palette.textSecondary),
        ),
        const Spacer(),
        GradientCta(label: 'Done', onPressed: () => Navigator.pop(context)),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _start(),
          child: const Text('Breathe again'),
        ),
      ],
    );
  }
}
