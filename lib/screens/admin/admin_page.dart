import 'package:flutter/material.dart';
import 'package:shop/widgets/custom_button.dart';
import 'package:shop/widgets/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPage extends StatefulWidget {
  static const String routeName = '/admin';
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  bool _loading = false;

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final supabase = Supabase.instance.client;

    // Use provided id or generate one based on timestamp
    final id = _idController.text.trim().isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : _idController.text.trim();

    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();
    final double? price = double.tryParse(_priceController.text.trim());
    final String imageUrl = _imageUrlController.text.trim();
    final String category = _categoryController.text.trim();
    final double? rate = double.tryParse(_rateController.text.trim());
    final String createdAt = DateTime.now().toIso8601String();

    final Map<String, dynamic> product = {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'created_at': createdAt,
      'category': category,
      'rate': rate,
    };

    try {
      final res = await supabase.from('products').insert(product).select();

      if (res.isNotEmpty) {
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: const SnackBar(content: Text('Product created successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product created successfully')),
        );
        _formKey.currentState!.reset();
        _clearControllers();
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _clearControllers() {
    _idController.clear();
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _categoryController.clear();
    _rateController.clear();
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ID (optional - will be generated if empty)
                CustomTextField(
                  controller: _idController,
                  labelText: 'ID (optional)',
                  icon: Icons.code,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Name',
                  icon: Icons.text_fields,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _priceController,
                  labelText: 'Price',
                  icon: Icons.price_check,
                ),

                const SizedBox(height: 12),
                CustomTextField(
                  controller: _imageUrlController,
                  labelText: 'Image URL',
                  icon: Icons.image,
                ),

                const SizedBox(height: 12),
                CustomTextField(
                  controller: _categoryController,
                  labelText: 'Category',
                  icon: Icons.category,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _rateController,
                  labelText: 'Rate',
                  icon: Icons.star,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null) return 'Enter a valid number';
                    if (parsed < 0 || parsed > 5) return 'Rate 0 - 5';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  onTap: _loading ? null : _submitProduct,
                  title: 'Add Product',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
