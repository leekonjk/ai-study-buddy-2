# Student AI Buddy 🎓🤖

> ⚠️ **IMPORTANT SECURITY NOTICE**: If you previously cloned this repository, please note that sensitive Firebase credentials were removed. See [SECURITY_AUDIT.md](SECURITY_AUDIT.md) for details.

**Student AI Buddy** is an intelligent Flutter application designed to help students organize their studies, stay focused, and learn more effectively using AI-powered tools.

## 🌟 Features

### 🧠 AI-Powered Study Planning
- **Smart Scheduling**: Automatically generates personalized study plans based on your subjects, difficulty levels, and available time.
- **Adaptive Learning**: Adjusts schedules based on your progress and focus sessions.

### 📚 Study Tools
- **Flashcards**: Create and review flashcards with spaced repetition to improved retention.
- **Notes**: Rich text note-taking with subject organization.
- **Quiz Generator**: Generate quizzes from your study materials to test your knowledge.
- **Resource Library**: Organize your study PDFs, links, and documents.

### ⏱️ Productivity
- **Focus Timer**: Pomodoro-style timer to keep you focused during study sessions.
- **Achievements**: Gamified badges and levels to keep you motivated.
- **Statistics**: Track your study hours, task completion, and focus trends.

## 🛠️ Tech Stack

- **Frontend**: Flutter (Mobile Cross-Platform)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider
- **AI Integration**: Firebase Vertex AI (Gemini)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed (latest stable version)
- VS Code or Android Studio
- A Google account for Firebase
- Dart SDK (comes with Flutter)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/leekonjk/ai-study-buddy-2.git
   cd ai-study-buddy-2
   ```

2. **Set up Firebase**
   
   ⚠️ **IMPORTANT**: You need to configure your own Firebase project before running the app.
   
   See the detailed setup guide: [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
   
   Quick setup using FlutterFire CLI:
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```
   
   This will generate the necessary configuration files:
   - `lib/firebase_options.dart`
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist` (if building for iOS)

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔒 Security Notice

This repository does **NOT** include Firebase configuration files for security reasons. You must set up your own Firebase project and generate your own configuration files. See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions.

**Never commit the following files to version control:**
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`
- `firestore_seed/serviceAccountKey.json`
- Any `.env` files

These files are already included in `.gitignore` to prevent accidental commits.

## 📂 Project Structure

- `lib/core`: Constants, utilities, and error handling.
- `lib/data`: Data sources, models, and repositories.
- `lib/domain`: Entities and repository interfaces (Clean Architecture).
- `lib/presentation`: Screens, widgets, and state management (Provider).

---
*Built with ❤️ using Flutter*
