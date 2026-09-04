import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';

class QuietMomentView extends StatefulWidget {
  const QuietMomentView({super.key});

  @override
  State<QuietMomentView> createState() => _QuietMomentViewState();
}

class _QuietMomentViewState extends State<QuietMomentView> {
  int _selectedMinutes = 2;
  bool _isRunning = false;
  int _secondsRemaining = 120;
  Timer? _timer;
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer?.stop();
      await _audioPlayer?.play(AssetSource('audio/alexis_gaming_cam-bell-notification-337658.mp3'));
    } catch (e) {
      try {
        await _audioPlayer?.play(AssetSource('audio/bell_notification.mp3'));
      } catch (err) {
        debugPrint('Audio playback error: $err');
      }
    }
  }

  void _startPause() {
    setState(() {
      _isRunning = true;
      _secondsRemaining = _selectedMinutes * 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _playNotificationSound();
        final session = AppSession.maybeOf(context);
        if (session != null && session.haptics) {
          HapticFeedback.heavyImpact();
        }
        setState(() => _isRunning = false);
      }
    });
  }

  void _cancelPause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    // Full zero-stimulation black screen mode while running
    if (_isRunning) {
      final mins = _secondsRemaining ~/ 60;
      final secs = (_secondsRemaining % 60).toString().padLeft(2, '0');
      return GestureDetector(
        onTap: _cancelPause,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$mins:$secs',
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Eyes closed · Rest your focus\nTap anywhere to exit',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white12, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/atmosphere/clouds.png', fit: BoxFit.cover),
          DecoratedBox(decoration: BoxDecoration(color: palette.overlay.withValues(alpha: 0.6))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const SizedBox(height: 16),
                  Text('Sensory Pause', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Zero-stimulation dark screen pause to relieve eye strain and cognitive overload.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: palette.textSecondary),
                  ),
                  const Spacer(),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.4),
                        border: Border.all(color: palette.border, width: 2),
                      ),
                      child: const Icon(Icons.visibility_off_outlined, size: 48, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Choose pause length',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.textMuted),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [1, 2, 5].map((mins) {
                      final isSelected = _selectedMinutes == mins;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text('$mins min'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedMinutes = mins);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  GradientCta(
                    label: 'Start dark screen pause',
                    onPressed: _startPause,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
