-- Schema drift found 2026-07-08: the remote project's `profiles` table and its
-- `handle_new_user()` trigger were still on an older `full_name` shape, while
-- every migration file (from 20260625170516_initial_schema.sql onward) and
-- ~25 call sites across student/teacher/admin services + login/signup already
-- assume `first_name`/`last_name`. Remote had only ever accumulated 1 manually
-- created admin row, so this realigns the live schema to match the migration
-- history and app code (rather than the other way around).

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS first_name TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_name TEXT;

-- Fresh databases built from the (already-corrected) initial schema never had
-- `full_name`, so only backfill from it when it's actually present.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'full_name'
  ) THEN
    UPDATE public.profiles
    SET first_name = COALESCE(NULLIF(split_part(full_name, ' ', 1), ''), ''),
        last_name = COALESCE(NULLIF(substring(full_name FROM position(' ' IN full_name) + 1), ''), '')
    WHERE full_name IS NOT NULL
      AND (first_name IS NULL OR last_name IS NULL);
  END IF;
END $$;

UPDATE public.profiles SET first_name = '' WHERE first_name IS NULL;
UPDATE public.profiles SET last_name = '' WHERE last_name IS NULL;

ALTER TABLE public.profiles ALTER COLUMN first_name SET NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN last_name SET NOT NULL;
ALTER TABLE public.profiles DROP COLUMN IF EXISTS full_name;

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, first_name, last_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'first_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
