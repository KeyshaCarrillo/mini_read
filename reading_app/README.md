# mini_read

A Flutter project with Firebase backend integration (Core, Auth, Firestore, Storage) for Android and Web.

## Getting Started

This project uses a feature-first structure and keeps existing UI/UX untouched while adding backend services in a clean, reusable way.

## Firebase Integration Added

- Firebase Core initialization in app startup.
- Firebase Authentication integration for email/password login and register.
- Cloud Firestore access with reusable CRUD utilities.
- Firebase Storage integration for image uploads (byte-based, Android/Web compatible).
- Flutter Web compatible configuration through FlutterFire options.

## New Service Layer

- `lib/core/services/auth_service.dart`
- `lib/core/services/firestore_service.dart`
- `lib/core/services/storage_service.dart`

## How To Configure Firebase (FlutterFire CLI)

1. Install Firebase and FlutterFire CLIs:
	- `npm install -g firebase-tools`
	- `dart pub global activate flutterfire_cli`

2. Login in Firebase:
	- `firebase login`

3. From project root, run configure:
	- `flutterfire configure`

4. Select:
	- The Firebase project in your console.
	- Platforms: Android and Web (add iOS/macOS if you use them).

5. Confirm generated file:
	- `lib/firebase_options.dart`

## Connect With Firebase Console

1. Open Firebase Console and create/select your project.
2. In Authentication:
	- Enable `Email/Password` provider.
3. In Firestore Database:
	- Create database in production or test mode.
4. In Storage:
	- Create default bucket.
5. In Project Settings > Your Apps:
	- Verify Android package name is `com.example.mini_read`.
	- Verify Web app exists and matches your `firebase_options.dart` values.

## Android Compatibility Check

- Gradle wrapper: `8.14` (compatible with AGP 8.11.1).
- Android app plugin is configured with `com.google.gms.google-services`.
- Root plugin management includes Google Services plugin.
- `android/app/google-services.json` exists and package name matches app id.

## Web Compatibility Check

- `lib/firebase_options.dart` contains `DefaultFirebaseOptions.web`.
- App initializes Firebase using:
  - `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
- No legacy JS Firebase script injection is required in `web/index.html`.

## Firestore CRUD Example (Ready To Use)

Implemented in `FirebaseLibraryDataSource`:

- `createUserNote(...)`
- `updateUserNote(...)`
- `deleteUserNote(...)`
- `watchUserNotes(...)`

These methods operate in: `users/{uid}/perfiles/{profileId}/notes`.

## Storage Upload Example (Ready To Use)

Implemented in `FirebaseLibraryDataSource`:

- `uploadProfileAvatar(...)`

This uploads image bytes to Storage path:

- `users/{uid}/profiles/{profileId}/avatar.jpg`

Then writes download URL into Firestore profile document.

## Common Firebase Errors To Verify

- `firebase_core/no-app`: Firebase not initialized before use.
- `permission-denied`: Firestore/Storage rules block operation.
- `storage/object-not-found`: missing file path.
- `auth/user-not-found` or `auth/wrong-password`: invalid login credentials.
- `auth/operation-not-allowed`: auth provider not enabled in Firebase Console.

## Quick Validation Commands

- `flutter pub get`
- `flutter analyze`
- `flutter run -d chrome`
- `flutter run -d android`

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
