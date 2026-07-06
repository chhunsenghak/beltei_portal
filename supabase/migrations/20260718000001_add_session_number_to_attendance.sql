-- Add session_number column and unique constraint to attendance table
ALTER TABLE public.attendance 
  ADD COLUMN IF NOT EXISTS session_number INTEGER NOT NULL DEFAULT 1 CHECK (session_number > 0);

-- Redefine unique constraint to include session_number
ALTER TABLE public.attendance
  DROP CONSTRAINT IF EXISTS attendance_student_id_class_term_course_id_date_key,
  DROP CONSTRAINT IF EXISTS attendance_student_id_class_term_course_id_date_session_key;

ALTER TABLE public.attendance
  ADD CONSTRAINT attendance_student_id_class_term_course_id_date_session_key UNIQUE (student_id, class_term_course_id, date, session_number);
