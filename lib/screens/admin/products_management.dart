import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shop/model/product_model.dart';
import 'package:shop/screens/admin/add_edit_product.dart';
import 'package:shop/services/store/firestore_service.dart';

class ProductsManagementPage extends StatefulWidget {
  static const String routeName = '/admin/products';
  const ProductsManagementPage({super.key});

  @override
  State<ProductsManagementPage> createState() => _ProductsManagementPageState();
}

class _ProductsManagementPageState extends State<ProductsManagementPage> {
  final FirestoreService firestoreService = FirestoreService();
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String selectedCategory = 'All';
  String selectedBrand = 'All';
  final TextEditingController searchController = TextEditingController();

  List<String> categories = ['All'];
  List<String> brands = ['All'];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    try {
      setState(() {
        isLoading = true;
      });

      log('Fetching all products for admin management...');
      final fetchedProducts = await firestoreService.getProducts();

      // Extract unique categories and brands
      Set<String> categorySet = {'All'};
      Set<String> brandSet = {'All'};

      for (var product in fetchedProducts) {
        if (product.category.isNotEmpty) categorySet.add(product.category);
        if (product.brand.isNotEmpty) brandSet.add(product.brand);
      }

      setState(() {
        products = fetchedProducts;
        filteredProducts = fetchedProducts;
        categories = categorySet.toList()..sort();
        brands = brandSet.toList()..sort();
        isLoading = false;
      });

      log('Loaded ${products.length} products for management');
    } catch (e) {
      log('Error fetching products: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterProducts() {
    setState(() {
      filteredProducts = products.where((product) {
        final matchesCategory =
            selectedCategory == 'All' || product.category == selectedCategory;
        final matchesBrand =
            selectedBrand == 'All' || product.brand == selectedBrand;
        final matchesSearch =
            searchController.text.isEmpty ||
            product.name.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ) ||
            product.description.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ) ||
            product.id.toLowerCase().contains(
              searchController.text.toLowerCase(),
            );
        return matchesCategory && matchesBrand && matchesSearch;
      }).toList();
    });
  }

  Future<void> _deleteProduct(Product product) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Product',
          style: GoogleFonts.sen(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
          style: GoogleFonts.sen(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.sen()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.sen()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await firestoreService.deleteProduct(product.id);

        setState(() {
          products.removeWhere((p) => p.id == product.id);
          _filterProducts();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product "${product.name}" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        log('Error deleting product: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting product: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditProductPage()),
    );

    if (result == true) {
      _fetchProducts(); // Refresh the list
    }
  }

  Future<void> _navigateToEditProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductPage(product: product),
      ),
    );

    if (result == true) {
      _fetchProducts(); // Refresh the list
    }
  }

  Future<void> _toggleProductStock(Product product) async {
    try {
      await firestoreService.updateProductStock(product.id, !product.inStock);

      setState(() {
        final index = products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          products[index] = Product(
            id: product.id,
            name: product.name,
            description: product.description,
            image: product.image,
            price: product.price,
            oldPrice: product.oldPrice,
            discount: product.discount,
            rate: product.rate,
            reviewsCount: product.reviewsCount,
            category: product.category,
            brand: product.brand,
            inStock: !product.inStock,
            tags: product.tags,
            createdAt: product.createdAt,
            updatedAt: DateTime.now(),
            variations: product.variations,
          );
        }
        _filterProducts();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Product ${product.inStock ? 'marked as out of stock' : 'marked as in stock'}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      log('Error updating product stock: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating stock: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Products Management',
          style: GoogleFonts.sen(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fetchProducts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Products',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Product',
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, description, or ID',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              _filterProducts();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _filterProducts(),
                ),
                const SizedBox(height: 12),
                // Filters Row
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category:',
                            style: GoogleFonts.sen(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            items: categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  style: GoogleFonts.sen(fontSize: 12.sp),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                              _filterProducts();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Brand Filter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Brand:',
                            style: GoogleFonts.sen(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          DropdownButton<String>(
                            value: selectedBrand,
                            isExpanded: true,
                            items: brands.map((brand) {
                              return DropdownMenuItem(
                                value: brand,
                                child: Text(
                                  brand,
                                  style: GoogleFonts.sen(fontSize: 12.sp),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedBrand = value!;
                              });
                              _filterProducts();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatCard(
                  'Total Products',
                  products.length.toString(),
                  Icons.inventory,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'In Stock',
                  products.where((p) => p.inStock).length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Out of Stock',
                  products.where((p) => !p.inStock).length.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Products List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64.r,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No products found',
                          style: GoogleFonts.sen(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (selectedCategory != 'All' ||
                            selectedBrand != 'All' ||
                            searchController.text.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedCategory = 'All';
                                selectedBrand = 'All';
                                searchController.clear();
                              });
                              _filterProducts();
                            },
                            child: Text(
                              'Clear Filters',
                              style: GoogleFonts.sen(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.r),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.sen(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.sen(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final hasDiscount = product.discount != null && product.discount! > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.image,
                    width: 60.w,
                    height: 60.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60.w,
                        height: 60.w,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported, size: 30.r),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: GoogleFonts.sen(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Stock Status
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: product.inStock
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: product.inStock
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              product.inStock ? 'In Stock' : 'Out of Stock',
                              style: GoogleFonts.sen(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: product.inStock
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: GoogleFonts.sen(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Price
                          Text(
                            '\$${product.price}',
                            style: GoogleFonts.sen(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 8),
                            Text(
                              '\$${product.oldPrice}',
                              style: GoogleFonts.sen(
                                fontSize: 12.sp,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product.discount!.toInt()}% OFF',
                              style: GoogleFonts.sen(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Category: ${product.category}',
                            style: GoogleFonts.sen(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Brand: ${product.brand}',
                            style: GoogleFonts.sen(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToEditProduct(product),
                    icon: Icon(Icons.edit, size: 16.r),
                    label: Text(
                      'Edit',
                      style: GoogleFonts.sen(fontSize: 12.sp),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleProductStock(product),
                    icon: Icon(
                      product.inStock ? Icons.visibility_off : Icons.visibility,
                      size: 16.r,
                    ),
                    label: Text(
                      product.inStock ? 'Mark Out' : 'Mark In',
                      style: GoogleFonts.sen(fontSize: 12.sp),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteProduct(product),
                    icon: Icon(Icons.delete, size: 16.r),
                    label: Text(
                      'Delete',
                      style: GoogleFonts.sen(fontSize: 12.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
