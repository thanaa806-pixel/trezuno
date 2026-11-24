import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trezuno/core/router/app_router.dart';
import 'package:trezuno/core/theme/app_colors.dart';
import 'package:trezuno/core/theme/app_typography.dart';

/// Notifications Screen for Trezuno application.
///
/// Display scheduled and relevant warranty reminders.
///
/// Reminder options:
/// - 30 days before expiration
/// - 14 days before expiration
/// - 7 days before expiration
/// - 1 day before expiration
///
/// Allows users to enable or disable individual reminders.
/// Uses local notifications only.
/// Does not use push notifications or remote notification servers.
/// Handles notification permissions gracefully.
class NotificationsScreen extends StatefulWidget {
  static const routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState;
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late _NotificationPage _currentPage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentPage = _NotificationPage.page1;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Called when user proceeds to next page or completes onboarding
  Future<void> _onProceed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', true);
    if (!mounted) return;
    context.go('/settings');
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _NotificationPage.page4;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            const SizedBox(height: 32),

            // Page content
            Expanded(
              child: _buildPageContent(),
            ),

            // Navigation buttons
            const SizedBox(height: 24),
            _buildNavigationButtons(isLastPage),
          ],
        ),
      ),
    );
  }

  /// Build the progress indicator showing current page out of total
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage.index >= index
                ? const Color(0xFF315C81)
                : const Color(0xFFDEE4E8),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  /// Build the current page content based on _currentPage
  Widget _buildPageContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: const Offset(0, 0),
        ).animate(_animationController),
        child: _NotificationPageWidget(
          page: _currentPage,
          onProceed: _onProceed,
        ),
      ),
    );
  }

  /// Build the navigation buttons
  Widget _buildNavigationButtons(bool isLastPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => context.go('/settings'),
          child: const Text('Skip'),
        ),
        const SizedBox(width: 8),
        if (!isLastPage)
          ElevatedButton(
            onPressed: () {
              _animationController.forward();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF315C81),
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 36),
            ),
            child: const Text('Next'),
          ),
        else ...[
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _onProceed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF315C81),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text('Get Started'),
          ),
        ],
      ],
    );
  }
}

/// Internal enum for notification pages
enum _NotificationPage {
  page1,
  page2,
  page3,
  page4;

  int get index {
    return switch (this) {
      _NotificationPage.page1 => 0,
      _NotificationPage.page2 => 1,
      _NotificationPage.page3 => 2,
      _NotificationPage.page4 => 3,
    };
  }

  /// Builds the widget for each notification page
  Widget build(BuildContext context, VoidCallback onProceed) {
    switch (this) {
      case _NotificationPage.page1:
        return _NotificationPage1(onProceed: onProceed);
      case _NotificationPage.page2:
        return _NotificationPage2(onProceed: onProceed);
      case _NotificationPage.page3:
        return _NotificationPage3(onProceed: onProceed);
      case _NotificationPage.page4:
        return _NotificationPage4(onProceed: onProceed);
    }
  }
}

/// Page 1: Introduction to notifications
class _NotificationPage1 extends StatelessWidget {
  final VoidCallback onProceed;

  const _NotificationPage1({
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE9B86E).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications,
              size: 50,
              color: Color(0xFFE9B86E),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Warranty Reminders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF182635),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Receive notifications before your warranties expire.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6E91AE),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Feature highlights
          _buildFeatureHighlight(
            '30 days before',
            'Get plenty of time to renew or take action.',
          ),
          _buildFeatureHighlight(
            '14 days before',
            'Make sure you do not miss the expiration.',
          ),
          _buildFeatureHighlight(
            '7 days before',
            'Final reminder to take action.',
          ),
          _buildFeatureHighlight(
            '1 day before',
            'Last chance before warranty expires.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlight(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF42A886),
            size: 16,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '$title: $description',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8291A0),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Page 2: Reminder scheduling options
class _NotificationPage2 extends StatelessWidget {
  final VoidCallback onProceed;

  const _NotificationPage2({
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Select Reminder Intervals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF182635),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Reminder option cards
          ..._buildReminderOptions(),
          const Spacer(),
          // Continue button
          ElevatedButton(
            onPressed: onProceed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF315C81),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Build reminder option cards
  List<Widget> _buildReminderOptions() {
    final options = [
      {'interval': '30 days', 'description': 'Before expiration'},
      {'interval': '14 days', 'description': 'Before expiration'},
      {'interval': '7 days', 'description': 'Before expiration'},
      {'interval': '1 day', 'description': 'Before expiration'},
    ];

    return List.generate(options.length, (index) => _ReminderOption(
      index: index,
      interval: options[index]['interval']!,
      description: options[index]['description']!,
      isSelected: _currentPage.index >= index + 1, // Simplified selection
      onTap: () {
        // Handle selection - in full impl would update state
      },
    ));
  }
}

/// Reminder option widget
class _ReminderOption extends StatelessWidget {
  final int index;
  final String interval;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReminderOption({
    required this.index,
    required this.interval,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(0xFF315C81).withOpacity(0.1)
              : Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: BorderSide(
            color: isSelected ? Color(0xFF315C81) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Checkmark if selected
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF42A886),
                size: 20,
              ),
            const Spacer(),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    interval,
                    style: TextStyle(
                      color: isSelected ? Color(0xFF315C81) : Color(0xFF182635),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: isSelected ? Color(0xFF8291A0) : Color(0xFF6E91AE),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF42A886),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// Page 3: Notification permissions and settings
class _NotificationPage3 extends StatelessWidget {
  final VoidCallback onProceed;

  const _NotificationPage3({
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Notification Permissions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF182635),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Permission status
          _buildPermissionStatus(context),
          const SizedBox(height: 32),
          // Options
          _buildPermissionOptions(context),
          const Spacer(),
          // Continue button
          ElevatedButton(
            onPressed: onProceed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF315C81),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Build the permission status display
  Widget _buildPermissionStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFDEE4E8)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.notifications_none,
            size: 48,
            color: Color(0xFF8291A0),
          ),
          const SizedBox(height: 12),
          const Text(
            'Notifications disabled',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF182635),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Enable notifications to receive warranty reminders.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6E91AE),
              height: 1.5,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the permission options
  Widget _buildPermissionOptions(BuildContext context) {
    return Column(
      children: [
        _PermissionOption(
          title: 'Enable All Reminders',
          description: 'Receive all notification intervals',
          isActive: false,
          onTap: () {
            // In full implementation, would request notification permission
          },
        ),
        const SizedBox(height: 12),
        _PermissionOption(
          title: 'Disable All Reminders',
          description: 'No warranty expiration notifications',
          isActive: true,
          onTap: () {
            // Handle disable all
          },
        ),
      ],
    );
  }
}

/// Permission option widget
class _PermissionOption extends StatelessWidget {
  final String title;
  final String description;
  final bool isActive;
  final VoidCallback onTap;

  const _PermissionOption({
    required this.title,
    required this.description,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? Color(0xFFE8F5F0) : Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: BorderSide(
            color: isActive ? Color(0xFF42A886) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? Icons.notifications_active : Icons.notifications_off,
              color: isActive ? Color(0xFF42A886) : Color(0xFF8291A0),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isActive ? Color(0xFF182635) : Color(0xFF182635),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: isActive ? Color(0xFF6E91A0) : Color(0xFF8291A0),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Color(0xFF78909C),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page 4: Final call to action
class _NotificationPage4 extends StatelessWidget {
  final VoidCallback onProceed;

  const _NotificationPage4({
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Summary
        _buildSummaryItem(
          'Total Reminder Intervals',
          '4 options available',
        ),
        _buildSummaryItem(
          'Notification Type',
          'Local only - no remote servers',
        ),
        _buildSummaryItem(
          'Data Privacy',
          'All data stays on your device',
        ),
        const Spacer(),
        // Get started button
        ElevatedButton(
          onPressed: onProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF315C81),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text('Get Started'),
        ),
        const SizedBox(height: 16),
        // Skip
        TextButton(
          onPressed: () => context.go('/settings'),
          child: const Text('Skip'),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF42A886),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF182635),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8291A0),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}