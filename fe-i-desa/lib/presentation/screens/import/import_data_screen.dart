import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../data/models/import_result.dart';
import '../../../data/repositories/import_repository.dart';
import '../../widgets/common/app_shell.dart';

enum _ImportStage { landing, uploading, result }

class ImportDataScreen extends StatefulWidget {
  const ImportDataScreen({super.key});

  @override
  State<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends State<ImportDataScreen> {
  final ImportRepository _repository = ImportRepository();

  _ImportStage _stage = _ImportStage.landing;
  bool _isDownloading = false;
  ImportSummaryResponse? _result;

  Future<void> _handleDownloadTemplate() async {
    setState(() => _isDownloading = true);
    final result = await _repository.downloadTemplate();
    if (!mounted) return;
    setState(() => _isDownloading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] as String),
        backgroundColor: result['success'] == true
            ? ForuiThemeConfig.successColor
            : ForuiThemeConfig.errorColor,
      ),
    );
  }

  Future<void> _handlePickAndUpload() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    if (picked == null || picked.files.single.bytes == null) return;

    final file = picked.files.single;

    setState(() => _stage = _ImportStage.uploading);

    final result = await _repository.uploadImportFile(file.bytes!, file.name);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _result = result['data'] as ImportSummaryResponse;
        _stage = _ImportStage.result;
      });
    } else {
      setState(() => _stage = _ImportStage.landing);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String),
          backgroundColor: ForuiThemeConfig.errorColor,
        ),
      );
    }
  }

  void _handleImportAnother() {
    setState(() {
      _result = null;
      _stage = _ImportStage.landing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
              child: switch (_stage) {
                _ImportStage.landing => _buildLandingCard(context),
                _ImportStage.uploading => _buildUploadingCard(context),
                _ImportStage.result => _buildResultView(context),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDesktop = AppShell.isDesktop(context);
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 14),
      child: Row(
        children: [
          if (!isDesktop)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
            color: ForuiThemeConfig.textPrimary,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Import Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ForuiThemeConfig.textPrimary,
                  ),
                ),
                Text(
                  'Unggah data Kartu Keluarga & Penduduk dari Excel',
                  style: TextStyle(
                    fontSize: 12,
                    color: ForuiThemeConfig.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ForuiThemeConfig.surfaceGreen,
                  borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
                ),
                child: const Icon(
                  Icons.upload_file,
                  size: 24,
                  color: ForuiThemeConfig.primaryGreen,
                ),
              ),
              const SizedBox(width: ForuiThemeConfig.spacingMedium),
              const Expanded(
                child: Text(
                  'Import Data Kartu Keluarga & Penduduk',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ForuiThemeConfig.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ForuiThemeConfig.spacingLarge),
          _buildStep('1', 'Unduh template Excel di bawah ini.'),
          _buildStep('2', 'Isi data Kartu Keluarga dan Anggota Keluarga sesuai petunjuk pada sheet "Petunjuk".'),
          _buildStep('3', 'Unggah kembali file yang sudah diisi.'),
          _buildStep('4', 'Sistem akan memproses dan menampilkan laporan hasil per baris.'),
          const SizedBox(height: ForuiThemeConfig.spacingLarge),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isDownloading ? null : _handleDownloadTemplate,
                  icon: _isDownloading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded),
                  label: const Text('Unduh Template'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: ForuiThemeConfig.primaryGreen),
                    foregroundColor: ForuiThemeConfig.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ForuiThemeConfig.spacingMedium),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handlePickAndUpload,
                  icon: const Icon(Icons.file_upload_rounded),
                  label: const Text('Unggah File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ForuiThemeConfig.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ForuiThemeConfig.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: ForuiThemeConfig.surfaceGreen,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: ForuiThemeConfig.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: ForuiThemeConfig.spacingSmall),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: ForuiThemeConfig.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(vertical: 64),
      alignment: Alignment.center,
      child: const Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ForuiThemeConfig.primaryGreen),
          ),
          SizedBox(height: ForuiThemeConfig.spacingMedium),
          Text(
            'Mengunggah dan memproses file...',
            style: TextStyle(fontSize: 14, color: ForuiThemeConfig.textSecondary),
          ),
          SizedBox(height: 4),
          Text(
            'Bisa memakan waktu beberapa saat untuk file besar.',
            style: TextStyle(fontSize: 12, color: ForuiThemeConfig.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(BuildContext context) {
    final result = _result!;
    final summary = result.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 640;
            final tiles = [
              _ImportStatTile(
                label: 'Total Baris',
                value: summary.totalRows,
                color: ForuiThemeConfig.skyBlue,
                icon: Icons.list_alt_rounded,
              ),
              _ImportStatTile(
                label: 'Berhasil',
                value: summary.totalInserted,
                color: ForuiThemeConfig.successColor,
                icon: Icons.check_circle_rounded,
              ),
              _ImportStatTile(
                label: 'Dilewati',
                value: summary.totalSkipped,
                color: ForuiThemeConfig.warningColor,
                icon: Icons.warning_rounded,
              ),
              _ImportStatTile(
                label: 'Gagal',
                value: summary.totalFailed,
                color: ForuiThemeConfig.errorColor,
                icon: Icons.cancel_rounded,
              ),
            ];
            if (isNarrow) {
              return Column(
                children: [
                  for (final t in tiles) ...[t, const SizedBox(height: ForuiThemeConfig.spacingMedium)],
                ],
              );
            }
            return Row(
              children: [
                for (final t in tiles) ...[
                  Expanded(child: t),
                  if (t != tiles.last) const SizedBox(width: ForuiThemeConfig.spacingMedium),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: ForuiThemeConfig.spacingLarge),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Rincian Per Baris',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ForuiThemeConfig.textPrimary,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _handleImportAnother,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Impor File Lain'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ForuiThemeConfig.primaryGreen,
                side: const BorderSide(color: ForuiThemeConfig.primaryGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: ForuiThemeConfig.spacingMedium),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: result.results.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) => _buildResultRow(result.results[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(ImportRowResult row) {
    final (chipColor, chipBg, chipLabel) = switch (row.status) {
      'inserted' => (ForuiThemeConfig.successColor, ForuiThemeConfig.surfaceGreen, 'Berhasil'),
      'skipped_duplicate' => (ForuiThemeConfig.goldDark, ForuiThemeConfig.goldLight, 'Dilewati'),
      _ => (ForuiThemeConfig.errorColor, const Color(0xFFFDEDED), 'Gagal'),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ForuiThemeConfig.spacingMedium, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
            ),
            child: Text(
              chipLabel,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: chipColor),
            ),
          ),
          const SizedBox(width: ForuiThemeConfig.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${row.sheet} · Baris ${row.row}${row.identifier.isNotEmpty ? ' · ${row.identifier}' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ForuiThemeConfig.textPrimary,
                  ),
                ),
                if (row.reason.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    row.reason,
                    style: const TextStyle(fontSize: 12, color: ForuiThemeConfig.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportStatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _ImportStatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ForuiThemeConfig.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: ForuiThemeConfig.spacingSmall),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: ForuiThemeConfig.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
