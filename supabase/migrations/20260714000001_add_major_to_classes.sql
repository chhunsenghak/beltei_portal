-- Classes can be filtered/organized by major in the admin UI (mirroring the
-- existing faculty_id), so a cohort can be tagged with the major it belongs
-- to (e.g. "Software Engineering Year 1 Evening") independent of which
-- courses happen to be in its curriculum.

ALTER TABLE classes ADD COLUMN IF NOT EXISTS major_id UUID REFERENCES majors(id);

CREATE INDEX IF NOT EXISTS classes_major_id_idx ON classes (major_id);
