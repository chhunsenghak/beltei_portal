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
  // Primary key for attendance/grades/roster lookups — one class_term_course
  // row is one specific teaching assignment (a course within one class term).
  final String classTermCourseId;
  final String courseId;
  final String? classId;
  final String? classCode;
  final String code;
  final String name;
  final int credits;
  final String? semesterId;
  final String? semesterName;
  final String? semesterAcademicYear;
  final String? semesterStartDate;
  final String? semesterEndDate;
  final bool isCurrentSemester;
  final int studentCount;
  final String scheduleDisplay;
  final String? room;
  final List<Map<String, dynamic>> schedule;
  final CourseStatus status;

  const TeacherCourse({
    required this.classTermCourseId,
    required this.courseId,
    this.classId,
    this.classCode,
    required this.code,
    required this.name,
    required this.credits,
    this.semesterId,
    this.semesterName,
    this.semesterAcademicYear,
    this.semesterStartDate,
    this.semesterEndDate,
    this.isCurrentSemester = false,
    required this.studentCount,
    required this.scheduleDisplay,
    this.room,
    this.schedule = const [],
    this.status = CourseStatus.active,
  });

  int? weekForDate(DateTime date) {
    if (semesterStartDate == null) return null;
    final start = DateTime.tryParse(semesterStartDate!);
    if (start == null) return null;
    final startOnly = DateTime(start.year, start.month, start.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diffDays = dateOnly.difference(startOnly).inDays;
    if (diffDays < 0) return 1;
    return (diffDays / 7).floor() + 1;
  }

  int get totalWeeks {
    if (semesterStartDate == null || semesterEndDate == null) return 15;
    final start = DateTime.tryParse(semesterStartDate!);
    final end = DateTime.tryParse(semesterEndDate!);
    if (start == null || end == null) return 15;
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);
    final diffDays = endOnly.difference(startOnly).inDays;
    return (diffDays / 7).ceil();
  }

  int get currentWeek {
    if (semesterStartDate == null) return 1;
    final start = DateTime.tryParse(semesterStartDate!);
    if (start == null) return 1;
    final now = DateTime.now();
    final startOnly = DateTime(start.year, start.month, start.day);
    final nowOnly = DateTime(now.year, now.month, now.day);
    final diffDays = nowOnly.difference(startOnly).inDays;
    if (diffDays < 0) return 1;
    final wk = (diffDays / 7).floor() + 1;
    final tot = totalWeeks;
    return wk > tot ? tot : wk;
  }

  List<DateTime> getSessionDatesForWeek(int weekNum) {
    if (semesterStartDate == null) return [];
    final start = DateTime.tryParse(semesterStartDate!);
    if (start == null) return [];

    final semesterStartMonday = start.subtract(Duration(days: start.weekday - 1));
    final weekMonday = semesterStartMonday.add(Duration(days: (weekNum - 1) * 7));

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sessionDates = <DateTime>[];

    final sortedSchedule = List<Map<String, dynamic>>.from(schedule)
      ..sort((a, b) {
        final dayA = a['day'] as String? ?? 'Mon';
        final dayB = b['day'] as String? ?? 'Mon';
        final idxA = dayNames.indexOf(dayA);
        final idxB = dayNames.indexOf(dayB);
        final dayCompare = idxA.compareTo(idxB);
        if (dayCompare != 0) return dayCompare;
        
        final startA = a['start'] as String? ?? '00:00';
        final startB = b['start'] as String? ?? '00:00';
        return startA.compareTo(startB);
      });

    for (final slot in sortedSchedule) {
      final day = slot['day'] as String? ?? 'Mon';
      final weekdayIndex = dayNames.indexOf(day);
      if (weekdayIndex >= 0) {
        final date = weekMonday.add(Duration(days: weekdayIndex));
        sessionDates.add(date);
      }
    }
    return sessionDates;
  }

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

class CourseGradeData {
  final String studentId;
  final double? midterm;
  final double? finalExam;
  final double? assignment;
  final double? participation;

  const CourseGradeData({
    required this.studentId,
    this.midterm,
    this.finalExam,
    this.assignment,
    this.participation,
  });

  CourseGradeData copyWith({
    double? midterm,
    double? finalExam,
    double? assignment,
    double? participation,
  }) =>
      CourseGradeData(
        studentId: studentId,
        midterm: midterm ?? this.midterm,
        finalExam: finalExam ?? this.finalExam,
        assignment: assignment ?? this.assignment,
        participation: participation ?? this.participation,
      );
}

// ── Course material DTO ────────────────────────────────────────────────────────

class CourseMaterialItem {
  final String id;
  final String title;
  final String? description;
  final String fileUrl;
  final String? fileType;
  final int? fileSize;
  final DateTime? uploadedAt;

  const CourseMaterialItem({
    required this.id,
    required this.title,
    this.description,
    required this.fileUrl,
    this.fileType,
    this.fileSize,
    this.uploadedAt,
  });

  factory CourseMaterialItem.fromMap(Map<String, dynamic> m) =>
      CourseMaterialItem(
        id: m['id'] as String,
        title: m['title'] as String,
        description: m['description'] as String?,
        fileUrl: m['file_url'] as String,
        fileType: m['file_type'] as String?,
        fileSize: m['file_size'] as int?,
        uploadedAt: m['uploaded_at'] == null
            ? null
            : DateTime.parse(m['uploaded_at'] as String),
      );

  String get sizeLabel {
    if (fileSize == null) return '';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}

// ── Attendance summary DTO ─────────────────────────────────────────────────────

class AttendanceSummaryData {
  final int totalSessions;
  final List<({String studentId, String fullName, int presentCount, int absentCount})> students;

  const AttendanceSummaryData({
    required this.totalSessions,
    required this.students,
  });

  int get totalPresent =>
      students.fold(0, (s, e) => s + e.presentCount);
  int get totalAbsent =>
      students.fold(0, (s, e) => s + e.absentCount);
  double get avgPresentRate {
    if (students.isEmpty || totalSessions == 0) return 0;
    final total = students.length * totalSessions;
    return total > 0 ? totalPresent / total : 0;
  }
}

// ── Course analytics DTO ───────────────────────────────────────────────────────

class CourseAnalyticsData {
  final List<({String grade, int count})> gradeDistribution;
  final List<({String name, double score})> ranking;
  final List<({String name, int attendancePct, String letterGrade})> atRiskStudents;
  final List<({String month, double avgPct})> monthlyAttendance;

  const CourseAnalyticsData({
    required this.gradeDistribution,
    required this.ranking,
    required this.atRiskStudents,
    required this.monthlyAttendance,
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
  final int? sessionNumber;

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
    this.sessionNumber,
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

  String get sessionLabel =>
      sessionNumber == null ? 'Full Day' : 'Session $sessionNumber';
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
      // Each class_term_course row is one teaching assignment: a course
      // taught to one class term, with its own schedule. Unlike the old
      // per-course grouping, a teacher teaching the same course to two
      // different class terms now sees two separate entries — each has its
      // own roster/attendance/grades, so they can't be merged.
      final ctc = await _db
          .from('class_term_courses')
          .select('id, course_id, class_term_id, schedule, status, '
              'courses(code, name, credits, status), '
              'class_terms(semester_id, class_id, classes(class_code))')
          .eq('teacher_id', teacherId)
          .eq('status', 'active');

      if (ctc.isEmpty) return [];

      final semesterIds = ctc
          .map((c) => (c['class_terms'] as Map<String, dynamic>?)?['semester_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      Map<String, Map<String, dynamic>> semesterMap = {};
      if (semesterIds.isNotEmpty) {
        final sems = await _db
            .from('semesters')
            .select('id, name, is_current, start_date, end_date, academic_years(name)')
            .inFilter('id', semesterIds);
        semesterMap = {for (final s in sems) s['id'] as String: s};
      }

      final classTermIds = ctc.map((c) => c['class_term_id'] as String).toList();
      final enrollments = await _db
          .from('enrollments')
          .select('class_term_id')
          .inFilter('class_term_id', classTermIds)
          .neq('status', 'dropped');

      final Map<String, int> countByTerm = {};
      for (final e in enrollments) {
        final tid = e['class_term_id'] as String?;
        if (tid != null) countByTerm[tid] = (countByTerm[tid] ?? 0) + 1;
      }

      return ctc.map((row) {
        final course = row['courses'] as Map<String, dynamic>?;
        if (course == null) return null;
        final term = row['class_terms'] as Map<String, dynamic>?;
        final cls = term?['classes'] as Map<String, dynamic>?;
        final semId = term?['semester_id'] as String?;
        final sem = semId != null ? semesterMap[semId] : null;
        final classTermId = row['class_term_id'] as String;
        final rawSchedule = ((row['schedule'] as List?) ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        return TeacherCourse(
          classTermCourseId: row['id'] as String,
          courseId: row['course_id'] as String,
          classId: term?['class_id'] as String?,
          classCode: cls?['class_code'] as String?,
          code: course['code'] as String,
          name: course['name'] as String,
          credits: course['credits'] as int? ?? 3,
          semesterId: semId,
          semesterName: sem?['name'] as String?,
          semesterAcademicYear: (sem?['academic_years'] as Map<String, dynamic>?)?['name'] as String?,
          semesterStartDate: sem?['start_date'] as String?,
          semesterEndDate: sem?['end_date'] as String?,
          isCurrentSemester: sem?['is_current'] as bool? ?? false,
          studentCount: countByTerm[classTermId] ?? 0,
          scheduleDisplay: _formatSchedule(rawSchedule),
          room: _extractRoom(rawSchedule),
          schedule: rawSchedule,
          status: CourseStatus.values
              .byName(course['status'] as String? ?? 'active'),
        );
      }).whereType<TeacherCourse>().toList();
    } catch (e, st) {
      debugPrint('getTeacherCourses error: $e\n$st');
      rethrow;
    }
  }

  /// Info for one teaching assignment (a course within one class term) —
  /// [classTermCourseId] is a `class_term_courses.id`, not a catalog course id.
  Future<TeacherCourse?> getCourseById(String classTermCourseId) async {
    try {
      final row = await _db
          .from('class_term_courses')
          .select('id, course_id, class_term_id, schedule, status, '
              'courses(code, name, credits, status), '
              'class_terms(semester_id, class_id, classes(class_code))')
          .eq('id', classTermCourseId)
          .maybeSingle();
      if (row == null) return null;

      final course = row['courses'] as Map<String, dynamic>?;
      if (course == null) return null;
      final term = row['class_terms'] as Map<String, dynamic>?;
      final cls = term?['classes'] as Map<String, dynamic>?;

      String? semesterName;
      String? semesterAcademicYear;
      String? semesterStartDate;
      String? semesterEndDate;
      bool isCurrentSemester = false;
      final semId = term?['semester_id'] as String?;
      if (semId != null) {
        final sem = await _db
            .from('semesters')
            .select('name, is_current, start_date, end_date, academic_years(name)')
            .eq('id', semId)
            .maybeSingle();
        semesterName = sem?['name'] as String?;
        semesterAcademicYear = (sem?['academic_years'] as Map<String, dynamic>?)?['name'] as String?;
        semesterStartDate = sem?['start_date'] as String?;
        semesterEndDate = sem?['end_date'] as String?;
        isCurrentSemester = sem?['is_current'] as bool? ?? false;
      }

      final classTermId = row['class_term_id'] as String;
      final enrollRows = await _db
          .from('enrollments')
          .select('id')
          .eq('class_term_id', classTermId)
          .neq('status', 'dropped');

      final rawSchedule = ((row['schedule'] as List?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return TeacherCourse(
        classTermCourseId: row['id'] as String,
        courseId: row['course_id'] as String,
        classId: term?['class_id'] as String?,
        classCode: cls?['class_code'] as String?,
        code: course['code'] as String,
        name: course['name'] as String,
        credits: course['credits'] as int? ?? 3,
        semesterId: semId,
        semesterName: semesterName,
        semesterAcademicYear: semesterAcademicYear,
        semesterStartDate: semesterStartDate,
        semesterEndDate: semesterEndDate,
        isCurrentSemester: isCurrentSemester,
        studentCount: enrollRows.length,
        scheduleDisplay: _formatSchedule(rawSchedule),
        room: _extractRoom(rawSchedule),
        schedule: rawSchedule,
        status: CourseStatus.values.byName(course['status'] as String? ?? 'active'),
      );
    } catch (e, st) {
      debugPrint('getCourseById error: $e\n$st');
      rethrow;
    }
  }

  /// Roster for one teaching assignment — since the curriculum is fixed,
  /// this is every student enrolled in [classTermCourseId]'s class term.
  Future<List<CourseStudent>> getCourseStudents(String classTermCourseId) async {
    try {
      final ctc = await _db
          .from('class_term_courses')
          .select('class_term_id')
          .eq('id', classTermCourseId)
          .maybeSingle();
      if (ctc == null) return [];

      final enrollments = await _db
          .from('enrollments')
          .select('student_id')
          .eq('class_term_id', ctc['class_term_id'] as String)
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
    required String classTermCourseId,
    required String date,
    required int sessionNumber,
    required Map<String, String> statuses,
  }) async {
    if (statuses.isEmpty) return;

    final ctc = await _db
        .from('class_term_courses')
        .select('course_id, class_terms(semester_id)')
        .eq('id', classTermCourseId)
        .single();
    final courseId = ctc['course_id'] as String;
    final semesterId = (ctc['class_terms'] as Map<String, dynamic>?)?['semester_id'] as String?;

    final rows = statuses.entries.map((entry) {
      final statusName = switch (entry.value) {
        'P' => 'present',
        'A' => 'absent',
        'L' => 'late',
        _ => 'excused',
      };
      return {
        'student_id': entry.key,
        'class_term_course_id': classTermCourseId,
        'course_id': courseId,
        if (semesterId != null) 'semester_id': semesterId,
        'date': date,
        'session_number': sessionNumber,
        'status': statusName,
        'marked_by': teacherId,
      };
    }).toList();

    await _db
        .from('attendance')
        .upsert(rows, onConflict: 'student_id,class_term_course_id,date,session_number');
  }
  Future<List<StudentLeaveDetail>> getStudentLeaveRequests(
      String teacherId) async {
    try {
      final ctc = await _db
          .from('class_term_courses')
          .select('class_term_id')
          .eq('teacher_id', teacherId)
          .eq('status', 'active');

      if (ctc.isEmpty) return [];

      final classTermIds = ctc.map((c) => c['class_term_id'] as String).toSet().toList();

      final enrollments = await _db
          .from('enrollments')
          .select('student_id')
          .inFilter('class_term_id', classTermIds)
          .neq('status', 'dropped');

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
          sessionNumber: l['session_number'] as int?,
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
        sessionNumber: leave['session_number'] as int?,
      );
    } catch (e, st) {
      debugPrint('getLeaveRequestDetail error: $e\n$st');
      rethrow;
    }
  }

  Future<List<CourseGradeData>> getCourseGrades(String classTermCourseId) async {
    try {
      final rows = await _db
          .from('grades')
          .select('student_id, midterm, final_exam, assignment, participation')
          .eq('class_term_course_id', classTermCourseId);
      return rows
          .map((r) => CourseGradeData(
                studentId: r['student_id'] as String,
                midterm: (r['midterm'] as num?)?.toDouble(),
                finalExam: (r['final_exam'] as num?)?.toDouble(),
                assignment: (r['assignment'] as num?)?.toDouble(),
                participation: (r['participation'] as num?)?.toDouble(),
              ))
          .toList();
    } catch (e, st) {
      debugPrint('getCourseGrades error: $e\n$st');
      rethrow;
    }
  }

  Future<void> saveGrades({
    required String classTermCourseId,
    required List<CourseGradeData> grades,
  }) async {
    if (grades.isEmpty) return;
    try {
      final ctc = await _db
          .from('class_term_courses')
          .select('course_id, class_terms(semester_id)')
          .eq('id', classTermCourseId)
          .single();
      final courseId = ctc['course_id'] as String;
      final semesterId = (ctc['class_terms'] as Map<String, dynamic>?)?['semester_id'] as String?;

      final records = grades.map((g) {
        final m = <String, dynamic>{
          'class_term_course_id': classTermCourseId,
          'course_id': courseId,
          if (semesterId != null) 'semester_id': semesterId,
          'student_id': g.studentId,
        };
        if (g.midterm != null) m['midterm'] = g.midterm;
        if (g.finalExam != null) m['final_exam'] = g.finalExam;
        if (g.assignment != null) m['assignment'] = g.assignment;
        if (g.participation != null) m['participation'] = g.participation;
        return m;
      }).toList();
      await _db.from('grades').upsert(
            records,
            onConflict: 'student_id, class_term_course_id',
          );
    } catch (e, st) {
      debugPrint('saveGrades error: $e\n$st');
      rethrow;
    }
  }

  // ── Attendance for a specific date ────────────────────────────────────────

  Future<Map<String, String>> getAttendanceForDate(
      String classTermCourseId, String date) async {
    try {
      final rows = await _db
          .from('attendance')
          .select('student_id, status')
          .eq('class_term_course_id', classTermCourseId)
          .eq('date', date);
      return {
        for (final r in rows)
          r['student_id'] as String: r['status'] as String
      };
    } catch (e, st) {
      debugPrint('getAttendanceForDate error: $e\n$st');
      rethrow;
    }
  }

  Future<Map<String, String>> getAllAttendance(String classTermCourseId) async {
    try {
      final rows = await _db
          .from('attendance')
          .select('student_id, date, status, session_number')
          .eq('class_term_course_id', classTermCourseId);
      return {
        for (final r in rows)
          '${r['student_id']}_${r['date']}_${r['session_number']}': r['status'] as String
      };
    } catch (e, st) {
      debugPrint('getAllAttendance error: $e\n$st');
      rethrow;
    }
  }

  // ── Create announcement ────────────────────────────────────────────────────

  Future<void> createAnnouncement({
    required String teacherId,
    String? courseId,
    required String title,
    required String body,
    bool isPinned = false,
  }) async {
    try {
      await _db.from('announcements').insert({
        'teacher_id': teacherId,
        if (courseId != null) 'course_id': courseId,
        'title': title,
        'body': body,
        'is_pinned': isPinned,
      });

      // Dynamically propagate announcement as a student notification
      final studentRows = await _db.from('students').select('id');
      final studentIds = studentRows.map((s) => s['id'] as String).toList();

      if (studentIds.isNotEmpty) {
        final notifications = studentIds.map((sid) => {
          'user_id': sid,
          'title': title,
          'body': body,
          'type': 'announcement',
          'is_read': false,
        }).toList();
        await _db.from('notifications').insert(notifications);
      }
    } catch (e, st) {
      debugPrint('createAnnouncement error: $e\n$st');
      rethrow;
    }
  }

  // ── Course materials ───────────────────────────────────────────────────────

  Future<List<CourseMaterialItem>> getCourseMaterials(String courseId) async {
    try {
      final rows = await _db
          .from('course_materials')
          .select('id, title, description, file_url, file_type, file_size, uploaded_at')
          .eq('course_id', courseId)
          .order('uploaded_at', ascending: false);
      return rows.map((r) => CourseMaterialItem.fromMap(r)).toList();
    } catch (e, st) {
      debugPrint('getCourseMaterials error: $e\n$st');
      rethrow;
    }
  }

  // ── Attendance summary ─────────────────────────────────────────────────────

  Future<AttendanceSummaryData> getAttendanceSummary(String classTermCourseId) async {
    try {
      final rows = await _db
          .from('attendance')
          .select('student_id, date, status')
          .eq('class_term_course_id', classTermCourseId);

      final studentIds = rows.map((r) => r['student_id'] as String).toSet().toList();
      Map<String, String> nameMap = {};
      if (studentIds.isNotEmpty) {
        final profiles = await _db
            .from('profiles')
            .select('id, first_name, last_name')
            .inFilter('id', studentIds);
        nameMap = {
          for (final p in profiles)
            p['id'] as String: '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim()
        };
      }

      final dates = <String>{};
      final byStudent = <String, ({String name, int present, int absent})>{};

      for (final row in rows) {
        final studentId = row['student_id'] as String;
        final status = row['status'] as String;
        final date = row['date'] as String;
        final name = nameMap[studentId] ?? 'Unknown';
        dates.add(date);
        final prev = byStudent[studentId] ?? (name: name, present: 0, absent: 0);
        final isPresent = status == 'present' || status == 'late';
        byStudent[studentId] = (
          name: name,
          present: prev.present + (isPresent ? 1 : 0),
          absent: prev.absent + (status == 'absent' ? 1 : 0),
        );
      }

      final students = byStudent.entries
          .map((e) => (
                studentId: e.key,
                fullName: e.value.name,
                presentCount: e.value.present,
                absentCount: e.value.absent,
              ))
          .toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName));

      return AttendanceSummaryData(
          totalSessions: dates.length, students: students);
    } catch (e, st) {
      debugPrint('getAttendanceSummary error: $e\n$st');
      rethrow;
    }
  }

  // ── Course analytics ───────────────────────────────────────────────────────

  Future<CourseAnalyticsData> getCourseAnalytics(String classTermCourseId) async {
    try {
      final gradeRows = await _db
          .from('grades')
          .select('student_id, total, letter_grade')
          .eq('class_term_course_id', classTermCourseId);

      final studentIds = gradeRows.map((g) => g['student_id'] as String).toSet().toList();
      Map<String, String> nameMap = {};
      if (studentIds.isNotEmpty) {
        final profiles = await _db
            .from('profiles')
            .select('id, first_name, last_name')
            .inFilter('id', studentIds);
        nameMap = {
          for (final p in profiles)
            p['id'] as String: '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim()
        };
      }

      final attendRows = await _db
          .from('attendance')
          .select('student_id, date, status')
          .eq('class_term_course_id', classTermCourseId);

      // Grade distribution
      final gradeCounts = <String, int>{};
      for (final g in gradeRows) {
        final grade = g['letter_grade'] as String? ?? '—';
        gradeCounts[grade] = (gradeCounts[grade] ?? 0) + 1;
      }
      const gradeOrder = ['A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'D', 'F'];
      final gradeDistribution = gradeCounts.entries
          .map((e) => (grade: e.key, count: e.value))
          .toList()
        ..sort((a, b) {
          final ai = gradeOrder.indexOf(a.grade);
          final bi = gradeOrder.indexOf(b.grade);
          return (ai < 0 ? 99 : ai).compareTo(bi < 0 ? 99 : bi);
        });

      // Ranking
      final ranking = gradeRows
          .where((g) => g['total'] != null)
          .map((g) => (
                name: nameMap[g['student_id'] as String] ?? '—',
                score: (g['total'] as num).toDouble(),
              ))
          .toList()
        ..sort((a, b) => b.score.compareTo(a.score));

      // Attendance per student
      final attendByStudent = <String, ({int total, int present})>{};
      final byMonth = <String, ({int total, int present})>{};
      for (final a in attendRows) {
        final studentId = a['student_id'] as String;
        final status = a['status'] as String;
        final date = a['date'] as String;
        final monthKey = date.length >= 7 ? date.substring(0, 7) : '';
        final isPresent = status == 'present' || status == 'late';

        final prev = attendByStudent[studentId] ?? (total: 0, present: 0);
        attendByStudent[studentId] = (
          total: prev.total + 1,
          present: prev.present + (isPresent ? 1 : 0),
        );

        if (monthKey.isNotEmpty) {
          final pm = byMonth[monthKey] ?? (total: 0, present: 0);
          byMonth[monthKey] = (
            total: pm.total + 1,
            present: pm.present + (isPresent ? 1 : 0),
          );
        }
      }

      // At-risk students (attendance < 75%)
      final atRisk = <({String name, int attendancePct, String letterGrade})>[];
      for (final g in gradeRows) {
        final studentId = g['student_id'] as String;
        final name = (g['profiles'] as Map?)?['full_name'] as String? ?? '—';
        final letterGrade = g['letter_grade'] as String? ?? '—';
        final ad = attendByStudent[studentId];
        if (ad != null && ad.total >= 3) {
          final pct = (ad.present / ad.total * 100).round();
          if (pct < 75) {
            atRisk.add((name: name, attendancePct: pct, letterGrade: letterGrade));
          }
        }
      }
      atRisk.sort((a, b) => a.attendancePct.compareTo(b.attendancePct));

      // Monthly attendance trend
      final sortedKeys = byMonth.keys.toList()..sort();
      final monthlyAttendance = sortedKeys.map((key) {
        final monthNum = int.tryParse(key.length >= 7 ? key.substring(5, 7) : '0') ?? 0;
        final d = byMonth[key]!;
        return (
          month: _monthAbbr(monthNum),
          avgPct: d.total > 0 ? d.present / d.total : 0.0,
        );
      }).toList();

      return CourseAnalyticsData(
        gradeDistribution: gradeDistribution,
        ranking: ranking.take(10).toList(),
        atRiskStudents: atRisk,
        monthlyAttendance: monthlyAttendance,
      );
    } catch (e, st) {
      debugPrint('getCourseAnalytics error: $e\n$st');
      rethrow;
    }
  }

  static String _monthAbbr(int month) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return month >= 1 && month <= 12 ? names[month] : '?';
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

  Future<List<NotificationRow>> getNotifications(String userId) async {
    try {
      final data = await _db
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      return data.map(NotificationRow.fromMap).toList();
    } catch (e, st) {
      debugPrint('getNotifications error: $e\n$st');
      rethrow;
    }
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _db
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }
}
