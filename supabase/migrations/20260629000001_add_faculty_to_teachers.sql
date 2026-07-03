-- Add faculty_id directly to teachers so teachers can be assigned to a faculty
-- without requiring a department assignment.
ALTER TABLE teachers
  ADD COLUMN IF NOT EXISTS faculty_id UUID REFERENCES faculties(id) ON DELETE SET NULL;
