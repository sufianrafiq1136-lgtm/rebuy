import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/product_model.dart';
import '../services/firebase_product_service.dart';

class ProductViewModel extends ChangeNotifier {
  final FirebaseProductService _productService = FirebaseProductService();

  List<Product> _filteredProducts = [];
  List<Product> _allProducts = []; // Keeps all products including user's own
  List<Product> _favoriteProducts = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String? _userId;
  
  // Stream subscriptions
  StreamSubscription<List<Product>>? _productsSubscription;
  StreamSubscription<List<Product>>? _favoritesSubscription;

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _allProducts; // Returns all products for "My Ads" view
  List<Product> get favorites => _favoriteProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => _productService.categories;

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  void listenToProducts() {
    _isLoading = true;
    notifyListeners();

    // Cancel previous subscription if it exists
    _productsSubscription?.cancel();

    try {
      if (_selectedCategory == 'All') {
        _productsSubscription = _productService.getProductsStream().listen(
          (products) {
            // Store all products including user's own
            _allProducts = products;
            // Exclude current user's products from main feed only
            _filteredProducts = products.where((p) => p.sellerId != _userId).toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _error = 'Failed to load products: $error';
            _isLoading = false;
            notifyListeners();
          },
        );
      } else {
        _productsSubscription = _productService.getProductsByCategoryStream(_selectedCategory).listen(
          (products) {
            // Store all products including user's own
            _allProducts = products;
            // Exclude current user's products from main feed only
            _filteredProducts = products.where((p) => p.sellerId != _userId).toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _error = 'Failed to load category: $error';
            _isLoading = false;
            notifyListeners();
          },
        );
      }
    } catch (e) {
      _error = 'Failed to listen to products: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String category) async {
    _selectedCategory = category;
    _isLoading = true;
    notifyListeners();

    // Cancel previous subscription if it exists
    _productsSubscription?.cancel();

    try {
      _productsSubscription = _productService.getProductsByCategoryStream(category).listen(
        (products) {
          // Store all products including user's own
          _allProducts = products;
          // Exclude current user's products from main feed only
          _filteredProducts = products.where((p) => p.sellerId != _userId).toList();
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Failed to load category: $error';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Failed to select category: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    try {
      if (query.isEmpty) {
        listenToProducts();
      } else {
        final results = await _productService.searchProducts(query);
        // Exclude current user's products from search results
        _filteredProducts = results.where((p) => p.sellerId != _userId).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String productId) async {
    if (_userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      await _productService.toggleFavorite(productId, _userId!);

      // Update in filtered list
      final index = _filteredProducts.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _filteredProducts[index] = _filteredProducts[index]
            .copyWith(isFavorite: !_filteredProducts[index].isFavorite);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to update favorite: ${e.toString()}';
      notifyListeners();
    }
  }

  void listenToFavorites(String userId) {
    // Cancel previous subscription if it exists
    _favoritesSubscription?.cancel();

    try {
      _favoritesSubscription = _productService.getFavoritesStream(userId).listen(
        (favorites) {
          _favoriteProducts = favorites;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Failed to load favorites: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Failed to listen to favorites: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  Future<void> addProduct({
    required String name,
    required String category,
    required int price,
    required double rating,
    required String image,
    String? description,
  }) async {
    if (_userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      _error = null; // Clear any previous errors
      final error = await _productService.addProduct(
        name: name,
        category: category,
        price: price,
        rating: rating,
        image: image,
        sellerId: _userId!,
        description: description,
      );

      if (error != null) {
        _error = error;
      } else {
        _error = null; // Clear error on success
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add product: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> updateProduct({
    required String productId,
    String? name,
    String? category,
    int? price,
    double? rating,
    String? image,
    String? description,
  }) async {
    if (_userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      final error = await _productService.updateProduct(
        productId: productId,
        sellerId: _userId!,
        name: name,
        category: category,
        price: price,
        rating: rating,
        image: image,
        description: description,
      );

      if (error != null) {
        _error = error;
        notifyListeners();
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update product: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    if (_userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      final error = await _productService.deleteProduct(
        productId: productId,
        sellerId: _userId!,
      );

      if (error != null) {
        _error = error;
        notifyListeners();
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete product: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  bool isProductOwner(String sellerId) {
    return _userId == sellerId;
  }

  /// Refresh products immediately without waiting for stream
  Future<void> refreshProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final products = await _productService.getProductsStream().first;
      _allProducts = products;
      
      if (_selectedCategory == 'All') {
        _filteredProducts = products.where((p) => p.sellerId != _userId).toList();
      } else {
        _filteredProducts = products
            .where((p) => p.sellerId != _userId && p.category == _selectedCategory)
            .toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh products: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
}

