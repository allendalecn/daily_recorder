# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Daily Recorder** — A Flutter app for recording daily life activities across 7 categories: Sleep, Meals, Exercise, Mood, Water Intake, Medication, and Notes.

- **Platform**: Flutter (Dart), targeting iOS and Android
- **Min SDK**: Flutter 3.24+ / Dart 3.5+
- **State management**: flutter_riverpod (StateNotifier pattern)
- **Persistence**: sqflite (SQLite)
- **UI**: Material 3 with system dark/light theme

## Common Commands

```bash
# Create platform files (required first time)
flutter create --project-name daily_recorder .

# Install dependencies
flutter pub get

# Run on connected device/simulator
flutter run

# Run with specific device
flutter run -d chrome        # Web (debug)
flutter run -d iphone        # iOS simulator

# Build
flutter build apk            # Android
flutter build ios             # iOS
flutter build web             # Web

# Analyze code
flutter analyze

# Run tests
flutter test
flutter test test/specific_test.dart
```

## Architecture

```
lib/
├── main.dart                   # Entry point, ProviderScope wrapper
├── app.dart                    # MaterialApp + MainScreen (NavigationBar with 3 tabs)
├── models/                     # Plain Dart data classes with toMap/fromMap serialization
│   ├── record_category.dart    # Enum defining 7 categories (icon, color, displayName)
│   ├── daily_record.dart       # Aggregate root — one per calendar day
│   └── [7 category records]    # SleepRecord, MealRecord, ExerciseRecord, etc.
├── services/
│   └── database_service.dart   # Singleton SQLite service — all CRUD operations, table creation
├── providers/
│   ├── database_provider.dart  # Riverpod Provider<DatabaseService>
│   ├── today_provider.dart     # StateNotifier for today's records across all categories
│   └── history_provider.dart   # StateNotifier for browsing all past DailyRecords
├── screens/
│   ├── today/                  # Today dashboard — shows all 7 category sections
│   ├── history/                # Chronological list of past days
│   ├── daily_summary/          # Detail view for a specific past day with stats header
│   ├── add_entry/              # Modal bottom sheet — single screen with switch on category
│   └── settings/               # Placeholder settings (water goal, reminders, data export)
├── widgets/                    # Shared components: CategoryIcon, CategorySection, EmptyState, DaySummaryCard
└── utils/                      # Constants (meal types, emotions, presets), Date extensions
```

### Key Patterns

- **DailyRecord as aggregate root**: One record per calendar day (date stored as epoch ms at midnight, UNIQUE constraint). All category records reference `daily_record_id` with CASCADE delete.
- **Models use `toMap`/`fromMap`**: No code generation. Lists (emotions, tags) stored as comma-separated strings in SQLite.
- **State management**: `TodayNotifier` and `HistoryNotifier` extend `StateNotifier` with immutable state classes. Screens are `ConsumerWidget` or `ConsumerStatefulWidget`.
- **Add entry flow**: Single `AddEntryScreen` takes `RecordCategory` + `dailyRecordId`, switches on category to render the appropriate form. Presented as modal bottom sheet.
- **Categories defined in enum**: `RecordCategory` enum holds `displayName`, `icon` (IconData), and `color` — the single source of truth for all category UI.

### Database Schema

8 tables: `daily_records` + 7 category tables (`sleep_records`, `meal_records`, `exercise_records`, `mood_records`, `water_intake_records`, `medication_records`, `note_records`). All category tables have `daily_record_id` FK with ON DELETE CASCADE.
