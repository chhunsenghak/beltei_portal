-- ── Grading Notifications Trigger ────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.handle_assessment_submission_graded()
RETURNS TRIGGER AS $$
DECLARE
  v_assessment_title TEXT;
BEGIN
  -- Only run if grade is set and changed
  IF NEW.grade IS NOT NULL AND (TG_OP = 'INSERT' OR OLD.grade IS NULL OR OLD.grade IS DISTINCT FROM NEW.grade) THEN
    -- Get the title of the assessment
    SELECT title INTO v_assessment_title
      FROM public.assessments
      WHERE id = NEW.assessment_id;

    -- Insert a notification for the student
    INSERT INTO public.notifications (user_id, title, body, type, data)
    VALUES (
      NEW.student_id,
      'Assignment Graded',
      'Your submission for "' || COALESCE(v_assessment_title, 'Assignment') || '" has been graded: ' || NEW.grade || '.',
      'grade',
      jsonb_build_object('assessment_id', NEW.assessment_id, 'submission_id', NEW.id)
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Trigger to run when a grade is inserted or updated
CREATE OR REPLACE TRIGGER on_assessment_submission_graded
  AFTER INSERT OR UPDATE OF grade ON public.assessment_submissions
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_assessment_submission_graded();
