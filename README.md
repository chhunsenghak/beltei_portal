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

## Architecture

### Routing (GoRouter)

`lib/core/router/app_router.dart` is the single source of truth for navigation. Route path constants live in the `AppRoutes` class. The app has three top-level zones:

- **Auth zone** (`/`, `/login`, `/forgot-password`) — plain GoRoutes
- **Student zone** (`/student/...`) — `ShellRoute` wrapping `StudentShell`, which renders a persistent bottom nav bar and a nested navigator for its screens
- **Teacher zone** (`/teacher/...`) — same pattern with `TeacherShell`

Role-based redirect happens in `login_screen.dart`: after login, `_selectedRole` determines whether to `context.go(AppRoutes.studentHome)` or `context.go(AppRoutes.teacherHome)`.

### Feature Structure

`lib/features/<role>/screens/` — all screens for that role live flat in this directory. There is no repository/service layer; screens use inline `const` mock data at the top of each file (named `_k*` by convention). When wiring up real data, that mock data is the replacement target.

`lib/shared/widgets/` — four widgets used across features:
- `BelteiAppBar` — custom app bar (Container-based, not AppBar widget) that guarantees 16 px left alignment matching `AppSpacing.screenPadding`. Pass `showSearch`/`showNotification` flags or a custom `actions` list. All tab-level screens should use this.
- `StatusBadge` — pill badge; accepts a `BadgeType` enum value.
- `SectionHeader` — section title with optional action link.
- `InfoCard` — bordered card container.

### Design Tokens

All design constants are in `lib/core/constants/`. Never use magic numbers for colors, spacing, or typography:

| File | Exports |
|---|---|
| `app_colors.dart` | `AppColors.primaryNavy`, `AppColors.statusGreen`, etc. |
| `app_text_styles.dart` | `AppTextStyles.h1`, `AppTextStyles.body`, `AppTextStyles.h3White`, etc. (Inter font via google_fonts) |
| `app_spacing.dart` | `AppSpacing.screenPadding` (16), `AppSpacing.cardRadius` (12), `AppSpacing.sectionGap` (20), etc. |

### AppBar Rules

- **Tab screens** (root destinations inside a ShellRoute): use `BelteiAppBar()` or set `automaticallyImplyLeading: false` on any `AppBar`/`SliverAppBar` to prevent Flutter from inserting a 56 px back button that breaks the 16 px left alignment.
- **Detail screens pushed on top** (with explicit back button): set `leading:` explicitly and `automaticallyImplyLeading: false`.
- **Dashboard screens** with `SliverAppBar`: always include `automaticallyImplyLeading: false` and `titleSpacing: 0`, with the title wrapped in `Padding(left: 16)`.

### Assets

`assets/images/beltei_logo.png` — referenced via `Image.asset(...)`. The `assets/images/` directory is registered under `flutter.assets` in `pubspec.yaml`.
