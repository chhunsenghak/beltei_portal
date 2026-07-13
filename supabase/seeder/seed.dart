import 'dart:io';
import 'package:supabase/supabase.dart';

const kPassword = 'Beltei@2026';

void main() async {
  final (url: url, serviceKey: key) = _loadConfig();

  print('🌱 Connecting to $url ...');
  final supabase = SupabaseClient(url, key);

  try {
    await _waitForAuthService(supabase);

    // ── 1. Auth users ───────────────────────────────────────────────────────
    print('\n👤 Creating auth users...');

    final adminId = await _createUser(supabase,
        email: 'admin@beltei.edu.kh',
        firstName: 'Admin',
        lastName: 'User',
        role: 'admin');

    final khanId = await _createUser(supabase,
        email: 'sokha.khan@beltei.edu.kh',
        firstName: 'Sokha',
        lastName: 'Khan',
        role: 'teacher');
    final chhaiId = await _createUser(supabase,
        email: 'chivon.chhai@beltei.edu.kh',
        firstName: 'Chivon',
        lastName: 'Chhai',
        role: 'teacher');
    final sinId = await _createUser(supabase,
        email: 'bunthoeurn.sin@beltei.edu.kh',
        firstName: 'Bunthoeurn',
        lastName: 'Sin',
        role: 'teacher');
    final chenId = await _createUser(supabase,
        email: 'sovann.chen@beltei.edu.kh',
        firstName: 'Sovann',
        lastName: 'Chen',
        role: 'teacher');
    final chanthornId = await _createUser(supabase,
        email: 'chanthorn@beltei.edu.kh',
        firstName: 'Chanthorn',
        lastName: '',
        role: 'teacher');

    final ranutId = await _createUser(supabase,
        email: 'hort.ranut@beltei.edu.kh',
        firstName: 'Hort',
        lastName: 'Ranut',
        role: 'student');
    final kimhengId = await _createUser(supabase,
        email: 'chhim.kimheng@beltei.edu.kh',
        firstName: 'Chhim',
        lastName: 'Kimheng',
        role: 'student');
    final samornId = await _createUser(supabase,
        email: 'mai.samorn@beltei.edu.kh',
        firstName: 'Mai',
        lastName: 'Samorn',
        role: 'student');
    final rathId = await _createUser(supabase,
        email: 'samrith.rath@beltei.edu.kh',
        firstName: 'Samrith',
        lastName: 'Rath',
        role: 'student');
    final senghakId = await _createUser(supabase,
        email: 'chhun.senghak@beltei.edu.kh',
        firstName: 'Chhun',
        lastName: 'Senghak',
        role: 'student');

    print('  ✓ 11 users created');

    // ── 2. Update profiles with phone numbers ───────────────────────────────
    print('\n📝 Updating profiles...');
    final phones = {
      adminId: '012 345 678',
      khanId: '012 111 222',
      chhaiId: '012 333 444',
      sinId: '012 555 666',
      chenId: '012 777 888',
      chanthornId: '012 999 000',
      ranutId: '096 100 001',
      kimhengId: '096 100 002',
      samornId: '096 100 003',
      rathId: '096 100 004',
      senghakId: '096 100 005',
    };
    for (final e in phones.entries) {
      await supabase
          .from('profiles')
          .update({'phone': e.value}).eq('id', e.key);
    }
    print('  ✓ Phone numbers added');

    // ── 3. Faculties ────────────────────────────────────────────────────────
    print('\n🏫 Inserting faculties...');
    final faculties = await supabase.from('faculties').insert([
      {'name': 'Faculty of Information Technology and Science', 'code': 'FITS'},
      {'name': 'Faculty of Business Administration', 'code': 'FBA'},
      {'name': 'Faculty of Digital Technology and Telecommunication', 'code': 'FDTT'},
    ]).select();

    String fid(String code) =>
        faculties.firstWhere((f) => f['code'] == code)['id'] as String;
    final fitsId = fid('FITS');
    print('  ✓ Faculties inserted');

    // ── 4. Departments ──────────────────────────────────────────────────────
    print('\n🏢 Inserting departments...');
    final departments = await supabase.from('departments').insert([
      {'faculty_id': fitsId, 'name': 'Computer Science', 'code': 'CS'},
      {'faculty_id': fitsId, 'name': 'Network & Security', 'code': 'NET'},
      {'faculty_id': fid('FDTT'), 'name': 'Digital Technology', 'code': 'DT'},
    ]).select();

    String did(String code) =>
        departments.firstWhere((d) => d['code'] == code)['id'] as String;
    final csDeptId = did('CS');
    final netDeptId = did('NET');
    print('  ✓ ${departments.length} departments');

    // ── 5. Majors ────────────────────────────────────────────────────────────
    print('\n📖 Inserting majors...');
    final majors = await supabase.from('majors').insert([
      {'department_id': csDeptId, 'name': 'Software Engineering'},
      {'department_id': csDeptId, 'name': 'Data Science & AI'},
      {'department_id': netDeptId, 'name': 'Networking & Cybersecurity'},
    ]).select();

    String mid(String name) =>
        majors.firstWhere((m) => m['name'] == name)['id'] as String;
    final seId = mid('Software Engineering');
    print('  ✓ ${majors.length} majors');

    // ── 6. Academic Years ───────────────────────────────────────────────────
    print('\n🗓️  Inserting academic years...');
    final academicYearsResult = await supabase.from('academic_years').insert([
      {
        'name': '2023-2024',
        'start_date': '2023-04-01',
        'end_date': '2024-03-15',
      },
      {
        'name': '2024-2025',
        'start_date': '2024-04-01',
        'end_date': '2025-03-15',
      },
      {
        'name': '2025-2026',
        'start_date': '2025-04-01',
        'end_date': '2026-03-15',
      },
      {
        'name': '2026-2027',
        'start_date': '2026-04-01',
        'end_date': '2027-03-15',
      },
    ]).select();
    
    final ay2324Id = academicYearsResult.firstWhere((y) => y['name'] == '2023-2024')['id'] as String;
    final ay2425Id = academicYearsResult.firstWhere((y) => y['name'] == '2024-2025')['id'] as String;
    final ay2526Id = academicYearsResult.firstWhere((y) => y['name'] == '2025-2026')['id'] as String;
    final ay2627Id = academicYearsResult.firstWhere((y) => y['name'] == '2026-2027')['id'] as String;
    print('  ✓ 4 academic years');

    // ── 7. Semesters ────────────────────────────────────────────────────────
    print('\n📅 Inserting semesters...');
    final semesters = await supabase.from('semesters').insert([
      // Year 1 (2023-2024)
      {
        'name': 'Semester 1',
        'academic_year_id': ay2324Id,
        'start_date': '2023-04-01',
        'end_date': '2023-08-15',
        'is_current': false,
      },
      {
        'name': 'Semester 2',
        'academic_year_id': ay2324Id,
        'start_date': '2023-09-01',
        'end_date': '2024-02-15',
        'is_current': false,
      },
      // Year 2 (2024-2025)
      {
        'name': 'Semester 1',
        'academic_year_id': ay2425Id,
        'start_date': '2024-04-01',
        'end_date': '2024-08-15',
        'is_current': false,
      },
      {
        'name': 'Semester 2',
        'academic_year_id': ay2425Id,
        'start_date': '2024-09-01',
        'end_date': '2025-02-15',
        'is_current': false,
      },
      // Year 3 (2025-2026)
      {
        'name': 'Semester 1',
        'academic_year_id': ay2526Id,
        'start_date': '2025-04-01',
        'end_date': '2025-08-15',
        'is_current': false,
      },
      {
        'name': 'Semester 2',
        'academic_year_id': ay2526Id,
        'start_date': '2025-09-01',
        'end_date': '2026-02-15',
        'is_current': false,
      },
      // Year 4 (2026-2027)
      {
        'name': 'Semester 1',
        'academic_year_id': ay2627Id,
        'start_date': '2026-04-01',
        'end_date': '2026-08-15',
        'is_current': true, // Year 4 Sem 1 is current
      },
      {
        'name': 'Semester 2',
        'academic_year_id': ay2627Id,
        'start_date': '2026-09-01',
        'end_date': '2027-02-15',
        'is_current': false,
      },
    ]).select();

    final semY1S1Id = semesters.firstWhere((s) => s['academic_year_id'] == ay2324Id && s['name'] == 'Semester 1')['id'] as String;
    final semY1S2Id = semesters.firstWhere((s) => s['academic_year_id'] == ay2324Id && s['name'] == 'Semester 2')['id'] as String;
    final semY2S1Id = semesters.firstWhere((s) => s['academic_year_id'] == ay2425Id && s['name'] == 'Semester 1')['id'] as String;
    final semY2S2Id = semesters.firstWhere((s) => s['academic_year_id'] == ay2425Id && s['name'] == 'Semester 2')['id'] as String;
    final semY3S1Id = semesters.firstWhere((s) => s['academic_year_id'] == ay2526Id && s['name'] == 'Semester 1')['id'] as String;
    final semY3S2Id = semesters.firstWhere((s) => s['academic_year_id'] == ay2526Id && s['name'] == 'Semester 2')['id'] as String;
    final semY4S1Id = semesters.firstWhere((s) => s['academic_year_id'] == ay2627Id && s['name'] == 'Semester 1')['id'] as String;
    print('  ✓ 8 semesters created');

    // ── 8. Teachers ─────────────────────────────────────────────────────────
    print('\n👨‍🏫 Inserting teacher records...');
    await supabase.from('teachers').insert([
      {
        'id': khanId,
        'employee_code': 'EMP-1001',
        'department_id': csDeptId,
        'position': 'Senior Lecturer',
        'specialization': 'Python Programming',
        'hire_date': '2022-01-15',
        'status': 'active',
      },
      {
        'id': chhaiId,
        'employee_code': 'EMP-1002',
        'department_id': did('DT'),
        'position': 'Lecturer',
        'specialization': 'Mobile Application Development',
        'hire_date': '2021-03-01',
        'status': 'active',
      },
      {
        'id': sinId,
        'employee_code': 'EMP-1003',
        'department_id': netDeptId,
        'position': 'Lecturer',
        'specialization': 'Cloud Computing',
        'hire_date': '2020-06-01',
        'status': 'active',
      },
      {
        'id': chenId,
        'employee_code': 'EMP-1004',
        'department_id': csDeptId,
        'position': 'Senior Lecturer',
        'specialization': 'Artificial Intelligence',
        'hire_date': '2019-09-01',
        'status': 'active',
      },
      {
        'id': chanthornId,
        'employee_code': 'EMP-1005',
        'department_id': csDeptId,
        'position': 'Lecturer',
        'specialization': 'Research Methodology',
        'hire_date': '2023-02-01',
        'status': 'active',
      },
    ]);
    print('  ✓ 5 teachers');

    // ── 9. Students ─────────────────────────────────────────────────────────
    print('\n👨‍🎓 Inserting student records...');
    await supabase.from('students').insert([
      for (final s in [
        (id: ranutId, code: 'STU-2301', dob: '2004-06-10', gender: 'female', addr: 'Phnom Penh'),
        (id: kimhengId, code: 'STU-2302', dob: '2004-11-02', gender: 'male', addr: 'Phnom Penh'),
        (id: samornId, code: 'STU-2303', dob: '2005-01-18', gender: 'female', addr: 'Battambang'),
        (id: rathId, code: 'STU-2304', dob: '2005-09-20', gender: 'male', addr: 'Siem Reap'),
        (id: senghakId, code: 'STU-2305', dob: '2005-03-25', gender: 'male', addr: 'Kandal'),
      ])
        {
          'id': s.id,
          'student_code': s.code,
          'faculty_id': fitsId,
          'major_id': seId,
          'enrollment_year': 2023,
          'year_level': 4,
          'status': 'active',
          'date_of_birth': s.dob,
          'gender': s.gender,
          'address': s.addr,
          'emergency_contact': '099 123 456',
        },
    ]);
    print('  ✓ 5 students');

    // ── 10. Courses Catalog ──────────────────────────────────────────────────
    print('\n📚 Inserting curriculum courses catalog...');
    final coursesResult = await supabase.from('courses').insert([
      // Year 1 Semester 1
      {'code': 'CS101', 'name': 'Introduction to Computer Science', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      {'code': 'MATH101', 'name': 'Calculus I', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      // Year 1 Semester 2
      {'code': 'CS102', 'name': 'Programming Fundamentals', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      {'code': 'MATH102', 'name': 'Discrete Mathematics', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      // Year 2 Semester 1
      {'code': 'CS201', 'name': 'Data Structures & Algorithms', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      {'code': 'CS202', 'name': 'Database Management Systems', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      // Year 2 Semester 2
      {'code': 'CS203', 'name': 'Object-Oriented Programming', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      {'code': 'CS204', 'name': 'Software Engineering Methodologies', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      // Year 3 Semester 1
      {'code': 'CS301', 'name': 'Web Application Development', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      {'code': 'CS302', 'name': 'Operating Systems', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      // Year 3 Semester 2
      {'code': 'CS303', 'name': 'Computer Networks', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      {'code': 'CS304', 'name': 'Human-Computer Interaction', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      // Year 4 Semester 1 (Current active courses)
      {'code': 'PY101', 'name': 'Python Programming', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      {'code': 'MOB101', 'name': 'Mobile App Development', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      {'code': 'CLD101', 'name': 'Cloud Computing', 'credits': 3, 'faculty_id': fitsId, 'department_id': netDeptId, 'major_id': seId, 'status': 'active'},
      {'code': 'AI101', 'name': 'Artificial Intelligence', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
      {'code': 'RES101', 'name': 'Research Methodology', 'credits': 3, 'faculty_id': fitsId, 'department_id': csDeptId, 'major_id': seId, 'status': 'active'},
    ]).select();

    String cid(String code) =>
        coursesResult.firstWhere((c) => c['code'] == code)['id'] as String;
    
    final cs101Id = cid('CS101');
    final math101Id = cid('MATH101');
    final cs102Id = cid('CS102');
    final math102Id = cid('MATH102');
    final cs201Id = cid('CS201');
    final cs202Id = cid('CS202');
    final cs203Id = cid('CS203');
    final cs204Id = cid('CS204');
    final cs301Id = cid('CS301');
    final cs302Id = cid('CS302');
    final cs303Id = cid('CS303');
    final cs304Id = cid('CS304');
    final pyId = cid('PY101');
    final mobId = cid('MOB101');
    final cldId = cid('CLD101');
    final aiId = cid('AI101');
    final resId = cid('RES101');
    print('  ✓ ${coursesResult.length} courses catalog inserted');

    // ── 11. Class SE3 ────────────────────────────────────────────────────────
    print('\n🏫 Inserting class...');
    final classes = await supabase.from('classes').insert([
      {
        'class_code': 'SE3',
        'faculty_id': fitsId,
        'major_id': seId,
        'program_type': 'national',
        'status': 'active',
      },
    ]).select();
    final classId = classes.first['id'] as String;
    print('  ✓ Class SE3 created');

    // Helper function to seed past semesters with completed class terms, enrollments, grades, and attendance
    Future<void> seedPastSemester({
      required String semesterId,
      required int yearLevel,
      required String startDate,
      required List<Map<String, dynamic>> semesterCoursesList,
    }) async {
      final sem = await supabase.from('semesters').select('start_date, end_date').eq('id', semesterId).single();
      final ct = await supabase.from('class_terms').insert({
        'class_id': classId,
        'semester_id': semesterId,
        'year_level': yearLevel,
        'schedule_type': 'weekday',
        'shift': 'evening',
        'room': 'E101',
        'max_students': 30,
        'status': 'active',
        'start_date': sem['start_date'],
        'end_date': sem['end_date'],
      }).select().single();
      final pastTermId = ct['id'] as String;

      await supabase.from('enrollments').insert([
        for (final sId in [ranutId, kimhengId, samornId, rathId, senghakId])
          {
            'student_id': sId,
            'class_term_id': pastTermId,
            'status': 'completed',
          }
      ]);

      // Seed 1 leave request per past semester for some student
      final startDt = DateTime.parse(startDate);
      final leaveDate = startDt.add(const Duration(days: 15));
      final leaveDateStr = _formatDate(leaveDate);
      final studentList = [ranutId, kimhengId, samornId, rathId, senghakId];
      final targetStudent = studentList[yearLevel % studentList.length];

      await supabase.from('leave_requests').insert({
        'requester_id': targetStudent,
        'requester_type': 'student',
        'type': 'Sick Leave',
        'reason': 'Fever and general weakness',
        'start_date': leaveDateStr,
        'end_date': leaveDateStr,
        'status': 'approved',
        'reviewed_by': adminId,
        'reviewed_at': '${leaveDateStr}T08:00:00+07:00',
        'review_notes': 'Approved. Take care.',
      });

      final List<Map<String, dynamic>> attendanceRows = [];

      for (final c in semesterCoursesList) {
        final cId = c['course_id'] as String;
        final tId = c['teacher_id'] as String;
        
        final ctc = await supabase.from('class_term_courses').insert({
          'class_term_id': pastTermId,
          'course_id': cId,
          'teacher_id': tId,
          'schedule': [],
        }).select().single();
        final ctcId = ctc['id'] as String;

        await supabase.from('grades').insert([
          for (final sId in studentList)
            {
              'student_id': sId,
              'class_term_course_id': ctcId,
              'course_id': cId,
              'semester_id': semesterId,
              'midterm': c['mid'],
              'final_exam': c['fin'],
              'assignment': c['asgn'],
              'participation': c['part'],
              'total': c['total'],
              'letter_grade': c['letter'],
              'gpa_points': c['gpa'],
            }
        ]);

        // Seed 4 sample attendance dates for each course to show historical attendance record stats
        for (int w = 1; w <= 4; w++) {
          final attDate = startDt.add(Duration(days: w * 7 + (yearLevel % 5)));
          final attDateStr = _formatDate(attDate);
          
          for (final sId in studentList) {
            final isTargetStudent = sId == targetStudent;
            // Session 1
            attendanceRows.add({
              'student_id': sId,
              'class_term_course_id': ctcId,
              'course_id': cId,
              'semester_id': semesterId,
              'date': attDateStr,
              'session_number': 1,
              'status': (isTargetStudent && w == 2) ? 'excused' : 'present',
              'marked_by': tId,
            });
            // Session 2
            attendanceRows.add({
              'student_id': sId,
              'class_term_course_id': ctcId,
              'course_id': cId,
              'semester_id': semesterId,
              'date': attDateStr,
              'session_number': 2,
              'status': (isTargetStudent && w == 2) ? 'excused' : 'present',
              'marked_by': tId,
            });
          }
        }
      }

      if (attendanceRows.isNotEmpty) {
        await supabase.from('attendance').insert(attendanceRows);
      }
    }

    // ── 12. Seed Year 1 to Year 3 completed semesters ───────────────────────
    print('\n🗂  Seeding past semesters completed data (Year 1 - Year 3)...');
    
    // Year 1 Sem 1
    await seedPastSemester(
      semesterId: semY1S1Id,
      yearLevel: 1,
      startDate: '2023-04-01',
      semesterCoursesList: [
        {'course_id': cs101Id, 'teacher_id': khanId, 'mid': 85.0, 'fin': 88.0, 'asgn': 90.0, 'part': 90.0, 'total': 88.25, 'letter': 'A', 'gpa': 4.0},
        {'course_id': math101Id, 'teacher_id': chanthornId, 'mid': 72.0, 'fin': 75.0, 'asgn': 80.0, 'part': 80.0, 'total': 75.5, 'letter': 'B', 'gpa': 3.0},
      ],
    );

    // Year 1 Sem 2
    await seedPastSemester(
      semesterId: semY1S2Id,
      yearLevel: 1,
      startDate: '2023-09-01',
      semesterCoursesList: [
        {'course_id': cs102Id, 'teacher_id': khanId, 'mid': 80.0, 'fin': 82.0, 'asgn': 85.0, 'part': 80.0, 'total': 81.75, 'letter': 'B+', 'gpa': 3.5},
        {'course_id': math102Id, 'teacher_id': chanthornId, 'mid': 70.0, 'fin': 68.0, 'asgn': 75.0, 'part': 80.0, 'total': 71.0, 'letter': 'C+', 'gpa': 2.5},
      ],
    );

    // Year 2 Sem 1
    await seedPastSemester(
      semesterId: semY2S1Id,
      yearLevel: 2,
      startDate: '2024-04-01',
      semesterCoursesList: [
        {'course_id': cs201Id, 'teacher_id': sinId, 'mid': 78.0, 'fin': 80.0, 'asgn': 80.0, 'part': 80.0, 'total': 79.5, 'letter': 'B', 'gpa': 3.0},
        {'course_id': cs202Id, 'teacher_id': chhaiId, 'mid': 88.0, 'fin': 90.0, 'asgn': 92.0, 'part': 90.0, 'total': 90.0, 'letter': 'A', 'gpa': 4.0},
      ],
    );

    // Year 2 Sem 2
    await seedPastSemester(
      semesterId: semY2S2Id,
      yearLevel: 2,
      startDate: '2024-09-01',
      semesterCoursesList: [
        {'course_id': cs203Id, 'teacher_id': sinId, 'mid': 82.0, 'fin': 84.0, 'asgn': 85.0, 'part': 80.0, 'total': 83.5, 'letter': 'A-', 'gpa': 3.7},
        {'course_id': cs204Id, 'teacher_id': chhaiId, 'mid': 85.0, 'fin': 88.0, 'asgn': 90.0, 'part': 90.0, 'total': 88.25, 'letter': 'A', 'gpa': 4.0},
      ],
    );

    // Year 3 Sem 1
    await seedPastSemester(
      semesterId: semY3S1Id,
      yearLevel: 3,
      startDate: '2025-04-01',
      semesterCoursesList: [
        {'course_id': cs301Id, 'teacher_id': chenId, 'mid': 90.0, 'fin': 92.0, 'asgn': 95.0, 'part': 90.0, 'total': 92.25, 'letter': 'A+', 'gpa': 4.0},
        {'course_id': cs302Id, 'teacher_id': chanthornId, 'mid': 75.0, 'fin': 78.0, 'asgn': 80.0, 'part': 80.0, 'total': 77.75, 'letter': 'B', 'gpa': 3.0},
      ],
    );

    // Year 3 Sem 2
    await seedPastSemester(
      semesterId: semY3S2Id,
      yearLevel: 3,
      startDate: '2025-09-01',
      semesterCoursesList: [
        {'course_id': cs303Id, 'teacher_id': chenId, 'mid': 84.0, 'fin': 86.0, 'asgn': 88.0, 'part': 80.0, 'total': 85.6, 'letter': 'A-', 'gpa': 3.7},
        {'course_id': cs304Id, 'teacher_id': sinId, 'mid': 80.0, 'fin': 82.0, 'asgn': 80.0, 'part': 80.0, 'total': 81.0, 'letter': 'B+', 'gpa': 3.5},
      ],
    );
    print('  ✓ Past completed semesters successfully seeded with rich history');

    // ── 13. Active Year 4 Semester 1 Class Term ─────────────────────────────
    print('\n🗂  Seeding active Year 4 Semester 1 Class Term offering...');
    final activeSem = await supabase.from('semesters').select('start_date, end_date').eq('id', semY4S1Id).single();
    final activeClassTerm = await supabase.from('class_terms').insert({
      'class_id': classId,
      'semester_id': semY4S1Id,
      'year_level': 4,
      'schedule_type': 'weekday',
      'shift': 'evening',
      'room': 'E101',
      'max_students': 30,
      'status': 'active',
      'start_date': activeSem['start_date'],
      'end_date': activeSem['end_date'],
    }).select().single();
    final activeTermId = activeClassTerm['id'] as String;

    await supabase.from('enrollments').insert([
      for (final studentId in [ranutId, kimhengId, samornId, rathId, senghakId])
        {
          'student_id': studentId,
          'class_term_id': activeTermId,
          'status': 'enrolled',
        },
    ]);
    print('  ✓ Enrollments for active class term added');

    // ── 14. Active Class Term Courses (Curriculum schedules Mon-Fri) ────────
    print('\n📖 Inserting active class term courses...');
    final classTermCoursesResult = await supabase.from('class_term_courses').insert([
      {
        'class_term_id': activeTermId,
        'course_id': pyId,
        'teacher_id': khanId,
        'schedule': [
          {'day': 'Mon', 'start': '17:30', 'end': '19:00', 'room': 'E101'},
          {'day': 'Mon', 'start': '19:20', 'end': '20:30', 'room': 'E101'},
        ],
      },
      {
        'class_term_id': activeTermId,
        'course_id': mobId,
        'teacher_id': chhaiId,
        'schedule': [
          {'day': 'Tue', 'start': '17:30', 'end': '19:00', 'room': 'E101'},
          {'day': 'Tue', 'start': '19:20', 'end': '20:30', 'room': 'E101'},
        ],
      },
      {
        'class_term_id': activeTermId,
        'course_id': cldId,
        'teacher_id': sinId,
        'schedule': [
          {'day': 'Wed', 'start': '17:30', 'end': '19:00', 'room': 'E101'},
          {'day': 'Wed', 'start': '19:20', 'end': '20:30', 'room': 'E101'},
        ],
      },
      {
        'class_term_id': activeTermId,
        'course_id': aiId,
        'teacher_id': chenId,
        'schedule': [
          {'day': 'Thu', 'start': '17:30', 'end': '19:00', 'room': 'E101'},
          {'day': 'Thu', 'start': '19:20', 'end': '20:30', 'room': 'E101'},
        ],
      },
      {
        'class_term_id': activeTermId,
        'course_id': resId,
        'teacher_id': chanthornId,
        'schedule': [
          {'day': 'Fri', 'start': '17:30', 'end': '19:00', 'room': 'Online'},
          {'day': 'Fri', 'start': '19:20', 'end': '20:30', 'room': 'Online'},
        ],
      },
    ]).select();
    print('  ✓ 5 active class term courses matching curriculum inserted');

    // ── 15. Active Attendance data (Past weeks only, current week open) ─────
    print('\n📆 Seeding active attendance records (past weeks only)...');
    final activeCids = {
      for (final c in classTermCoursesResult)
        c['course_id'] as String: c['id'] as String
    };

    final List<Map<String, dynamic>> activeAttendanceRows = [];
    final studentList = [ranutId, kimhengId, samornId, rathId, senghakId];

    final Map<String, (String cId, String tId)> dayCourseMap = {
      'Mon': (pyId, khanId),
      'Tue': (mobId, chhaiId),
      'Wed': (cldId, sinId),
      'Thu': (aiId, chenId),
      'Fri': (resId, chanthornId),
    };

    // Start date of active semester: April 1, 2026
    final activeStart = DateTime(2026, 4, 1);
    // End of past weeks: July 5, 2026 (excluding current week starting July 6, 2026)
    final activePastEnd = DateTime(2026, 7, 5);

    for (var date = activeStart; date.isBefore(activePastEnd) || date.isAtSameMomentAs(activePastEnd); date = date.add(const Duration(days: 1))) {
      final weekdayName = switch (date.weekday) {
        1 => 'Mon',
        2 => 'Tue',
        3 => 'Wed',
        4 => 'Thu',
        5 => 'Fri',
        _ => null,
      };
      if (weekdayName == null) continue;

      final courseInfo = dayCourseMap[weekdayName]!;
      final courseId = courseInfo.$1;
      final teacherId = courseInfo.$2;
      final ctcId = activeCids[courseId]!;
      final dateStr = _formatDate(date);

      for (final sId in studentList) {
        String status1 = 'present';
        String status2 = 'present';

        if (sId == ranutId && weekdayName == 'Mon' && date.day % 3 == 0) {
          status2 = 'late';
        }
        if (sId == kimhengId && weekdayName == 'Tue' && date.day % 4 == 0) {
          status1 = 'absent';
          status2 = 'absent';
        }

        // Add Session 1
        activeAttendanceRows.add({
          'student_id': sId,
          'class_term_course_id': ctcId,
          'course_id': courseId,
          'semester_id': semY4S1Id,
          'date': dateStr,
          'session_number': 1,
          'status': status1,
          'marked_by': teacherId,
        });

        // Add Session 2
        activeAttendanceRows.add({
          'student_id': sId,
          'class_term_course_id': ctcId,
          'course_id': courseId,
          'semester_id': semY4S1Id,
          'date': dateStr,
          'session_number': 2,
          'status': status2,
          'marked_by': teacherId,
        });
      }
    }

    if (activeAttendanceRows.isNotEmpty) {
      await supabase.from('attendance').insert(activeAttendanceRows);
    }
    print('  ✓ ${activeAttendanceRows.length} active attendance records successfully seeded');

    // ── 16. Active Grades (Midterm, assignment, participation filled, final exam null)
    print('\n🎓 Seeding active course grades (fill midterm, keep final exam null)...');
    final List<Map<String, dynamic>> activeGrades = [];
    for (final courseId in [pyId, mobId, cldId, aiId, resId]) {
      final ctcId = activeCids[courseId]!;
      for (final sId in studentList) {
        final double mid = 75.0 + (sId.hashCode % 20);
        final double asgn = 80.0 + (sId.hashCode % 15);
        final double part = 85.0 + (sId.hashCode % 10);
        
        activeGrades.add({
          'student_id': sId,
          'class_term_course_id': ctcId,
          'course_id': courseId,
          'semester_id': semY4S1Id,
          'midterm': mid,
          'assignment': asgn,
          'participation': part,
          'final_exam': null, // Keep final exam null
          'total': null,
          'letter_grade': null,
          'gpa_points': null,
        });
      }
    }
    await supabase.from('grades').insert(activeGrades);
    print('  ✓ Active course grades (midterm only) successfully seeded');

    // ── 16.5 Active Assessments ──────────────────────────────────────────────
    print('\n📝 Seeding active course assessments...');
    final List<Map<String, dynamic>> activeAssessments = [];
    for (final entry in activeCids.entries) {
      final ctcId = entry.value;

      activeAssessments.add({
        'class_term_course_id': ctcId,
        'title': 'Homework 1: Fundamentals',
        'type': 'Assignment',
        'max_score': 100.0,
        'due_date': '2026-05-15',
        'description': 'Please complete all exercises in Chapter 1.',
        'file_url': 'https://raw.githubusercontent.com/pdf-association/pdf-test-files/master/content/eng/pdf-a/PDF-A-1b.pdf',
      });
      activeAssessments.add({
        'class_term_course_id': ctcId,
        'title': 'Quiz 1: Progress Check',
        'type': 'Quiz',
        'max_score': 50.0,
        'due_date': '2026-06-10',
        'description': 'A quick check of concepts covered in weeks 1-4.',
      });
      activeAssessments.add({
        'class_term_course_id': ctcId,
        'title': 'Midterm Project Proposal',
        'type': 'Project',
        'max_score': 100.0,
        'due_date': '2026-06-30',
        'description': 'Submit your team project proposal document.',
      });
    }
    await supabase.from('assessments').insert(activeAssessments);
    print('  ✓ Active course assessments successfully seeded');


    // ── 17. Active Leave Requests ───────────────────────────────────────────
    print('\n🏖️  Inserting active leave requests...');
    await supabase.from('leave_requests').insert([
      {
        'requester_id': ranutId,
        'requester_type': 'student',
        'type': 'Sick Leave',
        'reason': 'Fever and flu symptoms',
        'start_date': '2026-04-20',
        'end_date': '2026-04-22',
        'status': 'pending',
      },
      {
        'requester_id': samornId,
        'requester_type': 'student',
        'type': 'Family Leave',
        'reason': 'Family ceremony in Siem Reap',
        'start_date': '2026-05-04',
        'end_date': '2026-05-04',
        'session_number': 1,
        'status': 'approved',
        'reviewed_by': adminId,
        'reviewed_at': '2026-05-02T09:00:00+07:00',
        'review_notes': 'Approved. Take care.',
      },
    ]);
    print('  ✓ 2 active leave requests seeded');

    // ── Summary ─────────────────────────────────────────────────────────────
    print('''

✅ Seeding complete!
   • 11 users  (1 admin · 5 teachers · 5 students)
   • 13 faculties · ${departments.length} departments · ${majors.length} majors
   • 4 academic years (2023-2027) · 8 semesters
   • 17 courses catalog · class SE3 · 7 class terms (6 completed · 1 active)
   • Completed cohort records (Y1-Y3) with historical student grades & attendance
   • Active Year 4 Semester 1 course grades (midterms and assignments filled, finals pending)
   • Active Year 4 Semester 1 past attendance records populated (open current week)

📧 Credentials — password: $kPassword
   admin@beltei.edu.kh
   sokha.khan@beltei.edu.kh · chivon.chhai@beltei.edu.kh · bunthoeurn.sin@beltei.edu.kh
   sovann.chen@beltei.edu.kh · chanthorn@beltei.edu.kh
   hort.ranut@beltei.edu.kh · chhim.kimheng@beltei.edu.kh · mai.samorn@beltei.edu.kh
   samrith.rath@beltei.edu.kh · chhun.senghak@beltei.edu.kh
''');
  } catch (e, st) {
    print('\n❌ Seeding failed: $e');
    print(st);
    exit(1);
  } finally {
    supabase.dispose();
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Future<String> _createUser(
  SupabaseClient supabase, {
  required String email,
  required String firstName,
  required String lastName,
  required String role,
}) async {
  try {
    final res = await supabase.auth.admin.createUser(AdminUserAttributes(
      email: email,
      password: kPassword,
      emailConfirm: true,
      userMetadata: {
        'first_name': firstName,
        'last_name': lastName,
        'role': role
      },
    ));
    final id = res.user!.id;
    print('  + $email  ($id)');
    return id;
  } catch (e) {
    if (e.toString().toLowerCase().contains('already') || 
        e.toString().toLowerCase().contains('exist')) {
      final usersRes = await supabase.auth.admin.listUsers(page: 1, perPage: 1000);
      for (final u in usersRes) {
        if (u.email == email) {
          print('  ~ $email  (already exists: ${u.id})');
          return u.id;
        }
      }
    }
    rethrow;
  }
}

({String url, String serviceKey}) _loadConfig() {
  String envPath = '.env';
  if (!File(envPath).existsSync()) {
    envPath = '../../.env';
  }
  final env = _readEnv(envPath);
  final url = env['SUPABASE_URL'];
  final key = env['SUPABASE_SERVICE_ROLE_KEY'];
  if (url == null || key == null) {
    stderr
        .writeln('❌ Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env');
    exit(1);
  }
  return (url: url, serviceKey: key);
}

Map<String, String> _readEnv(String path) {
  final file = File(path);
  if (!file.existsSync()) return {};
  final result = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final idx = trimmed.indexOf('=');
    if (idx == -1) continue;
    result[trimmed.substring(0, idx).trim()] =
        trimmed.substring(idx + 1).trim();
  }
  return result;
}

String _formatDate(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

Future<void> _waitForAuthService(SupabaseClient supabase) async {
  print('⏳ Waiting for auth service to become healthy...');
  for (int i = 0; i < 60; i++) {
    try {
      await supabase.auth.admin.listUsers(page: 1, perPage: 1);
      print('✅ Auth service is healthy!');
      return;
    } catch (e) {
      print('   [Attempt ${i + 1}/60] Connection status: $e');
      await Future.delayed(const Duration(seconds: 1));
    }
  }
  print('⚠️ Auth service did not become healthy in time.');
}
