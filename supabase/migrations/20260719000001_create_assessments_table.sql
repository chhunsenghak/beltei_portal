-- ── Assessments/Assignments Table ─────────────────────────────────────────────

CREATE TABLE assessments (
  id                   UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_term_course_id UUID REFERENCES class_term_courses(id) ON DELETE CASCADE,
  title                TEXT NOT NULL,
  type                 TEXT NOT NULL,
  max_score            DECIMAL(5,2) NOT NULL DEFAULT 100,
  due_date             DATE,
  description          TEXT,
  file_url             TEXT,
  created_at           TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;

-- Allow select policy for enrolled students, teachers, and admins
CREATE POLICY "Enrolled students views assessments" ON assessments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM enrollments e
      JOIN class_term_courses ctc ON ctc.class_term_id = e.class_term_id
      WHERE ctc.id = assessments.class_term_course_id AND e.student_id = auth.uid()
    ) OR EXISTS (
      SELECT 1 FROM class_term_courses ctc
      WHERE ctc.id = assessments.class_term_course_id AND ctc.teacher_id = auth.uid()
    ) OR is_admin()
  );

-- Allow full policy (all actions) for the course teacher
CREATE POLICY "Teacher manages own course assessments" ON assessments
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM class_term_courses ctc
      WHERE ctc.id = assessments.class_term_course_id AND ctc.teacher_id = auth.uid()
    )
  );

-- Grant privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON assessments TO authenticated;
GRANT SELECT ON assessments TO anon;
GRANT ALL ON assessments TO service_role;
