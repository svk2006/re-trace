import 'package:flutter/material.dart';
import 'package:re_trace/state/app_session.dart';
import 'package:re_trace/theme/re_trace_palette.dart';
import 'package:re_trace/widgets/atmosphere.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppSession.of(context);
    final palette = context.palette;

    return Scaffold(
      body: AmbientCanvas(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
              const SizedBox(height: 12),
              Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _themeRow(context, 'Light', ThemeMode.light, session),
              _themeRow(context, 'Dark', ThemeMode.dark, session),
              _themeRow(context, 'System', ThemeMode.system, session),
              const SizedBox(height: 22),
              Text('Accessibility', style: Theme.of(context).textTheme.titleLarge),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reduced motion'),
                subtitle: const Text('Softer fades instead of larger movement.'),
                value: session.reducedMotion,
                onChanged: session.setReducedMotion,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Low stimulation mode'),
                subtitle: const Text('Quieter visuals for concussion-friendly pacing.'),
                value: session.lowStimulation,
                onChanged: session.setLowStimulation,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Haptics'),
                subtitle: const Text('Optional, off by default, never startling.'),
                value: session.haptics,
                onChanged: session.setHaptics,
              ),
              const SizedBox(height: 12),
              Text('Recovery', style: Theme.of(context).textTheme.titleLarge),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Daily check-in reminder'),
                value: session.checkInReminder,
                onChanged: session.setCheckInReminder,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reminder time'),
                trailing: Text(session.reminderTime.format(context)),
                onTap: () async {
                  final next = await showTimePicker(context: context, initialTime: session.reminderTime);
                  if (next != null) session.setReminderTime(next);
                },
              ),
              const SizedBox(height: 12),
              Text('Data', style: Theme.of(context).textTheme.titleLarge),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recovery data'),
                subtitle: const Text('Mock-only in this prototype. No cloud export yet.'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Privacy'),
                subtitle: const Text('Check-ins stay on this device in the current mock architecture.'),
              ),
              const SizedBox(height: 12),
              Text('About', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('RE:TRACE 1.0.0', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(
                'RE:TRACE supports reflection and pacing. It does not diagnose concussion, does not medically clear work or sport, and does not replace clinical care.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeRow(BuildContext context, String label, ThemeMode mode, AppSessionController session) {
    final selected = session.themeMode == mode;
    final palette = context.palette;
    return Pressable(
      onTap: () => session.setThemeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? palette.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined, color: selected ? palette.accent : palette.textMuted),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17)),
          ],
        ),
      ),
    );
  }
}
