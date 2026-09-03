import 'package:flutter/material.dart';
import 'package:re_trace/data/mock_repositories.dart';
import 'package:app_core/app_core.dart';
import 'package:re_trace/screens/reset_view.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';
import 'package:re_trace/widgets/recovery_visuals.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.onOpenCheckIn,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenCheckIn;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final session = AppSession.of(context);
    final palette = context.palette;
    final recovery = MockRepositories.currentRecovery;
    final state = session.recoveryState;
    final load = session.load;
    final checkIn = session.checkIn;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final capacityPercent = load.recoveryCapacity == 'GOOD'
        ? 0.78
        : load.recoveryCapacity == 'MODERATE'
            ? 0.62
            : 0.38;

    return AmbientCanvas(
      asset: 'assets/atmosphere/morning.png',
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$greeting, ${MockRepositories.user.name}.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                IconButton(onPressed: onOpenSettings, icon: const Icon(Icons.settings_outlined)),
              ],
            ),
            Text(
              'Here\'s your recovery snapshot.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: 18),
            Stagger(
              index: 0,
              child: checkIn == null
                  ? Pressable(
                      onTap: onOpenCheckIn,
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          image: const DecorationImage(
                            image: AssetImage('assets/atmosphere/sunset_lake.png'),
                            fit: BoxFit.cover,
                            opacity: 0.45,
                          ),
                          color: palette.surface,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('How are you feeling right now?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text('Check in', style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GlassPanel(
                      tint: palette.surfaceInteractive,
                      child: Text(
                        'Checked in · Energy ${checkIn.energy}/10 · ${checkIn.symptoms.isEmpty ? 'No extra symptoms noted' : checkIn.symptoms.join(' · ')}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
            ),
            const SizedBox(height: 18),
            Stagger(
              index: 1,
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    colors: [
                      palette.accentSoft,
                      palette.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RECOVERY STATE', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.textMuted, letterSpacing: 1.4)),
                    const SizedBox(height: 8),
                    Text(_statusLabel(state.status), style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(state.summary, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: palette.textSecondary)),
                    const SizedBox(height: 16),
                    CustomPaint(
                      painter: _WavePainter(color: palette.accentGlow),
                      child: const SizedBox(height: 54, width: double.infinity),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Stagger(
                    index: 2,
                    child: GlassPanel(
                      child: Column(
                        children: [
                          Text('Today\'s capacity', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.textMuted)),
                          const SizedBox(height: 10),
                          CapacityRing(label: load.recoveryCapacity, percent: capacityPercent),
                          const SizedBox(height: 8),
                          Text(load.recoveryCapacity, style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stagger(
                    index: 3,
                    child: GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Key focus', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.textMuted)),
                          const SizedBox(height: 18),
                          Text('Sleep', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 6),
                          Text(recovery.sleep, style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Text('Steady enough to support the day.', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text('What changed?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _changeLine(context, 'Sleep', '48m less', palette.attention),
            _changeLine(context, 'Cognitive load', checkIn != null && checkIn.mentalLoad >= 6 ? 'Higher than usual' : 'Near usual', palette.attention),
            _changeLine(context, 'Activity', 'Slightly higher', palette.success),
            const SizedBox(height: 22),
            GlassPanel(
              tint: palette.surfaceInteractive,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRACE noticed', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    checkIn != null && checkIn.energy <= 4
                        ? 'Today\'s energy is lower than your recent pattern. A gentler afternoon is already suggested in Plan.'
                        : 'Yesterday was a higher-load day. A gentler afternoon may help.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('If you feel overwhelmed', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('A short reset is enough. You do not have to finish the day as planned.', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 14),
                  GradientCta(
                    label: 'Reset & relax',
                    onPressed: () {
                      Navigator.of(context).push(createAppRoute(const ResetView(), modal: true));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'RE:TRACE does not diagnose concussion and does not medically clear recovery. If symptoms worsen, seek medical advice.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(RecoveryStatus status) {
    return switch (status) {
      RecoveryStatus.steady => 'Steady',
      RecoveryStatus.improving => 'Improving',
      RecoveryStatus.elevatedLoad => 'Elevated load',
      RecoveryStatus.recoveryNeeded => 'Needs space',
      RecoveryStatus.variable => 'Variable',
    };
  }

  Widget _changeLine(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
          Text(value, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height * 0.55);
    path.cubicTo(size.width * 0.25, size.height * 0.1, size.width * 0.45, size.height * 0.9, size.width * 0.7, size.height * 0.45);
    path.cubicTo(size.width * 0.85, size.height * 0.18, size.width * 0.92, size.height * 0.7, size.width, size.height * 0.4);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
