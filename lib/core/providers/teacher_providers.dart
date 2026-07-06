import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../services/teacher_service.dart';
import '../supabase/database.types.dart';

final teacherServiceProvider =
    Provider<TeacherService>((ref) => TeacherService());

final teacherProfileProvider = FutureProvider<TeacherProfile?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  return ref.read(teacherServiceProvider).getTeacherProfile(user.id);
});

final teacherCoursesProvider =
    FutureProvider<List<TeacherCourse>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref.read(teacherServiceProvider).getTeacherCourses(user.id);
});

final teacherStudentLeavesProvider =
    FutureProvider<List<StudentLeaveDetail>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref
      .read(teacherServiceProvider)
      .getStudentLeaveRequests(user.id);
});

final teacherNotificationsProvider =
    FutureProvider<List<NotificationRow>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref.read(teacherServiceProvider).getNotifications(user.id);
});

final courseStudentsProvider =
    FutureProvider.family<List<CourseStudent>, String>((ref, courseId) async {
  return ref.read(teacherServiceProvider).getCourseStudents(courseId);
});

final courseInfoProvider =
    FutureProvider.family<TeacherCourse?, String>((ref, courseId) async {
  return ref.read(teacherServiceProvider).getCourseById(courseId);
});

final leaveDetailProvider =
    FutureProvider.family<StudentLeaveDetail?, String>((ref, requestId) async {
  return ref
      .read(teacherServiceProvider)
      .getLeaveRequestDetail(requestId);
});

final courseGradesProvider =
    FutureProvider.family<List<CourseGradeData>, String>((ref, courseId) async {
  return ref.read(teacherServiceProvider).getCourseGrades(courseId);
});

final attendanceForDateProvider = FutureProvider.family<Map<String, String>,
    ({String courseId, String date})>((ref, p) async {
  return ref.read(teacherServiceProvider).getAttendanceForDate(p.courseId, p.date);
});

final courseMaterialsProvider =
    FutureProvider.family<List<CourseMaterialItem>, String>((ref, courseId) async {
  return ref.read(teacherServiceProvider).getCourseMaterials(courseId);
});

final attendanceSummaryProvider =
    FutureProvider.family<AttendanceSummaryData, String>((ref, courseId) async {
  return ref.read(teacherServiceProvider).getAttendanceSummary(courseId);
});

final courseAnalyticsProvider =
    FutureProvider.family<CourseAnalyticsData, String>((ref, courseId) async {
  return ref.read(teacherServiceProvider).getCourseAnalytics(courseId);
});

final allAttendanceProvider =
    FutureProvider.family<Map<String, String>, String>((ref, courseId) async {
  return ref.read(teacherServiceProvider).getAllAttendance(courseId);
});
