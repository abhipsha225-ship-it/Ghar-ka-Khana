import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'providers.dart';

// Helper to map string to IconData
IconData getIconFromString(String name) {
  switch (name) {
    case 'soup_kitchen_outlined':
      return Icons.soup_kitchen_outlined;
    case 'set_meal_outlined':
      return Icons.set_meal_outlined;
    case 'rice_bowl_outlined':
      return Icons.rice_bowl_outlined;
    case 'lunch_dining_outlined':
      return Icons.lunch_dining_outlined;
    default:
      return Icons.fastfood_outlined;
  }
}

class CustomerAppScreen extends StatefulWidget {
  const CustomerAppScreen({Key? key}) : super(key: key);

  @override
  State<CustomerAppScreen> createState() => _CustomerAppScreenState();
}

class _CustomerAppScreenState extends State<CustomerAppScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_currentIndex) {
      case 0:
        body = const CustomerHomeScreen();
        break;
      case 1:
        body = const CartScreen();
        break;
      case 2:
        body = const CustomerOrdersScreen();
        break;
      case 3:
        body = const FavouritesScreen();
        break;
      default:
        body = const Center(child: Text("Profile (Coming Soon)"));
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1C1C1E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favourites'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF1C1C1E)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Grandma\'s Kitchen',
          style: TextStyle(color: Color(0xFF1C1C1E)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF1C1C1E)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Notifications'),
                  content: const Text('You have no new notifications right now.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1C1C1E)),
              child: Text('Grandma\'s Kitchen', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      body: Consumer2<MenuProvider, CartProvider>(
        builder: (context, menuProv, cartProv, child) {
          if (menuProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allCategories = ['All', ...menuProv.availableItems.map((e) => e.category).toSet().toList()];
          final menu = menuProv.availableItems.where((item) => _selectedCategory == 'All' || item.category == _selectedCategory).toList();

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E5EA)),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFF9F9F9),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Evening! ☀️',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'What would you like to eat today?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: allCategories.length,
                        itemBuilder: (context, index) {
                          final cat = allCategories[index];
                          final isSelected = cat == _selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: const Color(0xFFD85C27),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF1C1C1E),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Today\'s Menu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...menu
                        .map(
                          (item) => _buildMenuItem(
                            context,
                            item,
                            cartProv.getQuantity(item.id),
                            cartProv,
                          ),
                        )
                        .toList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              if (cartProv.totalItems > 0)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD85C27),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View Cart (${cartProv.totalItems} Items - ₹${cartProv.getSubtotal(menuProv.menuItems)})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    MenuItemModel item,
    int qty,
    CartProvider cartProv,
  ) {
    final favProv = Provider.of<FavouritesProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5EA)),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF9F9F9),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E5EA)),
              color: Colors.white,
            ),
            child: Icon(
              getIconFromString(item.iconName),
              color: const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => favProv.toggleFavourite(item.id),
                      child: Icon(
                        favProv.isFavourite(item.id) ? Icons.favorite : Icons.favorite_border,
                        color: favProv.isFavourite(item.id) ? Colors.red : const Color(0xFF1C1C1E),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '⏱ ${item.estimatedTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD85C27),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${item.price}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E5EA)),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => cartProv.updateQuantity(item.id, -1),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '-',
                      style: TextStyle(fontSize: 18, color: Color(0xFF1C1C1E)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                  child: Center(
                    child: Text(
                      '$qty',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (qty < item.quantityLeft) {
                      cartProv.updateQuantity(item.id, 1);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Only ${item.quantityLeft} left!')),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 18, 
                        color: qty < item.quantityLeft ? const Color(0xFF1C1C1E) : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String deliveryOption = 'Home Delivery';
  int get deliveryCharge => deliveryOption == 'Home Delivery' ? 40 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(color: Color(0xFF1C1C1E)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<CartProvider, MenuProvider>(
        builder: (context, cartProv, menuProv, child) {
          if (cartProv.items.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(color: Color(0xFF666666)),
              ),
            );
          }

          final menu = menuProv.menuItems;
          final int subtotal = cartProv.getSubtotal(menu);
          final int totalAmount = subtotal + deliveryCharge;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...cartProv.items.entries.map((entry) {
                  final item = menu.firstWhere((m) => m.id == entry.key);
                  return _buildCartItem(context, item, entry.value, cartProv);
                }).toList(),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E5EA)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bill Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBillRow('Subtotal', '₹$subtotal'),
                      const SizedBox(height: 8),
                      _buildBillRow('Delivery Charge', '₹$deliveryCharge'),
                      const Divider(color: Color(0xFFE5E5EA), height: 32),
                      _buildBillRow('Total', '₹$totalAmount', isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Delivery Option',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 12),
                _buildDeliveryRadio(
                  'Pickup',
                  'Collect your order\n(Estimated: 10 min)',
                ),
                _buildDeliveryRadio(
                  'Home Delivery',
                  'Get it delivered to you\n(Estimated: 25-30 min)',
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentGatewayScreen(
                            totalAmount: totalAmount,
                            subtotal: subtotal,
                            deliveryCharge: deliveryCharge,
                            deliveryType: deliveryOption,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFD85C27),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue to Checkout',
                      style: TextStyle(
                        color: Color(0xFFD85C27),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    MenuItemModel item,
    int qty,
    CartProvider cartProv,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5EA)),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF9F9F9),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E5EA)),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => cartProv.updateQuantity(item.id, -1),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('-', style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(
                  width: 16,
                  child: Center(
                    child: Text('$qty', style: const TextStyle(fontSize: 16)),
                  ),
                ),
                InkWell(
                  onTap: () => cartProv.updateQuantity(item.id, 1),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('+', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 45,
            child: Text(
              '₹${item.price * qty}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          InkWell(
            onTap: () => cartProv.removeItem(item.id),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.delete_outline,
                color: Color(0xFF666666),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isBold ? const Color(0xFF1C1C1E) : const Color(0xFF666666),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: const Color(0xFF1C1C1E),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryRadio(String value, String subtitle) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      activeColor: const Color(0xFFD85C27),
      value: value,
      groupValue: deliveryOption,
      onChanged: (String? newValue) =>
          setState(() => deliveryOption = newValue!),
      title: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF1C1C1E),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
      ),
    );
  }
}

class PaymentGatewayScreen extends StatefulWidget {
  final int totalAmount;
  final int subtotal;
  final int deliveryCharge;
  final String deliveryType;

  const PaymentGatewayScreen({
    Key? key,
    required this.totalAmount,
    required this.subtotal,
    required this.deliveryCharge,
    required this.deliveryType,
  }) : super(key: key);

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  bool _isProcessing = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);
    final cartProv = Provider.of<CartProvider>(context, listen: false);
    final menuProv = Provider.of<MenuProvider>(context, listen: false);
    final ordersProv = Provider.of<OrdersProvider>(context, listen: false);

    List<Map<String, dynamic>> orderItems = [];
    cartProv.items.forEach((id, qty) {
      final m = menuProv.menuItems.firstWhere((element) => element.id == id);
      orderItems.add({
        'item_id': m.id,
        'title': m.title,
        'quantity': qty,
        'price': m.price,
      });
    });

    final order = OrderModel(
      id: '', // Firebase will generate
      userId: 'test_user_123',
      items: orderItems,
      subtotal: widget.subtotal,
      deliveryCharge: widget.deliveryCharge,
      total: widget.totalAmount,
      deliveryType: widget.deliveryType,
      status: 'Order Received',
      timestamp: DateTime.now(),
    );

    await Future.delayed(const Duration(seconds: 2));
    final orderId = await ordersProv.placeOrder(order);
    cartProv.clear();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(orderId: orderId),
        ),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Secure Checkout',
          style: TextStyle(color: Color(0xFF1C1C1E)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Amount to Pay',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${widget.totalAmount}.00',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(Icons.account_balance, 'UPI / QR'),
            _buildPaymentOption(Icons.credit_card, 'Credit / Debit Card'),
            _buildPaymentOption(Icons.food_bank_outlined, 'Net Banking'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD85C27),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Pay ₹${widget.totalAmount} & Place Order',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5EA)),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF9F9F9),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1C1C1E)),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1C1C1E),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Color(0xFF666666)),
        ],
      ),
    );
  }
}

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({Key? key, required this.orderId})
    : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<OrdersProvider>(
      context,
      listen: false,
    ).listenToUserOrders('test_user_123');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1E)),
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: const Text(
          'Order Tracking',
          style: TextStyle(color: Color(0xFF1C1C1E)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProv, child) {
          final orderList = ordersProv.customerOrders
              .where((o) => o.id == widget.orderId)
              .toList();
          if (orderList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = orderList.first;
          final isDeclined = order.status == 'Declined';
          final statusList = isDeclined 
              ? ['Order Received', 'Declined'] 
              : [
                  'Order Received',
                  'Preparing',
                  'Ready',
                  'Out for Delivery',
                  'Delivered',
                ];
          final currentStatusIndex = isDeclined ? 1 : statusList.indexOf(order.status);

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 6).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    Text(
                      '${order.timestamp.day}/${order.timestamp.month} • ${order.timestamp.hour}:${order.timestamp.minute}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE5E5EA)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      ...statusList.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final status = entry.value;
                        final isCompleted = isDeclined ? idx == 0 : idx <= currentStatusIndex;
                        final isLast = idx == statusList.length - 1;
                        return _buildTimelineItem(status, isCompleted, isLast, isDeclined: isDeclined && isLast);
                      }).toList(),
                      
                      if (isDeclined && order.declineReason != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 32),
                          child: Text(
                            'Reason: ${order.declineReason}',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),

                      const SizedBox(height: 32),
                      const Text(
                        'Items Ordered',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...order.items.map((item) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${item['quantity']}x ${item['title']}'),
                          subtitle: Text('₹${item['price']}'),
                          trailing: order.status == 'Delivered'
                              ? OutlinedButton(
                                  onPressed: () => _showRatingDialog(context, item),
                                  child: const Text('Rate'),
                                )
                              : null,
                        );
                      }).toList(),
                    ],
                  ),
                ),
                if (!isDeclined && order.status != 'Delivered')
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E5EA)),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF9F9F9),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Color(0xFF666666),
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Time',
                              style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '25 minutes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.two_wheeler,
                          size: 32,
                          color: Color(0xFF1C1C1E),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(String title, bool isCompleted, bool isLast, {bool isDeclined = false}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDeclined ? Colors.red : (isCompleted ? const Color(0xFF1C1C1E) : Colors.white),
                    border: Border.all(
                      color: isDeclined ? Colors.red : (isCompleted ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA)),
                      width: 2,
                    ),
                  ),
                  child: isDeclined 
                      ? const Icon(Icons.close, size: 16, color: Colors.white)
                      : (isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted || isDeclined
                          ? const Color(0xFF1C1C1E)
                          : const Color(0xFFE5E5EA),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDeclined ? Colors.red : (isCompleted
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFF666666)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, Map<String, dynamic> item) {
    int rating = 5;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Rate ${item['title']}'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() {
                    rating = index + 1;
                  });
                },
              );
            }),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                // Here we would typically save the rating to Firestore
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for your rating!')));
                Navigator.pop(ctx);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({Key? key}) : super(key: key);

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<OrdersProvider>(context, listen: false).listenToUserOrders('test_user_123');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(color: Color(0xFF1C1C1E))),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProv, child) {
          final orders = ordersProv.customerOrders;
          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet", style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                elevation: 0,
                color: const Color(0xFFF9F9F9),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFE5E5EA)),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text('Order #${order.id.substring(0, 6).toUpperCase()}'),
                  subtitle: Text(order.status),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(orderId: order.id),
                    ));
                  },
                ),
              );
            },
          );
        }
      ),
    );
  }
}

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites', style: TextStyle(color: Color(0xFF1C1C1E))),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Consumer2<FavouritesProvider, MenuProvider>(
        builder: (context, favProv, menuProv, child) {
          final favIds = favProv.favourites;
          if (favIds.isEmpty) {
            return const Center(child: Text("No favourites yet", style: TextStyle(color: Colors.grey)));
          }
          final favItems = menuProv.menuItems.where((m) => favIds.contains(m.id)).toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favItems.length,
            itemBuilder: (context, index) {
              final item = favItems[index];
              return Card(
                elevation: 0,
                color: const Color(0xFFF9F9F9),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFE5E5EA)),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(getIconFromString(item.iconName), color: const Color(0xFF1C1C1E)),
                  ),
                  title: Text(item.title),
                  subtitle: Text('₹${item.price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      favProv.toggleFavourite(item.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  const OrderSuccessScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(orderId: widget.orderId),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFD85C27),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 64),
            ),
            const SizedBox(height: 32),
            const Text(
              'Order Placed Successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Routing to tracking screen...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
