import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_typography.dart';

/// Home Dashboard Screen for Trezuno application.
///
/// Displays:
/// - Welcome message
/// - Total Products
/// - Active Warranties
/// - Expiring Soon
/// - Expired Warranties
/// - Upcoming Expirations
/// - Recently Added Products
/// - Quick Add Product button
///
/// Uses visually distinctive summary cards.
/// Includes attractive empty state when no products exist.
class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _totalProducts = 0;
  int _activeWarranties = 0;
  int _expiringSoon = 0;
  int _expiredWarranties = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    // Initialize with mock data for demo
    _initializeMockData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize mock data for demonstration
  void _initializeMockData() {
    // In a full implementation, this would come from the database
    _totalProducts = 3;
    _activeWarranties = 2;
    _expiringSoon = 1;
    _expiredWarranties = 0;
  }

  /// Build the floating action button for adding a product
  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.go('/add-product'),
      backgroundColor: const Color(0xFF315C81),
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }

  /// Build summary card for dashboard
  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: valueColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: valueColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTypography.titleLarge.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF8291A0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: AnimatedBuilder(
        animation: _fadeInAnimation,
        builder: (context, child) => FadeTransition(
          opacity: _fadeInAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  _buildWelcomeSection(),
                  const SizedBox(height: 32),

                  // Summary cards
                  _buildSummarySection(),
                  const SizedBox(height: 32),

                  // Recently added products
                  _buildRecentlyAddedSection(),
                  const Spacer(),

                  // Quick add button area
                  _buildQuickAddSection(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Build the app bar with welcome and search
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFF182635),
      title: const Text('Trezuno'),
      actions: [
        // Theme toggle button
        IconButton(
          icon: const Icon(Icons.brightness_6_outlined),
          tooltip: 'Toggle theme',
          onPressed: () {
            // Will be implemented in settings
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Build welcome section with user greeting
  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        Row(
          children: [
            Text(
              'Hello!',
              style: AppTypography.headlineMedium.copyWith(
                color: const Color(0xFF182635),
              ),
            ),
            const Spacer(),
            // Avatar placeholder
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE9B86E),
              child: const Text(
                'U',
                style: TextStyle(
                  color: Color(0xFF182635),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          'Welcome back to Trezuno',
          style: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFF6E91AE),
          ),
        ),
      ],
    );
  }

  /// Build summary section with key statistics
  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF182635),
              ),
            ),
            const Spacer(),
            // See all link
            TextButton(
              onPressed: () {},
              child: const Text(
                'See all',
                style: TextStyle(
                  color: Color(0xFF315C81),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Summary cards row
        Row(
          children: [
            // Total Products card
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.inventory,
                title: 'Total Products',
                value: _totalProducts.toString(),
                valueColor: const Color(0xFF315C81),
                backgroundColor: const Color(0xFFF5F7FA),
              ),
            ),
            const SizedBox(width: 16),

            // Active Warranties card
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.check_circle,
                title: 'Active',
                value: _activeWarranties.toString(),
                valueColor: const Color(0xFF42A886),
                backgroundColor: const Color(0xFFE8F5F0),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            // Expiring Soon card
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.alarm,
                title: 'Expiring Soon',
                value: _expiringSoon.toString(),
                valueColor: const Color(0xFFE8A64D),
                backgroundColor: const Color(0xFFFFF8F0),
              ),
            ),
            const SizedBox(width: 16),

            // Expired Warranties card
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.remove,
                title: 'Expired',
                value: _expiredWarranties.toString(),
                valueColor: const Color(0xFFD96B6B),
                backgroundColor: const Color(0xFFFEF3F3),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Upcoming expirations header
        Row(
          children: [
            const Text(
              'Upcoming Expirations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF182635),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/warranty-calendar'),
              child: const Text(
                'View all',
                style: TextStyle(
                  color: Color(0xFF315C81),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build recently added products section
  Widget _buildRecentlyAddedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            const Text(
              'Recently Added',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF182635),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View all',
                style: TextStyle(
                  color: Color(0xFF315C81),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Empty state when no products
        if (_totalProducts == 0) _buildEmptyState()
        else ...[
          // Products list
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _totalProducts > 3 ? 3 : _totalProducts,
              itemBuilder: (context, index) => _buildProductPreviewCard(),
            ),
          ),
        ],
      ],
    );
  }

  /// Build empty state when no products exist
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF42A886).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Color(0xFF42A886),
          ),
          const SizedBox(height: 16),
          Text(
            'No products yet',
            style: AppTypography.titleMedium.copyWith(
              color: const Color(0xFF315C81),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first product to get started',
            style: AppTypography.bodyMedium.copyWith(
              color: const Color(0xFF6E91AE),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/add-product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF315C81),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('Add First Product'),
          ),
        ],
      ),
    );
  }

  /// Build a preview card for a product in the recently added list
  Widget _buildProductPreviewCard() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blur: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              color: const Color(0xFFDEE4E8),
            ),
            child: const Center(
              child: Text(
                'Product',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF78909C),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Product name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Product Name',
              style: AppTypography.bodySmall.copyWith(
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),
          // Warranty status
          Container(
            height: 16,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Active',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF42A886),
                  fontSize: 9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build quick add section at the bottom
  Widget _buildQuickAddSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF315C81),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Add Product',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF182635),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            '+',
            style: TextStyle(
              fontSize: 48,
              color: Color(0xFFE9B86E),
            ),
          ),
        ],
      ),
    );
  }
}