# shop

E-Commerce App Prototype with Flutter & Supabase
The app includes:
• Modern and responsive UI with product browsing
• Authentication and database powered by Supabase
• State management with Cubit for clean and scalable code
• Cart and wishlist features for a smooth shopping experience
• Cool animations for better UX
• Location services and Flutter Maps integration
• An Admin page with full functionality to add, edit, delete, and confirm orders

## Prerequisites

- Flutter (stable) and Dart (bundled)
- Android Studio / Xcode or VS Code with Flutter plugin
- A connected device or emulator

## Getting started

1. Clone the repository:

```bash
git clone https://github.com/Ahmed4r/EcommerceApp.git
cd shop
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run on a device or emulator:

```bash
flutter run
```

## Build

- Android (APK):

```bash
flutter build apk --release
```

- iOS (macOS required):

```bash
flutter build ios --release
```

## 🖼️ Screenshots

| Homepage                                     | Product Card                                        | Admin Dashboard                                            | Cart                                 | Category                                     |
| -------------------------------------------- | --------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------ | -------------------------------------------- |
| ![Homepage](assets/screenshots/homepage.jpg) | ![Product Card](assets/screenshots/add_product.jpg) | ![Admin Dashboard](assets/screenshots/admin_dashboard.jpg) | ![Cart](assets/screenshots/cart.jpg) | ![Category](assets/screenshots/category.jpg) |

| Checkout                                     | Confirm Products                                             | Details                                    | Forget Password                                           | Login                                  |
| -------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------ | --------------------------------------------------------- | -------------------------------------- |
| ![Checkout](assets/screenshots/checkout.jpg) | ![Confirm Products](assets/screenshots/confirm_products.jpg) | ![Details](assets/screenshots/details.jpg) | ![Forget Password](assets/screenshots/forgetPassword.jpg) | ![Login](assets/screenshots/login.jpg) |

| Maps                                 | Profile                                    | Signup                                   | User Orders                                       | Wishlist                                     |
| ------------------------------------ | ------------------------------------------ | ---------------------------------------- | ------------------------------------------------- | -------------------------------------------- |
| ![Maps](assets/screenshots/maps.jpg) | ![Profile](assets/screenshots/profile.jpg) | ![Signup](assets/screenshots/signup.jpg) | ![User Orders](assets/screenshots/user_ordes.jpg) | ![Wishlist](assets/screenshots/wishlist.jpg) |

| Address                                    |
| ------------------------------------------ |
| ![Address](assets/screenshots/address.jpg) |

## Project layout (high level)

- lib/ — application source
  - main.dart — entry point
  - screens/ — UI screens
  - models/ — data models
  - widgets/ — reusable widgets
- assets/ — images, fonts, etc.

## Contributing

Contributions welcome. Open issues or pull requests and follow the existing code style.
