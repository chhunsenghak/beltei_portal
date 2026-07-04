import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/database.types.dart';
import '../supabase/supabase_config.dart';

// ── DTOs ─────────────────────────────────────────────────────────────────────

class AdminStats {
  final int studentCount;
  final int teacherCount;
  final int courseCount;
  final int pendingLeaveCount;
  final double totalRevenue;
  final double collectedRevenue;
  final double outstandingRevenue;
  final String currentSemester;

  const AdminStats({
    required this.studentCount,
    required this.teacherCount,
    required this.courseCount,
    required this.pendingLeaveCount,
    required this.totalRevenue,
    required this.collectedRevenue,
    required this.outstandingRevenue,
    required this.currentSemester,
  });

  static final _fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

  String get fmtRevenue => _fmt.format(totalRevenue);
  String get fmtCollected => _fmt.format(collectedRevenue);
  String get fmtOutstanding => _fmt.format(outstandingRevenue);
}

class AdminAnalyticsData {
  final List<({String month, int count})> monthlyEnrollments;
  final List<({String name, double collectedPct})> facultyRevenue;
  final List<({String grade, int count})> gradeDistribution;
  final List<({String name, double attendancePct})> facultyAttendance;
  final int atRiskCount;
  final double avgGpa;
  final double passRate;

  const AdminAnalyticsData({
    required this.monthlyEnrollments,
    required this.facultyRevenue,
    required this.gradeDistribution,
    required this.facultyAttendance,
    required this.atRiskCount,
    required this.avgGpa,
    required this.passRate,
  });
}

class AdminStudent {
  final String id;
  final String studentCode;
  final String fullName;
  final String email;
  final String? phone;
  final String statusName;
  final String? majorName;
  final String? facultyName;
  final int yearLevel;

  const AdminStudent({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.email,
    this.phone,
    required this.statusName,
    this.majorName,
    this.facultyName,
    required this.yearLevel,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get statusLabel {
    switch (statusName) {
      case 'active': return 'Active';
      case 'inactive': return 'Inactive';
      case 'graduated': return 'Graduated';
      case 'suspended': return 'Suspended';
      default: return statusName;
    }
  }
}

class AdminTeacher {
  final String id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String statusName;
  final String? facultyName;
  final int courseCount;

  const AdminTeacher({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.statusName,
    this.facultyName,
    required this.courseCount,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get statusLabel {
    switch (statusName) {
      case 'active': return 'Active';
      case 'inactive': return 'Inactive';
      default: return statusName;
    }
  }
}

class AdminCourse {
  final String courseId;
  final String code;
  final String name;
  final int credits;
  final String? teacherName;
  final String? facultyId;
  final String? facultyName;
  final String? majorName;
  final String? semesterId;
  final String? semesterName;
  final String? semesterAcademicYear;
  final int enrolledCount;
  final int maxStudents;
  final CourseStatus status;

  const AdminCourse({
    required this.courseId,
    required this.code,
    required this.name,
    required this.credits,
    this.teacherName,
    this.facultyId,
    this.facultyName,
    this.majorName,
    this.semesterId,
    this.semesterName,
    this.semesterAcademicYear,
    required this.enrolledCount,
    required this.maxStudents,
    required this.status,
  });
}

class AdminLeaveRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final String? requesterCode;
  final String requesterType;
  final String type;
  final String reason;
  final String startDate;
  final String endDate;
  final String? docUrl;
  final LeaveStatus status;
  final String? reviewNotes;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  const AdminLeaveRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    this.requesterCode,
    required this.requesterType,
    required this.type,
    required this.reason,
    required this.startDate,
    required this.endDate,
    this.docUrl,
    required this.status,
    this.reviewNotes,
    this.reviewedAt,
    this.createdAt,
  });

  String get initials {
    final parts = requesterName.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return requesterName.isNotEmpty ? requesterName[0].toUpperCase() : '?';
  }

  String get dateRange {
    try {
      final s = DateFormat('MMM d').format(DateTime.parse(startDate));
      final e = DateFormat('MMM d, yyyy').format(DateTime.parse(endDate));
      return '$s – $e';
    } catch (_) {
      return '$startDate – $endDate';
    }
  }

  String get programInfo {
    final typePart = requesterType == 'student' ? 'Student' : 'Teacher';
    if (requesterCode != null) return '$typePart • ${requesterCode!}';
    return typePart;
  }
}

class AdminSemester {
  final String id;
  final String name;
  final String academicYear;
  final String startDate;
  final String endDate;
  final bool isCurrent;
  final bool registrationOpen;
  final int classCount;

  const AdminSemester({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
    required this.registrationOpen,
    this.classCount = 0,
  });

  String get statusLabel {
    if (isCurrent) return 'ACTIVE';
    try {
      final now = DateTime.now();
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      if (now.isBefore(start)) return 'UPCOMING';
      if (now.isAfter(end)) return 'CLOSED';
    } catch (_) {}
    return 'CLOSED';
  }

  String get fmtStart {
    try { return DateFormat('MMM d, yyyy').format(DateTime.parse(startDate)); } catch (_) { return startDate; }
  }

  String get fmtEnd {
    try { return DateFormat('MMM d, yyyy').format(DateTime.parse(endDate)); } catch (_) { return endDate; }
  }
}

class AdminAcademicYear {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final bool isCurrent;

  const AdminAcademicYear({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
  });

  String get fmtStart {
    try { return DateFormat('MMM d, yyyy').format(DateTime.parse(startDate)); } catch (_) { return startDate; }
  }

  String get fmtEnd {
    try { return DateFormat('MMM d, yyyy').format(DateTime.parse(endDate)); } catch (_) { return endDate; }
  }
}

class AdminFaculty {
  final String id;
  final String name;
  final String code;
  final int majorCount;

  const AdminFaculty({
    required this.id,
    required this.name,
    required this.code,
    required this.majorCount,
  });
}

class AdminMajor {
  final String id;
  final String name;
  final String? departmentId;
  final String? departmentName;
  final String? facultyId;
  final String? facultyName;

  const AdminMajor({
    required this.id,
    required this.name,
    this.departmentId,
    this.departmentName,
    this.facultyId,
    this.facultyName,
  });
}

class AdminDepartment {
  final String id;
  final String? facultyId;
  final String? facultyCode;
  final String name;
  final String code;
  final int studentCount;

  const AdminDepartment({
    required this.id,
    this.facultyId,
    this.facultyCode,
    required this.name,
    required this.code,
    required this.studentCount,
  });
}

class AdminInvoiceRecord {
  final String invoiceId;
  final String studentId;
  final String studentName;
  final String studentCode;
  final String? semesterName;
  final double amount;
  final String dueDate;
  final InvoiceStatus status;

  const AdminInvoiceRecord({
    required this.invoiceId,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    this.semesterName,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  static final _fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  String get initials {
    final parts = studentName.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return studentName.isNotEmpty ? studentName[0].toUpperCase() : '?';
  }

  String get fmtAmount => _fmt.format(amount);

  String get statusLabel {
    switch (status) {
      case InvoiceStatus.paid: return 'paid';
      case InvoiceStatus.partial: return 'partial';
      case InvoiceStatus.overdue: return 'overdue';
      default: return 'unpaid';
    }
  }
}

class AdminProfile {
  final String id;
  final String fullName;
  final String email;
  final String? phone;

  const AdminProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}

class AdminStudentDetail {
  final String id;
  final String studentCode;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? nationality;
  final String? address;
  final String statusName;
  final int yearLevel;
  final int enrollmentYear;
  final String? facultyId;
  final String? facultyName;
  final String? majorId;
  final String? majorName;

  const AdminStudentDetail({
    required this.id,
    required this.studentCode,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.address,
    required this.statusName,
    required this.yearLevel,
    required this.enrollmentYear,
    this.facultyId,
    this.facultyName,
    this.majorId,
    this.majorName,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    final combined = '$f$l';
    return combined.isNotEmpty ? combined : '?';
  }

  String get statusLabel {
    switch (statusName) {
      case 'active':    return 'Active';
      case 'suspended': return 'Suspended';
      case 'graduated': return 'Graduated';
      case 'inactive':  return 'Inactive';
      default:          return statusName;
    }
  }

  String get displayGender {
    switch (gender?.toLowerCase()) {
      case 'male':   return 'Male';
      case 'female': return 'Female';
      case 'other':  return 'Other';
      default:       return 'Male';
    }
  }

  String get fmtDateOfBirth {
    if (dateOfBirth == null) return '';
    try {
      final d = DateTime.parse(dateOfBirth!);
      return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return dateOfBirth!;
    }
  }
}

class AdminTeacherDetail {
  final String id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? position;
  final String statusName;
  final String? facultyId;
  final String? facultyName;
  final List<String> assignedCourses;
  final int totalStudents;

  const AdminTeacherDetail({
    required this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.position,
    required this.statusName,
    this.facultyId,
    this.facultyName,
    required this.assignedCourses,
    required this.totalStudents,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    final combined = '$f$l';
    return combined.isNotEmpty ? combined : '?';
  }
}

class AdminCourseDetail {
  final String id;
  final String code;
  final String name;
  final String? description;
  final int credits;
  final String statusName;
  final String? teacherId;
  final String? teacherName;
  final String? semesterId;
  final String? semesterName;
  final String? majorId;
  final String? majorName;
  final String? departmentId;
  final String? departmentName;
  final String? facultyId;
  final String? facultyName;
  final int maxStudents;
  final int enrolledCount;
  final List<Map<String, dynamic>> schedule;

  const AdminCourseDetail({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.credits,
    required this.statusName,
    this.teacherId,
    this.teacherName,
    this.semesterId,
    this.semesterName,
    this.majorId,
    this.majorName,
    this.departmentId,
    this.departmentName,
    this.facultyId,
    this.facultyName,
    required this.maxStudents,
    required this.enrolledCount,
    this.schedule = const [],
  });

  double get enrollmentPct => maxStudents > 0 ? enrolledCount / maxStudents : 0.0;
}

class AdminClass {
  final String id;
  final String courseId;
  final String courseCode;
  final String courseName;
  final String? semesterId;
  final String? semesterName;
  final String? teacherId;
  final String? teacherName;
  final String programType;   // 'national' | 'international'
  final String scheduleType;  // 'weekday'  | 'weekend'
  final String shift;         // 'morning'  | 'afternoon' | 'evening'
  final String classCode;
  final String? room;
  final int maxStudents;
  final int enrolledCount;
  final String status;

  const AdminClass({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    this.semesterId,
    this.semesterName,
    this.teacherId,
    this.teacherName,
    required this.programType,
    required this.scheduleType,
    required this.shift,
    required this.classCode,
    this.room,
    required this.maxStudents,
    required this.enrolledCount,
    required this.status,
  });

  double get pct => maxStudents > 0 ? enrolledCount / maxStudents : 0.0;

  String get shiftLabel {
    switch (shift) {
      case 'morning':   return 'Morning';
      case 'afternoon': return 'Afternoon';
      case 'evening':   return 'Evening';
      default:          return shift;
    }
  }

  String get programLabel =>
      programType == 'international' ? 'International' : 'National';

  String get scheduleLabel =>
      scheduleType == 'weekend' ? 'Weekend' : 'Weekday';
}

class AdminEnrollmentRecord {
  final String classId;
  final String courseId;
  final String? semesterId;
  final String courseCode;
  final String courseName;
  final String? teacherId;
  final String? teacherName;
  final String programType;   // 'national' | 'international'
  final String scheduleType;  // 'weekday'  | 'weekend'
  final String shift;
  final String classCode;
  final String? room;
  final String? semesterName;
  final String? facultyId;
  final String? facultyName;
  final int enrolled;
  final int maxStudents;

  const AdminEnrollmentRecord({
    required this.classId,
    required this.courseId,
    this.semesterId,
    required this.courseCode,
    required this.courseName,
    this.teacherId,
    this.teacherName,
    required this.programType,
    required this.scheduleType,
    required this.shift,
    required this.classCode,
    this.room,
    this.semesterName,
    this.facultyId,
    this.facultyName,
    required this.enrolled,
    required this.maxStudents,
  });

  double get pct => maxStudents > 0 ? enrolled / maxStudents : 0.0;

  String get shiftLabel {
    switch (shift) {
      case 'morning':   return 'Morning';
      case 'afternoon': return 'Afternoon';
      case 'evening':   return 'Evening';
      default:          return shift;
    }
  }

  String get programLabel =>
      programType == 'international' ? 'International' : 'National';

  String get scheduleLabel =>
      scheduleType == 'weekend' ? 'Weekend' : 'Weekday';
}

class CourseEnrollmentEntry {
  final String enrollmentId;
  final String studentId;
  final String studentCode;
  final String studentName;
  final String status;
  final DateTime? enrolledAt;

  const CourseEnrollmentEntry({
    required this.enrollmentId,
    required this.studentId,
    required this.studentCode,
    required this.studentName,
    required this.status,
    this.enrolledAt,
  });

  String get initials {
    final parts = studentName.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return studentName.isNotEmpty ? studentName[0].toUpperCase() : '?';
  }
}

class AdminAttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String studentCode;
  final int? yearLevel;
  final String? majorId;
  final String? majorName;
  final String? facultyId;
  final String? facultyName;
  final String courseId;
  final String courseName;
  final String? semesterId;
  final String? semesterName;
  final String? academicYear;
  final String date;
  final String status;

  const AdminAttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    this.yearLevel,
    this.majorId,
    this.majorName,
    this.facultyId,
    this.facultyName,
    required this.courseId,
    required this.courseName,
    this.semesterId,
    this.semesterName,
    this.academicYear,
    required this.date,
    required this.status,
  });

  String get initials {
    final parts = studentName.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return studentName.isNotEmpty ? studentName[0].toUpperCase() : '?';
  }

  String get statusCode {
    switch (status) {
      case 'present': return 'P';
      case 'absent':  return 'A';
      case 'late':    return 'L';
      case 'excused': return 'E';
      default:        return status.isNotEmpty ? status[0].toUpperCase() : '?';
    }
  }

  String get fmtDate {
    try {
      final d = DateTime.parse(date);
      return DateFormat('MMM d, yyyy').format(d);
    } catch (_) {
      return date;
    }
  }

  String get yearLevelLabel =>
      yearLevel != null ? 'Year $yearLevel' : '';
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _joinName(Map<String, dynamic> profile) =>
    '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();

// ── Service ───────────────────────────────────────────────────────────────────

class AdminAppSettings {
  final String id;
  final String universityName;
  final String contactEmail;
  final String? logoUrl;
  final String semesterFormat; // 'semester' | 'trimester'
  final bool pushNotificationsEnabled;
  final bool emailDigestsEnabled;

  const AdminAppSettings({
    required this.id,
    required this.universityName,
    required this.contactEmail,
    this.logoUrl,
    required this.semesterFormat,
    required this.pushNotificationsEnabled,
    required this.emailDigestsEnabled,
  });
}

class AdminService {
  SupabaseClient get _db => Supabase.instance.client;

  static SupabaseClient? _adminClient;
  SupabaseClient get _admin {
    _adminClient ??= SupabaseClient(
      supabaseUrl,
      supabaseServiceRoleKey,
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    return _adminClient!;
  }

  Future<AdminProfile?> getAdminProfile(String userId) async {
    final p = await _db.from('profiles').select('id, first_name, last_name, email, phone').eq('id', userId).maybeSingle();
    if (p == null) return null;
    return AdminProfile(
      id: p['id'] as String,
      fullName: _joinName(p),
      email: p['email'] as String,
      phone: p['phone'] as String?,
    );
  }

  Future<AdminAppSettings> getAppSettings() async {
    final s = await _db.from('app_settings').select().limit(1).single();
    return AdminAppSettings(
      id: s['id'] as String,
      universityName: s['university_name'] as String,
      contactEmail: s['contact_email'] as String,
      logoUrl: s['logo_url'] as String?,
      semesterFormat: s['semester_format'] as String? ?? 'semester',
      pushNotificationsEnabled: s['push_notifications_enabled'] as bool? ?? true,
      emailDigestsEnabled: s['email_digests_enabled'] as bool? ?? false,
    );
  }

  Future<void> updateAppSettings({
    required String id,
    required String universityName,
    required String contactEmail,
    String? logoUrl,
    required String semesterFormat,
    required bool pushNotificationsEnabled,
    required bool emailDigestsEnabled,
  }) async {
    await _db.from('app_settings').update({
      'university_name': universityName.trim(),
      'contact_email': contactEmail.trim(),
      if (logoUrl != null) 'logo_url': logoUrl,
      'semester_format': semesterFormat,
      'push_notifications_enabled': pushNotificationsEnabled,
      'email_digests_enabled': emailDigestsEnabled,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<String> uploadLogo(Uint8List bytes, String fileExt) async {
    final path = 'logo-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    await _db.storage.from('app-assets').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
        );
    return _db.storage.from('app-assets').getPublicUrl(path);
  }

  Future<AdminStats> getAdminStats() async {
    final students = await _db.from('students').select('status');
    final teachers = await _db.from('teachers').select('status');
    final courses = await _db.from('courses').select('status');
    final pendingLeaves = await _db.from('leave_requests').select('id').eq('status', 'pending');
    final invoices = await _db.from('invoices').select('amount, status');

    final totalRevenue = invoices.fold<double>(0, (s, i) => s + (i['amount'] as num).toDouble());
    final collected = invoices.where((i) => i['status'] == 'paid').fold<double>(0, (s, i) => s + (i['amount'] as num).toDouble());
    final outstanding = invoices.where((i) => i['status'] == 'overdue').fold<double>(0, (s, i) => s + (i['amount'] as num).toDouble());

    final semData = await _db.from('semesters').select('name').eq('is_current', true).limit(1).maybeSingle();

    return AdminStats(
      studentCount: students.where((s) => s['status'] == 'active').length,
      teacherCount: teachers.where((t) => t['status'] == 'active').length,
      courseCount: courses.where((c) => c['status'] == 'active').length,
      pendingLeaveCount: pendingLeaves.length,
      totalRevenue: totalRevenue,
      collectedRevenue: collected,
      outstandingRevenue: outstanding,
      currentSemester: semData?['name'] as String? ?? 'N/A',
    );
  }

  Future<List<AdminStudent>> getStudents({String? query}) async {
    final data = await _db.from('students')
        .select('id, student_code, year_level, status, faculty_id, major_id')
        .order('student_code');
    if (data.isEmpty) return [];

    final ids = data.map((s) => s['id'] as String).toList();
    final profiles = await _db.from('profiles').select('id, first_name, last_name, email, phone').inFilter('id', ids);

    final majorIds = data.map((s) => s['major_id'] as String?).whereType<String>().toSet().toList();
    final facultyIds = data.map((s) => s['faculty_id'] as String?).whereType<String>().toSet().toList();

    final Map<String, String> majorNames = {};
    if (majorIds.isNotEmpty) {
      final majors = await _db.from('majors').select('id, name').inFilter('id', majorIds);
      for (final m in majors) majorNames[m['id'] as String] = m['name'] as String;
    }

    final Map<String, String> facNames = {};
    if (facultyIds.isNotEmpty) {
      final facs = await _db.from('faculties').select('id, name').inFilter('id', facultyIds);
      for (final f in facs) facNames[f['id'] as String] = f['name'] as String;
    }

    final profileMap = {for (final p in profiles) p['id'] as String: p};
    final q = query?.toLowerCase();
    final result = <AdminStudent>[];

    for (final s in data) {
      final profile = profileMap[s['id'] as String];
      final fullName = profile != null ? _joinName(profile) : 'Unknown';
      final code = s['student_code'] as String;
      if (q != null && q.isNotEmpty) {
        if (!fullName.toLowerCase().contains(q) && !code.toLowerCase().contains(q)) continue;
      }
      result.add(AdminStudent(
        id: s['id'] as String,
        studentCode: code,
        fullName: fullName,
        email: profile?['email'] as String? ?? '',
        phone: profile?['phone'] as String?,
        statusName: s['status'] as String? ?? 'active',
        majorName: s['major_id'] != null ? majorNames[s['major_id'] as String] : null,
        facultyName: s['faculty_id'] != null ? facNames[s['faculty_id'] as String] : null,
        yearLevel: s['year_level'] as int? ?? 1,
      ));
    }
    return result;
  }

  Future<List<AdminTeacher>> getTeachers({String? query}) async {
    final data = await _db.from('teachers')
        .select('id, employee_code, faculty_id, status')
        .order('employee_code');
    if (data.isEmpty) return [];

    final ids = data.map((t) => t['id'] as String).toList();
    final profiles = await _db.from('profiles').select('id, first_name, last_name, email').inFilter('id', ids);

    final facIds = data.map((t) => t['faculty_id'] as String?).whereType<String>().toSet().toList();
    final Map<String, String> facNames = {};
    if (facIds.isNotEmpty) {
      final facs = await _db.from('faculties').select('id, name').inFilter('id', facIds);
      for (final f in facs) {
        facNames[f['id'] as String] = f['name'] as String;
      }
    }

    final coursesData = await _db.from('courses').select('teacher_id').inFilter('teacher_id', ids).eq('status', 'active');
    final Map<String, int> courseCounts = {};
    for (final c in coursesData) {
      final tid = c['teacher_id'] as String?;
      if (tid != null) courseCounts[tid] = (courseCounts[tid] ?? 0) + 1;
    }

    final profileMap = {for (final p in profiles) p['id'] as String: p};
    final q = query?.toLowerCase();
    final result = <AdminTeacher>[];

    for (final t in data) {
      final tid = t['id'] as String;
      final profile = profileMap[tid];
      final fullName = profile != null ? _joinName(profile) : 'Unknown';
      final code = t['employee_code'] as String;
      if (q != null && q.isNotEmpty) {
        if (!fullName.toLowerCase().contains(q) && !code.toLowerCase().contains(q)) continue;
      }
      result.add(AdminTeacher(
        id: tid,
        employeeCode: code,
        fullName: fullName,
        email: profile?['email'] as String? ?? '',
        statusName: t['status'] as String? ?? 'active',
        facultyName: t['faculty_id'] != null ? facNames[t['faculty_id'] as String] : null,
        courseCount: courseCounts[tid] ?? 0,
      ));
    }
    return result;
  }

  Future<List<AdminCourse>> getCourses({String? query, bool activeOnly = true}) async {
    final req = _db.from('courses')
        .select('id, code, name, credits, teacher_id, semester_id, major_id, department_id, max_students, status');
    final data = await (activeOnly ? req.eq('status', 'active') : req).order('code');
    if (data.isEmpty) return [];

    final courseIds = data.map((c) => c['id'] as String).toList();
    final teacherIds = data.map((c) => c['teacher_id'] as String?).whereType<String>().toSet().toList();
    final semIds = data.map((c) => c['semester_id'] as String?).whereType<String>().toSet().toList();
    final deptIds = data.map((c) => c['department_id'] as String?).whereType<String>().toSet().toList();
    final majorIds = data.map((c) => c['major_id'] as String?).whereType<String>().toSet().toList();

    final Map<String, String> majorNames = {};
    if (majorIds.isNotEmpty) {
      final majors = await _db.from('majors').select('id, name').inFilter('id', majorIds);
      for (final m in majors) { majorNames[m['id'] as String] = m['name'] as String; }
    }

    final Map<String, String> teacherNames = {};
    if (teacherIds.isNotEmpty) {
      final ps = await _db.from('profiles').select('id, first_name, last_name').inFilter('id', teacherIds);
      for (final p in ps) { teacherNames[p['id'] as String] = _joinName(p); }
    }

    final Map<String, String> semNames = {};
    final Map<String, String> semYears = {};
    if (semIds.isNotEmpty) {
      final sems = await _db.from('semesters')
          .select('id, name, academic_year')
          .inFilter('id', semIds);
      for (final s in sems) {
        semNames[s['id'] as String] = s['name'] as String;
        semYears[s['id'] as String] = s['academic_year'] as String? ?? '';
      }
    }

    // Resolve faculty id + name via department → faculty chain
    final Map<String, String> deptToFacultyId = {};
    final Map<String, String> deptToFacultyName = {};
    if (deptIds.isNotEmpty) {
      final depts = await _db.from('departments')
          .select('id, faculty_id')
          .inFilter('id', deptIds);
      final facIds = depts
          .map((d) => d['faculty_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      final Map<String, String> facMap = {};
      if (facIds.isNotEmpty) {
        final facs = await _db.from('faculties')
            .select('id, name')
            .inFilter('id', facIds);
        for (final f in facs) {
          facMap[f['id'] as String] = f['name'] as String;
        }
      }
      for (final d in depts) {
        final fid = d['faculty_id'] as String?;
        if (fid != null) {
          deptToFacultyId[d['id'] as String] = fid;
          if (facMap.containsKey(fid)) {
            deptToFacultyName[d['id'] as String] = facMap[fid]!;
          }
        }
      }
    }

    final enrollData = await _db.from('enrollments').select('course_id').inFilter('course_id', courseIds).neq('status', 'dropped');
    final Map<String, int> enrollCounts = {};
    for (final e in enrollData) {
      final cid = e['course_id'] as String;
      enrollCounts[cid] = (enrollCounts[cid] ?? 0) + 1;
    }

    final q = query?.toLowerCase();
    final result = <AdminCourse>[];
    for (final c in data) {
      final cid = c['id'] as String;
      final code = c['code'] as String;
      final name = c['name'] as String;
      if (q != null && q.isNotEmpty) {
        if (!name.toLowerCase().contains(q) && !code.toLowerCase().contains(q)) continue;
      }
      final sid = c['semester_id'] as String?;
      final did = c['department_id'] as String?;
      final mid = c['major_id'] as String?;
      result.add(AdminCourse(
        courseId: cid,
        code: code,
        name: name,
        credits: c['credits'] as int? ?? 3,
        teacherName: c['teacher_id'] != null ? teacherNames[c['teacher_id'] as String] : null,
        facultyId: did != null ? deptToFacultyId[did] : null,
        facultyName: did != null ? deptToFacultyName[did] : null,
        majorName: mid != null ? majorNames[mid] : null,
        semesterId: sid,
        semesterName: sid != null ? semNames[sid] : null,
        semesterAcademicYear: sid != null ? semYears[sid] : null,
        enrolledCount: enrollCounts[cid] ?? 0,
        maxStudents: c['max_students'] as int? ?? 40,
        status: CourseStatus.values.byName(c['status'] as String? ?? 'active'),
      ));
    }
    return result;
  }

  Future<List<AdminLeaveRequest>> getLeaveRequests({String? statusFilter}) async {
    final List<Map<String, dynamic>> leavesData;
    if (statusFilter != null && statusFilter != 'all') {
      leavesData = await _db.from('leave_requests').select('*').eq('status', statusFilter).order('created_at', ascending: false);
    } else {
      leavesData = await _db.from('leave_requests').select('*').order('created_at', ascending: false);
    }
    if (leavesData.isEmpty) return [];

    final requesterIds = leavesData.map((l) => l['requester_id'] as String).toSet().toList();
    final profiles = await _db.from('profiles').select('id, first_name, last_name').inFilter('id', requesterIds);
    final Map<String, String> nameMap = {for (final p in profiles) p['id'] as String: _joinName(p)};

    final studentIds = leavesData.where((l) => l['requester_type'] == 'student').map((l) => l['requester_id'] as String).toSet().toList();
    final Map<String, String> studentCodes = {};
    if (studentIds.isNotEmpty) {
      final ss = await _db.from('students').select('id, student_code').inFilter('id', studentIds);
      for (final s in ss) studentCodes[s['id'] as String] = s['student_code'] as String;
    }

    final teacherIds = leavesData.where((l) => l['requester_type'] == 'teacher').map((l) => l['requester_id'] as String).toSet().toList();
    final Map<String, String> teacherCodes = {};
    if (teacherIds.isNotEmpty) {
      final ts = await _db.from('teachers').select('id, employee_code').inFilter('id', teacherIds);
      for (final t in ts) teacherCodes[t['id'] as String] = t['employee_code'] as String;
    }

    return leavesData.map((l) {
      final rid = l['requester_id'] as String;
      final rtype = l['requester_type'] as String;
      return AdminLeaveRequest(
        id: l['id'] as String,
        requesterId: rid,
        requesterName: nameMap[rid] ?? 'Unknown',
        requesterCode: rtype == 'student' ? studentCodes[rid] : teacherCodes[rid],
        requesterType: rtype,
        type: l['type'] as String,
        reason: l['reason'] as String,
        startDate: l['start_date'] as String,
        endDate: l['end_date'] as String,
        docUrl: l['doc_url'] as String?,
        status: LeaveStatus.values.byName(l['status'] as String? ?? 'pending'),
        reviewNotes: l['review_notes'] as String?,
        reviewedAt: l['reviewed_at'] != null ? DateTime.parse(l['reviewed_at'] as String) : null,
        createdAt: l['created_at'] != null ? DateTime.parse(l['created_at'] as String) : null,
      );
    }).toList();
  }

  Future<void> createLeaveRequest({
    required String requesterId,
    required String requesterType,
    required String type,
    required String reason,
    required String startDate,
    required String endDate,
  }) async {
    await _db.from('leave_requests').insert({
      'requester_id': requesterId,
      'requester_type': requesterType,
      'type': type.trim(),
      'reason': reason.trim(),
      'start_date': startDate,
      'end_date': endDate,
      'status': 'pending',
    });
  }

  Future<void> approveLeaveRequest(String id, String adminId, {String? notes}) async {
    await _db.from('leave_requests').update({
      'status': 'approved',
      'reviewed_by': adminId,
      'reviewed_at': DateTime.now().toIso8601String(),
      if (notes != null && notes.isNotEmpty) 'review_notes': notes,
    }).eq('id', id);
    await _notifyStudentOfDecision(id);
  }

  Future<void> rejectLeaveRequest(String id, String adminId, {String? notes}) async {
    await _db.from('leave_requests').update({
      'status': 'rejected',
      'reviewed_by': adminId,
      'reviewed_at': DateTime.now().toIso8601String(),
      if (notes != null && notes.isNotEmpty) 'review_notes': notes,
    }).eq('id', id);
    await _notifyStudentOfDecision(id);
  }

  Future<void> _notifyStudentOfDecision(String leaveId) async {
    try {
      await _db.rpc('notify_student_of_leave_decision',
          params: {'p_leave_id': leaveId});
    } catch (e, st) {
      debugPrint('notify_student_of_leave_decision error: $e\n$st');
    }
  }

  Future<List<AdminSemester>> getSemesters() async {
    final data = await _db.from('semesters').select('id, name, academic_year, start_date, end_date, is_current, registration_open').order('start_date', ascending: false);
    if (data.isEmpty) return [];

    final semesterIds = data.map((s) => s['id'] as String).toList();
    final classesData = await _db.from('classes').select('semester_id').inFilter('semester_id', semesterIds);
    final Map<String, int> classCounts = {};
    for (final s in classesData) {
      final sid = s['semester_id'] as String?;
      if (sid != null) classCounts[sid] = (classCounts[sid] ?? 0) + 1;
    }

    return data.map((s) => AdminSemester(
      id: s['id'] as String,
      name: s['name'] as String,
      academicYear: s['academic_year'] as String,
      startDate: s['start_date'] as String,
      endDate: s['end_date'] as String,
      isCurrent: s['is_current'] as bool? ?? false,
      registrationOpen: (s['registration_open'] as bool?) ?? false,
      classCount: classCounts[s['id'] as String] ?? 0,
    )).toList();
  }

  Future<List<AdminAcademicYear>> getAcademicYears() async {
    final data = await _db.from('academic_years').select('id, name, start_date, end_date, is_current').order('start_date', ascending: false);
    return data.map((y) => AdminAcademicYear(
      id: y['id'] as String,
      name: y['name'] as String,
      startDate: y['start_date'] as String,
      endDate: y['end_date'] as String,
      isCurrent: y['is_current'] as bool? ?? false,
    )).toList();
  }

  Future<List<AdminFaculty>> getFaculties() async {
    final facs = await _db.from('faculties').select('id, name, code').order('name');
    if (facs.isEmpty) return [];

    final facIds = facs.map((f) => f['id'] as String).toList();

    // Count majors per faculty via departments
    final depts = await _db.from('departments').select('id, faculty_id').inFilter('faculty_id', facIds);
    final deptIds = depts.map((d) => d['id'] as String).toList();
    final Map<String, String> deptToFac = {for (final d in depts) d['id'] as String: d['faculty_id'] as String? ?? ''};

    final Map<String, int> majorCounts = {};
    if (deptIds.isNotEmpty) {
      final majors = await _db.from('majors').select('department_id').inFilter('department_id', deptIds);
      for (final m in majors) {
        final did = m['department_id'] as String?;
        if (did != null) {
          final fid = deptToFac[did] ?? '';
          if (fid.isNotEmpty) majorCounts[fid] = (majorCounts[fid] ?? 0) + 1;
        }
      }
    }

    return facs.map((f) {
      final fid = f['id'] as String;
      return AdminFaculty(id: fid, name: f['name'] as String, code: f['code'] as String, majorCount: majorCounts[fid] ?? 0);
    }).toList();
  }

  Future<List<AdminMajor>> getMajors() async {
    final data = await _db.from('majors').select('id, name, department_id').order('name');
    if (data.isEmpty) return [];

    final deptIds = data.map((m) => m['department_id'] as String?).whereType<String>().toSet().toList();
    final Map<String, Map<String, String>> deptInfo = {};
    if (deptIds.isNotEmpty) {
      final depts = await _db.from('departments').select('id, name, faculty_id').inFilter('id', deptIds);
      for (final d in depts) {
        deptInfo[d['id'] as String] = {
          'name': d['name'] as String,
          'faculty_id': d['faculty_id'] as String? ?? '',
        };
      }
    }

    final facIds = deptInfo.values.map((d) => d['faculty_id']!).where((id) => id.isNotEmpty).toSet().toList();
    final Map<String, String> facNames = {};
    if (facIds.isNotEmpty) {
      final facs = await _db.from('faculties').select('id, name').inFilter('id', facIds);
      for (final f in facs) facNames[f['id'] as String] = f['name'] as String;
    }

    return data.map((m) {
      final deptId = m['department_id'] as String?;
      final dept = deptId != null ? deptInfo[deptId] : null;
      final facId = dept != null && dept['faculty_id']!.isNotEmpty ? dept['faculty_id'] : null;
      return AdminMajor(
        id: m['id'] as String,
        name: m['name'] as String,
        departmentId: deptId,
        departmentName: dept?['name'],
        facultyId: facId,
        facultyName: facId != null ? facNames[facId] : null,
      );
    }).toList();
  }

  Future<List<AdminDepartment>> getDepartments() async {
    final depts = await _db.from('departments').select('id, faculty_id, name, code').order('name');
    if (depts.isEmpty) return [];

    final facIds = depts.map((d) => d['faculty_id'] as String?).whereType<String>().toSet().toList();
    final Map<String, String> facCodes = {};
    if (facIds.isNotEmpty) {
      final facs = await _db.from('faculties').select('id, code').inFilter('id', facIds);
      for (final f in facs) facCodes[f['id'] as String] = f['code'] as String;
    }

    final deptIds = depts.map((d) => d['id'] as String).toList();
    final students = await _db.from('students').select('department_id').inFilter('department_id', deptIds);
    final Map<String, int> studentCounts = {};
    for (final s in students) {
      final did = s['department_id'] as String?;
      if (did != null) studentCounts[did] = (studentCounts[did] ?? 0) + 1;
    }

    return depts.map((d) {
      final did = d['id'] as String;
      final fid = d['faculty_id'] as String?;
      return AdminDepartment(
        id: did,
        facultyId: fid,
        facultyCode: fid != null ? facCodes[fid] : null,
        name: d['name'] as String,
        code: d['code'] as String,
        studentCount: studentCounts[did] ?? 0,
      );
    }).toList();
  }

  Future<List<AdminInvoiceRecord>> getInvoices() async {
    final invoices = await _db.from('invoices')
        .select('id, student_id, semester_id, amount, due_date, status')
        .order('created_at', ascending: false);
    if (invoices.isEmpty) return [];

    final studentIds = invoices.map((i) => i['student_id'] as String).toSet().toList();
    final semIds = invoices.map((i) => i['semester_id'] as String?).whereType<String>().toSet().toList();

    final profiles = await _db.from('profiles').select('id, first_name, last_name').inFilter('id', studentIds);
    final Map<String, String> nameMap = {for (final p in profiles) p['id'] as String: _joinName(p)};

    final studentsData = await _db.from('students').select('id, student_code').inFilter('id', studentIds);
    final Map<String, String> codeMap = {for (final s in studentsData) s['id'] as String: s['student_code'] as String};

    final Map<String, String> semNames = {};
    if (semIds.isNotEmpty) {
      final sems = await _db.from('semesters').select('id, name').inFilter('id', semIds);
      for (final s in sems) semNames[s['id'] as String] = s['name'] as String;
    }

    return invoices.map((inv) {
      final sid = inv['student_id'] as String;
      return AdminInvoiceRecord(
        invoiceId: inv['id'] as String,
        studentId: sid,
        studentName: nameMap[sid] ?? 'Unknown',
        studentCode: codeMap[sid] ?? '—',
        semesterName: inv['semester_id'] != null ? semNames[inv['semester_id'] as String] : null,
        amount: (inv['amount'] as num).toDouble(),
        dueDate: inv['due_date'] as String,
        status: InvoiceStatus.values.byName(inv['status'] as String? ?? 'unpaid'),
      );
    }).toList();
  }

  Future<AdminStudentDetail?> getStudentDetail(String studentId) async {
    final s = await _db.from('students')
        .select('id, student_code, faculty_id, major_id, enrollment_year, year_level, status, date_of_birth, gender, nationality, address')
        .eq('id', studentId)
        .maybeSingle();
    if (s == null) return null;

    final p = await _db.from('profiles')
        .select('id, first_name, last_name, email, phone')
        .eq('id', studentId)
        .maybeSingle();

    String? facultyName;
    if (s['faculty_id'] != null) {
      final f = await _db.from('faculties').select('name').eq('id', s['faculty_id'] as String).maybeSingle();
      facultyName = f?['name'] as String?;
    }

    String? majorName;
    if (s['major_id'] != null) {
      final m = await _db.from('majors').select('name').eq('id', s['major_id'] as String).maybeSingle();
      majorName = m?['name'] as String?;
    }

    return AdminStudentDetail(
      id: s['id'] as String,
      studentCode: s['student_code'] as String,
      firstName: p?['first_name'] as String? ?? '',
      lastName: p?['last_name'] as String? ?? '',
      email: p?['email'] as String? ?? '',
      phone: p?['phone'] as String?,
      dateOfBirth: s['date_of_birth'] as String?,
      gender: s['gender'] as String?,
      nationality: s['nationality'] as String?,
      address: s['address'] as String?,
      statusName: s['status'] as String? ?? 'active',
      yearLevel: s['year_level'] as int? ?? 1,
      enrollmentYear: s['enrollment_year'] as int? ?? DateTime.now().year,
      facultyId: s['faculty_id'] as String?,
      facultyName: facultyName,
      majorId: s['major_id'] as String?,
      majorName: majorName,
    );
  }

  Future<AdminTeacherDetail?> getTeacherDetail(String teacherId) async {
    final t = await _db.from('teachers')
        .select('id, employee_code, faculty_id, position, status')
        .eq('id', teacherId)
        .maybeSingle();
    if (t == null) return null;

    final p = await _db.from('profiles')
        .select('id, first_name, last_name, email, phone')
        .eq('id', teacherId)
        .maybeSingle();

    final facultyId = t['faculty_id'] as String?;
    String? facultyName;
    if (facultyId != null) {
      final f = await _db.from('faculties').select('name').eq('id', facultyId).maybeSingle();
      facultyName = f?['name'] as String?;
    }

    final coursesData = await _db.from('courses')
        .select('id, code, name')
        .eq('teacher_id', teacherId)
        .eq('status', 'active');

    final courseIds = coursesData.map((c) => c['id'] as String).toList();
    int totalStudents = 0;
    if (courseIds.isNotEmpty) {
      final enrollData = await _db.from('enrollments')
          .select('id')
          .inFilter('course_id', courseIds)
          .neq('status', 'dropped');
      totalStudents = enrollData.length;
    }

    final assignedCourses = coursesData
        .map((c) => '${c['code']} ${c['name']}')
        .toList()
        .cast<String>();

    return AdminTeacherDetail(
      id: t['id'] as String,
      employeeCode: t['employee_code'] as String,
      firstName: p?['first_name'] as String? ?? '',
      lastName: p?['last_name'] as String? ?? '',
      email: p?['email'] as String? ?? '',
      phone: p?['phone'] as String?,
      position: t['position'] as String?,
      statusName: t['status'] as String? ?? 'active',
      facultyId: facultyId,
      facultyName: facultyName,
      assignedCourses: assignedCourses,
      totalStudents: totalStudents,
    );
  }

  Future<AdminCourseDetail?> getCourseDetail(String courseId) async {
    final c = await _db.from('courses')
        .select('id, code, name, description, credits, teacher_id, semester_id, major_id, department_id, max_students, status, schedule')
        .eq('id', courseId)
        .maybeSingle();
    if (c == null) return null;

    String? teacherName;
    if (c['teacher_id'] != null) {
      final p = await _db.from('profiles')
          .select('first_name, last_name')
          .eq('id', c['teacher_id'] as String)
          .maybeSingle();
      if (p != null) teacherName = _joinName(p);
    }

    String? semesterName;
    if (c['semester_id'] != null) {
      final s = await _db.from('semesters').select('name').eq('id', c['semester_id'] as String).maybeSingle();
      semesterName = s?['name'] as String?;
    }

    String? majorName;
    if (c['major_id'] != null) {
      final m = await _db.from('majors').select('name').eq('id', c['major_id'] as String).maybeSingle();
      majorName = m?['name'] as String?;
    }

    String? departmentName;
    String? facultyId;
    String? facultyName;
    if (c['department_id'] != null) {
      final d = await _db.from('departments')
          .select('name, faculty_id')
          .eq('id', c['department_id'] as String)
          .maybeSingle();
      departmentName = d?['name'] as String?;
      facultyId = d?['faculty_id'] as String?;
      if (facultyId != null) {
        final f = await _db.from('faculties').select('name').eq('id', facultyId).maybeSingle();
        facultyName = f?['name'] as String?;
      }
    }

    final enrollData = await _db.from('enrollments')
        .select('id')
        .eq('course_id', courseId)
        .neq('status', 'dropped');

    return AdminCourseDetail(
      id: c['id'] as String,
      code: c['code'] as String,
      name: c['name'] as String,
      description: c['description'] as String?,
      credits: c['credits'] as int? ?? 3,
      statusName: c['status'] as String? ?? 'active',
      teacherId: c['teacher_id'] as String?,
      teacherName: teacherName,
      semesterId: c['semester_id'] as String?,
      semesterName: semesterName,
      majorId: c['major_id'] as String?,
      majorName: majorName,
      departmentId: c['department_id'] as String?,
      departmentName: departmentName,
      facultyId: facultyId,
      facultyName: facultyName,
      maxStudents: c['max_students'] as int? ?? 40,
      enrolledCount: enrollData.length,
      schedule: ((c['schedule'] as List?) ?? []).map((s) => Map<String, dynamic>.from(s as Map)).toList(),
    );
  }

  Future<List<AdminEnrollmentRecord>> getEnrollmentData() async {
    final classesData = await _db.from('classes')
        .select('id, course_id, teacher_id, shift, class_code, semester_id, max_students, program_type, schedule_type, room')
        .eq('status', 'active')
        .order('shift')
        .order('class_code');
    if (classesData.isEmpty) return [];

    final classIds = classesData.map((s) => s['id'] as String).toList();
    final courseIds = classesData.map((s) => s['course_id'] as String).toSet().toList();
    final teacherIds = classesData.map((s) => s['teacher_id'] as String?).whereType<String>().toSet().toList();
    final semIds = classesData.map((s) => s['semester_id'] as String?).whereType<String>().toSet().toList();

    final Map<String, Map<String, String>> courseMap = {};
    final Set<String> deptIdsFromCourses = {};
    if (courseIds.isNotEmpty) {
      final courses = await _db.from('courses').select('id, code, name, department_id').inFilter('id', courseIds);
      for (final c in courses) {
        final deptId = c['department_id'] as String?;
        courseMap[c['id'] as String] = {
          'code': c['code'] as String,
          'name': c['name'] as String,
          if (deptId != null) 'department_id': deptId,
        };
        if (deptId != null) deptIdsFromCourses.add(deptId);
      }
    }

    // Resolve faculty id + name via department → faculty chain
    final Map<String, String> deptToFacultyId = {};
    final Map<String, String> deptToFacultyName = {};
    if (deptIdsFromCourses.isNotEmpty) {
      final depts = await _db.from('departments')
          .select('id, faculty_id')
          .inFilter('id', deptIdsFromCourses.toList());
      final facIds = depts.map((d) => d['faculty_id'] as String?).whereType<String>().toSet().toList();
      final Map<String, String> facMap = {};
      if (facIds.isNotEmpty) {
        final facs = await _db.from('faculties').select('id, name').inFilter('id', facIds);
        for (final f in facs) { facMap[f['id'] as String] = f['name'] as String; }
      }
      for (final d in depts) {
        final fid = d['faculty_id'] as String?;
        if (fid != null) {
          deptToFacultyId[d['id'] as String] = fid;
          if (facMap.containsKey(fid)) deptToFacultyName[d['id'] as String] = facMap[fid]!;
        }
      }
    }

    final Map<String, String> teacherNameMap = {};
    if (teacherIds.isNotEmpty) {
      final ps = await _db.from('profiles').select('id, first_name, last_name').inFilter('id', teacherIds);
      for (final p in ps) { teacherNameMap[p['id'] as String] = _joinName(p); }
    }

    final Map<String, String> semNameMap = {};
    if (semIds.isNotEmpty) {
      final sems = await _db.from('semesters').select('id, name').inFilter('id', semIds);
      for (final s in sems) { semNameMap[s['id'] as String] = s['name'] as String; }
    }

    final enrollData = await _db.from('enrollments')
        .select('class_id')
        .inFilter('class_id', classIds)
        .neq('status', 'dropped');
    final Map<String, int> enrollCounts = {};
    for (final e in enrollData) {
      final cid = e['class_id'] as String?;
      if (cid != null) enrollCounts[cid] = (enrollCounts[cid] ?? 0) + 1;
    }

    return classesData.map((s) {
      final classId = s['id'] as String;
      final courseId = s['course_id'] as String;
      final teacherId = s['teacher_id'] as String?;
      final semId = s['semester_id'] as String?;
      final course = courseMap[courseId];
      final deptId = course?['department_id'];
      return AdminEnrollmentRecord(
        classId: classId,
        courseId: courseId,
        semesterId: semId,
        courseCode: course?['code'] ?? '—',
        courseName: course?['name'] ?? 'Unknown',
        teacherId: teacherId,
        teacherName: teacherId != null ? teacherNameMap[teacherId] : null,
        programType: s['program_type'] as String? ?? 'national',
        scheduleType: s['schedule_type'] as String? ?? 'weekday',
        shift: s['shift'] as String? ?? 'morning',
        classCode: s['class_code'] as String,
        room: s['room'] as String?,
        semesterName: semId != null ? semNameMap[semId] : null,
        facultyId: deptId != null ? deptToFacultyId[deptId] : null,
        facultyName: deptId != null ? deptToFacultyName[deptId] : null,
        enrolled: enrollCounts[classId] ?? 0,
        maxStudents: s['max_students'] as int? ?? 30,
      );
    }).toList();
  }

  Future<List<CourseEnrollmentEntry>> getCourseEnrollments(String courseId) async {
    final data = await _db
        .from('enrollments')
        .select('id, student_id, status, enrolled_at')
        .eq('course_id', courseId)
        .neq('status', 'dropped')
        .order('enrolled_at');
    if (data.isEmpty) return [];

    final studentIds = data.map((e) => e['student_id'] as String).toList();
    final profiles = await _db
        .from('profiles')
        .select('id, first_name, last_name')
        .inFilter('id', studentIds);
    final studentsData = await _db
        .from('students')
        .select('id, student_code')
        .inFilter('id', studentIds);

    final nameMap = {for (final p in profiles) p['id'] as String: _joinName(p)};
    final codeMap = {for (final s in studentsData) s['id'] as String: s['student_code'] as String};

    return data.map((e) {
      final sid = e['student_id'] as String;
      final raw = e['enrolled_at'];
      return CourseEnrollmentEntry(
        enrollmentId: e['id'] as String,
        studentId: sid,
        studentCode: codeMap[sid] ?? '—',
        studentName: nameMap[sid] ?? 'Unknown',
        status: e['status'] as String? ?? 'enrolled',
        enrolledAt: raw != null ? DateTime.tryParse(raw.toString()) : null,
      );
    }).toList();
  }

  Future<List<CourseEnrollmentEntry>> getClassEnrollments(String classId) async {
    final data = await _db
        .from('enrollments')
        .select('id, student_id, status, enrolled_at')
        .eq('class_id', classId)
        .neq('status', 'dropped')
        .order('enrolled_at');
    if (data.isEmpty) return [];

    final studentIds = data.map((e) => e['student_id'] as String).toList();
    final profiles = await _db.from('profiles').select('id, first_name, last_name').inFilter('id', studentIds);
    final studentsData = await _db.from('students').select('id, student_code').inFilter('id', studentIds);

    final nameMap = {for (final p in profiles) p['id'] as String: _joinName(p)};
    final codeMap = {for (final s in studentsData) s['id'] as String: s['student_code'] as String};

    return data.map((e) {
      final sid = e['student_id'] as String;
      final raw = e['enrolled_at'];
      return CourseEnrollmentEntry(
        enrollmentId: e['id'] as String,
        studentId: sid,
        studentCode: codeMap[sid] ?? '—',
        studentName: nameMap[sid] ?? 'Unknown',
        status: e['status'] as String? ?? 'enrolled',
        enrolledAt: raw != null ? DateTime.tryParse(raw.toString()) : null,
      );
    }).toList();
  }

  Future<List<AdminClass>> getClasses(String courseId) async {
    final classes = await _db.from('classes')
        .select('id, semester_id, teacher_id, shift, class_code, room, max_students, status')
        .eq('course_id', courseId)
        .eq('status', 'active')
        .order('shift')
        .order('class_code');
    if (classes.isEmpty) return [];

    final courseData = await _db.from('courses').select('code, name').eq('id', courseId).maybeSingle();
    final courseCode = courseData?['code'] as String? ?? '';
    final courseName = courseData?['name'] as String? ?? '';

    final semIds = classes.map((s) => s['semester_id'] as String?).whereType<String>().toSet().toList();
    final Map<String, String> semNames = {};
    if (semIds.isNotEmpty) {
      final sems = await _db.from('semesters').select('id, name').inFilter('id', semIds);
      for (final s in sems) { semNames[s['id'] as String] = s['name'] as String; }
    }

    final teacherIds = classes.map((s) => s['teacher_id'] as String?).whereType<String>().toSet().toList();
    final Map<String, String> teacherNames = {};
    if (teacherIds.isNotEmpty) {
      final ps = await _db.from('profiles').select('id, first_name, last_name').inFilter('id', teacherIds);
      for (final p in ps) { teacherNames[p['id'] as String] = _joinName(p); }
    }

    final classIds = classes.map((s) => s['id'] as String).toList();
    final enrollData = await _db.from('enrollments')
        .select('class_id')
        .inFilter('class_id', classIds)
        .neq('status', 'dropped');
    final Map<String, int> enrollCounts = {};
    for (final e in enrollData) {
      final cid = e['class_id'] as String?;
      if (cid != null) enrollCounts[cid] = (enrollCounts[cid] ?? 0) + 1;
    }

    return classes.map((s) {
      final cid = s['id'] as String;
      final teacherId = s['teacher_id'] as String?;
      final semId = s['semester_id'] as String?;
      return AdminClass(
        id: cid,
        courseId: courseId,
        courseCode: courseCode,
        courseName: courseName,
        semesterId: semId,
        semesterName: semId != null ? semNames[semId] : null,
        teacherId: teacherId,
        teacherName: teacherId != null ? teacherNames[teacherId] : null,
        programType: s['program_type'] as String? ?? 'national',
        scheduleType: s['schedule_type'] as String? ?? 'weekday',
        shift: s['shift'] as String,
        classCode: s['class_code'] as String,
        room: s['room'] as String?,
        maxStudents: s['max_students'] as int? ?? 30,
        enrolledCount: enrollCounts[cid] ?? 0,
        status: s['status'] as String? ?? 'active',
      );
    }).toList();
  }

  Future<void> createClass({
    required String courseId,
    required String semesterId,
    String? teacherId,
    required String programType,
    required String scheduleType,
    required String shift,
    required String classCode,
    String? room,
    int maxStudents = 30,
  }) async {
    await _db.from('classes').insert({
      'course_id': courseId,
      'semester_id': semesterId,
      if (teacherId != null && teacherId.isNotEmpty) 'teacher_id': teacherId,
      'program_type': programType,
      'schedule_type': scheduleType,
      'shift': shift,
      'class_code': classCode.trim().toUpperCase(),
      if (room != null && room.trim().isNotEmpty) 'room': room.trim(),
      'max_students': maxStudents,
      'status': 'active',
    });
  }

  Future<void> updateClass({
    required String classId,
    required String semesterId,
    String? teacherId,
    required String programType,
    required String scheduleType,
    required String shift,
    required String classCode,
    String? room,
    required int maxStudents,
  }) async {
    await _db.from('classes').update({
      'semester_id': semesterId,
      'teacher_id': (teacherId != null && teacherId.isNotEmpty) ? teacherId : null,
      'program_type': programType,
      'schedule_type': scheduleType,
      'shift': shift,
      'class_code': classCode.trim().toUpperCase(),
      'room': (room != null && room.trim().isNotEmpty) ? room.trim() : null,
      'max_students': maxStudents,
    }).eq('id', classId);
  }

  Future<void> deleteClass(String classId) async {
    await _db.from('classes').update({'status': 'inactive'}).eq('id', classId);
  }

  Future<void> enrollStudent({
    required String studentId,
    required String classId,
  }) async {
    final cls = await _db.from('classes')
        .select('course_id, semester_id')
        .eq('id', classId)
        .single();
    await _db.from('enrollments').insert({
      'student_id': studentId,
      'class_id': classId,
      'course_id': cls['course_id'] as String,
      'semester_id': cls['semester_id'] as String,
      'status': 'enrolled',
    });
  }

  Future<void> dropEnrollment(String enrollmentId) async {
    await _db
        .from('enrollments')
        .update({'status': 'dropped'})
        .eq('id', enrollmentId);
  }

  Future<List<AdminAttendanceRecord>> getAttendanceRecords() async {
    final data = await _db
        .from('attendance')
        .select('id, student_id, course_id, date, status')
        .order('date', ascending: false)
        .limit(500);
    if (data.isEmpty) return [];

    final studentIds = data.map((a) => a['student_id'] as String).toSet().toList();
    final courseIds  = data.map((a) => a['course_id']  as String).toSet().toList();

    // ── student profiles ──────────────────────────────────────────────────────
    final profiles = await _db.from('profiles')
        .select('id, first_name, last_name')
        .inFilter('id', studentIds);
    final nameMap = <String, String>{
      for (final p in profiles) p['id'] as String: _joinName(p),
    };

    // ── students (code, year_level, major_id) ─────────────────────────────────
    final studentsData = await _db.from('students')
        .select('id, student_code, year_level, major_id')
        .inFilter('id', studentIds);
    final Map<String, Map<String, dynamic>> studentMap = {
      for (final s in studentsData) s['id'] as String: s,
    };

    // ── majors ────────────────────────────────────────────────────────────────
    final majorIds = studentsData
        .map((s) => s['major_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    final Map<String, Map<String, String>> majorMap = {};
    if (majorIds.isNotEmpty) {
      final majors = await _db.from('majors')
          .select('id, name, department_id')
          .inFilter('id', majorIds);
      for (final m in majors) {
        majorMap[m['id'] as String] = {
          'name':          m['name'] as String,
          'department_id': m['department_id'] as String? ?? '',
        };
      }
    }

    // ── courses (name, department_id, semester_id) ────────────────────────────
    final coursesData = await _db.from('courses')
        .select('id, name, department_id, semester_id')
        .inFilter('id', courseIds);
    final Map<String, Map<String, dynamic>> courseMap = {
      for (final c in coursesData) c['id'] as String: c,
    };

    // ── departments + faculties ───────────────────────────────────────────────
    final deptIds = coursesData
        .map((c) => c['department_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    final Map<String, Map<String, String>> deptMap = {};
    final Map<String, String> facultyNameMap = {};
    if (deptIds.isNotEmpty) {
      final depts = await _db.from('departments')
          .select('id, name, faculty_id')
          .inFilter('id', deptIds);
      for (final d in depts) {
        deptMap[d['id'] as String] = {
          'name':       d['name'] as String,
          'faculty_id': d['faculty_id'] as String? ?? '',
        };
      }
      final facIds = depts
          .map((d) => d['faculty_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      if (facIds.isNotEmpty) {
        final facs = await _db.from('faculties')
            .select('id, name')
            .inFilter('id', facIds);
        for (final f in facs) {
          facultyNameMap[f['id'] as String] = f['name'] as String;
        }
      }
    }

    // ── semesters ─────────────────────────────────────────────────────────────
    final semesterIds = coursesData
        .map((c) => c['semester_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    final Map<String, Map<String, String>> semMap = {};
    if (semesterIds.isNotEmpty) {
      final sems = await _db.from('semesters')
          .select('id, name, academic_year')
          .inFilter('id', semesterIds);
      for (final s in sems) {
        semMap[s['id'] as String] = {
          'name':          s['name'] as String,
          'academic_year': s['academic_year'] as String,
        };
      }
    }

    // ── assemble ──────────────────────────────────────────────────────────────
    return data.map((a) {
      final sid     = a['student_id'] as String;
      final cid     = a['course_id']  as String;
      final student = studentMap[sid];
      final course  = courseMap[cid];
      final majorId = student?['major_id'] as String?;
      final major   = majorId != null ? majorMap[majorId] : null;
      final deptId  = course?['department_id'] as String?;
      final dept    = deptId != null ? deptMap[deptId] : null;
      final facId   = dept?['faculty_id'];
      final semId   = course?['semester_id'] as String?;
      final sem     = semId != null ? semMap[semId] : null;

      return AdminAttendanceRecord(
        id:           a['id'] as String,
        studentId:    sid,
        studentName:  nameMap[sid] ?? 'Unknown',
        studentCode:  student?['student_code'] as String? ?? '—',
        yearLevel:    student?['year_level'] as int?,
        majorId:      majorId,
        majorName:    major?['name'],
        facultyId:    facId,
        facultyName:  facId != null ? facultyNameMap[facId] : null,
        courseId:     cid,
        courseName:   course?['name'] as String? ?? 'Unknown Course',
        semesterId:   semId,
        semesterName: sem?['name'],
        academicYear: sem?['academic_year'],
        date:         a['date'] as String,
        status:       a['status'] as String,
      );
    }).toList();
  }

  Future<void> updateAttendanceStatuses(List<String> ids, String status) async {
    if (ids.isEmpty) return;
    await _db.from('attendance').update({'status': status}).inFilter('id', ids);
  }

  Future<void> deleteAttendanceRecords(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.from('attendance').delete().inFilter('id', ids);
  }

  Future<void> createStudent({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String studentCode,
    String? phone,
    String? gender,
    String? facultyId,
    String? majorId,
    int yearLevel = 1,
    required int enrollmentYear,
  }) async {
    final resp = await _admin.auth.admin.createUser(AdminUserAttributes(
      email: email,
      password: password,
      userMetadata: {'first_name': firstName, 'last_name': lastName, 'role': 'student'},
      emailConfirm: true,
    ));
    final uid = resp.user!.id;
    if (phone != null && phone.isNotEmpty) {
      await _db.from('profiles').update({'phone': phone}).eq('id', uid);
    }
    await _db.from('students').insert({
      'id': uid,
      'student_code': studentCode,
      if (facultyId != null) 'faculty_id': facultyId,
      if (majorId != null) 'major_id': majorId,
      'year_level': yearLevel,
      'enrollment_year': enrollmentYear,
      if (gender != null && gender.isNotEmpty) 'gender': gender.toLowerCase(),
      'status': 'active',
    });
  }

  Future<void> createTeacher({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String employeeCode,
    String? phone,
    String? position,
    String? facultyId,
  }) async {
    final resp = await _admin.auth.admin.createUser(AdminUserAttributes(
      email: email,
      password: password,
      userMetadata: {'first_name': firstName, 'last_name': lastName, 'role': 'teacher'},
      emailConfirm: true,
    ));
    final uid = resp.user!.id;
    if (phone != null && phone.isNotEmpty) {
      await _db.from('profiles').update({'phone': phone}).eq('id', uid);
    }
    await _db.from('teachers').insert({
      'id': uid,
      'employee_code': employeeCode,
      if (facultyId != null && facultyId.isNotEmpty) 'faculty_id': facultyId,
      if (position != null && position.isNotEmpty) 'position': position,
      'status': 'active',
    });
  }

  Future<void> updateStudent({
    required String studentId,
    required String firstName,
    required String lastName,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? nationality,
    String? address,
    int? yearLevel,
    String? statusLabel,
    String? facultyId,
    String? majorId,
  }) async {
    await _db.from('profiles').update({
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone?.isEmpty == true ? null : phone,
    }).eq('id', studentId);
    final upd = <String, dynamic>{};
    if (gender != null) upd['gender'] = gender.toLowerCase();
    if (address != null) upd['address'] = address.isEmpty ? null : address;
    if (nationality != null) upd['nationality'] = nationality.isEmpty ? null : nationality;
    if (yearLevel != null) upd['year_level'] = yearLevel;
    if (statusLabel != null) upd['status'] = _studentStatusToDb(statusLabel);
    if (facultyId != null) upd['faculty_id'] = facultyId.isEmpty ? null : facultyId;
    if (majorId != null) upd['major_id'] = majorId.isEmpty ? null : majorId;
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
      final parsed = _parseDobToDb(dateOfBirth);
      if (parsed != null) upd['date_of_birth'] = parsed;
    }
    if (upd.isNotEmpty) await _db.from('students').update(upd).eq('id', studentId);
  }

  String? _parseDobToDb(String display) {
    final parts = display.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}';
    }
    final dashParts = display.split('-');
    if (dashParts.length == 3 && dashParts[0].length == 4) return display;
    return null;
  }

  Future<({String? departmentId, String? facultyId})> _resolveMajorHierarchy(String? majorId) async {
    if (majorId == null || majorId.isEmpty) return (departmentId: null, facultyId: null);
    final m = await _db.from('majors').select('department_id').eq('id', majorId).maybeSingle();
    final deptId = m?['department_id'] as String?;
    if (deptId == null) return (departmentId: null, facultyId: null);
    final d = await _db.from('departments').select('faculty_id').eq('id', deptId).maybeSingle();
    return (departmentId: deptId, facultyId: d?['faculty_id'] as String?);
  }

  Future<void> createCourse({
    required String code,
    required String name,
    String? description,
    required int credits,
    String? majorId,
  }) async {
    final hierarchy = await _resolveMajorHierarchy(majorId);
    await _db.from('courses').insert({
      'code': code.trim().toUpperCase(),
      'name': name.trim(),
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
      'credits': credits,
      if (majorId != null && majorId.isNotEmpty) 'major_id': majorId,
      if (hierarchy.departmentId != null) 'department_id': hierarchy.departmentId,
      if (hierarchy.facultyId != null) 'faculty_id': hierarchy.facultyId,
      'status': 'active',
    });
  }

  Future<void> updateCourse({
    required String courseId,
    required String code,
    required String name,
    String? description,
    required int credits,
    String? majorId,
  }) async {
    final hierarchy = await _resolveMajorHierarchy(majorId);
    await _db.from('courses').update({
      'code': code.trim().toUpperCase(),
      'name': name.trim(),
      'description': (description != null && description.trim().isNotEmpty)
          ? description.trim()
          : null,
      'credits': credits,
      'major_id': (majorId != null && majorId.isNotEmpty) ? majorId : null,
      'department_id': hierarchy.departmentId,
      'faculty_id': hierarchy.facultyId,
    }).eq('id', courseId);
  }

  Future<void> deleteCourse(String courseId) async {
    await _db.from('courses').update({'status': 'inactive'}).eq('id', courseId);
  }

  Future<void> createSemester({
    required String name,
    required String academicYear,
    required String startDate,
    required String endDate,
  }) async {
    await _db.from('semesters').insert({
      'name': name.trim(),
      'academic_year': academicYear.trim(),
      'start_date': startDate,
      'end_date': endDate,
      'is_current': false,
      'registration_open': false,
    });
  }

  Future<void> updateSemester({
    required String semesterId,
    required String name,
    required String academicYear,
    required String startDate,
    required String endDate,
  }) async {
    await _db.from('semesters').update({
      'name': name.trim(),
      'academic_year': academicYear.trim(),
      'start_date': startDate,
      'end_date': endDate,
    }).eq('id', semesterId);
  }

  Future<void> setCurrentSemester(String semesterId) async {
    await _db.from('semesters').update({'is_current': false}).neq('id', semesterId);
    final sem = await _db.from('semesters')
        .update({'is_current': true})
        .eq('id', semesterId)
        .select('academic_year')
        .maybeSingle();

    // Keep the academic year in sync so admins don't have to set both manually.
    final academicYear = sem?['academic_year'] as String?;
    if (academicYear != null) {
      final year = await _db.from('academic_years').select('id').eq('name', academicYear).maybeSingle();
      final yearId = year?['id'] as String?;
      if (yearId != null) {
        await _db.from('academic_years').update({'is_current': false}).neq('id', yearId);
        await _db.from('academic_years').update({'is_current': true}).eq('id', yearId);
      }
    }
  }

  Future<void> toggleSemesterRegistration(String semesterId, {required bool open}) async {
    await _db.from('semesters').update({'registration_open': open}).eq('id', semesterId);
  }

  Future<void> createAcademicYear({
    required String name,
    required String startDate,
    required String endDate,
  }) async {
    await _db.from('academic_years').insert({
      'name': name.trim(),
      'start_date': startDate,
      'end_date': endDate,
      'is_current': false,
    });
  }

  Future<void> updateAcademicYear({
    required String academicYearId,
    required String name,
    required String startDate,
    required String endDate,
  }) async {
    await _db.from('academic_years').update({
      'name': name.trim(),
      'start_date': startDate,
      'end_date': endDate,
    }).eq('id', academicYearId);
  }

  Future<void> setCurrentAcademicYear(String academicYearId) async {
    await _db.from('academic_years').update({'is_current': false}).neq('id', academicYearId);
    await _db.from('academic_years').update({'is_current': true}).eq('id', academicYearId);
  }

  Future<void> deleteAcademicYear(String academicYearId) async {
    await _db.from('academic_years').delete().eq('id', academicYearId);
  }

  Future<void> updateCourseSchedule({
    required String courseId,
    required List<Map<String, dynamic>> schedule,
  }) async {
    await _db.from('courses').update({'schedule': schedule}).eq('id', courseId);
  }

  Future<void> updateFaculty({
    required String facultyId,
    required String name,
    required String code,
  }) async {
    await _db.from('faculties').update({
      'name': name.trim(),
      'code': code.trim().toUpperCase(),
    }).eq('id', facultyId);
  }

  Future<void> updateMajor({
    required String majorId,
    required String name,
  }) async {
    await _db.from('majors').update({
      'name': name.trim(),
    }).eq('id', majorId);
  }

  Future<void> createFaculty({
    required String name,
    required String code,
  }) async {
    await _db.from('faculties').insert({
      'name': name.trim(),
      'code': code.trim().toUpperCase(),
    });
  }

  Future<void> createMajor({
    required String name,
    required String departmentId,
  }) async {
    await _db.from('majors').insert({
      'name': name.trim(),
      'department_id': departmentId,
    });
  }

  Future<void> deleteFaculty(String facultyId) async {
    await _db.from('faculties').delete().eq('id', facultyId);
  }

  Future<void> deleteMajor(String majorId) async {
    await _db.from('majors').delete().eq('id', majorId);
  }

  Future<void> updateTeacher({
    required String teacherId,
    required String firstName,
    required String lastName,
    String? phone,
    String? position,
    String? statusLabel,
    String? facultyId,
  }) async {
    await _db.from('profiles').update({
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone?.isEmpty == true ? null : phone,
    }).eq('id', teacherId);
    final upd = <String, dynamic>{};
    if (position != null) upd['position'] = position.isEmpty ? null : position;
    if (statusLabel != null) upd['status'] = statusLabel == 'Active' ? 'active' : 'inactive';
    if (facultyId != null) upd['faculty_id'] = facultyId.isEmpty ? null : facultyId;
    if (upd.isNotEmpty) await _db.from('teachers').update(upd).eq('id', teacherId);
  }

  Future<void> deleteUser(String userId) async {
    await _admin.auth.admin.deleteUser(userId);
  }

  Future<AdminAnalyticsData> getAnalyticsData() async {
    try {
      final enrollRows =
          await _db.from('enrollments').select('enrolled_at');
      final gradeRows =
          await _db.from('grades').select('letter_grade, gpa_points');
      final invoiceRows =
          await _db.from('invoices').select('amount, status, student_id');
      final studentRows =
          await _db.from('students').select('id, faculty_id');
      final facultyRows =
          await _db.from('faculties').select('id, name');
      final attendanceRows =
          await _db.from('attendance').select('student_id, status');

      // ── Monthly enrollments (last 12 months) ─────────────────────────
      final monthCounts = <String, int>{};
      for (final r in enrollRows) {
        final raw = r['enrolled_at'];
        if (raw == null) continue;
        try {
          final dt = raw is DateTime ? raw : DateTime.parse(raw.toString());
          final key =
              '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
          monthCounts[key] = (monthCounts[key] ?? 0) + 1;
        } catch (_) {}
      }
      final now = DateTime.now();
      final monthly = <({String month, int count})>[];
      for (var i = 11; i >= 0; i--) {
        final d = DateTime(now.year, now.month - i, 1);
        final key =
            '${d.year}-${d.month.toString().padLeft(2, '0')}';
        monthly.add((
          month: _monthAbbr(d.month),
          count: monthCounts[key] ?? 0,
        ));
      }

      // ── Grade distribution ────────────────────────────────────────────
      final gradeCounts = <String, int>{
        'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0
      };
      var totalGrades = 0;
      var gpaSum = 0.0;
      var gpaCount = 0;
      for (final r in gradeRows) {
        final g = (r['letter_grade'] as String?)
            ?.toUpperCase()
            .substring(0, 1);
        if (g != null && gradeCounts.containsKey(g)) {
          gradeCounts[g] = gradeCounts[g]! + 1;
          totalGrades++;
        }
        final gp = (r['gpa_points'] as num?)?.toDouble();
        if (gp != null) {
          gpaSum += gp;
          gpaCount++;
        }
      }
      final gradeDistribution = gradeCounts.entries
          .map((e) => (grade: e.key, count: e.value))
          .toList();
      final passCount = (gradeCounts['A'] ?? 0) +
          (gradeCounts['B'] ?? 0) +
          (gradeCounts['C'] ?? 0) +
          (gradeCounts['D'] ?? 0);
      final passRate =
          totalGrades > 0 ? passCount / totalGrades : 0.0;
      final avgGpa =
          gpaCount > 0 ? gpaSum / gpaCount : 0.0;

      // ── Faculty maps ──────────────────────────────────────────────────
      final studentFacMap = <String, String?>{};
      for (final r in studentRows) {
        studentFacMap[r['id'] as String] = r['faculty_id'] as String?;
      }
      final facultyNameMap = <String, String>{};
      for (final r in facultyRows) {
        facultyNameMap[r['id'] as String] = r['name'] as String;
      }

      // ── Faculty revenue ───────────────────────────────────────────────
      final facTotal = <String, double>{};
      final facCollected = <String, double>{};
      for (final inv in invoiceRows) {
        final sid = inv['student_id'] as String?;
        if (sid == null) continue;
        final facId = studentFacMap[sid];
        if (facId == null) continue;
        final amount = (inv['amount'] as num?)?.toDouble() ?? 0;
        final status = inv['status'] as String? ?? '';
        facTotal[facId] = (facTotal[facId] ?? 0) + amount;
        if (status == 'paid') {
          facCollected[facId] = (facCollected[facId] ?? 0) + amount;
        }
      }
      final facultyRevenue = facultyNameMap.entries
          .where((e) => facTotal.containsKey(e.key))
          .map((e) {
            final total = facTotal[e.key] ?? 0;
            final collected = facCollected[e.key] ?? 0;
            final pct =
                total > 0 ? (collected / total).clamp(0.0, 1.0) : 0.0;
            return (name: e.value, collectedPct: pct);
          })
          .toList()
        ..sort((a, b) => b.collectedPct.compareTo(a.collectedPct));

      // ── Attendance by faculty ─────────────────────────────────────────
      final facAttTotal = <String, int>{};
      final facAttPresent = <String, int>{};
      final studentAttTotal = <String, int>{};
      final studentAttPresent = <String, int>{};
      for (final att in attendanceRows) {
        final sid = att['student_id'] as String?;
        if (sid == null) continue;
        final facId = studentFacMap[sid];
        final status = att['status'] as String? ?? '';
        studentAttTotal[sid] = (studentAttTotal[sid] ?? 0) + 1;
        if (status == 'present' || status == 'late') {
          studentAttPresent[sid] = (studentAttPresent[sid] ?? 0) + 1;
        }
        if (facId != null) {
          facAttTotal[facId] = (facAttTotal[facId] ?? 0) + 1;
          if (status == 'present' || status == 'late') {
            facAttPresent[facId] = (facAttPresent[facId] ?? 0) + 1;
          }
        }
      }
      final facultyAttendance = facultyNameMap.entries
          .where((e) => facAttTotal.containsKey(e.key))
          .map((e) {
            final total = facAttTotal[e.key] ?? 0;
            final present = facAttPresent[e.key] ?? 0;
            final pct =
                total > 0 ? (present / total).clamp(0.0, 1.0) : 0.0;
            return (name: e.value, attendancePct: pct);
          })
          .toList()
        ..sort(
            (a, b) => b.attendancePct.compareTo(a.attendancePct));

      // ── At-risk count (<75% attendance, min 3 sessions) ──────────────
      var atRisk = 0;
      for (final sid in studentAttTotal.keys) {
        final total = studentAttTotal[sid] ?? 0;
        if (total < 3) continue;
        final present = studentAttPresent[sid] ?? 0;
        if (present / total < 0.75) atRisk++;
      }

      return AdminAnalyticsData(
        monthlyEnrollments: monthly,
        facultyRevenue: facultyRevenue,
        gradeDistribution: gradeDistribution,
        facultyAttendance: facultyAttendance,
        atRiskCount: atRisk,
        avgGpa: avgGpa,
        passRate: passRate,
      );
    } catch (e, st) {
      debugPrint('getAnalyticsData error: $e\n$st');
      rethrow;
    }
  }

  static String _monthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _studentStatusToDb(String label) {
    switch (label) {
      case 'Active':    return 'active';
      case 'Suspended': return 'suspended';
      default:          return 'inactive';
    }
  }
}
