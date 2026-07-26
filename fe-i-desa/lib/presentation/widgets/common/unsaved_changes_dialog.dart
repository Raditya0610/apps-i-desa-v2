import 'package:flutter/material.dart';
import '../../../core/theme/forui_theme.dart';

/// Asks the operator to confirm leaving with unsaved work. Returns `true`
/// if they chose to leave (discarding it), `false`/`null` if they chose to
/// stay.
Future<bool?> showUnsavedChangesDialog(
  BuildContext context, {
  required String title,
  required String message,
  String stayLabel = 'Tetap di Halaman Ini',
  String leaveLabel = 'Keluar',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: ForuiThemeConfig.warningColor, size: 28),
              ),
              const SizedBox(height: ForuiThemeConfig.spacingMedium),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ForuiThemeConfig.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: ForuiThemeConfig.textSecondary),
              ),
              const SizedBox(height: ForuiThemeConfig.spacingLarge),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ForuiThemeConfig.textSecondary,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                        ),
                      ),
                      child: Text(stayLabel),
                    ),
                  ),
                  const SizedBox(width: ForuiThemeConfig.spacingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ForuiThemeConfig.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                        ),
                      ),
                      child: Text(leaveLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
