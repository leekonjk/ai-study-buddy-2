# Firebase Setup Guide

This guide will help you set up Firebase configuration for the Student AI Buddy app without committing sensitive credentials to version control.

## ⚠️ Security Notice

**NEVER commit the following files to version control:**
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

These files contain API keys and are already listed in `.gitignore` to prevent accidental commits.

## Prerequisites

1. A Firebase account (https://firebase.google.com/)
2. Flutter SDK installed
3. Firebase CLI installed (optional but recommended)

## Setup Steps

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard to create your project
4. Enable Authentication, Firestore, and Storage in your Firebase project

### 2. Configure Flutter App for Firebase

#### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter app
flutterfire configure
```

This will automatically:
- Create `lib/firebase_options.dart`
- Download platform-specific configuration files
- Set up your Firebase project

#### Option B: Manual Configuration

If you prefer manual setup or the CLI doesn't work:

##### For Android:

1. In Firebase Console, go to Project Settings
2. Under "Your apps", click the Android icon
3. Register your app with package name: `com.yourcompany.studentaibuddy`
4. Download `google-services.json`
5. Copy the example template:
   ```bash
   cp android/app/google-services.json.example android/app/google-services.json
   ```
6. Replace the content with your downloaded file

##### For iOS:

1. In Firebase Console, go to Project Settings
2. Under "Your apps", click the iOS icon
3. Register your app with bundle ID: `com.yourcompany.studentaibuddy`
4. Download `GoogleService-Info.plist`
5. Copy the example template:
   ```bash
   cp ios/Runner/GoogleService-Info.plist.example ios/Runner/GoogleService-Info.plist
   ```
6. Replace the content with your downloaded file

##### For Web/Desktop:

1. Copy the example template:
   ```bash
   cp lib/firebase_options.dart.example lib/firebase_options.dart
   ```
2. In Firebase Console, go to Project Settings > General
3. Scroll to "Your apps" and select your web/desktop app
4. Copy the configuration values and update `lib/firebase_options.dart`

### 3. Enable Firebase Services

In the Firebase Console:

1. **Authentication**:
   - Go to Authentication > Sign-in method
   - Enable "Email/Password" provider

2. **Firestore Database**:
   - Go to Firestore Database
   - Create database in production mode or test mode
   - Deploy the security rules from `firestore.rules`

3. **Storage**:
   - Go to Storage
   - Get started with default settings
   - Deploy the security rules from `storage.rules`

4. **Vertex AI (Optional)**:
   - Go to Vertex AI
   - Enable Gemini API for AI features

### 4. Verify Setup

Run the app to verify everything is configured correctly:

```bash
flutter pub get
flutter run
```

## Team Development

### For Team Members:

1. **DO NOT** share your Firebase configuration files via the repository
2. Each developer should:
   - Get Firebase project access from the project owner
   - Download their own configuration files from Firebase Console
   - Place them in the correct locations as described above

### For Project Owners:

1. Grant team members access to the Firebase project via Firebase Console
2. Share the project ID securely (e.g., via team communication channel)
3. **NEVER** commit the actual configuration files to the repository

## Troubleshooting

### "Firebase not configured" Error

- Ensure all three configuration files are present:
  - `lib/firebase_options.dart`
  - `android/app/google-services.json` (for Android)
  - `ios/Runner/GoogleService-Info.plist` (for iOS)

### API Key Issues

- Double-check that you've copied the correct API keys from Firebase Console
- Ensure the package name/bundle ID matches your Firebase app registration

### Build Errors

- Run `flutter clean && flutter pub get`
- Ensure all Firebase dependencies are up to date in `pubspec.yaml`

## Security Best Practices

1. ✅ Use `.gitignore` to exclude sensitive files (already configured)
2. ✅ Use example/template files for documentation (provided)
3. ✅ Never hardcode secrets in source code
4. ✅ Use environment-specific Firebase projects (dev, staging, prod)
5. ✅ Regularly rotate API keys and service account credentials
6. ✅ Review Firebase security rules regularly

## Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)

---

If you encounter any issues, please check the [main README](README.md) or open an issue on GitHub.
