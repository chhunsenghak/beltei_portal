import 'dart:io';
import 'package:supabase/supabase.dart';

const kPassword = 'Beltei@2025';

void main() async {
  final (url: url, serviceKey: key) = _loadConfig();

  print('🌱 Connecting to $url ...');
  final supabase = SupabaseClient(url, key);

  try {
    // ── 1. Auth users ───────────────────────────────────────────────────────
    print('\n👤 Creating auth users...');

    final adminId = await _createUser(supabase,
        email: 'admin@beltei.edu.kh',
        firstName: 'Sopheap',
        lastName: 'Meas',
        role: 'admin');

    final sokhaId = await _createUser(supabase,
        email: 'sokha@beltei.edu.kh',
        firstName: 'Sokha',
        lastName: 'Chan',
        role: 'teacher');
    final daraId = await _createUser(supabase,
        email: 'dara@beltei.edu.kh',
        firstName: 'Dara',
        lastName: 'Kem',
        role: 'teacher');
    final chandaId = await _createUser(supabase,
        email: 'chanda@beltei.edu.kh',
        firstName: 'Chanda',
        lastName: 'Prum',
        role: 'teacher');

    final minaId = await _createUser(supabase,
        email: 'mina@beltei.edu.kh',
        firstName: 'Mina',
        lastName: 'Sok',
        role: 'student');
    final rithId = await _createUser(supabase,
        email: 'rith@beltei.edu.kh',
        firstName: 'Rith',
        lastName: 'Heng',
        role: 'student');
    final bophaId = await _createUser(supabase,
        email: 'bopha@beltei.edu.kh',
        firstName: 'Bopha',
        lastName: 'Lim',
        role: 'student');
    final vicheaId = await _createUser(supabase,
        email: 'vichea@beltei.edu.kh',
        firstName: 'Vichea',
        lastName: 'Tan',
        role: 'student');
    final sreymomId = await _createUser(supabase,
        email: 'sreymom@beltei.edu.kh',
        firstName: 'Sreymom',
        lastName: 'Ouk',
        role: 'student');
    final pisethId = await _createUser(supabase,
        email: 'piseth@beltei.edu.kh',
        firstName: 'Piseth',
        lastName: 'Neak',
        role: 'student');

    print('  ✓ 10 users created');

    // ── 2. Update profiles with phone numbers ───────────────────────────────
    print('\n📝 Updating profiles...');
    final phones = {
      adminId:   '012 345 678',
      sokhaId:   '012 111 222',
      daraId:    '012 333 444',
      chandaId:  '012 555 666',
      minaId:    '096 100 001',
      rithId:    '096 100 002',
      bophaId:   '096 100 003',
      vicheaId:  '096 100 004',
      sreymomId: '096 100 005',
      pisethId:  '096 100 006',
    };
    for (final e in phones.entries) {
      await supabase.from('profiles').update({'phone': e.value}).eq('id', e.key);
    }
    print('  ✓ Phone numbers added');

    // ── 3. Faculties ────────────────────────────────────────────────────────
    print('\n🏫 Inserting 13 faculties...');
    final faculties = await supabase.from('faculties').insert([
      {'name': 'Faculty of Business Administration',           'code': 'FBA'},
      {'name': 'Faculty of Finance and Banking',               'code': 'FFB'},
      {'name': 'Faculty of Economics',                         'code': 'ECO'},
      {'name': 'Faculty of Law',                               'code': 'LAW'},
      {'name': 'Faculty of Education, Arts, and Humanities',   'code': 'FEAH'},
      {'name': 'Faculty of Tourism and Hospitality',           'code': 'FTH'},
      {'name': 'Faculty of Information Technology and Science','code': 'FITS'},
      {'name': 'Faculty of Digital Technology and Telecommunication', 'code': 'FDTT'},
      {'name': 'Faculty of Engineering',                       'code': 'ENG'},
      {'name': 'Faculty of Architecture',                      'code': 'ARC'},
      {'name': 'Faculty of International Relations',           'code': 'FIR'},
      {'name': 'Faculty of Civil Aviation',                    'code': 'FCA'},
      {'name': 'Faculty of Chinese Language',                  'code': 'FCL'},
    ]).select();

    String fid(String code) => faculties.firstWhere((f) => f['code'] == code)['id'] as String;
    final fbaId  = fid('FBA');
    final ffbId  = fid('FFB');
    final fitsId = fid('FITS');
    final engId  = fid('ENG');
    print('  ✓ 13 faculties');

    // ── 4. Departments (hidden organizational layer) ─────────────────────
    print('\n🏢 Inserting departments...');
    final departments = await supabase.from('departments').insert([
      // FBA
      {'faculty_id': fbaId,  'name': 'Management',          'code': 'MGT'},
      {'faculty_id': fbaId,  'name': 'Marketing',           'code': 'MKT'},
      // FFB
      {'faculty_id': ffbId,  'name': 'Finance',             'code': 'FIN'},
      {'faculty_id': ffbId,  'name': 'Banking',             'code': 'BNK'},
      // ECO
      {'faculty_id': fid('ECO'), 'name': 'Economics',       'code': 'ECO'},
      // LAW
      {'faculty_id': fid('LAW'), 'name': 'Law',             'code': 'LAW'},
      // FEAH
      {'faculty_id': fid('FEAH'), 'name': 'Education',      'code': 'EDU'},
      {'faculty_id': fid('FEAH'), 'name': 'Arts & Humanities', 'code': 'ART'},
      // FTH
      {'faculty_id': fid('FTH'), 'name': 'Tourism',         'code': 'TOU'},
      {'faculty_id': fid('FTH'), 'name': 'Hospitality',     'code': 'HOS'},
      // FITS
      {'faculty_id': fitsId, 'name': 'Computer Science',    'code': 'CS'},
      {'faculty_id': fitsId, 'name': 'Network & Security',  'code': 'NET'},
      // FDTT
      {'faculty_id': fid('FDTT'), 'name': 'Digital Technology',    'code': 'DT'},
      {'faculty_id': fid('FDTT'), 'name': 'Telecommunications',    'code': 'TEL'},
      // ENG
      {'faculty_id': engId,  'name': 'Civil Engineering',   'code': 'CE'},
      {'faculty_id': engId,  'name': 'Electrical Engineering', 'code': 'EE'},
      // ARC
      {'faculty_id': fid('ARC'), 'name': 'Architecture',    'code': 'ARC'},
      // FIR
      {'faculty_id': fid('FIR'), 'name': 'International Relations', 'code': 'IR'},
      {'faculty_id': fid('FIR'), 'name': 'Political Science',       'code': 'PS'},
      // FCA
      {'faculty_id': fid('FCA'), 'name': 'Aviation',        'code': 'AVN'},
      // FCL
      {'faculty_id': fid('FCL'), 'name': 'Chinese Studies', 'code': 'CHN'},
    ]).select();

    String did(String code) => departments.firstWhere((d) => d['code'] == code)['id'] as String;
    final csDeptId  = did('CS');
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
      {'department_id': did('EDU'), 'name': 'Teaching English as Foreign Language'},
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
      {'department_id': csDeptId,  'name': 'Software Engineering'},
      {'department_id': csDeptId,  'name': 'Data Science & AI'},
      // Network (FITS)
      {'department_id': netDeptId, 'name': 'Networking & Cybersecurity'},
      {'department_id': netDeptId, 'name': 'Cloud Computing'},
      // Digital Technology (FDTT)
      {'department_id': did('DT'),  'name': 'Digital Media'},
      {'department_id': did('DT'),  'name': 'Mobile Application Development'},
      // Telecommunications (FDTT)
      {'department_id': did('TEL'), 'name': 'Telecommunication Engineering'},
      {'department_id': did('TEL'), 'name': 'Internet of Things'},
      // Civil Engineering (ENG)
      {'department_id': did('CE'),  'name': 'Civil Engineering'},
      {'department_id': did('CE'),  'name': 'Construction Management'},
      // Electrical Engineering (ENG)
      {'department_id': did('EE'),  'name': 'Electrical Engineering'},
      {'department_id': did('EE'),  'name': 'Mechanical Engineering'},
      // Architecture
      {'department_id': did('ARC'), 'name': 'Architecture'},
      {'department_id': did('ARC'), 'name': 'Interior Design'},
      // International Relations
      {'department_id': did('IR'),  'name': 'International Relations'},
      {'department_id': did('IR'),  'name': 'Diplomacy & Foreign Affairs'},
      // Political Science
      {'department_id': did('PS'),  'name': 'Political Science'},
      {'department_id': did('PS'),  'name': 'Public Administration'},
      // Aviation
      {'department_id': did('AVN'), 'name': 'Air Transportation Management'},
      {'department_id': did('AVN'), 'name': 'Aircraft Maintenance'},
      // Chinese Studies
      {'department_id': did('CHN'), 'name': 'Chinese Language & Literature'},
      {'department_id': did('CHN'), 'name': 'Chinese Business Communication'},
    ]).select();

    String mid(String name) => majors.firstWhere((m) => m['name'] == name)['id'] as String;
    final seId  = mid('Software Engineering');
    final netSecId = mid('Networking & Cybersecurity');
    final finMgmtId = mid('Financial Management');
    final mktMgmtId = mid('Marketing Management');
    final busMgmtId = mid('Business Management');
    final dataSciId = mid('Data Science & AI');
    print('  ✓ ${majors.length} majors');

    // ── 6. Semesters ────────────────────────────────────────────────────────
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

    final sem1Id = semesters.firstWhere((s) => s['academic_year'] == '2025-2026')['id'] as String;
    final sem2Id = semesters.firstWhere((s) => s['academic_year'] == '2024-2025')['id'] as String;
    print('  ✓ 2 semesters');

    // ── 7. Teachers ─────────────────────────────────────────────────────────
    print('\n👨‍🏫 Inserting teacher records...');
    await supabase.from('teachers').insert([
      {
        'id': sokhaId,
        'employee_code': 'EMP-1001',
        'department_id': csDeptId,
        'position': 'Senior Lecturer',
        'specialization': 'Software Engineering',
        'hire_date': '2022-01-15',
        'status': 'active',
      },
      {
        'id': daraId,
        'employee_code': 'EMP-1002',
        'department_id': netDeptId,
        'position': 'Lecturer',
        'specialization': 'Networking & Security',
        'hire_date': '2020-06-01',
        'status': 'active',
      },
      {
        'id': chandaId,
        'employee_code': 'EMP-1003',
        'department_id': finDeptId,
        'position': 'Associate Professor',
        'specialization': 'Financial Accounting',
        'hire_date': '2019-03-10',
        'status': 'active',
      },
    ]);
    print('  ✓ 3 teachers');

    // ── 8. Students (major_id instead of department_id) ──────────────────
    print('\n👨‍🎓 Inserting student records...');
    await supabase.from('students').insert([
      {
        'id': minaId,
        'student_code': 'STU-2301',
        'faculty_id': fitsId,
        'major_id': seId,
        'enrollment_year': 2023,
        'year_level': 2,
        'status': 'active',
        'date_of_birth': '2004-06-10',
        'gender': 'female',
        'address': 'Phnom Penh',
        'emergency_contact': '099 123 456',
      },
      {
        'id': rithId,
        'student_code': 'STU-2401',
        'faculty_id': fitsId,
        'major_id': netSecId,
        'enrollment_year': 2024,
        'year_level': 1,
        'status': 'active',
        'date_of_birth': '2005-09-20',
        'gender': 'male',
        'address': 'Siem Reap',
        'emergency_contact': '097 654 321',
      },
      {
        'id': bophaId,
        'student_code': 'STU-2302',
        'faculty_id': ffbId,
        'major_id': finMgmtId,
        'enrollment_year': 2023,
        'year_level': 2,
        'status': 'active',
        'date_of_birth': '2003-12-05',
        'gender': 'female',
        'address': 'Battambang',
        'emergency_contact': '098 111 222',
      },
      {
        'id': vicheaId,
        'student_code': 'STU-2402',
        'faculty_id': fitsId,
        'major_id': dataSciId,
        'enrollment_year': 2024,
        'year_level': 1,
        'status': 'active',
        'date_of_birth': '2005-03-17',
        'gender': 'male',
        'address': 'Kandal',
        'emergency_contact': '096 333 444',
      },
      {
        'id': sreymomId,
        'student_code': 'STU-2201',
        'faculty_id': fbaId,
        'major_id': mktMgmtId,
        'enrollment_year': 2022,
        'year_level': 3,
        'status': 'active',
        'date_of_birth': '2003-07-25',
        'gender': 'female',
        'address': 'Phnom Penh',
        'emergency_contact': '095 555 666',
      },
      {
        'id': pisethId,
        'student_code': 'STU-2303',
        'faculty_id': fbaId,
        'major_id': busMgmtId,
        'enrollment_year': 2023,
        'year_level': 2,
        'status': 'active',
        'date_of_birth': '2004-01-08',
        'gender': 'male',
        'address': 'Phnom Penh',
        'emergency_contact': '094 777 888',
      },
    ]);
    print('  ✓ 6 students');

    // ── 9. Courses ──────────────────────────────────────────────────────────
    print('\n📚 Inserting courses...');
    final courses = await supabase.from('courses').insert([
      {
        'code': 'CS101',
        'name': 'Introduction to Programming',
        'credits': 3,
        'teacher_id': sokhaId,
        'semester_id': sem1Id,
        'faculty_id': fitsId,
        'department_id': csDeptId,
        'max_students': 40,
        'schedule': [
          {'day': 'Mon', 'start': '08:00', 'end': '09:30', 'room': 'A101'},
          {'day': 'Wed', 'start': '08:00', 'end': '09:30', 'room': 'A101'},
        ],
        'description': 'Foundational programming concepts using Dart.',
        'status': 'active',
      },
      {
        'code': 'CS201',
        'name': 'Data Structures & Algorithms',
        'credits': 3,
        'teacher_id': sokhaId,
        'semester_id': sem1Id,
        'faculty_id': fitsId,
        'department_id': csDeptId,
        'max_students': 35,
        'schedule': [
          {'day': 'Tue', 'start': '10:00', 'end': '11:30', 'room': 'A102'},
          {'day': 'Thu', 'start': '10:00', 'end': '11:30', 'room': 'A102'},
        ],
        'description': 'Arrays, linked lists, trees, and sorting algorithms.',
        'status': 'active',
      },
      {
        'code': 'CS301',
        'name': 'Web Development',
        'credits': 3,
        'teacher_id': sokhaId,
        'semester_id': sem1Id,
        'faculty_id': fitsId,
        'department_id': csDeptId,
        'max_students': 30,
        'schedule': [
          {'day': 'Thu', 'start': '13:00', 'end': '14:30', 'room': 'Lab1'},
        ],
        'description': 'HTML, CSS, JavaScript and modern web frameworks.',
        'status': 'active',
      },
      {
        'code': 'NET101',
        'name': 'Computer Networks',
        'credits': 3,
        'teacher_id': daraId,
        'semester_id': sem1Id,
        'faculty_id': fitsId,
        'department_id': netDeptId,
        'max_students': 30,
        'schedule': [
          {'day': 'Mon', 'start': '10:00', 'end': '11:30', 'room': 'B201'},
          {'day': 'Fri', 'start': '08:00', 'end': '09:30', 'room': 'B201'},
        ],
        'description': 'TCP/IP, routing protocols, and network security.',
        'status': 'active',
      },
      {
        'code': 'FIN101',
        'name': 'Principles of Financial Management',
        'credits': 3,
        'teacher_id': chandaId,
        'semester_id': sem1Id,
        'faculty_id': ffbId,
        'department_id': finDeptId,
        'max_students': 45,
        'schedule': [
          {'day': 'Tue', 'start': '08:00', 'end': '09:30', 'room': 'C301'},
          {'day': 'Thu', 'start': '08:00', 'end': '09:30', 'room': 'C301'},
        ],
        'description': 'Financial statements, investment analysis, and corporate finance.',
        'status': 'active',
      },
      {
        'code': 'CS102',
        'name': 'Programming Fundamentals',
        'credits': 3,
        'teacher_id': sokhaId,
        'semester_id': sem2Id,
        'faculty_id': fitsId,
        'department_id': csDeptId,
        'max_students': 40,
        'schedule': [
          {'day': 'Mon', 'start': '08:00', 'end': '09:30', 'room': 'A101'},
        ],
        'description': 'Previous semester intro course (completed).',
        'status': 'inactive',
      },
    ]).select();

    final cs101Id  = courses.firstWhere((c) => c['code'] == 'CS101')['id']  as String;
    final cs201Id  = courses.firstWhere((c) => c['code'] == 'CS201')['id']  as String;
    final cs301Id  = courses.firstWhere((c) => c['code'] == 'CS301')['id']  as String;
    final net101Id = courses.firstWhere((c) => c['code'] == 'NET101')['id'] as String;
    final fin101Id = courses.firstWhere((c) => c['code'] == 'FIN101')['id'] as String;
    final cs102Id  = courses.firstWhere((c) => c['code'] == 'CS102')['id']  as String;
    print('  ✓ 6 courses');

    // ── 10. Enrollments ─────────────────────────────────────────────────────
    print('\n📋 Inserting enrollments...');
    await supabase.from('enrollments').insert([
      // Mina (SE) — CS101, CS201, CS301 + CS102 past
      {'student_id': minaId, 'course_id': cs101Id, 'semester_id': sem1Id, 'status': 'enrolled'},
      {'student_id': minaId, 'course_id': cs201Id, 'semester_id': sem1Id, 'status': 'enrolled'},
      {'student_id': minaId, 'course_id': cs301Id, 'semester_id': sem1Id, 'status': 'enrolled'},
      {'student_id': minaId, 'course_id': cs102Id, 'semester_id': sem2Id, 'status': 'completed'},
      // Rith (Networking) — CS101, NET101
      {'student_id': rithId,    'course_id': cs101Id,  'semester_id': sem1Id, 'status': 'enrolled'},
      {'student_id': rithId,    'course_id': net101Id, 'semester_id': sem1Id, 'status': 'enrolled'},
      // Bopha (Finance) — FIN101
      {'student_id': bophaId,   'course_id': fin101Id, 'semester_id': sem1Id, 'status': 'enrolled'},
      // Vichea (Data Science) — CS101, CS201
      {'student_id': vicheaId,  'course_id': cs101Id,  'semester_id': sem1Id, 'status': 'enrolled'},
      {'student_id': vicheaId,  'course_id': cs201Id,  'semester_id': sem1Id, 'status': 'enrolled'},
      // Sreymom (Marketing) — FIN101
      {'student_id': sreymomId, 'course_id': fin101Id, 'semester_id': sem1Id, 'status': 'enrolled'},
      // Piseth (Business Mgmt) — CS101, CS201
      {'student_id': pisethId,  'course_id': cs101Id,  'semester_id': sem1Id, 'status': 'enrolled'},
      {'student_id': pisethId,  'course_id': cs201Id,  'semester_id': sem1Id, 'status': 'enrolled'},
    ]);
    print('  ✓ 12 enrollments');

    // ── 11. Grades ──────────────────────────────────────────────────────────
    print('\n🎓 Inserting grades...');
    await supabase.from('grades').insert([
      _grade(minaId, cs101Id, sem1Id, mid: 85, fin: 88, asgn: 90, part: 88, total: 87.75, letter: 'A',  gpa: 4.00),
      _grade(minaId, cs201Id, sem1Id, mid: 78, fin: 82, asgn: 85, part: 80, total: 81.25, letter: 'B+', gpa: 3.50, remarks: 'Good improvement'),
      _grade(minaId, cs301Id, sem1Id, mid: 92, fin: 95, asgn: 93, part: 90, total: 93.25, letter: 'A+', gpa: 4.00, remarks: 'Excellent work'),
      _grade(minaId, cs102Id, sem2Id, mid: 80, fin: 85, asgn: 88, part: 82, total: 83.75, letter: 'A-', gpa: 3.70, remarks: 'Completed'),
      _grade(rithId,    cs101Id,  sem1Id, mid: 70, fin: 72, asgn: 75, part: 68, total: 71.25, letter: 'B',  gpa: 3.00),
      _grade(rithId,    net101Id, sem1Id, mid: 80, fin: 85, asgn: 88, part: 82, total: 83.75, letter: 'A-', gpa: 3.70),
      _grade(bophaId,   fin101Id, sem1Id, mid: 88, fin: 90, asgn: 92, part: 85, total: 89.00, letter: 'A',  gpa: 4.00),
      _grade(vicheaId,  cs101Id,  sem1Id, mid: 65, fin: 70, asgn: 72, part: 68, total: 68.75, letter: 'C+', gpa: 2.30, remarks: 'Needs improvement'),
      _grade(vicheaId,  cs201Id,  sem1Id, mid: 74, fin: 78, asgn: 80, part: 75, total: 76.75, letter: 'B',  gpa: 3.00),
      _grade(sreymomId, fin101Id, sem1Id, mid: 82, fin: 85, asgn: 87, part: 80, total: 83.50, letter: 'A-', gpa: 3.70),
      _grade(pisethId,  cs101Id,  sem1Id, mid: 90, fin: 92, asgn: 94, part: 90, total: 91.50, letter: 'A',  gpa: 4.00, remarks: 'Excellent'),
      _grade(pisethId,  cs201Id,  sem1Id, mid: 86, fin: 88, asgn: 90, part: 85, total: 87.25, letter: 'A',  gpa: 4.00),
    ]);
    print('  ✓ 12 grade records');

    // ── 12. Attendance ──────────────────────────────────────────────────────
    print('\n📆 Inserting attendance...');
    final List<Map<String, dynamic>> attendanceRows = [];

    for (final date in ['2025-09-08', '2025-09-15', '2025-09-22', '2025-09-29', '2025-10-06']) {
      attendanceRows.add(_att(minaId,   cs101Id, date, 'present', sokhaId));
      attendanceRows.add(_att(pisethId, cs101Id, date, 'present', sokhaId));
      attendanceRows.add(_att(rithId,   cs101Id, date,
          date == '2025-09-29' ? 'absent' : 'present', sokhaId,
          date == '2025-09-29' ? 'Absent without notice' : null));
      attendanceRows.add(_att(vicheaId, cs101Id, date,
          date == '2025-09-22' ? 'late' : date == '2025-10-06' ? 'absent' : 'present', sokhaId,
          date == '2025-09-22' ? 'Arrived 20 minutes late' : null));
    }
    for (final date in ['2025-09-10', '2025-09-17', '2025-09-24']) {
      attendanceRows.add(_att(rithId, net101Id, date, 'present', daraId));
    }
    for (final date in ['2025-09-09', '2025-09-16', '2025-09-23', '2025-09-30']) {
      attendanceRows.add(_att(bophaId, fin101Id, date, 'present', chandaId));
      attendanceRows.add(_att(sreymomId, fin101Id, date,
          date == '2025-09-23' ? 'excused' : 'present', chandaId,
          date == '2025-09-23' ? 'Family event approved' : null));
    }

    await supabase.from('attendance').insert(attendanceRows);
    print('  ✓ ${attendanceRows.length} attendance records');

    // ── 13. Leave requests ──────────────────────────────────────────────────
    print('\n🏖️  Inserting leave requests...');
    await supabase.from('leave_requests').insert([
      {
        'requester_id': minaId, 'requester_type': 'student',
        'type': 'Sick Leave', 'reason': 'Fever and flu symptoms',
        'start_date': '2025-10-01', 'end_date': '2025-10-03', 'status': 'pending',
      },
      {
        'requester_id': rithId, 'requester_type': 'student',
        'type': 'Family Leave', 'reason': 'Family ceremony in Siem Reap',
        'start_date': '2025-10-15', 'end_date': '2025-10-16', 'status': 'approved',
        'reviewed_by': adminId, 'reviewed_at': '2025-10-10T09:00:00+07:00',
        'review_notes': 'Approved. Please catch up on missed materials.',
      },
      {
        'requester_id': bophaId, 'requester_type': 'student',
        'type': 'Medical', 'reason': 'Dental appointment',
        'start_date': '2025-09-20', 'end_date': '2025-09-20', 'status': 'approved',
        'reviewed_by': adminId, 'reviewed_at': '2025-09-18T10:00:00+07:00',
        'review_notes': 'Approved.',
      },
      {
        'requester_id': vicheaId, 'requester_type': 'student',
        'type': 'Personal', 'reason': 'National sports competition',
        'start_date': '2025-10-22', 'end_date': '2025-10-24', 'status': 'rejected',
        'reviewed_by': adminId, 'reviewed_at': '2025-10-20T11:00:00+07:00',
        'review_notes': 'Clashes with midterm week.',
      },
      {
        'requester_id': sokhaId, 'requester_type': 'teacher',
        'type': 'Conference', 'reason': 'Attending ASEAN Tech Education Summit in Bangkok',
        'start_date': '2025-11-10', 'end_date': '2025-11-12', 'status': 'pending',
      },
    ]);
    print('  ✓ 5 leave requests');

    // ── 14. Invoices & payments ─────────────────────────────────────────────
    print('\n💰 Inserting invoices & payments...');
    final invoices = await supabase.from('invoices').insert([
      {'student_id': minaId,    'semester_id': sem1Id, 'description': 'Tuition Fee — Semester 1, 2025–2026', 'amount': 450.00, 'due_date': '2025-09-30', 'status': 'paid',    'paid_at': '2025-09-05T08:30:00+07:00'},
      {'student_id': rithId,    'semester_id': sem1Id, 'description': 'Tuition Fee — Semester 1, 2025–2026', 'amount': 450.00, 'due_date': '2025-09-30', 'status': 'overdue'},
      {'student_id': bophaId,   'semester_id': sem1Id, 'description': 'Tuition Fee — Semester 1, 2025–2026', 'amount': 450.00, 'due_date': '2025-09-30', 'status': 'paid',    'paid_at': '2025-09-12T14:00:00+07:00'},
      {'student_id': vicheaId,  'semester_id': sem1Id, 'description': 'Tuition Fee — Semester 1, 2025–2026', 'amount': 450.00, 'due_date': '2025-09-30', 'status': 'partial'},
      {'student_id': sreymomId, 'semester_id': sem1Id, 'description': 'Tuition Fee — Semester 1, 2025–2026', 'amount': 450.00, 'due_date': '2025-09-30', 'status': 'paid',    'paid_at': '2025-09-08T09:00:00+07:00'},
      {'student_id': pisethId,  'semester_id': sem1Id, 'description': 'Tuition Fee — Semester 1, 2025–2026', 'amount': 450.00, 'due_date': '2025-09-30', 'status': 'unpaid'},
    ]).select();

    final minaInvId    = invoices.firstWhere((i) => i['student_id'] == minaId)['id']    as String;
    final bophaInvId   = invoices.firstWhere((i) => i['student_id'] == bophaId)['id']   as String;
    final vicheaInvId  = invoices.firstWhere((i) => i['student_id'] == vicheaId)['id']  as String;
    final sreymomInvId = invoices.firstWhere((i) => i['student_id'] == sreymomId)['id'] as String;

    await supabase.from('payments').insert([
      {'invoice_id': minaInvId,    'student_id': minaId,    'amount': 450.00, 'payment_method': 'Bank Transfer', 'reference_number': 'TXN-20250905-001', 'verified_by': adminId, 'notes': 'Full payment received'},
      {'invoice_id': bophaInvId,   'student_id': bophaId,   'amount': 450.00, 'payment_method': 'Bank Transfer', 'reference_number': 'TXN-20250912-002', 'verified_by': adminId},
      {'invoice_id': vicheaInvId,  'student_id': vicheaId,  'amount': 200.00, 'payment_method': 'Cash',          'reference_number': 'CASH-20250920-001', 'notes': 'Partial payment — balance \$250 due'},
      {'invoice_id': sreymomInvId, 'student_id': sreymomId, 'amount': 450.00, 'payment_method': 'ABA Pay',       'reference_number': 'ABA-20250908-001',  'verified_by': adminId},
    ]);
    print('  ✓ 6 invoices, 4 payments');

    // ── 15. Notifications ───────────────────────────────────────────────────
    print('\n🔔 Inserting notifications...');
    await supabase.from('notifications').insert([
      {'user_id': minaId,    'title': 'Grade Posted',              'body': 'Your grade for Data Structures & Algorithms has been posted.', 'type': 'grade',   'is_read': false},
      {'user_id': minaId,    'title': 'Tuition Fee Paid',          'body': 'Your Semester 1 tuition payment of \$450 has been confirmed.',  'type': 'finance', 'is_read': true},
      {'user_id': rithId,    'title': 'Leave Request Approved',    'body': 'Your leave request for Oct 15–16 has been approved.',           'type': 'leave',   'is_read': true},
      {'user_id': rithId,    'title': 'Tuition Fee Overdue',       'body': 'Your Semester 1 tuition fee is overdue. Please pay immediately.','type': 'finance', 'is_read': false},
      {'user_id': vicheaId,  'title': 'Partial Payment Received',  'body': 'We received \$200. Remaining balance: \$250 due by Sep 30.',     'type': 'finance', 'is_read': false},
      {'user_id': vicheaId,  'title': 'Leave Request Rejected',    'body': 'Your leave request for Oct 22–24 was rejected (midterm week).',  'type': 'leave',   'is_read': false},
      {'user_id': adminId,   'title': 'New Student Leave Request', 'body': 'Mina Sok submitted a sick leave request (Oct 1–3).',            'type': 'leave',   'is_read': false},
      {'user_id': adminId,   'title': 'Teacher Leave Request',     'body': 'Sokha Chan requested leave for ASEAN Tech Summit (Nov 10–12).',  'type': 'leave',   'is_read': false},
    ]);
    print('  ✓ 8 notifications');

    // ── 16. Course materials ────────────────────────────────────────────────
    print('\n📄 Inserting course materials...');
    await supabase.from('course_materials').insert([
      {'course_id': cs101Id,  'teacher_id': sokhaId,  'title': 'Lecture 1: Introduction to Programming',    'description': 'Overview of programming concepts and Dart basics.',    'file_url': 'https://files.beltei.edu.kh/cs101/lecture1.pdf',    'file_type': 'pdf',  'file_size': 2048},
      {'course_id': cs101Id,  'teacher_id': sokhaId,  'title': 'Lab Exercise 1: Hello World',               'description': 'Your first Dart program — basic I/O and variables.',  'file_url': 'https://files.beltei.edu.kh/cs101/lab1.zip',        'file_type': 'zip',  'file_size': 512},
      {'course_id': cs201Id,  'teacher_id': sokhaId,  'title': 'Chapter 1: Arrays and Lists',               'description': 'Array operations, dynamic lists, and complexity.',    'file_url': 'https://files.beltei.edu.kh/cs201/chapter1.pdf',    'file_type': 'pdf',  'file_size': 3072},
      {'course_id': net101Id, 'teacher_id': daraId,   'title': 'Network Fundamentals Slides',               'description': 'OSI model, TCP/IP stack, and IP addressing.',         'file_url': 'https://files.beltei.edu.kh/net101/slides1.pptx',   'file_type': 'pptx', 'file_size': 5120},
      {'course_id': fin101Id, 'teacher_id': chandaId, 'title': 'Financial Management Reference Sheet',      'description': 'Time value of money, NPV, IRR, and ratio analysis.',  'file_url': 'https://files.beltei.edu.kh/fin101/reference.pdf',  'file_type': 'pdf',  'file_size': 1024},
    ]);
    print('  ✓ 5 course materials');

    // ── 17. Announcements ───────────────────────────────────────────────────
    print('\n📢 Inserting announcements...');
    await supabase.from('announcements').insert([
      {'teacher_id': sokhaId,  'course_id': cs101Id,  'title': 'Welcome to Introduction to Programming',   'body': 'Welcome! Please install Flutter SDK and VS Code before next class. Syllabus is in Course Materials.', 'is_pinned': true},
      {'teacher_id': sokhaId,  'course_id': cs201Id,  'title': 'Midterm Exam Schedule',                    'body': 'Midterm: October 20, 2025 — 09:00–11:00, Room A102. Topics: Arrays, Linked Lists, Stacks.',         'is_pinned': true},
      {'teacher_id': daraId,   'course_id': net101Id, 'title': 'Lab Assignment 1 Due',                     'body': 'Lab 1 (IP Addressing & Subnetting) is due September 30, 2025. Submit via the student portal.',       'is_pinned': false},
      {'teacher_id': chandaId, 'course_id': fin101Id, 'title': 'Chapter 2 Reading Required',               'body': 'Please read Chapter 2 (Capital Budgeting) before Thursday\'s class.',                               'is_pinned': false},
      {'teacher_id': sokhaId,  'course_id': cs301Id,  'title': 'Semester Project — Team Formation',        'body': 'Form teams of 3 for the semester project by next Monday. Email your team names to sokha@beltei.edu.kh.', 'is_pinned': false},
    ]);
    print('  ✓ 5 announcements');

    // ── Summary ─────────────────────────────────────────────────────────────
    print('''

✅ Seeding complete!
   • 10 users  (1 admin · 3 teachers · 6 students)
   • 13 faculties · ${departments.length} departments · ${majors.length} majors
   • 2 semesters · 6 courses
   • 12 enrollments · 12 grade records
   • ${attendanceRows.length} attendance records
   • 5 leave requests · 6 invoices · 4 payments
   • 8 notifications · 5 course materials · 5 announcements

📧 Credentials — password: $kPassword
   admin@beltei.edu.kh
   sokha@beltei.edu.kh  ·  dara@beltei.edu.kh  ·  chanda@beltei.edu.kh
   mina@beltei.edu.kh   ·  rith@beltei.edu.kh   ·  bopha@beltei.edu.kh
   vichea@beltei.edu.kh ·  sreymom@beltei.edu.kh ·  piseth@beltei.edu.kh
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
    userMetadata: {'first_name': firstName, 'last_name': lastName, 'role': role},
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
    stderr.writeln('❌ Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env');
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
    result[trimmed.substring(0, idx).trim()] = trimmed.substring(idx + 1).trim();
  }
  return result;
}
