# 📚 EduDoc - Flutter & Supabase Educational Platform

![EduDoc Banner](lib/assets/images/app_logo.png)

EduDoc is a premium educational document management platform built with **Flutter** and **Supabase**. It provides users with a seamless experience for browsing, purchasing, and managing educational materials, including PDFs and audio resources.

---

## 🚀 Features

- **User Authentication**: Secure login/signup using Email/Password and Google OAuth via Supabase Auth.
- **Document Marketplace**: Browse and purchase educational documents, notes, and resources.
- **Wallet System**: Integrated token-based wallet for purchasing materials and viewing transaction history.
- **PDF & Audio Support**: Built-in PDF viewer and audio player for educational content.
- **Community Features**: Product reviews, bookmarks (wishlist), and activity tracking.
- **Offline Access**: Secure local storage for downloaded materials.
- **Security**: Biometric authentication (Fingerprint/FaceID) and secure PIN protection.
- **Push Notifications**: Real-time updates for downloads and transactions.

---

## 🛠 Tech Stack

- **Frontend**: Flutter (Mobile & Web Support)
- **Backend**: Supabase (Auth, Database, Storage, Edge Functions)
- **State Management**: Provider
- **Security**: flutter_secure_storage, local_auth
- **Networking**: Dio, Supabase Client
- **UI/UX**: Google Fonts, FontAwesome, Lottie Animations

---

## 🏗 Database Schema (Supabase)

The backend is powered by PostgreSQL on Supabase. Below are the core tables and their structures:

### 1. `users` (Public Profiles)
Stores extended user information linked to Supabase Auth.
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | `uuid` | Primary Key (Matches Auth User ID) |
| `full_name` | `text` | User's full name |
| `email` | `text` | User's email address |
| `phone_num` | `text` | Contact number |
| `profile_image_url` | `text` | URL to profile picture |
| `updated_at` | `timestamp` | Last profile update |

### 2. `products`
The core catalog of educational materials.
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | `bigint` | Primary Key |
| `type` | `text` | e.g., 'Document', 'Course' |
| `title` | `text` | Title of the material |
| `price` | `int` | Price in tokens |
| `is_free` | `boolean` | Whether the item is free |
| `category` | `text` | Subject category |
| `tags` | `text[]` | Array of searchable tags |
| `pdf_url` | `text` | Link to the resource file |
| `image_url` | `text` | Cover image URL |
| `rating` | `float` | Average user rating |

### 3. `wallets` & `transactions`
Manages the user's token balance and audit trail.
- **`wallets`**: `user_id` (PK), `balance` (int)
- **`transactions`**: `id` (PK), `user_id`, `type` (Credit/Debit/Download), `amount`, `description`, `created_at`

### 4. `offers` (Bundles)
Promotional bundles containing multiple products.
- **Fields**: `id`, `title`, `cover_image_url`, `discount_label`, `token_price`, `product_ids` (int array)

### 5. `cart` & `bookmarks`
- **`cart`**: `user_id`, `product_id` (Tracks items ready for purchase)
- **`bookmarks`**: `user_id`, `product_id` (Wishlist items)
- **`owned_products`**: `user_id`, `product_id` (Library of purchased items)

### 6. `activity_logs`
System-wide audit trail for security and monitoring.
- **Fields**: `user_id`, `action` (e.g., 'Login', 'Purchase'), `entity_type`, `description`, `old_data`, `new_data`

---

## ⚡ Setup & Installation

### Prerequisites
- Flutter SDK (`>=3.0.0`)
- Supabase Account & Project
- Google Cloud Console (for Google Sign-In)

### Step 1: Clone the Project
```bash
git clone https://github.com/shwetajadhav0230-ux/edudoc_app_mdv.git
cd edudoc_app_mdv
```

### Step 2: Supabase Configuration
Create a `.env` file or update `lib/utils/config.dart` with your Supabase credentials:
```dart
const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### Step 3: Database Setup
Execute the SQL commands found in the Supabase Dashboard SQL Editor to create the tables listed above. Ensure the following RPCs are created:
- `add_tokens`
- `purchase_cart`
- `purchase_offer`

### Step 4: Install Dependencies
```bash
flutter pub get
```

### Step 5: Run the App
```bash
flutter run
```

---

## 📁 Project Structure

```text
lib/
├── assets/         # Images, Logos, Animations
├── models/         # Data Models (User, Product, etc.)
├── screens/        # UI Screens (Auth, Home, Profile, Wallet)
├── services/       # Business Logic (Supabase, Auth, Files)
├── state/          # State Management (Provider)
├── utils/          # Constants, Themes, Helpers
└── widgets/        # Reusable UI Components
```

---

## 🛡 License
Distributed under the MIT License. See `LICENSE` for more information.

---

Built with ❤️ by the EduDoc Team.
