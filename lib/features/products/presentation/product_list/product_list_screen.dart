import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:trezuno/features/products/domain/product_model.dart';
import 'package:trezuno/features/products/data/product_repository.dart';
import 'package:trezuno/core/theme/app_colors.dart';
import 'package:trezuno/core/theme/app_typography.dart';
import 'package:trezuno/core/constants/app_constants.dart';

/// Professional Products Screen - displays all saved products with filter chips & search.
class ProductsScreen extends StatefulWidget {
  static const routeName = '/products';

  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'expiration';
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'All',
    ...AppConstants.productCategories,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _searchController = TextEditingController();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await ProductRepository.instance.getProducts();
    if (mounted) {
      setState(() {
        _allProducts = products;
        _filterProducts();
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    _filteredProducts = _allProducts.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.storeName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (product.category?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    // Sort
    _filteredProducts.sort((a, b) {
      if (_selectedSort == 'expiration') {
        return a.remainingDays.compareTo(b.remainingDays);
      } else if (_selectedSort == 'name') {
        return a.productName.compareTo(b.productName);
      } else {
        return b.purchaseDate.compareTo(a.purchaseDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Sort Options',
            onPressed: _showSortBottomSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AnimatedBuilder(
              animation: _fadeInAnimation,
              builder: (context, child) => FadeTransition(
                opacity: _fadeInAnimation,
                child: Column(
                  children: [
                    // Search Bar & Filters
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                                _filterProducts();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search products, stores, serials...',
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                          _filterProducts();
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Category Horizontal Chips
                          SizedBox(
                            height: 42,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                final isSelected = _selectedCategory == category;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(category),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedCategory = category;
                                        _filterProducts();
                                      });
                                    },
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                    ),
                                    backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Product Count Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${_filteredProducts.length} items',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showSortBottomSheet,
                            icon: const Icon(Icons.sort_rounded, size: 16),
                            label: Text(
                              _selectedSort == 'expiration'
                                  ? 'Sort: Expiration'
                                  : _selectedSort == 'name'
                                      ? 'Sort: Name'
                                      : 'Sort: Newest',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Products List
                    Expanded(
                      child: _filteredProducts.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                return _buildProductCard(context, product, isDark);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-product'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, bool isDark) {
    final statusColor = product.warrantyStatus == 'Active'
        ? AppColors.success
        : product.warrantyStatus == 'Expiring Soon'
            ? AppColors.warning
            : AppColors.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => context.go('/product-details/${product.id}'),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.devices_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.category ?? "Electronics"} • ${product.storeName ?? "Store"}',
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            product.remainingDays > 0
                                ? '${product.remainingDays} days remaining'
                                : 'Warranty Expired',
                            style: AppTypography.bodySmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.warrantyStatus,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideY(begin: 0.05, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your search or category filter.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort Products',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.timer_outlined, color: AppColors.primary),
                title: const Text('Warranty Expiration'),
                trailing: _selectedSort == 'expiration' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _selectedSort = 'expiration');
                  _filterProducts();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha_rounded, color: AppColors.primary),
                title: const Text('Product Name'),
                trailing: _selectedSort == 'name' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _selectedSort = 'name');
                  _filterProducts();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                title: const Text('Purchase Date (Newest)'),
                trailing: _selectedSort == 'newest' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _selectedSort = 'newest');
                  _filterProducts();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
