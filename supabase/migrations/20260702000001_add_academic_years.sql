-- Academic Year as a first-class entity, separate from the free-text
-- semesters.academic_year column (which stays as-is for backward compat).

CREATE TABLE academic_years (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name       TEXT NOT NULL UNIQUE,
  start_date DATE NOT NULL,
  end_date   DATE NOT NULL,
  is_current BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE academic_years ENABLE ROW LEVEL SECURITY;

CREATE POLICY "academic_years_read"  ON academic_years FOR SELECT USING (true);
CREATE POLICY "academic_years_admin" ON academic_years FOR ALL    USING (is_admin());

GRANT SELECT, INSERT, UPDATE, DELETE ON academic_years TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON academic_years TO service_role;

-- Backfill from existing semester data so the list isn't empty on first load.
INSERT INTO academic_years (name, start_date, end_date)
SELECT academic_year, MIN(start_date), MAX(end_date)
FROM semesters
GROUP BY academic_year
ON CONFLICT (name) DO NOTHING;

UPDATE academic_years
SET is_current = true
WHERE name = (SELECT academic_year FROM semesters WHERE is_current = true LIMIT 1);
