import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../data/models/import_result.dart';
import '../../../data/repositories/import_repository.dart';
import '../../../providers/import_provider.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/unsaved_changes_dialog.dart';

enum _ImportStage { landing, uploading, preview, committing, result }

class ImportDataScreen extends ConsumerStatefulWidget {
  const ImportDataScreen({super.key});

  @override
  ConsumerState<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends ConsumerState<ImportDataScreen> {
  final ImportRepository _repository = ImportRepository();

  _ImportStage _stage = _ImportStage.landing;
  bool _isDownloading = false;
  ImportSummaryResponse? _result;

  // Held in memory from the preview step so "Terima & Simpan" can commit the
  // same file without asking the operator to re-pick it.
  Uint8List? _pendingBytes;
  String? _pendingFilename;

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

  /// Picks a file and asks the backend what it *would* do with it — nothing
  /// is written to the database yet. The operator reviews the result on the
  /// [_ImportStage.preview] screen before anything is committed.
  Future<void> _handlePickAndPreview() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    if (picked == null || picked.files.single.bytes == null) return;

    final file = picked.files.single;
    _pendingBytes = file.bytes!;
    _pendingFilename = file.name;

    setState(() => _stage = _ImportStage.uploading);

    final result = await _repository.previewImportFile(file.bytes!, file.name);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _result = result['data'] as ImportSummaryResponse;
        _stage = _ImportStage.preview;
      });
      ref.read(hasUnsavedImportPreviewProvider.notifier).state = true;
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

  /// Commits the same file the preview just showed. Re-validates server-side
  /// (data may have changed since the preview), so the final report can
  /// differ slightly from what was previewed.
  Future<void> _handleCommit() async {
    final bytes = _pendingBytes;
    final filename = _pendingFilename;
    if (bytes == null || filename == null) return;

    setState(() => _stage = _ImportStage.committing);

    final result = await _repository.uploadImportFile(bytes, filename);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _result = result['data'] as ImportSummaryResponse;
        _pendingBytes = null;
        _pendingFilename = null;
        _stage = _ImportStage.result;
      });
      ref.read(hasUnsavedImportPreviewProvider.notifier).state = false;
    } else {
      setState(() => _stage = _ImportStage.preview);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String),
          backgroundColor: ForuiThemeConfig.errorColor,
        ),
      );
    }
  }

  void _handleDiscardPreview() {
    setState(() {
      _result = null;
      _pendingBytes = null;
      _pendingFilename = null;
      _stage = _ImportStage.landing;
    });
    ref.read(hasUnsavedImportPreviewProvider.notifier).state = false;
  }

  void _handleImportAnother() {
    setState(() {
      _result = null;
      _pendingBytes = null;
      _pendingFilename = null;
      _stage = _ImportStage.landing;
    });
    ref.read(hasUnsavedImportPreviewProvider.notifier).state = false;
  }

  @override
  void dispose() {
    // Safety net: if this screen goes away through some path other than the
    // discard/commit handlers above, don't leave the flag stuck true with no
    // ImportDataScreen left to ever clear it — that would block navigation
    // forever with no way to reach the dialog that resolves it.
    if (ref.read(hasUnsavedImportPreviewProvider)) {
      Future.microtask(() => ref.read(hasUnsavedImportPreviewProvider.notifier).state = false);
    }
    super.dispose();
  }

  /// Guards navigating away while a preview hasn't been accepted or
  /// discarded yet — the fetched-but-unconfirmed report (and the file bytes
  /// held for commit) would otherwise be silently lost. Fires for the header
  /// back button, the system/browser back gesture, and any other pop
  /// attempt alike, since [PopScope] intercepts all of them the same way.
  Future<void> _handlePopAttempt(bool didPop, Object? result) async {
    if (didPop) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ada pratinjau import data yang belum disimpan!',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: ForuiThemeConfig.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );

    final leave = await showUnsavedChangesDialog(
      context,
      title: 'Pratinjau belum disimpan',
      message: 'Anda belum menekan "Terima & Simpan". Jika keluar sekarang, '
          'hasil pratinjau ini akan hilang dan Anda perlu mengunggah ulang file.',
      stayLabel: 'Lanjutkan Pratinjau',
      leaveLabel: 'Keluar & Batalkan',
    );

    if (leave == true) {
      _handleDiscardPreview();
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(result);
        } else {
          context.go('/');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _stage != _ImportStage.preview,
      onPopInvokedWithResult: _handlePopAttempt,
      child: AppShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              // Preview/result contain a long row list — that list scrolls on
              // its own (see _buildResultView) so the header, stat tiles, and
              // Batalkan/Terima & Simpan buttons stay put instead of requiring
              // a scroll to reach. The other stages are short, so a page-level
              // scroll is simplest and safest against overflow on small screens.
              child: switch (_stage) {
                _ImportStage.landing => SingleChildScrollView(
                    padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
                    child: _buildLandingCard(context),
                  ),
                _ImportStage.uploading => SingleChildScrollView(
                    padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
                    child: _buildUploadingCard(
                      context,
                      caption: 'Mengunggah dan memeriksa file...',
                    ),
                  ),
                _ImportStage.preview => Padding(
                    padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
                    child: _buildResultView(context, isPreview: true),
                  ),
                _ImportStage.committing => SingleChildScrollView(
                    padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
                    child: _buildUploadingCard(
                      context,
                      caption: 'Menyimpan data...',
                    ),
                  ),
                _ImportStage.result => Padding(
                    padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
                    child: _buildResultView(context, isPreview: false),
                  ),
              },
            ),
          ],
        ),
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
                  onPressed: _handlePickAndPreview,
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

  Widget _buildUploadingCard(BuildContext context, {required String caption}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(vertical: 64),
      alignment: Alignment.center,
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ForuiThemeConfig.primaryGreen),
          ),
          const SizedBox(height: ForuiThemeConfig.spacingMedium),
          Text(
            caption,
            style: const TextStyle(fontSize: 14, color: ForuiThemeConfig.textSecondary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bisa memakan waktu beberapa saat untuk file besar.',
            style: TextStyle(fontSize: 12, color: ForuiThemeConfig.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(BuildContext context, {required bool isPreview}) {
    final result = _result!;
    final summary = result.summary;
    // Problems first, so the operator sees what needs attention without
    // scrolling past hundreds of clean rows: rejected, then skipped, then
    // the (usually much longer) list of rows that are fine.
    final sortedResults = _sortResultsByPriority(result.results);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isPreview) _buildPreviewBanner(context),
        if (isPreview) const SizedBox(height: ForuiThemeConfig.spacingMedium),
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
                label: isPreview ? 'Akan Ditambahkan' : 'Berhasil',
                value: summary.totalInserted,
                color: ForuiThemeConfig.successColor,
                icon: Icons.check_circle_rounded,
              ),
              _ImportStatTile(
                label: isPreview ? 'Akan Dilewati' : 'Dilewati',
                value: summary.totalSkipped,
                color: ForuiThemeConfig.warningColor,
                icon: Icons.warning_rounded,
              ),
              _ImportStatTile(
                label: isPreview ? 'Akan Ditolak' : 'Gagal',
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ForuiThemeConfig.textPrimary,
                ),
              ),
            ),
            if (isPreview) ...[
              OutlinedButton(
                onPressed: _handleDiscardPreview,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ForuiThemeConfig.textSecondary,
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text('Batalkan'),
              ),
              const SizedBox(width: ForuiThemeConfig.spacingSmall),
              ElevatedButton.icon(
                onPressed: _handleCommit,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Terima & Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ForuiThemeConfig.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ] else
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
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
              border: Border.all(color: Colors.grey.shade200),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              itemCount: sortedResults.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, index) =>
                  _buildResultRow(sortedResults[index], isPreview: isPreview),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ForuiThemeConfig.spacingMedium),
      decoration: BoxDecoration(
        color: ForuiThemeConfig.surfaceGreen,
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
        border: Border.all(color: ForuiThemeConfig.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.fact_check_rounded, color: ForuiThemeConfig.primaryGreen, size: 20),
          SizedBox(width: ForuiThemeConfig.spacingSmall),
          Expanded(
            child: Text(
              'Ini pratinjau — belum ada data yang disimpan. Periksa hasilnya, lalu pilih Batalkan atau Terima & Simpan.',
              style: TextStyle(
                fontSize: 13,
                color: ForuiThemeConfig.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(ImportRowResult row, {required bool isPreview}) {
    final (chipColor, chipBg, chipLabel) = switch (row.status) {
      'inserted' => (
          ForuiThemeConfig.successColor,
          ForuiThemeConfig.surfaceGreen,
          isPreview ? 'Akan Ditambahkan' : 'Berhasil',
        ),
      'skipped_duplicate' => (
          ForuiThemeConfig.goldDark,
          ForuiThemeConfig.goldLight,
          isPreview ? 'Akan Dilewati' : 'Dilewati',
        ),
      _ => (
          ForuiThemeConfig.errorColor,
          const Color(0xFFFDEDED),
          isPreview ? 'Akan Ditolak' : 'Gagal',
        ),
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

/// Orders rows so the ones needing attention surface first: rejected, then
/// skipped, then the (usually much longer) run of clean rows — instead of
/// the file's own row order, which buries problems hundreds of rows deep.
/// Groups rather than sorts-with-a-comparator so rows keep their original
/// relative order within each status (List.sort isn't guaranteed stable).
List<ImportRowResult> _sortResultsByPriority(List<ImportRowResult> results) {
  const priority = {'failed': 0, 'skipped_duplicate': 1, 'inserted': 2};
  final buckets = <int, List<ImportRowResult>>{};
  for (final r in results) {
    final rank = priority[r.status] ?? 3;
    buckets.putIfAbsent(rank, () => []).add(r);
  }
  final sortedRanks = buckets.keys.toList()..sort();
  return [for (final rank in sortedRanks) ...buckets[rank]!];
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
