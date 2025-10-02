import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shop/services/store/firestore_service.dart';

class UserManagementPage extends StatefulWidget {
  static const String routeName = '/admin/users';
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final FirestoreService firestoreService = FirestoreService();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  String selectedRole = 'All';
  final TextEditingController searchController = TextEditingController();

  final List<String> userRoles = ['All', 'user', 'admin'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      setState(() {
        isLoading = true;
      });

      log('Fetching all users for admin management...');
      final snapshot = await firestoreService.firestore
          .collection('users')
          .get();

      final fetchedUsers = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        users = fetchedUsers;
        filteredUsers = fetchedUsers;
        isLoading = false;
      });

      log('Loaded ${users.length} users for management');
    } catch (e) {
      log('Error fetching users: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterUsers() {
    setState(() {
      filteredUsers = users.where((user) {
        final matchesRole =
            selectedRole == 'All' || user['role'] == selectedRole;
        final matchesSearch =
            searchController.text.isEmpty ||
            (user['name'] ?? '').toLowerCase().contains(
              searchController.text.toLowerCase(),
            ) ||
            (user['email'] ?? '').toLowerCase().contains(
              searchController.text.toLowerCase(),
            );
        return matchesRole && matchesSearch;
      }).toList();
    });
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await firestoreService.firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update local state
      setState(() {
        final userIndex = users.indexWhere((user) => user['id'] == userId);
        if (userIndex != -1) {
          users[userIndex]['role'] = newRole;
        }
        _filterUsers();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User role updated to $newRole'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      log('Error updating user role: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleUserStatus(String userId, bool isActive) async {
    try {
      await firestoreService.firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update local state
      setState(() {
        final userIndex = users.indexWhere((user) => user['id'] == userId);
        if (userIndex != -1) {
          users[userIndex]['isActive'] = isActive;
        }
        _filterUsers();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ${isActive ? 'activated' : 'deactivated'}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      log('Error updating user status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getUserOrdersCount(String userId) async {
    try {
      final orders = await firestoreService.firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'User Orders',
              style: GoogleFonts.sen(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'This user has ${orders.docs.length} orders',
              style: GoogleFonts.sen(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: GoogleFonts.sen()),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      log('Error fetching user orders: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching orders: $e'),
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
          'User Management',
          style: GoogleFonts.sen(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fetchUsers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Users',
          ),
        ],
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
                    hintText: 'Search by name or email',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              _filterUsers();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _filterUsers(),
                ),
                const SizedBox(height: 12),
                // Role Filter
                Row(
                  children: [
                    Text(
                      'Filter by Role:',
                      style: GoogleFonts.sen(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedRole,
                        isExpanded: true,
                        items: userRoles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                              role,
                              style: GoogleFonts.sen(fontSize: 14.sp),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                          _filterUsers();
                        },
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
                  'Total Users',
                  users.length.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Admins',
                  users.where((u) => u['role'] == 'admin').length.toString(),
                  Icons.admin_panel_settings,
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Active',
                  users.where((u) => u['isActive'] != false).length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Users List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64.r,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No users found',
                          style: GoogleFonts.sen(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (selectedRole != 'All' ||
                            searchController.text.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedRole = 'All';
                                searchController.clear();
                              });
                              _filterUsers();
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
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserCard(user);
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

  Widget _buildUserCard(Map<String, dynamic> user) {
    final userId = user['id'] ?? 'Unknown';
    final name = user['name'] ?? 'Unknown User';
    final email = user['email'] ?? 'No email';
    final role = user['role'] ?? 'user';
    final isActive = user['isActive'] ?? true;
    final createdAt = user['createdAt'];
    final profileImage = user['profileImage'];

    // Parse date
    String dateStr = 'Unknown Date';
    if (createdAt != null) {
      try {
        DateTime date;
        if (createdAt is String) {
          date = DateTime.parse(createdAt);
        } else {
          date = createdAt.toDate();
        }
        dateStr = DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        dateStr = createdAt.toString();
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage: profileImage != null
                      ? NetworkImage(profileImage)
                      : null,
                  child: profileImage == null
                      ? Icon(Icons.person, size: 24.r)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.sen(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: role == 'admin'
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: role == 'admin'
                                    ? Colors.orange.withOpacity(0.3)
                                    : Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              role.toUpperCase(),
                              style: GoogleFonts.sen(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: role == 'admin'
                                    ? Colors.orange
                                    : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        email,
                        style: GoogleFonts.sen(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Indicator
                Container(
                  width: 12.r,
                  height: 12.r,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // User Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User ID: ${userId.length > 15 ? userId.substring(0, 15) + '...' : userId}',
                        style: GoogleFonts.sen(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Joined: $dateStr',
                        style: GoogleFonts.sen(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Status: ${isActive ? 'Active' : 'Inactive'}',
                        style: GoogleFonts.sen(
                          fontSize: 11.sp,
                          color: isActive ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // View Orders Button
                    IconButton(
                      onPressed: () => _getUserOrdersCount(userId),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      tooltip: 'View Orders',
                      iconSize: 20.r,
                    ),
                    // Actions Menu
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 20.r),
                      onSelected: (action) {
                        switch (action) {
                          case 'make_admin':
                            _updateUserRole(userId, 'admin');
                            break;
                          case 'make_user':
                            _updateUserRole(userId, 'user');
                            break;
                          case 'activate':
                            _toggleUserStatus(userId, true);
                            break;
                          case 'deactivate':
                            _toggleUserStatus(userId, false);
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        List<PopupMenuEntry<String>> items = [];

                        // Role change options
                        if (role != 'admin') {
                          items.add(
                            PopupMenuItem<String>(
                              value: 'make_admin',
                              child: Text(
                                'Make Admin',
                                style: GoogleFonts.sen(),
                              ),
                            ),
                          );
                        }
                        if (role != 'user') {
                          items.add(
                            PopupMenuItem<String>(
                              value: 'make_user',
                              child: Text(
                                'Make User',
                                style: GoogleFonts.sen(),
                              ),
                            ),
                          );
                        }

                        // Status change options
                        if (!isActive) {
                          items.add(
                            PopupMenuItem<String>(
                              value: 'activate',
                              child: Text(
                                'Activate User',
                                style: GoogleFonts.sen(),
                              ),
                            ),
                          );
                        } else {
                          items.add(
                            PopupMenuItem<String>(
                              value: 'deactivate',
                              child: Text(
                                'Deactivate User',
                                style: GoogleFonts.sen(),
                              ),
                            ),
                          );
                        }

                        return items;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
