import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/services/orders_service.dart';

class OrdersAdminPage extends StatefulWidget {
  static const String routeName = '/admin/orders';
  const OrdersAdminPage({super.key});

  @override
  State<OrdersAdminPage> createState() => _OrdersAdminPageState();
}

class _OrdersAdminPageState extends State<OrdersAdminPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await OrdersService.instance.fetchAllOrders();
    setState(() {
      _orders = data;
      _loading = false;
    });
  }

  Future<void> _approve(dynamic id) async {
    await OrdersService.instance.updateOrderStatus(id, 'confirmed');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders', style: GoogleFonts.cairo())),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: EdgeInsets.all(12.r),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: _orders.length,
                itemBuilder: (context, i) {
                  final o = _orders[i];
                  final items = (o['items'] as List?) ?? [];
                  return ListTile(
                    title: Text(
                      'Order #${o['id']} • ${o['status']}',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total: ${o['total_amount']}',
                          style: GoogleFonts.cairo(),
                        ),
                        if (items.isNotEmpty) Text('Items: ${items.length}'),
                      ],
                    ),
                    trailing: o['status'] == 'pending'
                        ? ElevatedButton(
                            onPressed: () => _approve(o['id']),
                            child: const Text('Approve'),
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),
            ),
    );
  }
}
