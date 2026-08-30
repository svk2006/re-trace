import 'package:flutter/material.dart';
import 'package:re_trace/models/re_trace_models.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/motion.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';
import 'package:re_trace/widgets/check_in_controls.dart';

class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  final PageController _pageController = PageController();
  int _step = 0;
  int _mood = 3;
  double _energy = 6;
  double _fatigue = 3;
  double _focus = 5;
  final List<String> _symptoms = [];
  bool _complete = false;

  static const _symptomOptions = [
    'Headache',
    'Brain fog',
    'Fatigue',
    'Dizziness',
    'Nausea',
    'Light sensitivity',
    'Noise sensitivity',
    'Concentration difficulty',
    'Memory difficulty',
    'Sleep difficulty',
    'Mood changes',
  ];

  static const _questions = [
    'How are you feeling?',
    'How is your energy right now?',
    'How heavy does fatigue feel?',
    'How is your focus?',
    'What are you noticing today?',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DailyCheckInResult get _result => DailyCheckInResult(
        mood: _mood,
        energy: _energy.round(),
        fatigue: _fatigue.round(),
        focus: _focus.round(),
        mentalLoad: (11 - _focus.round()).clamp(1, 10),
        discomfort: _fatigue.round(),
        symptoms: List.of(_symptoms),
      );

  Future<void> _next() async {
    AppSession.maybeOf(context)?.tapFeedback();
    if (_step < _questions.length - 1) {
      await _pageController.nextPage(
        duration: ReTraceMotion.of(context, ReTraceMotion.medium),
        curve: ReTraceMotion.spatial,
      );
      return;
    }
    setState(() => _complete = true);
  }

  Future<void> _back() async {
    if (_complete) {
      setState(() => _complete = false);
      return;
    }
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    await _pageController.previousPage(
      duration: ReTraceMotion.of(context, ReTraceMotion.medium),
      curve: ReTraceMotion.spatial,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/atmosphere/sunset_lake.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  palette.overlay.withValues(alpha: 0.35),
                  palette.background.withValues(alpha: 0.88),
                  palette.background,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: AnimatedSwitcher(
                duration: ReTraceMotion.of(context, ReTraceMotion.long),
                child: _complete ? _buildComplete(palette) : _buildFlow(palette),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlow(ReTracePalette palette) {
    return Column(
      key: const ValueKey('flow'),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Expanded(
              child: Column(
                children: [
                  Text('Daily Check-in', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('${_step + 1} of ${_questions.length}', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: (_step + 1) / _questions.length,
            minHeight: 6,
            backgroundColor: palette.surfaceInteractive,
            color: palette.accent,
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (value) => setState(() => _step = value),
            children: [
              _questionCard(
                title: _questions[0],
                child: MoodPicker(value: _mood, onChanged: (v) => setState(() => _mood = v)),
              ),
              _questionCard(
                title: _questions[1],
                child: RecoverySlider(
                  value: _energy,
                  onChanged: (v) => setState(() => _energy = v),
                  lowLabel: 'Drained',
                  highLabel: 'Strong',
                  captionFor: _energyCaption,
                ),
              ),
              _questionCard(
                title: _questions[2],
                child: RecoverySlider(
                  value: _fatigue,
                  onChanged: (v) => setState(() => _fatigue = v),
                  lowLabel: 'Light',
                  highLabel: 'Heavy',
                  captionFor: _fatigueCaption,
                ),
              ),
              _questionCard(
                title: _questions[3],
                child: RecoverySlider(
                  value: _focus,
                  onChanged: (v) => setState(() => _focus = v),
                  lowLabel: 'Scattered',
                  highLabel: 'Clear',
                  captionFor: _focusCaption,
                ),
              ),
              _questionCard(
                title: _questions[4],
                subtitle: 'Choose anything that matches this moment. Skip if nothing fits.',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _symptomOptions.map((symptom) {
                    final selected = _symptoms.contains(symptom);
                    return FilterChip(
                      label: Text(symptom),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          if (selected) {
                            _symptoms.remove(symptom);
                          } else {
                            _symptoms.add(symptom);
                          }
                        });
                      },
                      selectedColor: palette.accentSoft,
                      checkmarkColor: palette.textPrimary,
                      backgroundColor: palette.surfaceGlass,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('You can always change it later.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        GradientCta(
          label: _step == _questions.length - 1 ? 'Finish' : 'Continue',
          onPressed: _next,
        ),
      ],
    );
  }

  Widget _questionCard({required String title, String? subtitle, required Widget child}) {
    return SizedBox.expand(
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 24),
            Expanded(child: SingleChildScrollView(child: child)),
          ],
        ),
      ),
    );
  }

  Widget _buildComplete(ReTracePalette palette) {
    final result = _result;
    return Column(
      key: const ValueKey('complete'),
      children: [
        const Spacer(),
        Text('That\'s enough for today.', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32)),
        const SizedBox(height: 10),
        Text(
          'Your recovery picture is a little clearer.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: 28),
        GlassPanel(
          child: Column(
            children: [
              _summaryRow('Energy', '${result.energy}/10'),
              _summaryRow('Fatigue', '${result.fatigue}/10'),
              _summaryRow('Focus', '${result.focus}/10'),
              _summaryRow(
                'Symptoms',
                result.symptoms.isEmpty ? 'None noted' : result.symptoms.join(' · '),
              ),
            ],
          ),
        ),
        const Spacer(),
        GradientCta(
          label: 'See my recovery',
          onPressed: () => Navigator.of(context).pop(result),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 92, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16))),
        ],
      ),
    );
  }

  String _energyCaption(int v) {
    if (v <= 2) return 'Drained';
    if (v <= 4) return 'Running low';
    if (v <= 6) return 'Getting by';
    if (v <= 8) return 'Feeling good';
    return 'Plenty of energy';
  }

  String _fatigueCaption(int v) {
    if (v <= 2) return 'Quite light';
    if (v <= 4) return 'Manageable';
    if (v <= 6) return 'Present';
    if (v <= 8) return 'Heavy';
    return 'Asking for rest';
  }

  String _focusCaption(int v) {
    if (v <= 2) return 'Hard to hold';
    if (v <= 4) return 'A little foggy';
    if (v <= 6) return 'Working through it';
    if (v <= 8) return 'Mostly clear';
    return 'Steady and available';
  }
}
