-- Add registration_open flag to semesters table
ALTER TABLE semesters
  ADD COLUMN IF NOT EXISTS registration_open BOOLEAN NOT NULL DEFAULT FALSE;
