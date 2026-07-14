import 'package:flutter/material.dart';

class GenderBadge extends StatelessWidget {
  final String jenisKelamin;

  const GenderBadge({
    super.key,
    required this.jenisKelamin,
  });

  @override
  Widget build(BuildContext context) {
    // Rows exist as "Laki-laki"/"Perempuan" and, from older writes, "L"/"P".
    // Matched explicitly: falling back to "Perempuan" for anything unrecognised
    // is what let a blank gender render as a woman instead of showing that the
    // record is incomplete.
    final (label, color) = switch (jenisKelamin.trim().toLowerCase()) {
      'l' || 'laki-laki' => ('Laki-Laki', Colors.blue.shade600),
      'p' || 'perempuan' => ('Perempuan', Colors.pink.shade400),
      _ => ('Tidak diketahui', Colors.grey.shade400),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
