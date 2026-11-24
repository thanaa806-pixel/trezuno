import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trezuno/features/products/domain/product_model.dart';
import 'package:trezuno/core/theme/app_typography.dart';

/// Product Details Screen for Trezuno application.
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
    // Try to find the product in sampleProducts or construct a default
    final samples = Product.sampleProducts();
    _product = samples.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => Product(
        id: widget.productId,
        productName: 'Sample Product',
        category: 'Electronics',
        purchaseDate: DateTime.now().subtract(const Duration(days: 90)),
        warrantyDurationMonths: 12,
        notes: 'Product warranty details',
        storeName: 'Official Store',
        serialNumber: 'SN-998822',
      ),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingDays = _product.remainingDays;
    final warrantyStatus = _product.warrantyStatus;

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
                  _buildProductImage(),
                  const SizedBox(height: 32),
                  _buildProductInfoSection(remainingDays, warrantyStatus),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(_product.productName),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/products'),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          onPressed: () => context.go('/add-product'),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Color(0xFFD96B6B)),
          tooltip: 'Delete',
          onPressed: _deleteProduct,
        ),
      ],
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Color(0xFFDEE4E8),
      ),
      child: _product.productImage != null
          ? Image.file(
              File(_product.productImage!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_outlined,
            size: 64,
            color: Color(0xFF78909C),
          ),
          const SizedBox(height: 12),
          Text(
            'No image',
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF78909C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoSection(int remainingDays, String warrantyStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _product.productName,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF182635),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor()),
              ),
              child: Text(
                warrantyStatus,
                style: AppTypography.bodySmall.copyWith(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                icon: Icons.category,
                label: 'Category',
                value: _product.category ?? 'General',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoRow(
                icon: Icons.shopping_bag,
                label: 'Purchase Date',
                value: _product.purchaseDateText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                icon: Icons.repeat,
                label: 'Warranty',
                value: _product.warrantyDurationText,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoRow(
                icon: Icons.numbers,
                label: 'Serial Number',
                value: _product.serialNumber ?? 'Not provided',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                icon: Icons.event,
                label: 'Expires',
                value: _product.expirationDateText,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoRow(
                icon: Icons.store,
                label: 'Store',
                value: _product.storeName ?? 'Not specified',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRemainingDays(remainingDays),
        if (_product.notes != null && _product.notes!.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildNotesSection(),
        ],
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF8291A0)),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF8291A0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingDays(int remainingDays) {
    Color statusColor;

    if (remainingDays <= 0) {
      statusColor = const Color(0xFFD96B6B);
    } else if (remainingDays <= 30) {
      statusColor = const Color(0xFFE8A64D);
    } else {
      statusColor = const Color(0xFF42A886);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForStatus(remainingDays),
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$remainingDays days remaining',
            style: AppTypography.titleMedium.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForStatus(int remainingDays) {
    if (remainingDays <= 0) return Icons.remove_circle_outline;
    if (remainingDays <= 30) return Icons.alarm;
    return Icons.calendar_today;
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEE4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.note,
                size: 16,
                color: Color(0xFF8291A0),
              ),
              SizedBox(width: 8),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF182635),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _product.notes!,
            style: AppTypography.bodyMedium.copyWith(
              color: const Color(0xFF182635),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/add-product'),
          icon: const Icon(Icons.edit),
          label: const Text('Edit Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF315C81),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _deleteProduct,
          icon: const Icon(Icons.delete, color: Color(0xFFD96B6B)),
          label: const Text('Delete Product', style: TextStyle(color: Color(0xFFD96B6B))),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFD96B6B)),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_product.warrantyStatus) {
      case 'Active':
        return const Color(0xFF42A886);
      case 'Expiring Soon':
        return const Color(0xFFE8A64D);
      case 'Expired':
        return const Color(0xFFD96B6B);
      default:
        return const Color(0xFF8291A0);
    }
  }

  Future<void> _deleteProduct() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text(
            'Are you sure you want to delete this product and all its associated data?\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD96B6B),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
          backgroundColor: Color(0xFF42A886),
        ),
      );
      context.go('/products');
    }
  }
}
