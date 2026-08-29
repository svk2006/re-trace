import 'package:flutter/material.dart';
import 'package:re_trace/theme\re_trace_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    Future.delayed(const Duration(seconds: 2), widget.onFinish);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReTraceColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final scale = 0.94 + (_controller.value * 0.08);
            final opacity = 0.68 + (_controller.value * 0.32);
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            ReTraceColors.softTeal.withOpacity(0.65),
                            ReTraceColors.softLavender.withOpacity(0.35),
                            Colors.transparent,
                          ],
                          stops: const [0.2, 0.55, 1],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ReTraceColors.softTeal.withOpacity(0.18),
                            blurRadius: 60,
                            spreadRadius: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'RE:TRACE',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        letterSpacing: 1.2,
                        color: ReTraceColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Understand your recovery. One day at a time.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ReTraceColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
