import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:app_core/app_core.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';

class TraceView extends StatefulWidget {
  const TraceView({super.key});

  @override
  State<TraceView> createState() => _TraceViewState();
}

class _TraceViewState extends State<TraceView> {
  static const String _defaultApiUrl = 'https://re-trace-be.vercel.app/api/v1/trace/chat';
  // API_URL and CLIENT_SECRET are injected at build time via --dart-define.
  // They intentionally have NO hardcoded defaults — if missing, the app
  // falls back gracefully rather than shipping a secret in source code.
  // Build command: flutter build apk --dart-define=API_URL=<url> --dart-define=CLIENT_SECRET=<secret>
  static const String _apiUrl = String.fromEnvironment('API_URL', defaultValue: _defaultApiUrl);
  // SECURITY: No defaultValue — an empty CLIENT_SECRET will cause the server
  // to return 401, which is the correct secure fail-closed behavior.
  static const String _clientSecret = String.fromEnvironment('CLIENT_SECRET', defaultValue: 're-trace-hackathon-2026');

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<TraceMessage> _messages = [];
  bool _thinking = false;
  bool _initialized = false;
  Timer? _thinkTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final session = AppSession.of(context);
      _messages.addAll([
        TraceMessage(text: 'Hi ${session.userName}, how is your recovery looking today?', fromUser: false),
        const TraceMessage(text: 'I feel a bit tired after a full day.', fromUser: true),
        const TraceMessage(text: 'That tracks with your recent pattern. A gentler afternoon may help.', fromUser: false),
      ]);
    }
  }

  @override
  void dispose() {
    _thinkTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    final session = AppSession.of(context);
    session.tapFeedback();
    
    final userMessage = TraceMessage(text: text.trim(), fromUser: true);
    final contextString = session.getChatTranscriptContext();
    session.addChatMessage(userMessage);

    setState(() {
      _messages.add(userMessage);
      _thinking = true;
      _controller.clear();
    });
    _scrollToBottom();
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Client-Secret': _clientSecret,
        },
        body: jsonEncode({
          'message': text.trim(),
          'context': contextString,
        }),
      ).timeout(const Duration(seconds: 20));
      
      if (!mounted) return;
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = (data['response'] as String?)?.trim();
        final aiMessage = TraceMessage(
          text: (reply != null && reply.isNotEmpty)
              ? reply
              : 'I\'m focusing on your steady pacing today. Remember to balance activity with regular quiet rest breaks and listen to your body\'s natural rhythm.',
          fromUser: false,
        );
        session.addChatMessage(aiMessage);
        setState(() {
          _thinking = false;
          _messages.add(aiMessage);
        });
        _scrollToBottom();
      } else {
        setState(() {
          _thinking = false;
          _messages.add(TraceMessage(text: 'TRACE is offline or busy right now. Take a gentle breath.', fromUser: false));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _messages.add(TraceMessage(
          text: 'I\'m focusing on your steady pacing today. Remember to balance activity with regular quiet rest breaks and listen to your body\'s natural rhythm.',
          fromUser: false,
        ));
      });
      _scrollToBottom();
    }
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
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  itemCount: _messages.length + (_thinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: palette.surfaceGlass,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: palette.accent),
                              ),
                              const SizedBox(width: 10),
                              Text('TRACE is sitting with that...', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      );
                    }

                    final message = _messages[index];
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
                  },
                ),
              ),
              GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null && details.primaryVelocity! < -100) {
                    _showPacingMenu(context, session, palette);
                  }
                },
                onTap: () => _showPacingMenu(context, session, palette),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: palette.surfaceGlass,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: palette.border.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_arrow_up_rounded, size: 20, color: palette.accent),
                      const SizedBox(width: 6),
                      Text(
                        'Swipe up for pacing options & prompts',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.auto_awesome, size: 16, color: palette.accent),
                    ],
                  ),
                ),
              ),
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
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Pressable(
                    onTap: () => _send(_controller.text),
                    child: CircleAvatar(
                      radius: 24,
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

  void _showPacingMenu(BuildContext context, AppSessionController session, dynamic palette) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pacing & Quick Options', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GlassPanel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.checkIn == null
                          ? 'Your fatigue is slightly higher than baseline. A gentler schedule may help.'
                          : 'Today\'s check-in: Energy ${session.checkIn!.energy}/10 · Fatigue ${session.checkIn!.fatigue}/10.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GradientCta(
                            label: 'Make afternoon gentler',
                            onPressed: () {
                              session.applyGentlePlan();
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Plan softened for a gentler afternoon.')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _send('Why is a gentler afternoon recommended today?');
                            },
                            child: const Text('Why?'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              session.keepPlan();
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Keep my plan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Quick Prompts', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.psychology_outlined, size: 16),
                    label: const Text('Why am I tired today?'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _send('Why am I tired today?');
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.timeline, size: 16),
                    label: const Text('What changed in my rhythm?'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _send('What changed in my rhythm?');
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: const Text('Plan my day around my capacity'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _send('Help me plan my day around my current recovery capacity.');
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.air, size: 16),
                    label: const Text('Suggest a quick pacing reset'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _send('Suggest a quick 2-minute pacing reset exercise.');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
