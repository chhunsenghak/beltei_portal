-- ============================================================
-- Class/curriculum redesign
-- ============================================================
-- Previously a `classes` row was scoped to exactly one course, one semester,
-- one teacher, and one schedule — a student taking two courses in the same
-- cohort needed two separate enrollment rows into two separate classes.
--
-- This redesign makes `classes` a stable, multi-year cohort identity. What
-- changes per year/semester (room, shift, schedule type, year level, and the
-- attached course list) now lives on a new `class_terms` row underneath it,
-- and the actual curriculum (which courses, with which teacher/schedule) is
-- `class_term_courses`. A student enrolls ONCE per semester into a class
-- term and automatically takes every course attached to it. Enrollment is
-- never auto-carried-forward between semesters — each term needs its own
-- explicit enrollment row, which is how new students join and how
-- non-continuing students simply don't get re-added.
--
-- Current DB content is seed/demo data only, so this migration cleanly
-- drops and recreates the affected tables rather than backfilling.

-- ── Drop tables being restructured (CASCADE drops their policies/indexes/FKs) ──

DROP TABLE IF EXISTS attendance, grades, enrollments, classes CASCADE;

-- ── Courses becomes a pure catalog — drop columns superseded by class_term_courses ──
-- Existing policies referencing courses.teacher_id must go first, or the
-- DROP COLUMN below fails with a dependency error.

DROP POLICY IF EXISTS "Enrolled students view courses" ON courses;
DROP POLICY IF EXISTS "Teacher manages own courses" ON courses;

ALTER TABLE courses
  DROP COLUMN IF EXISTS teacher_id,
  DROP COLUMN IF EXISTS semester_id,
  DROP COLUMN IF EXISTS max_students;

-- ── Classes: stable cohort identity, persists across years ──────────────────

CREATE TABLE classes (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_code    TEXT NOT NULL UNIQUE,
  faculty_id    UUID REFERENCES faculties(id),
  program_type  TEXT NOT NULL DEFAULT 'national' CHECK (program_type IN ('national', 'international')),
  status        TEXT NOT NULL DEFAULT 'active'   CHECK (status IN ('active', 'inactive')),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX classes_faculty_id_idx ON classes (faculty_id);

-- ── Class terms: one row per class per semester — the "year-specific" facts ──

CREATE TABLE class_terms (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id      UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  semester_id   UUID NOT NULL REFERENCES semesters(id),
  year_level    INTEGER NOT NULL DEFAULT 1 CHECK (year_level > 0),
  schedule_type TEXT NOT NULL DEFAULT 'weekday' CHECK (schedule_type IN ('weekday', 'weekend')),
  shift         TEXT NOT NULL CHECK (shift IN ('morning', 'afternoon', 'evening')),
  room          TEXT,
  max_students  INTEGER NOT NULL DEFAULT 30,
  status        TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (class_id, semester_id)
);

CREATE INDEX class_terms_class_id_idx    ON class_terms (class_id);
CREATE INDEX class_terms_semester_id_idx ON class_terms (semester_id);

-- ── Class term courses: the curriculum — which courses (+ teacher + schedule) ──

CREATE TABLE class_term_courses (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_term_id  UUID NOT NULL REFERENCES class_terms(id) ON DELETE CASCADE,
  course_id      UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  teacher_id     UUID REFERENCES teachers(id),
  schedule       JSONB NOT NULL DEFAULT '[]'::jsonb,  -- [{"day":"Mon","start":"08:00","end":"09:30","room":"A101"}]
  status         TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (class_term_id, course_id)
);

CREATE INDEX class_term_courses_class_term_id_idx ON class_term_courses (class_term_id);
CREATE INDEX class_term_courses_course_id_idx     ON class_term_courses (course_id);
CREATE INDEX class_term_courses_teacher_id_idx    ON class_term_courses (teacher_id);

-- ── Enrollments: one row per student per class TERM (not per course) ────────

CREATE TABLE enrollments (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id     UUID REFERENCES students(id) ON DELETE CASCADE,
  class_term_id  UUID NOT NULL REFERENCES class_terms(id) ON DELETE CASCADE,
  status         TEXT DEFAULT 'enrolled' CHECK (status IN ('enrolled', 'dropped', 'completed')),
  enrolled_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (student_id, class_term_id)
);

CREATE INDEX enrollments_student_id_idx    ON enrollments (student_id);
CREATE INDEX enrollments_class_term_id_idx ON enrollments (class_term_id);

-- ── Attendance: per course-within-term occurrence ────────────────────────────
-- course_id is denormalized from class_term_courses at write time (a
-- class_term_course row is never repointed to a different course), so
-- existing "attendance for course X" queries keep working unchanged.

CREATE TABLE attendance (
  id                    UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id            UUID REFERENCES students(id) ON DELETE CASCADE,
  class_term_course_id  UUID NOT NULL REFERENCES class_term_courses(id) ON DELETE CASCADE,
  course_id             UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  semester_id           UUID REFERENCES semesters(id),
  date                  DATE NOT NULL,
  status                TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late', 'excused')),
  marked_by             UUID REFERENCES teachers(id),
  notes                 TEXT,
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (student_id, class_term_course_id, date)
);

CREATE INDEX attendance_student_id_idx           ON attendance (student_id);
CREATE INDEX attendance_class_term_course_id_idx ON attendance (class_term_course_id);
CREATE INDEX attendance_course_id_idx            ON attendance (course_id);
CREATE INDEX attendance_semester_id_idx          ON attendance (semester_id);

-- ── Grades: per course-within-term occurrence ────────────────────────────────

CREATE TABLE grades (
  id                    UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id            UUID REFERENCES students(id) ON DELETE CASCADE,
  class_term_course_id  UUID NOT NULL REFERENCES class_term_courses(id) ON DELETE CASCADE,
  course_id             UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  semester_id           UUID REFERENCES semesters(id),
  midterm               DECIMAL(5,2),
  final_exam            DECIMAL(5,2),
  assignment            DECIMAL(5,2),
  participation         DECIMAL(5,2),
  total                 DECIMAL(5,2),
  letter_grade          TEXT,
  gpa_points            DECIMAL(3,2),
  remarks               TEXT,
  updated_at            TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (student_id, class_term_course_id)
);

CREATE INDEX grades_student_id_idx           ON grades (student_id);
CREATE INDEX grades_class_term_course_id_idx ON grades (class_term_course_id);
CREATE INDEX grades_course_id_idx            ON grades (course_id);
CREATE INDEX grades_semester_id_idx          ON grades (semester_id);

-- ── Grants (blanket ALL-TABLES grants only cover tables that existed at the ──
-- ── time they ran — every recreated/new table here needs an explicit grant) ──

GRANT SELECT, INSERT, UPDATE, DELETE ON classes, class_terms, class_term_courses, enrollments, attendance, grades
  TO authenticated, service_role;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE classes            ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_terms        ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_term_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments        ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance         ENABLE ROW LEVEL SECURITY;
ALTER TABLE grades             ENABLE ROW LEVEL SECURITY;

-- ── Helper functions ──────────────────────────────────────────────────────
-- Redefined in place (same names as before) so policies on tables we are NOT
-- touching (course_materials, announcements, profiles, leave_requests) keep
-- working without needing their own migration.

-- Is current user (student) enrolled in a class term that includes this course?
CREATE OR REPLACE FUNCTION is_enrolled_in(p_course_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.enrollments e
    JOIN public.class_term_courses ctc ON ctc.class_term_id = e.class_term_id
    WHERE ctc.course_id = p_course_id
      AND e.student_id = auth.uid()
      AND e.status != 'dropped'
  );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- Does current user (teacher) teach this course in any class term?
CREATE OR REPLACE FUNCTION teacher_owns_course(p_course_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.class_term_courses
    WHERE course_id = p_course_id AND teacher_id = auth.uid()
  );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- Does current user (teacher) teach this exact class_term_course?
CREATE OR REPLACE FUNCTION teacher_owns_class_term_course(p_class_term_course_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.class_term_courses
    WHERE id = p_class_term_course_id AND teacher_id = auth.uid()
  );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- Is current user (student) enrolled in this class term?
CREATE OR REPLACE FUNCTION is_enrolled_in_class_term(p_class_term_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.enrollments
    WHERE class_term_id = p_class_term_id AND student_id = auth.uid() AND status != 'dropped'
  );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- Does current user (teacher) teach any course the given student is enrolled in?
CREATE OR REPLACE FUNCTION teacher_teaches_student(p_student_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.enrollments e
    JOIN public.class_term_courses ctc ON ctc.class_term_id = e.class_term_id
    WHERE e.student_id = p_student_id AND ctc.teacher_id = auth.uid() AND e.status != 'dropped'
  );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- Does current user (student) have the given teacher in any of their courses?
CREATE OR REPLACE FUNCTION student_has_teacher(p_teacher_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.enrollments e
    JOIN public.class_term_courses ctc ON ctc.class_term_id = e.class_term_id
    WHERE e.student_id = auth.uid() AND ctc.teacher_id = p_teacher_id AND e.status != 'dropped'
  );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- ── Courses ──────────────────────────────────────────────────────────────────
-- (old policies referencing courses.teacher_id were already dropped above,
-- before the column itself was dropped)

CREATE POLICY "Enrolled students view courses" ON courses FOR SELECT USING (
  is_enrolled_in(courses.id) OR teacher_owns_course(courses.id) OR is_admin()
);
-- No teacher UPDATE policy: a course can now be taught by different
-- teachers across different class terms, so catalog edits are admin-only.

-- ── Classes ──────────────────────────────────────────────────────────────────

CREATE POLICY "Admin manages classes" ON classes FOR ALL
  USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY "Teacher views own classes" ON classes FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM class_terms ct
    JOIN class_term_courses ctc ON ctc.class_term_id = ct.id
    WHERE ct.class_id = classes.id AND ctc.teacher_id = auth.uid()
  )
);

CREATE POLICY "Student views enrolled classes" ON classes FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM class_terms ct
    JOIN enrollments e ON e.class_term_id = ct.id
    WHERE ct.class_id = classes.id AND e.student_id = auth.uid() AND e.status != 'dropped'
  )
);

-- ── Class terms ──────────────────────────────────────────────────────────────

CREATE POLICY "Admin manages class terms" ON class_terms FOR ALL
  USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY "Teacher views own class terms" ON class_terms FOR SELECT USING (
  EXISTS (SELECT 1 FROM class_term_courses ctc WHERE ctc.class_term_id = class_terms.id AND ctc.teacher_id = auth.uid())
);

CREATE POLICY "Student views enrolled class terms" ON class_terms FOR SELECT USING (
  is_enrolled_in_class_term(class_terms.id)
);

-- ── Class term courses ────────────────────────────────────────────────────────

CREATE POLICY "Admin manages class term courses" ON class_term_courses FOR ALL
  USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY "Teacher views own class term courses" ON class_term_courses FOR SELECT USING (
  teacher_id = auth.uid()
);

CREATE POLICY "Student views enrolled class term courses" ON class_term_courses FOR SELECT USING (
  is_enrolled_in_class_term(class_term_courses.class_term_id)
);

-- ── Enrollments ──────────────────────────────────────────────────────────────

CREATE POLICY "Student views own enrollments" ON enrollments FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "Teacher views term enrollments" ON enrollments FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM class_term_courses ctc
    WHERE ctc.class_term_id = enrollments.class_term_id AND ctc.teacher_id = auth.uid()
  )
);

CREATE POLICY "Admin manages enrollments" ON enrollments FOR ALL USING (is_admin());

-- ── Attendance ───────────────────────────────────────────────────────────────

CREATE POLICY "Student views own attendance" ON attendance FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "Teacher manages class term course attendance" ON attendance FOR ALL USING (
  teacher_owns_class_term_course(attendance.class_term_course_id)
);

CREATE POLICY "Admin manages attendance" ON attendance FOR ALL USING (is_admin());

-- ── Grades ───────────────────────────────────────────────────────────────────

CREATE POLICY "Student views own grades" ON grades FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "Teacher manages class term course grades" ON grades FOR ALL USING (
  teacher_owns_class_term_course(grades.class_term_course_id)
);

CREATE POLICY "Admin manages grades" ON grades FOR ALL USING (is_admin());
