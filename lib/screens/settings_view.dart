import 'package:flutter/material.dart';
import 'package:re_trace/services/notification_service.dart';
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
              Text('Profile & Name', style: Theme.of(context).textTheme.titleLarge),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Your name'),
                subtitle: Text(session.userName),
                trailing: const Icon(Icons.edit_outlined, size: 20),
                onTap: () {
                  final controller = TextEditingController(text: session.userName);
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Change Name'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                        FilledButton(
                          onPressed: () {
                            if (controller.text.trim().isNotEmpty) {
                              session.setUserName(controller.text.trim());
                            }
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Test reminder notification'),
                subtitle: const Text('Send an instant test alert to verify delivery.'),
                trailing: const Icon(Icons.notifications_active_outlined, size: 20),
                onTap: () async {
                  await NotificationService().showInstantNotification(
                    title: 'RE:TRACE Daily Check-in',
                    body: 'How are your energy and symptoms feeling today?',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test notification sent! Check your notification bar.')),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              Text('Data & Privacy', style: Theme.of(context).textTheme.titleLarge),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Local storage'),
                subtitle: Text('All check-ins, history, and settings are saved privately on this device.'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Privacy-first AI'),
                subtitle: Text('TRACE chats use secure, ephemeral memory. No diagnostic logs leave your control.'),
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
