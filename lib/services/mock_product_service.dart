import '../models/product_model.dart';

class MockProductService {
  static final MockProductService _instance = MockProductService._internal();

  late List<Product> _allProducts;

  factory MockProductService() {
    return _instance;
  }

  MockProductService._internal() {
    _initializeProducts();
  }

  void _initializeProducts() {
    _allProducts = [
      Product(
        id: 'p1',
        name: 'iPhone 13',
        category: 'Electronics',
        price: 549,
        rating: 4.5,
        image: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300&h=300&fit=crop',
        sellerId: 'seller1',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Used iPhone 13 in excellent condition',
      ),
      Product(
        id: 'p2',
        name: 'Nike Air Max',
        category: 'Fashion',
        price: 89,
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300&h=300&fit=crop',
        sellerId: 'seller2',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Nike Air Max 90 - Original',
      ),
      Product(
        id: 'p3',
        name: 'Wooden Desk',
        category: 'Furniture',
        price: 120,
        rating: 4.2,
        image: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=300&h=300&fit=crop',
        sellerId: 'seller3',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        description: 'Solid oak wood desk',
      ),
      Product(
        id: 'p4',
        name: 'Samsung TV 55"',
        category: 'Electronics',
        price: 399,
        rating: 4.6,
        image: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=300&h=300&fit=crop',
        sellerId: 'seller4',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Samsung 55 inch 4K TV',
      ),
      Product(
        id: 'p5',
        name: 'Leather Jacket',
        category: 'Fashion',
        price: 75,
        rating: 4.3,
        image: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=300&h=300&fit=crop',
        sellerId: 'seller5',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        description: 'Black leather jacket',
      ),
      Product(
        id: 'p6',
        name: 'Office Chair',
        category: 'Furniture',
        price: 95,
        rating: 4.7,
        image: 'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=300&h=300&fit=crop',
        sellerId: 'seller1',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        description: 'Ergonomic office chair',
      ),
      Product(
        id: 'p7',
        name: 'AirPods Pro',
        category: 'Electronics',
        price: 149,
        rating: 4.9,
        image: 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=300&h=300&fit=crop',
        sellerId: 'seller2',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Apple AirPods Pro with case',
      ),
      Product(
        id: 'p8',
        name: 'Running Shoes',
        category: 'Sports',
        price: 65,
        rating: 4.4,
        image: 'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=300&h=300&fit=crop',
        sellerId: 'seller3',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        description: 'Nike running shoes - size 10',
      ),
      Product(
        id: 'p9',
        name: 'MacBook Air M2',
        category: 'Electronics',
        price: 999,
        rating: 4.9,
        image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300&h=300&fit=crop',
        sellerId: 'seller4',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        description: 'MacBook Air M2 - nearly new',
      ),
      Product(
        id: 'p10',
        name: 'Yoga Mat Pro',
        category: 'Sports',
        price: 35,
        rating: 4.6,
        image: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=300&h=300&fit=crop',
        sellerId: 'seller5',
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        description: 'Premium yoga mat',
      ),
    ];
  }

  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _allProducts;
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (category.isEmpty || category == 'All') {
      return _allProducts;
    }
    return _allProducts.where((p) => p.category == category).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowerQuery = query.toLowerCase();
    return _allProducts
        .where((p) =>
            p.name.toLowerCase().contains(lowerQuery) ||
            p.category.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<Product?> getProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleFavorite(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _allProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = _allProducts[index];
      _allProducts[index] = product.copyWith(isFavorite: !product.isFavorite);
    }
  }

  Future<List<Product>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allProducts.where((p) => p.isFavorite).toList();
  }

  List<String> get categories =>
      ['All', 'Electronics', 'Fashion', 'Furniture', 'Books', 'Sports'];
}
