# Firebase Configuration Setup Guide

This guide will help you set up your own Firebase configuration for the Student AI Buddy app.

## Prerequisites

1. A Google account
2. Access to [Firebase Console](https://console.firebase.google.com/)

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter a project name (e.g., "my-student-ai-buddy")
4. Follow the setup wizard to complete project creation

## Step 2: Enable Required Services

In your Firebase project, enable the following services:

1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable Email/Password authentication

2. **Firestore Database**
   - Go to Firestore Database
   - Create database in production mode or test mode

3. **Storage**
   - Go to Storage
   - Get started with default settings

4. **Vertex AI (Gemini)**
   - Go to Vertex AI
   - Enable the Gemini API for your project

## Step 3: Configure Firebase for Your Platforms

### For Android

1. In Firebase Console, click on the Android icon to add an Android app
2. Register app with package name: `com.example.studnet_ai_buddy` (or your custom package name)
3. Download the `google-services.json` file
4. Place it in `android/app/google-services.json`

### For iOS (Optional)

1. In Firebase Console, click on the iOS icon to add an iOS app
2. Register app with bundle ID: `com.example.studnetAiBuddy`
3. Download the `GoogleService-Info.plist` file
4. Place it in `ios/Runner/GoogleService-Info.plist`

### For Web (Optional)

1. In Firebase Console, click on the Web icon to add a Web app
2. Register the app and copy the configuration

## Step 4: Generate Firebase Options for Flutter

The easiest way to configure Firebase for Flutter is using the FlutterFire CLI:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase for your Flutter project
flutterfire configure
```

This will:
- Automatically detect your Firebase project
- Generate the `lib/firebase_options.dart` file with your configuration
- Set up all necessary platform-specific files

Alternatively, you can manually create `lib/firebase_options.dart` using the template file `lib/firebase_options.dart.template` and replace the placeholder values with your actual Firebase configuration.

## Step 5: Set Up Firestore Seeding (Optional)

If you want to use the Firestore seeding script:

1. In Firebase Console, go to Project Settings → Service Accounts
2. Click "Generate new private key"
3. Save the downloaded JSON file as `firestore_seed/serviceAccountKey.json`
4. **IMPORTANT**: Never commit this file to version control!

## Step 6: Configure Firestore Security Rules

1. Copy the rules from `firestore.rules` to your Firebase Console
2. Go to Firestore Database → Rules
3. Paste and publish the rules

## Step 7: Configure Storage Security Rules

1. Copy the rules from `storage.rules` to your Firebase Console
2. Go to Storage → Rules
3. Paste and publish the rules

## Security Best Practices

- ✅ **DO** keep your `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`, and `serviceAccountKey.json` files private
- ✅ **DO** use environment-specific Firebase projects (development, staging, production)
- ✅ **DO** implement proper Firestore security rules
- ❌ **DON'T** commit sensitive configuration files to version control
- ❌ **DON'T** share your service account keys publicly

## Troubleshooting

### Build errors about missing google-services.json
- Make sure you've downloaded and placed the file in `android/app/google-services.json`
- Verify the package name in the file matches your app's package name

### Firebase not initialized error
- Ensure you've run `flutterfire configure` or created `lib/firebase_options.dart`
- Check that Firebase.initializeApp() is called in your main.dart

### Permission denied errors
- Review your Firestore and Storage security rules
- Ensure users are authenticated before accessing protected resources

## Need Help?

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
