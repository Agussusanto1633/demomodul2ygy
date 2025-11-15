# Panduan Setup Database Supabase

## File yang Dibutuhkan
- `database_full_setup.sql` - File SQL lengkap untuk setup database

## Cara Setup Database Baru

### 1. Buat Project Supabase Baru
1. Login ke [https://supabase.com](https://supabase.com)
2. Klik "New project"
3. Isi detail project:
   - Name: Pilih nama project (contoh: "service-app")
   - Database Password: Buat password yang kuat (SIMPAN password ini!)
   - Region: Pilih yang terdekat (contoh: "Southeast Asia (Singapore)")
4. Klik "Create new project"
5. Tunggu 2-3 menit sampai project selesai dibuat

### 2. Jalankan SQL Setup
1. Di dashboard Supabase, klik **"SQL Editor"** di sidebar kiri
2. Klik **"New query"**
3. Buka file `database_full_setup.sql`
4. Copy **SEMUA ISI** file tersebut
5. Paste ke SQL Editor
6. Klik **"Run"** atau tekan `Ctrl + Enter`
7. Tunggu sampai selesai (biasanya 10-30 detik)
8. Jika berhasil, akan muncul tabel hasil verification di bagian bawah

### 3. Setup Storage Bucket
Storage bucket untuk foto service harus dibuat manual:

1. Di dashboard, klik **"Storage"** di sidebar kiri
2. Klik **"New bucket"**
3. Isi detail:
   - **Name**: `service-images`
   - **Public bucket**: ✅ **CENTANG** (penting!)
   - **File size limit**: 5 MB
   - **Allowed MIME types**: `image/*`
4. Klik **"Create bucket"**
5. **Policies sudah otomatis dibuat** dari SQL script

### 4. Setup Authentication
1. Di dashboard, klik **"Authentication"** → **"Providers"**
2. Pastikan **"Email"** sudah enabled (biasanya sudah default)
3. Untuk testing, **DISABLE** "Confirm email":
   - Klik "Email" provider
   - Scroll ke bawah
   - Uncheck "Enable email confirmations"
   - Klik "Save"

### 5. Copy Credentials ke .env Flutter
1. Di dashboard Supabase, klik **"Settings"** (icon gear) → **"API"**
2. Copy 2 nilai penting:
   - **Project URL** (contoh: `https://xxxxx.supabase.co`)
   - **anon public** key (yang panjang)
3. Buka file `.env` di project Flutter Anda
4. Isi dengan:
```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=ey...xxxx...
```

### 6. Test Aplikasi
1. Run aplikasi Flutter: `flutter run`
2. Test fitur-fitur:
   - ✅ Register user baru
   - ✅ Login dengan user yang baru dibuat
   - ✅ Lihat daftar services (harus ada 10 sample data)
   - ✅ Create service baru (dengan upload foto)
   - ✅ Edit service
   - ✅ Delete service
   - ✅ Create note
   - ✅ Edit note
   - ✅ Delete note

## Struktur Database

### Tabel yang Dibuat
```
users
├── id (UUID, Primary Key, references auth.users)
├── email (TEXT)
├── username (TEXT)
├── phone_number (TEXT, nullable)
├── photo_url (TEXT, nullable)
├── created_at (TIMESTAMP)
└── last_login (TIMESTAMP, nullable)

notes
├── id (UUID, Primary Key)
├── user_id (UUID, Foreign Key → auth.users)
├── title (TEXT)
├── content (TEXT)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)

services
├── id (UUID, Primary Key)
├── name (TEXT)
├── price (TEXT)
├── description (TEXT)
├── icon (TEXT)
├── color (TEXT)
├── color_hex (TEXT, nullable)
├── image_url (TEXT, nullable)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)
```

### Storage Bucket
```
service-images/
└── services/
    ├── Service_Name_1_timestamp.jpg
    ├── Service_Name_2_timestamp.jpg
    └── ...
```

## Fitur yang Sudah Dikonfigurasi

### Row Level Security (RLS)
- ✅ **Users**: Hanya bisa view/update profile sendiri
- ✅ **Notes**: Hanya bisa CRUD notes sendiri
- ✅ **Services**: Public read, authenticated users dapat CRUD

### Auto Triggers
- ✅ Auto-create user profile saat sign up
- ✅ Auto-update `updated_at` timestamp pada notes & services

### Sample Data
- ✅ 10 sample services sudah diinsert otomatis

### Storage Policies
- ✅ Public dapat view semua gambar
- ✅ Authenticated users dapat upload/update/delete gambar

## Troubleshooting

### Error: "permission denied for table..."
**Penyebab**: RLS policies belum aktif atau salah konfigurasi

**Solusi**:
1. Cek RLS sudah enabled:
```sql
SELECT tablename, rowsecurity FROM pg_tables
WHERE schemaname = 'public';
```
2. Cek policies sudah dibuat:
```sql
SELECT tablename, policyname FROM pg_policies
WHERE schemaname = 'public';
```
3. Pastikan user sudah login di aplikasi

### Error: "Failed to upload image"
**Penyebab**: Storage bucket atau policies belum dibuat

**Solusi**:
1. Cek bucket `service-images` sudah dibuat
2. Pastikan bucket bersifat **Public**
3. Cek storage policies dengan:
```sql
SELECT policyname FROM pg_policies
WHERE schemaname = 'storage' AND tablename = 'objects';
```

### Sample Data Tidak Muncul
**Penyebab**: INSERT sample data gagal atau conflict

**Solusi**:
Run query ini untuk cek:
```sql
SELECT COUNT(*) FROM services;
```
Jika 0, run manual:
```sql
INSERT INTO services (name, price, description, icon, color, color_hex) VALUES
  ('Cat & Polish', 'Rp 500.000', 'Poles body mobil untuk hasil mengkilap', 'format_paint', 'blue', '#2196F3');
```

### Error Saat Register User
**Penyebab**: Email confirmation masih aktif

**Solusi**:
1. Dashboard → Authentication → Providers
2. Klik "Email"
3. Uncheck "Enable email confirmations"
4. Klik "Save"

### Lupa Database Password
Database password digunakan untuk:
- Direct database connection
- Database migration tools
- pg_dump/restore

Jika lupa:
1. Dashboard → Settings → Database
2. Klik "Reset database password"
3. Masukkan password baru

**Note**: Password ini BERBEDA dengan Anon Key untuk Flutter!

## Tips

### Backup Database
1. **Via Dashboard**:
   - Dashboard → Database → Backups
   - Klik "Create backup"

2. **Via pg_dump** (advanced):
```bash
pg_dump -h db.xxxxx.supabase.co -U postgres -d postgres > backup.sql
```

### Reset Database
Jika ingin mulai dari awal:

1. Buka `database_full_setup.sql`
2. **Uncomment** baris ini (hapus `--` di depannya):
```sql
DROP TABLE IF EXISTS notes CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS users CASCADE;
```
3. Run ulang script

### Monitoring
- **Database Usage**: Settings → Database → Usage
- **Storage Usage**: Storage → Settings
- **API Usage**: Settings → API → Usage

### Production Checklist
Sebelum deploy production:
- [ ] Enable email confirmation
- [ ] Setup email templates
- [ ] Enable rate limiting
- [ ] Setup custom domain
- [ ] Enable database backups
- [ ] Setup monitoring/alerting
- [ ] Review RLS policies
- [ ] Change database password

## Next Steps
1. ✅ Setup database (Anda di sini)
2. Test semua fitur aplikasi
3. Deploy aplikasi ke Play Store/App Store
4. Setup monitoring & analytics
5. Collect user feedback

## Support
- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Supabase Community](https://github.com/supabase/supabase/discussions)

---
**Created by**: Claude Code
**Last Updated**: 2025-01-12
**Version**: 1.0
