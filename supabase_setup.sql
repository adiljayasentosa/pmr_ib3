-- ============================================================
-- PMR WIRA SMK IBG 3 — SUPABASE DATABASE SETUP
-- Jalankan seluruh script ini di Supabase SQL Editor
-- ============================================================

-- ==========================
-- 1. TABEL PROFILES (extends auth.users)
-- ==========================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  nama_lengkap TEXT NOT NULL DEFAULT '',
  role TEXT NOT NULL DEFAULT 'anggota' CHECK (role IN ('admin', 'pengurus', 'anggota')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================
-- 2. TABEL ANGGOTA
-- ==========================
CREATE TABLE IF NOT EXISTS public.anggota (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nomor_anggota TEXT UNIQUE NOT NULL,
  nama TEXT NOT NULL,
  kelas TEXT NOT NULL,
  jabatan TEXT NOT NULL DEFAULT 'Anggota',
  status_aktif BOOLEAN DEFAULT TRUE,
  foto_url TEXT,
  no_hp TEXT,
  alamat TEXT,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================
-- 3. TABEL INVENTARIS
-- ==========================
CREATE TABLE IF NOT EXISTS public.inventaris (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama_barang TEXT NOT NULL,
  kategori TEXT NOT NULL DEFAULT 'Umum',
  jumlah_stok INTEGER NOT NULL DEFAULT 0 CHECK (jumlah_stok >= 0),
  kondisi TEXT NOT NULL DEFAULT 'Baik' CHECK (kondisi IN ('Baik', 'Rusak Ringan', 'Rusak Berat')),
  keterangan TEXT,
  lokasi_simpan TEXT,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================
-- 4. TABEL RIWAYAT PEMINJAMAN
-- ==========================
CREATE TABLE IF NOT EXISTS public.riwayat_pinjam (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  inventaris_id UUID NOT NULL REFERENCES public.inventaris(id) ON DELETE CASCADE,
  peminjam TEXT NOT NULL,
  jumlah INTEGER NOT NULL DEFAULT 1 CHECK (jumlah > 0),
  tgl_pinjam DATE NOT NULL DEFAULT CURRENT_DATE,
  tgl_kembali DATE,
  status TEXT NOT NULL DEFAULT 'Dipinjam' CHECK (status IN ('Dipinjam', 'Dikembalikan', 'Terlambat')),
  keterangan TEXT,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================
-- 5. TABEL KEGIATAN
-- ==========================
CREATE TABLE IF NOT EXISTS public.kegiatan (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama_kegiatan TEXT NOT NULL,
  deskripsi TEXT,
  tanggal_mulai DATE NOT NULL,
  tanggal_selesai DATE,
  lokasi TEXT,
  status TEXT NOT NULL DEFAULT 'Direncanakan' CHECK (status IN ('Direncanakan', 'Berlangsung', 'Selesai', 'Dibatalkan')),
  dokumentasi_url TEXT,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================
-- 6. TABEL PENGUMUMAN
-- ==========================
CREATE TABLE IF NOT EXISTS public.pengumuman (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  judul TEXT NOT NULL,
  konten TEXT NOT NULL,
  prioritas TEXT NOT NULL DEFAULT 'Normal' CHECK (prioritas IN ('Rendah', 'Normal', 'Penting', 'Darurat')),
  aktif BOOLEAN DEFAULT TRUE,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

-- Enable RLS pada semua tabel
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.anggota ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventaris ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.riwayat_pinjam ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kegiatan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pengumuman ENABLE ROW LEVEL SECURITY;

-- ==========================
-- HELPER FUNCTION: get_user_role
-- ==========================
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ==========================
-- RLS POLICIES: PROFILES
-- ==========================
CREATE POLICY "Profiles: user dapat lihat semua"
  ON public.profiles FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "Profiles: user hanya bisa update milik sendiri"
  ON public.profiles FOR UPDATE
  TO authenticated USING (id = auth.uid());

CREATE POLICY "Profiles: insert saat register"
  ON public.profiles FOR INSERT
  TO authenticated WITH CHECK (id = auth.uid());

-- ==========================
-- RLS POLICIES: ANGGOTA
-- ==========================
CREATE POLICY "Anggota: semua user terautentikasi bisa lihat"
  ON public.anggota FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "Anggota: pengurus & admin bisa tambah"
  ON public.anggota FOR INSERT
  TO authenticated WITH CHECK (
    public.get_user_role() IN ('admin', 'pengurus')
  );

CREATE POLICY "Anggota: pengurus & admin bisa edit"
  ON public.anggota FOR UPDATE
  TO authenticated USING (
    public.get_user_role() IN ('admin', 'pengurus')
  );

CREATE POLICY "Anggota: hanya admin bisa hapus"
  ON public.anggota FOR DELETE
  TO authenticated USING (
    public.get_user_role() = 'admin'
  );

-- ==========================
-- RLS POLICIES: INVENTARIS
-- ==========================
CREATE POLICY "Inventaris: semua bisa lihat"
  ON public.inventaris FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "Inventaris: pengurus & admin bisa tambah"
  ON public.inventaris FOR INSERT
  TO authenticated WITH CHECK (
    public.get_user_role() IN ('admin', 'pengurus')
  );

CREATE POLICY "Inventaris: pengurus & admin bisa edit"
  ON public.inventaris FOR UPDATE
  TO authenticated USING (
    public.get_user_role() IN ('admin', 'pengurus')
  );

CREATE POLICY "Inventaris: hanya admin bisa hapus"
  ON public.inventaris FOR DELETE
  TO authenticated USING (
    public.get_user_role() = 'admin'
  );

-- ==========================
-- RLS POLICIES: RIWAYAT PINJAM
-- ==========================
CREATE POLICY "Pinjam: semua bisa lihat"
  ON public.riwayat_pinjam FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "Pinjam: pengurus & admin bisa tambah"
  ON public.riwayat_pinjam FOR INSERT
  TO authenticated WITH CHECK (
    public.get_user_role() IN ('admin', 'pengurus')
  );

CREATE POLICY "Pinjam: pengurus & admin bisa edit"
  ON public.riwayat_pinjam FOR UPDATE
  TO authenticated USING (
    public.get_user_role() IN ('admin', 'pengurus')
  );

CREATE POLICY "Pinjam: hanya admin bisa hapus"
  ON public.riwayat_pinjam FOR DELETE
  TO authenticated USING (
    public.get_user_role() = 'admin'
  );

-- ==========================
-- RLS POLICIES: KEGIATAN
-- ==========================
CREATE POLICY "Kegiatan: semua bisa lihat"
  ON public.kegiatan FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "Kegiatan: pengurus & admin bisa tambah"
  ON public.kegiatan FOR INSERT
  TO authenticated WITH CHECK (
    public.get_user_role() IN ('admin', 'pengurus')
  );

CREATE POLICY "Kegiatan: pengurus & admin bisa edit"
  ON public.kegiatan FOR UPDATE
  TO authenticated USING (
    public.get_user_role() IN ('admin', 'pengurus')
  );

CREATE POLICY "Kegiatan: hanya admin bisa hapus"
  ON public.kegiatan FOR DELETE
  TO authenticated USING (
    public.get_user_role() = 'admin'
  );

-- ==========================
-- RLS POLICIES: PENGUMUMAN
-- ==========================
CREATE POLICY "Pengumuman: semua bisa lihat"
  ON public.pengumuman FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "Pengumuman: pengurus & admin bisa tambah"
  ON public.pengumuman FOR INSERT
  TO authenticated WITH CHECK (
    public.get_user_role() IN ('admin', 'pengurus')
  );

CREATE POLICY "Pengumuman: pengurus & admin bisa edit"
  ON public.pengumuman FOR UPDATE
  TO authenticated USING (
    public.get_user_role() IN ('admin', 'pengurus')
  );

CREATE POLICY "Pengumuman: hanya admin bisa hapus"
  ON public.pengumuman FOR DELETE
  TO authenticated USING (
    public.get_user_role() = 'admin'
  );

-- ============================================================
-- TRIGGER: Auto-buat profil saat user baru register
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, nama_lengkap, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'nama_lengkap', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'anggota')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- TRIGGER: Auto-update stok saat ada peminjaman/pengembalian
-- ============================================================
CREATE OR REPLACE FUNCTION public.update_stok_pinjam()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status = 'Dipinjam' THEN
    -- Kurangi stok saat dipinjam
    UPDATE public.inventaris
    SET jumlah_stok = jumlah_stok - NEW.jumlah,
        updated_at = NOW()
    WHERE id = NEW.inventaris_id;

  ELSIF TG_OP = 'UPDATE' AND OLD.status = 'Dipinjam' AND NEW.status = 'Dikembalikan' THEN
    -- Tambah stok saat dikembalikan
    UPDATE public.inventaris
    SET jumlah_stok = jumlah_stok + NEW.jumlah,
        updated_at = NOW()
    WHERE id = NEW.inventaris_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_riwayat_pinjam_change
  AFTER INSERT OR UPDATE ON public.riwayat_pinjam
  FOR EACH ROW EXECUTE FUNCTION public.update_stok_pinjam();

-- ============================================================
-- DATA AWAL (SEED) — Admin default
-- Ganti email dan password melalui Supabase Auth dashboard,
-- lalu update role di tabel profiles secara manual.
-- ============================================================

-- Contoh update role admin (jalankan setelah register pertama kali):
-- UPDATE public.profiles SET role = 'admin' WHERE email = 'admin@pmrsmkibg3.sch.id';
