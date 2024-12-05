-- Membuat Schema Baru pada database 
CREATE SCHEMA pemesanan_tiket
-- Mengahpus/ Drop Schema
DROP SCHEMA pemesanan_tiket

-- Membuat tabel pengunjung
CREATE TABLE pemesanan_tiket.pengunjung (
id_pengunjung INT PRIMARY KEY,
nama VARCHAR(50),
saldo DECIMAL(10,2) CHECK (saldo>0),
beli_tiket INT,
waktu_pesan TIMESTAMP
);

-- Membuat tabel destinasi_wisata
CREATE TABLE pemesanan_tiket.destinasi_wisata (
id_wisata INT PRIMARY KEY,
nama VARCHAR(50),
kuota INT,
harga DECIMAL(10,2)
);

--Membuat tabel pemesanan
CREATE TABLE pemesanan_tiket.pemesanan(
	id_pemesanan VARCHAR(10) PRIMARY KEY,
	id_wisata INT,
	total_pesanan INT,
	FOREIGN KEY (id_wisata) REFERENCES pemesanan_tiket.destinasi_wisata(id_wisata)
);

--Membuat tabel baru untuk tabel wisata dan pelanggan
CREATE TABLE pemesanan_tiket.pengunjung_wisata(
	id_pengunjung INT,
	id_wisata INT,
	FOREIGN KEY (id_pengunjung) REFERENCES pemesanan_tiket.pengunjung(id_pengunjung),
	FOREIGN KEY (id_wisata) REFERENCES pemesanan_tiket.destinasi_wisata(id_wisata)
	
);

-- Query dasar SELECT 
SELECT * FROM pemesanan_tiket.pengunjung
SELECT * FROM pemesanan_tiket.destinasi_wisata
SELECT * FROM pemesanan_tiket.pemesanan
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
(100601, 'Bukit Sidihoni', 20, 15000),
(100602, 'Bukit Holbung', 25, 15000),
(100603, 'Bukit Sibea Bea', 25, 20000),
(100604, 'Batu Marompa', 50, 15000),
(100605, 'Air Terjun Efrata', 65, 35000);

INSERT INTO pemesanan_tiket.pengunjung_wisata (id_pengunjung, id_wisata)
VALUES
(29112402,100601),
(29112402,100602),
(29112405,100602),
(29112404,100605),
(29112404,100603);

DROP TABLE pemesanan_tiket.pengunjung
DROP TABLE pemesanan_tiket.pemesanan
DROP TABLE pemesanan_tiket.destinasi_wisata
DROP TABLE pemesanan_tiket.pengunjung_wisata