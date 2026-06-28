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
  final String? departmentName;
  final int courseCount;

  const AdminTeacher({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.statusName,
    this.departmentName,
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
  final String? departmentName;
  final String? semesterName;
  final int enrolledCount;
  final int maxStudents;
  final CourseStatus status;

  const AdminCourse({
    required this.courseId,
    required this.code,
    required this.name,
    required this.credits,
    this.teacherName,
    this.departmentName,
    this.semesterName,
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

  const AdminSemester({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
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
  final String? departmentId;
  final String? departmentName;
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
    this.departmentId,
    this.departmentName,
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
  final String? departmentId;
  final String? departmentName;
  final int maxStudents;
  final int enrolledCount;

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
    this.departmentId,
    this.departmentName,
    required this.maxStudents,
    required this.enrolledCount,
  });

  double get enrollmentPct => maxStudents > 0 ? enrolledCount / maxStudents : 0.0;
}

class AdminEnrollmentRecord {
  final String courseId;
  final String courseCode;
  final String courseName;
  final String? teacherName;
  final int enrolled;
  final int maxStudents;

  const AdminEnrollmentRecord({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    this.teacherName,
    required this.enrolled,
    required this.maxStudents,
  });

  double get pct => maxStudents > 0 ? enrolled / maxStudents : 0.0;
}

class AdminAttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String studentCode;
  final String courseId;
  final String courseName;
  final String date;
  final String status;

  const AdminAttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.courseId,
    required this.courseName,
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
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _joinName(Map<String, dynamic> profile) =>
    '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();

// ── Service ───────────────────────────────────────────────────────────────────

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
        .select('id, employee_code, department_id, status')
        .order('employee_code');
    if (data.isEmpty) return [];

    final ids = data.map((t) => t['id'] as String).toList();
    final profiles = await _db.from('profiles').select('id, first_name, last_name, email').inFilter('id', ids);

    final deptIds = data.map((t) => t['department_id'] as String?).whereType<String>().toSet().toList();
    final Map<String, String> deptNames = {};
    if (deptIds.isNotEmpty) {
      final depts = await _db.from('departments').select('id, name').inFilter('id', deptIds);
      for (final d in depts) deptNames[d['id'] as String] = d['name'] as String;
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
        departmentName: t['department_id'] != null ? deptNames[t['department_id'] as String] : null,
        courseCount: courseCounts[tid] ?? 0,
      ));
    }
    return result;
  }

  Future<List<AdminCourse>> getCourses({String? query}) async {
    final data = await _db.from('courses')
        .select('id, code, name, credits, teacher_id, semester_id, department_id, max_students, status')
        .order('code');
    if (data.isEmpty) return [];

    final courseIds = data.map((c) => c['id'] as String).toList();
    final teacherIds = data.map((c) => c['teacher_id'] as String?).whereType<String>().toSet().toList();
    final semIds = data.map((c) => c['semester_id'] as String?).whereType<String>().toSet().toList();
    final deptIds = data.map((c) => c['department_id'] as String?).whereType<String>().toSet().toList();

    final Map<String, String> teacherNames = {};
    if (teacherIds.isNotEmpty) {
      final ps = await _db.from('profiles').select('id, first_name, last_name').inFilter('id', teacherIds);
      for (final p in ps) { teacherNames[p['id'] as String] = _joinName(p); }
    }

    final Map<String, String> semNames = {};
    if (semIds.isNotEmpty) {
      final sems = await _db.from('semesters').select('id, name').inFilter('id', semIds);
      for (final s in sems) semNames[s['id'] as String] = s['name'] as String;
    }

    final Map<String, String> deptNames = {};
    if (deptIds.isNotEmpty) {
      final depts = await _db.from('departments').select('id, name').inFilter('id', deptIds);
      for (final d in depts) deptNames[d['id'] as String] = d['name'] as String;
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
      result.add(AdminCourse(
        courseId: cid,
        code: code,
        name: name,
        credits: c['credits'] as int? ?? 3,
        teacherName: c['teacher_id'] != null ? teacherNames[c['teacher_id'] as String] : null,
        departmentName: c['department_id'] != null ? deptNames[c['department_id'] as String] : null,
        semesterName: c['semester_id'] != null ? semNames[c['semester_id'] as String] : null,
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

  Future<void> approveLeaveRequest(String id, String adminId, {String? notes}) async {
    await _db.from('leave_requests').update({
      'status': 'approved',
      'reviewed_by': adminId,
      'reviewed_at': DateTime.now().toIso8601String(),
      if (notes != null && notes.isNotEmpty) 'review_notes': notes,
    }).eq('id', id);
  }

  Future<void> rejectLeaveRequest(String id, String adminId, {String? notes}) async {
    await _db.from('leave_requests').update({
      'status': 'rejected',
      'reviewed_by': adminId,
      'reviewed_at': DateTime.now().toIso8601String(),
      if (notes != null && notes.isNotEmpty) 'review_notes': notes,
    }).eq('id', id);
  }

  Future<List<AdminSemester>> getSemesters() async {
    final data = await _db.from('semesters').select('*').order('start_date', ascending: false);
    return data.map((s) => AdminSemester(
      id: s['id'] as String,
      name: s['name'] as String,
      academicYear: s['academic_year'] as String,
      startDate: s['start_date'] as String,
      endDate: s['end_date'] as String,
      isCurrent: s['is_current'] as bool? ?? false,
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
        .select('id, employee_code, department_id, position, status')
        .eq('id', teacherId)
        .maybeSingle();
    if (t == null) return null;

    final p = await _db.from('profiles')
        .select('id, first_name, last_name, email, phone')
        .eq('id', teacherId)
        .maybeSingle();

    String? departmentName;
    if (t['department_id'] != null) {
      final d = await _db.from('departments').select('name').eq('id', t['department_id'] as String).maybeSingle();
      departmentName = d?['name'] as String?;
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
      departmentId: t['department_id'] as String?,
      departmentName: departmentName,
      assignedCourses: assignedCourses,
      totalStudents: totalStudents,
    );
  }

  Future<AdminCourseDetail?> getCourseDetail(String courseId) async {
    final c = await _db.from('courses')
        .select('id, code, name, description, credits, teacher_id, semester_id, department_id, max_students, status')
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

    String? departmentName;
    if (c['department_id'] != null) {
      final d = await _db.from('departments').select('name').eq('id', c['department_id'] as String).maybeSingle();
      departmentName = d?['name'] as String?;
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
      departmentId: c['department_id'] as String?,
      departmentName: departmentName,
      maxStudents: c['max_students'] as int? ?? 40,
      enrolledCount: enrollData.length,
    );
  }

  Future<List<AdminEnrollmentRecord>> getEnrollmentData() async {
    final data = await _db.from('courses')
        .select('id, code, name, teacher_id, max_students')
        .eq('status', 'active')
        .order('code');
    if (data.isEmpty) return [];

    final courseIds = data.map((c) => c['id'] as String).toList();
    final teacherIds = data.map((c) => c['teacher_id'] as String?).whereType<String>().toSet().toList();

    final Map<String, String> teacherNames = {};
    if (teacherIds.isNotEmpty) {
      final ps = await _db.from('profiles').select('id, first_name, last_name').inFilter('id', teacherIds);
      for (final p in ps) { teacherNames[p['id'] as String] = _joinName(p); }
    }

    final enrollData = await _db.from('enrollments')
        .select('course_id')
        .inFilter('course_id', courseIds)
        .neq('status', 'dropped');
    final Map<String, int> enrollCounts = {};
    for (final e in enrollData) {
      final cid = e['course_id'] as String;
      enrollCounts[cid] = (enrollCounts[cid] ?? 0) + 1;
    }

    return data.map((c) {
      final tid = c['teacher_id'] as String?;
      return AdminEnrollmentRecord(
        courseId: c['id'] as String,
        courseCode: c['code'] as String,
        courseName: c['name'] as String,
        teacherName: tid != null ? teacherNames[tid] : null,
        enrolled: enrollCounts[c['id'] as String] ?? 0,
        maxStudents: c['max_students'] as int? ?? 40,
      );
    }).toList();
  }

  Future<List<AdminAttendanceRecord>> getAttendanceRecords({String? courseId}) async {
    var query = _db.from('attendance').select('id, student_id, course_id, date, status');
    final List<Map<String, dynamic>> data;
    if (courseId != null) {
      data = await query.eq('course_id', courseId).order('date', ascending: false).limit(50);
    } else {
      data = await query.order('date', ascending: false).limit(50);
    }
    if (data.isEmpty) return [];

    final studentIds = data.map((a) => a['student_id'] as String).toSet().toList();
    final courseIds = data.map((a) => a['course_id'] as String).toSet().toList();

    final profiles = await _db.from('profiles').select('id, first_name, last_name').inFilter('id', studentIds);
    final Map<String, String> nameMap = {for (final p in profiles) p['id'] as String: _joinName(p)};

    final studentsData = await _db.from('students').select('id, student_code').inFilter('id', studentIds);
    final Map<String, String> codeMap = {for (final s in studentsData) s['id'] as String: s['student_code'] as String};

    final coursesData = await _db.from('courses').select('id, name').inFilter('id', courseIds);
    final Map<String, String> courseNameMap = {for (final c in coursesData) c['id'] as String: c['name'] as String};

    return data.map((a) {
      final sid = a['student_id'] as String;
      final cid = a['course_id'] as String;
      return AdminAttendanceRecord(
        id: a['id'] as String,
        studentId: sid,
        studentName: nameMap[sid] ?? 'Unknown',
        studentCode: codeMap[sid] ?? '—',
        courseId: cid,
        courseName: courseNameMap[cid] ?? 'Unknown Course',
        date: a['date'] as String,
        status: a['status'] as String,
      );
    }).toList();
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
    String? departmentId,
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
      if (departmentId != null) 'department_id': departmentId,
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

  Future<void> updateTeacher({
    required String teacherId,
    required String firstName,
    required String lastName,
    String? phone,
    String? position,
    String? statusLabel,
    String? departmentId,
  }) async {
    await _db.from('profiles').update({
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone?.isEmpty == true ? null : phone,
    }).eq('id', teacherId);
    final upd = <String, dynamic>{};
    if (position != null) upd['position'] = position.isEmpty ? null : position;
    if (statusLabel != null) upd['status'] = statusLabel == 'Active' ? 'active' : 'inactive';
    if (departmentId != null) upd['department_id'] = departmentId.isEmpty ? null : departmentId;
    if (upd.isNotEmpty) await _db.from('teachers').update(upd).eq('id', teacherId);
  }

  Future<void> deleteUser(String userId) async {
    await _admin.auth.admin.deleteUser(userId);
  }

  String _studentStatusToDb(String label) {
    switch (label) {
      case 'Active':    return 'active';
      case 'Suspended': return 'suspended';
      default:          return 'inactive';
    }
  }
}
