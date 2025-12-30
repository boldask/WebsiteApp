# Boldask Implementation Guide

This document provides instructions for setting up and deploying the Boldask application.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Firebase Setup](#firebase-setup)
3. [Project Setup](#project-setup)
4. [Running the App](#running-the-app)
5. [Deployment](#deployment)
6. [Content Management](#content-management)
7. [Project Structure](#project-structure)

---

## Prerequisites

### Required Software
- **Flutter SDK** 3.2.0 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK** (included with Flutter)
- **Node.js** 18+ (for Firebase CLI)
- **Firebase CLI** (`npm install -g firebase-tools`)
- **Git**

### For iOS Development
- macOS with Xcode 14+
- Apple Developer Account (for App Store deployment)
- CocoaPods (`sudo gem install cocoapods`)

### For Android Development
- Android Studio with SDK
- Google Play Developer Account (for Play Store deployment)

---

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project" and name it "boldask"
3. Enable Google Analytics (optional)
4. Wait for project creation

### 2. Enable Authentication

1. In Firebase Console → Authentication → Sign-in method
2. Enable **Email/Password** provider
3. (Optional) Configure password reset email template

### 3. Set Up Firestore Database

1. Go to Firestore Database → Create database
2. Start in **production mode**
3. Choose a region close to your users

#### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Polls collection
    match /polls/{pollId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null &&
        get(/databases/$(database)/documents/polls/$(pollId)).data.creatorUid == request.auth.uid;
    }

    // Circles collection
    match /circles/{circleId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null &&
        get(/databases/$(database)/documents/circles/$(circleId)).data.creatorUid == request.auth.uid;
    }

    // Site content (public read)
    match /site_content/{document} {
      allow read: if true;
      allow write: if false; // Admin only via console
    }

    // News (public read)
    match /news/{articleId} {
      allow read: if resource.data.isPublished == true;
      allow write: if false; // Admin only via console
    }

    // App config
    match /app_config/{document} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

### 4. Set Up Firebase Storage

1. Go to Storage → Get started
2. Start in production mode

#### Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile photos
    match /profile_photos/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Content images
    match /content/{path=**} {
      allow read: if true;
      allow write: if false; // Admin only
    }
  }
}
```

### 5. Generate Firebase Configuration

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
cd /path/to/boldask
flutterfire configure --project=your-firebase-project-id
```

This will create `lib/firebase_options.dart` with your configuration.

### 6. Update main.dart

```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(/* ... */);
}
```

---

## Project Setup

### 1. Clone and Install Dependencies

```bash
cd /path/to/boldask
flutter pub get
```

### 2. Add Assets

Place your brand assets in the `assets/` folder:

```
assets/
├── images/
│   ├── logofinal.png        # Main logo (wordmark)
│   ├── logosmall.png        # Small icon logo
│   └── backgrounds/
│       ├── login_bg.png     # Login screen background
│       └── home_bg.png      # Home screen background
└── fonts/
    └── BoldaskIcons.ttf     # Custom icon font (optional)
```

### 3. iOS Setup

```bash
cd ios
pod install
cd ..
```

Update `ios/Runner/Info.plist` for location permissions:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Boldask uses your location to show nearby polls and circles.</string>
```

### 4. Android Setup

Update `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

---

## Running the App

### Development

```bash
# Run on connected device/emulator
flutter run

# Run on Chrome (web)
flutter run -d chrome

# Run on specific device
flutter devices  # List available devices
flutter run -d <device_id>
```

### Hot Reload
Press `r` in terminal for hot reload, `R` for hot restart.

---

## Deployment

### Web (Firebase Hosting)

```bash
# Build web version
flutter build web --release

# Deploy to Firebase Hosting
firebase login
firebase init hosting  # Select your project, use 'build/web' as public directory
firebase deploy --only hosting
```

Your app will be available at: `https://your-project-id.web.app`

For custom domain (boldask.com):
1. Firebase Console → Hosting → Add custom domain
2. Follow DNS verification steps

### iOS (App Store)

1. **Configure signing**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select your team and bundle identifier
   - Configure provisioning profiles

2. **Build archive**:
   ```bash
   flutter build ipa --release
   ```

3. **Upload to App Store Connect**:
   - Use Xcode's Organizer or `xcrun altool`
   - Submit for review in App Store Connect

### Android (Play Store)

1. **Create keystore**:
   ```bash
   keytool -genkey -v -keystore ~/boldask-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias boldask
   ```

2. **Configure signing** in `android/key.properties`:
   ```
   storePassword=your_password
   keyPassword=your_key_password
   keyAlias=boldask
   storeFile=/path/to/boldask-release.jks
   ```

3. **Build**:
   ```bash
   flutter build appbundle --release
   ```

4. **Upload** to Google Play Console

---

## Content Management

### Updating Content via Firebase Console

#### Landing Page Content
Edit `site_content/landing` document:
```json
{
  "heroTitle": "Ask Bold Questions",
  "heroSubtitle": "Join the community that values curiosity",
  "ctaButtonText": "Get Started",
  "features": [...]
}
```

#### Adding News Articles
Add documents to `news` collection:
```json
{
  "title": "New Feature Released",
  "content": "We're excited to announce...",
  "imageUrl": "https://...",
  "category": "Updates",
  "publishedAt": timestamp,
  "isPublished": true
}
```

#### Uploading Images
1. Go to Firebase Storage
2. Upload to `content/` folder
3. Copy the download URL
4. Use URL in Firestore documents

---

## Project Structure

```
boldask/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── app.dart                  # MaterialApp configuration
│   ├── firebase_options.dart     # Firebase config (generated)
│   │
│   ├── config/                   # Configuration
│   │   ├── routes.dart           # Navigation routes
│   │   ├── theme.dart            # App theme
│   │   └── constants.dart        # Constants & enums
│   │
│   ├── models/                   # Data models
│   │   ├── user_model.dart
│   │   ├── poll_model.dart
│   │   ├── circle_model.dart
│   │   └── project_model.dart
│   │
│   ├── services/                 # Backend services
│   │   ├── auth_service.dart     # Firebase Auth
│   │   ├── database_service.dart # Firestore
│   │   ├── storage_service.dart  # Firebase Storage
│   │   └── location_service.dart # Geolocation
│   │
│   ├── providers/                # State management
│   │   ├── auth_provider.dart
│   │   ├── user_provider.dart
│   │   ├── polls_provider.dart
│   │   ├── circles_provider.dart
│   │   └── app_state_provider.dart
│   │
│   ├── widgets/                  # Reusable widgets
│   │   ├── common/               # App scaffold, nav, loading
│   │   ├── forms/                # Text fields, tag selector
│   │   ├── cards/                # Poll, circle, user cards
│   │   └── buttons/              # Primary, secondary buttons
│   │
│   ├── screens/                  # Page screens
│   │   ├── landing/              # Public website pages
│   │   ├── auth/                 # Login, signup, onboarding
│   │   ├── home/                 # Main app tabs
│   │   ├── polls/                # Poll features
│   │   ├── circles/              # Circle features
│   │   ├── profile/              # User profile
│   │   ├── social/               # Following management
│   │   ├── settings/             # Account settings
│   │   └── coming_soon/          # Placeholder screens
│   │
│   └── utils/                    # Utilities
│       ├── validators.dart       # Form validation
│       └── helpers.dart          # Helper functions
│
├── assets/                       # Static assets
│   ├── images/
│   └── fonts/
│
├── web/                          # Web config
├── ios/                          # iOS config
├── android/                      # Android config
├── pubspec.yaml                  # Dependencies
└── docs/
    └── implementation.md         # This file
```

---

## Troubleshooting

### Common Issues

**Firebase not initializing**
- Ensure `firebase_options.dart` exists and is imported
- Check that you've run `flutterfire configure`

**Web CORS errors**
- Configure Firebase Storage CORS rules
- Ensure Firebase Hosting is properly set up

**iOS build fails**
- Run `cd ios && pod install`
- Check Xcode signing configuration

**Android build fails**
- Ensure `key.properties` is configured
- Check minSdkVersion in `android/app/build.gradle` (should be 21+)

### Getting Help

- Flutter docs: https://docs.flutter.dev
- Firebase docs: https://firebase.google.com/docs
- Report issues: [Your GitHub repo]

---

## Next Steps

1. **Set up Firebase** following the steps above
2. **Add your brand assets** to the assets folder
3. **Test locally** with `flutter run`
4. **Deploy to web** for initial testing
5. **Prepare app store listings** (screenshots, descriptions)
6. **Submit for review** to App Store and Play Store

---

*Generated for Boldask - Community engagement platform*
