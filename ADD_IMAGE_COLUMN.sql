-- ============================================
-- ADD IMAGE_URL COLUMN TO SERVICES TABLE
-- ============================================

-- Tambah kolom image_url jika belum ada
ALTER TABLE services
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Verifikasi kolom sudah ditambahkan
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'services'
AND column_name = 'image_url';

-- ============================================
-- STORAGE BUCKET POLICIES
-- ============================================

-- 1. Policy: Enable INSERT for authenticated users
CREATE POLICY IF NOT EXISTS "Enable insert for authenticated users"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'service-images');

-- 2. Policy: Give public access to images (SELECT)
CREATE POLICY IF NOT EXISTS "Give public access to images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'service-images');

-- 3. Policy: Enable UPDATE for authenticated users
CREATE POLICY IF NOT EXISTS "Enable update for authenticated users"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'service-images')
WITH CHECK (bucket_id = 'service-images');

-- 4. Policy: Enable DELETE for authenticated users
CREATE POLICY IF NOT EXISTS "Enable delete for authenticated users"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'service-images');

-- ============================================
-- DONE!
-- ============================================
-- Sekarang Anda bisa:
-- 1. Upload foto saat create service
-- 2. Update foto saat edit service
-- 3. Delete foto saat delete service
-- 4. View foto di Service Card dan Detail Dialog
