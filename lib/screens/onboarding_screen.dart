import 'package:flutter/material.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onGetStarted});

  final void Function(String name) onGetStarted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.asset,
  });

  final String title;
  final String body;
  final String asset;
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      title: 'Recovery is personal',
      body: 'Everyone recovers differently. RE:TRACE stays with your recent pattern — not a generic timeline.',
      asset: 'assets/atmosphere/sunset_lake.png',
    ),
    _OnboardingPage(
      title: 'Notice what changes',
      body: 'Small shifts in energy, sleep, and symptoms become a picture you can actually read.',
      asset: 'assets/atmosphere/clouds.png',
    ),
    _OnboardingPage(
      title: 'Plan around your capacity',
      body: 'Structure your day around how you\'re actually feeling — with room to soften when you need it.',
      asset: 'assets/atmosphere/morning.png',
    ),
    _OnboardingPage(
      title: 'Meet TRACE',
      body: 'A calm companion that notices patterns and suggests gentler next steps. It does not diagnose.',
      asset: 'assets/atmosphere/breathe.png',
    ),
    _OnboardingPage(
      title: 'What should we call you?',
      body: 'RE:TRACE is your personal, judgment-free space to pace and recover.',
      asset: 'assets/atmosphere/sunset_lake.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_page < _pages.length - 1) {
      _pageController.nextPage(duration: ReTraceMotion.medium, curve: ReTraceMotion.spatial);
      return;
    }
    widget.onGetStarted(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final current = _pages[_page];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: ReTraceMotion.long,
            child: Image.asset(
              current.asset,
              key: ValueKey(current.asset),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  palette.overlay.withValues(alpha: 0.82),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => widget.onGetStarted(_nameController.text.trim()),
                      child: Text('Skip', style: TextStyle(color: Colors.white.withValues(alpha: 0.86))),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (value) => setState(() => _page = value),
                      itemBuilder: (context, index) {
                        final item = _pages[index];
                        final isNamePage = index == _pages.length - 1;
                        return Align(
                          alignment: Alignment.bottomLeft,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        color: Colors.white,
                                        fontSize: 34,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.body,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.88),
                                        fontSize: 17,
                                      ),
                                ),
                                if (isNamePage) ...[
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: _nameController,
                                    textCapitalization: TextCapitalization.words,
                                    style: const TextStyle(color: Colors.white, fontSize: 18),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your name (e.g. Alex)',
                                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                                      filled: true,
                                      fillColor: Colors.white.withValues(alpha: 0.15),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                                    ),
                                    onSubmitted: (_) => _nextPage(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: List.generate(_pages.length, (index) {
                      final active = index == _page;
                      return AnimatedContainer(
                        duration: ReTraceMotion.short,
                        width: active ? 22 : 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withValues(alpha: active ? 1 : 0.35),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  GradientCta(
                    label: _page == _pages.length - 1 ? 'Begin your journey' : 'Continue',
                    onPressed: _nextPage,
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
