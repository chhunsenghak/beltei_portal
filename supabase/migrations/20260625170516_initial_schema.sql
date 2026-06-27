-- ============================================================
-- BELTEI Campus Portal — Supabase Schema
-- Run this in: Supabase Dashboard → SQL Editor → New query
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Profiles (mirrors auth.users, one row per user) ─────────────────────────

CREATE TABLE profiles (
  id          UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email       TEXT NOT NULL,
  first_name   TEXT NOT NULL,
  last_name   TEXT NOT NULL,
  role        TEXT NOT NULL CHECK (role IN ('student', 'teacher', 'admin')),
  phone       TEXT,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── Faculties & Departments ──────────────────────────────────────────────────

CREATE TABLE faculties (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name        TEXT NOT NULL,
  code        TEXT NOT NULL UNIQUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE departments (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  faculty_id  UUID REFERENCES faculties(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  code        TEXT NOT NULL UNIQUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── Students ─────────────────────────────────────────────────────────────────

CREATE TABLE students (
  id                UUID REFERENCES profiles(id) ON DELETE CASCADE PRIMARY KEY,
  student_code      TEXT NOT NULL UNIQUE,
  faculty_id        UUID REFERENCES faculties(id),
  department_id     UUID REFERENCES departments(id),
  enrollment_year   INTEGER NOT NULL,
  year_level        INTEGER NOT NULL DEFAULT 1,
  status            TEXT NOT NULL DEFAULT 'active'
                      CHECK (status IN ('active', 'inactive', 'graduated', 'suspended')),
  date_of_birth     DATE,
  gender            TEXT CHECK (gender IN ('male', 'female', 'other')),
  address           TEXT,
  emergency_contact TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ── Teachers ─────────────────────────────────────────────────────────────────

CREATE TABLE teachers (
  id              UUID REFERENCES profiles(id) ON DELETE CASCADE PRIMARY KEY,
  employee_code   TEXT NOT NULL UNIQUE,
  department_id   UUID REFERENCES departments(id),
  position        TEXT,
  specialization  TEXT,
  hire_date       DATE,
  status          TEXT NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active', 'inactive')),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ── Semesters ────────────────────────────────────────────────────────────────

CREATE TABLE semesters (
  id             UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name           TEXT NOT NULL,
  academic_year  TEXT NOT NULL,
  start_date     DATE NOT NULL,
  end_date       DATE NOT NULL,
  is_current     BOOLEAN DEFAULT FALSE,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ── Courses ──────────────────────────────────────────────────────────────────

CREATE TABLE courses (
  id             UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  code           TEXT NOT NULL UNIQUE,
  name           TEXT NOT NULL,
  credits        INTEGER NOT NULL DEFAULT 3,
  teacher_id     UUID REFERENCES teachers(id),
  semester_id    UUID REFERENCES semesters(id),
  faculty_id     UUID REFERENCES faculties(id),
  department_id  UUID REFERENCES departments(id),
  max_students   INTEGER DEFAULT 40,
  schedule       JSONB,   -- [{"day":"Mon","start":"08:00","end":"09:30","room":"A101"}]
  description    TEXT,
  status         TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ── Enrollments ──────────────────────────────────────────────────────────────

CREATE TABLE enrollments (
  id           UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  student_id   UUID REFERENCES students(id) ON DELETE CASCADE,
  course_id    UUID REFERENCES courses(id) ON DELETE CASCADE,
  semester_id  UUID REFERENCES semesters(id),
  enrolled_at  TIMESTAMPTZ DEFAULT NOW(),
  status       TEXT DEFAULT 'enrolled'
                 CHECK (status IN ('enrolled', 'dropped', 'completed')),
  UNIQUE(student_id, course_id, semester_id)
);

-- ── Grades ───────────────────────────────────────────────────────────────────

CREATE TABLE grades (
  id            UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  student_id    UUID REFERENCES students(id) ON DELETE CASCADE,
  course_id     UUID REFERENCES courses(id) ON DELETE CASCADE,
  semester_id   UUID REFERENCES semesters(id),
  midterm       DECIMAL(5,2),
  final_exam    DECIMAL(5,2),
  assignment    DECIMAL(5,2),
  participation DECIMAL(5,2),
  total         DECIMAL(5,2),
  letter_grade  TEXT,
  gpa_points    DECIMAL(3,2),
  remarks       TEXT,
  updated_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, course_id, semester_id)
);

-- ── Attendance ───────────────────────────────────────────────────────────────

CREATE TABLE attendance (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  student_id  UUID REFERENCES students(id) ON DELETE CASCADE,
  course_id   UUID REFERENCES courses(id) ON DELETE CASCADE,
  date        DATE NOT NULL,
  status      TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late', 'excused')),
  marked_by   UUID REFERENCES teachers(id),
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, course_id, date)
);

-- ── Leave Requests ───────────────────────────────────────────────────────────

CREATE TABLE leave_requests (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  requester_id    UUID REFERENCES profiles(id) ON DELETE CASCADE,
  requester_type  TEXT NOT NULL CHECK (requester_type IN ('student', 'teacher')),
  type            TEXT NOT NULL,
  reason          TEXT NOT NULL,
  start_date      DATE NOT NULL,
  end_date        DATE NOT NULL,
  doc_url         TEXT,
  status          TEXT DEFAULT 'pending'
                    CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewed_by     UUID REFERENCES profiles(id),
  reviewed_at     TIMESTAMPTZ,
  review_notes    TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ── Finance ──────────────────────────────────────────────────────────────────

CREATE TABLE invoices (
  id           UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  student_id   UUID REFERENCES students(id) ON DELETE CASCADE,
  semester_id  UUID REFERENCES semesters(id),
  description  TEXT NOT NULL,
  amount       DECIMAL(10,2) NOT NULL,
  due_date     DATE NOT NULL,
  paid_at      TIMESTAMPTZ,
  status       TEXT DEFAULT 'unpaid'
                 CHECK (status IN ('unpaid', 'paid', 'overdue', 'partial')),
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE payments (
  id               UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  invoice_id       UUID REFERENCES invoices(id),
  student_id       UUID REFERENCES students(id),
  amount           DECIMAL(10,2) NOT NULL,
  payment_method   TEXT NOT NULL,
  reference_number TEXT,
  paid_at          TIMESTAMPTZ DEFAULT NOW(),
  verified_by      UUID REFERENCES profiles(id),
  notes            TEXT
);

-- ── Notifications ────────────────────────────────────────────────────────────

CREATE TABLE notifications (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id     UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  type        TEXT DEFAULT 'info',
  is_read     BOOLEAN DEFAULT FALSE,
  data        JSONB,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── Course Materials ─────────────────────────────────────────────────────────

CREATE TABLE course_materials (
  id           UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  course_id    UUID REFERENCES courses(id) ON DELETE CASCADE,
  teacher_id   UUID REFERENCES teachers(id),
  title        TEXT NOT NULL,
  description  TEXT,
  file_url     TEXT NOT NULL,
  file_type    TEXT,
  file_size    INTEGER,
  uploaded_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ── Announcements ────────────────────────────────────────────────────────────

CREATE TABLE announcements (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  teacher_id  UUID REFERENCES teachers(id),
  course_id   UUID REFERENCES courses(id),
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  is_pinned   BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE profiles         ENABLE ROW LEVEL SECURITY;
ALTER TABLE students         ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers         ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses          ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments      ENABLE ROW LEVEL SECURITY;
ALTER TABLE grades           ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance       ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_requests   ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices         ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments         ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications    ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements    ENABLE ROW LEVEL SECURITY;

-- Helper: check if current user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin');
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- ── Profiles ─────────────────────────────────────────────────────────────────
CREATE POLICY "Own profile readable"   ON profiles FOR SELECT USING (auth.uid() = id OR is_admin());
CREATE POLICY "Teacher views student profiles" ON profiles FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM enrollments e
    JOIN courses c ON c.id = e.course_id
    WHERE e.student_id = profiles.id
      AND c.teacher_id = auth.uid()
  )
);
CREATE POLICY "Own profile updatable"  ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Admin full access"      ON profiles FOR ALL    USING (is_admin());

-- ── Students ─────────────────────────────────────────────────────────────────
CREATE POLICY "Student views own record" ON students FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Teacher views enrolled"   ON students FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM enrollments e
    JOIN courses c ON c.id = e.course_id
    WHERE e.student_id = students.id
      AND c.teacher_id = auth.uid()
  )
);
CREATE POLICY "Admin manages students" ON students FOR ALL USING (is_admin());

-- ── Teachers ─────────────────────────────────────────────────────────────────
CREATE POLICY "Teacher views own record" ON teachers FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Admin manages teachers"   ON teachers FOR ALL   USING (is_admin());

-- ── Courses ──────────────────────────────────────────────────────────────────
CREATE POLICY "Enrolled students view courses" ON courses FOR SELECT USING (
  EXISTS (SELECT 1 FROM enrollments WHERE course_id = courses.id AND student_id = auth.uid())
  OR teacher_id = auth.uid()
  OR is_admin()
);
CREATE POLICY "Teacher manages own courses" ON courses FOR UPDATE USING (teacher_id = auth.uid());
CREATE POLICY "Admin manages courses"       ON courses FOR ALL    USING (is_admin());

-- ── Enrollments ──────────────────────────────────────────────────────────────
CREATE POLICY "Student views own enrollments" ON enrollments FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "Teacher views course enrollments" ON enrollments FOR SELECT USING (
  EXISTS (SELECT 1 FROM courses WHERE id = enrollments.course_id AND teacher_id = auth.uid())
);
CREATE POLICY "Admin manages enrollments" ON enrollments FOR ALL USING (is_admin());

-- ── Grades ───────────────────────────────────────────────────────────────────
CREATE POLICY "Student views own grades" ON grades FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "Teacher manages course grades" ON grades FOR ALL USING (
  EXISTS (SELECT 1 FROM courses WHERE id = grades.course_id AND teacher_id = auth.uid())
);
CREATE POLICY "Admin manages grades" ON grades FOR ALL USING (is_admin());

-- ── Attendance ───────────────────────────────────────────────────────────────
CREATE POLICY "Student views own attendance" ON attendance FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "Teacher manages course attendance" ON attendance FOR ALL USING (
  EXISTS (SELECT 1 FROM courses WHERE id = attendance.course_id AND teacher_id = auth.uid())
);
CREATE POLICY "Admin manages attendance" ON attendance FOR ALL USING (is_admin());

-- ── Leave Requests ───────────────────────────────────────────────────────────
CREATE POLICY "User views own requests"   ON leave_requests FOR SELECT USING (requester_id = auth.uid());
CREATE POLICY "User creates own request"  ON leave_requests FOR INSERT WITH CHECK (requester_id = auth.uid());
CREATE POLICY "Teacher views student requests" ON leave_requests FOR SELECT USING (
  requester_type = 'student' AND EXISTS (
    SELECT 1 FROM enrollments e
    JOIN courses c ON c.id = e.course_id
    WHERE e.student_id = leave_requests.requester_id
      AND c.teacher_id = auth.uid()
  )
);
CREATE POLICY "Admin manages all requests" ON leave_requests FOR ALL USING (is_admin());

-- ── Invoices ─────────────────────────────────────────────────────────────────
CREATE POLICY "Student views own invoices" ON invoices FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "Admin manages invoices"     ON invoices FOR ALL    USING (is_admin());

-- ── Payments ─────────────────────────────────────────────────────────────────
CREATE POLICY "Student views own payments" ON payments FOR SELECT USING (student_id = auth.uid());
CREATE POLICY "Admin manages payments"     ON payments FOR ALL    USING (is_admin());

-- ── Notifications ────────────────────────────────────────────────────────────
CREATE POLICY "User views own notifications"   ON notifications FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "User updates own notifications" ON notifications FOR UPDATE USING (user_id = auth.uid());

-- ── Course Materials ─────────────────────────────────────────────────────────
CREATE POLICY "Enrolled student views materials" ON course_materials FOR SELECT USING (
  EXISTS (SELECT 1 FROM enrollments WHERE course_id = course_materials.course_id AND student_id = auth.uid())
  OR teacher_id = auth.uid()
  OR is_admin()
);
CREATE POLICY "Teacher manages own materials" ON course_materials FOR ALL USING (teacher_id = auth.uid());

-- ── Announcements ────────────────────────────────────────────────────────────
CREATE POLICY "Enrolled student views announcements" ON announcements FOR SELECT USING (
  EXISTS (SELECT 1 FROM enrollments WHERE course_id = announcements.course_id AND student_id = auth.uid())
  OR teacher_id = auth.uid()
  OR is_admin()
);
CREATE POLICY "Teacher manages own announcements" ON announcements FOR ALL USING (teacher_id = auth.uid());

-- ============================================================
-- TRIGGER: auto-create profile row when a user signs up
-- ============================================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, first_name, last_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'first_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- GRANTS
-- ============================================================

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO service_role;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO service_role;
