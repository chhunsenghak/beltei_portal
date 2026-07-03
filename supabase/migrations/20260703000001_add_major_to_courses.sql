-- Courses gain a direct major link. department_id/faculty_id (both already on
-- courses) are kept in sync from the chosen major's department/faculty chain
-- by the application layer, so existing department/faculty joins keep working.
ALTER TABLE courses ADD COLUMN IF NOT EXISTS major_id UUID REFERENCES majors(id) ON DELETE SET NULL;
