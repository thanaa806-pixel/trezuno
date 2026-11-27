import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:trezuno/features/products/domain/product_model.dart';
import 'package:trezuno/features/products/data/product_repository.dart';
import 'package:trezuno/core/theme/app_colors.dart';
import 'package:trezuno/core/theme/app_typography.dart';
import 'package:trezuno/core/widgets/app_button.dart';
import 'package:trezuno/core/widgets/app_text_field.dart';

/// World-class Professional Add / Edit Product Screen for Trezuno.
class AddProductScreen extends StatefulWidget {
  static const routeName = '/products/add';

  final Product? existingProduct;

  const AddProductScreen({
    super.key,
    this.existingProduct,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _productNameController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _notesController = TextEditingController();

  late AnimationController _animationController;

  String? _selectedCategory;
  DateTime _selectedPurchaseDate = DateTime.now();
  int _selectedWarrantyMonths = 12;
  bool _isSaving = false;

  File? _productImageFile;
  File? _receiptImageFile;

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

  final List<int> _warrantyOptions = [3, 6, 12, 24, 36, 48];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    if (widget.existingProduct != null) {
      final p = widget.existingProduct!;
      _productNameController.text = p.productName;
      _storeNameController.text = p.storeName ?? '';
      _serialNumberController.text = p.serialNumber ?? '';
      _notesController.text = p.notes ?? '';
      _selectedCategory = p.category;
      _selectedPurchaseDate = p.purchaseDate;
      _selectedWarrantyMonths = p.warrantyDurationMonths;
      if (p.productImage != null) _productImageFile = File(p.productImage!);
      if (p.receiptImage != null) _receiptImageFile = File(p.receiptImage!);
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _storeNameController.dispose();
    _serialNumberController.dispose();
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final product = Product(
        id: widget.existingProduct?.id,
        productName: _productNameController.text.trim(),
        category: _selectedCategory ?? 'Electronics',
        purchaseDate: _selectedPurchaseDate,
        warrantyDurationMonths: _selectedWarrantyMonths,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        storeName: _storeNameController.text.trim().isNotEmpty ? _storeNameController.text.trim() : null,
        serialNumber: _serialNumberController.text.trim().isNotEmpty ? _serialNumberController.text.trim() : null,
        receiptImage: _receiptImageFile?.path,
        productImage: _productImageFile?.path,
      );

      // Persist to local repository
      await ProductRepository.instance.saveProduct(product);

      if (!mounted) return;
      context.go('/products');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving product: $e'), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickProductImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _productImageFile = File(picked.path));
    }
  }

  Future<void> _pickReceiptImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _receiptImageFile = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingProduct != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Warranty' : 'Add New Warranty'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/products'),
        ),
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Picker Card
                _buildImagePickerCard(isDark, surfaceColor),
                const SizedBox(height: 24),

                // Section: Product Information
                Text(
                  'Product Details',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Product Name*',
                        hintText: 'e.g., iPhone 15 Pro, MacBook Pro',
                        controller: _productNameController,
                        prefixIcon: const Icon(Icons.devices_rounded, color: AppColors.primary),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Product name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      // Category Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category*',
                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            dropdownColor: surfaceColor,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Select category',
                              prefixIcon: const Icon(Icons.category_rounded, color: AppColors.primary),
                              filled: true,
                              fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                              ),
                            ),
                            items: _categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val),
                            validator: (val) => val == null ? 'Please select a category' : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Store / Merchant',
                        hintText: 'e.g., Apple Store, Amazon',
                        controller: _storeNameController,
                        prefixIcon: const Icon(Icons.store_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Serial Number',
                        hintText: 'e.g., SN-99882234',
                        controller: _serialNumberController,
                        prefixIcon: const Icon(Icons.confirmation_number_rounded, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Warranty Information
                Text(
                  'Warranty & Purchase',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      // Purchase Date Picker Field
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedPurchaseDate,
                            firstDate: DateTime(2015),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => _selectedPurchaseDate = picked);
                        },
                        child: AbsorbPointer(
                          child: AppTextField(
                            label: 'Purchase Date*',
                            hintText: '${_selectedPurchaseDate.toLocal()}'.split(' ')[0],
                            controller: TextEditingController(
                              text: '${_selectedPurchaseDate.toLocal()}'.split(' ')[0],
                            ),
                            prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Warranty Duration selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Warranty Duration',
                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _warrantyOptions.map((months) {
                              final isSelected = _selectedWarrantyMonths == months;
                              return ChoiceChip(
                                label: Text('$months Months'),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _selectedWarrantyMonths = months),
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                ),
                                backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Receipt & Notes
                Text(
                  'Receipt & Notes',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      // Receipt image upload
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _receiptImageFile != null ? 'Receipt Attached ✓' : 'Attach Receipt / Invoice',
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _pickReceiptImage,
                            icon: const Icon(Icons.upload_file_rounded, size: 18),
                            label: Text(_receiptImageFile != null ? 'Change' : 'Upload'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Additional Notes',
                        hintText: 'Add store warranty details or remarks...',
                        controller: _notesController,
                        maxLines: 3,
                        prefixIcon: const Icon(Icons.note_alt_rounded, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                AppButton(
                  title: isEditing ? 'Update Warranty' : 'Save Warranty',
                  isLoading: _isSaving,
                  onPressed: _saveProduct,
                ),
                const SizedBox(height: 16),
                AppButton(
                  title: 'Cancel',
                  isOutlined: true,
                  onPressed: () => context.go('/products'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildImagePickerCard(bool isDark, Color surfaceColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _productImageFile != null
                ? Image.file(
                    _productImageFile!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.secondary),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add product photo',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _pickProductImage,
            icon: const Icon(Icons.photo_library_rounded),
            label: Text(_productImageFile == null ? 'Select Product Photo' : 'Change Photo'),
          ),
        ],
      ),
    );
  }
}
