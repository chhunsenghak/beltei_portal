import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../services/teacher_service.dart';
import '../supabase/database.types.dart';

final teacherServiceProvider = Provider<TeacherService>(
  (ref) => TeacherService(),
);

final teacherProfileProvider = FutureProvider.autoDispose<TeacherProfile?>((
  ref,
) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  return ref.read(teacherServiceProvider).getTeacherProfile(user.id);
});

final teacherCoursesProvider = FutureProvider.autoDispose<List<TeacherCourse>>((
  ref,
) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref.read(teacherServiceProvider).getTeacherCourses(user.id);
});

final teacherStudentLeavesProvider =
    FutureProvider.autoDispose<List<StudentLeaveDetail>>((ref) async {
      final user = await ref.watch(currentUserProvider.future);
      if (user == null) return [];
      return ref.read(teacherServiceProvider).getStudentLeaveRequests(user.id);
    });

final teacherNotificationsProvider =
    FutureProvider.autoDispose<List<NotificationRow>>((ref) async {
      final user = await ref.watch(currentUserProvider.future);
      if (user == null) return [];
      return ref.read(teacherServiceProvider).getNotifications(user.id);
    });

final courseStudentsProvider = FutureProvider.autoDispose
    .family<List<CourseStudent>, String>((ref, courseId) async {
      return ref.read(teacherServiceProvider).getCourseStudents(courseId);
    });

final courseInfoProvider = FutureProvider.autoDispose
    .family<TeacherCourse?, String>((ref, courseId) async {
      return ref.read(teacherServiceProvider).getCourseById(courseId);
    });

final leaveDetailProvider = FutureProvider.autoDispose
    .family<StudentLeaveDetail?, String>((ref, requestId) async {
      return ref.read(teacherServiceProvider).getLeaveRequestDetail(requestId);
    });

final courseGradesProvider = FutureProvider.autoDispose
    .family<List<CourseGradeData>, String>((ref, courseId) async {
      return ref.read(teacherServiceProvider).getCourseGrades(courseId);
    });

final attendanceForDateProvider = FutureProvider.autoDispose
    .family<Map<String, String>, ({String courseId, String date})>((
      ref,
      p,
    ) async {
      return ref
          .read(teacherServiceProvider)
          .getAttendanceForDate(p.courseId, p.date);
    });

final courseMaterialsProvider = FutureProvider.autoDispose
    .family<List<CourseMaterialItem>, String>((ref, courseId) async {
      return ref.read(teacherServiceProvider).getCourseMaterials(courseId);
    });

final attendanceSummaryProvider = FutureProvider.autoDispose
    .family<AttendanceSummaryData, String>((ref, courseId) async {
      return ref.read(teacherServiceProvider).getAttendanceSummary(courseId);
    });

final courseAnalyticsProvider = FutureProvider.autoDispose
    .family<CourseAnalyticsData, String>((ref, courseId) async {
      return ref.read(teacherServiceProvider).getCourseAnalytics(courseId);
    });

final allAttendanceProvider = FutureProvider.autoDispose
    .family<Map<String, String>, String>((ref, courseId) async {
      return ref.read(teacherServiceProvider).getAllAttendance(courseId);
    });

final courseAssessmentsProvider = FutureProvider.autoDispose
    .family<List<AssessmentItem>, String>((ref, classTermCourseId) async {
      return ref.read(teacherServiceProvider).getAssessments(classTermCourseId);
    });

final assessmentSubmissionsProvider = FutureProvider.autoDispose
    .family<List<SubmissionListItem>, String>((ref, arg) async {
      final parts = arg.split('_');
      final classTermCourseId = parts[0];
      final assessmentId = parts[1];
      return ref
          .read(teacherServiceProvider)
          .getAssessmentSubmissions(classTermCourseId, assessmentId);
    });
