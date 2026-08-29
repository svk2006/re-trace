import 'package:flutter/material.dart';
import 'package:re_trace/theme/re_trace_theme.dart';

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
    ),
    _OnboardingPageData(
      title: 'Understand your patterns',
      body: 'RE:TRACE brings your daily experiences and available health signals together.',
      accent: ReTraceColors.softBlueAlt,
    ),
    _OnboardingPageData(
      title: 'Plan around your capacity',
      body: 'Structure your day around how you\'re actually feeling.',
      accent: ReTraceColors.softLavenderAlt,
    ),
    _OnboardingPageData(
      title: 'Meet TRACE',
      body: 'Your calm AI recovery companion.',
      accent: ReTraceColors.warmNeutral,
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
    } else {
      widget.onGetStarted();
    }
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
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) {
                    final pageData = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: pageData.accent,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ReTraceColors.surface.withOpacity(0.7),
                                ),
                                child: Icon(
                                  index == 0
                                      ? Icons.favorite_outline
                                      : index == 1
                                          ? Icons.insights_outlined
                                          : index == 2
                                              ? Icons.calendar_month_outlined
                                              : Icons.auto_awesome_outlined,
                                  size: 36,
                                  color: ReTraceColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 26),
                              Text(
                                pageData.title,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                pageData.body,
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
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _page == index ? 22 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _page == index
                          ? ReTraceColors.primarySage
                          : ReTraceColors.primarySage.withOpacity(0.25),
                    ),
                  ),
                ),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  const _OnboardingPageData({
    required this.title,
    required this.body,
    required this.accent,
  });
}
