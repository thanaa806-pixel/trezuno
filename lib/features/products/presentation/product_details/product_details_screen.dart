import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:trezuno/features/products/domain/product_model.dart';
import 'package:trezuno/core/theme/app_colors.dart';
import 'package:trezuno/core/theme/app_typography.dart';
import 'package:trezuno/core/widgets/app_button.dart';

/// World-class Product Details Screen for Trezuno application.
class ProductDetailsScreen extends StatefulWidget {
  static const routeName = '/product-details';

  final String productId;

  const ProductDetailsScreen({
    required this.productId,
    super.key,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  late Product _product;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    final samples = Product.sampleProducts();
    _product = samples.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => Product(
        id: widget.productId,
        productName: 'Sample Product',
        category: 'Electronics',
        purchaseDate: DateTime.now().subtract(const Duration(days: 90)),
        warrantyDurationMonths: 12,
        notes: 'Official manufacturer warranty included with receipt.',
        storeName: 'Apple Flagship Store',
        serialNumber: 'SN-9988-2234-11',
      ),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _deleteProduct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product and its warranty record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(context);
              context.go('/products');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _product.warrantyStatus == 'Active'
        ? AppColors.success
        : _product.warrantyStatus == 'Expiring Soon'
            ? AppColors.warning
            : AppColors.danger;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_product.productName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/products'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => context.go('/add-product'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            tooltip: 'Delete',
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeInAnimation,
        builder: (context, child) => FadeTransition(
          opacity: _fadeInAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Header Banner / Image
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _product.productImage != null
                        ? Image.file(
                            File(_product.productImage!),
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.devices_rounded, size: 64, color: statusColor),
                                const SizedBox(height: 12),
                                Text(
                                  _product.productName,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Status Banner Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_rounded, color: statusColor, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Warranty Status: ${_product.warrantyStatus}',
                              style: AppTypography.titleSmall.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _product.remainingDays > 0
                                  ? '${_product.remainingDays} days remaining until expiration.'
                                  : 'This product warranty has expired.',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? Colors.white70 : AppColors.primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Information',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: _product.category ?? 'Electronics',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.store_outlined,
                        label: 'Store / Merchant',
                        value: _product.storeName ?? 'Not specified',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Serial Number',
                        value: _product.serialNumber ?? 'Not specified',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Purchase Date',
                        value: '${_product.purchaseDate.toLocal()}'.split(' ')[0],
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.timer_outlined,
                        label: 'Warranty Duration',
                        value: '${_product.warrantyDurationMonths} Months',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Notes Card
                if (_product.notes != null && _product.notes!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes & Remarks',
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _product.notes ?? '',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Action Buttons
                AppButton(
                  title: 'View Receipt / Invoice',
                  icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Receipt image opened successfully.')),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
