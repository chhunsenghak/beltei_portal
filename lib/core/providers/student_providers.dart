import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../services/student_service.dart';
import '../supabase/database.types.dart';

final studentServiceProvider =
    Provider<StudentService>((ref) => StudentService());

final studentProfileProvider = FutureProvider<StudentProfile?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  return ref.read(studentServiceProvider).getStudentProfile(user.id);
});

final studentCoursesProvider =
    FutureProvider<List<EnrolledCourse>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref.read(studentServiceProvider).getEnrolledCourses(user.id);
});

final studentGradesProvider =
    FutureProvider<List<SemesterGrades>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref.read(studentServiceProvider).getGradesBySemester(user.id);
});

final studentAttendanceProvider =
    FutureProvider<AttendanceSummary>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    return const AttendanceSummary(
      totalDays: 0,
      present: 0,
      absent: 0,
      late: 0,
      excused: 0,
      courseBreakdown: [],
      recentRecords: [],
    );
  }
  return ref.read(studentServiceProvider).getAttendanceSummary(user.id);
});

final studentFinanceProvider =
    FutureProvider<FinanceSummary>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    return const FinanceSummary(
      totalFees: 0,
      totalPaid: 0,
      outstanding: 0,
      status: 'PAID',
      invoices: [],
    );
  }
  return ref.read(studentServiceProvider).getFinanceSummary(user.id);
});

final studentLeaveRequestsProvider =
    FutureProvider<List<LeaveRequestRow>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref.read(studentServiceProvider).getLeaveRequests(user.id);
});

final studentNotificationsProvider =
    FutureProvider<List<NotificationRow>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref.read(studentServiceProvider).getNotifications(user.id);
});

final studentAttendanceCalendarProvider =
    FutureProvider<Map<String, AttendanceStatus>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return {};
  return ref.read(studentServiceProvider).getAttendanceCalendar(user.id);
});

final studentCourseAttendanceProvider =
    FutureProvider.family<List<AttendanceRecord>, String>((ref, courseId) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref
      .read(studentServiceProvider)
      .getCourseAttendanceHistory(user.id, courseId);
});
