import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/database.types.dart';

// ── DTOs ──────────────────────────────────────────────────────────────────────

class TeacherProfile {
  final String id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? departmentName;
  final String? position;
  final String? specialization;
  final String? hireDate;

  const TeacherProfile({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.departmentName,
    this.position,
    this.specialization,
    this.hireDate,
  });
}

class TeacherCourse {
  final String courseId;
  final String code;
  final String name;
  final int credits;
  final String? semesterName;
  final String? semesterAcademicYear;
  final bool isCurrentSemester;
  final int studentCount;
  final String scheduleDisplay;
  final String? room;
  final List<Map<String, dynamic>> schedule;
  final CourseStatus status;

  const TeacherCourse({
    required this.courseId,
    required this.code,
    required this.name,
    required this.credits,
    this.semesterName,
    this.semesterAcademicYear,
    this.isCurrentSemester = false,
    required this.studentCount,
    required this.scheduleDisplay,
    this.room,
    this.schedule = const [],
    this.status = CourseStatus.active,
  });

  bool hasTodayClass() {
    if (schedule.isEmpty) return false;
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = dayNames[DateTime.now().weekday - 1];
    return schedule.any((s) => (s['day'] as String?) == today);
  }

  Map<String, dynamic>? todaySlot() {
    if (schedule.isEmpty) return null;
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = dayNames[DateTime.now().weekday - 1];
    try {
      return schedule.firstWhere((s) => (s['day'] as String?) == today);
    } catch (_) {
      return null;
    }
  }
}

class CourseStudent {
  final String studentId;
  final String studentCode;
  final String fullName;

  const CourseStudent({
    required this.studentId,
    required this.studentCode,
    required this.fullName,
  });
}

class StudentLeaveDetail {
  final String id;
  final String studentId;
  final String studentName;
  final String studentCode;
  final String type;
  final String reason;
  final String startDate;
  final String endDate;
  final String? docUrl;
  final LeaveStatus status;
  final String? reviewNotes;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final double attendanceRate;
  final int totalAttendanceDays;

  const StudentLeaveDetail({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.type,
    required this.reason,
    required this.startDate,
    required this.endDate,
    this.docUrl,
    this.status = LeaveStatus.pending,
    this.reviewNotes,
    this.createdAt,
    this.reviewedAt,
    this.attendanceRate = 0,
    this.totalAttendanceDays = 0,
  });

  String get initials {
    final parts = studentName.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}

// ── Service ───────────────────────────────────────────────────────────────────

class TeacherService {
  SupabaseClient get _db => Supabase.instance.client;

  Future<TeacherProfile?> getTeacherProfile(String userId) async {
    try {
      final profile = await _db
          .from('profiles')
          .select('id, email, first_name, last_name, phone, avatar_url')
          .eq('id', userId)
          .maybeSingle();
      if (profile == null) return null;

      final teacher = await _db
          .from('teachers')
          .select(
              'employee_code, department_id, position, specialization, hire_date')
          .eq('id', userId)
          .maybeSingle();
      if (teacher == null) return null;

      String? departmentName;
      final deptId = teacher['department_id'] as String?;
      if (deptId != null) {
        final dept = await _db
            .from('departments')
            .select('name')
            .eq('id', deptId)
            .maybeSingle();
        departmentName = dept?['name'] as String?;
      }

      return TeacherProfile(
        id: userId,
        employeeCode: teacher['employee_code'] as String,
        fullName: '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim(),
        email: profile['email'] as String? ?? '',
        phone: profile['phone'] as String?,
        avatarUrl: profile['avatar_url'] as String?,
        departmentName: departmentName,
        position: teacher['position'] as String?,
        specialization: teacher['specialization'] as String?,
        hireDate: teacher['hire_date'] as String?,
      );
    } catch (e, st) {
      debugPrint('getTeacherProfile error: $e\n$st');
      rethrow;
    }
  }

  Future<List<TeacherCourse>> getTeacherCourses(String teacherId) async {
    try {
      final courses = await _db
          .from('courses')
          .select('id, code, name, credits, semester_id, schedule, status')
          .eq('teacher_id', teacherId);

      if (courses.isEmpty) return [];

      final semesterIds = courses
          .map((c) => c['semester_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      Map<String, Map<String, dynamic>> semesterMap = {};
      if (semesterIds.isNotEmpty) {
        final sems = await _db
            .from('semesters')
            .select('id, name, academic_year, is_current')
            .inFilter('id', semesterIds);
        semesterMap = {for (final s in sems) s['id'] as String: s};
      }

      final courseIds = courses.map((c) => c['id'] as String).toList();
      final enrollments = await _db
          .from('enrollments')
          .select('course_id')
          .inFilter('course_id', courseIds)
          .neq('status', 'dropped');

      final Map<String, int> countMap = {};
      for (final e in enrollments) {
        final cid = e['course_id'] as String;
        countMap[cid] = (countMap[cid] ?? 0) + 1;
      }

      return courses.map((c) {
        final courseId = c['id'] as String;
        final semId = c['semester_id'] as String?;
        final sem = semId != null ? semesterMap[semId] : null;
        final rawSchedule =
            (c['schedule'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return TeacherCourse(
          courseId: courseId,
          code: c['code'] as String,
          name: c['name'] as String,
          credits: c['credits'] as int? ?? 3,
          semesterName: sem?['name'] as String?,
          semesterAcademicYear: sem?['academic_year'] as String?,
          isCurrentSemester: sem?['is_current'] as bool? ?? false,
          studentCount: countMap[courseId] ?? 0,
          scheduleDisplay: _formatSchedule(rawSchedule),
          room: _extractRoom(rawSchedule),
          schedule: rawSchedule,
          status:
              CourseStatus.values.byName(c['status'] as String? ?? 'active'),
        );
      }).toList();
    } catch (e, st) {
      debugPrint('getTeacherCourses error: $e\n$st');
      rethrow;
    }
  }

  Future<TeacherCourse?> getCourseById(String courseId) async {
    try {
      final c = await _db
          .from('courses')
          .select('id, code, name, credits, semester_id, schedule, status')
          .eq('id', courseId)
          .maybeSingle();
      if (c == null) return null;

      String? semesterName;
      String? semesterAcademicYear;
      bool isCurrentSemester = false;
      final semId = c['semester_id'] as String?;
      if (semId != null) {
        final sem = await _db
            .from('semesters')
            .select('name, academic_year, is_current')
            .eq('id', semId)
            .maybeSingle();
        semesterName = sem?['name'] as String?;
        semesterAcademicYear = sem?['academic_year'] as String?;
        isCurrentSemester = sem?['is_current'] as bool? ?? false;
      }

      final enrollRows = await _db
          .from('enrollments')
          .select('id')
          .eq('course_id', courseId)
          .neq('status', 'dropped');

      final rawSchedule =
          (c['schedule'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      return TeacherCourse(
        courseId: courseId,
        code: c['code'] as String,
        name: c['name'] as String,
        credits: c['credits'] as int? ?? 3,
        semesterName: semesterName,
        semesterAcademicYear: semesterAcademicYear,
        isCurrentSemester: isCurrentSemester,
        studentCount: enrollRows.length,
        scheduleDisplay: _formatSchedule(rawSchedule),
        room: _extractRoom(rawSchedule),
        schedule: rawSchedule,
        status: CourseStatus.values.byName(c['status'] as String? ?? 'active'),
      );
    } catch (e, st) {
      debugPrint('getCourseById error: $e\n$st');
      rethrow;
    }
  }

  Future<List<CourseStudent>> getCourseStudents(String courseId) async {
    try {
      final enrollments = await _db
          .from('enrollments')
          .select('student_id')
          .eq('course_id', courseId)
          .neq('status', 'dropped');

      if (enrollments.isEmpty) return [];

      final studentIds =
          enrollments.map((e) => e['student_id'] as String).toList();

      final profiles = await _db
          .from('profiles')
          .select('id, first_name, last_name')
          .inFilter('id', studentIds);

      final students = await _db
          .from('students')
          .select('id, student_code')
          .inFilter('id', studentIds);

      final profileMap = {for (final p in profiles) p['id'] as String: p};
      final studentMap = {for (final s in students) s['id'] as String: s};

      return studentIds.map((id) {
        final profile = profileMap[id];
        final student = studentMap[id];
        if (profile == null || student == null) return null;
        return CourseStudent(
          studentId: id,
          studentCode: student['student_code'] as String,
          fullName: '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim(),
        );
      }).whereType<CourseStudent>().toList();
    } catch (e, st) {
      debugPrint('getCourseStudents error: $e\n$st');
      rethrow;
    }
  }

  Future<void> saveAttendance({
    required String teacherId,
    required String courseId,
    required String date,
    required Map<String, String> statuses,
  }) async {
    await _db
        .from('attendance')
        .delete()
        .eq('course_id', courseId)
        .eq('date', date);

    if (statuses.isEmpty) return;

    final rows = statuses.entries.map((entry) {
      final statusName = switch (entry.value) {
        'P' => 'present',
        'A' => 'absent',
        'L' => 'late',
        _ => 'excused',
      };
      return {
        'student_id': entry.key,
        'course_id': courseId,
        'date': date,
        'status': statusName,
        'marked_by': teacherId,
      };
    }).toList();

    await _db.from('attendance').insert(rows);
  }

  Future<List<StudentLeaveDetail>> getStudentLeaveRequests(
      String teacherId) async {
    try {
      final courses = await _db
          .from('courses')
          .select('id')
          .eq('teacher_id', teacherId);

      if (courses.isEmpty) return [];

      final courseIds = courses.map((c) => c['id'] as String).toList();

      final enrollments = await _db
          .from('enrollments')
          .select('student_id')
          .inFilter('course_id', courseIds);

      if (enrollments.isEmpty) return [];

      final studentIds = enrollments
          .map((e) => e['student_id'] as String)
          .toSet()
          .toList();

      final leaves = await _db
          .from('leave_requests')
          .select()
          .inFilter('requester_id', studentIds)
          .eq('requester_type', 'student')
          .order('created_at', ascending: false);

      if (leaves.isEmpty) return [];

      final requesterIds =
          leaves.map((l) => l['requester_id'] as String).toSet().toList();

      final profiles = await _db
          .from('profiles')
          .select('id, first_name, last_name')
          .inFilter('id', requesterIds);

      final students = await _db
          .from('students')
          .select('id, student_code')
          .inFilter('id', requesterIds);

      final profileMap = {
        for (final p in profiles)
          p['id'] as String: '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim()
      };
      final studentCodeMap = {
        for (final s in students)
          s['id'] as String: s['student_code'] as String
      };

      return leaves.map((l) {
        final requesterId = l['requester_id'] as String;
        return StudentLeaveDetail(
          id: l['id'] as String,
          studentId: requesterId,
          studentName: profileMap[requesterId] ?? 'Unknown',
          studentCode: studentCodeMap[requesterId] ?? '',
          type: l['type'] as String,
          reason: l['reason'] as String,
          startDate: l['start_date'] as String,
          endDate: l['end_date'] as String,
          docUrl: l['doc_url'] as String?,
          status: LeaveStatus.values
              .byName(l['status'] as String? ?? 'pending'),
          reviewNotes: l['review_notes'] as String?,
          createdAt: l['created_at'] == null
              ? null
              : DateTime.tryParse(l['created_at'] as String),
        );
      }).toList();
    } catch (e, st) {
      debugPrint('getStudentLeaveRequests error: $e\n$st');
      rethrow;
    }
  }

  Future<StudentLeaveDetail?> getLeaveRequestDetail(String requestId) async {
    try {
      final leave = await _db
          .from('leave_requests')
          .select()
          .eq('id', requestId)
          .maybeSingle();

      if (leave == null) return null;

      final requesterId = leave['requester_id'] as String;

      final profile = await _db
          .from('profiles')
          .select('id, first_name, last_name')
          .eq('id', requesterId)
          .maybeSingle();

      final student = await _db
          .from('students')
          .select('id, student_code')
          .eq('id', requesterId)
          .maybeSingle();

      final attRows = await _db
          .from('attendance')
          .select('status')
          .eq('student_id', requesterId);

      final totalAtt = attRows.length;
      final presentAtt =
          attRows.where((a) => a['status'] == 'present').length;
      final attendanceRate = totalAtt > 0 ? presentAtt / totalAtt : 0.0;

      return StudentLeaveDetail(
        id: leave['id'] as String,
        studentId: requesterId,
        studentName: profile != null ? '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim() : 'Unknown',
        studentCode: student?['student_code'] as String? ?? '',
        type: leave['type'] as String,
        reason: leave['reason'] as String,
        startDate: leave['start_date'] as String,
        endDate: leave['end_date'] as String,
        docUrl: leave['doc_url'] as String?,
        status: LeaveStatus.values
            .byName(leave['status'] as String? ?? 'pending'),
        reviewNotes: leave['review_notes'] as String?,
        createdAt: leave['created_at'] == null
            ? null
            : DateTime.tryParse(leave['created_at'] as String),
        reviewedAt: leave['reviewed_at'] == null
            ? null
            : DateTime.tryParse(leave['reviewed_at'] as String),
        attendanceRate: attendanceRate,
        totalAttendanceDays: totalAtt,
      );
    } catch (e, st) {
      debugPrint('getLeaveRequestDetail error: $e\n$st');
      rethrow;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatSchedule(List<Map<String, dynamic>> schedule) {
    if (schedule.isEmpty) return 'No schedule';
    final days = schedule
        .map((s) => s['day'] as String? ?? '')
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    final slot = schedule.first;
    final start = slot['start'] as String? ?? '';
    final end = slot['end'] as String? ?? '';
    final dayStr = days.join(', ');
    final timeStr =
        [start, end].where((s) => s.isNotEmpty).join(' – ');
    return [dayStr, timeStr].where((s) => s.isNotEmpty).join(' ');
  }

  String? _extractRoom(List<Map<String, dynamic>> schedule) {
    if (schedule.isEmpty) return null;
    return schedule.first['room'] as String?;
  }
}
