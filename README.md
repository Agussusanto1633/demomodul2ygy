# 🚗 Corner Garage

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-8B5CF6?style=for-the-badge&logo=flutter&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

**Aplikasi Mobile Layanan Bengkel Modern dengan Flutter & GetX**

[Demo](#-demo) • [Fitur](#-fitur-utama) • [Instalasi](#-instalasi) • [API](#-api-integration) • [Dokumentasi](#-dokumentasi)

</div>

---

## 📖 Tentang Aplikasi

**Corner Garage** adalah aplikasi mobile modern untuk manajemen layanan bengkel yang dibangun menggunakan Flutter. Aplikasi ini menyediakan antarmuka yang intuitif untuk pelanggan dalam memesan dan mengelola layanan perbaikan kendaraan mereka.

### 🎯 Tujuan Proyek

- ✅ Memudahkan pelanggan dalam memilih layanan bengkel
- ✅ Sistem pemesanan yang cepat dan mudah
- ✅ Manajemen data layanan dengan CRUD lengkap
- ✅ Integrasi API dengan HTTP & Dio Package
- ✅ UI/UX yang responsif dan menarik

---

## ✨ Fitur Utama

### 🔐 Authentication
- **Login System** dengan validasi
- **Secure Credentials** (Email: `repaint@gmail.com`, Password: `repaint123`)
- **Session Management** dengan GetX

### 🎨 User Interface
- ✨ **Animasi Eksplisit**: Pulse & Rotate animations
- 🎭 **Hero Transitions**: Transisi halus antar halaman
- 📱 **Responsive Design**: Support portrait & landscape
- 🌈 **Material Design 3**: UI modern dan konsisten
- 🎬 **Multiple Transitions**: Fade, Slide, Scale, Zoom animations

### 🛠️ Service Management
- 📋 **Katalog Layanan**: Tampilan grid interaktif
- 🔍 **Detail Layanan**: Informasi lengkap setiap layanan
- 💰 **Harga Transparan**: Informasi biaya jelas
- ⚡ **Quick Booking**: Pemesanan cepat dan mudah

### 🌐 API Integration
- 🔄 **Dual API Support**: HTTP Package & Dio Package
- 🎯 **CRUD Operations**: Create, Read, Update, Delete
- 🔌 **MockAPI Integration**: `https://mockapi.io`
- 📊 **Real-time Data**: Sinkronisasi data otomatis
- 🔀 **Easy API Switching**: Toggle HTTP ↔️ Dio dengan satu klik

### 🧪 Testing Features
- 🔬 **CRUD Test Page**: Testing API endpoint
- 📡 **API Monitoring**: Log request/response detail
- ⚠️ **Error Handling**: Error message yang informatif
- 🎯 **Status Indicators**: Visual feedback untuk setiap operasi

### 📱 Navigation
- 🏠 **Home**: Katalog layanan utama
- 📦 **Orders**: Riwayat pesanan
- 👤 **Profile**: Manajemen profil pengguna
- ⚙️ **Settings**: Pengaturan aplikasi lengkap

---

## 🚀 Demo

### Screenshots

<div align="center">

| Login Screen | Home Screen | Service Detail |
|:------------:|:-----------:|:--------------:|
| ![Login](https://via.placeholder.com/250x450/1E3A5F/FFFFFF?text=Login+Page) | ![Home](https://via.placeholder.com/250x450/455A64/FFFFFF?text=Home+Page) | ![Detail](https://via.placeholder.com/250x450/2196F3/FFFFFF?text=Detail+Page) |

| API Toggle | CRUD Test | Settings |
|:----------:|:---------:|:--------:|
| ![Toggle](https://via.placeholder.com/250x450/4CAF50/FFFFFF?text=API+Toggle) | ![CRUD](https://via.placeholder.com/250x450/FF9800/FFFFFF?text=CRUD+Test) | ![Settings](https://via.placeholder.com/250x450/9C27B0/FFFFFF?text=Settings) |

</div>

### 🎥 Video Demo

> 📹 *Coming Soon - Video demo akan segera ditambahkan*

---

## 🛠️ Tech Stack

| Technology | Description |
|------------|-------------|
| ![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter) | Framework UI cross-platform |
| ![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart) | Programming language |
| ![GetX](https://img.shields.io/badge/GetX-Latest-8B5CF6) | State management & routing |
| ![HTTP](https://img.shields.io/badge/HTTP-1.0+-2196F3) | HTTP client package |
| ![Dio](https://img.shields.io/badge/Dio-5.0+-4CAF50) | Advanced HTTP client |
| ![MockAPI](https://img.shields.io/badge/MockAPI-REST-FF6B6B) | Backend API simulation |

---

## 📦 Instalasi

### Prerequisites

Pastikan Anda sudah menginstall:
- ✅ [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0 atau lebih baru)
- ✅ [Dart SDK](https://dart.dev/get-dart) (3.0 atau lebih baru)
- ✅ [Android Studio](https://developer.android.com/studio) atau [VS Code](https://code.visualstudio.com/)
- ✅ [Git](https://git-scm.com/)

### 🔧 Langkah Instalasi

1. **Clone Repository**
```bash
git clone https://github.com/username/corner-garage.git
cd corner-garage
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Setup API Configuration**

Edit file `lib/services/api_service_http.dart` dan `lib/services/api_service_dio.dart`:

```dart
// Ubah baseUrl sesuai MockAPI Anda
static const String baseUrl = 'https://YOUR-MOCKAPI-URL.mockapi.io/api/v1';

// Pilih mode: 'local' atau 'online'
static const String mode = 'online';
```

4. **Run Application**
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

### 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/widget_test.dart
```

---

## 🌐 API Integration

### MockAPI Configuration

Aplikasi ini menggunakan **MockAPI** untuk backend simulation. 

#### Setup MockAPI:

1. Buka [mockapi.io](https://mockapi.io)
2. Buat project baru
3. Buat endpoint `/service` dengan struktur:

```json
{
  "id": "1",
  "title": "Cat Ulang Motor",
  "description": "Layanan pengecatan ulang motor dengan hasil maksimal",
  "price": "Rp 500.000",
  "icon": "format_paint",
  "color": "blue"
}
```

4. Copy URL endpoint Anda ke konfigurasi API

### 🔄 API Switching

Aplikasi mendukung **2 HTTP client libraries**:

```dart
// HTTP Package (Standard)
final _httpService = ApiService();

// Dio Package (Advanced)
final _dioService = ApiServiceDio();

// Toggle dengan mudah
serviceController.toggleApiMode();
```

### 📡 Available Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/service` | Ambil semua layanan |
| `GET` | `/service/:id` | Ambil layanan berdasarkan ID |
| `POST` | `/service` | Tambah layanan baru |
| `PUT` | `/service/:id` | Update layanan |
| `DELETE` | `/service/:id` | Hapus layanan |

### 💡 Code Example

```dart
// GET All Services
await serviceController.fetchAllServices();

// GET By ID
await serviceController.fetchServiceById('1');

// CREATE
final newService = ServiceModel(
  id: '1',
  title: 'New Service',
  description: 'Description',
  price: 'Rp 100.000',
  icon: 'build',
  color: 'blue',
);
await serviceController.createService(newService);

// UPDATE
await serviceController.updateService('1', updatedService);

// DELETE
await serviceController.deleteService('1');
```

---

## 📁 Struktur Projekt

```
corner_garage/
│
├── lib/
│   ├── controllers/
│   │   └── service_controller.dart      # GetX Controller
│   │
│   ├── models/
│   │   └── service_model.dart           # Data Model
│   │
│   ├── services/
│   │   ├── api_service_http.dart        # HTTP Client
│   │   └── api_service_dio.dart         # Dio Client
│   │
│   ├── views/
│   │   ├── login_page.dart              # Login Screen
│   │   ├── repair_service_page.dart     # Home/Main Screen
│   │   ├── service_detail_page.dart     # Detail Screen
│   │   ├── crud_test_page.dart          # API Testing Screen
│   │   ├── orders_page.dart             # Orders Screen
│   │   ├── profile_page.dart            # Profile Screen
│   │   └── setting_page.dart            # Settings Screen
│   │
│   └── main.dart                         # Entry Point
│
├── assets/
│   ├── images/
│   │   └── icon.png                     # App Icon
│   └── data/
│       └── sample.json                  # Local JSON Data
│
├── test/
│   └── widget_test.dart                 # Unit Tests
│
├── pubspec.yaml                         # Dependencies
└── README.md                            # Documentation
```

---

## 🎨 Design System

### Color Palette

```dart
// Primary Colors
const primaryDark = Color(0xFF1E3A5F);
const primaryMedium = Color(0xFF2E5984);
const primaryLight = Color(0xFF455A64);

// Service Colors
Colors.blue, Colors.green, Colors.red, Colors.orange,
Colors.purple, Colors.teal, Colors.indigo, Colors.amber,
Colors.pink, Colors.cyan
```

### Typography

```dart
// Headers
fontSize: 30, fontWeight: FontWeight.bold

// Body
fontSize: 16, fontWeight: FontWeight.normal

// Caption
fontSize: 12, color: Colors.grey
```

### Icons

Aplikasi menggunakan **Material Icons**:
- `format_paint` - Cat
- `sports_motorsports` - Motor
- `build` - Service
- `oil_barrel` - Oli
- `battery_charging_full` - Aki
- Dan masih banyak lagi...

---

## 🔐 Credentials

Untuk testing aplikasi, gunakan kredensial berikut:

```
Email: repaint@gmail.com
Password: repaint123
```

> ⚠️ **Note**: Ini adalah kredensial demo. Untuk production, implementasikan sistem autentikasi yang proper.

---

## 🤝 Contributing

Kontribusi sangat diterima! Ikuti langkah berikut:

1. Fork repository ini
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

### Coding Standards

- ✅ Gunakan Dart style guide
- ✅ Tulis komentar yang jelas
- ✅ Buat unit tests untuk fitur baru
- ✅ Update dokumentasi

---

## 📝 Changelog

### Version 1.0.0 (2024)

#### ✨ Added
- Login authentication system
- Service catalog dengan grid view
- Detail halaman layanan dengan hero animation
- CRUD operations lengkap
- Dual API support (HTTP & Dio)
- API testing page
- Bottom navigation
- Settings page dengan banyak opsi
- Responsive design untuk portrait & landscape
- Explicit animations (Pulse & Rotate)
- Multiple page transitions

#### 🐛 Fixed
- API endpoint URL configuration
- Hero animation tag conflicts
- Responsive layout issues
- Navigation transitions

#### 🔄 Changed
- Improved error handling
- Enhanced logging system
- Better UI/UX feedback

---

## 🐛 Known Issues

- [ ] Local JSON mode belum fully tested
- [ ] Dark mode masih dalam development
- [ ] Profile page masih static
- [ ] Order history belum terintegrasi dengan backend

---

## 📚 Dokumentasi

### GetX State Management

```dart
// Observable variable
var isLoading = false.obs;
var services = <ServiceModel>[].obs;

// Update value
isLoading.value = true;
services.value = result;

// Listen to changes
Obx(() => Text('${services.length}'))
```

### Navigation

```dart
// Navigate to page
Get.to(() => DetailPage());
Get.toNamed('/home');

// With transition
Get.to(
  () => DetailPage(),
  transition: Transition.rightToLeft,
  duration: Duration(milliseconds: 500),
);

// Replace & remove all
Get.offAllNamed('/login');
```

### Snackbar

```dart
Get.snackbar(
  'Title',
  'Message',
  snackPosition: SnackPosition.BOTTOM,
  backgroundColor: Colors.green,
  colorText: Colors.white,
);
```

---

## 📄 License

Proyek ini dilisensikan di bawah **MIT License** - lihat file [LICENSE](LICENSE) untuk detail.

```
MIT License

Copyright (c) 2024 Corner Garage

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 👥 Team

### Developer

- **Your Name** - *Full Stack Flutter Developer* - [@username](https://github.com/username)

### Contributors

Terima kasih kepada semua yang telah berkontribusi pada proyek ini!

<a href="https://github.com/username/corner-garage/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=username/corner-garage" />
</a>

---

## 📞 Contact & Support

- 📧 Email: agussusanto@webmail.umm.ac.id
- 💬 Discord: [Join my server](https://discord.gg/fuG9ARe5)
- 📷 Instagram: [@agus_siuuu7](https://www.instagram.com/agus_siuuu7?igsh=ems1ZTl1am9leWRh&utm_source=qr)
- 📱 WhatsApp: +62 895-3830-15559

### ⭐ Support This Project

Jika proyek ini membantu Anda, berikan ⭐ untuk repo ini!

[![Star History Chart](https://api.star-history.com/svg?repos=username/corner-garage&type=Date)](https://star-history.com/#username/corner-garage&Date)

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) - Framework yang luar biasa
- [GetX](https://pub.dev/packages/get) - State management yang powerful
- [MockAPI](https://mockapi.io) - Free REST API service
- [Heroicons](https://heroicons.com) - Beautiful icons
- Community Flutter Indonesia

---

<div align="center">

**Made with ❤️ using Flutter**

[⬆ Back to Top](#-corner-garage)

</div>