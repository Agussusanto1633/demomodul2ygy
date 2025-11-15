# 🚀 PANDUAN SETUP APLIKASI CORNER GARAGE

## ⚠️ BUG YANG TELAH DIPERBAIKI:

### 1. Database Supabase Belum Di-Setup (BUG UTAMA)
### 2. Badge Masih Mengatakan "FIRESTORE"
### 3. Dependency Firebase Tidak Digunakan
### 4. Email Confirmation di Supabase

---

## 📋 LANGKAH-LANGKAH SETUP

### STEP 1: Setup Database Supabase

1. **Buka Supabase Dashboard**
   - Login ke https://app.supabase.com
   - Pilih project Anda

2. **Jalankan SQL Script**
   - Pergi ke **SQL Editor** (icon database di sidebar)
   - Klik **New Query**
   - Copy seluruh isi file `SUPABASE_SETUP.sql` yang sudah dibuat
   - Paste di SQL Editor
   - Klik **Run** atau tekan `Ctrl + Enter`
   - Tunggu sampai muncul "Success. No rows returned"

3. **Verify Tables Created**
   ```sql
   -- Run query ini untuk cek tabel yang sudah dibuat:
   SELECT table_name FROM information_schema.tables
   WHERE table_schema = 'public';
   ```
   Anda harus melihat tabel: `users` dan `notes`

---

### STEP 2: Setup Storage Bucket

1. **Pergi ke Storage** (icon folder di sidebar)
2. **Create New Bucket**
   - Klik tombol **New bucket**
   - Bucket name: `profile-images`
   - **PENTING:** Set bucket sebagai **Public** (centang "Public bucket")
   - Klik **Create bucket**

3. **Set Storage Policies** (Opsional)
   - Klik bucket `profile-images`
   - Pergi ke tab **Policies**
   - Buat policy untuk allow authenticated users to upload:

   ```sql
   create policy "Authenticated users can upload profile images"
   on storage.objects for insert
   to authenticated
   with check (bucket_id = 'profile-images');

   create policy "Users can update their own profile images"
   on storage.objects for update
   to authenticated
   using (bucket_id = 'profile-images');

   create policy "Users can delete their own profile images"
   on storage.objects for delete
   to authenticated
   using (bucket_id = 'profile-images');

   create policy "Public can view profile images"
   on storage.objects for select
   to public
   using (bucket_id = 'profile-images');
   ```

---

### STEP 3: Disable Email Confirmation (PENTING!)

**⚠️ STEP INI SANGAT PENTING - Jika tidak dilakukan, registrasi akan gagal!**

1. **Pergi ke Authentication Settings**
   - Klik **Authentication** (icon shield di sidebar)
   - Klik **Settings** atau **Configuration**
   - Scroll ke bagian **Email Auth**

2. **Disable Email Confirmation**
   - Cari setting **"Confirm email"**
   - **MATIKAN/DISABLE** setting ini
   - Klik **Save**

**Alternatif:** Jika ingin menggunakan email confirmation, Anda perlu setup email template di Supabase.

---

### STEP 4: Verify .env File

1. **Cek file `.env` di root project** (sudah ada)
   ```env
   SUPABASE_URL=https://nvdhlhcwbxsskpqyxdom.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

2. **Pastikan credentials benar**
   - Jika perlu update, dapatkan credentials dari:
   - Supabase Dashboard → Settings → API
   - Copy **Project URL** dan **anon public** key

---

### STEP 5: Clean & Install Dependencies

**Jalankan command berikut di terminal:**

```bash
# 1. Clean project
flutter clean

# 2. Get dependencies (Firebase sudah dihapus)
flutter pub get

# 3. Run app
flutter run
```

---

## 🎯 CARA TESTING APLIKASI

### 1. Register User Baru

1. Buka aplikasi
2. Klik tombol **"Daftar"**
3. Isi form:
   - Nama Lengkap: `Test User`
   - Email: `test@example.com`
   - Password: `123456` (minimal 6 karakter)
   - Konfirmasi Password: `123456`
4. Klik **"Daftar"**
5. Jika berhasil:
   - Akan muncul snackbar hijau "Registrasi Berhasil"
   - Otomatis kembali ke halaman login
   - Email sudah terisi

### 2. Login

1. Masukkan email dan password yang baru didaftarkan
2. (Opsional) Centang "Ingat Saya" jika ingin credentials tersimpan
3. Klik **"Login"**
4. Jika berhasil:
   - Akan muncul snackbar hijau "Login Berhasil"
   - Redirect ke halaman Home

### 3. Verify di Supabase Dashboard

**Cek User di Authentication:**
- Dashboard → Authentication → Users
- User baru harus muncul di list

**Cek Data di Database:**
```sql
-- Cek tabel users
SELECT * FROM users;

-- Cek auth users
SELECT * FROM auth.users;
```

---

## ❌ TROUBLESHOOTING

### Problem: Login Gagal Terus

**Kemungkinan penyebab:**

1. **Database belum di-setup**
   - Jalankan `SUPABASE_SETUP.sql` di SQL Editor
   - Verify dengan query: `SELECT * FROM users;`

2. **Email confirmation masih enabled**
   - Authentication → Settings → Email Auth
   - Disable "Confirm email"

3. **RLS Policies belum dibuat**
   - Jalankan ulang `SUPABASE_SETUP.sql`
   - Cek dengan: `SELECT * FROM information_schema.table_privileges WHERE table_name = 'users';`

4. **Credentials salah**
   - Cek file `.env`
   - Verify SUPABASE_URL dan SUPABASE_ANON_KEY

### Problem: Error saat Register

**Cek log di console:**

```dart
// Log akan menampilkan error detail:
// ❌ [Supabase] Sign up error: ...
```

**Solusi umum:**
- Pastikan email belum terdaftar
- Pastikan password minimal 6 karakter
- Cek email confirmation sudah disabled

### Problem: Error "Failed to create user profile"

**Penyebab:**
- RLS policies belum dibuat
- User tidak bisa insert ke tabel `users`

**Solusi:**
1. Jalankan ulang SQL script
2. Verify policy dengan:
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'users';
   ```

---

## 📝 PERUBAHAN YANG DILAKUKAN

### ✅ File yang Diubah:

1. **pubspec.yaml** - Menghapus dependency Firebase:
   - ❌ firebase_core
   - ❌ firebase_auth
   - ❌ cloud_firestore
   - ❌ firebase_storage
   - ❌ google_sign_in

2. **lib/views/home_page.dart** - Update badge:
   - ❌ "FIRESTORE" → ✅ "SUPABASE"

### ✅ File yang Ditambahkan:

1. **SUPABASE_SETUP.sql** - Script untuk setup database
2. **SETUP_PANDUAN.md** - Panduan lengkap (file ini)

---

## 🎉 SELESAI!

Setelah mengikuti semua step di atas, aplikasi Anda seharusnya sudah bisa:
- ✅ Register user baru
- ✅ Login dengan email & password
- ✅ Menyimpan data user ke Supabase
- ✅ Menampilkan data user di halaman home
- ✅ Logout

**Selamat mencoba! 🚀**

---

## 📞 Support

Jika masih ada masalah:
1. Cek console log untuk error detail
2. Verify semua step sudah dijalankan
3. Cek Supabase Dashboard untuk verify data
