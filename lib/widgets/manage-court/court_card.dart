import 'package:flutter/material.dart';

class CourtCard extends StatelessWidget {
  final String name;
  final String type;
  final String address;
  final String price;
  final VoidCallback? onPressedDetail;
  final VoidCallback? onPressedEdit;
  final VoidCallback? onPressedDelete;

  const CourtCard({
    super.key,
    required this.name,
    required this.type,
    required this.address,
    required this.price,
    this.onPressedDetail,
    this.onPressedEdit,
    this.onPressedDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Nama Court & Harga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name, // "FASILKOM COURT"
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        type, // "Futsal Court"
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  price, // "100.000/H"
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Gambar Lapangan (Placeholder)
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800], // Warna gelap ala gambar malam
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  // Ganti ini nanti dengan NetworkImage kalau sudah ada API
                  image: AssetImage('assets/court_dummy_1.jpg'), 
                  fit: BoxFit.cover,
                ),
              ),
              // Fallback kalau gambar gak ada, biar gak error merah
              child: const Center(
                child: Icon(Icons.image, color: Colors.white54),
              ),
            ),
            const SizedBox(height: 8),

            // 3. Alamat
            Text(
              address,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // 4. Tombol Action (See Detail, Delete, Edit)
            Row(
              children: [
                // Tombol "SEE DETAIL"
                OutlinedButton(
                  onPressed: onPressedDetail,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "SEE DETAIL",
                    style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                
                // Icon Sampah (Delete)
                InkWell(
                  onTap: onPressedDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Icon Edit (Pensil)
                InkWell(
                  onTap: onPressedEdit,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.edit, color: Colors.green, size: 14),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}