# Application Architecture

## Entry Point
`main.dart` initializes Flutter bindings and Firebase using `DefaultFirebaseOptions.currentPlatform`, then runs `GharKaKhanaApp` within `MultiProvider`.

## UI and Theme
The app uses Material 3, a cream background, an orange seed color and a Poppins text theme. `RoleSelectionScreen` is the entry point for customer and admin paths.

## Data Models
- `MenuItemModel` maps `title`, `subtitle`, `price`, `icon_name`, `is_available`, `quantity_left`, `estimated_time`, `category` and `image_url`.
- `OrderModel` maps `user_id`, `items`, `subtotal`, `delivery_charge`, `total`, `delivery_type`, `status`, `timestamp`, `decline_reason` and `customer_address`.
