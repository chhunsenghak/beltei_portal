-- ── App settings (single-row global config) ────────────────────────────────

CREATE TABLE app_settings (
  id                         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  university_name            TEXT NOT NULL DEFAULT 'BELTEI International University',
  contact_email              TEXT NOT NULL DEFAULT 'info@beltei.edu.kh',
  logo_url                   TEXT,
  semester_format            TEXT NOT NULL DEFAULT 'semester' CHECK (semester_format IN ('semester', 'trimester')),
  push_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  email_digests_enabled      BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at                 TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO app_settings (university_name, contact_email) VALUES
  ('BELTEI International University', 'info@beltei.edu.kh');

ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "app_settings_read"  ON app_settings FOR SELECT USING (true);
CREATE POLICY "app_settings_admin" ON app_settings FOR ALL    USING (is_admin());

GRANT SELECT, UPDATE ON app_settings TO authenticated;
GRANT SELECT ON app_settings TO anon;
GRANT SELECT, UPDATE ON app_settings TO service_role;

-- ── Storage: public app-assets bucket (university logo, etc.) ──────────────

INSERT INTO storage.buckets (id, name, public)
VALUES ('app-assets', 'app-assets', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "app_assets_public_read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'app-assets');

CREATE POLICY "app_assets_admin_write"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'app-assets' AND is_admin());

CREATE POLICY "app_assets_admin_update"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'app-assets' AND is_admin());

CREATE POLICY "app_assets_admin_delete"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'app-assets' AND is_admin());
