-- ── Submissions Table and Policies ───────────────────────────────────────────

CREATE TABLE assessment_submissions (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  assessment_id   UUID REFERENCES assessments(id) ON DELETE CASCADE,
  student_id      UUID REFERENCES students(id) ON DELETE CASCADE,
  submission_text TEXT,
  file_url        TEXT,
  grade           DECIMAL(5,2),
  feedback        TEXT,
  submitted_at    TIMESTAMPTZ DEFAULT NOW(),
  graded_at       TIMESTAMPTZ,
  graded_by       UUID REFERENCES profiles(id),
  UNIQUE(assessment_id, student_id)
);

ALTER TABLE assessment_submissions ENABLE ROW LEVEL SECURITY;

-- ── RLS Policies ─────────────────────────────────────────────────────────────

-- 1. Students can view and manage their own submissions
CREATE POLICY "Student manages own submissions"
  ON assessment_submissions FOR ALL
  USING (student_id = auth.uid())
  WITH CHECK (student_id = auth.uid());

-- 2. Teachers can view and update submissions for their course assessments
CREATE POLICY "Teacher views course submissions"
  ON assessment_submissions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM assessments a
      JOIN class_term_courses ctc ON ctc.id = a.class_term_course_id
      WHERE a.id = assessment_submissions.assessment_id AND ctc.teacher_id = auth.uid()
    )
  );

CREATE POLICY "Teacher grades course submissions"
  ON assessment_submissions FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM assessments a
      JOIN class_term_courses ctc ON ctc.id = a.class_term_course_id
      WHERE a.id = assessment_submissions.assessment_id AND ctc.teacher_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM assessments a
      JOIN class_term_courses ctc ON ctc.id = a.class_term_course_id
      WHERE a.id = assessment_submissions.assessment_id AND ctc.teacher_id = auth.uid()
    )
  );

CREATE POLICY "Teacher inserts course submissions"
  ON assessment_submissions FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM assessments a
      JOIN class_term_courses ctc ON ctc.id = a.class_term_course_id
      WHERE a.id = assessment_submissions.assessment_id AND ctc.teacher_id = auth.uid()
    )
  );


-- 3. Admins can do everything
CREATE POLICY "Admin full access submissions"
  ON assessment_submissions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ── Grants ───────────────────────────────────────────────────────────────────
GRANT SELECT, INSERT, UPDATE, DELETE ON assessment_submissions TO authenticated;
GRANT SELECT ON assessment_submissions TO anon;
GRANT ALL ON assessment_submissions TO service_role;

