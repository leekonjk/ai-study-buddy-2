<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Gemini_AI-8E75B2?style=for-the-badge&logo=google&logoColor=white" alt="Gemini AI"/>
</p>

<h1 align="center">🎓 Student AI Buddy</h1>

<p align="center">
  <strong>Your Intelligent Study Companion</strong><br>
  <em>Powered by AI to help you learn smarter, not harder</em>
</p>

<p align="center">
  <a href="#-features">Features</a> •
  <a href="#-screenshots">Screenshots</a> •
  <a href="#-tech-stack">Tech Stack</a> •
  <a href="#-getting-started">Getting Started</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-contributing">Contributing</a>
</p>

---

## 📖 Overview

**Student AI Buddy** is a comprehensive Flutter application designed to revolutionize how students study. By leveraging cutting-edge AI technology through Firebase Vertex AI (Gemini), the app provides personalized study plans, intelligent flashcard generation, adaptive quizzes, and productivity tools—all in one beautiful, intuitive interface.

---

## ✨ Features

### 🧠 AI-Powered Learning
| Feature | Description |
|---------|-------------|
| **Smart Study Plans** | AI generates personalized schedules based on your subjects, difficulty levels, and available time |
| **Adaptive Learning** | Dynamically adjusts recommendations based on your progress and performance |
| **AI Chat Mentor** | Get instant help with study questions and explanations |
| **Auto-Generated Flashcards** | Create study sets from topics using AI in seconds |

### 📚 Study Tools
| Feature | Description |
|---------|-------------|
| **Flashcards** | Create and review flashcards with spaced repetition (SM-2 algorithm) for optimal retention |
| **Notes** | Rich text note-taking with subject organization and search |
| **Quiz Generator** | Generate adaptive quizzes from your study materials to test knowledge |
| **Resource Library** | Organize your study PDFs, links, and documents in one place |

### ⏱️ Productivity & Gamification
| Feature | Description |
|---------|-------------|
| **Focus Timer** | Pomodoro-style timer with session tracking and statistics |
| **Achievements** | Gamified badges and XP levels to keep you motivated |
| **Statistics Dashboard** | Track study hours, task completion, focus trends, and weekly progress |
| **Calendar Integration** | View and manage your study schedule with an intuitive calendar |

---

## 📸 Screenshots

<p align="center">
  <em>Coming soon...</em>
</p>

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.x (Cross-Platform Mobile) |
| **Language** | Dart |
| **Backend** | Firebase (Authentication, Firestore, Storage) |
| **AI/ML** | Firebase Vertex AI (Gemini 1.5 Pro) |
| **State Management** | Provider |
| **Architecture** | Clean Architecture with Repository Pattern |
| **Animations** | Flutter Animate, Lottie |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- VS Code or Android Studio
- Firebase project with Vertex AI enabled
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/leekonjk/ai-study-buddy-2.git
   cd ai-study-buddy-2
   ```

2. **Configure Firebase**
   
   ⚠️ **Important**: Firebase configuration files are not included in this repository for security reasons.
   
   See [SETUP.md](SETUP.md) for detailed instructions on setting up Firebase configuration.

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                  # Constants, utilities, theme, error handling
│   ├── constants/
│   ├── errors/
│   ├── theme/
│   └── utils/
├── data/                  # Data layer
│   ├── datasources/       # Remote and local data sources
│   ├── models/            # Data models (DTOs)
│   ├── repositories/      # Repository implementations
│   └── services/          # Service implementations
├── di/                    # Dependency injection (GetIt)
│   └── service_locator.dart
├── domain/                # Domain layer (business logic)
│   ├── entities/          # Core business entities
│   ├── repositories/      # Repository interfaces (contracts)
│   └── services/          # Service interfaces
├── presentation/          # UI layer
│   ├── auth/              # Authentication screens
│   ├── navigation/        # App routing
│   ├── providers/         # Shared state providers
│   ├── screens/           # Feature screens
│   ├── theme/             # App theming
│   ├── viewmodels/        # Screen-specific state management
│   └── widgets/           # Reusable UI components
└── main.dart              # App entry point
```

---

## 🔐 Firebase Collections Schema

| Collection | Description |
|------------|-------------|
| `users` | User profiles and preferences |
| `subjects` | Enrolled subjects and topics |
| `study_sets` | User-created study sets |
| `flashcards` | Individual flashcards with spaced repetition data |
| `quizzes` | Quiz templates and questions |
| `quiz_attempts` | Quiz attempt history and scores |
| `focus_sessions` | Focus timer session records |
| `notes` | User notes organized by subject |
| `achievements` | User achievement progress |

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Lee Kon Jk**

- GitHub: [@leekonjk](https://github.com/leekonjk)

---

<p align="center">
  <strong>Built with ❤️ using Flutter</strong><br>
  <em>Making studying smarter, one student at a time</em>
</p>
