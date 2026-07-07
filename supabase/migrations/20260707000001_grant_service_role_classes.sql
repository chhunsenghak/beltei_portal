-- 20260630000002_add_classes.sql granted `classes` (then `sections`) to
-- `authenticated` only, unlike every other post-initial-schema table
-- (majors, academic_years, app_settings), which granted both `authenticated`
-- and `service_role`. That gap breaks anything using the service-role key
-- against `classes` — e.g. the seeder's admin-style inserts.

GRANT SELECT, INSERT, UPDATE, DELETE ON public.classes TO service_role;
