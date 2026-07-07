-- Link semesters to academic years via UUID foreign key
ALTER TABLE semesters ADD COLUMN academic_year_id UUID REFERENCES academic_years(id) ON DELETE CASCADE;

-- Backfill academic_year_id using the text name mapping
UPDATE semesters s
SET academic_year_id = a.id
FROM academic_years a
WHERE s.academic_year = a.name;

-- Enforce referential integrity
ALTER TABLE semesters ALTER COLUMN academic_year_id SET NOT NULL;

-- Remove old academic_year string column
ALTER TABLE semesters DROP COLUMN academic_year;

-- Deduplicate is_current: remove it from academic_years
ALTER TABLE academic_years DROP COLUMN is_current;
