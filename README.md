# Ghar Ka Khana (Grandma's Kitchen)

A direct-to-consumer (D2C) food commerce application built with Flutter and Firebase. The app is designed to provide working professionals with healthy, nostalgic, home-cooked meals prepared by a single home chef ("Grandma"), while providing an accessible dashboard for easy kitchen management.

---

## Features

### Customer App (The Diner)
- **Menu Browsing:** Real-time view of daily specials and authentic home-style dishes.
- **Dynamic Quantity Stepper:** Add or remove items directly from the menu card with instant feedback[cite: 1].
- **Interactive Cart & Bill Breakdown:** Live calculation of subtotal, delivery charges, and total bill amounts[cite: 2].
- **Fulfillment Options:** Flexible selection between **Self-Pickup** and **Home Delivery**[cite: 2].
- **Simulated Payment Gateway:** Mock checkout flow supporting UPI/QR, Cards, and Net Banking.
- **Order Tracking:** Live visual status timeline tracking orders from kitchen prep to doorstep delivery[cite: 1].

### Grandma’s Dashboard (Admin Interface)
- **High-Accessibility Design:** High-contrast layout with large touch targets designed specifically for elderly usability.
- **Order Management:** Simplified view of incoming orders with one-touch status progression.
- **Inventory Control:** Straightforward toggles to mark dishes available or sold out in real-time.
- **Database Seeding:** Built-in seed functionality to populate the initial menu directly to Cloud Firestore.

---

## Tech Stack

- **Frontend:** [Flutter](https://flutter.dev/) (Dart)
- **Backend & Database:** [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore)[cite: 3]
- **State Management:** Flutter `ChangeNotifier` / `ListenableBuilder`
- **Authentication & Hosting:** Firebase Core

---

## Project Structure

```text
lib/
├── firebase_options.dart   # Firebase configuration for Web, Android, & iOS
├── main.dart               # Core app entry point, customer UI, and state management
├── seed_db.dart            # Firestore menu database seeder
└── admin_app.dart          # Grandma's accessible admin dashboard
