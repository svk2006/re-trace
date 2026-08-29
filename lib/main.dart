import 'dart:async';

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

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Recovery is personal',
      body: 'Everyone recovers differently.',
      accent: ReTraceColors.softGreen,
      icon: Icons.favorite_outline,
    ),
    _OnboardingPageData(
      title: 'Understand your patterns',
      body: 'RE:TRACE brings your daily experiences and available health signals together.',
      accent: ReTraceColors.softBlueAlt,
      icon: Icons.insights_outlined,
    ),
    _OnboardingPageData(
      title: 'Plan around your capacity',
      body: 'Structure your day around how you\'re actually feeling.',
      accent: ReTraceColors.softLavenderAlt,
      icon: Icons.calendar_month_outlined,
    ),
    _OnboardingPageData(
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

class _OnboardingPageData {
  final String title;
  final String body;
  final Color accent;
  final IconData icon;

  const _OnboardingPageData({
    required this.title,
    required this.body,
    required this.accent,
    required this.icon,
  });
}

class ReTraceShell extends StatefulWidget {
  const ReTraceShell({super.key});

  @override
  State<ReTraceShell> createState() => _ReTraceShellState();
}

class _ReTraceShellState extends State<ReTraceShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    RecoveryView(),
    PlanView(),
    InsightsView(),
    TraceView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
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
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final recovery = MockRepositories.currentRecovery;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
            const SizedBox(height: 22),
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
            Row(
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
                    label: 'Key indicators',
                    value: 'Sleep',
                    subtitle: recovery.sleep,
                    accent: ReTraceColors.softGreen,
                  ),
                ),
              ],
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
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
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
          Text(
            '“${quote.text}”',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
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
      appBar: AppBar(
        title: const Text('Reset'),
      ),
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
                title: 'Fidget',
                subtitle: 'A tactile, low-pressure sensory break.',
                icon: Icons.touch_app_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FidgetView()),
                ),
              ),
              const SizedBox(height: 14),
              _ResetOptionCard(
                title: 'Quiet moment',
                subtitle: 'Just a pause without effort.',
                icon: Icons.spa_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('A quiet moment is available whenever you need it.'),
                    ),
                  );
                },
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
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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
  int _elapsed = 0;
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
    _startTimer();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _orbController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRunning || _completed) {
        return;
      }

      setState(() {
        _elapsed += 1;
        if (_elapsed >= _selectedDuration) {
          _completed = true;
          _isRunning = false;
          _sessionTimer?.cancel();
        }
      });
    });
  }

  void _togglePause() {
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  String get _phaseLabel {
    final total =
        _selectedPreset.inhale + _selectedPreset.hold + _selectedPreset.exhale + _selectedPreset.rest;
    final cycle = _elapsed % total;

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
    final cycle = _elapsed % total;

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
    final remaining = _selectedDuration - _elapsed;
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_elapsed / _selectedDuration).clamp(0.0, 1.0);

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
                      setState(() {
                        _selectedPreset = preset;
                        _elapsed = 0;
                        _completed = false;
                        _isRunning = true;
                      });
                      _startTimer();
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
                      setState(() {
                        _selectedDuration = seconds;
                        _elapsed = 0;
                        _completed = false;
                        _isRunning = true;
                      });
                      _startTimer();
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
                                      onPressed: () {
                                        setState(() {
                                          _elapsed = 0;
                                          _completed = false;
                                          _isRunning = true;
                                        });
                                        _startTimer();
                                      },
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
                                        setState(() {
                                          _elapsed = _selectedDuration;
                                          _completed = true;
                                          _isRunning = false;
                                        });
                                        _sessionTimer?.cancel();
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

class FidgetView extends StatefulWidget {
  const FidgetView({super.key});

  @override
  State<FidgetView> createState() => _FidgetViewState();
}

class _FidgetViewState extends State<FidgetView> {
  double _sliderValue = 0.4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReTraceColors.background,
      appBar: AppBar(title: const Text('Fidget')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A small sensory reset.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ReTraceColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: ReTraceColors.border),
                ),
                child: Column(
                  children: [
                    Text('Soft slider', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Slider(
                      value: _sliderValue,
                      onChanged: (value) => setState(() => _sliderValue = value),
                      activeColor: ReTraceColors.primarySage,
                    ),
                    const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      width: 110 + (_sliderValue * 120),
                      height: 54,
                      decoration: BoxDecoration(
                        color: ReTraceColors.softGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: ReTraceColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: ReTraceColors.border),
                  ),
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.9, end: 1.4),
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  ReTraceColors.primarySage.withValues(alpha: 0.8),
                                  ReTraceColors.softLavender.withValues(alpha: 0.5),
                                  Colors.white,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

class RecoveryView extends StatelessWidget {
  const RecoveryView({super.key});

  @override
  Widget build(BuildContext context) {
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
  const PlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your day', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 18),
            ...(MockRepositories.todaysPlan.map<Widget>((item) => _PlanRow(item: item)).toList()),
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

  const _PlanRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ReTraceColors.surface,
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
          Checkbox(value: item.complete, onChanged: (_) {}),
        ],
      ),
    );
  }
}

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

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
              return Container(
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
  const TraceView({super.key});

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
                children: MockRepositories.traceHistory.map((message) {
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
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _PromptChip('Why am I tired today?'),
                _PromptChip('What changed?'),
                _PromptChip('Plan my day.'),
              ],
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
