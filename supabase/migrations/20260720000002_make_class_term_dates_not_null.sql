-- Set existing class terms start_date and end_date using the parent semester's dates if they are null
UPDATE class_terms
SET start_date = semesters.start_date
FROM semesters
WHERE class_terms.semester_id = semesters.id AND class_terms.start_date IS NULL;

UPDATE class_terms
SET end_date = semesters.end_date
FROM semesters
WHERE class_terms.semester_id = semesters.id AND class_terms.end_date IS NULL;

-- Enforce NOT NULL constraints
ALTER TABLE class_terms ALTER COLUMN start_date SET NOT NULL;
ALTER TABLE class_terms ALTER COLUMN end_date SET NOT NULL;
