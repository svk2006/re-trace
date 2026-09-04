import 'package:flutter/material.dart';
import 'package:re_trace/screens/breathe_view.dart';
import 'package:re_trace/screens/pattern_garden_view.dart';
import 'package:re_trace/screens/quiet_moment_view.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';

class ResetView extends StatelessWidget {
  const ResetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientCanvas(
        asset: 'assets/atmosphere/breathe.png',
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  Text('Reset', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
              const SizedBox(height: 8),
              Text('Choose a small reset.', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'A few gentle moments can help create more space.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.palette.textSecondary),
              ),
              const SizedBox(height: 24),
              _option(context, 'Breathe', 'A guided 4-7-8 breathing reset for your nervous system.', Icons.air_rounded, const BreatheView()),
              _option(context, 'Pattern Garden', 'A gentle memory-and-focus game to settle the mind.', Icons.eco_rounded, const PatternGardenView()),
              _option(context, 'Sensory Pause', 'Zero-stimulation dark screen to relieve eye strain.', Icons.visibility_off_outlined, const QuietMomentView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(BuildContext context, String title, String subtitle, IconData icon, Widget page) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Pressable(
        onTap: () => Navigator.of(context).push(createAppRoute(page, immersive: true)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: palette.surfaceInteractive,
              child: Icon(icon, color: palette.textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}
