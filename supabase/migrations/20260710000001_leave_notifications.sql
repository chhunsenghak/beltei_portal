-- "Teacher notification not work" — root cause: the `notifications` table was
-- never populated by anything except the one-off seed script (no RLS INSERT
-- policy for regular users, no trigger, no app-code insert path). Rather than
-- open a broad INSERT policy letting any user write notifications for any
-- other user, these two SECURITY DEFINER functions encapsulate exactly the
-- two events the app now needs: a student submitting a leave request notifies
-- every teacher who teaches them, and a teacher/admin decision on that
-- request notifies the student back. Each function derives its own
-- recipients/content server-side from the leave_requests row and validates
-- the caller's relationship to it, so no client-supplied user_id/content is
-- trusted blindly.

CREATE OR REPLACE FUNCTION notify_teachers_of_leave_request(p_leave_id UUID)
RETURNS VOID AS $$
DECLARE
  v_leave RECORD;
BEGIN
  SELECT id, requester_id, type, start_date, end_date
    INTO v_leave
    FROM public.leave_requests
    WHERE id = p_leave_id AND requester_type = 'student';

  IF v_leave IS NULL OR v_leave.requester_id <> auth.uid() THEN
    RETURN;
  END IF;

  INSERT INTO public.notifications (user_id, title, body, type, data)
  SELECT DISTINCT c.teacher_id,
    'New Leave Request',
    (SELECT COALESCE(first_name || ' ' || last_name, email) FROM public.profiles WHERE id = v_leave.requester_id)
      || ' requested ' || v_leave.type || ' leave (' || v_leave.start_date || ' – ' || v_leave.end_date || ').',
    'leave',
    jsonb_build_object('leave_id', v_leave.id)
  FROM public.enrollments e
  JOIN public.courses c ON c.id = e.course_id
  WHERE e.student_id = v_leave.requester_id AND e.status <> 'dropped';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION notify_student_of_leave_decision(p_leave_id UUID)
RETURNS VOID AS $$
DECLARE
  v_leave RECORD;
BEGIN
  SELECT id, requester_id, status, review_notes
    INTO v_leave
    FROM public.leave_requests
    WHERE id = p_leave_id AND requester_type = 'student' AND reviewed_by = auth.uid();

  IF v_leave IS NULL OR v_leave.status NOT IN ('approved', 'rejected') THEN
    RETURN;
  END IF;

  INSERT INTO public.notifications (user_id, title, body, type, data)
  VALUES (
    v_leave.requester_id,
    CASE WHEN v_leave.status = 'approved' THEN 'Leave Request Approved' ELSE 'Leave Request Rejected' END,
    CASE WHEN v_leave.status = 'approved' THEN 'Your leave request has been approved.' ELSE 'Your leave request has been rejected.' END
      || CASE WHEN v_leave.review_notes IS NOT NULL AND v_leave.review_notes <> '' THEN ' Note: ' || v_leave.review_notes ELSE '' END,
    'leave',
    jsonb_build_object('leave_id', v_leave.id)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
