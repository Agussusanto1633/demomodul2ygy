# 🚀 SUPABASE QUICK SETUP GUIDE

## Error yang Anda Alami:
```
PostgrestException(message: Could not find the table 'public.services' in the schema cache, code: PGRST205)
```

**Penyebab:** Table `services` belum dibuat di Supabase database Anda.

---

## ✅ SOLUSI: Setup Database Supabase

### Step 1: Buka Supabase Dashboard
1. Buka browser dan pergi ke: https://app.supabase.com
2. Login ke project Anda

### Step 2: Buka SQL Editor
1. Di sidebar kiri, klik **SQL Editor**
2. Klik tombol **New Query** (pojok kanan atas)

### Step 3: Copy & Paste SQL Script
1. Buka file `SUPABASE_SETUP.sql` di project ini
2. **Copy SELURUH isi file** (Ctrl+A → Ctrl+C)
3. **Paste** ke SQL Editor di Supabase

### Step 4: Run SQL Script
1. Klik tombol **Run** (atau tekan Ctrl+Enter)
2. Tunggu sampai selesai (biasanya 2-3 detik)
3. Anda akan melihat pesan sukses: ✅ "Success. No rows returned"

### Step 5: Verify Tables Created
Jalankan query ini untuk verify:
```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';
```

Anda harus melihat 3 tables:
- ✅ `users`
- ✅ `notes`
- ✅ `services` ← **INI YANG PENTING!**

---

## 🎯 Yang Sudah Dibuat oleh SQL Script

### 1. Table `services` dengan kolom:
- `id` (UUID, auto-generated)
- `name` (text)
- `price` (text)
- `description` (text)
- `icon` (text)
- `color` (text)
- `color_hex` (text)
- `created_at` (timestamp)
- `updated_at` (timestamp)

### 2. Sample Data (8 services):
- Cat & Polish
- Ganti Oli Mesin
- Tune Up
- Balancing Ban
- Cuci Mobil Premium
- Ganti Aki
- Kuras Radiator
- Service AC

### 3. Row Level Security (RLS) Policies:
- ✅ Semua orang bisa **view** services (public read)
- ✅ User login bisa **create, update, delete** services

---

## 🔄 Setelah Setup Database

### 1. Restart Flutter App
```bash
# Stop app (tekan r di terminal atau stop di IDE)
# Lalu run lagi
flutter run
```

### 2. Test CRUD Operations
1. Buka app
2. Masuk ke halaman **CRUD Supabase Testing**
3. Coba:
   - ✅ View services (auto-load)
   - ✅ Add new service (tombol +)
   - ✅ Edit service (klik card)
   - ✅ Delete service (swipe atau tombol delete)

---

## ❌ Troubleshooting

### Error: "JWT expired" atau "Invalid JWT"
**Solusi:**
1. Logout dari app
2. Login lagi
3. Token akan di-refresh otomatis

### Error masih muncul setelah run SQL?
**Solusi:**
1. Check di Supabase Dashboard → Table Editor
2. Pastikan table `services` terlihat
3. Coba refresh Supabase dashboard (F5)
4. Tunggu 1-2 menit (cache Supabase perlu refresh)

### RLS Error: "row-level security policy"
**Solusi:**
1. Pastikan Anda sudah **LOGIN** di app
2. RLS policy memerlukan authenticated user untuk create/update/delete
3. View services bisa tanpa login (public read)

---

## 📝 Notes

- **Firebase sudah DIHAPUS** - Project ini sekarang 100% Supabase
- **No more google-services.json needed**
- **Kotlin version sudah upgraded ke 2.1.0**
- **All CRUD operations menggunakan Supabase PostgreSQL**

---

## 🎉 Done!

Setelah setup database, app Anda akan berfungsi normal tanpa error!

Jika masih ada error, cek:
1. ✅ .env file sudah benar (SUPABASE_URL & SUPABASE_ANON_KEY)
2. ✅ SQL script sudah dijalankan di Supabase
3. ✅ Table `services` terlihat di Supabase Dashboard
4. ✅ User sudah login di app

---

**Happy Coding! 🚀**
