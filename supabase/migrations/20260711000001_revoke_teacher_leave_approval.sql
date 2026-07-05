-- Reverting the teacher leave-approval capability added in
-- 20260709000001_teacher_leave_review.sql: teachers should only be able to
-- view their students' leave requests, not decide on them — that stays
-- admin-only. Keep the SELECT policy and teacher_teaches_student() function,
-- both still needed for viewing and for the profiles policy.

DROP POLICY IF EXISTS "Teacher reviews student requests" ON leave_requests;
