## Dokumentasi dan Hasil Praktik Lapang di Beritagar.id

Oleh Yoiq Satria Rambadian

### Dokumentasi

Dokumentasi proses dapat dilihat pada direktori `docs`.

1. **Variabel Manifes** - Proses pembentukan indikator yang digunakan pada indeks ketenagakerjaan.


### Dataset

Dataset yang digunakan terdapat pada direktori `dataset`.

1. **Publikasi BPS_PDRB ADHB Lapangan Usaha** - Data PDRB atas dasar harga berlaku berdasarkan lapangan usaha 34 provinsi di Indonesia tahun 2013-2017.

## Source code

1. `plspm.R` - Fungsi yang dapat memodelkan indikator menjadi indeks ketenagakerjaan secara otomatis.

`plspm_autofit(data)`

Memodelkan *plspm* dengan tahap awal menggunakan seluruh indikator pada `data`, tahap kedua menggunakan indikator yang positif, dan tahap ketiga menggunakan indikator penting.

`plspm_predict(plspm_model, newdata)`

Menggunakan model *plspm* pada `plspm_model` untuk memprediksi indikator baru pada `newdata`.