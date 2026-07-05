import 'dart:io';
import 'package:supabase/supabase.dart';

const kPassword = 'Beltei@2025';

void main() async {
  final (url: url, serviceKey: key) = _loadConfig();

  print('🌱 Connecting to $url ...');
  final supabase = SupabaseClient(url, key);

  try {
    // Real admins now sign up/get created through the app itself, but the
    // seeder still creates a starter admin plus 5 teachers + 5 students for
    // local/demo environments to have someone to log in as. All 5 students
    // share one evening class term whose curriculum has 5 courses, one per
    // weekday, each taught by its own teacher — this is the scenario that
    // motivated the class/class_term/class_term_course split: one cohort,
    // many courses, many teachers, all under a single enrollment per student.

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
    print('\n🏫 Inserting 13 faculties...');
    final faculties = await supabase.from('faculties').insert([
      {'name': 'Faculty of Business Administration', 'code': 'FBA'},
      {'name': 'Faculty of Finance and Banking', 'code': 'FFB'},
      {'name': 'Faculty of Economics', 'code': 'ECO'},
      {'name': 'Faculty of Law', 'code': 'LAW'},
      {'name': 'Faculty of Education, Arts, and Humanities', 'code': 'FEAH'},
      {'name': 'Faculty of Tourism and Hospitality', 'code': 'FTH'},
      {'name': 'Faculty of Information Technology and Science', 'code': 'FITS'},
      {
        'name': 'Faculty of Digital Technology and Telecommunication',
        'code': 'FDTT'
      },
      {'name': 'Faculty of Engineering', 'code': 'ENG'},
      {'name': 'Faculty of Architecture', 'code': 'ARC'},
      {'name': 'Faculty of International Relations', 'code': 'FIR'},
      {'name': 'Faculty of Civil Aviation', 'code': 'FCA'},
      {'name': 'Faculty of Chinese Language', 'code': 'FCL'},
    ]).select();

    String fid(String code) =>
        faculties.firstWhere((f) => f['code'] == code)['id'] as String;
    final fbaId = fid('FBA');
    final ffbId = fid('FFB');
    final fitsId = fid('FITS');
    final engId = fid('ENG');
    print('  ✓ 13 faculties');

    // ── 4. Departments (hidden organizational layer) ─────────────────────
    print('\n🏢 Inserting departments...');
    final departments = await supabase.from('departments').insert([
      // FBA
      {'faculty_id': fbaId, 'name': 'Management', 'code': 'MGT'},
      {'faculty_id': fbaId, 'name': 'Marketing', 'code': 'MKT'},
      // FFB
      {'faculty_id': ffbId, 'name': 'Finance', 'code': 'FIN'},
      {'faculty_id': ffbId, 'name': 'Banking', 'code': 'BNK'},
      // ECO
      {'faculty_id': fid('ECO'), 'name': 'Economics', 'code': 'ECO'},
      // LAW
      {'faculty_id': fid('LAW'), 'name': 'Law', 'code': 'LAW'},
      // FEAH
      {'faculty_id': fid('FEAH'), 'name': 'Education', 'code': 'EDU'},
      {'faculty_id': fid('FEAH'), 'name': 'Arts & Humanities', 'code': 'ART'},
      // FTH
      {'faculty_id': fid('FTH'), 'name': 'Tourism', 'code': 'TOU'},
      {'faculty_id': fid('FTH'), 'name': 'Hospitality', 'code': 'HOS'},
      // FITS
      {'faculty_id': fitsId, 'name': 'Computer Science', 'code': 'CS'},
      {'faculty_id': fitsId, 'name': 'Network & Security', 'code': 'NET'},
      // FDTT
      {'faculty_id': fid('FDTT'), 'name': 'Digital Technology', 'code': 'DT'},
      {'faculty_id': fid('FDTT'), 'name': 'Telecommunications', 'code': 'TEL'},
      // ENG
      {'faculty_id': engId, 'name': 'Civil Engineering', 'code': 'CE'},
      {'faculty_id': engId, 'name': 'Electrical Engineering', 'code': 'EE'},
      // ARC
      {'faculty_id': fid('ARC'), 'name': 'Architecture', 'code': 'ARC'},
      // FIR
      {
        'faculty_id': fid('FIR'),
        'name': 'International Relations',
        'code': 'IR'
      },
      {'faculty_id': fid('FIR'), 'name': 'Political Science', 'code': 'PS'},
      // FCA
      {'faculty_id': fid('FCA'), 'name': 'Aviation', 'code': 'AVN'},
      // FCL
      {'faculty_id': fid('FCL'), 'name': 'Chinese Studies', 'code': 'CHN'},
    ]).select();

    String did(String code) =>
        departments.firstWhere((d) => d['code'] == code)['id'] as String;
    final csDeptId = did('CS');
    final netDeptId = did('NET');
    final finDeptId = did('FIN');
    final mgtDeptId = did('MGT');
    final mktDeptId = did('MKT');
    print('  ✓ ${departments.length} departments');

    // ── 5. Majors ────────────────────────────────────────────────────────────
    print('\n📖 Inserting majors...');
    final majors = await supabase.from('majors').insert([
      // Management (FBA)
      {'department_id': mgtDeptId, 'name': 'Business Management'},
      {'department_id': mgtDeptId, 'name': 'Entrepreneurship'},
      // Marketing (FBA)
      {'department_id': mktDeptId, 'name': 'Marketing Management'},
      {'department_id': mktDeptId, 'name': 'Digital Marketing'},
      // Finance (FFB)
      {'department_id': finDeptId, 'name': 'Financial Management'},
      {'department_id': finDeptId, 'name': 'Investment & Securities'},
      // Banking (FFB)
      {'department_id': did('BNK'), 'name': 'Banking & Financial Services'},
      {'department_id': did('BNK'), 'name': 'Accounting & Auditing'},
      // Economics
      {'department_id': did('ECO'), 'name': 'General Economics'},
      {'department_id': did('ECO'), 'name': 'Development Economics'},
      // Law
      {'department_id': did('LAW'), 'name': 'Private Law'},
      {'department_id': did('LAW'), 'name': 'Public Law'},
      {'department_id': did('LAW'), 'name': 'Commercial Law'},
      // Education (FEAH)
      {'department_id': did('EDU'), 'name': 'Education Management'},
      {
        'department_id': did('EDU'),
        'name': 'Teaching English as Foreign Language'
      },
      // Arts (FEAH)
      {'department_id': did('ART'), 'name': 'Khmer Literature'},
      {'department_id': did('ART'), 'name': 'English Literature'},
      // Tourism
      {'department_id': did('TOU'), 'name': 'Tourism Management'},
      {'department_id': did('TOU'), 'name': 'Ecotourism'},
      // Hospitality
      {'department_id': did('HOS'), 'name': 'Hotel Management'},
      {'department_id': did('HOS'), 'name': 'Food & Beverage Management'},
      // Computer Science (FITS)
      {'department_id': csDeptId, 'name': 'Software Engineering'},
      {'department_id': csDeptId, 'name': 'Data Science & AI'},
      // Network (FITS)
      {'department_id': netDeptId, 'name': 'Networking & Cybersecurity'},
      {'department_id': netDeptId, 'name': 'Cloud Computing'},
      // Digital Technology (FDTT)
      {'department_id': did('DT'), 'name': 'Digital Media'},
      {'department_id': did('DT'), 'name': 'Mobile Application Development'},
      // Telecommunications (FDTT)
      {'department_id': did('TEL'), 'name': 'Telecommunication Engineering'},
      {'department_id': did('TEL'), 'name': 'Internet of Things'},
      // Civil Engineering (ENG)
      {'department_id': did('CE'), 'name': 'Civil Engineering'},
      {'department_id': did('CE'), 'name': 'Construction Management'},
      // Electrical Engineering (ENG)
      {'department_id': did('EE'), 'name': 'Electrical Engineering'},
      {'department_id': did('EE'), 'name': 'Mechanical Engineering'},
      // Architecture
      {'department_id': did('ARC'), 'name': 'Architecture'},
      {'department_id': did('ARC'), 'name': 'Interior Design'},
      // International Relations
      {'department_id': did('IR'), 'name': 'International Relations'},
      {'department_id': did('IR'), 'name': 'Diplomacy & Foreign Affairs'},
      // Political Science
      {'department_id': did('PS'), 'name': 'Political Science'},
      {'department_id': did('PS'), 'name': 'Public Administration'},
      // Aviation
      {'department_id': did('AVN'), 'name': 'Air Transportation Management'},
      {'department_id': did('AVN'), 'name': 'Aircraft Maintenance'},
      // Chinese Studies
      {'department_id': did('CHN'), 'name': 'Chinese Language & Literature'},
      {'department_id': did('CHN'), 'name': 'Chinese Business Communication'},
    ]).select();

    String mid(String name) =>
        majors.firstWhere((m) => m['name'] == name)['id'] as String;
    final seId = mid('Software Engineering');
    print('  ✓ ${majors.length} majors');

    // ── 6. Academic Years ───────────────────────────────────────────────────
    print('\n🗓️  Inserting academic years...');
    await supabase.from('academic_years').insert([
      {
        'name': '2025-2026',
        'start_date': '2025-09-01',
        'end_date': '2026-06-30',
        'is_current': true,
      },
      {
        'name': '2024-2025',
        'start_date': '2024-09-01',
        'end_date': '2025-06-30',
        'is_current': false,
      },
    ]);
    print('  ✓ 2 academic years');

    // ── 7. Semesters ────────────────────────────────────────────────────────
    print('\n📅 Inserting semesters...');
    final semesters = await supabase.from('semesters').insert([
      {
        'name': 'Semester 1',
        'academic_year': '2025-2026',
        'start_date': '2025-09-01',
        'end_date': '2025-12-31',
        'is_current': true,
      },
      {
        'name': 'Semester 2',
        'academic_year': '2024-2025',
        'start_date': '2025-02-01',
        'end_date': '2025-06-30',
        'is_current': false,
      },
    ]).select();

    final sem1Id = semesters
        .firstWhere((s) => s['academic_year'] == '2025-2026')['id'] as String;
    final sem2Id = semesters
        .firstWhere((s) => s['academic_year'] == '2024-2025')['id'] as String;
    print('  ✓ 2 semesters');

    // ── 8. Teachers ─────────────────────────────────────────────────────────
    // One teacher per course — each teaches their own weekday evening slot.
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

    // ── 9. Students (major_id instead of department_id) ──────────────────
    // All 5 share one evening class term (see section 10c).
    print('\n👨‍🎓 Inserting student records...');
    await supabase.from('students').insert([
      {
        'id': ranutId,
        'student_code': 'STU-2501',
        'faculty_id': fitsId,
        'major_id': seId,
        'enrollment_year': 2025,
        'year_level': 1,
        'status': 'active',
        'date_of_birth': '2004-06-10',
        'gender': 'female',
        'address': 'Phnom Penh',
        'emergency_contact': '099 123 456',
      },
      {
        'id': kimhengId,
        'student_code': 'STU-2502',
        'faculty_id': fitsId,
        'major_id': seId,
        'enrollment_year': 2025,
        'year_level': 1,
        'status': 'active',
        'date_of_birth': '2004-11-02',
        'gender': 'male',
        'address': 'Phnom Penh',
        'emergency_contact': '099 234 567',
      },
      {
        'id': samornId,
        'student_code': 'STU-2503',
        'faculty_id': fitsId,
        'major_id': seId,
        'enrollment_year': 2025,
        'year_level': 1,
        'status': 'active',
        'date_of_birth': '2005-01-18',
        'gender': 'female',
        'address': 'Battambang',
        'emergency_contact': '099 345 678',
      },
      {
        'id': rathId,
        'student_code': 'STU-2504',
        'faculty_id': fitsId,
        'major_id': seId,
        'enrollment_year': 2025,
        'year_level': 1,
        'status': 'active',
        'date_of_birth': '2005-09-20',
        'gender': 'male',
        'address': 'Siem Reap',
        'emergency_contact': '097 654 321',
      },
      {
        'id': senghakId,
        'student_code': 'STU-2505',
        'faculty_id': fitsId,
        'major_id': seId,
        'enrollment_year': 2025,
        'year_level': 1,
        'status': 'active',
        'date_of_birth': '2005-03-25',
        'gender': 'male',
        'address': 'Kandal',
        'emergency_contact': '097 765 432',
      },
    ]);
    print('  ✓ 5 students');

    // ── 10. Courses ──────────────────────────────────────────────────────────
    // Pure catalog now — no teacher/semester/capacity here. Those live on
    // classes/class_terms/class_term_courses below, since the same course can
    // be taught to different cohorts by different teachers at different times.
    print('\n📚 Inserting courses...');
    final courses = await supabase.from('courses').insert([
      {
        'code': 'PY101',
        'name': 'Python Programming',
        'credits': 3,
        'faculty_id': fitsId,
        'department_id': csDeptId,
        'major_id': seId,
        'description': 'Python syntax, data structures, and scripting fundamentals.',
        'status': 'active',
      },
      {
        'code': 'MOB101',
        'name': 'Mobile App Development',
        'credits': 3,
        'faculty_id': fitsId,
        'department_id': csDeptId,
        'major_id': seId,
        'description': 'Building cross-platform mobile applications.',
        'status': 'active',
      },
      {
        'code': 'CLD101',
        'name': 'Cloud Computing',
        'credits': 3,
        'faculty_id': fitsId,
        'department_id': netDeptId,
        'major_id': seId,
        'description': 'Cloud service models, deployment, and infrastructure basics.',
        'status': 'active',
      },
      {
        'code': 'AI101',
        'name': 'Artificial Intelligence',
        'credits': 3,
        'faculty_id': fitsId,
        'department_id': csDeptId,
        'major_id': seId,
        'description': 'Search, knowledge representation, and machine learning foundations.',
        'status': 'active',
      },
      {
        'code': 'RES101',
        'name': 'Research Methodology',
        'credits': 3,
        'faculty_id': fitsId,
        'department_id': csDeptId,
        'major_id': seId,
        'description': 'Research design, data collection, and academic writing.',
        'status': 'active',
      },
    ]).select();

    String cid(String code) =>
        courses.firstWhere((c) => c['code'] == code)['id'] as String;
    final pyId = cid('PY101');
    final mobId = cid('MOB101');
    final cldId = cid('CLD101');
    final aiId = cid('AI101');
    final resId = cid('RES101');
    print('  ✓ ${courses.length} courses');

    // ── 10b. Classes ─────────────────────────────────────────────────────────
    // One evening cohort — all 5 students share this single class, which
    // persists across years as a stable identity.
    print('\n🏫 Inserting classes...');
    final classes = await supabase.from('classes').insert([
      {
        'class_code': 'EVENING-2025-A',
        'faculty_id': fitsId,
        'major_id': seId,
        'program_type': 'national',
        'status': 'active',
      },
    ]).select();

    final classId = classes.first['id'] as String;
    print('  ✓ ${classes.length} class');

    // ── 10c. Class terms ─────────────────────────────────────────────────────
    // This class's offering for the current semester — evening shift, weekday
    // schedule (Mon-Fri), one course per day.
    print('\n🗂️  Inserting class term...');
    final classTerms = await supabase.from('class_terms').insert([
      {
        'class_id': classId,
        'semester_id': sem1Id,
        'year_level': 1,
        'schedule_type': 'weekday',
        'shift': 'evening',
        'room': 'E101',
        'max_students': 30,
        'status': 'active',
      },
    ]).select();

    final termId = classTerms.first['id'] as String;
    print('  ✓ ${classTerms.length} class term');

    // ── 10d. Class term courses (the curriculum) ────────────────────────────
    // Each weekday is dedicated to one course, split into two sessions with
    // a 20-minute break — everyone in the evening class takes all 5 courses,
    // each with its own teacher.
    print('\n📖 Inserting class term courses...');
    await supabase.from('class_term_courses').insert([
      {
        'class_term_id': termId,
        'course_id': pyId,
        'teacher_id': khanId,
        'status': 'active',
        'schedule': [
          {'day': 'Mon', 'start': '17:30', 'end': '19:00', 'room': 'E101'},
          {'day': 'Mon', 'start': '19:20', 'end': '20:30', 'room': 'E101'},
        ],
      },
      {
        'class_term_id': termId,
        'course_id': mobId,
        'teacher_id': chhaiId,
        'status': 'active',
        'schedule': [
          {'day': 'Tue', 'start': '17:30', 'end': '19:00', 'room': 'E101'},
          {'day': 'Tue', 'start': '19:20', 'end': '20:30', 'room': 'E101'},
        ],
      },
      {
        'class_term_id': termId,
        'course_id': cldId,
        'teacher_id': sinId,
        'status': 'active',
        'schedule': [
          {'day': 'Wed', 'start': '17:30', 'end': '19:00', 'room': 'E101'},
          {'day': 'Wed', 'start': '19:20', 'end': '20:30', 'room': 'E101'},
        ],
      },
      {
        'class_term_id': termId,
        'course_id': aiId,
        'teacher_id': chenId,
        'status': 'active',
        'schedule': [
          {'day': 'Thu', 'start': '17:30', 'end': '19:00', 'room': 'E101'},
          {'day': 'Thu', 'start': '19:20', 'end': '20:30', 'room': 'E101'},
        ],
      },
      {
        'class_term_id': termId,
        'course_id': resId,
        'teacher_id': chanthornId,
        'status': 'active',
        'schedule': [
          {'day': 'Fri', 'start': '17:30', 'end': '19:00', 'room': 'Online'},
          {'day': 'Fri', 'start': '19:20', 'end': '20:30', 'room': 'Online'},
        ],
      },
    ]);
    print('  ✓ 5 class term courses');

    // ── 11. Enrollments ─────────────────────────────────────────────────────
    // One row per student for the evening class term — enrolling once gets
    // each student all 5 courses in the curriculum automatically.
    print('\n📋 Inserting enrollments...');
    await supabase.from('enrollments').insert([
      for (final studentId in [ranutId, kimhengId, samornId, rathId, senghakId])
        {
          'student_id': studentId,
          'class_term_id': termId,
          'status': 'enrolled',
        },
    ]);
    print('  ✓ 5 enrollments');

    /* Disabled: grades, attendance, leave requests, invoices/payments,
       notifications, materials, and announcements all reference the old
       5-course demo dataset (CS101/CS201/CS301/NET101/CS102) and its
       enrollments — left disabled rather than rewritten against the new
       AI/Web Design courses since they're demo-only content, not needed for
       the app to function. Create these through the app's admin/teacher UI
       instead, or rewrite this block by hand if you want richer demo data.

    // ── 12. Grades ──────────────────────────────────────────────────────────
    print('\n🎓 Inserting grades...');
    await supabase.from('grades').insert([
      _grade(nitaId, cs101Id, sem1Id,
          mid: 85,
          fin: 88,
          asgn: 90,
          part: 88,
          total: 87.75,
          letter: 'A',
          gpa: 4.00),
      _grade(nitaId, cs201Id, sem1Id,
          mid: 78,
          fin: 82,
          asgn: 85,
          part: 80,
          total: 81.25,
          letter: 'B+',
          gpa: 3.50,
          remarks: 'Good improvement'),
      _grade(nitaId, cs301Id, sem1Id,
          mid: 92,
          fin: 95,
          asgn: 93,
          part: 90,
          total: 93.25,
          letter: 'A+',
          gpa: 4.00,
          remarks: 'Excellent work'),
      _grade(nitaId, cs102Id, sem2Id,
          mid: 80,
          fin: 85,
          asgn: 88,
          part: 82,
          total: 83.75,
          letter: 'A-',
          gpa: 3.70,
          remarks: 'Completed'),
      _grade(rithId, cs101Id, sem1Id,
          mid: 70,
          fin: 72,
          asgn: 75,
          part: 68,
          total: 71.25,
          letter: 'B',
          gpa: 3.00),
      _grade(rithId, net101Id, sem1Id,
          mid: 80,
          fin: 85,
          asgn: 88,
          part: 82,
          total: 83.75,
          letter: 'A-',
          gpa: 3.70),
    ]);
    print('  ✓ 6 grade records');

    // ── 13. Attendance ──────────────────────────────────────────────────────
    print('\n📆 Inserting attendance...');
    final List<Map<String, dynamic>> attendanceRows = [];

    for (final date in [
      '2025-09-08',
      '2025-09-15',
      '2025-09-22',
      '2025-09-29',
      '2025-10-06'
    ]) {
      attendanceRows.add(_att(nitaId, cs101Id, date, 'present', sokhaId));
      attendanceRows.add(_att(
          rithId,
          cs101Id,
          date,
          date == '2025-09-29' ? 'absent' : 'present',
          sokhaId,
          date == '2025-09-29' ? 'Absent without notice' : null));
    }
    for (final date in ['2025-09-10', '2025-09-17', '2025-09-24']) {
      attendanceRows.add(_att(rithId, net101Id, date, 'present', daraId));
    }

    await supabase.from('attendance').insert(attendanceRows);
    print('  ✓ ${attendanceRows.length} attendance records');

    // ── 14. Leave requests ──────────────────────────────────────────────────
    print('\n🏖️  Inserting leave requests...');
    await supabase.from('leave_requests').insert([
      {
        'requester_id': nitaId,
        'requester_type': 'student',
        'type': 'Sick Leave',
        'reason': 'Fever and flu symptoms',
        'start_date': '2025-10-01',
        'end_date': '2025-10-03',
        'status': 'pending',
      },
      {
        'requester_id': rithId,
        'requester_type': 'student',
        'type': 'Family Leave',
        'reason': 'Family ceremony in Siem Reap',
        'start_date': '2025-10-15',
        'end_date': '2025-10-16',
        'status': 'approved',
        'reviewed_by': adminId,
        'reviewed_at': '2025-10-10T09:00:00+07:00',
        'review_notes': 'Approved. Please catch up on missed materials.',
      },
      {
        'requester_id': sokhaId,
        'requester_type': 'teacher',
        'type': 'Conference',
        'reason': 'Attending ASEAN Tech Education Summit in Bangkok',
        'start_date': '2025-11-10',
        'end_date': '2025-11-12',
        'status': 'pending',
      },
      {
        // Nita's class term (BATCH-2025-A) has two sessions on Monday (AI101
        // at 08:00, WD101 at 10:00) — this leave only covers the first one,
        // demonstrating session_number instead of a full-day leave.
        'requester_id': nitaId,
        'requester_type': 'student',
        'type': 'Personal',
        'reason': 'Morning doctor appointment',
        'start_date': '2025-10-06',
        'end_date': '2025-10-06',
        'session_number': 1,
        'status': 'pending',
      },
    ]);
    print('  ✓ 4 leave requests');

    // ── 15. Invoices & payments ─────────────────────────────────────────────
    print('\n💰 Inserting invoices & payments...');
    final invoices = await supabase.from('invoices').insert([
      {
        'student_id': nitaId,
        'semester_id': sem1Id,
        'description': 'Tuition Fee — Semester 1, 2025–2026',
        'amount': 450.00,
        'due_date': '2025-09-30',
        'status': 'paid',
        'paid_at': '2025-09-05T08:30:00+07:00'
      },
      {
        'student_id': rithId,
        'semester_id': sem1Id,
        'description': 'Tuition Fee — Semester 1, 2025–2026',
        'amount': 450.00,
        'due_date': '2025-09-30',
        'status': 'overdue'
      },
    ]).select();

    final nitaInvId =
        invoices.firstWhere((i) => i['student_id'] == nitaId)['id'] as String;

    await supabase.from('payments').insert([
      {
        'invoice_id': nitaInvId,
        'student_id': nitaId,
        'amount': 450.00,
        'payment_method': 'Bank Transfer',
        'reference_number': 'TXN-20250905-001',
        'verified_by': adminId,
        'notes': 'Full payment received'
      },
    ]);
    print('  ✓ 2 invoices, 1 payment');

    // ── 16. Notifications ───────────────────────────────────────────────────
    print('\n🔔 Inserting notifications...');
    await supabase.from('notifications').insert([
      {
        'user_id': nitaId,
        'title': 'Grade Posted',
        'body': 'Your grade for Data Structures & Algorithms has been posted.',
        'type': 'grade',
        'is_read': false
      },
      {
        'user_id': nitaId,
        'title': 'Tuition Fee Paid',
        'body': 'Your Semester 1 tuition payment of \$450 has been confirmed.',
        'type': 'finance',
        'is_read': true
      },
      {
        'user_id': rithId,
        'title': 'Leave Request Approved',
        'body': 'Your leave request for Oct 15–16 has been approved.',
        'type': 'leave',
        'is_read': true
      },
      {
        'user_id': rithId,
        'title': 'Tuition Fee Overdue',
        'body':
            'Your Semester 1 tuition fee is overdue. Please pay immediately.',
        'type': 'finance',
        'is_read': false
      },
      {
        'user_id': adminId,
        'title': 'New Student Leave Request',
        'body': 'Nita Lim submitted a sick leave request (Oct 1–3).',
        'type': 'leave',
        'is_read': false
      },
      {
        'user_id': adminId,
        'title': 'Teacher Leave Request',
        'body': 'Sokha Chan requested leave for ASEAN Tech Summit (Nov 10–12).',
        'type': 'leave',
        'is_read': false
      },
    ]);
    print('  ✓ 6 notifications');

    // ── 17. Course materials ────────────────────────────────────────────────
    print('\n📄 Inserting course materials...');
    await supabase.from('course_materials').insert([
      {
        'course_id': cs101Id,
        'teacher_id': sokhaId,
        'title': 'Lecture 1: Introduction to Programming',
        'description': 'Overview of programming concepts and Dart basics.',
        'file_url': 'https://files.beltei.edu.kh/cs101/lecture1.pdf',
        'file_type': 'pdf',
        'file_size': 2048
      },
      {
        'course_id': cs101Id,
        'teacher_id': sokhaId,
        'title': 'Lab Exercise 1: Hello World',
        'description': 'Your first Dart program — basic I/O and variables.',
        'file_url': 'https://files.beltei.edu.kh/cs101/lab1.zip',
        'file_type': 'zip',
        'file_size': 512
      },
      {
        'course_id': cs201Id,
        'teacher_id': sokhaId,
        'title': 'Chapter 1: Arrays and Lists',
        'description': 'Array operations, dynamic lists, and complexity.',
        'file_url': 'https://files.beltei.edu.kh/cs201/chapter1.pdf',
        'file_type': 'pdf',
        'file_size': 3072
      },
      {
        'course_id': net101Id,
        'teacher_id': daraId,
        'title': 'Network Fundamentals Slides',
        'description': 'OSI model, TCP/IP stack, and IP addressing.',
        'file_url': 'https://files.beltei.edu.kh/net101/slides1.pptx',
        'file_type': 'pptx',
        'file_size': 5120
      },
    ]);
    print('  ✓ 4 course materials');

    // ── 18. Announcements ───────────────────────────────────────────────────
    print('\n📢 Inserting announcements...');
    await supabase.from('announcements').insert([
      {
        'teacher_id': sokhaId,
        'course_id': cs101Id,
        'title': 'Welcome to Introduction to Programming',
        'body':
            'Welcome! Please install Flutter SDK and VS Code before next class. Syllabus is in Course Materials.',
        'is_pinned': true
      },
      {
        'teacher_id': sokhaId,
        'course_id': cs201Id,
        'title': 'Midterm Exam Schedule',
        'body':
            'Midterm: October 20, 2025 — 09:00–11:00, Room A102. Topics: Arrays, Linked Lists, Stacks.',
        'is_pinned': true
      },
      {
        'teacher_id': daraId,
        'course_id': net101Id,
        'title': 'Lab Assignment 1 Due',
        'body':
            'Lab 1 (IP Addressing & Subnetting) is due September 30, 2025. Submit via the student portal.',
        'is_pinned': false
      },
      {
        'teacher_id': sokhaId,
        'course_id': cs301Id,
        'title': 'Semester Project — Team Formation',
        'body':
            'Form teams of 3 for the semester project by next Monday. Email your team names to sokha@beltei.edu.kh.',
        'is_pinned': false
      },
    ]);
    print('  ✓ 4 announcements');
    */

    // ── Summary ─────────────────────────────────────────────────────────────
    print('''

✅ Seeding complete!
   • 11 users  (1 admin · 5 teachers · 5 students)
   • 13 faculties · ${departments.length} departments · ${majors.length} majors
   • 2 academic years · 2 semesters
   • ${courses.length} courses · ${classes.length} class · ${classTerms.length} class term · 5 enrollments
   • Evening class (Mon-Fri, one course/day, 2 sessions/day, 20min break)

   (Grades, attendance, leave requests, invoices, notifications, materials,
   and announcements are disabled — create those through the app instead.)

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
}

Map<String, dynamic> _grade(
  String studentId,
  String courseId,
  String semesterId, {
  required double mid,
  required double fin,
  required double asgn,
  required double part,
  required double total,
  required String letter,
  required double gpa,
  String? remarks,
}) =>
    {
      'student_id': studentId,
      'course_id': courseId,
      'semester_id': semesterId,
      'midterm': mid,
      'final_exam': fin,
      'assignment': asgn,
      'participation': part,
      'total': total,
      'letter_grade': letter,
      'gpa_points': gpa,
      if (remarks != null) 'remarks': remarks,
    };

Map<String, dynamic> _att(
  String studentId,
  String courseId,
  String date,
  String status,
  String markedBy, [
  String? notes,
]) =>
    {
      'student_id': studentId,
      'course_id': courseId,
      'date': date,
      'status': status,
      'marked_by': markedBy,
      if (notes != null) 'notes': notes,
    };

({String url, String serviceKey}) _loadConfig() {
  final env = _readEnv('../../.env');
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
