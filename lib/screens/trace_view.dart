import 'dart:async';

import 'package:flutter/material.dart';
import 'package:re_trace/data/mock_repositories.dart';
import 'package:re_trace/models/re_trace_models.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';

class TraceView extends StatefulWidget {
  const TraceView({super.key});

  @override
  State<TraceView> createState() => _TraceViewState();
}

class _TraceViewState extends State<TraceView> {
  final TextEditingController _controller = TextEditingController();
  final List<TraceMessage> _messages = List.of(MockRepositories.traceHistory);
  bool _thinking = false;
  Timer? _thinkTimer;

  @override
  void dispose() {
    _thinkTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    final session = AppSession.of(context);
    session.tapFeedback();
    setState(() {
      _messages.add(TraceMessage(text: text.trim(), fromUser: true));
      _thinking = true;
      _controller.clear();
    });
    _thinkTimer?.cancel();
    _thinkTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final checkIn = session.checkIn;
      final reply = checkIn != null && checkIn.energy <= 4
          ? 'Your check-in showed lower energy. I can keep the afternoon gentler, or we can look at what changed.'
          : 'That tracks with your recent pattern. A gentler afternoon may help, or we can simply keep today as it is.';
      setState(() {
        _thinking = false;
        _messages.add(TraceMessage(text: reply, fromUser: false));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = AppSession.of(context);
    final palette = context.palette;
    return AmbientCanvas(
      asset: 'assets/atmosphere/breathe.png',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  _TracePresence(lowStim: session.quietMode),
                  const SizedBox(width: 10),
                  Text('TRACE', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'A companion for pacing — not a clinician.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    ..._messages.map((message) {
                      return Align(
                        alignment: message.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: const BoxConstraints(maxWidth: 300),
                          decoration: BoxDecoration(
                            color: message.fromUser ? palette.accent : palette.surfaceGlass,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            message.text,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: message.fromUser ? palette.onAccent : palette.textPrimary,
                                ),
                          ),
                        ),
                      );
                    }),
                    if (_thinking)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text('TRACE is sitting with that...', style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GlassPanel(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.checkIn == null
                                  ? 'Your fatigue is a little higher than your recent baseline, and yesterday was a higher-load day.'
                                  : 'Today\'s check-in is now part of this conversation.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 12),
                            GradientCta(
                              label: 'Make afternoon gentler',
                              onPressed: session.applyGentlePlan,
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
                                    onPressed: session.keepPlan,
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
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(label: const Text('Why am I tired today?'), onPressed: () => _send('Why am I tired today?')),
                  ActionChip(label: const Text('What changed?'), onPressed: () => _send('What changed?')),
                  ActionChip(label: const Text('Plan my day.'), onPressed: () => _send('Plan my day.')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: 'Ask TRACE...',
                        filled: true,
                        fillColor: palette.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Pressable(
                    onTap: () => _send(_controller.text),
                    child: CircleAvatar(
                      backgroundColor: palette.accent,
                      child: Icon(Icons.arrow_upward_rounded, color: palette.onAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TracePresence extends StatefulWidget {
  const _TracePresence({required this.lowStim});
  final bool lowStim;

  @override
  State<_TracePresence> createState() => _TracePresenceState();
}

class _TracePresenceState extends State<_TracePresence> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    if (!widget.lowStim) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _TracePresence oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lowStim) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final scale = widget.lowStim ? 1.0 : 0.9 + _controller.value * 0.18;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [palette.accentGlow, palette.accent]),
            ),
          ),
        );
      },
    );
  }
}
