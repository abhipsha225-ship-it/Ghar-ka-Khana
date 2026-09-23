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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _currentIndex == 0
            ? const ActiveOrdersScreen()
            : const InventoryToggleScreen(),
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
              label: 'Orders',
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
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 80, // Massive touch target
            child: ElevatedButton(
              onPressed: () {
                if (order.status == 'Order Received') {
                  provider.updateOrderStatus(order.id, 'Preparing');
                } else if (order.status == 'Preparing') {
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
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1C1E),
                        ),
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
