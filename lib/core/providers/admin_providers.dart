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

final adminEnrollmentProvider =
    FutureProvider<List<AdminEnrollmentRecord>>((ref) async {
  return ref.read(adminServiceProvider).getEnrollmentData();
});

final adminAttendanceProvider =
    FutureProvider<List<AdminAttendanceRecord>>((ref) async {
  return ref.read(adminServiceProvider).getAttendanceRecords();
});

final courseEnrollmentsProvider =
    FutureProvider.family<List<CourseEnrollmentEntry>, String>((ref, courseId) async {
  return ref.read(adminServiceProvider).getCourseEnrollments(courseId);
});

final classEnrollmentsProvider =
    FutureProvider.family<List<CourseEnrollmentEntry>, String>((ref, classId) async {
  return ref.read(adminServiceProvider).getClassEnrollments(classId);
});

final classesForCourseProvider =
    FutureProvider.family<List<AdminClass>, String>((ref, courseId) async {
  return ref.read(adminServiceProvider).getClasses(courseId);
});

final adminAnalyticsProvider =
    FutureProvider<AdminAnalyticsData>((ref) async {
  return ref.read(adminServiceProvider).getAnalyticsData();
});
