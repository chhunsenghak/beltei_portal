import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../services/student_service.dart';
import '../services/teacher_service.dart';
import '../supabase/database.types.dart';

final studentServiceProvider = Provider<StudentService>(
  (ref) => StudentService(),
);

final studentProfileProvider = FutureProvider.autoDispose<StudentProfile?>((
  ref,
) async {
  try {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return null;
    return await ref.read(studentServiceProvider).getStudentProfile(user.id);
  } catch (e, st) {
    debugPrint('studentProfileProvider error: $e\n$st');
    return null;
  }
});

final studentCoursesProvider = FutureProvider.autoDispose<List<EnrolledCourse>>(
  (ref) async {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return [];
    return ref.read(studentServiceProvider).getEnrolledCourses(user.id);
  },
);

final studentGradesProvider = FutureProvider.autoDispose<List<SemesterGrades>>((
  ref,
) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  return ref.read(studentServiceProvider).getGradesBySemester(user.id);
});

final studentAttendanceProvider = FutureProvider.autoDispose<AttendanceSummary>(
  (ref) async {
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
  },
);

final studentFinanceProvider = FutureProvider.autoDispose<FinanceSummary>((
  ref,
) async {
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
    FutureProvider.autoDispose<List<LeaveRequestRow>>((ref) async {
      final user = await ref.watch(currentUserProvider.future);
      if (user == null) return [];
      return ref.read(studentServiceProvider).getLeaveRequests(user.id);
    });

final studentNotificationsProvider =
    FutureProvider.autoDispose<List<NotificationRow>>((ref) async {
      final user = await ref.watch(currentUserProvider.future);
      if (user == null) return [];
      return ref.read(studentServiceProvider).getNotifications(user.id);
    });

final studentAttendanceCalendarProvider =
    FutureProvider.autoDispose<Map<String, AttendanceStatus>>((ref) async {
      final user = await ref.watch(currentUserProvider.future);
      if (user == null) return {};
      return ref.read(studentServiceProvider).getAttendanceCalendar(user.id);
    });

final studentCourseAttendanceProvider = FutureProvider.autoDispose
    .family<List<AttendanceRecord>, String>((ref, courseId) async {
      final user = await ref.watch(currentUserProvider.future);
      if (user == null) return [];
      return ref
          .read(studentServiceProvider)
          .getCourseAttendanceHistory(user.id, courseId);
    });

final studentCourseAssessmentsProvider = FutureProvider.autoDispose
    .family<List<AssessmentItem>, String>((ref, classTermCourseId) async {
      return ref
          .read(studentServiceProvider)
          .getCourseAssessments(classTermCourseId);
    });

final studentAssessmentSubmissionProvider = FutureProvider.autoDispose
    .family<AssessmentSubmission?, String>((ref, arg) async {
      final parts = arg.split('_');
      final assessmentId = parts[0];
      final studentId = parts[1];
      return ref
          .read(studentServiceProvider)
          .getSubmission(assessmentId, studentId);
    });
