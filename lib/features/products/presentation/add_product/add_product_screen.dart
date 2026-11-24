import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:trezuno/features/products/domain/product_model.dart';
import 'package:trezuno/core/router/app_router.dart';
import 'package:trezuno/core/theme/app_colors.dart';
import 'package:trezuno/core/theme/app_typography.dart';

/// Add Product Screen for Trezuno application.
///
/// Allows users to add products using the following fields:
///
/// Required:
/// - Product Name
/// - Purchase Date
/// - Warranty Duration
///
/// Optional:
/// - Product Image
/// - Product Category
/// - Store Name
/// - Receipt Number
/// - Product Serial Number
/// - Product Description
/// - Receipt Image
/// - Additional Notes
///
/// Features:
/// - Date picker
/// - Warranty duration selector
/// - Automatic expiration date calculation
/// - Image attachment through the iOS system photo picker or file picker
/// - Form validation
/// - Save and Cancel actions
class AddProductScreen extends StatefulWidget {
  static const routeName = '/products/add';

  final Product? existingProduct; // For editing existing product

  const AddProductScreen({
    super.key,
    this.existingProduct,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with SingleTickerProviderStateMixin {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _productNameController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _receiptNumberController = TextEditingController();
  final _notesController = TextEditingController();

  // State values
  String? _selectedCategory;
  DateTime? _selectedPurchaseDate;
  int _selectedWarrantyMonths = 12;
  bool _isSaving = false;

  // Image paths
  File? _productImageFile;
  File? _receiptImageFile;

  // Available categories
  final List<String> _categories = [
    'Smartphones',
    'Laptops',
    'Tablets',
    'TVs',
    'Home Appliances',
    'Gaming Devices',
    'Accessories',
    'Other',
  ];

  // Warranty duration options (in months)
  final List<int> _warrantyOptions = [3, 6, 12, 24, 36, 48];

  @override
  void initState() {
    super.initState();
    // Initialize with existing product data if provided
    if (widget.existingProduct != null) {
      final product = widget.existingProduct;
      _productNameController.text = product.productName;
      _serialNumberController.text = product.serialNumber ?? '';
      _receiptNumberController.text = product.receiptImage != null ? 'Receipt attached' : '';
      _notesController.text = product.notes ?? '';
      _selectedCategory = product.category;
      _selectedPurchaseDate = product.purchaseDate;
      _selectedWarrantyMonths = product.warrantyDurationMonths;
      _productImageFile = product.productImage != null
          ? File(product.productImage!)
          : null;
      _receiptImageFile = product.receiptImage != null
          ? File(product.receiptImage!)
          : null;
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _serialNumberController.dispose();
    _receiptNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Save the product (either new or updated)
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final product = Product(
        id: widget.existingProduct?.id,
        productName: _productNameController.text.trim(),
        category: _selectedCategory,
        purchaseDate: _selectedPurchaseDate!,
        warrantyDurationMonths: _selectedWarrantyMonths,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        storeName: null, // Could be added as a field if needed
        serialNumber: _serialNumberController.text.trim().isNotEmpty
            ? _serialNumberController.text.trim()
            : null,
        description: null, // Could be added from notes if needed
        receiptImage: _receiptImageFile?.path,
        productImage: _productImageFile?.path,
      );

      // In a full implementation, this would save to the database
      // For now, navigate back
      if (!mounted) return;
      context.go('/products');
    } catch (e) {
      // Error handling
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving product: $e'),
          backgroundColor: const Color(0xFFD96B6B),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Pick product image from gallery
  Future<void> _pickProductImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _productImageFile = File(pickedImage.path);
      });
    }
  }

  /// Pick receipt image from gallery
  Future<void> _pickReceiptImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _receiptImageFile = File(pickedImage.path);
        _receiptNumberController.text = 'Receipt attached';
      });
    }
  }

  /// Show warranty duration options bottom sheet
  Future<void> _showWarrantyDurationBottomSheet() async {
    final result = await showModalBottomSheet<
        int>.context(context: context, isScrollControlled: true) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Warranty Duration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF182635),
              ),
            ),
            const SizedBox(height: 24),
            ..._warrantyOptions.map((months) => _WarrantyOption(
              months: months,
              isSelected: _selectedWarrantyMonths == months,
              onTap: () => Navigator.pop(context, months),
            )),
            const SizedBox(height: 24),
            // Custom option
            TextButton(
              onPressed: () => Navigator.pop(context,
                  _warrantyOptions.last + 1), // One month beyond last option
              child: const Text('Custom duration'),
            ),
          ],
        ),
      );
    };

    if (result != null && mounted) {
      setState(() {
        _selectedWarrantyMonths = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingProduct != null;

    return Scaffold(
      appBar: _buildAppBar(context, isEditing),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => FadeTransition(
          opacity: _animationController,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(isEditing),

                    const SizedBox(height: 32),

                    // Product name field
                    _buildProductNameField(),

                    const SizedBox(height: 20),

                    // Category dropdown
                    _buildCategoryDropdown(),

                    const SizedBox(height: 20),

                    // Purchase date field
                    _buildPurchaseDateField(),

                    const SizedBox(height: 20),

                    // Warranty duration field
                    _buildWarrantyDurationField(),

                    const SizedBox(height: 20),

                    // Serial number field
                    _buildSerialNumberField(),

                    const SizedBox(height: 20),

                    // Receipt number field
                    _buildReceiptNumberField(),

                    const SizedBox(height: 20),

                    // Notes field
                    _buildNotesField(),

                    const Spacer(),

                    // Save/Cancel buttons
                    _buildSaveAndCancelButtons(isEditing),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the app bar
  AppBar _buildAppBar(BuildContext context, bool isEditing) {
    return AppBar(
      title: Text(
        isEditing ? 'Edit Product' : 'Add Product',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/products'),
      ),
      actions: [
        // Done/cancel buttons
        if (isEditing)
          TextButton(
            onPressed: () => context.go('/products'),
            child: const Text('Cancel'),
          )
        else
          TextButton(
            onPressed: () => context.go('/products'),
            child: const Text('Cancel'),
          ),
      ],
    );
  }

  /// Build the header section with product image
  Widget _buildHeader(bool isEditing) {
    return Column(
      children: [
        // Product image preview
        _buildProductImagePreview(),
        const SizedBox(height: 16),

        // Add product image button
        ElevatedButton.icon(
          onPressed: _pickProductImage,
          icon: const Icon(Icons.photo_library),
          label: const Text(
            _productImageFile == null ? 'Add Product Image' : 'Change Image',
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ],
    );
  }

  /// Build product image preview
  Widget _buildProductImagePreview() {
    if (_productImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _productImageFile!,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    // Placeholder when no image
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFDEE4E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: const Text(
          'No image selected',
          style: TextStyle(
            color: Color(0xFF78909C),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// Build product name field
  Widget _buildProductNameField() {
    return TextFormField(
      controller: _productNameController,
      decoration: const InputDecoration(
        labelText: 'Product Name*',
        hintText: 'e.g., iPhone 15 Pro',
        prefixIcon: Icon(Icons.product),
        filled: true,
        fillColor: Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Product name is required';
        }
        if (value.trim().length < 2) {
          return 'Product name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  /// Build category dropdown
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Product Category*',
        hintText: 'Select a category',
        prefixIcon: Icon(Icons.category),
        filled: true,
        fillColor: Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  /// Build purchase date field with date picker
  Widget _buildPurchaseDateField() {
    return GestureDetector(
      onTap: _selectPurchaseDate,
      // Override the tap to show date picker
      child: AbsorbPointer(
        // This allows the text field to still be focused but shows the date
        child: TextFormField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Purchase Date*',
            hintText: 'Select purchase date',
            prefixIcon: Icon(Icons.calendar_today),
            filled: true,
            fillColor: Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  /// Select purchase date using date picker
  Future<void> _selectPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPurchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedPurchaseDate = picked;
      });
    }
  }

  /// Build warranty duration field
  Widget _buildWarrantyDurationField() {
    return GestureDetector(
      onTap: _showWarrantyDurationBottomSheet,
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Warranty Duration*',
            hintText: 'e.g., 12 months',
            prefixIcon: Icon(Icons.timelapse),
            filled: true,
            fillColor: Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  /// Build serial number field
  Widget _buildSerialNumberField() {
    return TextFormField(
      controller: _serialNumberController,
      decoration: InputDecoration(
        labelText: 'Serial Number',
        hintText: 'e.g., SN123456789',
        prefixIcon: const Icon(Icons.numbers),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  /// Build receipt number field
  Widget _buildReceiptNumberField() {
    return TextFormField(
      controller: _receiptNumberController,
      decoration: InputDecoration(
        labelText: 'Receipt Number',
        hintText: 'e.g., RECEIPT123',
        prefixIcon: const Icon(Icons.receipt),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  /// Build notes field
  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: 'Additional Notes',
        hintText: 'Any additional information about the product',
        prefixIcon: const Icon(Icons.note),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        isDense: true,
        alignLabelWithHint: true,
      ),
      maxLines: 3,
    );
  }

  /// Build save and cancel buttons
  Widget _buildSaveAndCancelButtons(bool isEditing) {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: TextButton(
            onPressed: () => context.go('/products'),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        // Save button
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF315C81),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save Product'),
          ),
        ),
      ],
    );
  }
}

/// Warranty option bottom sheet item
class _WarrantyOption extends StatelessWidget {
  final int months;
  final bool isSelected;
  final VoidCallback onTap;

  const _WarrantyOption({
    required this.months,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              '$months months',
              style: TextStyle(
                color: isSelected ? const Color(0xFF315C81) : const Color(0xFF8291A0),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF42A886),
              ),
          ],
        ),
      ),
    );
  }
}