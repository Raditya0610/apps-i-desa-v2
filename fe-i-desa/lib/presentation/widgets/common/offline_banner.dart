import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shown when the server could not be reached and the screen is rendering data
/// from the local cache. Without this the stale numbers are indistinguishable
/// from live ones, which is worse than showing an error.
class OfflineBanner extends StatelessWidget {
  final DateTime? cachedAt;
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    required this.cachedAt,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = cachedAt == null
        ? null
        : DateFormat('dd/MM/yyyy HH:mm').format(cachedAt!.toLocal());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: const Color(0xFFFFF4E5),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 18, color: Color(0xFFB25E02)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              timestamp == null
                  ? 'Tidak dapat terhubung ke server. Menampilkan data tersimpan.'
                  : 'Tidak dapat terhubung ke server. Menampilkan data tersimpan per $timestamp.',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8A4B00),
              ),
            ),
          ),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Coba lagi'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB25E02),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
