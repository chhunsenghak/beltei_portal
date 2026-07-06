import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../services/admin_service.dart';

final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

final adminProfileProvider = FutureProvider<AdminProfile?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  return ref.read(adminServiceProvider).getAdminProfile(user.id);
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  return ref.read(adminServiceProvider).getAdminStats();
});

final appSettingsProvider = FutureProvider<AdminAppSettings>((ref) async {
  return ref.read(adminServiceProvider).getAppSettings();
});

final adminStudentsProvider = FutureProvider<List<AdminStudent>>((ref) async {
  return ref.read(adminServiceProvider).getStudents();
});

final adminTeachersProvider = FutureProvider<List<AdminTeacher>>((ref) async {
  return ref.read(adminServiceProvider).getTeachers();
});

final adminCoursesProvider = FutureProvider<List<AdminCourse>>((ref) async {
  return ref.read(adminServiceProvider).getCourses();
});

// All courses (active + inactive) — used for filter dropdowns in attendance screen
final adminAllCoursesProvider = FutureProvider<List<AdminCourse>>((ref) async {
  return ref.read(adminServiceProvider).getCourses(activeOnly: false);
});

final adminLeaveRequestsProvider =
    FutureProvider<List<AdminLeaveRequest>>((ref) async {
  return ref.read(adminServiceProvider).getLeaveRequests();
});

final adminSemestersProvider =
    FutureProvider<List<AdminSemester>>((ref) async {
  return ref.read(adminServiceProvider).getSemesters();
});

final adminAcademicYearsProvider =
    FutureProvider<List<AdminAcademicYear>>((ref) async {
  return ref.read(adminServiceProvider).getAcademicYears();
});

final adminFacultiesProvider =
    FutureProvider<List<AdminFaculty>>((ref) async {
  return ref.read(adminServiceProvider).getFaculties();
});

final adminMajorsProvider =
    FutureProvider<List<AdminMajor>>((ref) async {
  return ref.read(adminServiceProvider).getMajors();
});

final adminDepartmentsProvider =
    FutureProvider<List<AdminDepartment>>((ref) async {
  return ref.read(adminServiceProvider).getDepartments();
});

final adminInvoicesProvider =
    FutureProvider<List<AdminInvoiceRecord>>((ref) async {
  return ref.read(adminServiceProvider).getInvoices();
});

final studentDetailProvider =
    FutureProvider.family<AdminStudentDetail?, String>((ref, studentId) async {
  return ref.read(adminServiceProvider).getStudentDetail(studentId);
});

final teacherDetailProvider =
    FutureProvider.family<AdminTeacherDetail?, String>((ref, teacherId) async {
  return ref.read(adminServiceProvider).getTeacherDetail(teacherId);
});

final courseDetailProvider =
    FutureProvider.family<AdminCourseDetail?, String>((ref, courseId) async {
  return ref.read(adminServiceProvider).getCourseDetail(courseId);
});

final adminClassTermsProvider =
    FutureProvider<List<AdminClassTerm>>((ref) async {
  return ref.read(adminServiceProvider).getClassTerms();
});

// All classes (cohorts), independent of term — used to pick an existing
// class when adding a new term for the next semester.
final adminAllClassesProvider =
    FutureProvider<List<AdminClass>>((ref) async {
  return ref.read(adminServiceProvider).getClasses();
});

class AdminAttendanceFilter {
  final String? courseId;
  final String? semesterId;
  final String? studentId;

  const AdminAttendanceFilter({this.courseId, this.semesterId, this.studentId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminAttendanceFilter &&
          runtimeType == other.runtimeType &&
          courseId == other.courseId &&
          semesterId == other.semesterId &&
          studentId == other.studentId;

  @override
  int get hashCode => Object.hash(courseId, semesterId, studentId);
}

final adminAttendanceProvider =
    FutureProvider.family<List<AdminAttendanceRecord>, AdminAttendanceFilter>((ref, filter) async {
  return ref.read(adminServiceProvider).getAttendanceRecords(
    courseId: filter.courseId,
    semesterId: filter.semesterId,
    studentId: filter.studentId,
  );
});

final classTermEnrollmentsProvider =
    FutureProvider.family<List<CourseEnrollmentEntry>, String>((ref, classTermId) async {
  return ref.read(adminServiceProvider).getClassTermEnrollments(classTermId);
});

final classTermCoursesForCourseProvider =
    FutureProvider.family<List<AdminClassTermCourse>, String>((ref, courseId) async {
  return ref.read(adminServiceProvider).getClassTermCoursesForCourse(courseId);
});

final adminAnalyticsProvider =
    FutureProvider<AdminAnalyticsData>((ref) async {
  return ref.read(adminServiceProvider).getAnalyticsData();
});
