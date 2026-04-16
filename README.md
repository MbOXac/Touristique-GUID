# Touristique GUID

A Flutter tourist guide app showcasing the beauty of **Southeast Morocco** — ancient kasbahs, Sahara dunes, dramatic gorges, and lush oases.

## Features

- **Splash Screen** – Animated fade/scale, auto-navigates after 2.5 s
- **Welcome Screen** – Full-bleed hero image with description and "Get Started" button
- **Home Screen** – 4 destination cards (Kasbah & Valleys, Merzouga Desert, Todra Gorge, Oasis & Palmeraies) with rating and distance
- **Morocco-inspired theme** – Desert orange, deep blue, earth tones, Material 3

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── destination.dart
├── screens/
│   ├── splash_page.dart
│   ├── welcome_page.dart
│   └── home_page.dart
├── theme/
│   └── app_theme.dart
└── widgets/
    └── destination_card.dart
assets/
└── images/
    ├── splash.jpg
    ├── welcome.jpg
    ├── destination_1.jpg  (Kasbah & Valleys)
    ├── destination_2.jpg  (Merzouga Desert)
    ├── destination_3.jpg  (Todra Gorge)
    └── destination_4.jpg  (Oasis & Palmeraies)
```

## Prerequisites

- Flutter SDK ≥ 3.0.0 ([install guide](https://docs.flutter.dev/get-started/install))
- Dart SDK ≥ 3.0.0 (bundled with Flutter)
- Android Studio / Xcode / VS Code

## How to Run

```bash
# Clone the repository
git clone https://github.com/MbOXac/Touristique-GUID.git
cd Touristique-GUID

# Install dependencies
flutter pub get

# Run on connected device / emulator
flutter run
```

## Build for Release

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

## Replacing Images

The `assets/images/` folder contains placeholder images.  
Replace them with your own photos (keep the same filenames), then run:

```bash
flutter pub get
flutter run
```

## License

MIT