import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'product_detail_view.dart';
import 'edit_product_view.dart';

class MyAdsView extends StatefulWidget {
  const MyAdsView({super.key});

  @override
  State<MyAdsView> createState() => _MyAdsViewState();
}

class _MyAdsViewState extends State<MyAdsView> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('My Ads', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1D2B))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF3A3F52)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<ProductViewModel, AuthViewModel>(
        builder: (context, productVM, authVM, _) {
          final userId = authVM.currentUser?.id;
          
          // Get all products by current user from allProducts (which includes user's own)
          final myProducts = productVM.allProducts.where((p) => p.sellerId == userId).toList();
          
          // Get unique categories from my products
          final categories = {'All', ...myProducts.map((p) => p.category)};
          
          // Filter by selected category
          final filteredProducts = _selectedCategory == 'All'
              ? myProducts
              : myProducts.where((p) => p.category == _selectedCategory).toList();

          return Column(
            children: [
              // Category Filter
              SizedBox(
                height: 45,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = categories.toList()[i];
                    final selected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? const LinearGradient(colors: [Color(0xFFFF4F69), Color(0xFFC76FB6)])
                              : null,
                          color: selected ? null : const Color(0xFFEDEEF2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cat,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : const Color(0xFF5A6078),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Products List
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              _selectedCategory == 'All'
                                  ? 'No ads yet'
                                  : 'No ads in $_selectedCategory',
                              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF8A91A8)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final product = filteredProducts[i];
                          return _MyAdCard(
                            product: product,
                            onTap: () async {
                              final result = await showDialog<String>(
                                context: context,
                                builder: (_) => ProductDetailView(product: product),
                              );
                              if (result == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProductView(product: product),
                                  ),
                                ).then((_) => setState(() {}));
                              } else if (result == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Ad'),
                                    content: const Text('Are you sure you want to delete this ad?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          productVM.deleteProduct(product.id);
                                        },
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProductView(product: product),
                                ),
                              ).then((_) => setState(() {}));
                            },
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Ad'),
                                  content: const Text('Are you sure you want to delete this ad?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        productVM.deleteProduct(product.id);
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MyAdCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _MyAdCard({
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            // Image
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFEDEEF2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Color(0xFF8A91A8),
                    ),
                  ),
                ),
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1D2B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE94E92).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product.category,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFFE94E92),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                                const SizedBox(width: 2),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF8A91A8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${product.price}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE94E92),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: onEdit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE94E92).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.edit_rounded, size: 16, color: Color(0xFFE94E92)),
                                const SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFFE94E92),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                                const SizedBox(width: 4),
                                Text(
                                  'Delete',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
