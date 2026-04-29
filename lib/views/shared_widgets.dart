import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final String? Function(String?)? validator;

  const CustomField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF2A3148), fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8D93A6)),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDisabled ? [Colors.grey.shade400, Colors.grey.shade400] : const [Color(0xFFFF4F69), Color(0xFFC76FB6)],
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 50,
            child: Center(
              child: isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String category;
  final int price;
  final double rating;
  final String image;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onCardTap;
  final bool isOwner;

  const ProductCard({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.image,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onEditTap,
    this.onDeleteTap,
    this.onCardTap,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Color(0xFFEDEEF2), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported_outlined, size: 40, color: Color(0xFF8A91A8)))),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: onFavoriteTap,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                      child: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: const Color(0xFFE94E92), size: 18),
                    ),
                  ),
                ),
                if (isOwner)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE94E92),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Your Item',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2B))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('\$$price', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFFE94E92))),
                    const Spacer(),
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                    const SizedBox(width: 2),
                    Text(rating.toStringAsFixed(1), style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF8A91A8), fontWeight: FontWeight.w600)),
                  ],
                ),
                if (isOwner) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: onEditTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE94E92).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Edit',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFE94E92), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: onDeleteTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Delete',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red.shade600, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1D2B))),
          const Spacer(),
          GestureDetector(
            onTap: onSeeAll,
            child: Text('See all', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFFE94E92), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
