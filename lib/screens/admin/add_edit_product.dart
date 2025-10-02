import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/model/product_model.dart';
import 'package:shop/services/store/firestore_service.dart';

class AddEditProductPage extends StatefulWidget {
  final Product? product; // null for add, Product for edit

  static const String routeName = '/admin/add-edit-product';

  const AddEditProductPage({super.key, this.product});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final FirestoreService firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _oldPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _tagsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _inStock = true;
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _oldPriceController.text = product.oldPrice?.toString() ?? '';
    _discountController.text = product.discount?.toString() ?? '';
    _categoryController.text = product.category;
    _brandController.text = product.brand;
    _tagsController.text = product.tags.join(', ');
    _imageUrlController.text = product.image;
    _inStock = product.inStock;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _oldPriceController.dispose();
    _discountController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _tagsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      log('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse values
      final price = double.tryParse(_priceController.text) ?? 0;
      final oldPrice = _oldPriceController.text.isNotEmpty
          ? double.tryParse(_oldPriceController.text)
          : null;
      final discount = _discountController.text.isNotEmpty
          ? double.tryParse(_discountController.text)
          : null;

      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Use existing image URL or uploaded image
      String imageUrl = _imageUrlController.text;

      // If a new image is selected, you would upload it here
      // For now, we'll use the URL provided or keep the existing one
      if (_selectedImage != null) {
        // TODO: Implement image upload to Firebase Storage
        // For now, we'll use a placeholder
        log('Image selected but upload not implemented yet');
      }

      final product = Product(
        id: isEditing
            ? widget.product!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        image: imageUrl,
        price: price,
        oldPrice: oldPrice,
        discount: discount,
        rate: isEditing ? widget.product!.rate : 0.0,
        reviewsCount: isEditing ? widget.product!.reviewsCount : 0,
        category: _categoryController.text.trim(),
        brand: _brandController.text.trim(),
        inStock: _inStock,
        tags: tags,
        createdAt: isEditing ? widget.product!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        variations: isEditing ? widget.product!.variations : null,
      );

      if (isEditing) {
        await firestoreService.updateProduct(product);
      } else {
        await firestoreService.addProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Product ${isEditing ? 'updated' : 'added'} successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      log('Error saving product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          isEditing ? 'Edit Product' : 'Add New Product',
          style: GoogleFonts.sen(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _saveProduct,
              icon: const Icon(Icons.save),
              tooltip: 'Save Product',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Product Image Section
            _buildImageSection(),
            const SizedBox(height: 20),

            // Basic Information
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _nameController,
              label: 'Product Name',
              hint: 'Enter product name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Product name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter product description',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Pricing Section
            _buildSectionTitle('Pricing'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: 'Price (\$)',
                    hint: '0.00',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Price is required';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Enter valid price';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _oldPriceController,
                    label: 'Old Price (\$)',
                    hint: '0.00 (optional)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Enter valid old price';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _discountController,
              label: 'Discount (%)',
              hint: '0 (optional)',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final discount = double.tryParse(value);
                  if (discount == null || discount < 0 || discount > 100) {
                    return 'Enter valid discount (0-100)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Category & Brand Section
            _buildSectionTitle('Category & Brand'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _categoryController,
                    label: 'Category',
                    hint: 'e.g., Electronics',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Category is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _brandController,
                    label: 'Brand',
                    hint: 'e.g., Apple',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Brand is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Additional Information
            _buildSectionTitle('Additional Information'),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _tagsController,
              label: 'Tags',
              hint: 'tag1, tag2, tag3 (comma separated)',
            ),
            const SizedBox(height: 16),

            // Stock Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _inStock ? Icons.check_circle : Icons.cancel,
                      color: _inStock ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Product is ${_inStock ? 'in stock' : 'out of stock'}',
                        style: GoogleFonts.sen(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch(
                      value: _inStock,
                      onChanged: (value) {
                        setState(() {
                          _inStock = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'Update Product' : 'Add Product',
                        style: GoogleFonts.sen(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Image',
              style: GoogleFonts.sen(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Image URL Field
            _buildTextField(
              controller: _imageUrlController,
              label: 'Image URL',
              hint: 'https://example.com/image.jpg',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Image URL is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            Text(
              'OR',
              style: GoogleFonts.sen(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Image Picker Button
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text('Pick Image from Gallery', style: GoogleFonts.sen()),
            ),

            // Selected Image Preview
            if (_selectedImage != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ] else if (_imageUrlController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imageUrlController.text,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.sen(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
      style: GoogleFonts.sen(),
    );
  }
}
