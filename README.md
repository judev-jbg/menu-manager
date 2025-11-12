# Menu Manager 🍽️

A personal Flutter application for managing daily meals and shopping lists with local persistence using SQLite.

## 📱 About

Menu Manager is a minimalist Android app designed for personal meal tracking and shopping list management. It provides an intuitive interface to record your daily meals (breakfast, lunch, dinner) and maintain a shopping list, all stored locally on your device.

## ✨ Features

### Meal Management

- 📅 Track daily meals with Spanish date formatting
- 🍳 Record breakfast, lunch, and dinner for each day
- 📌 "TODAY" badge for current day meals
- 👻 Visual effects for past dates (opacity and strikethrough)
- 🚫 Unique date validation (one meal entry per day)
- ✏️ Swipe left to edit existing meals
- 🗑️ Swipe right to delete with confirmation

### Shopping List

- 🛒 Simple item management with descriptions
- ✏️ Quick edit with swipe left
- 🗑️ Delete with swipe right and confirmation
- 📋 Creation order sorting

### User Experience

- 🎨 Clean, minimalist design
- 🔄 Real-time validation and feedback
- 📊 Dynamic item counter per tab
- 💾 Persistent local storage with SQLite
- 🌐 Spanish localization for dates
- ⚡ Fast and responsive interface

## 🛠️ Tech Stack

- **Framework:** Flutter 3.0+
- **Language:** Dart
- **Database:** SQLite (sqflite)
- **State Management:** Provider
- **UI Components:**
  - Material Design
  - Google Fonts (Inter)
  - Flutter Slidable (swipe gestures)
- **Localization:** intl package (Spanish dates)

## 📋 Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Android device or emulator

## 🚀 Installation

1. **Clone the repository**

```bash
git clone https://github.com/judev-jbg/menu-manager.git
cd menu-manager
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run the app**

```bash
flutter run
```

## 📁 Project Structure

```
menu_manager/
├── lib/
│   ├── main.dart                      # App entry point and theme
│   ├── models/                        # Data models
│   │   ├── meal_day.dart             # Meal day model
│   │   └── shopping_item.dart        # Shopping item model
│   ├── database/                      # Database layer
│   │   └── database_helper.dart      # SQLite operations
│   ├── providers/                     # State management
│   │   ├── meals_provider.dart       # Meals state
│   │   └── shopping_provider.dart    # Shopping list state
│   ├── screens/                       # App screens
│   │   └── home_screen.dart          # Main screen with tabs
│   └── widgets/                       # Reusable widgets
│       ├── meal_card.dart            # Meal display card
│       ├── shopping_card.dart        # Shopping item card
│       ├── meal_list_view.dart       # Meals list
│       ├── shopping_list_view.dart   # Shopping list
│       ├── create_meal_dialog.dart   # Meal creation/edit
│       └── create_shopping_dialog.dart # Item creation/edit
├── pubspec.yaml                       # Dependencies
└── README.md                          # This file
```

## 🎨 Design

### Color Palette

- **Background:** `#F5F5F5` (Light Gray)
- **Primary/Accent:** `#54D3C2` (Turquoise)
- **Cards:** `#FFFFFF` (White)
- **Delete:** `#FF0000` (Red)

### Typography

- **Font:** Inter (Google Fonts)
- **Date:** 16px, Bold
- **Content:** 14px, Regular

### Icons

- 🌅 Breakfast: `wb_sunny`
- 🍽️ Lunch: `restaurant`
- 🌙 Dinner: `nightlight`
- 🛒 Shopping: `shopping_basket`

## 💡 Usage

### Creating a Meal

1. Navigate to the "Comidas" tab
2. Tap the FAB (+) button
3. Select a date (defaults to today)
4. Fill in at least one meal field
5. Tap "Crear" to save

### Editing a Meal

1. Swipe left on a meal card
2. Modify the fields as needed
3. Tap "Actualizar" to save changes

### Deleting a Meal

1. Swipe right on a meal card
2. Confirm deletion in the dialog

### Managing Shopping List

1. Navigate to the "Lista de Compras" tab
2. Tap the FAB (+) button
3. Enter item description
4. Tap "Crear" or press Enter
5. Swipe left to edit, swipe right to delete

## 🏗️ Architecture

The app follows a clean architecture pattern with separation of concerns:

- **Models:** Plain Dart classes with data validation
- **Database:** Singleton pattern for SQLite operations
- **Providers:** ChangeNotifier for reactive state management
- **Widgets:** Composable UI components
- **Screens:** Main app screens coordinating widgets

### Key Design Patterns

- Singleton (DatabaseHelper)
- Provider (State Management)
- Repository Pattern (CRUD operations)
- Builder Pattern (UI composition)

## 🔒 Data Persistence

All data is stored locally using SQLite with two main tables:

### meal_days

- `id`: Primary key
- `date`: Unique date (YYYY-MM-DD)
- `breakfast`, `lunch`, `dinner`: Meal descriptions
- `created_at`: Timestamp

### shopping_items

- `id`: Primary key
- `description`: Item description
- `created_at`: Timestamp for sorting

## 🧪 Testing

The app includes database validation and UI state management testing through:

- CRUD operation verification
- Date uniqueness validation
- Empty state handling
- Error state management

## 🚧 Future Improvements

- [ ] Custom GestureDetector for automatic swipe execution
- [ ] Meal search and filtering by date
- [ ] Shopping list export functionality
- [ ] Meal statistics and insights
- [ ] Dark mode support
- [ ] Cloud backup (optional)

## 📄 License

This project is a personal application and is available for reference and learning purposes.

## 👤 Author

**Judev**

- GitHub: [@judev-jbg](https://github.com/judev-jbg)
- Project: [Menu Manager](https://github.com/judev-jbg/menu-manager)

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Icons from [Material Design](https://material.io/design)
- Fonts by [Google Fonts](https://fonts.google.com/)

---

Made with ❤️ for personal meal and shopping management
