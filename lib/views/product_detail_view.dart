import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class ProductDetailView extends StatefulWidget {
  final Product product;

  const ProductDetailView({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = context.watch<AuthViewModel>();
    final productVM = context.read<ProductViewModel>();
    
    final isOwner = authVM.currentUser?.id == widget.product.sellerId;
    final currentUserId = authVM.currentUser?.id;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Material(
        color: const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close Button Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.product.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1D2B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEEF2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Product Image
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFEDEEF2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 60,
                        color: const Color(0xFF8A91A8),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Product Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE94E92).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.product.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFE94E92),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFC107)),
                            const SizedBox(width: 4),
                            Text(
                              widget.product.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1D2B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Price
                    Text(
                      '\$${widget.product.price}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE94E92),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description Title
                    if ((widget.product.description ?? '').isNotEmpty)
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1D2B),
                        ),
                      ),
                    
                    if ((widget.product.description ?? '').isNotEmpty)
                      const SizedBox(height: 8),
                    
                    // Full Description
                    if ((widget.product.description ?? '').isNotEmpty)
                      Text(
                        widget.product.description ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5A6078),
                          height: 1.5,
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Owner Badge
                    if (isOwner)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE94E92).withValues(alpha: 0.15),
                          border: Border.all(color: const Color(0xFFE94E92)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Your Item - You can edit or delete this product',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFE94E92),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    
                    if (!isOwner)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8A91A8).withValues(alpha: 0.1),
                          border: Border.all(color: const Color(0xFF8A91A8)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'View Only - You can only view this product',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8A91A8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Favorite Button (for non-owners)
                    if (!isOwner)
                      InkWell(
                        onTap: currentUserId != null
                            ? () {
                                setState(() => _isFavorite = !_isFavorite);
                                productVM.toggleFavorite(widget.product.id);
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isFavorite
                                ? const Color(0xFFE94E92)
                                : const Color(0xFFE94E92).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE94E92),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _isFavorite
                                    ? Colors.white
                                    : const Color(0xFFE94E92),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isFavorite ? 'Added to Favorites' : 'Add to Favorites',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: _isFavorite
                                      ? Colors.white
                                      : const Color(0xFFE94E92),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Edit & Delete Buttons (for owners)
                    if (isOwner) ...[
                      InkWell(
                        onTap: () {
                          Navigator.pop(context, 'edit');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE94E92).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE94E92),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.edit_rounded,
                                color: Color(0xFFE94E92),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Edit Product',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFE94E92),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context, 'delete');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.delete_rounded,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete Product',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
