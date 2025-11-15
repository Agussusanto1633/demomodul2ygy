# 🔴 FIX ERROR: Table 'public.services' Not Found

## Error yang Anda Dapat:
```
PostgrestException(message: Could not find the table 'public.services' in the schema cache,
code: PGRST205, details: Not Found, hint: Perhaps you meant the table 'public.users')
```

---

## ❓ Apa Artinya?

**Database Supabase Anda tidak punya table `services`!**

Ini seperti Anda membuka lemari kosong, tapi mencari baju di dalamnya. Table-nya belum dibuat!

---

## ✅ SOLUSI: Ikuti Langkah Ini (5 MENIT)

### 📍 Step 1: Buka Supabase Dashboard

1. Buka browser (Chrome/Firefox/Edge)
2. Ketik di address bar: `https://app.supabase.com`
3. **Login** dengan akun Anda
4. **Pilih project** Anda (yang URL dan ANON_KEY-nya Anda pakai di .env)

---

### 📍 Step 2: Buka SQL Editor

Di sidebar KIRI, cari dan klik:

```
🔧 SQL Editor
```

Atau langsung ke: `https://app.supabase.com/project/YOUR_PROJECT_ID/sql/new`

---

### 📍 Step 3: Buat Query Baru

Klik tombol di pojok kanan atas:

```
[+ New query]
```

Akan muncul editor kosong.

---

### 📍 Step 4: Copy SQL Script

**DI PROJECT FLUTTER INI**, buka file:

```
CREATE_SERVICES_TABLE.sql
```

**COPY SEMUA ISI FILE** (Ctrl+A → Ctrl+C)

Atau copy dari sini:

```sql
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

-- 2. ENABLE RLS
ALTER TABLE services ENABLE ROW LEVEL SECURITY;

-- 3. BUAT POLICIES
CREATE POLICY "Anyone can view services"
  ON services FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert services"
  ON services FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update services"
  ON services FOR UPDATE USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete services"
  ON services FOR DELETE USING (auth.uid() IS NOT NULL);

-- 4. INSERT DATA SAMPLE
INSERT INTO services (name, price, description, icon, color, color_hex) VALUES
  ('Cat & Polish', 'Rp 500.000', 'Poles body mobil', 'format_paint', 'blue', '#2196F3'),
  ('Ganti Oli', 'Rp 150.000', 'Ganti oli mesin', 'oil_barrel', 'orange', '#FF9800'),
  ('Tune Up', 'Rp 300.000', 'Tune up mesin', 'settings_suggest', 'green', '#4CAF50'),
  ('Balancing', 'Rp 100.000', 'Balancing roda', 'trip_origin', 'purple', '#9C27B0')
ON CONFLICT DO NOTHING;
```

---

### 📍 Step 5: Paste dan Run

1. **PASTE** script di SQL Editor (Ctrl+V)
2. Klik tombol **RUN** (atau tekan Ctrl+Enter)

   ```
   [▶ Run]
   ```

3. Tunggu 2-3 detik

---

### 📍 Step 6: Verify Sukses

Anda akan lihat di bagian bawah:

```
✅ Success. No rows returned
```

Atau:

```
✅ Success. Returned X rows
```

**Jangan panic jika ada error "policy already exists"** - itu normal, artinya policy sudah ada sebelumnya.

---

### 📍 Step 7: Check Table Sudah Ada

Masih di Supabase Dashboard, klik di sidebar kiri:

```
📊 Table Editor
```

Anda HARUS lihat table baru bernama **`services`**

Klik table `services`, Anda akan lihat 4-8 data sample!

---

### 📍 Step 8: Restart Flutter App

**PENTING!** Restart app Flutter Anda:

```bash
# Tekan 'q' di terminal untuk stop app
# Lalu run lagi:
flutter run
```

Atau di VS Code: **Stop** → **Run** lagi (F5)

---

## 🎉 SELESAI!

Sekarang buka app, masuk ke **CRUD Supabase Testing**, Anda akan lihat:

- ✅ Cat & Polish - Rp 500.000
- ✅ Ganti Oli - Rp 150.000
- ✅ Tune Up - Rp 300.000
- ✅ Balancing - Rp 100.000

**ERROR SUDAH HILANG!** 🎊

---

## ❌ Masih Error?

### Cek 1: Table `services` ada atau tidak?

Di Supabase Dashboard → Table Editor, pastikan ada table **`services`**

### Cek 2: .env file benar?

Buka file `.env`, pastikan isinya seperti ini:

```env
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci.....(panjang)
```

**URL dan KEY harus dari project Supabase yang SAMA** dengan tempat Anda run SQL!

### Cek 3: Sudah login di app?

Beberapa operasi butuh login. Coba:
1. Logout dari app
2. Login lagi
3. Buka CRUD page lagi

### Cek 4: Internet connection

Pastikan device/emulator Anda ada koneksi internet ke Supabase cloud!

---

## 🆘 Butuh Bantuan?

Kalau masih error, screenshot:
1. Hasil run SQL di Supabase (bagian Success/Error message)
2. Table Editor Supabase (tunjukkan list tables)
3. Error message di Flutter console

---

**Semoga berhasil! 🚀**
