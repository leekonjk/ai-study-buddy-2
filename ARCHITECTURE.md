# Student AI Buddy - Architecture Documentation

## Overview

This application follows **Clean Architecture** with **MVVM** pattern for the presentation layer. The goal is to create a maintainable, testable, and scalable AI-powered study planner.

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Screens   │──│  Widgets    │  │     ViewModels      │  │
│  │   (UI)      │  │  (Reusable) │  │ (State Management)  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Entities   │  │  Services   │  │    Repositories     │  │
│  │  (Models)   │  │ (AI Logic)  │  │   (Interfaces)      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Models    │  │ DataSources │  │    Repositories     │  │
│  │   (DTOs)    │  │  (Local)    │  │ (Implementations)   │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
lib/
├── assets/                     # Static assets (see Asset Rules below)
│   ├── UI/UX/                  # UI illustrations, onboarding images
│   ├── Flow/                   # Architecture diagrams (docs only)
│   └── requirements/           # Specification documents (docs only)
│
├── core/                       # Shared infrastructure
│   ├── constants/              # App-wide constants, asset paths
│   ├── errors/                 # Failures and exceptions
│   ├── theme/                  # App theme configuration
│   └── utils/                  # Utility functions (Result type, date utils)
│
├── data/                       # Data layer
│   ├── datasources/            # Local and remote data sources
│   │   └── local/              # SharedPreferences, local DB
│   ├── models/                 # DTOs with JSON serialization
│   └── repositories/           # Repository implementations
│
├── di/                         # Dependency injection
│   └── service_locator.dart    # DI container setup
│
├── domain/                     # Business logic layer
│   ├── entities/               # Core domain models
│   ├── repositories/           # Repository interfaces (contracts)
│   └── services/               # AI-driven domain services
│
├── presentation/               # UI layer
│   ├── navigation/             # App router and routes
│   ├── screens/                # Screen widgets (one per feature)
│   │   ├── dashboard/
│   │   ├── focus/
│   │   ├── mentor/
│   │   ├── onboarding/
│   │   ├── quiz/
│   │   └── study_plan/
│   ├── viewmodels/             # State management (ChangeNotifier)
│   │   ├── dashboard/
│   │   ├── focus/
│   │   ├── mentor/
│   │   ├── onboarding/
│   │   └── quiz/
│   └── widgets/                # Reusable UI components
│       ├── cards/
│       └── common/
│
├── firebase_options.dart       # Firebase configuration
└── main.dart                   # App entry point
```

## Asset Rules

| Directory | Purpose | Runtime Usage |
|-----------|---------|---------------|
| `lib/assets/UI/UX/` | Illustrations, onboarding images | ✅ Yes |
| `lib/assets/Flow/` | Architecture diagrams | ❌ Documentation only |
| `lib/assets/requirements/` | Specifications | ❌ Documentation only |

**Do NOT invent new asset paths outside these directories.**

## Key Design Decisions

### 1. Result Type for Error Handling
Uses a sealed `Result<T>` type instead of exceptions for predictable error handling:
```dart
final result = await repository.getProfile();
result.fold(
  onSuccess: (profile) => updateState(profile),
  onFailure: (failure) => showError(failure.message),
);
```

### 2. Immutable State in ViewModels
ViewModels expose immutable state objects. UI rebuilds only when state changes:
```dart
class DashboardState {
  final List<StudyTask> todaysTasks;
  final ViewState viewState;
  // ... copyWith method for updates
}
```

### 3. AI Explainability
Every AI decision includes a `reasoning` field explaining why:
- `StudyTask.aiReasoning` - Why this task was recommended
- `KnowledgeLevel.reasoningNote` - How mastery was estimated
- `RiskAssessment.aiExplanation` - What factors contribute to risk
- `AIInsight.reasoning` - Why this advice was generated

### 4. Domain Services for AI Logic
AI algorithms live in domain services, not in ViewModels or widgets:
- `KnowledgeEstimationService` - Estimates mastery from quiz performance
- `StudyPlannerService` - Generates weekly study plans
- `RiskAnalysisService` - Identifies at-risk subjects
- `AIMentorService` - Produces advisory insights

## Development Order

1. ✅ Define core domain models (entities)
2. ⏳ Implement domain services (AI logic)
3. ⏳ Define ViewModel states and events
4. ⏳ Implement ViewModels
5. ⏳ Build UI screens bound to ViewModels

## Dependencies to Add

```yaml
dependencies:
  provider: ^6.1.0          # State management
  shared_preferences: ^2.2.0 # Local storage
  uuid: ^4.2.0              # ID generation
  iconify_flutter: ^0.0.2   # Line-MD icons via Iconify

dev_dependencies:
  mockito: ^5.4.0           # Testing mocks
  build_runner: ^2.4.0      # Code generation
```

## Testing Strategy

- **Unit tests**: Domain entities, services, ViewModels
- **Widget tests**: Individual widgets with mock ViewModels
- **Integration tests**: Complete user flows

## Icons

Use **Line-MD** icons via Iconify only. Example:
```dart
Iconify(LineMd.check_circle)
```

---

*Last updated: Project initialization*
