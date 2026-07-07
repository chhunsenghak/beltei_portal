-- Students could never actually read their own teacher's profile row: the only
-- profiles SELECT policies were "own profile", "admin", and "teacher views
-- student profiles" (one-directional, teacher -> student). Any query resolving
-- a professor's name for a student (e.g. the student course list) silently got
-- zero rows back from `profiles`, even though the student could read the
-- `classes` row naming that teacher_id.
--
-- Teacher assignment is per-class (see 20260630000002_add_classes.sql), so this
-- checks classes the student is actively enrolled in, not courses.teacher_id.

CREATE OR REPLACE FUNCTION student_has_teacher(p_teacher_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.enrollments e
    JOIN public.classes c ON c.id = e.class_id
    WHERE e.student_id = auth.uid()
      AND c.teacher_id = p_teacher_id
      AND e.status <> 'dropped'
  );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

CREATE POLICY "Student views own teachers' profiles"
  ON profiles FOR SELECT
  USING (student_has_teacher(profiles.id));
