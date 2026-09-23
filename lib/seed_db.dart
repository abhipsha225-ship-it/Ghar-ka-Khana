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
    },
    {
      'title': 'Aloo Paratha',
      'subtitle': 'Stuffed potato flatbread with fresh curd and pickle',
      'price': 80,
      'icon_name': 'bakery_dining_outlined',
      'is_available': true,
    },
    {
      'title': 'Paneer Butter Masala',
      'subtitle': 'Rich paneer gravy with 2 butter rotis',
      'price': 180,
      'icon_name': 'ramen_dining_outlined',
      'is_available': true,
    },
    {
      'title': 'Dal Makhani',
      'subtitle': 'Slow-cooked black lentils with cream and spices',
      'price': 140,
      'icon_name': 'soup_kitchen_outlined',
      'is_available': true,
    },
    {
      'title': 'Gulab Jamun',
      'subtitle': 'Sweet milk dumplings in rose syrup (2 pcs)',
      'price': 60,
      'icon_name': 'cookie_outlined',
      'is_available': true,
    },
  ];

  try {
    final snapshot = await db.collection('menu_items').get();
    
    // First, let's clean up existing duplicates to be safe
    final titles = <String>{};
    for (var doc in snapshot.docs) {
      final title = doc.data()['title'] as String;
      if (titles.contains(title)) {
        await db.collection('menu_items').doc(doc.id).delete();
      } else {
        titles.add(title);
      }
    }

    // Now add if missing
    for (var item in initialMenu) {
      if (!titles.contains(item['title'])) {
        await db.collection('menu_items').add(item);
      }
    }
    debugPrint("Database successfully seeded/cleaned!");
  } catch (e) {
    debugPrint("Error seeding database: $e");
  }
}
