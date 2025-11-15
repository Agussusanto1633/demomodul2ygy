-- ============================================
-- ADD IMAGE UPLOAD FEATURE - SUPABASE SQL
-- ============================================
-- Copy dan jalankan di Supabase SQL Editor!

-- STEP 1: Tambah column image_url ke table services
ALTER TABLE services
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- STEP 2: Create Storage Bucket untuk service images
-- (Ini akan membuat bucket jika belum ada)
INSERT INTO storage.buckets (id, name, public)
VALUES ('service-images', 'service-images', true)
ON CONFLICT (id) DO NOTHING;

-- STEP 3: Enable RLS untuk storage bucket
-- Policy untuk VIEW images (public)
CREATE POLICY IF NOT EXISTS "Anyone can view service images"
ON storage.objects FOR SELECT
USING (bucket_id = 'service-images');

-- Policy untuk UPLOAD images (authenticated users only)
CREATE POLICY IF NOT EXISTS "Authenticated users can upload service images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'service-images'
  AND auth.uid() IS NOT NULL
);

-- Policy untuk UPDATE images
CREATE POLICY IF NOT EXISTS "Authenticated users can update service images"
ON storage.objects FOR UPDATE
USING (bucket_id = 'service-images' AND auth.uid() IS NOT NULL);

-- Policy untuk DELETE images
CREATE POLICY IF NOT EXISTS "Authenticated users can delete service images"
ON storage.objects FOR DELETE
USING (bucket_id = 'service-images' AND auth.uid() IS NOT NULL);

-- ============================================
-- VERIFY - Check if column added successfully
-- ============================================
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'services';

-- You should see 'image_url' column in the results!

-- ============================================
-- ✅ DONE! Next steps:
-- ============================================
-- 1. Run Flutter app
-- 2. Try adding a service with image upload
-- 3. Images will be stored in 'service-images' bucket
