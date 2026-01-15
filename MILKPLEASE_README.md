# MilkPlease - Grocery List App

A beautiful, intuitive mobile app for managing your grocery shopping lists. Built with Flutter and inspired by modern apps like Instagram and Facebook.

## Features

✨ **Core Functionality**

- ➕ Add grocery items with details (name, category, quantity, unit, estimated price, notes)
- ✏️ Edit existing items
- 🗑️ Delete items from your list
- ✅ Check off completed items
- 📊 Track total items, completed items, and estimated cost

🎨 **User Experience**

- Beautiful, modern UI using GoogleFonts (Poppins font family)
- Smooth animations and transitions
- Intuitive category filters (Vegetables, Fruits, Dairy, Meat, Pantry, Frozen, Beverages, Snacks, Other)
- Color-coded categories for quick visual identification
- Empty state illustrations

📤 **Sharing**

- Generate and share grocery lists as PDF files
- PDF includes summary statistics and organized by category
- One-tap sharing via device's native share menu

💾 **Data Management**

- Local storage using SharedPreferences
- Automatic saving of items
- No internet connection required

## Getting Started

### Prerequisites

- Flutter SDK (v3.0.0+)
- Dart SDK
- iOS/Android development environment

### Installation

1. Clone the repository:

```bash
cd weshop
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── grocery_item.dart     # GroceryItem model
├── services/
│   ├── storage_service.dart  # Local storage management
│   └── pdf_service.dart      # PDF generation and sharing
├── screens/
│   └── home_screen.dart      # Main grocery list screen
├── widgets/
│   ├── grocery_item_card.dart    # Item card component
│   ├── empty_state.dart          # Empty state view
│   └── add_edit_item_dialog.dart # Add/Edit item dialog
└── theme/
    └── app_theme.dart            # App theming and styling
```

## Key Technologies

- **Flutter** - Cross-platform mobile framework
- **GoogleFonts** - Professional typography (Poppins)
- **SharedPreferences** - Local data persistence
- **PDF Package** - PDF generation
- **share_plus** - Native share functionality
- **uuid** - Unique item identification

## App Features Explained

### Add/Edit Items

Tap the **+** button to add a new item. Fill in:

- **Item Name** - What you're buying
- **Category** - Type of item (auto-fills color)
- **Quantity** - How many
- **Unit** - Measurement unit (pcs, kg, g, l, ml, etc.)
- **Estimated Price** - Optional price tracking
- **Notes** - Optional extra information

### Filter by Category

Use the category chips at the top to filter items by type. Tap "All" to see everything.

### Track Your Progress

The stats card shows:

- Total items in your list
- Items you've already collected
- Estimated total cost

### Check Off Items

Tap an item or its checkbox to mark it as purchased. Checked items show with a strikethrough.

### Share Your List

Tap the **Share PDF** button to:

1. Generate a formatted PDF of your list
2. Open device share menu
3. Send via email, messaging, or other apps

The PDF includes:

- Total items and completion status
- Estimated total cost
- Items organized by category
- Checkmark status for each item

## Customization

### Change Theme Colors

Edit `lib/theme/app_theme.dart`:

- `primaryColor` - Main brand color (Blue)
- `secondaryColor` - Accent color (Teal)
- `accentColor` - Highlight color (Red)
- `categoryColors` - Category-specific colors

### Add/Remove Categories

Edit the `categories` list in `lib/screens/home_screen.dart` and `lib/widgets/add_edit_item_dialog.dart`

### Modify Units

Edit the `units` list in `lib/widgets/add_edit_item_dialog.dart`

## Future Enhancements

- 👥 Share lists with other users
- 📱 Multi-device sync
- 🎯 Recurring items
- 📈 Shopping statistics
- 🔍 Search and sorting options
- 💬 Collaborative lists
- 📸 Photo attachments
- 🛒 Price comparison integration

## Troubleshooting

### PDF not generating?

- Ensure `path_provider` and `pdf` packages are installed
- Check device storage permissions

### Items not saving?

- Ensure `shared_preferences` package is installed
- Check app permissions

### UI looks off?

- Run `flutter pub get` to ensure all dependencies are current
- Try `flutter clean` followed by `flutter pub get`

## License

This project is open source and available for personal use.

---

**Happy Shopping! 🛒**
