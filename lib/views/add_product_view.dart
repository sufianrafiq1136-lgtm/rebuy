import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_viewmodel.dart';
import 'shared_widgets.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _ratingController;
  late TextEditingController _imageController;
  late TextEditingController _descriptionController;

  String _selectedCategory = 'Electronics';
  final List<String> _categories = ['Electronics', 'Fashion', 'Furniture', 'Books', 'Sports'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _categoryController = TextEditingController();
    _priceController = TextEditingController();
    _ratingController = TextEditingController(text: '5.0');
    _imageController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<ProductViewModel>().addProduct(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        price: int.parse(_priceController.text),
        rating: double.parse(_ratingController.text),
        image: _imageController.text.trim(),
        description: _descriptionController.text.trim(),
      ).then((_) {
        final viewModel = context.read<ProductViewModel>();
        if (viewModel.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
          // Wait a moment for Firestore to sync
          Future.delayed(const Duration(milliseconds: 500)).then((_) {
            viewModel.refreshProducts();
            Navigator.pop(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${viewModel.error}')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('Add Product', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1D2B))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF3A3F52)),
          onPressed: () => Navigator.pop(context),
        ),
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
                  const SizedBox(height: 16),
                  Text(
                    'Select Category *',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1A1D2B)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(colors: [Color(0xFFFF4F69), Color(0xFFC76FB6)])
                                : null,
                            color: isSelected ? null : const Color(0xFFEDEEF2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFE94E92) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected ? Colors.white : const Color(0xFF5A6078),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
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
                    label: 'Add Product',
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
