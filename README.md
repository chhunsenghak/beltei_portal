# BELTEI PORTAL

A comprehensive academic portal system designed for BELTEI International University, providing tailored workspaces for Admins, Teachers, and Students to manage courses, class schedules, grading, attendance, and leave requests.

## Tech Stack

- **Client / Mobile**: Flutter (Dart)
- **State Management**: Riverpod (`flutter_riverpod`)
- **Routing**: GoRouter (`go_router`)
- **Backend / Database**: Supabase (PostgreSQL, Auth, Storage, Row-Level Security)
- **Local Utilities**: `flutter_dotenv` (environment variables), `shared_preferences` (local key-value cache)
- **Libraries & Reports**: `pdf` / `printing` (document exports), `excel` (report exports), `fl_chart` (analytics charts)
- **Deployment**: Vercel (`vercel`)

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

# 3. Reset database (drop all tables and data)
"y" | supabase db reset --linked

# 4. Seed database with test data
.\seed.ps1

# 5. Start local Supabase (requires Docker)
supabase start

# 6. Apply all migrations to the local database
supabase db reset
```

### Credentials

The app loads environment variables from a `.env` file at the project root.

```powershell
# 1. Copy the example environment template
copy .env.example .env

# 2. View local credentials (after starting supabase)
supabase status

# 3. Update the .env file with the appropriate keys:
# - SUPABASE_URL: Project URL / API URL
# - SUPABASE_ANON_KEY: anon key (Publishable)
# - SUPABASE_SERVICE_ROLE_KEY: service_role key
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
  seeder/               ← Dart database seeder
lib/core/
  supabase/
    supabase_config.dart  ← URL + key (loads from .env)
    database.types.dart   ← Dart models for all 18 DB tables
  services/
    auth_service.dart     ← signIn, signOut, getProfile
  providers/
    auth_provider.dart    ← Riverpod providers
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
| `assessments` | Class/course assignments & assessments |
| `assessment_submissions` | Student submissions and grades for assessments |

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
│   │   │   ├── supabase_config.dart     # URL + key (loads from .env)
│   │   │   └── database.types.dart      # Dart models for all 18 DB tables
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
│   │   │   └── screens/
│   │   │       ├── teacher_shell.dart
│   │   │       └── …
│   │   └── admin/
│   │       └── screens/
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
├── assets/
│   └── images/
│       └── beltei_logo.png
└── pubspec.yaml
```

## Features by User Role

### 🔑 Admin Features
- **Dashboard & Analytics**: View high-level university statistics, institutional reports, and general quick actions.
- **User Management**: Manage profile types, view/edit detailed student (`student_detail_screen`) and teacher (`teacher_detail_screen`) information.
- **Academic Management**: Configure academic calendars, faculties, departments, majors, academic years, semesters, and courses.
- **Class & Enrollment Management**: Create and configure classes, manage curriculum/schedules, and handle student enrollment registrations.
- **Attendance & Leave Control**: Monitor class attendance logs, review globally submitted student and teacher leave requests.
- **Financial Control (View Only)**: View student invoices, payment history, and logs (under development).
- **System Settings**: Access global application configurations.

### 👨‍🏫 Teacher Features
- **Dashboard & Schedule**: Review daily schedule, personal classes, and active student metrics.
- **Course & Material Hub**: Upload course materials and files, post announcements for specific courses/classes.
- **Attendance Management**: Mark and edit student attendance records.
- **Assessment & Grading**: Create assignments/assessments, track submissions, and grade student work with feedback.
- **Analytics**: Track student performance statistics and course grade distributions.
- **Leave Requests**: Request leaves of absence and monitor approval status.

### 🎓 Student Features
- **Personal Dashboard**: Track academic GPA, attendance health, upcoming schedule, and notifications.
- **Classroom Hub**: View active courses, class schedules, and download course materials.
- **Grades & Analytics**: Check semester-by-semester grade details and analyze academic progression/analytics.
- **Attendance Logs**: Access personal attendance history and details.
- **Leave Requests**: Submit leave requests and monitor approvals.
- **Finance & Payments (View Only)**: View pending/paid invoices and fee details (online payment process not implemented).

