import 'package:flutter/material.dart';
import 'package:re_trace/screens/breathe_view.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';

class QuietMomentView extends StatefulWidget {
  const QuietMomentView({super.key});

  @override
  State<QuietMomentView> createState() => _QuietMomentViewState();
}

class _QuietMomentViewState extends State<QuietMomentView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
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
          Image.asset('assets/atmosphere/clouds.png', fit: BoxFit.cover),
          DecoratedBox(decoration: BoxDecoration(color: palette.overlay.withValues(alpha: 0.35))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final scale = reduced ? 1.0 : 0.92 + _controller.value * 0.12;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 168,
                          height: 168,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                palette.accentGlow.withValues(alpha: 0.8),
                                palette.accent.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('A moment for yourself.', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'Nothing to do right now. Just be here for a moment.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: palette.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  GradientCta(
                    label: 'Start breathing',
                    onPressed: () => Navigator.of(context).push(createAppRoute(const BreatheView(), immersive: true)),
                  ),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
