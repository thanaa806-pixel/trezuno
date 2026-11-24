import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trezuno/core/constants/app_constants.dart';
import 'package:trezuno/core/theme/app_colors.dart';
import 'package:trezuno/core/theme/app_typography.dart';

/// Settings Screen for Trezuno application.
class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en';
  String _selectedTheme = 'system';
  List<int> _reminderDays = [30, 14, 7, 1];
  bool _isLoading = true;

  static const _keyNotifications = 'notifications_enabled';
  static const _keyLanguage = 'selected_language';
  static const _keyTheme = 'selected_theme';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
      _selectedLanguage = prefs.getString(_keyLanguage) ?? 'en';
      _selectedTheme = prefs.getString(_keyTheme) ?? 'system';
      _isLoading = false;
    });
  }

  Future<void> _updateNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _updateLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
    setState(() {
      _selectedLanguage = lang;
    });
  }

  Future<void> _updateTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, theme);
    setState(() {
      _selectedTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Preferences'),
          _buildThemeCard(),
          const SizedBox(height: 12),
          _buildLanguageCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Notifications'),
          _buildNotificationCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('About & Privacy'),
          _buildPrivacyCard(),
          const SizedBox(height: 12),
          _buildAboutCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Data Management'),
          _buildDangerZoneCard(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      child: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThemeCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Theme Mode',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'light', label: Text('Light'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: 'system', label: Text('System'), icon: Icon(Icons.brightness_auto)),
                ButtonSegment(value: 'dark', label: Text('Dark'), icon: Icon(Icons.dark_mode)),
              ],
              selected: {_selectedTheme},
              onSelectionChanged: (set) => _updateTheme(set.first),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.language, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Language',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            DropdownButton<String>(
              value: _selectedLanguage,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English (US)')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (val) {
                if (val != null) _updateLanguage(val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Warranty Expiration Alerts',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Receive reminders before your warranties expire',
                style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
              ),
              value: _notificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: _updateNotifications,
            ),
            if (_notificationsEnabled) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reminder intervals',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${_reminderDays.join(', ')} days before',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
        title: Text(
          'Privacy Policy',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Read our offline data policy',
          style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.go('/privacy-policy'),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trezuno Warranty Tracker',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.version} (Build ${AppConstants.buildNumber})',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.delete_outline, color: AppColors.danger),
        title: Text(
          'Clear All Data',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.danger,
          ),
        ),
        subtitle: Text(
          'Permanently remove all products and receipts',
          style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.danger),
        onTap: _showClearDataConfirmation,
      ),
    );
  }

  Future<void> _showClearDataConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your stored warranties and attached receipts from this device. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data has been reset successfully.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
}
