# BELTEI Portal — Project Overview

This document summarizes what has been built in the project, the technology choices (and why), and major implementation work. For setup commands, folder structure, and database table reference, see [README.md](../README.md). For admin screen-level detail, see [admin_features.md](./admin_features.md).

---

## What This Project Is

BELTEI Portal is a role-based academic management system for BELTEI International University. Three separate workspaces — **Admin**, **Teacher**, and **Student** — share one Flutter codebase and one Supabase backend.

---

## Technology Stack & Why We Use It

| Technology | Role | Why we chose it |
|---|---|---|
| **Flutter (Dart)** | Cross-platform client (Web, Android, iOS, desktop) | Single codebase for web and mobile; strong UI tooling; good fit for data-heavy dashboards and forms |
| **Riverpod** (`flutter_riverpod`) | App-wide state management | Compile-safe providers; works well with async Supabase calls; easy to split state by role (admin / teacher / student) |
| **GoRouter** (`go_router`) | Declarative routing + deep links | Shell routes per role; auth redirect guard; URL-based navigation for web |
| **Supabase** | Backend (PostgreSQL, Auth, Storage, RLS) | Managed Postgres with built-in auth and file storage; Row-Level Security for role-based data access; no custom API server to maintain |
| **PostgreSQL migrations** (Supabase CLI) | Schema versioning | All DB changes are tracked in `supabase/migrations/`; reproducible local and production schema |
| **Docker Desktop** (local only) | Runs local Supabase stack | Required by `supabase start` for local development — **not used in production hosting** |
| **Vercel** | Production web hosting | Static Flutter web output served globally via CDN; zero server management; fits SPA deployment model |
| **GitHub Actions** | CI/CD pipeline | Builds Flutter web on every merge to `main`; deploys prebuilt artifacts to Vercel with environment approval gate |
| **Google Fonts** | Typography | Consistent branding without bundling font files manually |
| **fl_chart** | Analytics charts | Dashboard KPIs and grade/enrollment visualizations for admin and student views |
| **table_calendar** | Calendar UI | Academic calendar and schedule views |
| **pdf / printing** | Document export | Generate printable reports and invoices |
| **excel** | Spreadsheet export | Admin report downloads |
| **file_picker / image_picker** | File uploads | Course materials, assessment submissions, profile assets |
| **url_launcher** | External links | Open submitted file URLs and external resources safely |
| **shared_preferences** | Local persistence | Theme mode, locale, and UI preferences cached on device |
| **flutter_localizations + ARB files** | i18n (English & Khmer) | University operates in Cambodia; bilingual UI support |
| **flutter_lints** | Static analysis | Enforces Dart/Flutter best practices in CI and locally |

---

## Architecture Highlights

- **Feature-first folder layout** — `lib/features/{auth,admin,teacher,student}/` with role-specific screens; shared UI in `lib/shared/`.
- **Service layer** — `auth_service`, `admin_service`, `teacher_service`, and `student_service` encapsulate all Supabase queries; screens consume Riverpod providers, not raw Supabase calls.
- **Auth-aware routing** — `GoRouter` redirect listens to Supabase `onAuthStateChange`; unauthenticated users are sent to `/login`; authenticated users land in the correct role shell.
- **Role shells** — `AdminShell`, `TeacherShell`, and `StudentShell` provide persistent navigation (top bar / bottom nav) across each role's screens.
- **Design system** — Centralized tokens in `app_colors.dart`, `app_spacing.dart`, and `app_text_styles.dart`; theme and brand color driven by `theme_provider.dart`.
- **Responsive layout** — `shared/utils/responsive.dart` adapts layouts for mobile and wider web viewports.
- **Environment config** — Local dev uses `.env` via `flutter_dotenv`; production web build injects `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define` in GitHub Actions.

---

## What Has Been Implemented

### Authentication & Session

- Splash screen with session check and role-based redirect
- Email/password login via Supabase Auth
- Forgot password flow
- Auth state persisted across app restarts
- Role enum: `admin`, `teacher`, `student`

### Admin Module (~20 screens)

- **Dashboard** — Live KPI stats (students, teachers, courses, revenue, pending leave, current semester); revenue collection rate; recent leave requests
- **User management** — Searchable student and teacher lists with detail screens (profile edit, status toggle, department/course assignment)
- **Academic management** — Faculties, departments, majors, academic years, semesters, courses
- **Class management** — Class creation, curriculum, schedules, custom term dates, student enrollment
- **Academic calendar** — Term and event management
- **Attendance management** — Global attendance oversight
- **Leave requests** — Review and manage student/teacher leave across the institution
- **Finance** — Invoice and payment views (read-only; online payment not implemented)
- **Reports & analytics** — Institutional reports, university analytics, admin reports with export support
- **System settings** — App-wide configuration (backed by `app_settings` table)
- **Admin profile** — Logged-in admin account view

> Screen-by-screen admin documentation: [admin_features.md](./admin_features.md)

### Teacher Module (~15 screens)

- Dashboard with daily schedule and class metrics
- Course list and per-course management
- Upload course materials (Supabase Storage `materials` bucket)
- Post announcements per course/class
- Mark and edit student attendance (with session number support)
- Create assessments/assignments
- Grade submissions with score and written feedback
- Student performance analytics
- Leave request submission and status tracking
- Leave request review (where permitted by RLS policy)
- Notification center
- Teacher profile

### Student Module (~19 screens)

- Personal dashboard (GPA, attendance health, schedule preview, notifications)
- Course list and course detail (materials, announcements, assessments)
- Submit assignment text and file attachments
- View grades and semester grade breakdown
- Academic analytics and progression charts
- Class schedule and daily agenda
- Attendance dashboard and history
- Leave request create, list, detail, and delete (pending only)
- Finance dashboard and invoice detail (view-only)
- Notification center
- Student profile with sign-out

### Shared Components

- `BelteiAppBar`, `StatusBadge`, `SectionHeader`, `InfoCard`
- `AppToast` for in-app feedback
- `ClassScheduleSheet` and `EnrollStudentSheet` reusable bottom sheets
- Custom scroll behavior supporting mouse, touch, and trackpad on web

### Backend & Database (28 migrations)

Key schema evolution delivered through migrations:

- Initial schema — profiles, students, teachers, faculties, departments, courses, enrollments, grades, attendance, leave, invoices, payments, notifications
- Academic structure — majors, academic years, semesters linked to years, registration flags
- Class redesign — sections renamed to classes; schedules moved to classes; curriculum tables; custom class term dates
- Assessments — assessments table, submissions table, materials storage bucket
- Leave workflow — notifications on leave events; session-level leave; teacher review policies; student delete pending leave
- Security & access — RLS policies, service role grants, student view of teacher profiles, app settings

### Data Seeding

- Dart seeder in `supabase/seeder/` populates realistic test data
- `seed.ps1` — run seeder against current DB
- `reset-db.ps1` — reset DB, restart local Kong gateway, then seed

### UI / UX Enhancements

- Light / dark / system theme with persisted preference
- Configurable brand color (admin system settings)
- English and Khmer localization (`app_en.arb`, `app_km.arb`)
- App launcher icons generated for Android, iOS, Web, Windows, and macOS

### Quality & Tooling

- `run-tests.ps1` — runs `flutter analyze` then `flutter test` (supports `-Strict`, `-SkipAnalyze`, `-Coverage`)
- `flutter_lints` configured via `analysis_options.yaml`
- Widget tests in `test/widget_test.dart`

---

## Platform Targets

| Platform | Status |
|---|---|
| **Web** | Primary production target — deployed to Vercel |
| **Android** | Supported — release build via `flutter build apk` |
| **iOS** | Supported — Xcode project configured |
| **Windows / macOS / Linux** | Scaffolded — available for desktop builds |

---

## Known Limitations & In-Progress Items

- Online payment processing is UI-only; no payment gateway integrated
- Some admin dashboard charts use illustrative data where per-period DB aggregation is not yet wired
- Finance module is view-only for admins and students
- Test coverage is minimal (smoke widget test only)

---

## Related Documentation

| Document | Contents |
|---|---|
| [README.md](../README.md) | Quick start, Supabase setup, commands, folder structure, DB tables |
| [admin_features.md](./admin_features.md) | Admin screen-by-screen feature reference |
| [deployment.md](./deployment.md) | Production deployment workflow (GitHub Actions → Vercel) |
