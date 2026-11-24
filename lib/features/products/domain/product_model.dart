import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Model representing a product warranty entry.
@immutable
class Product {
  /// Unique identifier for the product.
  final String id;

  /// Name of the product (required).
  final String productName;

  /// Category of the product (optional).
  final String? category;

  /// Date when the product was purchased (required).
  final DateTime purchaseDate;

  /// Warranty duration in months (required).
  final int warrantyDurationMonths;

  /// Additional notes about the product (optional).
  final String? notes;

  /// Store name where the product was purchased (optional).
  final String? storeName;

  /// Product serial number (optional).
  final String? serialNumber;

  /// Additional description about the product (optional).
  final String? description;

  /// Receipt image path or identifier (optional).
  final String? receiptImage;

  /// Product image path or identifier (optional).
  final String? productImage;

  /// Calculated warranty expiration date.
  DateTime get expirationDate {
    return purchaseDate.add(Duration(days: warrantyDurationMonths * 30));
  }

  /// Returns the remaining warranty days from the current date.
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(expirationDate)) {
      return 0; // Expired
    }
    return expirationDate.difference(now).inDays;
  }

  /// Gets the warranty status based on the current date.
  String get warrantyStatus {
    if (remainingDays <= 0) return 'Expired';
    if (remainingDays <= 30) return 'Expiring Soon';
    return 'Active';
  }

  /// Human-readable expiration date string.
  String get expirationDateText {
    return DateFormat('MMMM dd, yyyy', 'en').format(expirationDate);
  }

  /// Creates a new [Product] instance.
  Product({
    String? id,
    required this.productName,
    this.category,
    required this.purchaseDate,
    required this.warrantyDurationMonths,
    this.notes,
    this.storeName,
    this.serialNumber,
    this.description,
    this.receiptImage,
    this.productImage,
  }) : id = id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}_${productName.hashCode}';

  /// Creates a copy of this [Product] with the given fields replaced.
  Product copyWith({
    String? id,
    String? productName,
    String? category,
    DateTime? purchaseDate,
    int? warrantyDurationMonths,
    String? notes,
    String? storeName,
    String? serialNumber,
    String? description,
    String? receiptImage,
    String? productImage,
  }) {
    return Product(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyDurationMonths: warrantyDurationMonths ?? this.warrantyDurationMonths,
      notes: notes ?? this.notes,
      storeName: storeName ?? this.storeName,
      serialNumber: serialNumber ?? this.serialNumber,
      description: description ?? this.description,
      receiptImage: receiptImage ?? this.receiptImage,
      productImage: productImage ?? this.productImage,
    );
  }

  /// Returns a human-readable string for the warranty duration.
  String get warrantyDurationText {
    if (warrantyDurationMonths <= 0) return 'Lifetime';
    final years = warrantyDurationMonths ~/ 12;
    final months = warrantyDurationMonths % 12;
    if (years > 0 && months > 0) {
      return '$years years, $months months';
    }
    if (years > 0) {
      return '$years years';
    }
    return '$months months';
  }

  /// Returns a formatted purchase date string.
  String get purchaseDateText {
    return DateFormat('MMMM dd, yyyy', 'en').format(purchaseDate);
  }

  /// Sample products for initial states and preview
  static List<Product> sampleProducts() {
    final now = DateTime.now();
    return [
      Product(
        id: 'sample_1',
        productName: 'iPhone 15 Pro',
        category: 'Smartphones',
        purchaseDate: now.subtract(const Duration(days: 60)),
        warrantyDurationMonths: 24,
        storeName: 'Apple Store',
        serialNumber: 'APL-15P-9921',
        notes: 'Includes AppleCare+ coverage',
      ),
      Product(
        id: 'sample_2',
        productName: 'MacBook Pro 16"',
        category: 'Laptops',
        purchaseDate: now.subtract(const Duration(days: 345)),
        warrantyDurationMonths: 12,
        storeName: 'Authorized Reseller',
        serialNumber: 'MBP-16-4402',
        notes: 'Expiring soon',
      ),
      Product(
        id: 'sample_3',
        productName: 'Sony WH-1000XM5',
        category: 'Accessories',
        purchaseDate: now.subtract(const Duration(days: 420)),
        warrantyDurationMonths: 12,
        storeName: 'Electronics Store',
        serialNumber: 'SNY-WH-8812',
        notes: 'Expired warranty',
      ),
    ];
  }

  /// JSON serialization support.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'category': category,
      'purchaseDate': purchaseDate.toIso8601String(),
      'warrantyDurationMonths': warrantyDurationMonths,
      'notes': notes,
      'storeName': storeName,
      'serialNumber': serialNumber,
      'description': description,
      'receiptImage': receiptImage,
      'productImage': productImage,
    };
  }

  /// JSON deserialization support.
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String?,
      productName: (map['productName'] as String?) ?? 'Product',
      category: map['category'] as String?,
      purchaseDate: DateTime.tryParse(map['purchaseDate'] as String? ?? '') ?? DateTime.now(),
      warrantyDurationMonths: (map['warrantyDurationMonths'] as num?)?.toInt() ?? 12,
      notes: map['notes'] as String?,
      storeName: map['storeName'] as String?,
      serialNumber: map['serialNumber'] as String?,
      description: map['description'] as String?,
      receiptImage: map['receiptImage'] as String?,
      productImage: map['productImage'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
