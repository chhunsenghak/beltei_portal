# BELTEI PORTAL

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter analyze          # Lint (uses flutter_lints)
flutter test             # Run all tests
flutter test test/path/to/test.dart  # Run a single test
flutter build apk        # Android release build
flutter build web        # Web release build
```

After adding new assets to `pubspec.yaml`, a full restart (`flutter run`) is required — hot reload will not pick up new assets.

## Supabase Setup

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — must be running for local Supabase
- [Supabase CLI](https://supabase.com/docs/guides/cli) — install via scoop or npm:

```powershell
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
# or
npm install -g supabase
```

### First-Time Local Setup

```powershell
# 1. Login to Supabase
supabase login

# 2. Link to the remote project
supabase link --project-ref devqlpzjanbekxlrbozp

# 3. Start local Supabase (requires Docker)
supabase start

# 4. Apply all migrations to the local database
supabase db reset
```

### Credentials

After `supabase start`, run `supabase status` to get local credentials:

```
Project URL:  http://127.0.0.1:54321
Publishable:  sb_publishable_...   ← use this as supabaseAnonKey for local
Secret:       sb_secret_...        ← never use in Flutter app
Studio:       http://127.0.0.1:54323
```

Configure in `lib/core/supabase/supabase_config.dart`:

```dart
// Local development
const String supabaseUrl = 'http://127.0.0.1:54321';
const String supabaseAnonKey = 'sb_publishable_...'; // from supabase status

// Remote (production) — uncomment to switch
// const String supabaseUrl = 'https://devqlpzjanbekxlrbozp.supabase.co';
// const String supabaseAnonKey = 'sb_publishable_...'; // from Supabase Dashboard → API keys
```

> **Note:** The remote `Publishable` key is in the Supabase Dashboard under **Project Settings → API keys**. The old name was "anon key" — same thing.

### Create a Local Test User

1. Open Local Studio: `http://127.0.0.1:54323`
2. Go to **Authentication → Users → Add user**
3. Fill in email + password, check **Auto confirm user**
4. Set the role in SQL Editor:

```sql
UPDATE profiles SET role = 'admin', full_name = 'System Admin'
WHERE email = 'your@email.com';
```

### Migration Workflow

All schema changes must go through migration files — never edit the database directly.

```powershell
# Create a new migration
supabase migration new <migration_name>
# → creates supabase/migrations/[timestamp]_<migration_name>.sql
# Write your SQL in that file, then:

# Apply to local DB
supabase db reset

# Push to remote (production)
supabase db push
```
```powershell
# Database seeding
.\seed.ps1               # Seed local DB with test data
.\reset-db.ps1           # Reset DB then seed (combines db reset + seed)
```

### Daily Development Commands

```powershell
supabase start          # Start local Supabase (Docker)
supabase stop           # Stop local Supabase
supabase status         # Show local URLs and keys
supabase db reset       # Wipe local DB and re-apply all migrations
supabase db push        # Push local migrations to remote
supabase migration list # List all migrations and their status
```

### Project Structure (Supabase)

```
supabase/
  migrations/           ← SQL migration files (version-controlled)
lib/core/
  supabase/
    supabase_config.dart  ← URL + key (switch local ↔ remote here)
    database.types.dart   ← Dart models for all 14 DB tables
  services/
    auth_service.dart     ← signIn, signOut, getProfile
  providers/
    auth_provider.dart    ← Riverpod providers
supabase_schema.sql       ← Reference copy of the full schema
```

### Database Tables

| Table | Purpose |
|---|---|
| `profiles` | One row per user (mirrors auth.users) |
| `students` | Student-specific data |
| `teachers` | Teacher-specific data |
| `faculties` | Faculties |
| `departments` | Departments per faculty |
| `semesters` | Academic semesters |
| `courses` | Courses per semester/teacher |
| `enrollments` | Student ↔ Course enrolments |
| `grades` | Grades per student per course |
| `attendance` | Daily attendance records |
| `leave_requests` | Student/teacher leave requests |
| `invoices` | Student fee invoices |
| `payments` | Payment records |
| `notifications` | Per-user notifications |
| `course_materials` | Uploaded files per course |
| `announcements` | Teacher announcements per course |

---

## Architecture

### Folder Structure

```
beltei_portal/
├── lib/
│   ├── main.dart                        # Entry point — Supabase init + ProviderScope
│   ├── app.dart                         # MaterialApp.router
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart          # Color tokens
│   │   │   ├── app_spacing.dart         # Spacing/radius tokens
│   │   │   └── app_text_styles.dart     # Typography tokens
│   │   ├── providers/
│   │   │   └── auth_provider.dart       # Riverpod auth providers
│   │   ├── router/
│   │   │   └── app_router.dart          # GoRouter + auth redirect guard
│   │   ├── services/
│   │   │   └── auth_service.dart        # signIn, signOut, getProfile
│   │   ├── supabase/
│   │   │   ├── supabase_config.dart     # URL + key (local ↔ remote toggle)
│   │   │   └── database.types.dart      # Dart models for all 16 DB tables
│   │   └── theme/
│   │       └── app_theme.dart           # MaterialTheme
│   ├── features/
│   │   ├── auth/
│   │   │   ├── models/
│   │   │   │   └── app_user.dart        # AppUser model + UserRole enum
│   │   │   └── screens/
│   │   │       ├── splash_screen.dart   # Checks session → routes by role
│   │   │       ├── login_screen.dart    # Supabase email/password auth
│   │   │       └── forgot_password_screen.dart
│   │   ├── student/
│   │   │   └── screens/                 # 19 screens (dashboard, grades, attendance…)
│   │   │       ├── student_shell.dart   # Bottom nav shell
│   │   │       └── …
│   │   ├── teacher/
│   │   │   └── screens/                 # 15 screens (courses, grading, attendance…)
│   │   │       ├── teacher_shell.dart
│   │   │       └── …
│   │   └── admin/
│   │       └── screens/                 # 21 screens (users, academic, finance…)
│   │           ├── admin_shell.dart
│   │           └── …
│   └── shared/
│       └── widgets/
│           ├── beltei_app_bar.dart
│           ├── status_badge.dart
│           ├── section_header.dart
│           └── info_card.dart
├── supabase/
│   ├── config.toml                      # Supabase CLI config
│   └── migrations/
│       └── 20260625170516_initial_schema.sql
├── supabase_schema.sql                  # Reference copy of full schema
├── assets/
│   └── images/
│       └── beltei_logo.png
└── pubspec.yaml
```

### Screen Count

| Role | Screens |
|---|---|
| Admin | 21 |
| Student | 19 |
| Teacher | 15 |
| Auth | 3 |
| **Total** | **58** |

### Routing (GoRouter)

`lib/core/router/app_router.dart` is the single source of truth for navigation. Route path constants live in the `AppRoutes` class. The app has four top-level zones:

- **Auth zone** (`/`, `/login`, `/forgot-password`) — plain `GoRoute`s
- **Student zone** (`/student/...`) — `ShellRoute` wrapping `StudentShell` (bottom nav)
- **Teacher zone** (`/teacher/...`) — `ShellRoute` wrapping `TeacherShell` (bottom nav)
- **Admin zone** (`/admin/...`) — `ShellRoute` wrapping `AdminShell` (bottom nav)

Auth redirect: unauthenticated users are automatically sent to `/login` via the router's `redirect` callback + `_AuthNotifier` (ChangeNotifier that listens to Supabase auth state changes). After login, `AuthService` fetches the user's role from the `profiles` table and routes to the correct shell.

### Feature Structure

`lib/features/<role>/screens/` — all screens for that role live flat in this directory. Screens currently use inline `const` mock data at the top of each file (named `_k*` by convention). When wiring up real data, that mock data is the replacement target.

`lib/shared/widgets/` — four reusable widgets:
- `BelteiAppBar` — custom app bar (Container-based) that guarantees 16 px left alignment matching `AppSpacing.screenPadding`. Pass `showSearch`/`showNotification` flags or a custom `actions` list.
- `StatusBadge` — pill badge; accepts a `BadgeType` enum value.
- `SectionHeader` — section title with optional action link.
- `InfoCard` — bordered card container.

### Design Tokens

All design constants live in `lib/core/constants/`. Never use magic numbers for colors, spacing, or typography:

| File | Exports |
|---|---|
| `app_colors.dart` | `AppColors.primaryNavy`, `AppColors.statusGreen`, etc. |
| `app_text_styles.dart` | `AppTextStyles.h1`, `AppTextStyles.body`, etc. (Inter via google_fonts) |
| `app_spacing.dart` | `AppSpacing.screenPadding` (16), `AppSpacing.cardRadius` (12), etc. |

### AppBar Rules

- **Tab screens** (root destinations inside a ShellRoute): use `BelteiAppBar()` or set `automaticallyImplyLeading: false` to prevent Flutter inserting a 56 px back button.
- **Detail screens** pushed on top: set `leading:` explicitly and `automaticallyImplyLeading: false`.
- **Dashboard screens** with `SliverAppBar`: always include `automaticallyImplyLeading: false` and `titleSpacing: 0`, with title wrapped in `Padding(left: 16)`.

### Assets

`assets/images/beltei_logo.png` — referenced via `Image.asset(...)`. The `assets/images/` directory is registered under `flutter.assets` in `pubspec.yaml`.
