import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../viewmodels/product_viewmodel.dart';
import 'shared_widgets.dart';

class EditProductView extends StatefulWidget {
  final Product product;

  const EditProductView({super.key, required this.product});

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _ratingController;
  late TextEditingController _imageController;
  late TextEditingController _descriptionController;

  late String _selectedCategory;
  final List<String> _categories = ['Electronics', 'Fashion', 'Furniture', 'Books', 'Sports'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _ratingController = TextEditingController(text: widget.product.rating.toString());
    _imageController = TextEditingController(text: widget.product.image);
    _descriptionController = TextEditingController(text: widget.product.description ?? '');
    _selectedCategory = widget.product.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<ProductViewModel>().updateProduct(
        productId: widget.product.id,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        price: int.parse(_priceController.text),
        rating: double.parse(_ratingController.text),
        image: _imageController.text.trim(),
        description: _descriptionController.text.trim(),
      ).then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
          Navigator.pop(context);
        } else {
          final viewModel = context.read<ProductViewModel>();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${viewModel.error}')),
          );
        }
      });
    }
  }

  void _deleteProduct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProductViewModel>().deleteProduct(widget.product.id).then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted successfully!')),
                  );
                  Navigator.pop(context);
                } else {
                  final viewModel = context.read<ProductViewModel>();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${viewModel.error}')),
                  );
                }
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('Edit Product', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1D2B))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF3A3F52)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outlined, color: Colors.red),
            onPressed: _deleteProduct,
            tooltip: 'Delete product',
          ),
        ],
      ),
      body: Consumer<ProductViewModel>(
        builder: (context, productVM, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Details',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2B)),
                  ),
                  const SizedBox(height: 16),
                  CustomField(
                    controller: _nameController,
                    hint: 'Product Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter product name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE4E5EA)),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem(value: category, child: Text(category));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value ?? 'Electronics'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF2A3148), fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomField(
                    controller: _priceController,
                    hint: 'Price',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter price';
                      if (int.tryParse(value) == null) return 'Enter valid price';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomField(
                    controller: _ratingController,
                    hint: 'Rating (0-5)',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter rating';
                      final rating = double.tryParse(value);
                      if (rating == null || rating < 0 || rating > 5) return 'Rating must be 0-5';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomField(
                    controller: _imageController,
                    hint: 'Image URL',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter image URL';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Product Description (Optional)',
                      filled: true,
                      fillColor: const Color(0xFFF1F1F4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE4E5EA)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Update Product',
                    isLoading: productVM.isLoading,
                    onPressed: _submitForm,
                  ),
                  if (productVM.error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text(
                        productVM.error!,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
