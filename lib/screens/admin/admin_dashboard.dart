import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/services/auth/auth_service.dart';

class AdminPage extends StatefulWidget {
  static const String routeName = '/admin_dashboard';
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final authService = FirebaseAuthService();

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
            Text(
              'Quick Stats',
              style: GoogleFonts.sen(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Products',
                    '0',
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Orders',
                    '0',
                    Icons.shopping_cart,
                    Colors.green,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Users',
                    '0',
                    Icons.people,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Revenue',
                    '\$0',
                    Icons.attach_money,
                    Colors.purple,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Orders management coming soon!')),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User management coming soon!')),
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
}
