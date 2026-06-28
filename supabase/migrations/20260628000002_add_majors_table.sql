-- Create majors table (faculty → department → majors)
CREATE TABLE IF NOT EXISTS majors (
  id            UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  name          TEXT NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE majors ENABLE ROW LEVEL SECURITY;
CREATE POLICY "majors_read"  ON majors FOR SELECT USING (true);
CREATE POLICY "majors_admin" ON majors FOR ALL    USING (is_admin());

GRANT SELECT, INSERT, UPDATE, DELETE ON majors TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON majors TO service_role;

-- Students enroll in a major (replaces department_id on students)
ALTER TABLE students ADD COLUMN IF NOT EXISTS major_id UUID REFERENCES majors(id) ON DELETE SET NULL;
ALTER TABLE students DROP COLUMN IF EXISTS department_id;
