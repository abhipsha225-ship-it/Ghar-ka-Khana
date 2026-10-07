import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';
import 'main.dart'; // added to access scaffoldMessengerKey

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Authentication failed.';
    } catch (e) {
      return 'An unknown error occurred.';
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Account already exists for this email.';
      } else if (e.code == 'weak-password') {
        return 'Password is too weak. Please use at least 6 characters.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      }
      return e.message ?? 'Registration failed.';
    } catch (e) {
      return 'Error while trying to sign up: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

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
      // Deduplicate by title to fix duplicate entries issue
      final allItems = snapshot.docs
          .map((doc) => MenuItemModel.fromFirestore(doc))
          .toList();
      
      final Map<String, MenuItemModel> uniqueItems = {};
      for (var item in allItems) {
        if (!uniqueItems.containsKey(item.title)) {
          uniqueItems[item.title] = item;
        } else {
          // Keep the one that is available if duplicates exist
          if (item.isAvailable && !uniqueItems[item.title]!.isAvailable) {
            uniqueItems[item.title] = item;
          }
        }
      }
      
      _menuItems = uniqueItems.values.toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> toggleAvailability(String id, bool currentStatus) async {
    await _db.collection('menu_items').doc(id).update({
      'is_available': !currentStatus,
    });
  }

  Future<void> updateQuantityLeft(String id, int newQuantity) async {
    await _db.collection('menu_items').doc(id).update({
      'quantity_left': newQuantity,
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
  List<String> get notifications {
    return _customerOrders.map((order) {
      if (order.status == 'Delivered') {
        return 'Your Order #${order.id.substring(0, 6).toUpperCase()} has been delivered! Please rate your items.';
      } else if (order.status == 'Declined') {
        return 'Order #${order.id.substring(0, 6).toUpperCase()} was declined. Reason: ${order.declineReason}';
      } else {
        return 'Order #${order.id.substring(0, 6).toUpperCase()} is currently: ${order.status}';
      }
    }).toList();
  }

  // For customer - fetch user's orders
  void listenToUserOrders(String userId) {
    _db
        .collection('orders')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.modified) {
              final order = OrderModel.fromFirestore(change.doc);
              
              // Check if status actually changed (prevent loop on rating updates)
              final oldOrderIndex = _customerOrders.indexWhere((o) => o.id == order.id);
              if (oldOrderIndex != -1 && _customerOrders[oldOrderIndex].status == order.status) {
                continue; 
              }

              SystemSound.play(SystemSoundType.alert);
              final msg = order.status == 'Declined' 
                  ? 'Order #${order.id.substring(0, 6).toUpperCase()} was declined. Reason: ${order.declineReason}' 
                  : 'Order #${order.id.substring(0, 6).toUpperCase()} status updated to: ${order.status}';
              
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
              );
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

  Future<void> updateOrderStatus(String id, String newStatus, {String? declineReason}) async {
    final data = {'status': newStatus};
    if (declineReason != null) {
      data['decline_reason'] = declineReason;
    }
    await _db.collection('orders').doc(id).update(data);
  }

  List<OrderModel> _completedAdminOrders = [];
  List<OrderModel> get completedAdminOrders => _completedAdminOrders;

  void listenToCompletedOrders() {
    _db
        .collection('orders')
        .where('status', isEqualTo: 'Delivered')
        .snapshots()
        .listen((snapshot) {
          _completedAdminOrders = snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
          _completedAdminOrders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          notifyListeners();
        });
  }

  Future<void> rateOrderItem(String orderId, String itemId, int rating) async {
    final docRef = _db.collection('orders').doc(orderId);
    final doc = await docRef.get();
    if (doc.exists) {
      final items = List<Map<String, dynamic>>.from(doc.data()?['items'] ?? []);
      for (var i = 0; i < items.length; i++) {
        if (items[i]['item_id'] == itemId) {
          items[i]['rating'] = rating;
          break;
        }
      }
      await docRef.update({'items': items});
    }
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
