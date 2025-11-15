-- ============================================
-- SIMPLE SCRIPT: BUAT TABLE SERVICES
-- ============================================
-- Copy script ini dan jalankan di Supabase SQL Editor
-- Ini akan membuat table 'services' dan isi dengan data sample

-- 1. BUAT TABLE SERVICES
CREATE TABLE IF NOT EXISTS services (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  price TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL DEFAULT 'build',
  color TEXT NOT NULL DEFAULT 'blue',
  color_hex TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. ENABLE RLS (Row Level Security)
ALTER TABLE services ENABLE ROW LEVEL SECURITY;

-- 3. BUAT POLICIES (Agar bisa di-akses)
-- Siapapun bisa view services
CREATE POLICY "Anyone can view services"
  ON services FOR SELECT
  USING (true);

-- User login bisa create/update/delete
CREATE POLICY "Authenticated users can insert services"
  ON services FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update services"
  ON services FOR UPDATE
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete services"
  ON services FOR DELETE
  USING (auth.uid() IS NOT NULL);

-- 4. INSERT DATA SAMPLE
INSERT INTO services (name, price, description, icon, color, color_hex) VALUES
  ('Cat & Polish', 'Rp 500.000', 'Poles body mobil untuk hasil mengkilap', 'format_paint', 'blue', '#2196F3'),
  ('Ganti Oli Mesin', 'Rp 150.000', 'Servis ganti oli mesin berkala', 'oil_barrel', 'orange', '#FF9800'),
  ('Tune Up', 'Rp 300.000', 'Tune up mesin untuk performa optimal', 'settings_suggest', 'green', '#4CAF50'),
  ('Balancing Ban', 'Rp 100.000', 'Balancing dan spooring roda', 'trip_origin', 'purple', '#9C27B0'),
  ('Cuci Mobil Premium', 'Rp 75.000', 'Cuci mobil lengkap dengan wax', 'water_drop', 'cyan', '#00BCD4'),
  ('Ganti Aki', 'Rp 800.000', 'Penggantian aki mobil baru', 'battery_charging_full', 'amber', '#FFC107'),
  ('Kuras Radiator', 'Rp 200.000', 'Kuras dan isi ulang air radiator', 'speed', 'red', '#F44336'),
  ('Service AC', 'Rp 250.000', 'Servis AC mobil lengkap', 'ac_unit', 'teal', '#009688')
ON CONFLICT DO NOTHING;

-- ============================================
-- SELESAI! ✅
-- ============================================
-- Setelah run script ini, restart Flutter app Anda
