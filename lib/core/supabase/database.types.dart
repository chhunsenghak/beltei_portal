// Dart models generated from supabase_schema.sql
// Use .fromMap() to deserialize Supabase rows, .toMap() to serialize for inserts.

import '../../features/auth/models/app_user.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

// UserRole is defined in app_user.dart — import from there to avoid duplicates

enum StudentStatus { active, inactive, graduated, suspended }

enum AttendanceStatus { present, absent, late, excused }

enum LeaveStatus { pending, approved, rejected }

enum InvoiceStatus { unpaid, paid, overdue, partial }

enum EnrollmentStatus { enrolled, dropped, completed }

enum CourseStatus { active, inactive }

// ── Table name constants ──────────────────────────────────────────────────────

class Tables {
  static const String profiles        = 'profiles';
  static const String faculties       = 'faculties';
  static const String departments     = 'departments';
  static const String students        = 'students';
  static const String teachers        = 'teachers';
  static const String semesters       = 'semesters';
  static const String courses         = 'courses';
  static const String enrollments     = 'enrollments';
  static const String grades          = 'grades';
  static const String attendance      = 'attendance';
  static const String leaveRequests   = 'leave_requests';
  static const String invoices        = 'invoices';
  static const String payments        = 'payments';
  static const String notifications   = 'notifications';
  static const String courseMaterials = 'course_materials';
  static const String announcements   = 'announcements';
}

// ── profiles ──────────────────────────────────────────────────────────────────

class ProfileRow {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phone;
  final String? avatarUrl;
  final DateTime? createdAt;

  const ProfileRow({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.createdAt,
  });

  factory ProfileRow.fromMap(Map<String, dynamic> m) => ProfileRow(
        id: m['id'] as String,
        email: m['email'] as String,
        fullName: '${m['first_name'] ?? ''} ${m['last_name'] ?? ''}'.trim(),
        role: UserRole.values.byName(m['role'] as String),
        phone: m['phone'] as String?,
        avatarUrl: m['avatar_url'] as String?,
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'first_name': fullName.split(' ').first,
        'last_name': fullName.split(' ').skip(1).join(' '),
        'role': role.name,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };
}

// ── faculties ─────────────────────────────────────────────────────────────────

class FacultyRow {
  final String id;
  final String name;
  final String code;
  final DateTime? createdAt;

  const FacultyRow({required this.id, required this.name, required this.code, this.createdAt});

  factory FacultyRow.fromMap(Map<String, dynamic> m) => FacultyRow(
        id: m['id'] as String,
        name: m['name'] as String,
        code: m['code'] as String,
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {'name': name, 'code': code};
}

// ── departments ───────────────────────────────────────────────────────────────

class DepartmentRow {
  final String id;
  final String? facultyId;
  final String name;
  final String code;
  final DateTime? createdAt;

  const DepartmentRow({required this.id, this.facultyId, required this.name, required this.code, this.createdAt});

  factory DepartmentRow.fromMap(Map<String, dynamic> m) => DepartmentRow(
        id: m['id'] as String,
        facultyId: m['faculty_id'] as String?,
        name: m['name'] as String,
        code: m['code'] as String,
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (facultyId != null) 'faculty_id': facultyId,
        'name': name,
        'code': code,
      };
}

// ── students ──────────────────────────────────────────────────────────────────

class StudentRow {
  final String id;
  final String studentCode;
  final String? facultyId;
  final String? departmentId;
  final int enrollmentYear;
  final int yearLevel;
  final StudentStatus status;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? emergencyContact;
  final DateTime? createdAt;

  const StudentRow({
    required this.id,
    required this.studentCode,
    this.facultyId,
    this.departmentId,
    required this.enrollmentYear,
    this.yearLevel = 1,
    this.status = StudentStatus.active,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.emergencyContact,
    this.createdAt,
  });

  factory StudentRow.fromMap(Map<String, dynamic> m) => StudentRow(
        id: m['id'] as String,
        studentCode: m['student_code'] as String,
        facultyId: m['faculty_id'] as String?,
        departmentId: m['department_id'] as String?,
        enrollmentYear: m['enrollment_year'] as int,
        yearLevel: m['year_level'] as int? ?? 1,
        status: StudentStatus.values.byName(m['status'] as String? ?? 'active'),
        dateOfBirth: m['date_of_birth'] as String?,
        gender: m['gender'] as String?,
        address: m['address'] as String?,
        emergencyContact: m['emergency_contact'] as String?,
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'student_code': studentCode,
        if (facultyId != null) 'faculty_id': facultyId,
        if (departmentId != null) 'department_id': departmentId,
        'enrollment_year': enrollmentYear,
        'year_level': yearLevel,
        'status': status.name,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (gender != null) 'gender': gender,
        if (address != null) 'address': address,
        if (emergencyContact != null) 'emergency_contact': emergencyContact,
      };
}

// ── teachers ──────────────────────────────────────────────────────────────────

class TeacherRow {
  final String id;
  final String employeeCode;
  final String? departmentId;
  final String? position;
  final String? specialization;
  final String? hireDate;
  final String status;
  final DateTime? createdAt;

  const TeacherRow({
    required this.id,
    required this.employeeCode,
    this.departmentId,
    this.position,
    this.specialization,
    this.hireDate,
    this.status = 'active',
    this.createdAt,
  });

  factory TeacherRow.fromMap(Map<String, dynamic> m) => TeacherRow(
        id: m['id'] as String,
        employeeCode: m['employee_code'] as String,
        departmentId: m['department_id'] as String?,
        position: m['position'] as String?,
        specialization: m['specialization'] as String?,
        hireDate: m['hire_date'] as String?,
        status: m['status'] as String? ?? 'active',
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'employee_code': employeeCode,
        if (departmentId != null) 'department_id': departmentId,
        if (position != null) 'position': position,
        if (specialization != null) 'specialization': specialization,
        if (hireDate != null) 'hire_date': hireDate,
        'status': status,
      };
}

// ── semesters ─────────────────────────────────────────────────────────────────

class SemesterRow {
  final String id;
  final String name;
  final String academicYear;
  final String startDate;
  final String endDate;
  final bool isCurrent;
  final DateTime? createdAt;

  const SemesterRow({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
    this.createdAt,
  });

  factory SemesterRow.fromMap(Map<String, dynamic> m) => SemesterRow(
        id: m['id'] as String,
        name: m['name'] as String,
        academicYear: m['academic_year'] as String,
        startDate: m['start_date'] as String,
        endDate: m['end_date'] as String,
        isCurrent: m['is_current'] as bool? ?? false,
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'academic_year': academicYear,
        'start_date': startDate,
        'end_date': endDate,
        'is_current': isCurrent,
      };
}

// ── courses ───────────────────────────────────────────────────────────────────

class CourseRow {
  final String id;
  final String code;
  final String name;
  final int credits;
  final String? teacherId;
  final String? semesterId;
  final String? facultyId;
  final String? departmentId;
  final int maxStudents;
  final List<Map<String, dynamic>>? schedule;
  final String? description;
  final CourseStatus status;
  final DateTime? createdAt;

  const CourseRow({
    required this.id,
    required this.code,
    required this.name,
    this.credits = 3,
    this.teacherId,
    this.semesterId,
    this.facultyId,
    this.departmentId,
    this.maxStudents = 40,
    this.schedule,
    this.description,
    this.status = CourseStatus.active,
    this.createdAt,
  });

  factory CourseRow.fromMap(Map<String, dynamic> m) => CourseRow(
        id: m['id'] as String,
        code: m['code'] as String,
        name: m['name'] as String,
        credits: m['credits'] as int? ?? 3,
        teacherId: m['teacher_id'] as String?,
        semesterId: m['semester_id'] as String?,
        facultyId: m['faculty_id'] as String?,
        departmentId: m['department_id'] as String?,
        maxStudents: m['max_students'] as int? ?? 40,
        schedule: (m['schedule'] as List?)?.cast<Map<String, dynamic>>(),
        description: m['description'] as String?,
        status: CourseStatus.values.byName(m['status'] as String? ?? 'active'),
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'code': code,
        'name': name,
        'credits': credits,
        if (teacherId != null) 'teacher_id': teacherId,
        if (semesterId != null) 'semester_id': semesterId,
        if (facultyId != null) 'faculty_id': facultyId,
        if (departmentId != null) 'department_id': departmentId,
        'max_students': maxStudents,
        if (schedule != null) 'schedule': schedule,
        if (description != null) 'description': description,
        'status': status.name,
      };
}

// ── enrollments ───────────────────────────────────────────────────────────────

class EnrollmentRow {
  final String id;
  final String studentId;
  final String courseId;
  final String? semesterId;
  final DateTime? enrolledAt;
  final EnrollmentStatus status;

  const EnrollmentRow({
    required this.id,
    required this.studentId,
    required this.courseId,
    this.semesterId,
    this.enrolledAt,
    this.status = EnrollmentStatus.enrolled,
  });

  factory EnrollmentRow.fromMap(Map<String, dynamic> m) => EnrollmentRow(
        id: m['id'] as String,
        studentId: m['student_id'] as String,
        courseId: m['course_id'] as String,
        semesterId: m['semester_id'] as String?,
        enrolledAt: m['enrolled_at'] == null ? null : DateTime.parse(m['enrolled_at'] as String),
        status: EnrollmentStatus.values.byName(m['status'] as String? ?? 'enrolled'),
      );

  Map<String, dynamic> toMap() => {
        'student_id': studentId,
        'course_id': courseId,
        if (semesterId != null) 'semester_id': semesterId,
        'status': status.name,
      };
}

// ── grades ────────────────────────────────────────────────────────────────────

class GradeRow {
  final String id;
  final String studentId;
  final String courseId;
  final String? semesterId;
  final double? midterm;
  final double? finalExam;
  final double? assignment;
  final double? participation;
  final double? total;
  final String? letterGrade;
  final double? gpaPoints;
  final String? remarks;

  const GradeRow({
    required this.id,
    required this.studentId,
    required this.courseId,
    this.semesterId,
    this.midterm,
    this.finalExam,
    this.assignment,
    this.participation,
    this.total,
    this.letterGrade,
    this.gpaPoints,
    this.remarks,
  });

  factory GradeRow.fromMap(Map<String, dynamic> m) => GradeRow(
        id: m['id'] as String,
        studentId: m['student_id'] as String,
        courseId: m['course_id'] as String,
        semesterId: m['semester_id'] as String?,
        midterm: (m['midterm'] as num?)?.toDouble(),
        finalExam: (m['final_exam'] as num?)?.toDouble(),
        assignment: (m['assignment'] as num?)?.toDouble(),
        participation: (m['participation'] as num?)?.toDouble(),
        total: (m['total'] as num?)?.toDouble(),
        letterGrade: m['letter_grade'] as String?,
        gpaPoints: (m['gpa_points'] as num?)?.toDouble(),
        remarks: m['remarks'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'student_id': studentId,
        'course_id': courseId,
        if (semesterId != null) 'semester_id': semesterId,
        if (midterm != null) 'midterm': midterm,
        if (finalExam != null) 'final_exam': finalExam,
        if (assignment != null) 'assignment': assignment,
        if (participation != null) 'participation': participation,
        if (total != null) 'total': total,
        if (letterGrade != null) 'letter_grade': letterGrade,
        if (gpaPoints != null) 'gpa_points': gpaPoints,
        if (remarks != null) 'remarks': remarks,
      };
}

// ── attendance ────────────────────────────────────────────────────────────────

class AttendanceRow {
  final String id;
  final String studentId;
  final String courseId;
  final String date;
  final AttendanceStatus status;
  final String? markedBy;
  final String? notes;
  final DateTime? createdAt;

  const AttendanceRow({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.date,
    required this.status,
    this.markedBy,
    this.notes,
    this.createdAt,
  });

  factory AttendanceRow.fromMap(Map<String, dynamic> m) => AttendanceRow(
        id: m['id'] as String,
        studentId: m['student_id'] as String,
        courseId: m['course_id'] as String,
        date: m['date'] as String,
        status: AttendanceStatus.values.byName(m['status'] as String),
        markedBy: m['marked_by'] as String?,
        notes: m['notes'] as String?,
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'student_id': studentId,
        'course_id': courseId,
        'date': date,
        'status': status.name,
        if (markedBy != null) 'marked_by': markedBy,
        if (notes != null) 'notes': notes,
      };
}

// ── leave_requests ────────────────────────────────────────────────────────────

class LeaveRequestRow {
  final String id;
  final String requesterId;
  final String requesterType;
  final String type;
  final String reason;
  final String startDate;
  final String endDate;
  final String? docUrl;
  final LeaveStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final DateTime? createdAt;

  const LeaveRequestRow({
    required this.id,
    required this.requesterId,
    required this.requesterType,
    required this.type,
    required this.reason,
    required this.startDate,
    required this.endDate,
    this.docUrl,
    this.status = LeaveStatus.pending,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    this.createdAt,
  });

  factory LeaveRequestRow.fromMap(Map<String, dynamic> m) => LeaveRequestRow(
        id: m['id'] as String,
        requesterId: m['requester_id'] as String,
        requesterType: m['requester_type'] as String,
        type: m['type'] as String,
        reason: m['reason'] as String,
        startDate: m['start_date'] as String,
        endDate: m['end_date'] as String,
        docUrl: m['doc_url'] as String?,
        status: LeaveStatus.values.byName(m['status'] as String? ?? 'pending'),
        reviewedBy: m['reviewed_by'] as String?,
        reviewedAt: m['reviewed_at'] == null ? null : DateTime.parse(m['reviewed_at'] as String),
        reviewNotes: m['review_notes'] as String?,
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'requester_id': requesterId,
        'requester_type': requesterType,
        'type': type,
        'reason': reason,
        'start_date': startDate,
        'end_date': endDate,
        if (docUrl != null) 'doc_url': docUrl,
        'status': status.name,
      };
}

// ── invoices ──────────────────────────────────────────────────────────────────

class InvoiceRow {
  final String id;
  final String studentId;
  final String? semesterId;
  final String description;
  final double amount;
  final String dueDate;
  final DateTime? paidAt;
  final InvoiceStatus status;
  final DateTime? createdAt;

  const InvoiceRow({
    required this.id,
    required this.studentId,
    this.semesterId,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.paidAt,
    this.status = InvoiceStatus.unpaid,
    this.createdAt,
  });

  factory InvoiceRow.fromMap(Map<String, dynamic> m) => InvoiceRow(
        id: m['id'] as String,
        studentId: m['student_id'] as String,
        semesterId: m['semester_id'] as String?,
        description: m['description'] as String,
        amount: (m['amount'] as num).toDouble(),
        dueDate: m['due_date'] as String,
        paidAt: m['paid_at'] == null ? null : DateTime.parse(m['paid_at'] as String),
        status: InvoiceStatus.values.byName(m['status'] as String? ?? 'unpaid'),
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'student_id': studentId,
        if (semesterId != null) 'semester_id': semesterId,
        'description': description,
        'amount': amount,
        'due_date': dueDate,
        'status': status.name,
      };
}

// ── payments ──────────────────────────────────────────────────────────────────

class PaymentRow {
  final String id;
  final String? invoiceId;
  final String? studentId;
  final double amount;
  final String paymentMethod;
  final String? referenceNumber;
  final DateTime? paidAt;
  final String? verifiedBy;
  final String? notes;

  const PaymentRow({
    required this.id,
    this.invoiceId,
    this.studentId,
    required this.amount,
    required this.paymentMethod,
    this.referenceNumber,
    this.paidAt,
    this.verifiedBy,
    this.notes,
  });

  factory PaymentRow.fromMap(Map<String, dynamic> m) => PaymentRow(
        id: m['id'] as String,
        invoiceId: m['invoice_id'] as String?,
        studentId: m['student_id'] as String?,
        amount: (m['amount'] as num).toDouble(),
        paymentMethod: m['payment_method'] as String,
        referenceNumber: m['reference_number'] as String?,
        paidAt: m['paid_at'] == null ? null : DateTime.parse(m['paid_at'] as String),
        verifiedBy: m['verified_by'] as String?,
        notes: m['notes'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (invoiceId != null) 'invoice_id': invoiceId,
        if (studentId != null) 'student_id': studentId,
        'amount': amount,
        'payment_method': paymentMethod,
        if (referenceNumber != null) 'reference_number': referenceNumber,
        if (notes != null) 'notes': notes,
      };
}

// ── notifications ─────────────────────────────────────────────────────────────

class NotificationRow {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime? createdAt;

  const NotificationRow({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = 'info',
    this.isRead = false,
    this.data,
    this.createdAt,
  });

  factory NotificationRow.fromMap(Map<String, dynamic> m) => NotificationRow(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        title: m['title'] as String,
        body: m['body'] as String,
        type: m['type'] as String? ?? 'info',
        isRead: m['is_read'] as bool? ?? false,
        data: m['data'] as Map<String, dynamic>?,
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': isRead,
        if (data != null) 'data': data,
      };
}

// ── course_materials ──────────────────────────────────────────────────────────

class CourseMaterialRow {
  final String id;
  final String courseId;
  final String? teacherId;
  final String title;
  final String? description;
  final String fileUrl;
  final String? fileType;
  final int? fileSize;
  final DateTime? uploadedAt;

  const CourseMaterialRow({
    required this.id,
    required this.courseId,
    this.teacherId,
    required this.title,
    this.description,
    required this.fileUrl,
    this.fileType,
    this.fileSize,
    this.uploadedAt,
  });

  factory CourseMaterialRow.fromMap(Map<String, dynamic> m) => CourseMaterialRow(
        id: m['id'] as String,
        courseId: m['course_id'] as String,
        teacherId: m['teacher_id'] as String?,
        title: m['title'] as String,
        description: m['description'] as String?,
        fileUrl: m['file_url'] as String,
        fileType: m['file_type'] as String?,
        fileSize: m['file_size'] as int?,
        uploadedAt: m['uploaded_at'] == null ? null : DateTime.parse(m['uploaded_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'course_id': courseId,
        if (teacherId != null) 'teacher_id': teacherId,
        'title': title,
        if (description != null) 'description': description,
        'file_url': fileUrl,
        if (fileType != null) 'file_type': fileType,
        if (fileSize != null) 'file_size': fileSize,
      };
}

// ── announcements ─────────────────────────────────────────────────────────────

class AnnouncementRow {
  final String id;
  final String? teacherId;
  final String? courseId;
  final String title;
  final String body;
  final bool isPinned;
  final DateTime? createdAt;

  const AnnouncementRow({
    required this.id,
    this.teacherId,
    this.courseId,
    required this.title,
    required this.body,
    this.isPinned = false,
    this.createdAt,
  });

  factory AnnouncementRow.fromMap(Map<String, dynamic> m) => AnnouncementRow(
        id: m['id'] as String,
        teacherId: m['teacher_id'] as String?,
        courseId: m['course_id'] as String?,
        title: m['title'] as String,
        body: m['body'] as String,
        isPinned: m['is_pinned'] as bool? ?? false,
        createdAt: m['created_at'] == null ? null : DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (teacherId != null) 'teacher_id': teacherId,
        if (courseId != null) 'course_id': courseId,
        'title': title,
        'body': body,
        'is_pinned': isPinned,
      };
}
