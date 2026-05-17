# Dream Home Interior Planner

A Flutter mobile app for designing rooms by dragging furniture items.

## Setup Instructions

### Step 1 — Open in Android Studio
1. Open Android Studio
2. Click **File → Open**
3. Select the `dream_home_interior_planner` folder
4. Wait for Gradle sync to complete

### Step 2 — Get Packages
Open the Terminal inside Android Studio and run:
```
flutter pub get
```

### Step 3 — Run the App
```
flutter run
```
Or press the **Run** button (green triangle) in Android Studio.

---

## Folder Structure

```
lib/
 ┣ models/
 ┃ ┣ furniture_model.dart     → FurnitureItem, PlacedFurniture, furnitureData list
 ┃ ┗ design_model.dart        → RoomDesign, RoomCategory, roomCategories list
 ┣ providers/
 ┃ ┗ app_provider.dart        → Theme, selected furniture, saved designs (SharedPreferences)
 ┣ screens/
 ┃ ┣ splash_screen.dart       → Animated splash with logo
 ┃ ┣ home_screen.dart         → Room category grid + recent designs
 ┃ ┣ furniture_screen.dart    → Furniture catalog with category filter + Hero animation
 ┃ ┣ room_builder_screen.dart → Drag & drop canvas, image picker, save design
 ┃ ┗ saved_designs_screen.dart→ Grid of all saved designs
 ┣ widgets/
 ┃ ┣ room_card.dart           → Room category card widget
 ┃ ┣ furniture_card.dart      → Furniture item card with tap animation
 ┃ ┗ design_tile.dart         → Saved design thumbnail tile
 ┗ main.dart                  → App entry, Provider setup, routes, light/dark theme

assets/
 ┣ logo.png
 ┣ furniture/
 ┃ ┣ sofa.png, bed.png, chair.png, table.png
 ┃ ┣ lamp.png, wardrobe.png, bookshelf.png, tv_unit.png
 ┗ rooms/
   ┣ bedroom.png, living_room.png, kitchen.png, office.png
```

## Flutter Concepts Used (for Viva)

| Concept | Where Used |
|---|---|
| Navigation | `Navigator.pushNamed` + named routes in `main.dart` |
| State Management (Provider) | `AppProvider` — theme, selected furniture, saved designs |
| Hero Animation | Furniture card → Room Builder (`Hero` widget) |
| Implicit Animation | `AnimatedContainer` in category chips, `ScaleTransition` in furniture cards |
| Drag & Drop | `Draggable` + `DragTarget` in `room_builder_screen.dart` |
| Local Storage | `SharedPreferences` saving/loading `RoomDesign` as JSON |
| Image Picker | Gallery image selection for room background |
| Dark/Light Theme | `ThemeMode` toggled via Provider, `MaterialApp.themeMode` |
| Responsive UI | `MediaQuery`, `SliverGrid`, `GridView` |
| Custom Widgets | `RoomCard`, `FurnitureCard`, `DesignTile` |

## Packages Used

| Package | Version | Purpose |
|---|---|---|
| provider | ^6.1.1 | State management |
| image_picker | ^1.0.7 | Pick room background from gallery |
| shared_preferences | ^2.2.2 | Save designs locally |
| google_fonts | ^6.2.1 | Poppins typography |
| path_provider | ^2.1.2 | File path utilities |
| uuid | ^4.3.3 | Unique IDs for designs |
