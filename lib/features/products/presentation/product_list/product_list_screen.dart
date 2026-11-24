import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trezuno/features/products/domain/product_model.dart';
import 'package:trezuno/core/router/app_router.dart';
import 'package:trezuno/core/theme/app_colors.dart';
import 'package:trezuno/core/theme/app_typography.dart';

/// Products Screen - displays all saved products.
///
/// Features:
/// - List and grid presentation
/// - Search products
/// - Filter by warranty status
/// - Filter by category
/// - Sort by expiration date
/// - Sort by purchase date
/// - Empty states
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
  String? _selectedFilter;
  String? _selectedSort;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  // Sample products for demonstration
  late final List<Product> _allProducts;
  late final List<Product> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _searchController = TextEditingController();
    _initializeProducts();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Initialize sample products for demonstration
  void _initializeProducts() {
    _allProducts = Product.sampleProducts();
    _filteredProducts = List.from(_allProducts);
  }

  /// Filter and sort the products list based on current selections
  void _applyFiltersAndSort() {
    setState(() {
      _filteredProducts = List.from(_allProducts);

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        _filteredProducts = _filteredProducts.where((product) {
          return product.productName.toLowerCase().contains(query) ||
              (product.notes?.toLowerCase().contains(query) ?? false) ||
              (product.storeName?.toLowerCase().contains(query) ?? false) ||
              (product.serialNumber?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      // Apply category filter
      if (_selectedFilter != null) {
        _filteredProducts = _filteredProducts.where((product) {
          return product.category == _selectedFilter ||
              _selectedFilter == 'All';
        }).toList();
      }

      // Apply sorting
      _filteredProducts.sort((a, b) {
        switch (_selectedSort) {
          case 'expiration':
            return a.remainingDays!.compareTo(b.remainingDays!);
          case 'purchase':
            return a.purchaseDate.compareTo(b.purchaseDate);
          case 'name':
            return a.productName.compareTo(b.productName);
          case 'status':
            return a.warrantyStatus.compareTo(b.warrantyStatus);
          default:
            return 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _applyFiltersAndSort();

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
                  // Search and filters header
                  _buildSearchAndFilters(),

                  const SizedBox(height: 24),

                  // Products list
                  _buildProductsList(),

                  const Spacer(),

                  // Floating action button for adding product
                  _buildFab(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Build the app bar with title and filters
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFF182635),
      title: const Text('Products'),
      actions: [
        // Add button
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add Product',
          onPressed: () => context.go('/products/add'),
        ),
      ],
    );
  }

  /// Build the search and filters bar
  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
              _applyFiltersAndSort();
            });
          },
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),

        // Filters row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Category filter button
              _FilterButton(
                isSelected: _selectedFilter == null || _selectedFilter == 'All',
                label: 'All',
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? null : 'All';
                    _applyFiltersAndSort();
                  });
                },
              ),
              const SizedBox(width: 8),

              // Status filter buttons
              _FilterButton(
                isSelected: _selectedFilter == 'Expiring Soon',
                label: 'Expiring',
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? 'Expiring Soon' : null;
                    _applyFiltersAndSort();
                  });
                },
              ),
              const SizedBox(width: 8),

              _FilterButton(
                isSelected: _selectedFilter == 'Expired',
                label: 'Expired',
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? 'Expired' : null;
                    _applyFiltersAndSort();
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Sort dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedSort,
          decoration: InputDecoration(
            hintText: 'Sort by',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(value: 'name', child: Text('Name')),
            DropdownMenuItem(value: 'expiration', child: Text('Expiration')),
            DropdownMenuItem(value: 'purchase', child: Text('Purchase Date')),
            DropdownMenuItem(value: 'status', child: Text('Status')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedSort = value;
              _applyFiltersAndSort();
            });
          },
        ),
      ],
    );
  }

  /// Build the products list view
  Widget _buildProductsList() {
    if (_filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        const Text(
          'My Products',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF182635),
          ),
        ),
        const SizedBox(height: 16),

        // Grid view of products
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 140,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _filteredProducts.length,
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return _ProductCard(product: product);
          },
        ),
      ],
    );
  }

  /// Build empty state when no products match the filters
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_outlined,
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
            onPressed: () => context.go('/products/add'),
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

  /// Build the floating action button
  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => context.go('/products/add'),
      backgroundColor: const Color(0xFF315C81),
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }
}

/// Filter chip/button widget
class _FilterButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<_FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<_FilterButton> {
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        widget.label,
        style: TextStyle(
          color: widget.isSelected
              ? const Color(0xFF315C81)
              : const Color(0xFF8291A0),
          fontWeight: widget.isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      selected: widget.isSelected,
      onSelected: widget.onSelected,
      backgroundColor: const Color(0xFFF5F7FA),
      checkmarkColor: const Color(0xFF315C81),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}

/// Product card widget
class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name
            Text(
              product.productName,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 8),

            // Warranty status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.warrantyStatus,
                    style: AppTypography.bodySmall.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                // Expiration days
                Text(
                  '${product.remainingDays}d',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF8291A0),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Product details
            Row(
              children: [
                // Category chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9B86E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.category ?? 'Other',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFFE9B86E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                // More info arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: const Color(0xFF78909C),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (product.warrantyStatus) {
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
}

/// Extension on Product list for sample data
extension ProductExtensions on List<Product> {
  /// Creates a list of sample products for demonstration.
  static List<Product> sampleProducts(int count) {
    final categories = ['Smartphones', 'Laptops', 'Tablets', 'TVs', 'Appliances'];
    final now = DateTime.now();

    return List.generate(count, (index) => Product(
      productName: 'Product ${index + 1}',
      category: categories[index % categories.length],
      purchaseDate: now.subtract(Duration(days: index * 30)),
      warrantyDurationMonths: 12 + (index % 6) * 6,
    ));
  }
}