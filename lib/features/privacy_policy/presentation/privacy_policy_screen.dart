import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trezuno/core/theme/app_colors.dart';
import 'package:trezuno/core/theme/app_typography.dart';

/// Privacy Policy Screen for Trezuno application.
class PrivacyPolicyScreen extends StatefulWidget {
  static const routeName = '/privacy-policy';

  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCard(
              title: '100% Offline & Local Data',
              content:
                  'Trezuno operates completely offline. All your products, warranties, purchase dates, and receipt images are stored exclusively on your device. We do not have servers, accounts, or cloud databases that access or track your records.',
              icon: Icons.shield_outlined,
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Photo & Camera Access',
              content:
                  'Trezuno requests permission to use your camera and photo library solely to allow you to photograph or select receipts and warranty documents for your items. These images stay on your device and are never uploaded.',
              icon: Icons.photo_library_outlined,
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Local Notifications',
              content:
                  'If enabled, Trezuno schedules local on-device alarms to notify you before your product warranties expire. No notification content or identifiers leave your device.',
              icon: Icons.notifications_active_outlined,
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'No Advertising or Analytics',
              content:
                  'We do not include third-party advertising SDKs, tracking frameworks, or diagnostic tracking in Trezuno. Your usage remains completely private.',
              icon: Icons.block_outlined,
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Data Deletion & User Rights',
              content:
                  'You have full control over your data. You can edit or delete any product at any time, or permanently erase all app data using the "Clear All Data" feature in Settings.',
              icon: Icons.delete_outline,
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Last updated: November 2026',
                style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy-First by Design',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your warranties belong to you. No tracking, no cloud.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
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
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: AppTypography.bodyMedium.copyWith(
                color: const Color(0xFF182635),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
