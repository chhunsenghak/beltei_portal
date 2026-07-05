-- A class's `schedule` (JSONB on `classes`) can already have more than one
-- time slot on the same weekday (e.g. a morning session and an afternoon
-- session). Leave requests were previously always "full day" — this adds a
-- way to file leave for just one session of a day instead of the whole day.

ALTER TABLE leave_requests
  ADD COLUMN IF NOT EXISTS session_number INTEGER
    CHECK (session_number IS NULL OR session_number > 0);

COMMENT ON COLUMN leave_requests.session_number IS
  'NULL = full day leave. Otherwise the 1-based ordinal of the class session on start_date, ordered by start time (e.g. 1 = first session of the day, 2 = second).';
