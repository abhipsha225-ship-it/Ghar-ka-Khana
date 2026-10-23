\# Ghar Ka Khana — Application Architecture



\## Overview



Ghar Ka Khana is a Flutter-based food-ordering application that uses Firebase services for authentication and data storage. Its architecture separates the user interface, shared application state, data models and backend services.



\## Application Entry Point



`main.dart` initializes Flutter bindings, initializes Firebase using platform-specific configuration, and launches `GharKaKhanaApp`. `MultiProvider` makes shared provider instances accessible to the relevant screens.



\## Data Models



\- `MenuItemModel` represents menu items, including their names, descriptions, prices, availability, quantities, categories and image information.

\- `OrderModel` represents customer orders, including their items, cost breakdown, fulfilment method, status and delivery information.



\## State Management



\- `AuthProvider` manages authentication-related state and account operations.

\- `CartProvider` maintains cart quantities and calculates the subtotal.

\- `MenuProvider` manages menu data and menu-related operations.

\- `OrdersProvider` manages order lists, order placement, status updates and item ratings.

\- `FavouritesProvider` manages favourite-state changes.



\## Firebase Integration



Firebase Authentication supports user sign-in and account operations. Cloud Firestore stores application data, including menu items and orders.



\## Database Seeding



`seed\_db.dart` contains sample menu data for development. Its existing deletion behaviour means it should only be used with an appropriate test database.



\## Security Considerations



Administrator permissions should be enforced through secure authorization and Firestore Security Rules. Hard-coded administrator credentials should not be retained in production code.



