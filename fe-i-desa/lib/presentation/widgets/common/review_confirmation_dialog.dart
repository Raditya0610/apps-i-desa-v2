import 'package:flutter/material.dart';
import '../../../core/theme/forui_theme.dart';

/// One label/value row shown in a [showReviewConfirmationDialog]. Rows that
/// share the same non-null [section] are grouped under a header, in the
/// order sections first appear in the field list.
class ReviewField {
  final String label;
  final String value;
  final String? section;

  const ReviewField(this.label, this.value, {this.section});
}

/// Shows a read-only summary of [fields] and asks the operator to confirm
/// before anything is saved. Returns `true` on accept, `false`/`null` on
/// decline (back button, barrier tap) — callers should treat anything but
/// `true` as decline and leave the underlying form untouched.
Future<bool?> showReviewConfirmationDialog(
  BuildContext context, {
  required String title,
  String? subtitle,
  IconData icon = Icons.fact_check_rounded,
  required List<ReviewField> fields,
  String declineLabel = 'Kembali & Perbaiki',
  String acceptLabel = 'Ya, Simpan',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => _ReviewConfirmationDialog(
      title: title,
      subtitle: subtitle,
      icon: icon,
      fields: fields,
      declineLabel: declineLabel,
      acceptLabel: acceptLabel,
    ),
  );
}

class _ReviewConfirmationDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<ReviewField> fields;
  final String declineLabel;
  final String acceptLabel;

  const _ReviewConfirmationDialog({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.fields,
    required this.declineLabel,
    required this.acceptLabel,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 620;
    final dialogWidth = screenWidth < 600 ? screenWidth - 24 : 560.0;

    // Groups fields under their section header, preserving the order
    // sections first appear in — a plain (unsectioned) field list ends up as
    // one group keyed by null.
    final sections = <String?, List<ReviewField>>{};
    for (final f in fields) {
      sections.putIfAbsent(f.section, () => []).add(f);
    }

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 12 : 40,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(ForuiThemeConfig.borderRadiusLarge),
                  topRight: Radius.circular(ForuiThemeConfig.borderRadiusLarge),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: ForuiThemeConfig.surfaceGreen,
                      borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
                    ),
                    child: Icon(icon, size: 24, color: ForuiThemeConfig.primaryGreen),
                  ),
                  const SizedBox(width: ForuiThemeConfig.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: ForuiThemeConfig.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: ForuiThemeConfig.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in sections.entries) ...[
                      if (entry.key != null) ...[
                        _buildSectionHeader(entry.key!),
                        const SizedBox(height: ForuiThemeConfig.spacingSmall),
                      ],
                      for (final f in entry.value) _buildFieldRow(f),
                      const SizedBox(height: ForuiThemeConfig.spacingMedium),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        foregroundColor: ForuiThemeConfig.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                        ),
                      ),
                      child: Text(declineLabel),
                    ),
                  ),
                  const SizedBox(width: ForuiThemeConfig.spacingMedium),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ForuiThemeConfig.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                        ),
                      ),
                      child: Text(
                        acceptLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: ForuiThemeConfig.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: ForuiThemeConfig.spacingSmall),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ForuiThemeConfig.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(ReviewField f) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ForuiThemeConfig.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              f.label,
              style: const TextStyle(fontSize: 13, color: ForuiThemeConfig.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              f.value.isEmpty ? '-' : f.value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ForuiThemeConfig.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
