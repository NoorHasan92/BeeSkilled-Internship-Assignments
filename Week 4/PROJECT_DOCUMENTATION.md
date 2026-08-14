# NovaCart

**A Flutter-based e-commerce mobile application built with Firebase Authentication, Cloud Firestore, Provider state management, and Firebase Cloud Messaging.**

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Objectives](#objectives)
3. [Key Features](#key-features)
4. [Application Flow](#application-flow)
5. [Technology Stack](#technology-stack)
6. [Architecture](#architecture)
7. [Project Structure](#project-structure)
8. [Firebase Authentication](#firebase-authentication)
9. [Firestore Database Design](#firestore-database-design)
10. [Firestore Security](#firestore-security)
11. [Cart State Management](#cart-state-management)
12. [Checkout and Order Creation](#checkout-and-order-creation)
13. [Mock Payment](#mock-payment)
14. [Notification System](#notification-system)
15. [UI and UX Design](#ui-and-ux-design)
16. [Error Handling](#error-handling)
17. [Security Considerations](#security-considerations)
18. [Setup and Installation](#setup-and-installation)
19. [Running the Project](#running-the-project)
20. [Firestore Initial Data and Seeding](#firestore-initial-data-and-seeding)
21. [Testing and Verification](#testing-and-verification)
22. [Release APK](#release-apk)
23. [Limitations](#limitations)
24. [Future Enhancements](#future-enhancements)
25. [Learning Outcomes](#learning-outcomes)
26. [Internship Assignment Completion](#internship-assignment-completion)
27. [Author](#author)
28. [License](#license)

---

## Project Overview

NovaCart is a fully functional e-commerce mobile application built with Flutter and Firebase. It demonstrates a complete online shopping workflow — from user authentication and product browsing through to checkout, simulated payment processing, and order history — all backed by a real-time cloud database.

The application targets the **Android** platform and uses **Cloud Firestore** as the primary data store, **Firebase Authentication** for user management, and **Firebase Cloud Messaging (FCM)** for push notifications. Products are loaded in real-time from Firestore, and orders are securely stored per user with server-enforced access rules.

NovaCart is intended as a demonstration project for an internship assignment. It showcases practical skills in Flutter application development, Firebase integration, state management, form validation, asynchronous programming, and building a release-ready Android APK.

**Important:** Payment processing in NovaCart is entirely simulated. No real payment gateway is integrated, and no actual financial transactions take place.

---

## Objectives

- Build a complete, polished Flutter mobile application from scratch.
- Implement user authentication using Firebase Authentication (email/password sign-in and registration).
- Integrate Cloud Firestore for real-time product catalog storage and retrieval.
- Build a product search feature with text search and category filtering.
- Implement a product details screen with image display, ratings, and add-to-cart functionality.
- Implement cart state management using Provider and ChangeNotifier.
- Build a multi-step checkout flow with address form validation and order summary.
- Implement a mock payment flow supporting Card, UPI, and Cash on Delivery options.
- Store completed orders securely in Firestore with user-specific access control.
- Display order history and detailed order information.
- Integrate Firebase Cloud Messaging for push notification support.
- Handle notification permissions and display foreground notifications using local notifications.
- Integrate Gemini AI for an intelligent customer support chat assistant using Firebase AI Logic and Firebase App Check.
- Implement light and dark mode theming using Material 3.
- Maintain clean, analyzable code with zero static analysis issues.
- Produce a signed release APK suitable for distribution.

---

## Key Features

### Authentication

- **Login** — Email and password sign-in with form validation and Firebase error handling.
- **Registration** — Account creation via `createUserWithEmailAndPassword` with password confirmation and validation.
- **Logout** — Sign-out from the Profile page, returning the user to the login screen.
- **Auth Persistence** — Firebase Authentication automatically persists the session. Users remain signed in across app restarts.
- **AuthGate** — A `StreamBuilder` listening to `FirebaseAuth.instance.authStateChanges()` routes the user to either the login screen or the home shell depending on authentication state.

### Home

- Personalized greeting derived from the user's email address.
- Promotional banner with gradient background.
- Horizontal category chips (Tech, Fashion, Home, Lifestyle).
- Featured products grid loaded in real-time from Firestore via `ProductService.getFeaturedProducts()`.
- Pull-to-refresh support.
- Product cards with images, category labels, ratings, and prices.

### Search

- Full-text search field with clear button.
- Case-insensitive search across product name, description, and category fields.
- Category filter chips: All, Tech, Fashion, Home, Lifestyle.
- Combined text search and category filtering work simultaneously.
- Empty state displayed when no products match the current query and filter.
- Products are loaded from Firestore via `ProductService.getProducts()` and filtered client-side.

### Product Details

- Full-width product image loaded from a network URL with error handling for broken images.
- Product name, category label, price in INR (₹), and star rating.
- Full product description.
- Favorite toggle button with scale animation (local state only; not persisted to Firestore).
- "Add to Cart" button that reflects current cart quantity (e.g., "Add more (in cart: 2)").
- SnackBar confirmation with a "View Cart" action that navigates directly to the Cart tab.

### Shopping Cart

- Managed by `CartProvider`, a `ChangeNotifier`-based provider.
- Displays all cart items with product images, names, individual prices, and quantity controls.
- Quantity increment and decrement with minimum quantity of 1.
- Delete button to remove an item entirely.
- Cart summary panel showing subtotal, delivery (currently free), and total.
- "Proceed to Checkout" button.
- Empty cart state with a "Continue Shopping" button that returns to the Home tab.
- Cart item count badge displayed on the bottom navigation bar.

### Checkout

- Delivery address form with six validated fields: Full Name, Phone Number, Street Address, City, State, PIN Code.
- All fields are required; the form prevents submission if any field is empty.
- Order summary listing each item with thumbnail, name, quantity, and line total.
- Subtotal, delivery fee, and total displayed.
- "Proceed to Payment" button navigates to the mock payment screen with the validated address and cart data.

### Mock Payment

- **Three payment methods:** Credit/Debit Card, UPI, Cash on Delivery.
- **Card:** Form fields for card number, expiry (MM/YY), CVV, and cardholder name. All fields are validated.
- **UPI:** Form field for UPI ID with validation.
- **COD:** No additional input required.
- **Simulated processing delay** of 2 seconds to replicate a payment gateway interaction.
- On success: the order is created in Firestore, the cart is cleared, and the user is navigated to a success screen.
- On failure: a SnackBar error message is displayed and the cart is not cleared.
- **No real payment processing occurs.** Card numbers, CVVs, expiry dates, and UPI IDs entered in the form are used only for local validation and are **not stored** in Firestore or transmitted to any server. Only the payment method name (e.g., "Card") and payment status (e.g., "paid") are recorded.

### Orders

- **Order history** loaded in real-time from Firestore using `OrderService.getUserOrders()`, filtered by the authenticated user's UID.
- Orders are sorted by creation date (most recent first) and require a composite Firestore index on `userId` + `createdAt`.
- Each order card displays the order ID, date, item count, total amount, payment status badge, and order status badge.
- Tapping an order card opens a detailed view showing all ordered items, delivery address, payment method, subtotal, delivery fee, and total.
- Empty state displayed with a "Start Shopping" button when no orders exist.
- Error state with a "Retry" button for Firestore query failures.

### Notifications

- Firebase Cloud Messaging integration for receiving push notifications.
- Notification permission request on app startup (required on Android 13+).
- Foreground message handling using `flutter_local_notifications` to display heads-up notifications while the app is active.
- Background message handler registered via a top-level Dart function annotated with `@pragma('vm:entry-point')`.
- Custom Android notification channel (`novacart_high_importance_channel`) with high importance for heads-up display.
- Notification tap handling routes the user to the Orders tab via a broadcast `StreamController`.
- Initial message handling for cold-start scenarios (app launched via a notification from terminated state).
- FCM token retrieval on initialization.
- **Non-blocking initialization:** If FCM fails (e.g., on an emulator without Google Play Services), the app continues to function normally.

### NovaCart AI Assistant

- **Gemini Powered** — Integrated with `gemini-3.7-flash` via the Firebase AI Logic SDK to provide intelligent customer support.
- **Context-Aware** — The AI reads the user's current cart state, order history, and product catalog to provide personalized and accurate responses.
- **Secure Access** — Enforced using Firebase App Check (`AndroidProvider.debug` for emulators, Play Integrity for production) to guarantee that only the authentic NovaCart app can access the Gemini Developer API.
- **Streaming Responses** — Implements `sendMessageStream` with a custom typewriter effect to stream responses word-by-word for a smooth, natural chat experience.
- **Markdown Formatting** — Uses `flutter_markdown_plus` to render structured responses, bold text, and lists correctly in the UI.

### Profile

- User avatar placeholder and email display.
- Dark mode toggle switch.
- Notification permission status indicator (Enabled/Disabled).
- Sign Out button.

### Theme

- **Light mode** with a purple seed color (`#635BFF`) and light scaffold background (`#F7F7FB`).
- **Dark mode** with a complementary purple seed color (`#8B83FF`) and dark scaffold background (`#0D0D12`).
- Built using Material 3 (`useMaterial3: true`) with `ColorScheme.fromSeed()`.
- Custom `InputDecorationTheme` for consistent form field styling across both themes.
- Theme toggle accessible from the Profile page.

---

## Application Flow

### Shopping Flow

```
Login / Sign Up
  → Home (featured products, categories)
    → Search / Browse (text search + category filter)
      → Product Details (image, info, rating)
        → Add to Cart
          → Cart (review items, quantities)
            → Checkout (delivery address, order summary)
              → Mock Payment (Card / UPI / COD)
                → Order created in Firestore
                  → Payment Success screen
                    → Orders tab (order history)
                      → Order Details
```

### Notification Flow

```
Firebase Cloud Messaging
  → Device receives push message
    → NotificationService handles message
      → Foreground: flutter_local_notifications displays heads-up notification
      → Background/Terminated: system tray notification
        → User taps notification
          → App navigates to Orders tab
```

---

## Technology Stack

| Category | Technology | Version |
|---|---|---|
| Framework | Flutter | SDK ^3.12.2 |
| Language | Dart | Bundled with Flutter SDK |
| UI Toolkit | Material 3 | Built-in |
| Authentication | Firebase Authentication (`firebase_auth`) | ^6.5.7 |
| Database | Cloud Firestore (`cloud_firestore`) | ^6.8.0 |
| Firebase Core | `firebase_core` | ^4.13.0 |
| Push Notifications | Firebase Cloud Messaging (`firebase_messaging`) | ^16.5.0 |
| Local Notifications | `flutter_local_notifications` | ^22.3.0 |
| AI Integration | Firebase AI Logic (`firebase_ai`) | ^3.15.0 |
| App Security | Firebase App Check (`firebase_app_check`) | ^0.4.6 |
| Markdown Parsing | `flutter_markdown_plus` | ^1.0.12 |
| State Management | Provider (`provider`) | ^6.1.5+1 |
| Internationalization | `intl` | ^0.20.3 |
| Icons | Cupertino Icons (`cupertino_icons`) | ^1.0.8 |
| Build System | Android Gradle (Kotlin DSL) | Gradle 9.1.0 |
| Java Compatibility | Core Library Desugaring (`desugar_jdk_libs`) | 2.1.4 |
| Target Platform | Android | compileSdk per Flutter defaults |

---

## Architecture

NovaCart follows a layered architecture organized by responsibility:

```
┌─────────────────────────────────────────┐
│               UI Layer                  │
│  (Pages, Widgets, Navigation, Theme)    │
├─────────────────────────────────────────┤
│          State Management               │
│       (CartProvider / Provider)          │
├─────────────────────────────────────────┤
│           Service Layer                 │
│  ProductService, OrderService,          │
│  NotificationService                    │
├─────────────────────────────────────────┤
│            Model Layer                  │
│    Product, OrderModel, OrderItem,      │
│    Address, CartItem                    │
├─────────────────────────────────────────┤
│       Firebase / Cloud Layer            │
│  Firebase Auth, Cloud Firestore, FCM    │
└─────────────────────────────────────────┘
```

- **UI Layer:** All pages and widgets are defined in `main.dart`. Navigation uses a bottom `NavigationBar` with `IndexedStack` to preserve page state across tab switches. Full-screen pages (Product Details, Checkout, Payment, Order Details) are pushed via `MaterialPageRoute`.
- **State Management:** `CartProvider` extends `ChangeNotifier` and is provided to the widget tree via `ChangeNotifierProvider` at the root. Widgets consume cart state through `Consumer<CartProvider>` and `context.watch<CartProvider>()`.
- **Service Layer:** Singleton services (`ProductService`, `OrderService`, `NotificationService`) encapsulate all Firebase interactions. Each uses a private constructor with a static `instance` field.
- **Model Layer:** Data classes (`Product`, `OrderModel`, `OrderItem`, `Address`, `CartItem`) handle serialization to/from Firestore documents via `fromFirestore()` factory constructors and `toMap()` methods.
- **Firebase Layer:** Firebase is initialized in `main()` using `Firebase.initializeApp()` with platform-specific options from `DefaultFirebaseOptions`. Authentication state is observed reactively via `authStateChanges()`.

---

## Project Structure

```
novacart/
├── lib/
│   ├── main.dart                          # Application entry point, all pages and widgets
│   ├── firebase_options.dart              # FlutterFire-generated platform configuration
│   ├── models/
│   │   ├── product.dart                   # Product data model with Firestore deserialization
│   │   └── order.dart                     # OrderModel, OrderItem, and Address models
│   ├── providers/
│   │   └── cart_provider.dart             # CartProvider (ChangeNotifier) and CartItem
│   └── services/
│       ├── product_service.dart           # Firestore product queries (all products, featured)
│       ├── order_service.dart             # Firestore order creation and user-specific queries
│       ├── notification_service.dart      # FCM + local notifications initialization and handling
│       └── product_seed_service.dart      # Development utility for seeding demo products
├── android/
│   └── app/
│       ├── build.gradle.kts               # Android build configuration with desugaring
│       ├── src/main/AndroidManifest.xml   # App manifest with FCM intent filters and metadata
│       └── google-services.json           # Firebase Android configuration (generated by FlutterFire)
├── pubspec.yaml                           # Dependencies, metadata, and Flutter configuration
├── firebase.json                          # FlutterFire CLI configuration
├── analysis_options.yaml                  # Dart static analysis rules
└── .gitignore                             # Version control exclusions
```

### Key File Responsibilities

| File | Purpose |
|---|---|
| `main.dart` | Contains `main()`, `NovaCartApp`, `AuthGate`, all page widgets (`HomePage`, `SearchPage`, `CartPage`, `CheckoutPage`, `MockPaymentPage`, `OrdersPage`, `OrderDetailsPage`, `ProfilePage`, `ProductDetailsPage`), the `HomeShell` navigation scaffold, and theme definitions. |
| `product.dart` | Immutable `Product` class with `fromFirestore()` factory for deserializing Firestore documents. Fields: `id`, `name`, `description`, `price`, `category`, `rating`, `imageUrl`, `featured`. |
| `order.dart` | `OrderModel` with nested `OrderItem` and `Address` classes. Includes `toMap()` for Firestore writes and `fromFirestore()` for reads. Uses `FieldValue.serverTimestamp()` for `createdAt`. |
| `cart_provider.dart` | `CartProvider` (ChangeNotifier) managing an in-memory `Map<String, CartItem>`. Provides `addProduct`, `removeProduct`, `increaseQuantity`, `decreaseQuantity`, `removeItem`, `clearCart`, `containsProduct`, `quantityFor`, `totalItems`, and `subtotal`. |
| `product_service.dart` | Singleton service exposing `getProducts()` and `getFeaturedProducts()` as Firestore `Stream<List<Product>>` queries. |
| `order_service.dart` | Singleton service exposing `createOrder()` (writes to `orders` collection with the order ID as the document ID) and `getUserOrders()` (queries by `userId`, ordered by `createdAt` descending). |
| `notification_service.dart` | Singleton service handling FCM permission requests, local notification initialization, foreground/background/terminated message handling, notification channel creation, and tap-to-navigate via a broadcast stream. |
| `product_seed_service.dart` | Development utility that writes 15 predefined products to Firestore using batch writes with deterministic document IDs. Not exposed in the production UI. |

---

## Firebase Authentication

NovaCart uses **Firebase Authentication with email and password** as the sole authentication method.

### Implementation Details

- **Login:** `FirebaseAuth.instance.signInWithEmailAndPassword()` is called from `LoginPage`. The form validates that the email field is non-empty and contains an `@` symbol, and that the password field is non-empty.
- **Registration:** `FirebaseAuth.instance.createUserWithEmailAndPassword()` is called from `SignUpPage`. The form includes email, password, and confirm password fields. Password confirmation is validated to match the original password.
- **Auth State Routing:** `AuthGate` is a `StreamBuilder<User?>` listening to `FirebaseAuth.instance.authStateChanges()`. When `snapshot.hasData` is true (user is authenticated), the `HomeShell` is displayed. Otherwise, `LoginPage` is shown. While the connection state is waiting, a `SplashScreen` with a loading indicator is displayed.
- **Logout:** `FirebaseAuth.instance.signOut()` is called from the Profile page. Because `AuthGate` reactively listens to auth state, the UI automatically returns to the login screen.
- **Error Handling:** Firebase `FirebaseAuthException` codes are mapped to user-friendly error messages. Handled codes include `invalid-credential`, `invalid-email`, `user-disabled`, `too-many-requests`, `email-already-in-use`, and `weak-password`.
- **User UID:** The authenticated user's `uid` is used as the `userId` field when creating orders and when querying orders. This ensures that each user can only access their own order data.

---

## Firestore Database Design

NovaCart uses three Firestore collections:

### `products` Collection

Each document represents a product in the catalog.

| Field | Type | Description |
|---|---|---|
| `name` | String | Product name |
| `description` | String | Product description |
| `price` | Number | Price in INR |
| `category` | String | Product category (Tech, Fashion, Home, Lifestyle) |
| `rating` | Number | Product rating (0.0–5.0) |
| `imageUrl` | String | URL to the product image (Unsplash) |
| `featured` | Boolean | Whether the product appears on the Home page |

Document IDs are deterministic strings set during seeding (e.g., `nova_x1_headphones`).

### `orders` Collection

Each document represents a completed order.

| Field | Type | Description |
|---|---|---|
| `userId` | String | Firebase Auth UID of the ordering user |
| `orderId` | String | Application-generated order ID (e.g., `NC-47839251`) |
| `items` | Array | List of ordered items (see below) |
| `subtotal` | Number | Sum of (price × quantity) for all items |
| `deliveryFee` | Number | Delivery fee (currently 0) |
| `total` | Number | Final total amount |
| `paymentMethod` | String | "Card", "UPI", or "COD" |
| `paymentStatus` | String | "paid" or "pending" |
| `orderStatus` | String | "placed" (default on creation) |
| `address` | Map | Delivery address (see below) |
| `createdAt` | Timestamp | Server-generated timestamp |

**Order Item (nested in `items` array):**

| Field | Type | Description |
|---|---|---|
| `productId` | String | Product document ID |
| `name` | String | Product name at time of purchase |
| `price` | Number | Unit price at time of purchase |
| `quantity` | Number | Quantity ordered |
| `imageUrl` | String | Product image URL |

**Address (nested map):**

| Field | Type | Description |
|---|---|---|
| `name` | String | Recipient full name |
| `phone` | String | Recipient phone number |
| `address` | String | Street address |
| `city` | String | City |
| `state` | String | State |
| `pinCode` | String | PIN code |

The document ID for each order is set to the `orderId` value, ensuring a one-to-one mapping.

### Composite Index Requirement

The `getUserOrders()` query filters by `userId` and orders by `createdAt` descending. This requires a **composite index** in Firestore:

- Collection: `orders`
- Fields: `userId` (Ascending), `createdAt` (Descending)

If this index does not exist, Firestore returns a `FAILED_PRECONDITION` error with a direct link to create the required index in the Firebase Console.

---

## Firestore Security

The Firestore security rules enforce the following access control:

### Products

- **Read:** Allowed for any authenticated user.
- **Write:** Disabled for client applications. Product data is managed through the Firebase Console or seeding utilities during development.

### Users

- Users can read and write only their own user document (matched by `request.auth.uid`).

### Orders

- **Create:** Allowed only if the authenticated user's UID matches the `userId` field in the order being created, and the `orderId` field matches the document ID.
- **Read:** Allowed only if the authenticated user's UID matches the `userId` field in the existing order document.
- **Update/Delete:** Disabled. Once an order is created, it cannot be modified or deleted by client applications.

These rules ensure that:
- No user can read or create orders on behalf of another user.
- No user can modify or delete their own orders after creation.
- The product catalog is read-only from the client side.

---

## Cart State Management

The shopping cart is managed by `CartProvider`, which extends `ChangeNotifier` and is provided to the entire widget tree via `ChangeNotifierProvider` at the application root.

### CartItem

```dart
class CartItem {
  final Product product;
  int quantity;  // Defaults to 1
}
```

### CartProvider

The internal data structure is a `Map<String, CartItem>` keyed by product ID. This prevents duplicate entries — adding the same product increments the existing quantity instead.

**Key methods:**

| Method | Behavior |
|---|---|
| `addProduct(Product)` | If the product is already in the cart, increments its quantity by 1. Otherwise, adds a new `CartItem` with quantity 1. |
| `removeProduct(Product)` | If quantity > 1, decrements by 1. If quantity is 1, removes the item entirely. |
| `increaseQuantity(Product)` | Delegates to `addProduct`. |
| `decreaseQuantity(Product)` | Delegates to `removeProduct`. |
| `removeItem(Product)` | Removes the item regardless of quantity. |
| `clearCart()` | Removes all items. |
| `containsProduct(Product)` | Returns `true` if the product is in the cart. |
| `quantityFor(Product)` | Returns the current quantity for a product (0 if not in cart). |
| `totalItems` | Returns the sum of all item quantities. |
| `subtotal` | Returns the sum of `price × quantity` across all items. |

All mutating methods call `notifyListeners()`, which triggers UI rebuilds for any widgets using `Consumer<CartProvider>` or `context.watch<CartProvider>()`.

**Note:** Cart state is held in memory only. It is not persisted to Firestore or local storage. Closing the app clears the cart.

---

## Checkout and Order Creation

The checkout process follows these steps:

1. **Cart Review** — The user reviews cart items on the Cart page and taps "Proceed to Checkout."
2. **Address Input** — The Checkout page presents a validated form with fields for full name, phone number, street address, city, state, and PIN code. All fields are required.
3. **Order Summary** — Below the address form, each cart item is listed with a thumbnail, name, quantity, and line total. Subtotal, delivery fee (free), and total are displayed.
4. **Payment** — Tapping "Proceed to Payment" creates an `Address` object from the form data and navigates to `MockPaymentPage` with the address, subtotal, total, and a list of `OrderItem` objects built from the cart.
5. **Mock Payment Processing** — The user selects a payment method and submits. After a 2-second simulated delay, an `OrderModel` is constructed and written to Firestore via `OrderService.createOrder()`.
6. **Cart Clearing** — The cart is cleared only after the Firestore write succeeds.
7. **Success Screen** — `PaymentSuccessPage` displays the order ID and a "Continue Shopping" button that returns to the home shell.

**Failure handling:** If the Firestore write fails, a SnackBar error is shown and the cart is not cleared, allowing the user to retry.

---

## Mock Payment

> **This project uses a simulated payment flow for demonstration purposes. No real financial transaction is performed. No payment gateway is integrated.**

### Supported Methods

| Method | Form Fields | Payment Status on Order |
|---|---|---|
| Credit / Debit Card | Card number, Expiry (MM/YY), CVV, Cardholder name | `paid` |
| UPI | UPI ID | `paid` |
| Cash on Delivery | None | `pending` |

### Important Security Notes

- Card numbers, CVV, expiry dates, and UPI IDs are used **only for local form validation** within the mock payment screen.
- These values are **never stored** in Firestore, transmitted to any server, or persisted in any way.
- The only payment-related data written to the Firestore order document is:
  - `paymentMethod`: "Card", "UPI", or "COD"
  - `paymentStatus`: "paid" or "pending"

---

## Notification System

NovaCart integrates Firebase Cloud Messaging (FCM) for push notification support.

### NotificationService

`NotificationService` is a singleton that initializes on app startup without blocking the main thread. Its `init()` method is called from `main()` as a fire-and-forget future.

### Initialization Steps

1. **Permission Request** — Calls `FirebaseMessaging.instance.requestPermission()` for alert, badge, and sound permissions.
2. **Local Notifications Setup** — Initializes `FlutterLocalNotificationsPlugin` with the app's launcher icon and registers a callback for notification tap responses.
3. **Notification Channel** — Creates an Android notification channel named "NovaCart Notifications" with high importance for heads-up display.
4. **Background Handler** — Registers a top-level background message handler function annotated with `@pragma('vm:entry-point')`.
5. **Foreground Listener** — Listens to `FirebaseMessaging.onMessage` and displays incoming notifications using `flutter_local_notifications` while the app is in the foreground.
6. **Tap Handling** — Listens to `FirebaseMessaging.onMessageOpenedApp` (background tap) and checks `getInitialMessage()` (terminated tap). Both emit the `orderId` from the message data to a broadcast stream.
7. **FCM Token** — Retrieves the device FCM token for potential server-side use.

### Navigation on Tap

`HomeShell` subscribes to `NotificationService.instance.onNotificationTap` and switches to the Orders tab (index 3) when a notification is tapped.

### Android Configuration

The `AndroidManifest.xml` includes:
- An intent filter for `FLUTTER_NOTIFICATION_CLICK` on the main activity.
- Metadata for the default notification channel ID (`novacart_high_importance_channel`).
- Metadata for the default notification icon (`@mipmap/ic_launcher`).

### Non-Blocking Design

If notification initialization fails (e.g., on an emulator without Google Play Services), the error is caught and logged via `debugPrint`. The app continues to function normally. Notification initialization does not block app startup.

### Server-Side Notes

The Flutter client does not contain Firebase Admin credentials or FCM server keys. In a production environment, server-triggered notifications (e.g., "Your order has shipped") would be sent via Cloud Functions or another trusted backend that stores device FCM tokens securely.

---

## UI and UX Design

### Design System

- **Material 3** with `ColorScheme.fromSeed()` for consistent, adaptive color theming.
- **Primary accent:** Purple (`#635BFF` light / `#8B83FF` dark).
- **Rounded corners:** 16–28px border radius used consistently on cards, buttons, inputs, and containers.
- **Custom input fields:** Filled inputs with no visible border in the default state, and a purple accent border on focus.

### Navigation

- Five-tab bottom `NavigationBar`: Home, Search, Cart, Orders, Profile.
- `IndexedStack` preserves page state when switching tabs.
- Cart badge on the navigation bar shows the total item count, updated reactively.

### Responsive States

- **Loading states:** `CircularProgressIndicator` displayed while Firestore streams are in `ConnectionState.waiting`.
- **Error states:** Dedicated error widgets with descriptive messages (e.g., "Could not load products" with network advice).
- **Empty states:** Contextual empty state widgets with relevant icons and action buttons (e.g., "Your cart is empty" with "Continue Shopping," "No orders yet" with "Start Shopping").
- **Image error handling:** `Image.network` widgets include `errorBuilder` callbacks that display placeholder icons when images fail to load.

### Animations

- Favorite button on the Product Details page uses `AnimatedSwitcher` with a `ScaleTransition` for a smooth toggle effect.
- Payment processing uses a `CircularProgressIndicator` overlay on the pay button during the simulated delay.

---

## Error Handling

| Scenario | Handling |
|---|---|
| Firebase Auth errors (wrong password, email in use, weak password, etc.) | Mapped to user-friendly messages via `_firebaseError()` and displayed in a SnackBar. |
| Firestore query failures (network, permission, missing index) | Error state widget with descriptive message and a Retry button (Orders page). |
| Product image loading failure | `errorBuilder` on `Image.network` displays a placeholder icon (`Icons.image_not_supported_outlined`). |
| Empty product catalog | Empty state widget with an inventory icon and message. |
| Empty search results | Placeholder page with "No products found" message. |
| Unauthenticated access to orders | Orders page displays "Not authenticated" if `currentUser` is null. |
| Payment/order creation failure | SnackBar error message displayed. Cart is not cleared, allowing retry. |
| Notification initialization failure | Caught by try/catch in `NotificationService.init()`. Error logged, app continues normally. |
| Form validation failures | `TextFormField` validators return error messages displayed inline. Form submission is blocked until all fields are valid. |

---

## Security Considerations

### What is Protected

- **Firebase Authentication** ensures that only registered users can access the application's data.
- **Firestore Security Rules** enforce server-side access control. Users can only read their own orders and can only create orders where the `userId` matches their authenticated UID.
- **No sensitive payment data** (card numbers, CVVs, expiry dates, UPI IDs) is stored in Firestore or transmitted outside the device.
- **No Firebase Admin credentials** are present in the Flutter codebase.
- **No private server keys** or FCM server secrets are included in the client application.
- **Order immutability** is enforced by Firestore rules: once created, orders cannot be updated or deleted by client applications.

### firebase_options.dart

The `firebase_options.dart` file is generated by the FlutterFire CLI and contains **client-side Firebase configuration** (API keys, project ID, app ID, messaging sender ID). These are intended for use in client applications and are analogous to the `google-services.json` file for Android. They identify the Firebase project to the client but do not grant administrative access. Administrative access requires separate service account credentials that are not included in this project.

### .gitignore

The `.gitignore` file excludes build artifacts, IDE configuration files, the `.dart_tool/` directory, and Flutter plugin caches. For production use, additional entries for `google-services.json` and any `.env` files containing secrets would be recommended.

---

## Setup and Installation

### Prerequisites

- **Flutter SDK** (version 3.12.2 or later)
- **Dart SDK** (bundled with Flutter)
- **Android Studio** with Android SDK
- **Android emulator** or a physical Android device
- **Firebase project** with Authentication, Cloud Firestore, and Cloud Messaging enabled
- **FlutterFire CLI** for Firebase configuration (`dart pub global activate flutterfire_cli`)

### Firebase Configuration

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Email/Password** authentication in the Authentication section.
3. Create a **Cloud Firestore** database (start in test mode or configure security rules).
4. Run `flutterfire configure` in the project root to generate `firebase_options.dart` and `google-services.json`.
5. Create the required **composite index** for the orders query:
   - Collection: `orders`
   - Fields: `userId` (Ascending), `createdAt` (Descending)

### Install Dependencies

```bash
flutter pub get
```

---

## Running the Project

1. Clone the repository and open the project in Android Studio or your preferred IDE.
2. Ensure a Firebase project is configured (see Setup and Installation).
3. Connect an Android device or start an Android emulator.
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Run the application:
   ```bash
   flutter run
   ```
6. To build a release APK:
   ```bash
   flutter build apk --release
   ```

---

## Firestore Initial Data and Seeding

The product catalog is populated using `ProductSeedService`, a development utility that writes 15 demo products to the Firestore `products` collection.

### Seeded Products

| Category | Products |
|---|---|
| Tech (4) | Nova X1 Headphones, Nova AirPods Pro, Nova Smart Speaker, Nova Mechanical Keyboard |
| Fashion (4) | Urban Oversized Hoodie, Essential Sneakers, Classic Denim Jacket, Minimal Leather Backpack |
| Home (4) | Aura Desk Lamp, Nordic Ceramic Vase, Cloud Soft Cushion, Minimal Wall Clock |
| Lifestyle (3) | Nova Smart Watch, Stainless Steel Bottle, Everyday Travel Organizer |

### Seeding Behavior

- Products use **deterministic document IDs** (e.g., `nova_x1_headphones`), so repeated seeding updates existing documents rather than creating duplicates.
- Seeding is performed via a Firestore **batch write** with `SetOptions(merge: true)`.
- Product images are sourced from Unsplash URLs.
- Prices are in INR (Indian Rupees) and range from ₹599 to ₹18,999.
- Six of the fifteen products are marked as `featured: true`.

### Production Status

The `[DEV] Seed Products` button has been **removed from the production UI**. The `ProductSeedService` class remains in the codebase as a development utility but is not imported or used in the final application. It can be accessed programmatically if re-seeding is needed.

---

## Testing and Verification

### Static Analysis

```bash
flutter analyze
```

**Result: No issues found.**

The codebase has zero warnings, zero errors, and zero info-level issues.

### Release Build

```bash
flutter build apk --release
```

**Result: Build successful.**

- APK size: approximately **50.9 MB**
- Material Icons font was tree-shaken (99.6% reduction).
- Java deprecation and unchecked-operations notes from third-party Firebase dependencies are informational only and do not affect the build or runtime behavior.

### Functional Testing

The following features were manually tested on an Android emulator (sdk gphone16k x86_64):

| Feature | Status |
|---|---|
| Email/password login | Verified |
| Email/password registration | Verified |
| Auth state persistence across app restart | Verified |
| Logout and return to login screen | Verified |
| Home page with featured products from Firestore | Verified |
| Product card image loading and error handling | Verified |
| Category chips on Home page | Verified |
| Search with text input | Verified |
| Search with category filter | Verified |
| Combined text + category search | Verified |
| Empty search state | Verified |
| Product Details page (image, info, rating, description) | Verified |
| Favorite toggle animation | Verified |
| Add to Cart from Product Details | Verified |
| Cart badge count on navigation bar | Verified |
| Cart item quantity increment/decrement | Verified |
| Cart item removal | Verified |
| Empty cart state | Verified |
| Checkout address form with validation | Verified |
| Checkout order summary | Verified |
| Mock payment — Card method | Verified |
| Mock payment — UPI method | Verified |
| Mock payment — COD method | Verified |
| Payment success screen | Verified |
| Order creation in Firestore | Verified |
| Orders page with order history | Verified |
| Order Details page | Verified |
| FCM notification permission request | Verified |
| FCM token retrieval | Verified |
| Notification permission status on Profile page | Verified |
| Dark mode toggle | Verified |
| Light mode | Verified |
| Dark mode | Verified |
| Release APK build | Verified |

---

## Release APK

The release APK is generated at:

```
build/app/outputs/flutter-apk/app-release.apk
```

- **Size:** Approximately 50.9 MB
- **Signing:** Debug signing keys (for development and testing purposes)
- **Target:** Android

For Google Play Store distribution, a proper signing key configuration would be required in `android/app/build.gradle.kts`.

---

## Limitations

- **Mock payment only.** No real payment gateway (Razorpay, Stripe, etc.) is integrated. No actual financial transactions occur.
- **Cart is in-memory only.** Cart contents are lost when the app is closed or the user logs out. Cart data is not persisted to Firestore or local storage.
- **Favorite state is local only.** The favorite toggle on the Product Details page is held in widget state and is not persisted.
- **Product catalog is static demo data.** Products are seeded once and cannot be managed through the app. There is no admin panel or product CRUD functionality.
- **No delivery/shipping integration.** Delivery is always shown as free. There is no real delivery tracking or logistics integration.
- **Notification sending requires a backend.** The client can receive and display FCM notifications, but sending notifications (e.g., "Order shipped") requires a trusted server or Cloud Functions, which are not included in this project.
- **No user profile editing.** The user's display name and profile photo cannot be updated from within the app.
- **Single sign-in method.** Only email/password authentication is supported. Google Sign-In, phone auth, and other providers are not implemented.
- **Debug signing on release APK.** The release build uses debug signing keys and is not ready for Play Store submission without proper key configuration.

---

## Future Enhancements

The following features are **not currently implemented** but represent realistic next steps:

- **Real payment gateway integration** (Razorpay, Stripe, or similar) with proper PCI compliance.
- **Cloud Functions** for automated order status notifications (e.g., "Your order has been shipped").
- **Persistent cart** stored in Firestore or local storage, synced across sessions.
- **Admin dashboard** for product and order management.
- **Product reviews and ratings** submitted by users and stored in Firestore.
- **Wishlist persistence** using a Firestore subcollection per user.
- **Google Sign-In and phone authentication** as additional sign-in methods.
- **Coupon and discount system** with server-validated codes.
- **Delivery tracking** with real-time status updates.
- **Multiple saved addresses** with address selection at checkout.
- **Order cancellation and refund workflow.**
- **Product image gallery** with multiple images per product.
- **Inventory management** with stock tracking and out-of-stock handling.
- **Analytics integration** using Firebase Analytics.
- **Proper release signing** with a production keystore for Play Store distribution.

---

## Learning Outcomes

This project demonstrates practical experience with the following technical skills:

- **Flutter application development** — Building a multi-screen mobile application with complex navigation, form handling, and responsive layouts.
- **Dart programming** — Asynchronous programming with `async/await`, `Streams`, `StreamBuilder`, `Future`, error handling with `try/catch`, and object-oriented design with data models.
- **Firebase Authentication** — Implementing email/password login and registration, handling authentication state reactively, and using user UIDs for data scoping.
- **Cloud Firestore** — Designing document-based data models, performing real-time queries with streams, creating composite indexes, writing batch operations, and implementing security rules.
- **State management** — Using Provider and ChangeNotifier for reactive UI updates across the widget tree.
- **Form validation** — Building validated multi-field forms with `TextFormField`, `GlobalKey<FormState>`, and custom validators.
- **Push notifications** — Integrating Firebase Cloud Messaging, handling foreground/background/terminated message states, creating notification channels, and displaying local notifications.
- **Material 3 theming** — Implementing light and dark themes using `ColorScheme.fromSeed()` with consistent design tokens.
- **Release engineering** — Configuring Gradle for core library desugaring, resolving dependency version conflicts, running static analysis, and building a release APK.

---

## Internship Assignment Completion

### Week 4 — Complete E-Commerce Application

The NovaCart project represents the culmination of the Week 4 internship assignment, encompassing:

| Component | Implementation |
|---|---|
| Firebase project setup | Firebase Core, FlutterFire CLI configuration |
| Firebase Authentication | Email/password login and registration with AuthGate routing |
| Cloud Firestore integration | Product catalog, order storage, real-time streams |
| Product catalog | 15 seeded products across 4 categories with images, ratings, and descriptions |
| Product search | Text search + category filtering with combined query support |
| Product details | Full product view with image, description, rating, price, favorite toggle, and add-to-cart |
| Shopping cart | Provider-based state management with quantity controls and summary |
| Checkout flow | Validated address form with order summary |
| Mock payment | Card, UPI, and COD with simulated processing and Firestore order creation |
| Order history | User-specific order listing with status badges and detailed order view |
| FCM notifications | Permission handling, foreground display, background handling, tap navigation |
| Dark mode | Material 3 light/dark theme with user toggle |
| Production cleanup | Debug logs removed, dev UI removed, secret scan, zero analysis issues |
| Release APK | Successfully built at approximately 50.9 MB |

---

## Author

Author: Md Noor Hasan Ansari
