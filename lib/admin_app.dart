import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'providers.dart';
import 'seed_db.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<OrdersProvider>(context, listen: false).listenToActiveOrders();
    Provider.of<OrdersProvider>(context, listen: false).listenToCompletedOrders();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_currentIndex == 0) {
      body = const ActiveOrdersScreen();
    } else if (_currentIndex == 1) {
      body = const CompletedOrdersScreen();
    } else {
      body = const InventoryToggleScreen();
    }

    return Scaffold(
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1C1C1E),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 20,
          unselectedFontSize: 18,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt, size: 32),
              label: 'Active',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline, size: 32),
              label: 'Completed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory, size: 32),
              label: 'Inventory',
            ),
          ],
        ),
      );
  }
}

class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Active Orders',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red, size: 32),
            onPressed: () async {
              final nav = Navigator.of(context, rootNavigator: true);
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              nav.pop();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProv, child) {
          if (ordersProv.activeAdminOrders.isEmpty) {
            return const Center(
              child: Text(
                'No Active Orders',
                style: TextStyle(fontSize: 24, color: Color(0xFF666666)),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: ordersProv.activeAdminOrders.length,
            itemBuilder: (context, index) {
              final order = ordersProv.activeAdminOrders[index];
              return _buildOrderCard(context, order, ordersProv);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    OrdersProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        border: Border.all(color: const Color(0xFF1C1C1E), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.deliveryType,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1C1C1E), thickness: 2),
          const SizedBox(height: 16),
          ...order.items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    '${item['quantity']}x ${item['title']}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
              )
              .toList(),
          if (order.status == 'Order Received')
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () {
                        _showDeclineDialog(context, order.id, provider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'DECLINE',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.updateOrderStatus(order.id, 'Preparing');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD85C27),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'ACCEPT',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              height: 80, // Massive touch target
              child: ElevatedButton(
                onPressed: () {
                  if (order.status == 'Preparing') {
                    provider.updateOrderStatus(order.id, 'Ready');
                  } else if (order.status == 'Ready') {
                    provider.updateOrderStatus(order.id, 'Out for Delivery');
                  } else if (order.status == 'Out for Delivery') {
                    provider.updateOrderStatus(order.id, 'Delivered');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(order.status),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _getButtonText(order.status),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, String orderId, OrdersProvider provider) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Order'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Reason for declining'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonCtrl.text.isNotEmpty) {
                provider.updateOrderStatus(orderId, 'Declined', declineReason: reasonCtrl.text);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Decline Order'),
          ),
        ],
      ),
    );
  }

  Color _getButtonColor(String status) {
    if (status == 'Order Received') return const Color(0xFFD85C27);
    if (status == 'Preparing') return Colors.blue.shade700;
    if (status == 'Ready') return Colors.green.shade700;
    if (status == 'Out for Delivery') return Colors.purple.shade700;
    return const Color(0xFF1C1C1E);
  }

  String _getButtonText(String status) {
    if (status == 'Order Received') return 'ACCEPT ORDER';
    if (status == 'Preparing') return 'MARK AS READY';
    if (status == 'Ready') return 'SEND OUT';
    if (status == 'Out for Delivery') return 'MARK DELIVERED';
    return 'UPDATE STATUS';
  }
}

class CompletedOrdersScreen extends StatelessWidget {
  const CompletedOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Completed Orders',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProv, child) {
          if (ordersProv.completedAdminOrders.isEmpty) {
            return const Center(
              child: Text(
                'No Completed Orders',
                style: TextStyle(fontSize: 24, color: Color(0xFF666666)),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: ordersProv.completedAdminOrders.length,
            itemBuilder: (context, index) {
              final order = ordersProv.completedAdminOrders[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  border: Border.all(color: const Color(0xFFE5E5EA), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 6).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF1C1C1E), thickness: 2),
                    const SizedBox(height: 16),
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item['quantity']}x ${item['title']}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 24),
                                const SizedBox(width: 4),
                                Text(
                                  item['rating'] != null ? '${item['rating']}' : 'NR',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class InventoryToggleScreen extends StatelessWidget {
  const InventoryToggleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Inventory',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined, size: 32),
            onPressed: () async {
              await seedDatabase();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu seeded successfully!')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context);
        },
        backgroundColor: const Color(0xFF1C1C1E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menuProv, child) {
          if (menuProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: menuProv.menuItems.length,
            itemBuilder: (context, index) {
              final item = menuProv.menuItems[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  border: Border.all(color: const Color(0xFFE5E5EA), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 32),
                                onPressed: () {
                                  if (item.quantityLeft > 0) {
                                    menuProv.updateQuantityLeft(item.id, item.quantityLeft - 1);
                                  }
                                },
                              ),
                              Text(
                                'Qty: ${item.quantityLeft}',
                                style: const TextStyle(fontSize: 20),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 32),
                                onPressed: () {
                                  menuProv.updateQuantityLeft(item.id, item.quantityLeft + 1);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 2.0, // Massive touch target switch
                      child: Switch(
                        value: item.isAvailable,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                        inactiveTrackColor: Colors.red.shade200,
                        onChanged: (val) {
                          menuProv.toggleAvailability(
                            item.id,
                            item.isAvailable,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Menu Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: subtitleCtrl, decoration: const InputDecoration(labelText: 'Subtitle')),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if(titleCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                Provider.of<MenuProvider>(context, listen: false).addMenuItem(
                  MenuItemModel(
                    id: '', 
                    title: titleCtrl.text,
                    subtitle: subtitleCtrl.text,
                    price: int.tryParse(priceCtrl.text) ?? 0,
                    iconName: 'soup_kitchen_outlined',
                    isAvailable: true,
                  )
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          )
        ],
      )
    );
  }
}
class AdminAuthWrapper extends StatelessWidget {
  const AdminAuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProv, child) {
        if (authProv.isAuthenticated) {
          return const AdminDashboardScreen();
        } else {
          return const AdminLoginScreen();
        }
      },
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;

  void _login() async {
    setState(() => _isLoading = true);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final errorMsg = await authProv.signIn(emailCtrl.text.trim(), passCtrl.text.trim());
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (errorMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 80, color: Color(0xFFD85C27)),
            const SizedBox(height: 24),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Admin Email', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl, 
              obscureText: _obscurePass, 
              decoration: InputDecoration(
                labelText: 'Password', 
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C1C1E)),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login as Grandma', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
