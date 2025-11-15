# Setup Supabase Storage untuk Upload Foto

## Langkah Setup di Supabase Dashboard

### 1. Buka Supabase Dashboard
- Login ke https://supabase.com
- Pilih project Anda

### 2. Buat Storage Bucket
1. Di sidebar kiri, klik **Storage**
2. Klik tombol **New bucket**
3. Isi detail bucket:
   - **Name**: `service-images`
   - **Public bucket**: ✅ CENTANG (supaya gambar bisa diakses publik)
   - **File size limit**: 5MB (atau sesuai kebutuhan)
   - **Allowed MIME types**: `image/*` (semua jenis gambar)
4. Klik **Create bucket**

### 3. Set Storage Policy (RLS - Row Level Security)

Setelah bucket dibuat, Anda perlu membuat policy untuk mengatur akses:

#### 3.1 Policy untuk Upload (INSERT)
```sql
-- Policy: Enable insert for authenticated users
CREATE POLICY "Enable insert for authenticated users"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'service-images');
```

Atau melalui Dashboard:
1. Klik bucket `service-images`
2. Klik tab **Policies**
3. Klik **New Policy**
4. Pilih **For full customization**
5. Isi:
   - **Policy name**: `Enable insert for authenticated users`
   - **Policy command**: `INSERT`
   - **Target roles**: `authenticated`
   - **WITH CHECK expression**: `bucket_id = 'service-images'`
6. Klik **Review** lalu **Save policy**

#### 3.2 Policy untuk Public Access (SELECT)
```sql
-- Policy: Give public access to images
CREATE POLICY "Give public access to images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'service-images');
```

Atau melalui Dashboard:
1. Klik **New Policy** lagi
2. Pilih **For full customization**
3. Isi:
   - **Policy name**: `Give public access to images`
   - **Policy command**: `SELECT`
   - **Target roles**: `public`
   - **USING expression**: `bucket_id = 'service-images'`
4. Klik **Review** lalu **Save policy**

#### 3.3 Policy untuk Update (UPDATE)
```sql
-- Policy: Enable update for authenticated users
CREATE POLICY "Enable update for authenticated users"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'service-images')
WITH CHECK (bucket_id = 'service-images');
```

#### 3.4 Policy untuk Delete (DELETE)
```sql
-- Policy: Enable delete for authenticated users
CREATE POLICY "Enable delete for authenticated users"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'service-images');
```

### 4. Verifikasi Setup

Untuk memastikan bucket sudah benar:
1. Coba upload foto dari aplikasi Flutter
2. Cek di **Storage** > **service-images**
3. Pastikan gambar muncul di folder `services/`

## Cara Menggunakan Fitur Upload Foto

### 1. Create Service dengan Foto
1. Buka halaman CRUD
2. Klik tombol **Add Service** (FAB)
3. Tap area **"Tap to add image"** untuk memilih foto dari galeri
4. Isi nama, harga, dan deskripsi service
5. Klik **Create**

### 2. Edit Service dan Update Foto
1. Klik tombol **Edit** (icon pensil) pada service card
2. Tap foto yang ada untuk mengganti dengan foto baru
3. Atau klik icon **X** untuk menghapus foto
4. Klik **Update** untuk menyimpan perubahan

### 3. Delete Service (Otomatis Hapus Foto)
1. Klik tombol **Delete** (icon sampah)
2. Konfirmasi delete
3. Foto akan otomatis terhapus dari Storage

## Struktur Penyimpanan

Foto akan disimpan di:
```
service-images/
  └── services/
      ├── Service_Name_1_1705123456789.jpg
      ├── Service_Name_2_1705123456790.jpg
      └── ...
```

Format nama file: `{ServiceName}_{timestamp}.jpg`

## Troubleshooting

### Error: "Failed to upload image"
- **Solusi**: Pastikan policy INSERT sudah dibuat untuk authenticated users
- Pastikan Anda sudah login di aplikasi

### Error: "Failed to load image"
- **Solusi**: Pastikan policy SELECT sudah dibuat untuk public
- Periksa URL gambar sudah benar

### Gambar Tidak Muncul
- **Solusi**: Pastikan bucket `service-images` dibuat dengan opsi **Public bucket** dicentang
- Cek Network Inspector di browser/emulator untuk lihat error detail

### Policy Error
- **Solusi**: Jalankan SQL policy di Supabase SQL Editor
- Atau buat manual di Dashboard Storage > Policies

## Fitur yang Sudah Ditambahkan

- ✅ Upload foto saat create service
- ✅ Update/ganti foto saat edit service
- ✅ Hapus foto saat edit (dengan tombol X)
- ✅ Hapus foto otomatis saat delete service
- ✅ Preview foto di Service Card
- ✅ Preview foto besar di Detail Dialog
- ✅ Error handling jika foto gagal load
- ✅ Image compression (max 1024x1024, quality 85%)
- ✅ Support dark mode

## Kode yang Sudah Diubah

### 1. Model (service_model.dart)
- Sudah ada field `imageUrl` ✅

### 2. Controller (service_controller.dart)
- ✅ `pickImage()` - Pilih foto dari galeri
- ✅ `uploadImage()` - Upload ke Supabase Storage
- ✅ `deleteImage()` - Hapus dari Supabase Storage

### 3. View (crud_test_page.dart)
- ✅ Create Dialog dengan image picker
- ✅ Edit Dialog dengan image picker dan preview
- ✅ Service Card menampilkan foto
- ✅ Detail Dialog menampilkan foto besar

## Permission (Android/iOS)

Pastikan permission sudah ditambahkan:

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select images</string>
```

## Database Schema

Tabel `services` sudah memiliki kolom `image_url`:
```sql
ALTER TABLE services ADD COLUMN IF NOT EXISTS image_url TEXT;
```

Jika belum ada, jalankan SQL di Supabase SQL Editor.
