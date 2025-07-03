# Google Play Store Deployment Guide

This guide outlines the steps to deploy your MDReader Flutter app to the Google Play Store.

## Prerequisites

- Flutter app already deployed to Firebase
- Google Play Console Developer Account ($25 one-time fee)
- Android development environment set up

## Step 1: Create Release Signing Key

Generate a keystore for signing your release builds:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important:** 
- Store the keystore file and passwords securely
- You'll need these for all future app updates
- Losing this keystore means you cannot update your app

## Step 2: Configure Signing

1. Create a key properties file:

```bash
echo "storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD  
keyAlias=upload
storeFile=../upload-keystore.jks" > android/key.properties
```

2. Update `android/app/build.gradle.kts` to use the signing configuration:

Add before the `android` block:
```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Update the `buildTypes` section:
```kotlin
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

Add signing configs:
```kotlin
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

## Step 3: Build Release App Bundle

```bash
flutter build appbundle --release
```

The AAB file will be generated at: `build/app/outputs/bundle/release/app-release.aab`

## Step 4: Prepare Play Store Assets

### Required Assets:
1. **App Icon** - 512x512 PNG (already configured in pubspec.yaml)
2. **Feature Graphic** - 1024x500 PNG
3. **Screenshots** - At least 2 for phone, tablet optional
4. **App Description** - Short (80 chars) and full description
5. **Privacy Policy** - Required for apps handling user data

### App Store Listing Information:
- **App Name:** MDReader
- **Short Description:** Read and organize markdown documents offline with customizable themes
- **Full Description:** 
```
MDReader is a simple offline Markdown reader that allows you to read and view Markdown files without any internet connection. Perfect for developers, writers, and anyone who works with Markdown documents.

Features:
• Complete offline functionality
• Beautiful syntax highlighting
• Customizable themes
• No data collection or tracking
• Support for standard Markdown formatting
```

## Step 5: Google Play Console Setup

1. **Create App Listing:**
   - Go to Google Play Console
   - Create new app
   - Choose app name and default language
   - Select app or game type

2. **Complete App Content:**
   - Upload app bundle (AAB file)
   - Add store listing details
   - Upload required graphics
   - Set content rating
   - Complete privacy policy requirements

3. **Release Management:**
   - Choose release track (Internal testing → Alpha → Beta → Production)
   - Upload your AAB file
   - Complete release notes

## Step 6: Content Rating & Policies

1. **Content Rating Questionnaire:**
   - Complete Google Play's content rating questionnaire
   - MDReader should receive an "Everyone" rating

2. **Privacy Policy:**
   - Create a privacy policy (required)
   - Host it on a publicly accessible URL
   - Add the URL to your app listing

3. **App Category:**
   - Productivity or Tools category recommended

## Step 7: Testing & Release

1. **Internal Testing:**
   - Upload to internal testing first
   - Test the signed APK thoroughly
   - Verify all features work correctly

2. **Staged Rollout:**
   - Start with a small percentage release
   - Monitor for crashes or issues
   - Gradually increase rollout percentage

## Version Management

Current app version: 1.0.2+3 (from pubspec.yaml)
- Version name: 1.0.2 (user-facing)
- Version code: 3 (internal tracking)

For updates, increment these values in pubspec.yaml before building.

## Important Notes

- **Bundle Size:** Current app should be under 10MB
- **Target SDK:** Ensure you're targeting latest Android API level
- **Permissions:** Review AndroidManifest.xml for required permissions
- **Testing:** Test on multiple device types and Android versions
- **Store Optimization:** Use relevant keywords in your app description

## Troubleshooting

### Common Issues:
1. **Signing errors:** Verify keystore path and passwords
2. **Upload failures:** Check AAB file size and format
3. **Policy violations:** Ensure privacy policy is accessible
4. **Content rating:** Complete all required questionnaires

### Useful Commands:
```bash
# Check app bundle contents
bundletool build-apks --bundle=app-release.aab --output=app.apks

# Test release build locally
flutter build apk --release
flutter install --release
```

## Next Steps After Upload

1. Monitor app performance in Play Console
2. Respond to user reviews
3. Plan feature updates
4. Track download and usage metrics
5. Consider implementing in-app feedback