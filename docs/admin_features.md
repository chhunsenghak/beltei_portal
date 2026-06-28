# BELTEI Campus Portal — Admin Features

## Overview

The admin portal is accessible to users with the `admin` role. It is wrapped in `AdminShell`, which renders a persistent top header and bottom navigation bar across all admin screens. The shell header shows the logged-in admin's real name, email, and initials pulled from Supabase.

---

## Navigation

| Tab | Route | Screen |
|---|---|---|
| Dashboard | `/admin` | `AdminDashboardScreen` |
| Users | `/admin/users` | `UserManagementScreen` |
| Academic | `/admin/academic` | `AcademicManagementScreen` |
| Finance | `/admin/finance` | `FinanceManagementScreen` |
| Settings | `/admin/settings` | `SystemSettingsScreen` |

---

## 1. Dashboard (`/admin`)

**File:** `lib/features/admin/screens/admin_dashboard_screen.dart`

**Data source:** Supabase (via `adminStatsProvider`, `adminLeaveRequestsProvider`)

### Features
- **Stats grid (6 KPI cards):** Total Students, Active Teachers, Active Courses, Revenue Collected, Leave Pending, Current Semester — all real-time from DB
- **Enrollment Trends chart:** 6-month bar chart (visual illustration; no per-month DB query)
- **Revenue Collection Rate:** Circular progress showing collected vs. total billed (real data)
- **Revenue by Department:** Bar breakdown per department (illustrative; no per-dept DB query)
- **Academic Performance card:** Avg GPA, Pass Rate, Honors count (illustrative)
- **Quick Management shortcuts:** Tap tiles to navigate to Users, Courses, Finance tabs
- **Recent Leave Requests:** Last 5 leave requests with requester name, type, date range, and status badge (real data)

---

## 2. User Management (`/admin/users`)

**File:** `lib/features/admin/screens/user_management_screen.dart`

**Data source:** Supabase (via `adminStudentsProvider`, `adminTeachersProvider`)

### Features
- **Students tab:** Searchable list of all students with student code, faculty, year level, and status badge (Active / Suspended / Graduated)
- **Teachers tab:** Searchable list of all teachers with employee code, department, and status badge
- Tap any row to navigate to the detail screen

---

## 2a. Student Detail (`/admin/users/students/:id`)

**File:** `lib/features/admin/screens/student_detail_screen.dart`

**Data source:** Supabase (via `studentDetailProvider(id)`)

### Features
- **Profile header:** Real initials avatar, full name, student code
- **Personal Info section:** First name, last name, date of birth, gender dropdown, nationality
- **Academic Info section:** Faculty dropdown, department, year level, enrollment year
- **Contact Info section:** Phone, email, residential address
- **Account Status section:** Active / Suspended / Archived toggle chips with color coding; Suspend Access and Save Changes buttons

---

## 2b. Teacher Detail (`/admin/users/teachers/:id`)

**File:** `lib/features/admin/screens/teacher_detail_screen.dart`

**Data source:** Supabase (via `teacherDetailProvider(id)`)

### Features
- **Profile header:** Real initials avatar, full name, employee code
- **Personal Info section:** First name, last name, email, phone, position
- **Department assignment:** Dropdown pre-populated with real department from DB
- **Assigned Courses chips:** Real course list from DB, removable from local state
- **Workload summary:** Course count and total enrolled students (real data)
- **Account Status section:** Active / Suspended toggle with Save Changes button

---

## 3. Academic Management (`/admin/academic`)

**File:** `lib/features/admin/screens/academic_management_screen.dart`

**Data source:** Supabase (via `adminCoursesProvider`, `adminLeaveRequestsProvider`, `adminSemestersProvider`)

### Tabs

#### Courses tab
- Searchable list of all courses with course code, department, enrolled/max count, and status badge
- Tap any course to navigate to Course Detail

#### Leave Requests tab
- List of all student/teacher leave requests with requester name, type, date range, and status badge
- **Business rule:** Admin can view AND approve/reject leave requests; teachers can only view

#### Semesters tab
- List of all semesters with name, academic year, start/end dates, and status tag (ACTIVE / UPCOMING / CLOSED)

---

## 3a. Course Detail (`/admin/academic/courses/:id`)

**File:** `lib/features/admin/screens/course_detail_screen.dart`

**Data source:** Supabase (via `courseDetailProvider(id)`)

### Features
- **General Information section:** Course code, name, description, credits (editable), department dropdown, semester dropdown — all pre-populated from DB
- **Faculty Assignment section:** Lead teacher dropdown pre-populated from DB
- **Enrolled Students card:** Real enrolled count, max capacity, and progress bar
- **Unsaved Changes warning:** Shown when credits field is edited
- **Save Changes / Delete Course** action buttons

---

## 4. Finance Management (`/admin/finance`)

**File:** `lib/features/admin/screens/finance_management_screen.dart`

**Data source:** Supabase (via `adminInvoicesProvider`, `adminStatsProvider`)

### Tabs

#### Overview tab
- Revenue summary cards: Total Billed, Collected, Outstanding (real data)
- Invoice list: All student invoices with name, student code, semester, amount, due date, and status badge (Paid / Partial / Overdue / Unpaid)

#### Enrollment tab
**File:** `lib/features/admin/screens/enrollment_management_screen.dart`
- Active semester name card (real data from `adminSemestersProvider`)
- Bulk Enrollment upload card
- Course-wise enrollment list with capacity progress bars (real data from `adminEnrollmentProvider`)
- Filter chips: All Courses / Under-capacity / Full or Overloaded
- Color-coded bars: Blue (< 50%) → Navy (50–79%) → Amber (80–99%) → Red (≥ 100%)

#### Attendance tab
**File:** `lib/features/admin/screens/attendance_management_screen.dart`
- Live search by student name or ID
- Table of 50 most recent attendance records (ordered by date desc) with student name, code, course name, date, and status code (P/A/L/E)
- Bulk Edit mode: checkbox selection → Mark Present / Mark Absent / Delete Records action bar
- Status colors: Green (present), Red (absent), Amber (late), Gray (excused)
- Export CSV button (UI only)

---

## 5. Settings (`/admin/settings`)

**File:** `lib/features/admin/screens/system_settings_screen.dart`

### Features
- University name and contact email fields
- Grouped settings list: Academic, Finance, Notifications, System
- Toggle switches for Push Notifications, Email Digests, SMS Alerts
- Sign Out button

---

## 6. University Analytics

**File:** `lib/features/admin/screens/university_analytics_screen.dart`

**Data source:** Supabase (via `adminStatsProvider`)

**Access:** Navigated from within Academic Management

### Features
- Semester selector dropdown (illustrative)
- **KPI cards (4):** Active Students (real), Active Courses (real), Attendance Rate (illustrative), Revenue Collected (real)
- Student Enrollment Trend: 12-month bar chart (illustrative)
- Grade Distribution: A/B/C/D breakdown progress bars (illustrative)
- Department Attendance: per-department attendance bars (illustrative)
- At-Risk Students card

---

## 7. Institutional Reports

**File:** `lib/features/admin/screens/institutional_reports_screen.dart`

**Data source:** Supabase (via `adminDepartmentsProvider`, `adminSemestersProvider`)

**Access:** Navigated from within Finance Management

### Features
- **Filters:** Date Range, Semester (real names from DB), Department (real names from DB)
- Quick Export: PDF Report / CSV Sheet buttons (UI only)
- **Report Modules:** Attendance, Grade, Revenue, Enrollment, Faculty — each with a "View Analytics" link
- Custom Dashboard shortcut
- Overview Trend chart: 6-month academic performance bar chart (illustrative)
- Monthly / Yearly toggle

---

## Data Sources Summary

| Provider | Table(s) queried |
|---|---|
| `adminStatsProvider` | `students`, `teachers`, `courses`, `invoices`, `leave_requests`, `semesters` |
| `adminStudentsProvider` | `students`, `profiles`, `departments`, `faculties` |
| `adminTeachersProvider` | `teachers`, `profiles`, `departments` |
| `adminCoursesProvider` | `courses`, `departments`, `profiles` (teachers) |
| `adminLeaveRequestsProvider` | `leave_requests`, `profiles` |
| `adminSemestersProvider` | `semesters` |
| `adminFacultiesProvider` | `faculties` |
| `adminDepartmentsProvider` | `departments`, `faculties` |
| `adminInvoicesProvider` | `invoices`, `students`, `profiles`, `semesters` |
| `adminEnrollmentProvider` | `courses`, `enrollments`, `profiles` (teachers) |
| `adminAttendanceProvider` | `attendance`, `profiles`, `students`, `courses` |
| `studentDetailProvider(id)` | `students`, `profiles`, `faculties`, `departments` |
| `teacherDetailProvider(id)` | `teachers`, `profiles`, `departments`, `courses`, `enrollments` |
| `courseDetailProvider(id)` | `courses`, `profiles` (teacher), `semesters`, `departments`, `enrollments` |
| `adminProfileProvider` | `admins`, `profiles` |

---

## Business Rules

- Only **admins** can approve or reject leave requests. Teachers can only view them.
- The `AdminShell` wraps all admin routes — detail screens must NOT include their own `AppBar` (they use `_buildNavRow` instead to avoid duplicate headers).
- Admin identity is resolved via `auth.userId` → `profiles` → `admins` tables.
