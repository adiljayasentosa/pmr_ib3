# 🏥 PMR Wira SMK IBG 3 — Sistem Manajemen Organisasi

Website manajemen PMR berbasis **Emergency Medical Dashboard** menggunakan HTML, CSS, Vanilla JS, dan Supabase.

---

## 📁 Struktur Folder

```
pmr-smkibg3/
├── index.html              ← Halaman login
├── dashboard.html          ← Dashboard utama
├── anggota.html            ← Manajemen anggota
├── inventaris.html         ← Inventaris & peminjaman
├── kegiatan.html           ← Kegiatan PMR
├── pengumuman.html         ← Pengumuman
│
├── css/
│   ├── main.css            ← Global styles, komponen, layout
│   └── auth.css            ← Styling halaman login
│
├── js/
│   ├── supabase.js         ← Inisialisasi & utility Supabase
│   ├── auth.js             ← Login, logout, session
│   ├── dashboard.js        ← Statistik dashboard
│   ├── anggota.js          ← CRUD data anggota
│   ├── inventaris.js       ← CRUD inventaris + riwayat pinjam
│   ├── kegiatan.js         ← CRUD kegiatan PMR
│   └── pengumuman.js       ← CRUD pengumuman
│
└── supabase_setup.sql      ← SQL setup database Supabase
```

---

## 🚀 Cara Setup

### 1. Buat Project Supabase

1. Buka [supabase.com](https://supabase.com) → Buat akun / login
2. Klik **"New Project"**
3. Isi nama project: `pmr-smkibg3`
4. Pilih region terdekat (Singapore)
5. Buat password database yang kuat → **Simpan passwordnya!**
6. Tunggu project selesai dibuat (~2 menit)

### 2. Jalankan SQL Setup

1. Di dashboard Supabase → **SQL Editor** (ikon di sidebar kiri)
2. Klik **"New Query"**
3. Copy-paste seluruh isi file `supabase_setup.sql`
4. Klik **"Run"** (atau Ctrl+Enter)
5. Pastikan muncul pesan "Success" di bawah

### 3. Konfigurasi Kunci API

1. Di Supabase → **Settings** → **API**
2. Salin:
   - **Project URL** (contoh: `https://abcxyz.supabase.co`)
   - **anon public key** (bukan service role!)
3. Buka file `js/supabase.js`
4. Ganti dua baris ini:

```javascript
const SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE';
```

menjadi kunci milikmu.

### 4. Buat Akun Admin Pertama

1. Di Supabase → **Authentication** → **Users** → **"Invite user"**
2. Masukkan email admin (contoh: `admin@pmrsmkibg3.sch.id`)
3. Setelah user dibuat, buka **SQL Editor** jalankan:

```sql
UPDATE public.profiles 
SET role = 'admin', nama_lengkap = 'Nama Admin'
WHERE email = 'admin@pmrsmkibg3.sch.id';
```

4. Set password lewat fitur **"Send password reset"** atau langsung di tabel auth

### 5. Hosting (Opsional)

**GitHub Pages (Gratis):**
```bash
# Upload semua file ke repo GitHub
# Settings → Pages → Source: main branch
# URL: https://username.github.io/pmr-smkibg3/
```

**Vercel (Lebih mudah):**
```bash
# Drag & drop folder ke vercel.com
# Deploy otomatis
```

> ⚠️ **Penting:** Tambahkan URL website ke **Supabase → Authentication → URL Configuration → Site URL & Redirect URLs**

---

## 👥 Manajemen User

### Tambah Pengurus / Anggota Baru

1. Supabase → **Authentication** → **Users** → **"Add user"**
2. Isi email dan password
3. Jalankan SQL untuk set role:

```sql
-- Untuk pengurus:
UPDATE public.profiles 
SET role = 'pengurus', nama_lengkap = 'Nama Pengurus'
WHERE email = 'pengurus@email.com';

-- Untuk anggota biasa:
UPDATE public.profiles 
SET role = 'anggota', nama_lengkap = 'Nama Anggota'
WHERE email = 'anggota@email.com';
```

### Level Akses

| Fitur              | Admin | Pengurus | Anggota |
|--------------------|:-----:|:--------:|:-------:|
| Lihat semua data   | ✅    | ✅       | ✅      |
| Tambah/Edit data   | ✅    | ✅       | ❌      |
| Hapus data         | ✅    | ❌       | ❌      |
| Kelola user        | ✅    | ❌       | ❌      |

---

## 🗄️ Struktur Database

| Tabel            | Fungsi                          |
|------------------|---------------------------------|
| `profiles`       | Data profil & role user         |
| `anggota`        | Data anggota PMR                |
| `inventaris`     | Data barang / logistik          |
| `riwayat_pinjam` | Riwayat peminjaman inventaris   |
| `kegiatan`       | Jadwal & dokumentasi kegiatan   |
| `pengumuman`     | Pengumuman organisasi           |

---

## 🔧 Pengembangan Lanjutan

Fitur yang bisa ditambahkan ke depan:

- [ ] Export data ke Excel/PDF
- [ ] Notifikasi email otomatis (Supabase Edge Functions)
- [ ] Upload foto anggota ke Supabase Storage
- [ ] Absensi kegiatan per anggota
- [ ] Laporan bulanan / statistik lanjutan
- [ ] PWA (Progressive Web App) agar bisa diinstall di HP
- [ ] Dark mode
- [ ] Print kartu anggota

---

## 🐛 Troubleshooting

**Login gagal terus:**
- Pastikan URL dan anon key di `supabase.js` sudah benar
- Cek di Supabase → Authentication apakah user sudah ada
- Pastikan email sudah dikonfirmasi (atau disable email confirmation di Auth Settings)

**Data tidak muncul:**
- Cek browser console (F12) untuk error
- Pastikan SQL setup sudah dijalankan semua
- Cek RLS policies sudah benar

**Disable email confirmation (development):**
- Supabase → Authentication → Providers → Email → Matikan "Confirm email"

---

## 📞 Teknologi

- **Frontend:** HTML5, CSS3 (Custom Properties), Vanilla JavaScript (ES6+)
- **Database:** Supabase PostgreSQL
- **Auth:** Supabase Auth (email/password)
- **Hosting:** GitHub Pages / Vercel
- **Font:** Inter + Space Grotesk (Google Fonts)
- **Icons:** Emoji (tidak perlu library tambahan)

---

*© 2026 PMR Wira SMK IBG 3 — Siap Sedia, Setia Berbakti*
