import 'dart:async';

import 'package:flutter/material.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _breathe;
  Timer? _finishTimer;

  static const _messages = [
    'Preparing your recovery space...',
    'Understanding your recent rhythm...',
    'Setting up today\'s view...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _finishTimer = Timer(const Duration(milliseconds: 2200), widget.onFinish);
  }

  @override
  void dispose() {
    _finishTimer?.cancel();
    _controller.dispose();
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_controller, _breathe]),
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(_controller.value);
          final breathe = 0.96 + (_breathe.value * 0.08);
          final messageIndex = _controller.value < 0.38
              ? 0
              : _controller.value < 0.72
                  ? 1
                  : 2;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/atmosphere/sunset_lake.png', fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      palette.overlay,
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                  child: Column(
                    children: [
                      const Spacer(),
                      Opacity(
                        opacity: t.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, (1 - t) * 16),
                          child: Transform.scale(
                            scale: breathe,
                            child: Column(
                              children: [
                                Icon(Icons.eco_rounded, size: 42, color: Colors.white.withValues(alpha: 0.92)),
                                const SizedBox(height: 16),
                                Text(
                                  'RE:TRACE',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        color: Colors.white,
                                        letterSpacing: 2.4,
                                        fontSize: 34,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Understand. Adapt. Recover.',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.82),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: ReTraceMotion.short,
                        child: Text(
                          _messages[messageIndex],
                          key: ValueKey(messageIndex),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: t,
                          minHeight: 4,
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
