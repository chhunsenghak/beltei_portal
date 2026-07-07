-- ── Supabase Storage Bucket for Course Materials ─────────────────────────────

INSERT INTO storage.buckets (id, name, public)
VALUES ('course-materials', 'course-materials', true)
ON CONFLICT (id) DO NOTHING;

-- RLS policies for course-materials bucket
CREATE POLICY "Teacher manages own course materials files"
  ON storage.objects FOR ALL
  USING (bucket_id = 'course-materials' AND auth.role() = 'authenticated');
