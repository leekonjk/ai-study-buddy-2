# 🔧 Firebase Setup Guide

This guide will walk you through setting up Firebase for the Student AI Buddy application.

---

## 📋 Prerequisites

Before you begin, make sure you have:

- A Google account
- Flutter SDK installed (3.0 or higher)
- Git installed
- A code editor (VS Code or Android Studio)

---

## 🔥 Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter a project name (e.g., "student-ai-buddy")
4. (Optional) Enable Google Analytics if desired
5. Click **"Create project"** and wait for it to complete

---

## 📱 Step 2: Register Your Apps

### For Android:

1. In the Firebase Console, click the **Android icon** to add an Android app
2. Enter your Android package name:
   ```
   com.example.studnet_ai_buddy
   ```
   > **Note**: You can find this in `android/app/build.gradle.kts` under `applicationId`
3. (Optional) Enter an app nickname (e.g., "Student AI Buddy Android")
4. Click **"Register app"**
5. Download the `google-services.json` file
6. Place it in the `android/app/` directory of your project
   ```
   android/app/google-services.json
   ```

### For iOS:

1. In the Firebase Console, click the **iOS icon** to add an iOS app
2. Enter your iOS bundle ID:
   ```
   com.example.studnetAiBuddy
   ```
   > **Note**: You can find this in `ios/Runner.xcodeproj/project.pbxproj`
3. (Optional) Enter an app nickname (e.g., "Student AI Buddy iOS")
4. Click **"Register app"**
5. Download the `GoogleService-Info.plist` file
6. Place it in the `ios/Runner/` directory
   ```
   ios/Runner/GoogleService-Info.plist
   ```

---

## 🔐 Step 3: Enable Firebase Services

### Enable Authentication:

1. In Firebase Console, go to **Authentication** → **Get Started**
2. Click on **Sign-in method** tab
3. Enable the following providers:
   - **Email/Password** (required)
   - **Google** (optional but recommended)
4. Click **Save**

### Enable Firestore Database:

1. Go to **Firestore Database** → **Create database**
2. Choose **Start in test mode** (for development)
3. Select a Cloud Firestore location closest to you
4. Click **Enable**

### Enable Firebase Storage:

1. Go to **Storage** → **Get Started**
2. Start in **test mode** (for development)
3. Click **Next** and **Done**

### Configure Security Rules:

After enabling services, update the security rules:

**Firestore Rules** (`firestore.rules`):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /subjects/{subjectId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    match /study_sets/{setId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    match /flashcards/{cardId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    match /quizzes/{quizId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    match /quiz_attempts/{attemptId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    match /focus_sessions/{sessionId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    match /notes/{noteId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    match /achievements/{achievementId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

**Storage Rules** (`storage.rules`):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🤖 Step 4: Enable Vertex AI (Gemini)

1. In Firebase Console, go to **Build with Gemini** or search for **Vertex AI**
2. Click **Get Started** or **Enable**
3. Accept the terms of service
4. Vertex AI in Firebase will be enabled for your project
5. Make sure the **Gemini 1.5 Pro** model is available

> **Important**: Vertex AI may require billing to be enabled on your Google Cloud project. You may need to upgrade to the Blaze (pay-as-you-go) plan.

---

## 🔧 Step 5: Generate Firebase Options Dart File

1. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Run the FlutterFire configure command in your project directory:
   ```bash
   flutterfire configure
   ```

3. Select your Firebase project from the list
4. Select the platforms you want to configure (Android, iOS)
5. This will generate `lib/firebase_options.dart` automatically

---

## 📦 Step 6: Install Dependencies

Run the following command to install all required packages:

```bash
flutter pub get
```

---

## ▶️ Step 7: Run the App

### Clean and rebuild:
```bash
flutter clean && flutter pub get
```

### Run on your device/emulator:
```bash
flutter run
```

---

## ✅ Verification Checklist

Make sure you have completed all these steps:

- [ ] Created Firebase project
- [ ] Added Android app and placed `google-services.json` in `android/app/`
- [ ] Added iOS app and placed `GoogleService-Info.plist` in `ios/Runner/`
- [ ] Enabled Authentication (Email/Password)
- [ ] Enabled Firestore Database
- [ ] Enabled Firebase Storage
- [ ] Configured Firestore and Storage security rules
- [ ] Enabled Vertex AI (Gemini)
- [ ] Generated `firebase_options.dart` using FlutterFire CLI
- [ ] Ran `flutter pub get`
- [ ] Successfully ran the app with `flutter run`

---

## 🐛 Troubleshooting

### Issue: "No Firebase App '[DEFAULT]' has been created"
**Solution**: Make sure you've called `Firebase.initializeApp()` in your `main.dart` and that `firebase_options.dart` exists.

### Issue: "google-services.json not found"
**Solution**: Verify the file is placed in `android/app/google-services.json` (not in `android/`)

### Issue: "GoogleService-Info.plist not found"
**Solution**: 
1. Open `ios/Runner.xcworkspace` in Xcode
2. Drag and drop `GoogleService-Info.plist` into the Runner folder
3. Make sure "Copy items if needed" is checked

### Issue: Vertex AI/Gemini not working
**Solution**: 
1. Ensure billing is enabled in Google Cloud Console
2. Verify Vertex AI API is enabled
3. Check that you're using the correct model name in your code

### Issue: Build fails with Gradle errors (Android)
**Solution**: 
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Vertex AI in Firebase](https://firebase.google.com/docs/vertex-ai)
- [Flutter Documentation](https://flutter.dev/docs)

---

## 🔒 Security Notes

⚠️ **Important Security Practices**:

1. **Never commit** `google-services.json`, `GoogleService-Info.plist`, or `firebase_options.dart` to public repositories
2. These files are listed in `.gitignore` for your protection
3. Use environment-specific configurations for development and production
4. Update Firestore and Storage rules before deploying to production
5. Enable App Check for additional security in production

---

## 💡 Next Steps

After completing the setup:

1. Create your first user account in the app
2. Explore the AI study plan generation
3. Try creating flashcards and quizzes
4. Test the focus timer and productivity features
5. Check out the achievements system

---

<p align="center">
  <strong>Happy Coding! 🚀</strong>
</p>
