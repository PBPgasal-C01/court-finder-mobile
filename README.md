<div align="center">

# Court Finder

<img src="static/images/cflogo2.png" alt="Court Finder Logo" width="140" />

### _Temukan Lapangan Terdekat dengan Mudah_

</div>

---

[![Build Status](https://app.bitrise.io/app/78dbfbf3-5f80-4f6c-94a2-cbd904f40cec/status.svg?token=OJYoiOqufHzitDOSQlYIOA&branch=main)](https://app.bitrise.io/app/78dbfbf3-5f80-4f6c-94a2-cbd904f40cec)

## 📝 Deskripsi

**Court Finder** Court Finder adalah aplikasi yang membantu masyarakat umum menemukan dan memantau ketersediaan fasilitas/lapangan olahraga terdekat secara real-time, menjawab kesulitan pemain kasual maupun komunitas yang sering harus datang langsung atau bergantung pada informasi tercecer di internet maupun grup chat. Selain menampilkan lokasi, aplikasi juga memberikan detail kondisi lapangan (indoor/outdoor, gratis/berbayar, material lantai, dll), bisa bermain dengan orang lain dan bisa mengecek ada event apa aja yang tersedia. Selain itu, Court Finder juga berfungsi sebagai platform bagi pemilik lapangan untuk mendaftarkan, mengelola, dan mempromosikan fasilitas olahraga mereka ke audiens yang lebih luas.

## 📱 Alur Pengintegrasian dengan Aplikasi Web

1. Menambahkan library http agar aplikasi bisa terhubung dengan website.

2. Menggunakan kembali autentikasi yang ada pada web (login, ,logout dan register) untuk diintegrasikan ke aplikasi flutter, agar pengguna dapat login sesuai perannya dengan memberikan token id.

3. Memakai library pbp_django_auth untuk mengurus request server yang berupa cookies request agar user bisa terautentikasi dan tertorisasi dengan baik.

4. Mengimplementasikan REST API pada Django (views.py) dengan menggunakan Django Serializers atau JsonResponse.

## 👥 Data Kelompok

| NPM        | Nama                     | Role              | Modul                       |
| ---------- | ------------------------ | ----------------- | --------------------------- |
| 2406495451 | Zhafira Uzma             | PJ QA (Unit test) | Complain & Report System    |
| 2406495445 | Raida Khoyyara           | PJ Figma          | Manage Court                |
| 2406408086 | Maira Azma Shaliha       | PJ Figma          | Court finder (map & filter) |
| 2406437565 | Jihan Andita Kresnaputri | PJ PM             | Game Scheduler              |
| 2406405304 | Alfino Ahmad Feriza      | PJ Developer      | Autentikasi                 |
| 2406358472 | Tristan Rasheed Satria   | PJ Developer      | Blog                        |

## 🔗 Link PWS

https://tristan-rasheed-court-finder.pbp.cs.ui.ac.id/auth/user-flutter/host:8000
/

## 🎨 Link Design

https://www.figma.com/design/PdASDdg1WngWONePYMoFxW/Design-System?node-id=108-727&t=Isu8lalSrYHcemyl-1

https://www.figma.com/design/ezyGnnjO8O5jLVmO1aatXT/Mobile-Prototype?node-id=66-255&t=FdVNFYA7ZzYKELhm-0

## 📊 Link Sumber Dataset

https://docs.google.com/document/d/1XPr0RdUumJm2YWlrm4AMsrK8ALj-I9bUs48UgpPLh5M/edit?tab=t.0

---

# 📋 Daftar Modul

## 1. Modul Autentikasi (Alfino) 🔐

- **Fitur Autentikasi:** Registrasi/login menggunakan email atau Google, serta pengaturan profil user (nama, foto, preferensi main indoor/outdoor).

|                | User                                                              | Admin                                  |
| -------------- | ----------------------------------------------------------------- | -------------------------------------- |
| Peran Pengguna | Dapat registrasi/login, mengatur profil (nama, foto, preferensi). | Dapat mengelola akun user (hapus/ban). |

---

## 2. Modul Court Finder (Map & Filter) (Maira) 🗺️

- **Fitur Court Finder:** Menyediakan map interaktif untuk mencari lapangan, dilengkapi filter,favorit, dan sorting.

|                | User                                                                                              | Admin              |
| -------------- | ------------------------------------------------------------------------------------------------- | ------------------ |
| Peran Pengguna | Dapat melihat map dan info dasar court, serta menggunakan filter, sorting, dan menandai favorite. | Sama seperti User. |

---

## 3. Modul Manage Court (Raida) 📍

- **CRUD Court:** Memungkinkan user (pemilik lapangan) untuk membuat, melihat, mengedit, dan menghapus (CRUD) daftar lapangan yang mereka miliki.

|                | User                                                                                      | Admin              |
| -------------- | ----------------------------------------------------------------------------------------- | ------------------ |
| Peran Pengguna | Dapat melakukan CRUD (Create, Read, Update, Delete) penuh pada lapangan miliknya sendiri. | Sama seperti User. |

---

## 4. Modul Blog (Tristan) 📒

- **CRUD Blog:** Pengguna dapat melihat artikel, dan menambahkan ke favorit Admin dapat melakukan semua fitur pengguna serta membuat, mengedit, dan menghapus artikel.

|                | User                                            | Admin                                                                         |
| -------------- | ----------------------------------------------- | ----------------------------------------------------------------------------- |
| Peran Pengguna | Dapat melihat artikel, dan menambahkan favorit. | Semua fitur User + Dapat membuat, mengedit dan menghapus artikel tanpa batas. |

---

## 5. Modul Game Scheduler (Cari Teman Main) (Jihan) 🏀

- **Fitur Game Scheduler:** Membuat dan bergabung ke jadwal game yang ada dengan opsi public atau private, dan terintegrasi dengan kalender.

|                | User                                                                                                                                                                                                                    | Admin             |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- |
| Peran Pengguna | Dapat melakukan CRUD (Create, Read, Update, Delete) (user yang login = creator, creator dapat mengikuti jadwal permainan dan dapat tidak mengikuti jadwal permainan nya \*noted: di models ada partisipan sama creator) | Sama seperti User |

---

## 6. Modul Complaint & Report System (Zhafira) 🚨

- **Fitur Laporan:** pelaporan masalah terkait lapangan (ring rusak, lampu mati, lantai licin), dengan status laporan yang dapat diperbarui. User bisa create, read, & delete report dan admin bisa update & read report

|                | User                                                                                             | Admin                                                                                                              |
| -------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| Peran Pengguna | Dapat melapor masalah terkait lapangan & menghapus laporan selagi masih dalam status "In Review" | Dapat merespons laporan, memperbarui status (In Review, In Process, Done), dan memberi komentar pada semua report. |

---

# 👤 Jenis Pengguna Aplikasi

### 🏃‍♂️ User

- Bisa melihat peta dan informasi dasar lapangan
- Bisa melihat rating dan ulasan lapangan
- Bisa melihat jadwal permainan
- Bisa membaca blog
- Bisa melihat jadwal event
- Bisa membuat atau mengikuti game dan event
- Bisa memberikan rating dan ulasan lapangan
- Bisa mengunggah foto/video lapangan
- Bisa melaporkan masalah lapangan
- Bisa memperbarui profil dan preferensi
- Bisa menambahkan blog favorit

### ⚡ Admin

- Semua fitur User
- Mengelola data lapangan (membuat, mengedit, menghapus)
- Merespons laporan (mengubah status/memberi catatan)
- Mengelola pengguna (menghapus akun, memblokir)
- Mengelola blog (membuat, mengedit, menghapus)
