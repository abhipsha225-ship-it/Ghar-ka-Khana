import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> seedDatabase() async {
  final db = FirebaseFirestore.instance;

    final List<Map<String, dynamic>> initialMenu = [
      {
        'title': 'Rajma Chawal',
        'subtitle': 'Classic red kidney beans curry with steamed rice',
        'price': 120,
        'icon_name': 'rice_bowl_outlined',
        'is_available': true,
        'quantity_left': 20,
        'estimated_time': '15 mins',
        'category': 'Main Course',
      },
      {
        'title': 'Aloo Paratha',
        'subtitle': 'Stuffed potato flatbread with fresh curd and pickle',
        'price': 80,
        'icon_name': 'bakery_dining_outlined',
        'is_available': true,
        'quantity_left': 15,
        'estimated_time': '10 mins',
        'category': 'Breakfast',
      },
      {
        'title': 'Paneer Butter Masala',
        'subtitle': 'Rich paneer gravy with 2 butter rotis',
        'price': 180,
        'icon_name': 'ramen_dining_outlined',
        'is_available': true,
        'quantity_left': 10,
        'estimated_time': '20 mins',
        'category': 'Main Course',
      },
      {
        'title': 'Dal Makhani',
        'subtitle': 'Slow-cooked black lentils with cream and spices',
        'price': 140,
        'icon_name': 'soup_kitchen_outlined',
        'is_available': true,
        'quantity_left': 25,
        'estimated_time': '25 mins',
        'category': 'Main Course',
      },
      {
        'title': 'Gulab Jamun',
        'subtitle': 'Sweet milk dumplings in rose syrup (2 pcs)',
        'price': 60,
        'icon_name': 'cookie_outlined',
        'is_available': true,
        'quantity_left': 30,
        'estimated_time': '5 mins',
        'category': 'Dessert',
      },
    ];

    try {
      final snapshot = await db.collection('menu_items').get();
      
      // First, let's clean up ALL existing items and seed fresh to avoid duplicates and ensure new fields exist
      for (var doc in snapshot.docs) {
        await db.collection('menu_items').doc(doc.id).delete();
      }

      // Now add fresh items
      for (var item in initialMenu) {
        await db.collection('menu_items').add(item);
      }
      debugPrint("Database successfully seeded/cleaned!");
    } catch (e) {
      debugPrint("Error seeding database: $e");
    }
}
