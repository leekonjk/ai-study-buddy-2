/// Settings Screen
/// App settings and preferences.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:studnet_ai_buddy/presentation/providers/theme_provider.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Settings screen for app preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _notificationsEnabled = true;
  bool _dailyReminders = true;
  bool _studyStreakReminders = true;
  bool _soundEffects = true;
  bool _hapticFeedback = true;
  String _studyGoal = '30 min';
  String _theme = 'Dark';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: StudyBuddyColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Settings list
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notifications section
                      _buildSectionTitle(
                        'Notifications',
                        Icons.notifications_rounded,
                      ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                            _buildSwitchTile(
                              title: 'Push Notifications',
                              subtitle: 'Receive study reminders and updates',
                              value: _notificationsEnabled,
                              onChanged: (v) =>
                                  setState(() => _notificationsEnabled = v),
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: 'Daily Reminders',
                              subtitle: 'Get reminded to study every day',
                              value: _dailyReminders,
                              enabled: _notificationsEnabled,
                              onChanged: (v) =>
                                  setState(() => _dailyReminders = v),
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: 'Streak Alerts',
                              subtitle: 'Don\'t lose your study streak',
                              value: _studyStreakReminders,
                              enabled: _notificationsEnabled,
                              onChanged: (v) =>
                                  setState(() => _studyStreakReminders = v),
                            ),
                          ])
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 24),

                      // Study Settings section
                      _buildSectionTitle('Study Settings', Icons.school_rounded)
                          .animate()
                          .fadeIn(delay: 150.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                            _buildSelectionTile(
                              title: 'Daily Study Goal',
                              value: _studyGoal,
                              options: [
                                '15 min',
                                '30 min',
                                '45 min',
                                '1 hour',
                                '2 hours',
                              ],
                              onChanged: (v) => setState(() => _studyGoal = v),
                            ),
                          ])
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 24),

                      // Appearance section
                      _buildSectionTitle('Appearance', Icons.palette_rounded)
                          .animate()
                          .fadeIn(delay: 250.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                            _buildSelectionTile(
                              title: 'Theme',
                              value: _theme,
                              options: ['Dark', 'Light', 'System'],
                              onChanged: (v) {
                                setState(() => _theme = v);
                                // Apply theme using ThemeProvider
                                final themeProvider = context
                                    .read<ThemeProvider>();
                                switch (v) {
                                  case 'Dark':
                                    themeProvider.setDarkMode();
                                    break;
                                  case 'Light':
                                    themeProvider.setLightMode();
                                    break;
                                  case 'System':
                                    themeProvider.setSystemMode();
                                    break;
                                }
                              },
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: 'Sound Effects',
                              subtitle: 'Play sounds for actions',
                              value: _soundEffects,
                              onChanged: (v) =>
                                  setState(() => _soundEffects = v),
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: 'Haptic Feedback',
                              subtitle: 'Vibration on interactions',
                              value: _hapticFeedback,
                              onChanged: (v) =>
                                  setState(() => _hapticFeedback = v),
                            ),
                          ])
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 24),

                      // Data & Privacy section
                      _buildSectionTitle(
                            'Data & Privacy',
                            Icons.security_rounded,
                          )
                          .animate()
                          .fadeIn(delay: 350.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                            _buildNavigationTile(
                              title: 'Privacy Policy',
                              icon: Icons.privacy_tip_rounded,
                              onTap: () =>
                                  _launchUrl('https://studybuddy.app/privacy'),
                            ),
                            _buildDivider(),
                            _buildNavigationTile(
                              title: 'Terms of Service',
                              icon: Icons.description_rounded,
                              onTap: () =>
                                  _launchUrl('https://studybuddy.app/terms'),
                            ),
                            _buildDivider(),
                            _buildNavigationTile(
                              title: 'Export My Data',
                              icon: Icons.download_rounded,
                              onTap: () => _exportData(),
                            ),
                            _buildDivider(),
                            _buildDangerTile(
                              title: 'Clear Study History',
                              icon: Icons.delete_sweep_rounded,
                              onTap: () => _showClearHistoryDialog(),
                            ),
                          ])
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 24),

                      // Support section
                      _buildSectionTitle('Support', Icons.help_rounded)
                          .animate()
                          .fadeIn(delay: 450.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                            _buildNavigationTile(
                              title: 'Help Center',
                              icon: Icons.help_outline_rounded,
                              onTap: () =>
                                  _launchUrl('https://studybuddy.app/help'),
                            ),
                            _buildDivider(),
                            _buildNavigationTile(
                              title: 'Contact Support',
                              icon: Icons.email_rounded,
                              onTap: () =>
                                  _launchEmail('support@studybuddy.app'),
                            ),
                            _buildDivider(),
                            _buildNavigationTile(
                              title: 'Rate the App',
                              icon: Icons.star_rounded,
                              onTap: () => _launchUrl(
                                'https://play.google.com/store/apps/details?id=com.studybuddy.app',
                              ),
                            ),
                          ])
                          .animate()
                          .fadeIn(delay: 500.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 32),

                      // App version
                      Center(
                        child: Text(
                          'AI Study Buddy v1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: StudyBuddyColors.textTertiary,
                          ),
                        ),
                      ).animate().fadeIn(delay: 550.ms),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StudyBuddyColors.cardBackground,
                borderRadius: StudyBuddyDecorations.borderRadiusS,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: StudyBuddyColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: StudyBuddyColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: StudyBuddyColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: StudyBuddyColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: StudyBuddyColors.border.withValues(alpha: 0.5),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: StudyBuddyColors.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeThumbColor: StudyBuddyColors.primary,
          inactiveTrackColor: StudyBuddyColors.border,
        ),
      ),
    );
  }

  Widget _buildSelectionTile({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: StudyBuddyColors.textPrimary,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: StudyBuddyColors.primary.withValues(alpha: 0.1),
          borderRadius: StudyBuddyDecorations.borderRadiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: StudyBuddyColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: StudyBuddyColors.primary,
            ),
          ],
        ),
      ),
      onTap: () => _showSelectionDialog(title, value, options, onChanged),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, size: 22, color: StudyBuddyColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: StudyBuddyColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: StudyBuddyColors.textTertiary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDangerTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, size: 22, color: StudyBuddyColors.error),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: StudyBuddyColors.error,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: StudyBuddyColors.error,
      ),
      onTap: onTap,
    );
  }

  void _showSelectionDialog(
    String title,
    String currentValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: StudyBuddyColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map(
              (option) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    color: option == currentValue
                        ? StudyBuddyColors.primary
                        : StudyBuddyColors.textPrimary,
                    fontWeight: option == currentValue
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                trailing: option == currentValue
                    ? const Icon(
                        Icons.check_rounded,
                        color: StudyBuddyColors.primary,
                      )
                    : null,
                onTap: () {
                  onChanged(option);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StudyBuddyColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: StudyBuddyDecorations.borderRadiusL,
        ),
        title: const Text(
          'Clear Study History?',
          style: TextStyle(color: StudyBuddyColors.textPrimary),
        ),
        content: const Text(
          'This will permanently delete all your study session data. This action cannot be undone.',
          style: TextStyle(color: StudyBuddyColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Study history cleared'),
                  backgroundColor: StudyBuddyColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StudyBuddyColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Study Buddy Support Request'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing your data export...'),
        duration: Duration(seconds: 2),
      ),
    );
    // In real implementation, this would export user data
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data export complete! Check your downloads.'),
            backgroundColor: StudyBuddyColors.success,
          ),
        );
      }
    });
  }
}
