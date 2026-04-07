# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

---

## Project Overview

Strength Labs is a fitness training tracking mobile app (MVP). This repository contains the Flutter mobile application for iOS and Android. The backend is a separate Python/FastAPI service documented in `docs/arquitectura.tex`.

The app allows users to log workouts, track fatigue, and access predefined training routines.

---

## Repository Layout

```
mobile/
└── lib/
    ├── main.dart
    ├── app.dart
    ├── core/
    │   ├── constants/    # Base URLs, colors, strings
    │   ├── network/      # Dio client and JWT interceptor
    │   ├── storage/      # flutter_secure_storage wrapper
    │   └── router/       # GoRouter — named routes and auth guards
    ├── features/
    │   ├── auth/
    │   │   ├── data/         # AuthRepository, RemoteDataSource
    │   │   ├── domain/       # Entities, UseCases
    │   │   └── presentation/ # LoginPage, RegisterPage, Cubit
    │   ├── workouts/
    │   │   ├── data/
    │   │   ├── domain/
    │   │   └── presentation/ # WorkoutListPage, WorkoutDetailPage, ActiveWorkoutPage
    │   ├── fatigue/
    │   │   └── presentation/ # FatigueDashboardPage
    │   ├── routines/
    │   │   └── presentation/ # RoutinesPage, RoutineDetailPage
    │   └── export/
    │       └── presentation/ # ExportPage
    └── shared/
        ├── widgets/      # Reusable buttons, cards, inputs
        └── utils/        # Formatters, validators
```

---

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device or emulator
dart analyze             # Static analysis and lint
flutter test             # Run unit and widget tests
flutter build apk        # Build Android APK
flutter build ios        # Build iOS binary
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x — iOS and Android |
| State management | Flutter Bloc / Cubit |
| Navigation | GoRouter |
| HTTP client | Dio with JWT interceptor |
| Token storage | flutter_secure_storage |

---

## Conventions

- Feature-first folder structure under `features/`. Each feature has `data/`, `domain/`, and `presentation/` layers.
- State management is Bloc/Cubit only. Do not use `setState` for anything beyond purely local UI state such as a toggle inside a single widget.
- All API calls go through the Dio client defined in `core/network/`. The JWT interceptor handles attaching the token and refreshing it automatically.
- The access token is stored in `flutter_secure_storage` only. Never store it in shared preferences or any other local storage.
- Navigation is declarative via GoRouter. Route guards check authentication status before allowing access to protected screens.
- Do not hardcode base URLs or any configuration value. Use the constants defined in `core/constants/`.

---

## API endpoints consumed

| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/register` | Create user account |
| POST | `/auth/login` | Authenticate, returns access + refresh JWT |
| GET | `/auth/me` | Authenticated user profile |
| GET | `/workouts` | Paginated workout history |
| POST | `/workouts` | Create new workout session |
| GET | `/workouts/{id}` | Session detail with all sets |
| PUT | `/workouts/{id}` | Update session name or notes |
| DELETE | `/workouts/{id}` | Delete session |
| GET | `/exercises` | Global + user exercise catalog |
| POST | `/exercises` | Create custom exercise |
| GET | `/fatigue/summary` | Fatigue index and overtraining alert |
| GET | `/fatigue/weekly` | Weekly volume by muscle group |
| GET | `/routines` | Suggested routines by level and goal |
| GET | `/routines/{id}` | Routine detail with exercises |
| GET | `/export/xlsx` | Download full history as Excel |
| GET | `/export/csv` | Download full history as CSV |

---

## Roadmap

- [x] MVP — Workout recording and fatigue dashboard
- [ ] v1.1 — Push notifications via FCM
- [ ] v1.2 — AI-driven routine generation
- [ ] v1.3 — Apple Health and Google Fit integration
- [ ] v2.0 — Web admin dashboard
