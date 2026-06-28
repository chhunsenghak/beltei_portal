import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/database.types.dart';

// ── DTOs ──────────────────────────────────────────────────────────────────────

class StudentProfile {
  final String id;
  final String studentCode;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? facultyName;
  final String? majorName;
  final int yearLevel;
  final int enrollmentYear;
  final StudentStatus status;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? nationality;
  final String? emergencyContact;

  const StudentProfile({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.facultyName,
    this.majorName,
    required this.yearLevel,
    required this.enrollmentYear,
    required this.status,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.nationality,
    this.emergencyContact,
  });
}

class EnrolledCourse {
  final String courseId;
  final String enrollmentId;
  final String code;
  final String name;
  final int credits;
  final String? teacherName;
  final String? semesterName;
  final String? semesterAcademicYear;
  final bool isCurrentSemester;
  final EnrollmentStatus enrollmentStatus;
  final double? attendanceRate;

  const EnrolledCourse({
    required this.courseId,
    required this.enrollmentId,
    required this.code,
    required this.name,
    required this.credits,
    this.teacherName,
    this.semesterName,
    this.semesterAcademicYear,
    this.isCurrentSemester = false,
    required this.enrollmentStatus,
    this.attendanceRate,
  });
}

class CourseGrade {
  final String courseId;
  final String courseName;
  final String courseCode;
  final int credits;
  final double? midterm;
  final double? finalExam;
  final double? assignment;
  final double? total;
  final String? letterGrade;
  final double? gpaPoints;

  const CourseGrade({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.credits,
    this.midterm,
    this.finalExam,
    this.assignment,
    this.total,
    this.letterGrade,
    this.gpaPoints,
  });
}

class SemesterGrades {
  final String semesterId;
  final String semesterName;
  final String academicYear;
  final String startDate;
  final bool isCurrent;
  final List<CourseGrade> courses;

  const SemesterGrades({
    required this.semesterId,
    required this.semesterName,
    required this.academicYear,
    required this.startDate,
    required this.isCurrent,
    required this.courses,
  });

  double get semesterGpa {
    final graded = courses.where((c) => c.gpaPoints != null && c.credits > 0).toList();
    if (graded.isEmpty) return 0;
    final totalPoints = graded.fold(0.0, (sum, c) => sum + c.gpaPoints! * c.credits);
    final totalCredits = graded.fold(0, (sum, c) => sum + c.credits);
    return totalCredits > 0 ? totalPoints / totalCredits : 0;
  }

  int get totalCredits => courses.fold(0, (sum, c) => sum + c.credits);
}

class AttendanceRecord {
  final String date;
  final String courseName;
  final String courseCode;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.date,
    required this.courseName,
    required this.courseCode,
    required this.status,
  });
}

class CourseAttendance {
  final String courseName;
  final int total;
  final int present;
  final int absent;
  final int late;
  final int excused;

  const CourseAttendance({
    required this.courseName,
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
  });

  double get rate => total > 0 ? present / total : 0;
}

class AttendanceSummary {
  final int totalDays;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final List<CourseAttendance> courseBreakdown;
  final List<AttendanceRecord> recentRecords;

  const AttendanceSummary({
    required this.totalDays,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.courseBreakdown,
    required this.recentRecords,
  });

  double get overallRate => totalDays > 0 ? present / totalDays : 0;
}

class FinanceSummary {
  final double totalFees;
  final double totalPaid;
  final double outstanding;
  final String? nextDueDate;
  final String? nextDueName;
  final String status;
  final List<InvoiceRow> invoices;

  const FinanceSummary({
    required this.totalFees,
    required this.totalPaid,
    required this.outstanding,
    this.nextDueDate,
    this.nextDueName,
    required this.status,
    required this.invoices,
  });

  double get paidPercent => totalFees > 0 ? totalPaid / totalFees : 0;
}

// ── Service ───────────────────────────────────────────────────────────────────

class StudentService {
  SupabaseClient get _db => Supabase.instance.client;

  Future<StudentProfile?> getStudentProfile(String userId) async {
    try {
      final profile = await _db
          .from('profiles')
          .select('id, email, first_name, last_name, phone, avatar_url')
          .eq('id', userId)
          .maybeSingle();
      if (profile == null) return null;

      final student = await _db
          .from('students')
          .select(
              'student_code, year_level, enrollment_year, status, '
              'date_of_birth, gender, nationality, address, emergency_contact, '
              'faculty_id, major_id')
          .eq('id', userId)
          .maybeSingle();
      if (student == null) return null;

      String? facultyName;
      String? majorName;

      final facultyId = student['faculty_id'] as String?;
      final majorId = student['major_id'] as String?;

      if (facultyId != null) {
        final fac = await _db
            .from('faculties')
            .select('name')
            .eq('id', facultyId)
            .maybeSingle();
        facultyName = fac?['name'] as String?;
      }
      if (majorId != null) {
        final major = await _db
            .from('majors')
            .select('name')
            .eq('id', majorId)
            .maybeSingle();
        majorName = major?['name'] as String?;
      }

      return StudentProfile(
        id: userId,
        studentCode: student['student_code'] as String,
        fullName: '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim(),
        email: profile['email'] as String? ?? '',
        phone: profile['phone'] as String?,
        avatarUrl: profile['avatar_url'] as String?,
        facultyName: facultyName,
        majorName: majorName,
        yearLevel: student['year_level'] as int? ?? 1,
        enrollmentYear: student['enrollment_year'] as int,
        status: StudentStatus.values.byName(
            student['status'] as String? ?? 'active'),
        dateOfBirth: student['date_of_birth'] as String?,
        gender: student['gender'] as String?,
        address: student['address'] as String?,
        nationality: student['nationality'] as String?,
        emergencyContact: student['emergency_contact'] as String?,
      );
    } catch (e, st) {
      debugPrint('getStudentProfile error: $e\n$st');
      rethrow;
    }
  }

  Future<List<EnrolledCourse>> getEnrolledCourses(String studentId) async {
    try {
      final enrollments = await _db
          .from('enrollments')
          .select('id, status, course_id')
          .eq('student_id', studentId);

      if (enrollments.isEmpty) return [];

      final courseIds =
          enrollments.map((e) => e['course_id'] as String).toList();

      final courseRows = await _db
          .from('courses')
          .select('id, code, name, credits, teacher_id, semester_id')
          .inFilter('id', courseIds);

      final semesterIds = courseRows
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

      final teacherIds = courseRows
          .map((c) => c['teacher_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      Map<String, String> teacherNames = {};
      if (teacherIds.isNotEmpty) {
        final profs = await _db
            .from('profiles')
            .select('id, first_name, last_name')
            .inFilter('id', teacherIds);
        teacherNames = {
          for (final p in profs)
            p['id'] as String: '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim()
        };
      }

      // Attendance rate per course
      Map<String, double> attendanceRates = {};
      if (courseIds.isNotEmpty) {
        final attRows = await _db
            .from('attendance')
            .select('course_id, status')
            .eq('student_id', studentId)
            .inFilter('course_id', courseIds);

        final Map<String, List<String>> byCourse = {};
        for (final a in attRows) {
          byCourse
              .putIfAbsent(a['course_id'] as String, () => [])
              .add(a['status'] as String);
        }
        for (final entry in byCourse.entries) {
          final total = entry.value.length;
          final present =
              entry.value.where((s) => s == 'present').length;
          attendanceRates[entry.key] =
              total > 0 ? present / total : 0;
        }
      }

      final courseMap = {for (final c in courseRows) c['id'] as String: c};

      return enrollments.map((e) {
        final courseId = e['course_id'] as String;
        final course = courseMap[courseId];
        if (course == null) return null;
        final semId = course['semester_id'] as String?;
        final sem = semId != null ? semesterMap[semId] : null;
        final teacherId = course['teacher_id'] as String?;
        return EnrolledCourse(
          courseId: courseId,
          enrollmentId: e['id'] as String,
          code: course['code'] as String,
          name: course['name'] as String,
          credits: course['credits'] as int? ?? 3,
          teacherName:
              teacherId != null ? teacherNames[teacherId] : null,
          semesterName: sem?['name'] as String?,
          semesterAcademicYear: sem?['academic_year'] as String?,
          isCurrentSemester: sem?['is_current'] as bool? ?? false,
          enrollmentStatus: EnrollmentStatus.values.byName(
              e['status'] as String? ?? 'enrolled'),
          attendanceRate: attendanceRates[courseId],
        );
      }).whereType<EnrolledCourse>().toList();
    } catch (e, st) {
      debugPrint('getEnrolledCourses error: $e\n$st');
      rethrow;
    }
  }

  Future<List<SemesterGrades>> getGradesBySemester(
      String studentId) async {
    try {
      final grades = await _db
          .from('grades')
          .select(
              'course_id, semester_id, midterm, final_exam, assignment, '
              'participation, total, letter_grade, gpa_points')
          .eq('student_id', studentId);

      if (grades.isEmpty) return [];

      final courseIds =
          grades.map((g) => g['course_id'] as String).toSet().toList();
      final semesterIds = grades
          .map((g) => g['semester_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final courses = await _db
          .from('courses')
          .select('id, code, name, credits')
          .inFilter('id', courseIds);
      final courseMap = {for (final c in courses) c['id'] as String: c};

      List<Map<String, dynamic>> semList = [];
      if (semesterIds.isNotEmpty) {
        semList = await _db
            .from('semesters')
            .select('id, name, academic_year, start_date, is_current')
            .inFilter('id', semesterIds)
            .order('start_date', ascending: false);
      }
      // Group grades by semester
      final Map<String, List<Map<String, dynamic>>> bySem = {};
      for (final g in grades) {
        final sid = g['semester_id'] as String? ?? '__none__';
        bySem.putIfAbsent(sid, () => []).add(g);
      }

      return semList.map((sem) {
        final sid = sem['id'] as String;
        final semGrades = bySem[sid] ?? [];

        final courseGrades = semGrades.map((g) {
          final cid = g['course_id'] as String;
          final course = courseMap[cid];
          if (course == null) return null;
          return CourseGrade(
            courseId: cid,
            courseName: course['name'] as String,
            courseCode: course['code'] as String,
            credits: course['credits'] as int? ?? 3,
            midterm: (g['midterm'] as num?)?.toDouble(),
            finalExam: (g['final_exam'] as num?)?.toDouble(),
            assignment: (g['assignment'] as num?)?.toDouble(),
            total: (g['total'] as num?)?.toDouble(),
            letterGrade: g['letter_grade'] as String?,
            gpaPoints: (g['gpa_points'] as num?)?.toDouble(),
          );
        }).whereType<CourseGrade>().toList();

        return SemesterGrades(
          semesterId: sid,
          semesterName: sem['name'] as String,
          academicYear: sem['academic_year'] as String,
          startDate: sem['start_date'] as String,
          isCurrent: sem['is_current'] as bool? ?? false,
          courses: courseGrades,
        );
      }).toList();
    } catch (e, st) {
      debugPrint('getGradesBySemester error: $e\n$st');
      rethrow;
    }
  }

  Future<AttendanceSummary> getAttendanceSummary(
      String studentId) async {
    try {
      final records = await _db
          .from('attendance')
          .select('course_id, date, status')
          .eq('student_id', studentId)
          .order('date', ascending: false);

      if (records.isEmpty) {
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

      final courseIds =
          records.map((r) => r['course_id'] as String).toSet().toList();
      final courseRows = await _db
          .from('courses')
          .select('id, name, code')
          .inFilter('id', courseIds);
      final courseMap = {
        for (final c in courseRows) c['id'] as String: c
      };

      int present = 0, absent = 0, late = 0, excused = 0;
      final Map<String, List<String>> byCourse = {};

      for (final r in records) {
        final s = r['status'] as String;
        switch (s) {
          case 'present':
            present++;
            break;
          case 'absent':
            absent++;
            break;
          case 'late':
            late++;
            break;
          case 'excused':
            excused++;
            break;
        }
        byCourse
            .putIfAbsent(r['course_id'] as String, () => [])
            .add(s);
      }

      final courseBreakdown = byCourse.entries.map((entry) {
        final course = courseMap[entry.key];
        final statuses = entry.value;
        return CourseAttendance(
          courseName: course?['name'] as String? ?? 'Unknown',
          total: statuses.length,
          present: statuses.where((s) => s == 'present').length,
          absent: statuses.where((s) => s == 'absent').length,
          late: statuses.where((s) => s == 'late').length,
          excused: statuses.where((s) => s == 'excused').length,
        );
      }).toList();

      final recentRecords = records.take(15).map((r) {
        final course = courseMap[r['course_id'] as String];
        AttendanceStatus status;
        try {
          status = AttendanceStatus.values
              .byName(r['status'] as String);
        } catch (_) {
          status = AttendanceStatus.present;
        }
        return AttendanceRecord(
          date: r['date'] as String,
          courseName: course?['name'] as String? ?? 'Unknown',
          courseCode: course?['code'] as String? ?? '',
          status: status,
        );
      }).toList();

      return AttendanceSummary(
        totalDays: records.length,
        present: present,
        absent: absent,
        late: late,
        excused: excused,
        courseBreakdown: courseBreakdown,
        recentRecords: recentRecords,
      );
    } catch (e, st) {
      debugPrint('getAttendanceSummary error: $e\n$st');
      rethrow;
    }
  }

  Future<FinanceSummary> getFinanceSummary(String studentId) async {
    try {
      final invoices = await _db
          .from('invoices')
          .select(
              'id, description, amount, due_date, paid_at, status, semester_id')
          .eq('student_id', studentId)
          .order('due_date', ascending: true);

      if (invoices.isEmpty) {
        return const FinanceSummary(
          totalFees: 0,
          totalPaid: 0,
          outstanding: 0,
          status: 'PAID',
          invoices: [],
        );
      }

      double totalFees = 0;
      double totalPaid = 0;

      for (final inv in invoices) {
        final amount = (inv['amount'] as num).toDouble();
        totalFees += amount;
        if (inv['status'] == 'paid') totalPaid += amount;
      }

      final outstanding = totalFees - totalPaid;

      // Nearest unpaid invoice for due-date reminder
      final unpaidList = invoices.where((inv) {
        final s = inv['status'] as String;
        return s == 'unpaid' || s == 'partial' || s == 'overdue';
      }).toList();

      String? nextDueDate =
          unpaidList.isNotEmpty ? unpaidList.first['due_date'] as String : null;
      String? nextDueName =
          unpaidList.isNotEmpty ? unpaidList.first['description'] as String : null;

      final hasOverdue = invoices.any((inv) => inv['status'] == 'overdue');
      final hasUnpaid = unpaidList.isNotEmpty;
      String status;
      if (hasOverdue) {
        status = 'OVERDUE';
      } else if (hasUnpaid && totalPaid > 0) {
        status = 'PARTIAL';
      } else if (hasUnpaid) {
        status = 'UNPAID';
      } else {
        status = 'PAID';
      }

      final invoiceRows = invoices.map((inv) {
        return InvoiceRow(
          id: inv['id'] as String,
          studentId: studentId,
          semesterId: inv['semester_id'] as String?,
          description: inv['description'] as String,
          amount: (inv['amount'] as num).toDouble(),
          dueDate: inv['due_date'] as String,
          paidAt: inv['paid_at'] == null
              ? null
              : DateTime.tryParse(inv['paid_at'] as String),
          status: InvoiceStatus.values.byName(
              inv['status'] as String? ?? 'unpaid'),
        );
      }).toList();

      return FinanceSummary(
        totalFees: totalFees,
        totalPaid: totalPaid,
        outstanding: outstanding,
        nextDueDate: nextDueDate,
        nextDueName: nextDueName,
        status: status,
        invoices: invoiceRows,
      );
    } catch (e, st) {
      debugPrint('getFinanceSummary error: $e\n$st');
      rethrow;
    }
  }

  Future<List<LeaveRequestRow>> getLeaveRequests(
      String studentId) async {
    try {
      final data = await _db
          .from('leave_requests')
          .select()
          .eq('requester_id', studentId)
          .eq('requester_type', 'student')
          .order('created_at', ascending: false);
      return data.map(LeaveRequestRow.fromMap).toList();
    } catch (e, st) {
      debugPrint('getLeaveRequests error: $e\n$st');
      rethrow;
    }
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

  Future<void> createLeaveRequest({
    required String studentId,
    required String type,
    required String reason,
    required String startDate,
    required String endDate,
    String? docUrl,
  }) async {
    await _db.from('leave_requests').insert({
      'requester_id': studentId,
      'requester_type': 'student',
      'type': type,
      'reason': reason,
      'start_date': startDate,
      'end_date': endDate,
      'status': 'pending',
      if (docUrl != null) 'doc_url': docUrl,
    });
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _db
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }
}
