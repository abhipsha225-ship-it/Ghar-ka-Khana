# State Management and Database

## Providers
- `AuthProvider` listens to Firebase Authentication state changes and provides sign-in, sign-up, profile-name update and sign-out operations.
- `CartProvider` maintains item quantities and calculates the subtotal.
- `MenuProvider` listens to `menu_items` snapshots and supports availability, quantity and add-item operations.
- `OrdersProvider` exposes customer, active-admin and completed-admin order collections. It supports listeners, `placeOrder`, `updateOrderStatus` and `rateOrderItem`.
- `FavouritesProvider` provides favourite-state toggling.

## Database Seeding
`seed_db.dart` contains sample menu data. It deletes existing `menu_items` documents before adding seed data. This destructive operation must be used carefully and must never be run against production data.
