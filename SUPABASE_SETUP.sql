-- ============================================
-- SUPABASE DATABASE SETUP
-- ============================================
-- Jalankan script ini di Supabase SQL Editor
-- Dashboard → SQL Editor → New Query → Paste script ini → Run

-- ============================================
-- 1. CREATE USERS TABLE
-- ============================================
create table if not exists users (
  id uuid primary key references auth.users on delete cascade,
  email text not null,
  username text not null,
  phone_number text,
  photo_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  last_login timestamp with time zone
);

-- Add index for better performance
create index if not exists users_email_idx on users(email);

-- ============================================
-- 2. CREATE NOTES TABLE
-- ============================================
create table if not exists notes (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  title text not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Add index for better performance
create index if not exists notes_user_id_idx on notes(user_id);
create index if not exists notes_created_at_idx on notes(created_at desc);

-- ============================================
-- 3. CREATE SERVICES TABLE
-- ============================================
create table if not exists services (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  price text not null,
  description text not null,
  icon text not null default 'build',
  color text not null default 'blue',
  color_hex text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Add index for better performance
create index if not exists services_name_idx on services(name);
create index if not exists services_created_at_idx on services(created_at desc);

-- ============================================
-- 4. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS for users table
alter table users enable row level security;

-- Enable RLS for notes table
alter table notes enable row level security;

-- Enable RLS for services table
alter table services enable row level security;

-- ============================================
-- 5. CREATE RLS POLICIES FOR USERS TABLE
-- ============================================

-- Users can view their own profile
create policy "Users can view their own profile"
  on users for select
  using (auth.uid() = id);

-- Users can insert their own profile (needed for sign up)
create policy "Users can insert their own profile"
  on users for insert
  with check (auth.uid() = id);

-- Users can update their own profile
create policy "Users can update their own profile"
  on users for update
  using (auth.uid() = id);

-- ============================================
-- 6. CREATE RLS POLICIES FOR NOTES TABLE
-- ============================================

-- Users can view their own notes
create policy "Users can view their own notes"
  on notes for select
  using (auth.uid() = user_id);

-- Users can create their own notes
create policy "Users can create their own notes"
  on notes for insert
  with check (auth.uid() = user_id);

-- Users can update their own notes
create policy "Users can update their own notes"
  on notes for update
  using (auth.uid() = user_id);

-- Users can delete their own notes
create policy "Users can delete their own notes"
  on notes for delete
  using (auth.uid() = user_id);

-- ============================================
-- 7. CREATE RLS POLICIES FOR SERVICES TABLE
-- ============================================

-- Anyone can view services (public read)
create policy "Anyone can view services"
  on services for select
  using (true);

-- Only authenticated users can create services
create policy "Authenticated users can create services"
  on services for insert
  with check (auth.uid() is not null);

-- Only authenticated users can update services
create policy "Authenticated users can update services"
  on services for update
  using (auth.uid() is not null);

-- Only authenticated users can delete services
create policy "Authenticated users can delete services"
  on services for delete
  using (auth.uid() is not null);

-- ============================================
-- 8. CREATE FUNCTION TO UPDATE UPDATED_AT
-- ============================================

-- Function to automatically update updated_at timestamp
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = timezone('utc'::text, now());
  return new;
end;
$$ language plpgsql;

-- Trigger to call the function before update on notes
create trigger update_notes_updated_at
  before update on notes
  for each row
  execute procedure update_updated_at_column();

-- Trigger to call the function before update on services
create trigger update_services_updated_at
  before update on services
  for each row
  execute procedure update_updated_at_column();

-- ============================================
-- 9. INSERT SAMPLE SERVICES DATA
-- ============================================
insert into services (name, price, description, icon, color, color_hex) values
  ('Cat & Polish', 'Rp 500.000', 'Poles body mobil untuk hasil mengkilap', 'format_paint', 'blue', '#2196F3'),
  ('Ganti Oli Mesin', 'Rp 150.000', 'Servis ganti oli mesin berkala', 'oil_barrel', 'orange', '#FF9800'),
  ('Tune Up', 'Rp 300.000', 'Tune up mesin untuk performa optimal', 'settings_suggest', 'green', '#4CAF50'),
  ('Balancing Ban', 'Rp 100.000', 'Balancing dan spooring roda', 'trip_origin', 'purple', '#9C27B0'),
  ('Cuci Mobil Premium', 'Rp 75.000', 'Cuci mobil lengkap dengan wax', 'water_drop', 'cyan', '#00BCD4'),
  ('Ganti Aki', 'Rp 800.000', 'Penggantian aki mobil baru', 'battery_charging_full', 'amber', '#FFC107'),
  ('Kuras Radiator', 'Rp 200.000', 'Kuras dan isi ulang air radiator', 'speed', 'red', '#F44336'),
  ('Service AC', 'Rp 250.000', 'Servis AC mobil lengkap', 'ac_unit', 'teal', '#009688')
on conflict do nothing;

-- ============================================
-- 10. VERIFY TABLES CREATED
-- ============================================
-- Run this to verify tables are created:
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- ============================================
-- SETUP COMPLETE!
-- ============================================
-- Next Steps:
-- 1. Go to Storage → Create new bucket "profile-images" → Set to Public
-- 2. Go to Authentication → Settings → Email Auth →
--    DISABLE "Confirm email" untuk testing (atau setup email template)
-- 3. Test dengan register user baru di aplikasi Flutter
