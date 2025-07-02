# App Icon Setup Instructions

Since your `icons.png` file contains 4 different icon options, you'll need to:

1. **Extract the icon you want to use**:
   - Open `icons.png` in an image editor
   - Choose one of the 4 icons you prefer
   - Export it as a square PNG image (recommended size: 1024x1024 pixels)
   - Save it as `assets/icons/app_icon.png`

2. **For Android Adaptive Icons** (optional but recommended):
   - Create a foreground version of your icon with transparent background
   - Save it as `assets/icons/app_icon_foreground.png`
   - The background color is set to `#2563EB` (the app's primary blue color) in the configuration
   
   **Important distinction**:
   - `app_icon.png` - This should be your complete icon WITH background (for older Android versions and iOS)
   - `app_icon_foreground.png` - This should be ONLY the icon shape/logo with transparent background
   - The `adaptive_icon_background: "#2563EB"` in pubspec.yaml provides the background color automatically

3. **Run the icon generator**:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

4. **Rebuild your app**:
   ```bash
   flutter clean
   flutter build apk --release
   ```

## Alternative Quick Setup

If you want to use the entire `icons.png` as is (though it's not recommended since it contains 4 icons):

1. Copy the icons.png to the assets folder:
   ```bash
   cp icons.png assets/icons/app_icon.png
   cp icons.png assets/icons/app_icon_foreground.png
   ```

2. Run the commands above (steps 3 and 4)

## Note
The current configuration uses:
- Primary blue color (#2563EB) as the adaptive icon background
- This matches the MDReader's theme colors
- The icon will look good on all Android versions including Android 12+ with Material You theming