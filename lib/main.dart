import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:re_trace/data/mock_repositories.dart';
import 'package:re_trace/models/re_trace_models.dart';
import 'package:re_trace/theme/re_trace_theme.dart';

void main() {
  runApp(const ReTraceApp());
}

class ReTraceApp extends StatefulWidget {
  const ReTraceApp({super.key});

  @override
  State<ReTraceApp> createState() => _ReTraceAppState();
}

class _ReTraceAppState extends State<ReTraceApp> {
  bool _showSplash = true;
  bool _showOnboarding = false;

  void _finishSplash() {
    setState(() {
      _showSplash = false;
      _showOnboarding = true;
    });
  }

  void _finishOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RE:TRACE',
      debugShowCheckedModeBanner: false,
      theme: ReTraceTheme.build(),
      home: _showSplash
          ? SplashScreen(onFinish: _finishSplash)
          : _showOnboarding
              ? OnboardingScreen(onGetStarted: _finishOnboarding)
              : const ReTraceShell(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _splashTimer = Timer(const Duration(seconds: 2), widget.onFinish);
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
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
            final scale = 0.92 + (_controller.value * 0.12);
            final opacity = 0.7 + (_controller.value * 0.3);
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
                            ReTraceColors.softTeal.withValues(alpha: 0.7),
                            ReTraceColors.softLavender.withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                          stops: const [0.2, 0.52, 1],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ReTraceColors.softTeal.withValues(alpha: 0.2),
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
                    const SizedBox(height: 12),
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

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenData {
  final String title;
  final String body;
  final Color accent;
  final IconData icon;

  const _OnboardingScreenData({
    required this.title,
    required this.body,
    required this.accent,
    required this.icon,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  final List<_OnboardingScreenData> _pages = const [
    _OnboardingScreenData(
      title: 'Recovery is personal',
      body: 'Everyone recovers differently.',
      accent: ReTraceColors.softGreen,
      icon: Icons.favorite_outline,
    ),
    _OnboardingScreenData(
      title: 'Understand your patterns',
      body: 'RE:TRACE brings your daily experiences and available health signals together.',
      accent: ReTraceColors.softBlueAlt,
      icon: Icons.insights_outlined,
    ),
    _OnboardingScreenData(
      title: 'Plan around your capacity',
      body: 'Structure your day around how you\'re actually feeling.',
      accent: ReTraceColors.softLavenderAlt,
      icon: Icons.calendar_month_outlined,
    ),
    _OnboardingScreenData(
      title: 'Meet TRACE',
      body: 'Your calm AI recovery companion.',
      accent: ReTraceColors.warmNeutral,
      icon: Icons.auto_awesome_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_page < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    widget.onGetStarted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReTraceColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onGetStarted,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: item.accent,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  color: ReTraceColors.surface.withValues(alpha: 0.75),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(item.icon, size: 36, color: ReTraceColors.primaryText),
                              ),
                              const SizedBox(height: 24),
                              Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 12),
                              Text(
                                item.body,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: ReTraceColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final isActive = index == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isActive ? 22 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isActive
                          ? ReTraceColors.primarySage
                          : ReTraceColors.primarySage.withValues(alpha: 0.25),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _nextPage,
                  style: FilledButton.styleFrom(
                    backgroundColor: ReTraceColors.primarySage,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    _page == _pages.length - 1 ? 'Get Started' : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReTraceShell extends StatefulWidget {
  const ReTraceShell({super.key});

  @override
  State<ReTraceShell> createState() => _ReTraceShellState();
}

class _ReTraceShellState extends State<ReTraceShell> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  bool _quietMode = false;
  List<PlanItem> _planItems = List.of(MockRepositories.todaysPlan);

  void _toggleQuietMode() {
    setState(() => _quietMode = !_quietMode);
  }

  void _updatePlan(List<PlanItem> nextPlan) {
    setState(() => _planItems = nextPlan);
  }

  void _applyGentlePlan() {
    final updated = _planItems.map((item) {
      if (item.title == 'Focus session') {
        return PlanItem(
          time: item.time,
          title: 'Light work',
          type: 'Recovery',
          complete: false,
        );
      }
      if (item.title == 'Recovery break' || item.title == 'Lunch + rest') {
        return PlanItem(
          time: item.time,
          title: item.title,
          type: item.type,
          complete: true,
        );
      }
      return item;
    }).toList();

    setState(() => _planItems = updated);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          HomeView(
            quietMode: _quietMode,
            onToggleQuietMode: _toggleQuietMode,
          ),
          RecoveryView(quietMode: _quietMode),
          PlanView(
            planItems: _planItems,
            onPlanChanged: _updatePlan,
            quietMode: _quietMode,
          ),
          InsightsView(quietMode: _quietMode),
          TraceView(
            onPlanAdjusted: _applyGentlePlan,
            quietMode: _quietMode,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.trending_up_rounded), label: 'Recovery'),
          NavigationDestination(icon: Icon(Icons.event_note_rounded), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.insights_rounded), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_rounded), label: 'TRACE'),
        ],
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    this.quietMode = false,
    this.onToggleQuietMode,
  });

  final bool quietMode;
  final VoidCallback? onToggleQuietMode;

  @override
  Widget build(BuildContext context) {
    final recovery = MockRepositories.currentRecovery;
    final capacityRow = Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Today\'s capacity',
            value: recovery.capacity,
            subtitle: recovery.capacitySummary,
            accent: ReTraceColors.softBlueAlt,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Sleep rhythm',
            value: recovery.sleep,
            subtitle: 'Steady and supportive',
            accent: ReTraceColors.softGreen,
          ),
        ),
      ],
    );

    final isQuiet = quietMode;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 24, 20, isQuiet ? 12 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning, ${MockRepositories.user.name}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'How are you feeling today?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: ReTraceColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: quietMode,
                  onChanged: (_) => onToggleQuietMode?.call(),
                  activeThumbColor: ReTraceColors.primarySage,
                  activeTrackColor: ReTraceColors.primarySage.withValues(alpha: 0.35),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (quietMode)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ReTraceColors.softGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_off_rounded, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Quiet mode is on: calmer layout, fewer motions, easier reading.',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ReTraceColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: ReTraceColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: ReTraceColors.primarySage,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'RECOVERY STATE',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 0.8,
                          color: ReTraceColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    recovery.state,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recovery.summary,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: ReTraceColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 360) {
                  return Column(
                    children: [
                      capacityRow,
                      const SizedBox(height: 12),
                    ],
                  );
                }
                return capacityRow;
              },
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ReTraceColors.softLavenderAlt,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Something you reported may need medical attention.',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'RE:TRACE does not diagnose concussion and does not medically clear users for work, school, or sport. If symptoms are worsening or severe, please seek medical advice or urgent care.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ReTraceColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: ReTraceColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Key indicators', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _IndicatorChip(label: 'Sleep', value: '7h 24m'),
                      _IndicatorChip(label: 'Energy', value: '6/10'),
                      _IndicatorChip(label: 'Fatigue', value: '3/10'),
                      _IndicatorChip(label: 'Stress', value: '4/10'),
                      _IndicatorChip(label: 'Activity', value: '5,840 steps'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ReTraceColors.softLavenderAlt,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRACE noticed', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Yesterday was a higher-load day. Would you like a gentler afternoon?',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: ReTraceColors.primarySage,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Adjust my day'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: ReTraceColors.primarySage),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Why?'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _QuoteCard(),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ReTraceColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ReTraceColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gentle reminders', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _ReminderChip('Take one slow breath.'),
                      _ReminderChip('Relax your shoulders.'),
                      _ReminderChip('Look away from the screen for a moment.'),
                      _ReminderChip('You do not have to do everything today.'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ResetView()),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: ReTraceColors.primarySage,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Reset & relax'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderChip extends StatelessWidget {
  final String label;

  const _ReminderChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ReTraceColors.softGreen,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: ReTraceColors.primaryText,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: ReTraceColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _IndicatorChip extends StatelessWidget {
  final String label;
  final String value;

  const _IndicatorChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ReTraceColors.softGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: ReTraceColors.secondaryText,
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatefulWidget {
  const _QuoteCard();

  @override
  State<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<_QuoteCard> {
  int _quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _quoteIndex = DateTime.now().millisecondsSinceEpoch % MockRepositories.quotes.length;
  }

  void _rotateQuote() {
    setState(() {
      _quoteIndex = (_quoteIndex + 1) % MockRepositories.quotes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quote = MockRepositories.quotes[_quoteIndex];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ReTraceColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ReTraceColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('A little reminder', style: Theme.of(context).textTheme.titleLarge),
              TextButton(onPressed: _rotateQuote, child: const Text('Another reminder')),
            ],
          ),
          const SizedBox(height: 10),
          Text('“${quote.text}”', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class ResetView extends StatelessWidget {
  const ResetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReTraceColors.background,
      appBar: AppBar(title: const Text('Reset')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a small reset.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'A few gentle moments can help create more space.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: ReTraceColors.secondaryText,
                ),
              ),
              const SizedBox(height: 24),
              _ResetOptionCard(
                title: 'Breathe',
                subtitle: 'A guided reset for your nervous system.',
                icon: Icons.air_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BreatheView()),
                ),
              ),
              const SizedBox(height: 14),
              _ResetOptionCard(
                title: 'Pattern Garden',
                subtitle: 'A gentle memory-and-focus game to settle the mind.',
                icon: Icons.eco_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PatternGardenView()),
                ),
              ),
              const SizedBox(height: 14),
              _ResetOptionCard(
                title: 'Quiet moment',
                subtitle: 'Just a pause without effort.',
                icon: Icons.spa_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuietMomentView()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResetOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ResetOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ReTraceColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ReTraceColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: ReTraceColors.softGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: ReTraceColors.primaryText),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
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

class BreatheView extends StatefulWidget {
  const BreatheView({super.key});

  @override
  State<BreatheView> createState() => _BreatheViewState();
}

class _BreatheViewState extends State<BreatheView>
    with SingleTickerProviderStateMixin {
  final List<BreathingPreset> _presets = MockRepositories.breathingPresets;
  late final AnimationController _orbController;
  Timer? _sessionTimer;
  int _selectedDuration = 180;
  Duration _elapsed = Duration.zero;
  bool _isRunning = true;
  bool _completed = false;
  BreathingPreset _selectedPreset = MockRepositories.breathingPresets.first;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _startSession();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _orbController.dispose();
    super.dispose();
  }

  void _startSession({bool resetElapsed = true}) {
    if (resetElapsed) {
      _elapsed = Duration.zero;
    }
    _completed = false;
    _isRunning = true;
    _phaseTimerTick();
    if (_orbController.isAnimating == false) {
      _orbController.repeat(reverse: true);
    }
  }

  void _phaseTimerTick() {
    _sessionTimer?.cancel();

    _sessionTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || !_isRunning || _completed) {
        return;
      }

      final nextElapsed = _elapsed + const Duration(milliseconds: 100);
      if (nextElapsed >= Duration(seconds: _selectedDuration)) {
        _sessionTimer?.cancel();
        if (!mounted) return;
        setState(() {
          _elapsed = Duration(seconds: _selectedDuration);
          _completed = true;
          _isRunning = false;
        });
        _orbController.stop(canceled: false);
        return;
      }

      if (mounted) {
        setState(() {
          _elapsed = nextElapsed;
        });
      }
    });
  }

  void _togglePause() {
    if (_completed) return;
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _orbController.repeat(reverse: true);
      _phaseTimerTick();
      return;
    }

    _sessionTimer?.cancel();
    _orbController.stop(canceled: false);
  }

  void _resetSession() {
    _sessionTimer?.cancel();
    setState(() {
      _elapsed = Duration.zero;
      _completed = false;
      _isRunning = true;
    });
    _orbController.repeat(reverse: true);
    _phaseTimerTick();
  }

  String get _phaseLabel {
    final total =
        _selectedPreset.inhale + _selectedPreset.hold + _selectedPreset.exhale + _selectedPreset.rest;
    final cycle = (_elapsed.inSeconds % total);

    if (cycle < _selectedPreset.inhale) return 'Inhale';
    if (cycle < _selectedPreset.inhale + _selectedPreset.hold) return 'Hold';
    if (cycle < _selectedPreset.inhale + _selectedPreset.hold + _selectedPreset.exhale) {
      return 'Exhale';
    }
    return 'Rest';
  }

  double get _orbScale {
    final total =
        _selectedPreset.inhale + _selectedPreset.hold + _selectedPreset.exhale + _selectedPreset.rest;
    final cycle = (_elapsed.inSeconds % total);

    if (cycle < _selectedPreset.inhale) {
      final progress = cycle / _selectedPreset.inhale;
      return 0.9 + (progress * 0.45);
    }
    if (cycle < _selectedPreset.inhale + _selectedPreset.hold) {
      return 1.35;
    }
    if (cycle < _selectedPreset.inhale + _selectedPreset.hold + _selectedPreset.exhale) {
      final progress =
          (cycle - (_selectedPreset.inhale + _selectedPreset.hold)) / _selectedPreset.exhale;
      return 1.35 - (progress * 0.45);
    }
    return 0.9;
  }

  String get _timeRemaining {
    final remaining = Duration(seconds: _selectedDuration) - _elapsed;
    final totalSeconds = remaining.inSeconds.clamp(0, Duration.secondsPerDay);
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_elapsed.inSeconds / _selectedDuration).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: ReTraceColors.background,
      appBar: AppBar(title: const Text('Breathe')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Let\'s slow things down together.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Choose a steady rhythm with a gentler pace.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: ReTraceColors.secondaryText,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presets.map((preset) {
                  final selected = preset.id == _selectedPreset.id;
                  return ChoiceChip(
                    label: Text(preset.name),
                    selected: selected,
                    onSelected: (_) {
                      _sessionTimer?.cancel();
                      setState(() {
                        _selectedPreset = preset;
                        _elapsed = Duration.zero;
                        _completed = false;
                        _isRunning = true;
                      });
                      _orbController.repeat(reverse: true);
                      _phaseTimerTick();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [60, 180, 300].map((seconds) {
                  final selected = seconds == _selectedDuration;
                  return ChoiceChip(
                    label: Text('${seconds ~/ 60} min'),
                    selected: selected,
                    onSelected: (_) {
                      _sessionTimer?.cancel();
                      setState(() {
                        _selectedDuration = seconds;
                        _elapsed = Duration.zero;
                        _completed = false;
                        _isRunning = true;
                      });
                      _orbController.repeat(reverse: true);
                      _phaseTimerTick();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 26),
              Expanded(
                child: Center(
                  child: _completed
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: ReTraceColors.surface,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: ReTraceColors.border),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'You made space to breathe.',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Session duration: ${_selectedDuration ~/ 60} minutes',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Done'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _resetSession,
                                      child: const Text('Breathe again'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : AnimatedBuilder(
                          animation: _orbController,
                          builder: (context, _) {
                            final scale = _orbScale + (_orbController.value * 0.08);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 220,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          ReTraceColors.primarySage.withValues(alpha: 0.9),
                                          ReTraceColors.softTeal.withValues(alpha: 0.5),
                                          Colors.white,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ReTraceColors.primarySage.withValues(alpha: 0.25),
                                          blurRadius: 50,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _phaseLabel,
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _timeRemaining,
                                            style: Theme.of(context).textTheme.headlineMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(12),
                                  backgroundColor: ReTraceColors.softGreen,
                                  valueColor: const AlwaysStoppedAnimation(ReTraceColors.primarySage),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: _togglePause,
                                      icon: Icon(
                                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      ),
                                      label: Text(_isRunning ? 'Pause' : 'Resume'),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton(
                                      onPressed: () {
                                        _sessionTimer?.cancel();
                                        _orbController.stop(canceled: false);
                                        setState(() {
                                          _elapsed = Duration(seconds: _selectedDuration);
                                          _completed = true;
                                          _isRunning = false;
                                        });
                                      },
                                      child: const Text('End'),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PatternGardenView extends StatefulWidget {
  const PatternGardenView({super.key});

  @override
  State<PatternGardenView> createState() => _PatternGardenViewState();
}

class _GardenObject {
  final String label;
  final IconData icon;
  final bool isCircle;

  const _GardenObject({required this.label, required this.icon, required this.isCircle});
}

class _PatternGardenViewState extends State<PatternGardenView> {
  final List<_GardenObject> _gardenObjects = const [
    _GardenObject(label: 'A', icon: Icons.circle, isCircle: true),
    _GardenObject(label: 'B', icon: Icons.forest_rounded, isCircle: false),
    _GardenObject(label: 'C', icon: Icons.spa_rounded, isCircle: true),
    _GardenObject(label: 'D', icon: Icons.park_rounded, isCircle: false),
    _GardenObject(label: 'E', icon: Icons.brightness_1_rounded, isCircle: true),
    _GardenObject(label: 'F', icon: Icons.filter_vintage_rounded, isCircle: false),
    _GardenObject(label: 'G', icon: Icons.eco_rounded, isCircle: true),
  ];

  List<int> _pattern = [];
  List<int> _selection = [];
  int _level = 1;
  int _activeIndex = -1;
  int _patternStepIndex = 0;
  bool _showingPattern = false;
  bool _sessionComplete = false;
  String _feedback = 'Find your rhythm.';
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
  int get _patternLength => math.min(3 + ((_level - 1)), _objectCount);

  void _startRound() {
    if (!mounted) return;
    _patternTimer?.cancel();

    final random = math.Random();
    final pattern = <int>[];
    for (var i = 0; i < _patternLength; i++) {
      pattern.add(random.nextInt(_objectCount));
    }

    setState(() {
      _pattern = pattern;
      _selection = [];
      _feedback = 'Observe';
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
        _feedback = 'Your turn';
      });
      return;
    }

    final index = _pattern[_patternStepIndex];
    setState(() => _activeIndex = index);

    _patternTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _activeIndex = -1);

      _patternStepIndex++;
      if (_patternStepIndex >= _pattern.length) {
        if (!mounted) return;
        setState(() {
          _showingPattern = false;
          _feedback = 'Your turn';
        });
        return;
      }

      _patternTimer = Timer(const Duration(milliseconds: 180), () {
        if (!mounted) return;
        _showNextPatternStep();
      });
    });
  }

  void _handleSelection(int index) {
    if (_showingPattern || _sessionComplete) return;

    setState(() {
      _activeIndex = index;
      _selection = [..._selection, index];
    });

    final expected = _pattern[_selection.length - 1];
    if (index != expected) {
      setState(() {
        _feedback = 'That\'s okay. Take another look.';
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
          _feedback = 'Pattern complete.';
          _sessionComplete = true;
        });
        return;
      }

      setState(() {
        _feedback = 'Beautiful. Keep going.';
      });
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

    setState(() {
      _feedback = 'Nice. Your attention is here.';
    });
    _patternTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() => _activeIndex = -1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = List.generate(_objectCount, (index) {
      final object = _gardenObjects[index];
      final isSelected = _selection.contains(index);
      final isActive = _activeIndex == index;

      return GestureDetector(
        onTap: () => _handleSelection(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: object.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: object.isCircle ? null : BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive || isSelected
                  ? [
                      ReTraceColors.primarySage,
                      ReTraceColors.softTeal,
                    ]
                  : [
                      ReTraceColors.surface,
                      ReTraceColors.softGreen,
                    ],
            ),
            border: Border.all(
              color: isActive || isSelected
                  ? ReTraceColors.primarySage
                  : ReTraceColors.border,
              width: isActive || isSelected ? 2.5 : 1,
            ),
            boxShadow: isActive || isSelected
                ? [
                    BoxShadow(
                      color: ReTraceColors.primarySage.withValues(alpha: 0.18),
                      blurRadius: 18,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(object.icon, color: ReTraceColors.primaryText, size: 22),
              const SizedBox(height: 4),
              Text(
                object.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      );
    });

    return Scaffold(
      backgroundColor: ReTraceColors.background,
      appBar: AppBar(title: const Text('Pattern Garden')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _sessionComplete
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ReTraceColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: ReTraceColors.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'A little more space.',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nice work. Take another moment if you\'d like.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  setState(() {
                                    _level = 1;
                                    _sessionComplete = false;
                                    _selection = [];
                                  });
                                  _startRound();
                                },
                                child: const Text('Play again'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Done'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Finding your rhythm',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _feedback,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ReTraceColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: ReTraceColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: ReTraceColors.border),
                      ),
                      child: Column(
                        children: [
                          Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            alignment: WrapAlignment.center,
                            children: items,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: ReTraceColors.softGreen,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'Level $_level',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class QuietMomentView extends StatelessWidget {
  const QuietMomentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReTraceColors.background,
      appBar: AppBar(title: const Text('Quiet moment')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 2),
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ReTraceColors.softTeal.withValues(alpha: 0.8),
                        ReTraceColors.softLavender.withValues(alpha: 0.4),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'A moment for yourself.',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nothing to do right now. Just be here for a moment.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: ReTraceColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const BreatheView()),
                        ),
                        child: const Text('Start breathing'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecoveryView extends StatelessWidget {
  const RecoveryView({
    super.key,
    this.quietMode = false,
  });

  final bool quietMode;

  @override
  Widget build(BuildContext context) {
    final symptomNodes = [
      _SymptomNode(label: 'Headache', severity: 2, x: 0.20, y: 0.28),
      _SymptomNode(label: 'Fatigue', severity: 6, x: 0.45, y: 0.35),
      _SymptomNode(label: 'Sleep', severity: 4, x: 0.68, y: 0.42),
      _SymptomNode(label: 'Dizziness', severity: 3, x: 0.54, y: 0.68),
      _SymptomNode(label: 'Brain fog', severity: 6, x: 0.34, y: 0.58),
      _SymptomNode(label: 'Stress', severity: 4, x: 0.76, y: 0.63),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recovery', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 18),
            const _SegmentTabs(),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ReTraceColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: ReTraceColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Symptom landscape', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: ReTraceColors.border.withValues(alpha: 0.6)),
                              borderRadius: BorderRadius.circular(24),
                              color: ReTraceColors.softGreen.withValues(alpha: 0.16),
                            ),
                          ),
                        ),
                        ...symptomNodes.map((node) {
                          return Positioned(
                            left: node.x * 260,
                            top: node.y * 170,
                            child: _SymptomNodeChip(
                              label: node.label,
                              severity: node.severity,
                              quietMode: quietMode,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Brain fog — 6 / 10 • ↑ 2 from yesterday • Above your recent baseline',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: ReTraceColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _TrendCard(
              title: 'Energy',
              points: MockRepositories.energyTrend,
              insight: 'Your energy has gradually improved over the last week.',
            ),
            const SizedBox(height: 16),
            _TrendCard(
              title: 'Sleep',
              points: MockRepositories.sleepTrend,
              insight: 'Your sleep has become more consistent over the past week.',
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ReTraceColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ReTraceColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What changed?', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  const _ChangeRow(label: 'Sleep', value: '↓ 48 min from recent average'),
                  const _ChangeRow(label: 'Cognitive load', value: '↑ Higher than usual'),
                  const _ChangeRow(label: 'Headache', value: '→ Similar to yesterday'),
                  const _ChangeRow(label: 'Activity', value: '↑ Slightly higher'),
                  const SizedBox(height: 12),
                  Text(
                    'TRACE noticed: “Your fatigue and cognitive symptoms were both higher after yesterday\'s higher-load day.”',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ReTraceColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ReTraceColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recovery journey', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _JourneyStep('Day 1', 'Higher symptoms'),
                      _JourneyStep('Day 3', 'Sleep improving'),
                      _JourneyStep('Day 7', 'Energy rising'),
                      _JourneyStep('Today', 'Closer to baseline'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text('Your baseline', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ReTraceColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ReTraceColors.border),
              ),
              child: const Column(
                children: [
                  _BaselineRow(label: 'Typical sleep', value: '7h 15m'),
                  _BaselineRow(label: 'Typical resting HR', value: '68 bpm'),
                  _BaselineRow(label: 'Typical activity', value: '6,200 steps'),
                  _BaselineRow(label: 'Typical energy', value: '7/10'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SymptomNode {
  final String label;
  final int severity;
  final double x;
  final double y;

  const _SymptomNode({
    required this.label,
    required this.severity,
    required this.x,
    required this.y,
  });
}

class _SymptomNodeChip extends StatelessWidget {
  final String label;
  final int severity;
  final bool quietMode;

  const _SymptomNodeChip({
    required this.label,
    required this.severity,
    required this.quietMode,
  });

  @override
  Widget build(BuildContext context) {
    final size = (18 + severity * 3).toDouble();
    return AnimatedContainer(
      duration: quietMode ? Duration.zero : const Duration(milliseconds: 260),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ReTraceColors.primarySage,
        boxShadow: [
          BoxShadow(
            color: ReTraceColors.primarySage.withValues(alpha: 0.25),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label.split(' ').first.substring(0, 1),
          style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  final String label;
  final String value;

  const _ChangeRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: Theme.of(context).textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  final String label;
  final String detail;

  const _JourneyStep(this.label, this.detail);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ReTraceColors.softGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SegmentTabs extends StatefulWidget {
  const _SegmentTabs();

  @override
  State<_SegmentTabs> createState() => _SegmentTabsState();
}

class _SegmentTabsState extends State<_SegmentTabs> {
  int selected = 0;
  final tabs = ['7 Days', '14 Days', '30 Days'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = index == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selected = index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: EdgeInsets.only(right: index < tabs.length - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isSelected ? ReTraceColors.primarySage : ReTraceColors.softGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  tabs[index],
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? Colors.white : ReTraceColors.primaryText,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String title;
  final List<TrendPoint> points;
  final String insight;

  const _TrendCard({
    required this.title,
    required this.points,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ReTraceColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ReTraceColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((point) {
                final heightValue = (point.value / maxValue) * 70;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: heightValue.clamp(18, 90),
                          decoration: BoxDecoration(
                            color: ReTraceColors.primarySage,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(point.label, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            insight,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: ReTraceColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _BaselineRow extends StatelessWidget {
  final String label;
  final String value;

  const _BaselineRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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

class PlanView extends StatelessWidget {
  const PlanView({
    super.key,
    this.planItems = const [],
    this.onPlanChanged,
    this.quietMode = false,
  });

  final List<PlanItem> planItems;
  final ValueChanged<List<PlanItem>>? onPlanChanged;
  final bool quietMode;

  @override
  Widget build(BuildContext context) {
    final items = planItems.isEmpty ? MockRepositories.todaysPlan : planItems;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your day', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 18),
            ...items.map<Widget>((item) => _PlanRow(
                  item: item,
                  quietMode: quietMode,
                  onToggle: () {
                    final updates = items.map((entry) {
                      if (entry.title == item.title && entry.time == item.time) {
                        return PlanItem(
                          time: entry.time,
                          title: entry.title,
                          type: entry.type,
                          complete: !entry.complete,
                        );
                      }
                      return entry;
                    }).toList();
                    onPlanChanged?.call(updates);
                  },
                )),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ReTraceColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ReTraceColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Return to learn', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const _LearningTag('Reading', 'Moderate'),
                  const _LearningTag('Lecture', 'Moderate'),
                  const _LearningTag('Assignments', 'High'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ReTraceColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ReTraceColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Return to activity', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const _ActivityStep('Everyday activity'),
                  const _ActivityStep('Light activity'),
                  const _ActivityStep('Moderate activity'),
                  const _ActivityStep('Higher activity • Healthcare-provider guided'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: ReTraceColors.primarySage,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Add activity'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final PlanItem item;
  final bool quietMode;
  final VoidCallback onToggle;

  const _PlanRow({
    required this.item,
    required this.quietMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: quietMode ? Duration.zero : const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.complete ? ReTraceColors.softGreen : ReTraceColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ReTraceColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(item.time, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(item.type, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Checkbox(value: item.complete, onChanged: (_) => onToggle()),
        ],
      ),
    );
  }
}

class _LearningTag extends StatelessWidget {
  final String title;
  final String level;

  const _LearningTag(this.title, this.level);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ReTraceColors.softGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          Text(level, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _ActivityStep extends StatelessWidget {
  final String label;

  const _ActivityStep(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ReTraceColors.softBlueAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class InsightsView extends StatelessWidget {
  const InsightsView({
    super.key,
    this.quietMode = false,
  });

  final bool quietMode;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your insights', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 18),
            ...(MockRepositories.insights.map<Widget>((insight) {
              return AnimatedContainer(
                duration: quietMode ? Duration.zero : const Duration(milliseconds: 220),
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: ReTraceColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: ReTraceColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.type,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: ReTraceColors.primarySage,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(insight.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      insight.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ReTraceColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }
}

class TraceView extends StatefulWidget {
  const TraceView({
    super.key,
    this.onPlanAdjusted,
    this.quietMode = false,
  });

  final VoidCallback? onPlanAdjusted;
  final bool quietMode;

  @override
  State<TraceView> createState() => _TraceViewState();
}

class _TraceViewState extends State<TraceView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promptLabels = [
      'Why am I tired today?',
      'What changed?',
      'Plan my day.',
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: ReTraceColors.primarySage),
                const SizedBox(width: 10),
                Text('TRACE', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                children: [
                  ...MockRepositories.traceHistory.map((message) {
                    final isUser = message.fromUser;
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: const BoxConstraints(maxWidth: 260),
                        decoration: BoxDecoration(
                          color: isUser ? ReTraceColors.primarySage : ReTraceColors.surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          message.text,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isUser ? Colors.white : ReTraceColors.primaryText,
                          ),
                        ),
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: const BoxConstraints(maxWidth: 260),
                      decoration: BoxDecoration(
                        color: ReTraceColors.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your fatigue is a little higher than your recent baseline, and yesterday was a higher-load day.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {
                                    widget.onPlanAdjusted?.call();
                                    setState(() {});
                                  },
                                  child: const Text('Make afternoon gentler'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Why?'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Keep my plan'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: promptLabels.map((label) => _PromptChip(label)).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask TRACE...',
                      filled: true,
                      fillColor: ReTraceColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: ReTraceColors.primarySage,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  final String label;

  const _PromptChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ReTraceColors.softGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
