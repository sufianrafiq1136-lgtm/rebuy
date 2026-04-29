import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirebaseProductService {
  static final FirebaseProductService _instance = FirebaseProductService._internal();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirebaseProductService() {
    return _instance;
  }

  FirebaseProductService._internal();

  // Get all products as a stream
  Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => _productFromFirestore(doc)).toList();
        });
  }

  // Get products by category as a stream
  Stream<List<Product>> getProductsByCategoryStream(String category) {
    if (category == 'All') {
      return getProductsStream();
    }
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          final products = snapshot.docs.map((doc) => _productFromFirestore(doc)).toList();
          // Sort by createdAt on the client side to avoid needing a composite index
          products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return products;
        });
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore.collection('products').get();
      final lowerQuery = query.toLowerCase();
      
      return snapshot.docs
          .where((doc) {
            final name = (doc['name'] ?? '').toLowerCase();
            final category = (doc['category'] ?? '').toLowerCase();
            return name.contains(lowerQuery) || category.contains(lowerQuery);
          })
          .map((doc) => _productFromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Get single product
  Future<Product?> getProduct(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return _productFromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  // Add product
  Future<String?> addProduct({
    required String name,
    required String category,
    required int price,
    required double rating,
    required String image,
    required String sellerId,
    String? description,
  }) async {
    try {
      await _firestore.collection('products').add({
        'name': name,
        'category': category,
        'price': price,
        'rating': rating,
        'image': image,
        'sellerId': sellerId,
        'description': description ?? '',
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null; // Success
    } catch (e) {
      return 'Failed to add product: ${e.toString()}';
    }
  }

  // Update product (only seller can update)
  Future<String?> updateProduct({
    required String productId,
    required String sellerId,
    String? name,
    String? category,
    int? price,
    double? rating,
    String? image,
    String? description,
  }) async {
    try {
      // Verify seller owns this product
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists || doc['sellerId'] != sellerId) {
        return 'You can only edit your own products';
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (category != null) updateData['category'] = category;
      if (price != null) updateData['price'] = price;
      if (rating != null) updateData['rating'] = rating;
      if (image != null) updateData['image'] = image;
      if (description != null) updateData['description'] = description;

      await _firestore.collection('products').doc(productId).update(updateData);
      return null; // Success
    } catch (e) {
      return 'Failed to update product: ${e.toString()}';
    }
  }

  // Delete product (only seller can delete)
  Future<String?> deleteProduct({
    required String productId,
    required String sellerId,
  }) async {
    try {
      // Verify seller owns this product
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists || doc['sellerId'] != sellerId) {
        return 'You can only delete your own products';
      }

      await _firestore.collection('products').doc(productId).delete();
      return null; // Success
    } catch (e) {
      return 'Failed to delete product: ${e.toString()}';
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String productId, String userId) async {
    try {
      final userFavoritesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId);

      final doc = await userFavoritesRef.get();
      if (doc.exists) {
        await userFavoritesRef.delete();
      } else {
        await userFavoritesRef.set({'productId': productId});
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  // Get favorites stream for user
  Stream<List<Product>> getFavoritesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
          List<Product> favorites = [];
          for (var doc in snapshot.docs) {
            final productId = doc['productId'];
            final product = await getProduct(productId);
            if (product != null) {
              favorites.add(product.copyWith(isFavorite: true));
            }
          }
          return favorites;
        });
  }

  // Check if product is favorite
  Future<bool> isFavorite(String productId, String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get products by user
  Stream<List<Product>> getUserProductsStream(String userId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => _productFromFirestore(doc)).toList();
        });
  }

  // Helper method to convert Firestore document to Product
  Product _productFromFirestore(DocumentSnapshot doc) {
    return Product(
      id: doc.id,
      name: doc['name'] ?? '',
      category: doc['category'] ?? '',
      price: doc['price'] ?? 0,
      rating: (doc['rating'] ?? 0.0).toDouble(),
      image: doc['image'] ?? '',
      sellerId: doc['sellerId'] ?? '',
      description: doc['description'],
      isFavorite: doc['isFavorite'] ?? false,
      createdAt: doc['createdAt'] != null
          ? (doc['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  List<String> get categories =>
      ['All', 'Electronics', 'Fashion', 'Furniture', 'Books', 'Sports'];
}
