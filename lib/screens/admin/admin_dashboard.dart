import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/model/product_model.dart';
import 'package:shop/screens/admin/orders_management.dart';
import 'package:shop/screens/admin/user_management.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/services/auth/auth_service.dart';
import 'package:shop/services/store/firestore_service.dart';

class AdminPage extends StatefulWidget {
  static const String routeName = '/admin_dashboard';
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final authService = FirebaseAuthService();
  final firestoreService = FirestoreService();
  List<Product> products = [];
  bool isLoading = true;
  String productsCount = '0';
  int ordersCount = 0;
  int usersCount = 0;
  double totalRevenue = 0.0;
  Map<String, double> revenueStats = {};

  Future<void> _ensureAdminRole() async {
    try {
      // Check if current user has admin role in Firestore
      final userDoc = await firestoreService.firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        log(
          'Admin Dashboard: User document does not exist, creating admin user...',
        );
        // Create admin user document
        await firestoreService.firestore
            .collection('users')
            .doc(currentUser.uid)
            .set({
              'uid': currentUser.uid,
              'email': currentUser.email,
              'displayName': currentUser.displayName ?? 'Admin',
              'role': 'admin', // Set as admin
              'createdAt': DateTime.now().toIso8601String(),
            });
        log('Admin Dashboard: Created admin user document');
      } else {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData['role'] != 'admin') {
          log('Admin Dashboard: Updating user role to admin...');
          // Update user role to admin
          await firestoreService.firestore
              .collection('users')
              .doc(currentUser.uid)
              .update({'role': 'admin'});
          log('Admin Dashboard: Updated user role to admin');
        }
      }
    } catch (e) {
      log('Admin Dashboard: Error ensuring admin role: $e');
      throw e;
    }
  }

  void _fetchStats() async {
    try {
      setState(() {
        isLoading = true;
      });

      log('Admin Dashboard: Ensuring admin role...');
      await _ensureAdminRole();

      log('Admin Dashboard: Debugging orders data...');
      await firestoreService.debugOrdersData();

      log('Admin Dashboard: Fetching stats from Firestore...');

      // Fetch all stats concurrently
      final results = await Future.wait([
        firestoreService.getProducts(),
        firestoreService.getOrdersCount(),
        firestoreService.getTotalUsers(),
        firestoreService.getTotalRevenue(),
        firestoreService.getRevenueStats(),
      ]);

      final products = results[0] as List<Product>;
      final ordersCount = results[1] as int;
      final usersCount = results[2] as int;
      final totalRevenue = results[3] as double;
      final revenueStats = results[4] as Map<String, double>;

      log(
        'Admin Dashboard: Found ${products.length} products, $ordersCount orders, $usersCount users, \$${totalRevenue.toStringAsFixed(2)} revenue',
      );

      setState(() {
        this.products = products;
        this.productsCount = products.length.toString();
        this.ordersCount = ordersCount;
        this.usersCount = usersCount;
        this.totalRevenue = totalRevenue;
        this.revenueStats = revenueStats;
        isLoading = false;
      });
    } catch (e) {
      log('Admin Dashboard: Error fetching stats: $e');
      setState(() {
        isLoading = false;
      });

      // Show detailed error to user
      String errorMessage = 'Error loading dashboard stats';
      if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage =
            'Permission denied. Please ensure you have admin access and try again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage\n\nTap refresh to retry.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Refresh',
              textColor: Colors.white,
              onPressed: _fetchStats,
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch stats after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.sen(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        centerTitle: true,
        leading: Icon(
          Icons.admin_panel_settings,
          color: Colors.brown,
          size: 30,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await authService.signOut();
              Navigator.pushReplacementNamed(context, LoginPage.routeName);
            },
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Admin!',
                            style: GoogleFonts.sen(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.titleLarge?.color,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            currentUser.email ?? 'admin@example.com',
                            style: GoogleFonts.sen(
                              fontSize: 14.sp,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Text(
                  'Quick Stats',
                  style: GoogleFonts.sen(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                Spacer(),
                IconButton(onPressed: _fetchStats, icon: Icon(Icons.refresh)),
              ],
            ),
            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Products',
                    productsCount,
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Orders',
                    isLoading
                        ? '...'
                        : (ordersCount == -1 ? 'N/A' : ordersCount.toString()),
                    Icons.shopping_cart,
                    Colors.green,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Users',
                    isLoading ? '...' : usersCount.toString(),
                    Icons.people,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showRevenueDetails(),
                    child: _buildStatCard(
                      context,
                      'Revenue',
                      isLoading
                          ? '...'
                          : '\$${totalRevenue.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.purple,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Management Options
            Text(
              'Management',
              style: GoogleFonts.sen(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            SizedBox(height: 12),

            _buildManagementOption(
              context,
              'Manage Products',
              'Add, edit, or remove products',
              Icons.inventory_2,
              Colors.blue,
              () {
                // Navigate to product management
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product management coming soon!')),
                );
              },
            ),

            _buildManagementOption(
              context,
              'View Orders',
              'Monitor and process orders',
              Icons.receipt_long,
              Colors.green,
              () {
                // Navigate to orders management
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrdersManagementPage(),
                  ),
                );
              },
            ),

            _buildManagementOption(
              context,
              'User Management',
              'View and manage user accounts',
              Icons.people_outline,
              Colors.orange,
              () {
                // Navigate to user management
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementPage(),
                  ),
                );
              },
            ),

            _buildManagementOption(
              context,
              'Analytics',
              'View sales and performance analytics',
              Icons.analytics,
              Colors.purple,
              () {
                // Navigate to analytics
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Analytics coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.sen(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.sen(
                fontSize: 12.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.sen(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.sen(
            fontSize: 12.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }

  void _showRevenueDetails() {
    if (revenueStats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revenue data not available yet')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Revenue Breakdown',
            style: GoogleFonts.sen(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRevenueDetailRow(
                  'Total Revenue',
                  '\$${(revenueStats['total'] ?? 0.0).toStringAsFixed(2)}',
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildRevenueDetailRow(
                  'Today\'s Revenue',
                  '\$${(revenueStats['today'] ?? 0.0).toStringAsFixed(2)}',
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildRevenueDetailRow(
                  'Monthly Revenue',
                  '\$${(revenueStats['monthly'] ?? 0.0).toStringAsFixed(2)}',
                  Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  'Note: Only completed/delivered orders are included',
                  style: GoogleFonts.sen(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.sen(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRevenueDetailRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: GoogleFonts.sen(fontSize: 14.sp)),
        ),
        Text(
          value,
          style: GoogleFonts.sen(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
