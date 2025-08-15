import 'package:flutter/material.dart';
import 'package:shop/services/admin_service.dart';
import 'package:shop/utils/auth_utils.dart';

/// Debug widget to test admin functionality
class AdminDebugWidget extends StatefulWidget {
  const AdminDebugWidget({Key? key}) : super(key: key);

  @override
  State<AdminDebugWidget> createState() => _AdminDebugWidgetState();
}

class _AdminDebugWidgetState extends State<AdminDebugWidget> {
  String _debugInfo = '';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Debug Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(_debugInfo),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _checkCurrentAdminStatus,
                  child: Text('Check Admin Status'),
                ),
                ElevatedButton(
                  onPressed: _testAdminEmail,
                  child: Text('Test Admin Email'),
                ),
                ElevatedButton(
                  onPressed: _clearAdminStatus,
                  child: Text('Clear Admin'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkCurrentAdminStatus() async {
    try {
      bool isAdmin = await AdminService.isAdmin();
      String email = await AdminService.getCurrentUserEmail();
      bool hasAccess = await AuthUtils.hasAdminAccess();

      setState(() {
        _debugInfo =
            '''
Current Status:
- Is Admin: $isAdmin
- Email: $email
- Has Admin Access: $hasAccess
- Timestamp: ${DateTime.now()}
        ''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Error checking admin status: $e';
      });
    }
  }

  Future<void> _testAdminEmail() async {
    try {
      // Test with a known admin email
      String testEmail = 'ahmedrady03@gmail.com';
      bool result = await AdminService.checkAdminRoleSimple(testEmail);

      setState(() {
        _debugInfo =
            '''
Test Result for $testEmail:
- Is Admin: $result
- Test completed at: ${DateTime.now()}
        ''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Error testing admin email: $e';
      });
    }
  }

  Future<void> _clearAdminStatus() async {
    try {
      await AdminService.clearAdminStatus();
      setState(() {
        _debugInfo = 'Admin status cleared at: ${DateTime.now()}';
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Error clearing admin status: $e';
      });
    }
  }
}
