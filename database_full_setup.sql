-- ============================================
-- SUPABASE DATABASE FULL SETUP
-- ============================================
-- File ini berisi setup lengkap database Supabase
-- Aplikasi: Service Management App
--
-- CARA PENGGUNAAN:
-- 1. Login ke Supabase Dashboard (https://supabase.com)
-- 2. Buat Project Baru atau Pilih Project yang Sudah Ada
-- 3. Buka SQL Editor (di sidebar kiri)
-- 4. Klik "New Query"
-- 5. Copy SEMUA isi file ini dan paste ke SQL Editor
-- 6. Klik "Run" atau tekan Ctrl+Enter
-- 7. Tunggu sampai selesai (sekitar 10-30 detik)
-- 8. Lanjutkan ke setup Storage Bucket (lihat bagian akhir)
--
-- ============================================
-- DATABASE INFO
-- ============================================
-- Tables:
--   1. users          - Profil pengguna (linked to auth.users)
--   2. notes          - Catatan pribadi pengguna
--   3. services       - Daftar layanan servis (dengan foto)
--
-- Storage Buckets:
--   1. service-images - Untuk menyimpan foto layanan
--
-- ============================================


-- ============================================
-- STEP 1: ENABLE REQUIRED EXTENSIONS
-- ============================================
-- Extension untuk generate UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Extension untuk generate random UUID
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ============================================
-- STEP 2: DROP EXISTING TABLES (OPTIONAL)
-- ============================================
-- UNCOMMENT baris di bawah jika Anda ingin RESET database
-- HATI-HATI: Ini akan MENGHAPUS semua data!
--
-- DROP TABLE IF EXISTS notes CASCADE;
-- DROP TABLE IF EXISTS services CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;


-- ============================================
-- STEP 3: CREATE TABLES
-- ============================================

-- --------------------------------------------
-- 3.1. TABLE: users
-- --------------------------------------------
-- Tabel untuk menyimpan profil pengguna
-- Linked ke auth.users (Supabase Authentication)

CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  username TEXT NOT NULL,
  phone_number TEXT,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  last_login TIMESTAMP WITH TIME ZONE,

  -- Constraints
  CONSTRAINT users_email_check CHECK (char_length(email) >= 3),
  CONSTRAINT users_username_check CHECK (char_length(username) >= 3)
);

-- Add indexes untuk performa lebih baik
CREATE INDEX IF NOT EXISTS users_email_idx ON public.users(email);
CREATE INDEX IF NOT EXISTS users_username_idx ON public.users(username);
CREATE INDEX IF NOT EXISTS users_created_at_idx ON public.users(created_at DESC);

-- Add comment
COMMENT ON TABLE public.users IS 'User profiles linked to Supabase Auth';


-- --------------------------------------------
-- 3.2. TABLE: notes
-- --------------------------------------------
-- Tabel untuk menyimpan catatan pribadi pengguna

CREATE TABLE IF NOT EXISTS public.notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,

  -- Constraints
  CONSTRAINT notes_title_check CHECK (char_length(title) >= 1),
  CONSTRAINT notes_content_check CHECK (char_length(content) >= 1)
);

-- Add indexes untuk performa lebih baik
CREATE INDEX IF NOT EXISTS notes_user_id_idx ON public.notes(user_id);
CREATE INDEX IF NOT EXISTS notes_created_at_idx ON public.notes(created_at DESC);
CREATE INDEX IF NOT EXISTS notes_updated_at_idx ON public.notes(updated_at DESC);
CREATE INDEX IF NOT EXISTS notes_title_idx ON public.notes USING gin(to_tsvector('english', title));
CREATE INDEX IF NOT EXISTS notes_content_idx ON public.notes USING gin(to_tsvector('english', content));

-- Add comment
COMMENT ON TABLE public.notes IS 'User notes/memos';


-- --------------------------------------------
-- 3.3. TABLE: services
-- --------------------------------------------
-- Tabel untuk menyimpan daftar layanan servis

CREATE TABLE IF NOT EXISTS public.services (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  price TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL DEFAULT 'build',
  color TEXT NOT NULL DEFAULT 'blue',
  color_hex TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,

  -- Constraints
  CONSTRAINT services_name_check CHECK (char_length(name) >= 1),
  CONSTRAINT services_price_check CHECK (char_length(price) >= 1),
  CONSTRAINT services_description_check CHECK (char_length(description) >= 1)
);

-- Add indexes untuk performa lebih baik
CREATE INDEX IF NOT EXISTS services_name_idx ON public.services(name);
CREATE INDEX IF NOT EXISTS services_created_at_idx ON public.services(created_at DESC);
CREATE INDEX IF NOT EXISTS services_updated_at_idx ON public.services(updated_at DESC);
CREATE INDEX IF NOT EXISTS services_search_idx ON public.services USING gin(to_tsvector('english', name || ' ' || description));

-- Add comment
COMMENT ON TABLE public.services IS 'Service catalog with images';


-- ============================================
-- STEP 4: ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;


-- ============================================
-- STEP 5: CREATE RLS POLICIES
-- ============================================

-- --------------------------------------------
-- 5.1. POLICIES FOR: users
-- --------------------------------------------

-- Drop existing policies if any (untuk re-run script)
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;

-- SELECT: Users can view their own profile
CREATE POLICY "Users can view their own profile"
  ON public.users
  FOR SELECT
  USING (auth.uid() = id);

-- INSERT: Users can create their own profile (untuk sign up)
CREATE POLICY "Users can insert their own profile"
  ON public.users
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- UPDATE: Users can update their own profile
CREATE POLICY "Users can update their own profile"
  ON public.users
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);


-- --------------------------------------------
-- 5.2. POLICIES FOR: notes
-- --------------------------------------------

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view their own notes" ON public.notes;
DROP POLICY IF EXISTS "Users can create their own notes" ON public.notes;
DROP POLICY IF EXISTS "Users can update their own notes" ON public.notes;
DROP POLICY IF EXISTS "Users can delete their own notes" ON public.notes;

-- SELECT: Users can view their own notes
CREATE POLICY "Users can view their own notes"
  ON public.notes
  FOR SELECT
  USING (auth.uid() = user_id);

-- INSERT: Users can create their own notes
CREATE POLICY "Users can create their own notes"
  ON public.notes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- UPDATE: Users can update their own notes
CREATE POLICY "Users can update their own notes"
  ON public.notes
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- DELETE: Users can delete their own notes
CREATE POLICY "Users can delete their own notes"
  ON public.notes
  FOR DELETE
  USING (auth.uid() = user_id);


-- --------------------------------------------
-- 5.3. POLICIES FOR: services
-- --------------------------------------------

-- Drop existing policies if any
DROP POLICY IF EXISTS "Anyone can view services" ON public.services;
DROP POLICY IF EXISTS "Authenticated users can create services" ON public.services;
DROP POLICY IF EXISTS "Authenticated users can update services" ON public.services;
DROP POLICY IF EXISTS "Authenticated users can delete services" ON public.services;

-- SELECT: Anyone can view services (public read)
CREATE POLICY "Anyone can view services"
  ON public.services
  FOR SELECT
  USING (true);

-- INSERT: Only authenticated users can create services
CREATE POLICY "Authenticated users can create services"
  ON public.services
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- UPDATE: Only authenticated users can update services
CREATE POLICY "Authenticated users can update services"
  ON public.services
  FOR UPDATE
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

-- DELETE: Only authenticated users can delete services
CREATE POLICY "Authenticated users can delete services"
  ON public.services
  FOR DELETE
  USING (auth.uid() IS NOT NULL);


-- ============================================
-- STEP 6: CREATE FUNCTIONS & TRIGGERS
-- ============================================

-- --------------------------------------------
-- 6.1. FUNCTION: update_updated_at_column()
-- --------------------------------------------
-- Function untuk auto-update kolom updated_at

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add comment
COMMENT ON FUNCTION public.update_updated_at_column() IS 'Automatically update updated_at timestamp';


-- --------------------------------------------
-- 6.2. TRIGGERS: Auto-update updated_at
-- --------------------------------------------

-- Drop existing triggers if any
DROP TRIGGER IF EXISTS update_notes_updated_at ON public.notes;
DROP TRIGGER IF EXISTS update_services_updated_at ON public.services;

-- Trigger for notes table
CREATE TRIGGER update_notes_updated_at
  BEFORE UPDATE ON public.notes
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger for services table
CREATE TRIGGER update_services_updated_at
  BEFORE UPDATE ON public.services
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();


-- --------------------------------------------
-- 6.3. FUNCTION: handle_new_user()
-- --------------------------------------------
-- Function untuk auto-create user profile saat sign up

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, username, created_at, last_login)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    NOW(),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comment
COMMENT ON FUNCTION public.handle_new_user() IS 'Automatically create user profile on sign up';


-- --------------------------------------------
-- 6.4. TRIGGER: Auto-create user profile
-- --------------------------------------------

-- Drop existing trigger if any
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Trigger untuk create user profile otomatis saat sign up
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();


-- ============================================
-- STEP 7: INSERT SAMPLE DATA
-- ============================================

-- --------------------------------------------
-- 7.1. INSERT SAMPLE SERVICES
-- --------------------------------------------

INSERT INTO public.services (name, price, description, icon, color, color_hex) VALUES
  ('Cat & Polish', 'Rp 500.000', 'Poles body mobil untuk hasil mengkilap dan memukau. Menggunakan bahan premium berkualitas tinggi.', 'format_paint', 'blue', '#2196F3'),
  ('Ganti Oli Mesin', 'Rp 150.000', 'Servis ganti oli mesin berkala untuk menjaga performa mesin tetap optimal dan awet.', 'oil_barrel', 'orange', '#FF9800'),
  ('Tune Up', 'Rp 300.000', 'Tune up mesin lengkap untuk performa optimal dan efisiensi bahan bakar maksimal.', 'settings_suggest', 'green', '#4CAF50'),
  ('Balancing Ban', 'Rp 100.000', 'Balancing dan spooring roda untuk kenyamanan berkendara dan umur ban lebih lama.', 'trip_origin', 'purple', '#9C27B0'),
  ('Cuci Mobil Premium', 'Rp 75.000', 'Cuci mobil lengkap dengan wax dan poles untuk hasil bersih mengkilap.', 'water_drop', 'cyan', '#00BCD4'),
  ('Ganti Aki', 'Rp 800.000', 'Penggantian aki mobil baru dengan garansi resmi dan instalasi profesional.', 'battery_charging_full', 'amber', '#FFC107'),
  ('Kuras Radiator', 'Rp 200.000', 'Kuras dan isi ulang air radiator untuk sistem pendingin mesin yang optimal.', 'speed', 'red', '#F44336'),
  ('Service AC', 'Rp 250.000', 'Servis AC mobil lengkap: isi freon, cuci evaporator, cek kompresor.', 'ac_unit', 'teal', '#009688'),
  ('Ganti Rem Cakram', 'Rp 600.000', 'Penggantian rem cakram depan/belakang dengan spare part original berkualitas.', 'settings', 'indigo', '#3F51B5'),
  ('Spooring & Balancing', 'Rp 175.000', 'Spooring dan balancing roda keempat untuk handling optimal dan ban awet.', 'build', 'pink', '#E91E63')
ON CONFLICT (id) DO NOTHING;


-- ============================================
-- STEP 8: SETUP STORAGE BUCKET
-- ============================================
-- PENTING: Storage bucket tidak bisa dibuat via SQL!
-- Anda harus setup secara manual di Dashboard atau via API
--
-- Cara Setup Storage Bucket:
-- 1. Buka Supabase Dashboard
-- 2. Klik "Storage" di sidebar kiri
-- 3. Klik "New bucket"
-- 4. Isi detail:
--    - Name: service-images
--    - Public bucket: CENTANG (✓)
--    - File size limit: 5MB
--    - Allowed MIME types: image/*
-- 5. Klik "Create bucket"
--
-- Setelah bucket dibuat, jalankan SQL di bawah untuk setup policies:

-- --------------------------------------------
-- 8.1. STORAGE POLICIES FOR: service-images
-- --------------------------------------------

-- Drop existing policies if any
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON storage.objects;
DROP POLICY IF EXISTS "Give public access to images" ON storage.objects;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON storage.objects;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON storage.objects;

-- SELECT: Public dapat melihat semua gambar
CREATE POLICY "Give public access to images"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'service-images');

-- INSERT: Authenticated users dapat upload gambar
CREATE POLICY "Enable insert for authenticated users"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'service-images');

-- UPDATE: Authenticated users dapat update gambar
CREATE POLICY "Enable update for authenticated users"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (bucket_id = 'service-images')
  WITH CHECK (bucket_id = 'service-images');

-- DELETE: Authenticated users dapat delete gambar
CREATE POLICY "Enable delete for authenticated users"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (bucket_id = 'service-images');


-- ============================================
-- STEP 9: VERIFY SETUP
-- ============================================

-- Verify tables created
SELECT
  table_name,
  table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('users', 'notes', 'services')
ORDER BY table_name;

-- Verify RLS enabled
SELECT
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('users', 'notes', 'services');

-- Verify policies created
SELECT
  schemaname,
  tablename,
  policyname
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Verify sample data inserted
SELECT
  (SELECT COUNT(*) FROM public.services) as total_services,
  (SELECT COUNT(*) FROM public.notes) as total_notes,
  (SELECT COUNT(*) FROM public.users) as total_users;


-- ============================================
-- STEP 10: AUTHENTICATION SETTINGS
-- ============================================
-- Setup Authentication di Supabase Dashboard:
--
-- 1. Buka "Authentication" → "Providers"
-- 2. Enable "Email"
-- 3. DISABLE "Confirm email" (untuk testing)
--    ATAU setup Email Template jika ingin production-ready
--
-- 4. Optional - Enable provider lain:
--    - Google OAuth
--    - GitHub OAuth
--    - etc.
--


-- ============================================
-- SETUP SELESAI!
-- ============================================
--
-- CHECKLIST:
-- ✓ Tables created (users, notes, services)
-- ✓ RLS enabled untuk semua tables
-- ✓ Policies created untuk semua tables
-- ✓ Triggers created untuk auto-update timestamps
-- ✓ Sample data inserted (10 services)
-- ✓ Storage policies created
--
-- NEXT STEPS:
-- 1. Setup Storage Bucket "service-images" (lihat STEP 8)
-- 2. Setup Authentication Settings (lihat STEP 10)
-- 3. Copy Project URL dan Anon Key ke file .env Flutter:
--    SUPABASE_URL=your_project_url
--    SUPABASE_ANON_KEY=your_anon_key
-- 4. Test aplikasi Flutter dengan:
--    - Register user baru
--    - Login
--    - Create/Read/Update/Delete services
--    - Create/Read/Update/Delete notes
--    - Upload foto service
--
-- TROUBLESHOOTING:
-- - Jika error "permission denied", cek RLS policies
-- - Jika error "relation does not exist", cek nama tabel
-- - Jika error saat upload foto, cek storage bucket dan policies
-- - Jika error saat register, cek authentication settings
--
-- BACKUP DATABASE:
-- Untuk backup, gunakan:
-- 1. Supabase Dashboard → Database → Backups
-- 2. Atau export via pg_dump
--
-- RESET DATABASE:
-- Jika ingin reset, uncomment bagian DROP TABLE di STEP 2
-- lalu run ulang script ini
--
-- ============================================
-- CREATED BY: Claude Code
-- VERSION: 1.0
-- LAST UPDATED: 2025-01-12
-- ============================================
