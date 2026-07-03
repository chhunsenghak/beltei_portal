import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/student/screens/student_shell.dart';
import '../../features/student/screens/student_dashboard_screen.dart';
import '../../features/student/screens/course_list_screen.dart';
import '../../features/student/screens/course_detail_screen.dart' as student_course;
import '../../features/student/screens/attendance_dashboard_screen.dart';
import '../../features/student/screens/attendance_history_screen.dart';
import '../../features/student/screens/grades_dashboard_screen.dart';
import '../../features/student/screens/semester_grade_detail_screen.dart';
import '../../features/student/screens/schedule_screen.dart';
import '../../features/student/screens/daily_agenda_screen.dart';
import '../../features/student/screens/finance_dashboard_screen.dart';
import '../../features/student/screens/invoice_detail_screen.dart';
import '../../features/student/screens/online_payment_screen.dart';
import '../../features/student/screens/leave_request_dashboard_screen.dart';
import '../../features/student/screens/leave_request_detail_screen.dart';
import '../../features/student/screens/create_leave_request_screen.dart';
import '../../features/student/screens/academic_analytics_screen.dart';
import '../../features/student/screens/notification_center_screen.dart';
import '../../features/student/screens/student_profile_screen.dart';
import '../../features/teacher/screens/teacher_shell.dart';
import '../../features/teacher/screens/teacher_dashboard_screen.dart';
import '../../features/teacher/screens/teacher_course_list_screen.dart';
import '../../features/teacher/screens/mark_attendance_screen.dart';
import '../../features/teacher/screens/edit_attendance_screen.dart';
import '../../features/teacher/screens/attendance_report_screen.dart';
import '../../features/teacher/screens/grade_management_screen.dart';
import '../../features/teacher/screens/create_assessment_screen.dart';
import '../../features/teacher/screens/upload_materials_screen.dart';
import '../../features/teacher/screens/teacher_schedule_screen.dart';
import '../../features/teacher/screens/leave_management_screen.dart';
import '../../features/teacher/screens/leave_request_review_screen.dart';
import '../../features/teacher/screens/teacher_student_analytics_screen.dart';
import '../../features/teacher/screens/create_announcement_screen.dart';
import '../../features/teacher/screens/teacher_profile_screen.dart';
import '../../features/admin/screens/admin_shell.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/user_management_screen.dart';
import '../../features/admin/screens/student_detail_screen.dart';
import '../../features/admin/screens/teacher_detail_screen.dart';
import '../../features/admin/screens/academic_management_screen.dart';
import '../../features/admin/screens/course_detail_screen.dart';
import '../../features/admin/screens/finance_management_screen.dart';
import '../../features/admin/screens/system_settings_screen.dart';

// Notifies GoRouter whenever the Supabase auth state changes so the redirect
// runs again and unauthenticated users are sent to /login.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      // Defer to next frame so navigation never interrupts an in-progress build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) notifyListeners();
      });
    });
  }
}

final _authNotifier = _AuthNotifier();

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';

  // Student
  static const studentHome = '/student';
  static const courseList = '/student/courses';
  static const courseDetail = '/student/courses/:id';
  static const attendanceDashboard = '/student/attendance';
  static const attendanceHistory = '/student/attendance/history';
  static const gradesDashboard = '/student/grades';
  static const semesterGradeDetail = '/student/grades/:id';
  static const schedule = '/student/schedule';
  static const dailyAgenda = '/student/schedule/daily';
  static const financeDashboard = '/student/finance';
  static const invoiceDetail = '/student/finance/invoice/:id';
  static const onlinePayment = '/student/finance/payment';
  static const leaveRequestDashboard = '/student/leave';
  static const leaveRequestDetail = '/student/leave/:id';
  static const createLeaveRequest = '/student/leave/create';
  static const academicAnalytics = '/student/analytics';
  static const notificationCenter = '/student/notifications';
  static const studentProfile = '/student/profile';

  // Teacher
  static const teacherHome = '/teacher';
  static const teacherCourses = '/teacher/courses';
  static const teacherSchedule = '/teacher/schedule';
  static const teacherStudents = '/teacher/students';
  static const teacherAlerts = '/teacher/alerts';
  static const teacherProfile = '/teacher/profile';
  static const teacherAnnouncement = '/teacher/alerts/announcement';

  // Admin
  static const adminHome     = '/admin';
  static const adminUsers    = '/admin/users';
  static const adminAcademic = '/admin/academic';
  static const adminFinance  = '/admin/finance';
  static const adminSettings = '/admin/settings';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final isAuthenticated =
        Supabase.instance.client.auth.currentSession != null;
    final loc = state.matchedLocation;
    final isPublic = loc == AppRoutes.splash ||
        loc == AppRoutes.login ||
        loc == AppRoutes.forgotPassword;
    if (!isAuthenticated && !isPublic) return AppRoutes.login;
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ── Student shell ────────────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => StudentShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.studentHome,
          builder: (context, state) => const StudentDashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.courseList,
          builder: (context, state) => const CourseListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  student_course.CourseDetailScreen(courseId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.attendanceDashboard,
          builder: (context, state) => const AttendanceDashboardScreen(),
          routes: [
            GoRoute(
              path: 'history',
              builder: (context, state) => const AttendanceHistoryScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.gradesDashboard,
          builder: (context, state) => const GradesDashboardScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  SemesterGradeDetailScreen(semesterId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.schedule,
          builder: (context, state) => const ScheduleScreen(),
          routes: [
            GoRoute(
              path: 'daily',
              builder: (context, state) => const DailyAgendaScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.financeDashboard,
          builder: (context, state) => const FinanceDashboardScreen(),
          routes: [
            GoRoute(
              path: 'invoice/:id',
              builder: (context, state) =>
                  InvoiceDetailScreen(invoiceId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'payment',
              builder: (context, state) => const OnlinePaymentScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.leaveRequestDashboard,
          builder: (context, state) => const LeaveRequestDashboardScreen(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => const CreateLeaveRequestScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  LeaveRequestDetailScreen(requestId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.academicAnalytics,
          builder: (context, state) => const AcademicAnalyticsScreen(),
        ),
        GoRoute(
          path: AppRoutes.notificationCenter,
          builder: (context, state) => const NotificationCenterScreen(),
        ),
        GoRoute(
          path: AppRoutes.studentProfile,
          builder: (context, state) => const StudentProfileScreen(),
        ),
      ],
    ),

    // ── Teacher shell ────────────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => TeacherShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.teacherHome,
          builder: (context, state) => const TeacherDashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.teacherCourses,
          builder: (context, state) => const TeacherCourseListScreen(),
          routes: [
            GoRoute(
              path: ':id/attendance',
              builder: (context, state) =>
                  MarkAttendanceScreen(courseId: state.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) =>
                      EditAttendanceScreen(courseId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'report',
                  builder: (context, state) =>
                      AttendanceReportScreen(courseId: state.pathParameters['id']!),
                ),
              ],
            ),
            GoRoute(
              path: ':id/grades',
              builder: (context, state) =>
                  GradeManagementScreen(courseId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: ':id/assessments/create',
              builder: (context, state) =>
                  CreateAssessmentScreen(courseId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: ':id/materials',
              builder: (context, state) =>
                  UploadMaterialsScreen(courseId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.teacherSchedule,
          builder: (context, state) => const TeacherScheduleScreen(),
        ),
        GoRoute(
          path: AppRoutes.teacherStudents,
          builder: (context, state) => const LeaveManagementScreen(),
          routes: [
            GoRoute(
              path: 'leave/:id',
              builder: (context, state) =>
                  LeaveRequestReviewScreen(requestId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.teacherAlerts,
          builder: (context, state) => const TeacherStudentAnalyticsScreen(),
          routes: [
            GoRoute(
              path: 'announcement',
              builder: (context, state) => const CreateAnnouncementScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.teacherProfile,
          builder: (context, state) => const TeacherProfileScreen(),
        ),
      ],
    ),

    // ── Admin shell ──────────────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.adminHome,
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.adminUsers,
          builder: (context, state) => const UserManagementScreen(),
          routes: [
            GoRoute(
              path: 'students/:id',
              builder: (context, state) =>
                  StudentDetailScreen(studentId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'teachers/:id',
              builder: (context, state) =>
                  TeacherDetailScreen(teacherId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.adminAcademic,
          builder: (context, state) => const AcademicManagementScreen(),
          routes: [
            GoRoute(
              path: 'courses/:id',
              builder: (context, state) =>
                  CourseDetailScreen(courseId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.adminFinance,
          builder: (context, state) => const FinanceManagementScreen(),
        ),
        GoRoute(
          path: AppRoutes.adminSettings,
          builder: (context, state) => const SystemSettingsScreen(),
        ),
      ],
    ),
  ],
);
