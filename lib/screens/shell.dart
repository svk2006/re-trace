import 'package:flutter/material.dart';
import 'package:re_trace/models/re_trace_models.dart';
import 'package:re_trace/screens/check_in_screen.dart';
import 'package:re_trace/screens/home_view.dart';
import 'package:re_trace/screens/insights_view.dart';
import 'package:re_trace/screens/plan_view.dart';
import 'package:re_trace/screens/recovery_view.dart';
import 'package:re_trace/screens/settings_view.dart';
import 'package:re_trace/screens/trace_view.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';

class ReTraceShell extends StatefulWidget {
  const ReTraceShell({super.key});

  @override
  State<ReTraceShell> createState() => _ReTraceShellState();
}

class _ReTraceShellState extends State<ReTraceShell> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openCheckIn() async {
    final session = AppSession.of(context);
    final result = await Navigator.of(context).push<DailyCheckInResult>(
      createAppRoute<DailyCheckInResult>(const DailyCheckInScreen(), immersive: true),
    );
    if (result != null) {
      session.applyCheckIn(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          HomeView(
            onOpenCheckIn: _openCheckIn,
            onOpenSettings: () {
              Navigator.of(context).push(createAppRoute(const SettingsView(), modal: true));
            },
          ),
          const RecoveryView(),
          const PlanView(),
          const InsightsView(),
          const TraceView(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: 0.94),
          border: Border(top: BorderSide(color: palette.border)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
            _pageController.animateToPage(
              index,
              duration: ReTraceMotion.of(context, ReTraceMotion.medium),
              curve: ReTraceMotion.spatial,
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
      ),
    );
  }
}
