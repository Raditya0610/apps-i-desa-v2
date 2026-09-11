import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/forui_theme.dart';
import '../../../data/models/pending_mutation.dart';
import '../../../providers/write_queue_provider.dart';

/// Lists this village's pending offline writes and lets the operator force a
/// retry (for a WiFi-up-but-no-real-internet captive portal, where the
/// automatic connectivity listener never fires) or dismiss/retry entries the
/// backend has permanently rejected.
Future<void> showPendingSyncSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _PendingSyncSheet(),
  );
}

class _PendingSyncSheet extends ConsumerWidget {
  const _PendingSyncSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(writeQueueProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Data belum tersinkron',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ForuiThemeConfig.textPrimary),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => ref.read(writeQueueProvider.notifier).flushNow(),
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  label: const Text('Sinkronkan sekarang'),
                ),
              ],
            ),
            const SizedBox(height: ForuiThemeConfig.spacingSmall),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Semua perubahan sudah tersinkron.',
                  style: TextStyle(color: ForuiThemeConfig.textSecondary),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) => _PendingEntryTile(entries[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PendingEntryTile extends ConsumerWidget {
  final PendingMutation entry;
  const _PendingEntryTile(this.entry);

  String get _domainLabel => switch (entry.domain) {
        MutationDomain.familyCard => 'Kartu Keluarga',
        MutationDomain.villager => 'Penduduk',
      };

  String get _opLabel => switch (entry.op) {
        MutationOp.create => 'Tambah',
        MutationOp.update => 'Ubah',
        MutationOp.delete => 'Hapus',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      leading: Icon(
        entry.isFailed ? Icons.error_outline_rounded : Icons.schedule_rounded,
        color: entry.isFailed ? ForuiThemeConfig.errorColor : ForuiThemeConfig.warningColor,
      ),
      title: Text('$_opLabel $_domainLabel • ${entry.entityKey}'),
      subtitle: entry.isFailed
          ? Text(entry.lastError!, maxLines: 2, overflow: TextOverflow.ellipsis)
          : const Text('Menunggu koneksi internet'),
      trailing: entry.isFailed
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Coba lagi',
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  onPressed: () => ref.read(writeQueueProvider.notifier).retry(entry.id),
                ),
                IconButton(
                  tooltip: 'Hapus',
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: () => ref.read(writeQueueProvider.notifier).dismiss(entry.id),
                ),
              ],
            )
          : null,
    );
  }
}
