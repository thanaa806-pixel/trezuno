import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trezuno/core/router/app_router.dart';
import 'package:trezuno/core/theme/app_colors.dart';
import 'package:trezuno/core/theme/app_typography.dart';

/// Notifications Screen for Trezuno application.
///
/// Display scheduled and relevant warranty reminders.
class NotificationsScreen extends StatefulWidget {
  static const routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
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
              child: _currentPage.build(context, _onProceed),
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
            color: _currentPage.pageIndex >= index
                ? const Color(0xFF315C81)
                : const Color(0xFFDEE4E8),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  /// Build the navigation buttons
  Widget _buildNavigationButtons(bool isLastPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
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
                setState(() {
                  final nextIndex = _currentPage.pageIndex + 1;
                  if (nextIndex < _NotificationPage.values.length) {
                    _currentPage = _NotificationPage.values[nextIndex];
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF315C81),
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 36),
              ),
              child: const Text('Next'),
            )
          else
            Expanded(
              child: ElevatedButton(
                onPressed: _onProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF315C81),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Get Started'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Internal enum for notification pages
enum _NotificationPage {
  page1,
  page2,
  page3,
  page4;

  int get pageIndex {
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
      child: Row(
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
          const SizedBox(height: 24),
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
      isSelected: index <= 1,
      onTap: () {},
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
              ? const Color(0xFF315C81).withOpacity(0.1)
              : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF315C81) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF42A886),
                size: 20,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    interval,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF315C81) : const Color(0xFF182635),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF8291A0) : const Color(0xFF6E91AE),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
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
          _buildPermissionStatus(context),
          const SizedBox(height: 32),
          _buildPermissionOptions(context),
          const SizedBox(height: 24),
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
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEE4E8)),
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
          const Text(
            'Enable notifications to receive warranty reminders.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6E91AE),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
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
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _PermissionOption(
          title: 'Disable All Reminders',
          description: 'No warranty expiration notifications',
          isActive: true,
          onTap: () {},
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
          color: isActive ? const Color(0xFFE8F5F0) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF42A886) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? Icons.notifications_active : Icons.notifications_off,
              color: isActive ? const Color(0xFF42A886) : const Color(0xFF8291A0),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF182635),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: isActive ? const Color(0xFF6E91A0) : const Color(0xFF8291A0),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
