-- Schema drift found 2026-07-09: `teacher_teaches_student()` and the two RLS
-- policies that depend on it ("Teacher views student profiles" on `profiles`,
-- "Teacher views student requests" on `leave_requests`) are present in
-- 20260625170516_initial_schema.sql as currently written, but were never
-- actually applied to remote — that file was edited after its initial push
-- and remote was never re-synced (same root cause as the profiles/full_name
-- and student_has_teacher drift found in prior migrations). This backfills
-- both, then adds the new capability: teachers can now also decide
-- (approve/reject) leave requests for students they teach, not just view them.

CREATE OR REPLACE FUNCTION teacher_teaches_student(p_student_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.enrollments e
    JOIN public.courses c ON c.id = e.course_id
    WHERE e.student_id = p_student_id AND c.teacher_id = auth.uid()
  );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

DROP POLICY IF EXISTS "Teacher views student profiles" ON profiles;
CREATE POLICY "Teacher views student profiles" ON profiles FOR SELECT
  USING (teacher_teaches_student(profiles.id));

DROP POLICY IF EXISTS "Teacher views student requests" ON leave_requests;
CREATE POLICY "Teacher views student requests" ON leave_requests FOR SELECT
  USING (requester_type = 'student' AND teacher_teaches_student(leave_requests.requester_id));

DROP POLICY IF EXISTS "Teacher reviews student requests" ON leave_requests;
CREATE POLICY "Teacher reviews student requests" ON leave_requests FOR UPDATE
  USING (requester_type = 'student' AND teacher_teaches_student(leave_requests.requester_id))
  WITH CHECK (requester_type = 'student' AND teacher_teaches_student(leave_requests.requester_id));
