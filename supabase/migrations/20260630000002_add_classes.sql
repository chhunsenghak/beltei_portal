-- ── Sections table ────────────────────────────────────────────────────────────
-- Each section is one physical class group (e.g. CS101 · International · Weekday · Morning A).
-- Teacher, shift, program type, schedule type and capacity live here — NOT on the course catalog.

CREATE TABLE sections (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id     UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  semester_id   UUID NOT NULL REFERENCES semesters(id),
  teacher_id    UUID REFERENCES teachers(id),
  program_type  TEXT NOT NULL DEFAULT 'national'  CHECK (program_type  IN ('national', 'international')),
  schedule_type TEXT NOT NULL DEFAULT 'weekday'   CHECK (schedule_type IN ('weekday', 'weekend')),
  shift         TEXT NOT NULL                     CHECK (shift         IN ('morning', 'afternoon', 'evening')),
  section_code  TEXT NOT NULL,
  room          TEXT,
  max_students  INTEGER NOT NULL DEFAULT 30,
  status        TEXT NOT NULL DEFAULT 'active'    CHECK (status        IN ('active', 'inactive')),
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (course_id, semester_id, program_type, schedule_type, shift, section_code)
);

CREATE INDEX sections_course_id_idx    ON sections (course_id);
CREATE INDEX sections_semester_id_idx  ON sections (semester_id);
CREATE INDEX sections_teacher_id_idx   ON sections (teacher_id);
CREATE INDEX sections_program_idx      ON sections (program_type);
CREATE INDEX sections_schedule_idx     ON sections (schedule_type);

-- ── Add section_id to enrollments and attendance FIRST ────────────────────────
-- These columns must exist before any RLS policy on `sections` references them.

ALTER TABLE enrollments
  ADD COLUMN IF NOT EXISTS section_id UUID REFERENCES sections(id);

CREATE INDEX enrollments_section_id_idx ON enrollments (section_id);

ALTER TABLE attendance
  ADD COLUMN IF NOT EXISTS section_id UUID REFERENCES sections(id);

CREATE INDEX attendance_section_id_idx ON attendance (section_id);

-- ── Grants ───────────────────────────────────────────────────────────────────
-- The initial schema's GRANT ON ALL TABLES only covers tables that existed at
-- that point. New tables need explicit grants.

GRANT SELECT, INSERT, UPDATE, DELETE ON public.sections TO authenticated;

-- ── Row Level Security ────────────────────────────────────────────────────────

ALTER TABLE sections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin manages sections"
  ON sections FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "Teacher views own sections"
  ON sections FOR SELECT
  USING (teacher_id = auth.uid());

CREATE POLICY "Student views enrolled sections"
  ON sections FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM enrollments e
      WHERE e.section_id = sections.id
        AND e.student_id = auth.uid()
        AND e.status != 'dropped'
    )
  );
