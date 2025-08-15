import 'package:flutter/material.dart';
import 'package:shop/screens/admin/admin_page.dart';
import 'package:shop/services/admin_service.dart';

class AdminAccessWidget extends StatelessWidget {
  const AdminAccessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AdminService.isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return FloatingActionButton(
            mini: true,
            backgroundColor: Colors.deepPurple,
            onPressed: () async {
              try {
                await AdminService.requireAdminAccess();
                Navigator.pushNamed(context, AdminPage.routeName);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Admin access required'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 20,
            ),
            heroTag: "admin_access",
          );
        }
        return SizedBox.shrink(); // Hide if not admin
      },
    );
  }
}

class AdminGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminGuard({Key? key, required this.child, this.fallback})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AdminService.isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        }

        return fallback ??
            Scaffold(
              appBar: AppBar(title: Text('Access Denied')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Admin Access Required',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You need admin privileges to access this page.',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
      },
    );
  }
}
