import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/screens/admin/add_page.dart';
import 'package:shop/screens/admin/delete_page.dart';
import 'package:shop/screens/admin/edit_page.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/widgets/admin_access_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPage extends StatefulWidget {
  static const String routeName = '/admin';
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final supabase = Supabase.instance.client;
  List products = [];

  Future<void> fetchProducts() async {
    final response = await supabase.from('products').select().order('id');
    setState(() {
      products = response as List;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(child: _buildAdminContent(context));
  }

  Widget _buildAdminContent(BuildContext context) {
    // Enhanced color palette for vibrant UI
    List<List<Color>> cardGradients = [
      [Color(0xFF667eea), Color(0xFF764ba2)], // Purple to Blue
      [Color(0xFFf093fb), Color(0xFFf5576c)], // Pink to Red
      [Color(0xFF4facfe), Color(0xFF00f2fe)], // Blue to Cyan
      [Color(0xFF11998e), Color(0xFF38ef7d)], // Teal to Green
      [Color(0xFFfc466b), Color(0xFF3f5efb)], // Pink to Purple
      [Color(0xFFffcc70), Color(0xFFc850c0)], // Orange to Pink
    ];

    List<Color> emptySlotColors = [
      Color(0xFFe0e7ff), // Light purple
      Color(0xFFfce7f3), // Light pink
      Color(0xFFe0f2fe), // Light blue
      Color(0xFFecfdf5), // Light green
      Color(0xFFfef3f2), // Light orange
      Color(0xFFf9fafb), // Light gray
    ];

    // Background gradient colors
    List<Color> backgroundGradient = [
      Color(0xFF6a11cb),
      Color(0xFF2575fc),
      Color(0xFF667eea),
      Color(0xFF764ba2),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Header with animation
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Manage your products with style',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF10b981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF10b981).withOpacity(0.3),
                            offset: Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Handle logout
                          Navigator.pushReplacementNamed(
                            context,
                            LoginPage.routeName,
                          );
                        },
                        icon: Icon(Icons.logout),
                      ),
                    ),
                  ],
                ),
              ),

              // Products Grid with enhanced styling
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${products.length} Products',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: fetchProducts,
                          color: Colors.white,
                          backgroundColor: Color(0xFF667eea),
                          strokeWidth: 3,
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 20),
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: products.isEmpty ? 1 : products.length,
                            itemBuilder: (context, index) {
                              final product = products.isEmpty
                                  ? null
                                  : products[index];
                              final isProductEmpty = product == null;
                              final gradientIndex =
                                  index % cardGradients.length;
                              final emptyColorIndex =
                                  index % emptySlotColors.length;

                              return AnimatedContainer(
                                duration: Duration(
                                  milliseconds: 300 + (index * 100),
                                ),
                                margin: EdgeInsets.only(bottom: 16),
                                height: 200.h,
                                decoration: BoxDecoration(
                                  gradient: isProductEmpty
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            emptySlotColors[emptyColorIndex]
                                                .withOpacity(0.8),
                                            emptySlotColors[emptyColorIndex],
                                          ],
                                        )
                                      : LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: cardGradients[gradientIndex],
                                        ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isProductEmpty
                                          ? emptySlotColors[emptyColorIndex]
                                                .withOpacity(0.4)
                                          : cardGradients[gradientIndex][0]
                                                .withOpacity(0.4),
                                      offset: Offset(0, 12),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1.w,
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(18),
                                  child: Row(
                                    children: [
                                      // Product Info Section
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.25,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  isProductEmpty
                                                      ? Icons.add_box_outlined
                                                      : Icons
                                                            .shopping_bag_outlined,
                                                  color: isProductEmpty
                                                      ? Colors.grey[600]
                                                      : Colors.white,
                                                  size: 32,
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                product != null
                                                    ? product['name'] ??
                                                          'Unknown Product'
                                                    : 'Add Your First Product',
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.sp,
                                                  color: isProductEmpty
                                                      ? Colors.grey[700]
                                                      : Colors.white,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              if (product != null) ...[
                                                SizedBox(height: 8),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '\$${product['price'] ?? 'N/A'}',
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 16),

                                      // Action Buttons Section
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Add Button
                                            if (isProductEmpty)
                                              _buildActionButton(
                                                icon: Icons.add_circle_outline,
                                                color: Color(0xFF10b981),
                                                label: 'Add New',
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/add_product',
                                                  );
                                                },
                                              ),

                                            // Edit Button
                                            if (product != null)
                                              _buildActionButton(
                                                icon: Icons.edit_outlined,
                                                color: Color(0xFF3b82f6),
                                                label: 'Edit',
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          EditProductPage(
                                                            product: product,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),

                                            if (product != null)
                                              SizedBox(height: 12),

                                            // Delete Button
                                            if (product != null)
                                              _buildActionButton(
                                                icon: Icons.delete_outline,
                                                color: Color(0xFFef4444),
                                                label: 'Delete',
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          DeleteProductPage(
                                                            product: product,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Enhanced Bottom Section
              // Container(
              //   padding: EdgeInsets.all(20),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       GestureDetector(
              //         onTap: fetchProducts,
              //         child: Container(
              //           padding: EdgeInsets.symmetric(
              //             horizontal: 24,
              //             vertical: 14,
              //           ),
              //           decoration: BoxDecoration(
              //             gradient: LinearGradient(
              //               colors: [
              //                 Colors.white.withOpacity(0.25),
              //                 Colors.white.withOpacity(0.15),
              //               ],
              //             ),
              //             borderRadius: BorderRadius.circular(30),
              //             border: Border.all(
              //               color: Colors.white.withOpacity(0.3),
              //             ),
              //             boxShadow: [
              //               BoxShadow(
              //                 color: Colors.black.withOpacity(0.1),
              //                 offset: Offset(0, 8),
              //                 blurRadius: 20,
              //               ),
              //             ],
              //           ),
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.start,
              //             mainAxisSize: MainAxisSize.min,
              //             children: [
              //               Icon(
              //                 Icons.refresh_rounded,
              //                 color: Colors.white,
              //                 size: 22,
              //               ),
              //               SizedBox(width: 10.w),
              //               Text(
              //                 'Refresh Products',
              //                 style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 15.sp,
              //                   fontWeight: FontWeight.w600,
              //                   letterSpacing: 0.3,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AddProductPage.routeName);
        },
        backgroundColor: Color(0xFF10b981),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: Icon(Icons.add_rounded),
        label: Text('Quick Add', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: color.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
