-- Membuat Schema Baru pada database 
CREATE SCHEMA pemesanan_tiket
-- Mengahpus/ Drop Schema
DROP SCHEMA pemesanan_tiket

-- Membuat tabel pengunjung
CREATE TABLE pemesanan_tiket.pengunjung (
id_pengunjung INT PRIMARY KEY,
nama VARCHAR(50),
saldo DECIMAL(10,2) CHECK (saldo>0)
);

-- Membuat tabel destinasi_wisata
CREATE TABLE pemesanan_tiket.destinasi_wisata (
id_wisata INT PRIMARY KEY,
nama VARCHAR(50),
kuota INT,
harga DECIMAL(10,2),
jumlah_pembelian INT
);


--Membuat tabel baru untuk tabel wisata dan pelanggan
CREATE TABLE pemesanan_tiket.pengunjung_wisata(
	id_pengunjung INT,
	id_wisata INT,
	beli_tiket INT,
	waktu_pesan TIMESTAMP,
	FOREIGN KEY (id_pengunjung) REFERENCES pemesanan_tiket.pengunjung(id_pengunjung),
	FOREIGN KEY (id_wisata) REFERENCES pemesanan_tiket.destinasi_wisata(id_wisata)
	
);

-- Query dasar SELECT 
SELECT * FROM pemesanan_tiket.pengunjung
SELECT * FROM pemesanan_tiket.destinasi_wisata
SELECT * FROM pemesanan_tiket.pengunjung_wisata

INSERT INTO pemesanan_tiket.pengunjung (id_pengunjung,nama,saldo)
VALUES
(29112401, 'Cahyadi', 2000000),
(29112402, 'Supriyadi',3500000),
(29112403, 'Tatayan', 2700000),
(29112404, 'Maretty', 1500000),
(29112405, 'Aziznee', 1000000);

INSERT INTO pemesanan_tiket.destinasi_wisata (id_wisata, nama, kuota, harga)
VALUES
(100601, 'Dunia Fantasi Ancol', 20, 164000),
(100602, 'Hill Park Sibolangit', 25, 130000),
(100603, 'Lombok Wildlife Park', 25, 90000),
(100604, 'Bali Bird Park', 50, 56000),
(100605, 'Bali Zoo', 65, 45000);



DROP TABLE pemesanan_tiket.pengunjung
DROP TABLE pemesanan_tiket.destinasi_wisata
DROP TABLE pemesanan_tiket.pengunjung_wisata

-- Membuat tampilan sementara dengan VIEW
CREATE VIEW detail_pesan_tiket AS
SELECT pengunjung.nama AS nama_pengunjung, destinasi_wisata.nama 
AS wisata, destinasi_wisata.harga, pengunjung_wisata.beli_tiket 
FROM 
	pemesanan_tiket.pengunjung, 
	pemesanan_tiket.destinasi_wisata, 
	pemesanan_tiket.pengunjung_wisata
WHERE 
	pengunjung.id_pengunjung = pengunjung_wisata.id_pengunjung
	AND 
	destinasi_wisata.id_wisata = pengunjung_wisata.id_wisata


SELECT * FROM detail_pesan_tiket
DROP VIEW detail_pesan_tiket


-- PROCEDURE melakukan transaksi pembelian tiket dan pengurangan kuota dan saldo
CREATE OR REPLACE PROCEDURE pemesanan_tiket.transaksi_pembelian_tiket(
    nama_pengunjung VARCHAR(50),
    p_id_wisata INT,
    jumlah_tiket INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    p_id_pengunjung INT;
    harga_per_tiket DECIMAL(10,2);
    total_harga DECIMAL(10,2);
    saldo_pengunjung DECIMAL(10,2);
    kuota_wisata INT;
BEGIN
    -- Mendapatkan ID pengunjung berdasarkan nama
    SELECT id_pengunjung INTO p_id_pengunjung
    FROM pemesanan_tiket.pengunjung
    WHERE nama = nama_pengunjung;

    -- Pastikan ID pengunjung ditemukan
    IF p_id_pengunjung IS NULL THEN
        RAISE EXCEPTION 'Pengunjung dengan nama % tidak ditemukan', nama_pengunjung;
    END IF;

    -- Mendapatkan harga tiket dan kuota destinasi
    SELECT harga, kuota INTO harga_per_tiket, kuota_wisata
    FROM pemesanan_tiket.destinasi_wisata
    WHERE id_wisata = p_id_wisata;

    -- Pastikan destinasi wisata ditemukan
    IF harga_per_tiket IS NULL OR kuota_wisata IS NULL THEN
        RAISE EXCEPTION 'Destinasi wisata dengan ID % tidak ditemukan', p_id_wisata;
    END IF;

    -- Menghitung total harga tiket
    total_harga := harga_per_tiket * jumlah_tiket;

    -- Memastikan saldo pengunjung cukup
    SELECT saldo INTO saldo_pengunjung
    FROM pemesanan_tiket.pengunjung
    WHERE id_pengunjung = p_id_pengunjung;

    IF saldo_pengunjung < total_harga THEN
        RAISE EXCEPTION 'Saldo pengunjung tidak cukup';
    END IF;

    -- Memastikan kuota destinasi cukup
    IF kuota_wisata < jumlah_tiket THEN
        RAISE EXCEPTION 'Kuota tidak mencukupi untuk pembelian tiket';
    END IF;

    -- Mengurangi saldo pengunjung
    UPDATE pemesanan_tiket.pengunjung
    SET saldo = saldo - total_harga
    WHERE id_pengunjung = p_id_pengunjung;

    -- Mengurangi kuota destinasi wisata
    UPDATE pemesanan_tiket.destinasi_wisata
    SET kuota = kuota - jumlah_tiket
    WHERE id_wisata = p_id_wisata;

    -- Memasukkan data pengunjung, destinasi wisata, dan jumlah tiket ke tabel pengunjung_wisata
    INSERT INTO pemesanan_tiket.pengunjung_wisata (id_pengunjung, id_wisata, beli_tiket)
    VALUES (p_id_pengunjung, p_id_wisata, jumlah_tiket);
END;
$$;


--Pemanggilan Procedure pembelian tiket
CALL pemesanan_tiket.transaksi_pembelian_tiket('Tatayan', 100601, 4);
CALL pemesanan_tiket.transaksi_pembelian_tiket('Tatayan', 100604, 10);
CALL pemesanan_tiket.transaksi_pembelian_tiket('Supriyadi', 100603, 4);
CALL pemesanan_tiket.transaksi_pembelian_tiket('Maretty', 100605, 4);
CALL pemesanan_tiket.transaksi_pembelian_tiket('Aziznee', 100605, 10);
CALL pemesanan_tiket.transaksi_pembelian_tiket('Maretty', 100603, 2);
CALL pemesanan_tiket.transaksi_pembelian_tiket('Cahyadi', 100602, 10);
CALL pemesanan_tiket.transaksi_pembelian_tiket('Cahyadi', 100601, 3);
CALL pemesanan_tiket.transaksi_pembelian_tiket('Supriyadi', 100602, 1);
CALL pemesanan_tiket.transaksi_pembelian_tiket('Maretty', 100604, 7);


SELECT * FROM pemesanan_tiket.pengunjung_wisata

DROP PROCEDURE pemesanan_tiket.transaksi_pembelian_tiket

-- Membuat Role untuk membatasi hak akses 
CREATE ROLE admin;

CREATE ROLE user_role;

GRANT SELECT ON pemesanan_tiket.pengunjung TO user_role;
GRANT ALL ON pemesanan_tiket.pengunjung TO admin;
GRANT ALL ON pemesanan_tiket.destinasi_wisata TO admin;

SET ROLE admin;
SET ROLE user_role;
/*	Membuat sebuah trigger untuk menambahkan waktu ketika menambahkan pengunjung yang 
	ingin membeli tiket
*/
CREATE OR REPLACE FUNCTION riwayat_beli_tiket()
RETURNS TRIGGER 
AS
$$
BEGIN 
    NEW.waktu_pesan = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER tambah_waktu_pesan
BEFORE INSERT OR UPDATE
ON pemesanan_tiket.pengunjung_wisata
FOR EACH ROW
EXECUTE FUNCTION riwayat_beli_tiket()


--Melakukan Penambahan tiket kuota wisata
CREATE OR REPLACE PROCEDURE pemesanan_tiket.tambah_kuota (
    p_id_wisata INT,
    p_kuota_tambah INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE pemesanan_tiket.destinasi_wisata
    SET kuota = kuota + p_kuota_tambah
    WHERE id_wisata = p_id_wisata;
END;
$$;

CALL pemesanan_tiket.tambah_kuota (100601,50)

-- FUNCTION untuk melakukan Update jumlah_pembelian di destinasi_wisata berdasarkan beli_tiket di pengunjung_wisata
CREATE OR REPLACE FUNCTION update_jumlah_pemesanan() 
RETURNS TRIGGER AS $$
BEGIN
    -- Update jumlah_pembelian di destinasi_wisata berdasarkan beli_tiket di pengunjung_wisata
    UPDATE pemesanan_tiket.destinasi_wisata
    SET jumlah_pembelian = COALESCE((
        SELECT SUM(beli_tiket)
        FROM pemesanan_tiket.pengunjung_wisata
        WHERE id_wisata = NEW.id_wisata
    ), 0)
    WHERE id_wisata = NEW.id_wisata;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_update_jumlah_pemesanan
AFTER INSERT OR UPDATE ON pemesanan_tiket.pengunjung_wisata
FOR EACH ROW
EXECUTE FUNCTION update_jumlah_pemesanan();



DROP TRIGGER IF EXISTS trigger_update_jumlah_pemesanan ON pemesanan_tiket.pengunjung_wisata;




-- Membuat Data Tabel destinasi wisata dalam bentuk CSV
COPY pemesanan_tiket.destinasi_wisata TO 'C:/KULIAH/Semester 3/Sistem Basis Data (SBD)/Proyek/destinasi_wisata.csv' DELIMITER ',' CSV HEADER;

