import 'package:flutter/material.dart';
import 'package:re_trace/screens/onboarding_screen.dart';
import 'package:re_trace/screens/shell.dart';
import 'package:re_trace/screens/splash_screen.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/re_trace_theme.dart';

class ReTraceApp extends StatefulWidget {
  const ReTraceApp({super.key});

  @override
  State<ReTraceApp> createState() => _ReTraceAppState();
}

class _ReTraceAppState extends State<ReTraceApp> {
  final AppSessionController _session = AppSessionController();
  bool _showSplash = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _session.addListener(_onSession);
  }

  void _onSession() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _session.removeListener(_onSession);
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSession(
      notifier: _session,
      child: MaterialApp(
        title: 'RE:TRACE',
        debugShowCheckedModeBanner: false,
        theme: ReTraceTheme.build(dark: false),
        darkTheme: ReTraceTheme.build(dark: true),
        themeMode: _session.themeMode,
        home: _showSplash
            ? SplashScreen(
                onFinish: () {
                  if (!mounted) return;
                  setState(() {
                    _showSplash = false;
                    _showOnboarding = true;
                  });
                },
              )
            : _showOnboarding
                ? OnboardingScreen(
                    onGetStarted: () {
                      if (!mounted) return;
                      setState(() => _showOnboarding = false);
                    },
                  )
                : const ReTraceShell(),
      ),
    );
  }
}
