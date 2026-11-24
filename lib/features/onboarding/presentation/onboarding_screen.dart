import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trezuno/core/router/app_router.dart';

/// Onboarding Screen for Trezuno application.
/// 
/// This screen introduces users to the application's purpose,
/// highlights warranty tracking features, explains local storage and privacy,
/// and provides an optional notification introduction.
class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late _OnboardingPage _currentPage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Track if notifications were explained
  bool _notificationsExplained = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentPage = _OnboardingPage.page1;
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
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    context.go('/dashboard');
  }

  /// Called when user skips onboarding
  Future<void> _onSkip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    context.go('/dashboard');
  }

  /// Called when user enables notifications reminder
  Future<void> _onEnableNotifications() async {
    setState(() {
      _notificationsExplained = true;
    });
    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _OnboardingPage.page5;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator for multi-page onboarding
            _buildProgressIndicator(),
            const SizedBox(height: 32),

            // Page content
            Expanded(
              child: _currentPage.build(context, _onSkip, _onProceed, _notificationsExplained, _onEnableNotifications),
            ),

            // Navigation buttons (only on last page)
            if (!isLastPage) ...[
              const SizedBox(height: 24),
              _buildNavigationButtons(),
            ] else ...[
              const SizedBox(height: 40),
              _buildFinalCallToAction(),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the progress indicator showing current page out of total
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
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

  /// Builds the navigation buttons for non-final pages
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _onSkip,
          child: const Text(
            'Skip',
            style: TextStyle(
              color: Color(0xFF6E91AE),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            _animationController.forward();
            setState(() {
              final nextIndex = _currentPage.pageIndex + 1;
              if (nextIndex < _OnboardingPage.values.length) {
                _currentPage = _OnboardingPage.values[nextIndex];
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF315C81),
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 36),
          ),
          child: const Text('Next'),
        ),
      ],
    );
  }

  /// Builds the final call-to-action on the last page
  Widget _buildFinalCallToAction() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Get Started button
        ElevatedButton(
          onPressed: _onProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF315C81),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Get Started',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Internal enum for onboarding pages
enum _OnboardingPage {
  page1,
  page2,
  page3,
  page4,
  page5;

  int get pageIndex {
    return switch (this) {
      _OnboardingPage.page1 => 0,
      _OnboardingPage.page2 => 1,
      _OnboardingPage.page3 => 2,
      _OnboardingPage.page4 => 3,
      _OnboardingPage.page5 => 4,
    };
  }

  /// Builds the widget for each onboarding page
  Widget build(BuildContext context, VoidCallback onSkip, VoidCallback onProceed, bool notificationsExplained, VoidCallback onEnableNotifications) {
    switch (this) {
      case _OnboardingPage.page1:
        return _OnboardingPage1(onSkip: onSkip, onProceed: onProceed);
      case _OnboardingPage.page2:
        return _OnboardingPage2(onSkip: onSkip, onProceed: onProceed);
      case _OnboardingPage.page3:
        return _OnboardingPage3(onSkip: onSkip, onProceed: onProceed);
      case _OnboardingPage.page4:
        return _OnboardingPage4(
          onSkip: onSkip,
          onProceed: onProceed,
          notificationsExplained: notificationsExplained,
          onEnableNotifications: onEnableNotifications,
        );
      case _OnboardingPage.page5:
        return _OnboardingPage5(
          onSkip: onSkip,
          onProceed: onProceed,
          notificationsExplained: notificationsExplained,
          onEnableNotifications: onEnableNotifications,
        );
    }
  }
}

/// Page 1: Introduction to Trezuno
class _OnboardingPage1 extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onProceed;

  const _OnboardingPage1({
    required this.onSkip,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App icon illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE9B86E).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2,
              size: 60,
              color: Color(0xFFE9B86E),
            ),
          ),
          const SizedBox(height: 32),
          // Title
          const Text(
            'Never Lose Track of Your Warranties.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF315C81),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          const Text(
            'Trezuno helps you organize and track product warranties in one convenient place.\n'
            'Add your purchased products, save purchase dates, warranty periods, and attach invoice images.\n'
            'The application automatically calculates warranty expiration dates.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8291A0),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Key features preview
          _buildFeaturePreview(
            'Add Products',
            'Save purchase dates, warranty duration, and product details.',
          ),
          _buildFeaturePreview(
            'Auto Expiry',
            'Automatic calculation of warranty expiration dates.',
          ),
          _buildFeaturePreview(
            'Local Privacy',
            'All data stays on your device. No cloud, no tracking.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePreview(String title, String description) {
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
          Text(
            '$title: $description',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8291A0),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Page 2: Warranty tracking focus
class _OnboardingPage2 extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onProceed;

  const _OnboardingPage2({
    required this.onSkip,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Warranty card illustration
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF315C81).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF315C81),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Active Warranty',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF315C81),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress bar visual
                const LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: Color(0xFFE0E0E0),
                  color: Color(0xFF42A886),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                const Text(
                  '70% remaining',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8291A0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Stay on top of your warranty expiration dates.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF182635),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Trezuno automatically calculates when your warranties expire\n'
            'and helps you stay informed.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8291A0),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildFeaturePreview(
            'Multiple Warranties',
            'Track warranties for multiple products in one place.',
          ),
          _buildFeaturePreview(
            'Category Filtering',
            'Organize by product type: smartphones, laptops, appliances, etc.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePreview(String title, String description) {
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
          Text(
            '$title: $description',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8291A0),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Page 3: Local storage and privacy
class _OnboardingPage3 extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onProceed;

  const _OnboardingPage3({
    required this.onSkip,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Privacy icon/illustration
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE9B86E).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 50,
              color: Color(0xFFE9B86E),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Your Data is Private.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF182635),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Trezuno respects your privacy. All your product information,\n'
            'receipt images, and warranty details are stored locally on your device.\n'
            'No data is sent to the cloud. No tracking. No third-party services.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8291A0),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildFeaturePreview(
            'No Account Required',
            'No registration, no login, no phone number needed.',
          ),
          _buildFeaturePreview(
            'No Analytics',
            'No tracking, no crash reporting to external services.',
          ),
          _buildFeaturePreview(
            'Offline First',
            'Full functionality without internet connection.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePreview(String title, String description) {
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
          Text(
            '$title: $description',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8291A0),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Page 4: Notification introduction (optional)
class _OnboardingPage4 extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onProceed;
  final bool notificationsExplained;
  final VoidCallback onEnableNotifications;

  const _OnboardingPage4({
    required this.onSkip,
    required this.onProceed,
    required this.notificationsExplained,
    required this.onEnableNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Notification icon
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
            'Optional Warranty Reminders.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF182635),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Receive notifications before your warranties expire.\n'
            'Choose when you want to be reminded: 1 day, 7 days, 14 days, or 30 days before expiration.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8291A0),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          if (!notificationsExplained) ...[
            const Text(
              'We do not request notification permission immediately on launch.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8291A0),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'You can enable reminders later in the Settings screen.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8291A0),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onEnableNotifications,
              icon: const Icon(Icons.notifications_active, color: Colors.white),
              label: const Text('Enable Reminders'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF315C81),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ] else ...[
            const Text(
              'Reminders can be enabled later in Settings.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8291A0),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Icon(
              Icons.check_circle,
              color: Color(0xFF42A886),
              size: 24,
            ),
          ],
        ],
      ),
    );
  }
}

/// Page 5: Final call to action / get started
class _OnboardingPage5 extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onProceed;
  final bool notificationsExplained;
  final VoidCallback onEnableNotifications;

  const _OnboardingPage5({
    required this.onSkip,
    required this.onProceed,
    required this.notificationsExplained,
    required this.onEnableNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBenefitItem(
            'Organize All Products',
            'Add and manage all your products in one place.',
          ),
          _buildBenefitItem(
            'Auto Expiration',
            'Never forget a warranty expiration date again.',
          ),
          _buildBenefitItem(
            'Local Privacy',
            'Your data stays on your device, always.',
          ),
          _buildBenefitItem(
            'Optional Reminders',
            'Get notified before warranties expire.',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
