import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/product_model.dart';

/// Repository for managing persistent product storage using SharedPreferences.
class ProductRepository {
  static const String _storageKey = 'saved_trezuno_products_v2';

  static final ProductRepository instance = ProductRepository._internal();
  ProductRepository._internal();

  /// Get all saved products. If none exist, initializes with sample products.
  Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      final samples = Product.sampleProducts();
      await saveAllProducts(samples);
      return samples;
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((map) => Product.fromMap(map as Map<String, dynamic>)).toList();
    } catch (e) {
      return Product.sampleProducts();
    }
  }

  /// Save all products list
  Future<void> saveAllProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(products.map((p) => p.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  /// Add or update a product
  Future<void> saveProduct(Product product) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      products[index] = product;
    } else {
      products.insert(0, product);
    }
    await saveAllProducts(products);
  }

  /// Delete a product by id
  Future<void> deleteProduct(String id) async {
    final products = await getProducts();
    products.removeWhere((p) => p.id == id);
    await saveAllProducts(products);
  }

  /// Get product by id
  Future<Product?> getProductById(String id) async {
    final products = await getProducts();
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
