import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _items = {};

  Map<String, int> get items => _items;

  int getQuantity(String id) => _items[id] ?? 0;

  int get totalItems => _items.values.fold(0, (sum, qty) => sum + qty);

  int getSubtotal(List<MenuItemModel> menu) {
    int total = 0;
    _items.forEach((id, qty) {
      final item = menu.firstWhere((m) => m.id == id);
      total += item.price * qty;
    });
    return total;
  }

  void updateQuantity(String id, int delta) {
    final current = getQuantity(id);
    final newQty = current + delta;

    if (newQty <= 0) {
      _items.remove(id);
    } else {
      _items[id] = newQty;
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class MenuProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<MenuItemModel> _menuItems = [];
  bool _isLoading = true;

  List<MenuItemModel> get menuItems => _menuItems;
  List<MenuItemModel> get availableItems =>
      _menuItems.where((i) => i.isAvailable).toList();
  bool get isLoading => _isLoading;

  MenuProvider() {
    _db.collection('menu_items').snapshots().listen((snapshot) {
      _menuItems = snapshot.docs
          .map((doc) => MenuItemModel.fromFirestore(doc))
          .toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> toggleAvailability(String id, bool currentStatus) async {
    await _db.collection('menu_items').doc(id).update({
      'is_available': !currentStatus,
    });
  }

  Future<void> addMenuItem(MenuItemModel item) async {
    await _db.collection('menu_items').add(item.toMap());
  }
}

class OrdersProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<OrderModel> _customerOrders = [];
  List<OrderModel> _activeAdminOrders = [];

  List<OrderModel> get customerOrders => _customerOrders;
  List<OrderModel> get activeAdminOrders => _activeAdminOrders;

  // For customer - fetch user's orders
  void listenToUserOrders(String userId) {
    _db
        .collection('orders')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.modified) {
              SystemSound.play(SystemSoundType.alert);
              // In a real app, this would trigger a local push notification
            }
          }
          _customerOrders = snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
          _customerOrders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          notifyListeners();
        });
  }

  // For admin - fetch active orders (not delivered)
  void listenToActiveOrders() {
    _db
        .collection('orders')
        .where('status', isNotEqualTo: 'Delivered')
        .snapshots()
        .listen((snapshot) {
          // Check if new order added for audio alert
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              SystemSound.play(SystemSoundType.alert);
            }
          }

          _activeAdminOrders = snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();

          // Sort in memory because Firestore limits sorting on inequality filters sometimes
          _activeAdminOrders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          notifyListeners();
        });
  }

  Future<String> placeOrder(OrderModel order) async {
    final docRef = await _db.collection('orders').add(order.toMap());
    return docRef.id;
  }

  Future<void> updateOrderStatus(String id, String newStatus) async {
    await _db.collection('orders').doc(id).update({'status': newStatus});
  }
}

class FavouritesProvider extends ChangeNotifier {
  final Set<String> _favourites = {};

  Set<String> get favourites => _favourites;

  bool isFavourite(String id) => _favourites.contains(id);

  void toggleFavourite(String id) {
    if (_favourites.contains(id)) {
      _favourites.remove(id);
    } else {
      _favourites.add(id);
    }
    notifyListeners();
  }
}
