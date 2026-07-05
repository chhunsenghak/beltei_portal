-- Schedule (day/start/end/room time slots) was modeled on `courses`, but a
-- single course (e.g. "AI") can have multiple `classes` (sections) that meet
-- at different days/times — e.g. Class 01 of a course meets Monday while
-- Class 02 of the same course meets Tuesday. Storing schedule on `courses`
-- meant every class of a course was forced to share one schedule. This moves
-- it to `classes`, where it actually belongs.

ALTER TABLE classes ADD COLUMN IF NOT EXISTS schedule JSONB DEFAULT '[]'::jsonb;

-- Backfill: give each existing class a starting copy of its course's old
-- schedule. A course with 2+ classes gets the same starting point copied
-- into each — admin can differentiate them via the per-class schedule editor
-- from here on. Courses with zero classes have nothing to backfill into.
UPDATE classes c
SET schedule = co.schedule
FROM courses co
WHERE co.id = c.course_id
  AND co.schedule IS NOT NULL
  AND jsonb_array_length(co.schedule) > 0;

ALTER TABLE courses DROP COLUMN IF EXISTS schedule;
