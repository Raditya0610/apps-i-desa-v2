import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../providers/family_card_provider.dart';
import '../../../data/services/export_service.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/villagers/avatar_circle.dart';

class FamilyCardsScreen extends ConsumerStatefulWidget {
  const FamilyCardsScreen({super.key});

  @override
  ConsumerState<FamilyCardsScreen> createState() => _FamilyCardsScreenState();
}

class _FamilyCardsScreenState extends ConsumerState<FamilyCardsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> selectedNiks = {};
  int currentPage = 1;
  int itemsPerPage = 10;
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> get filteredFamilyCards {
    final allCards = ref.watch(familyCardsProvider).familyCards;
    if (searchQuery.isEmpty) return allCards;
    final q = searchQuery.toLowerCase();
    return allCards
        .where((c) => c.name.toLowerCase().contains(q) || c.nik.contains(q))
        .toList();
  }

  List<dynamic> get paginatedFamilyCards {
    final filtered = filteredFamilyCards;
    final start = (currentPage - 1) * itemsPerPage;
    if (start >= filtered.length) return [];
    final end = (start + itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int get totalPages =>
      (filteredFamilyCards.length / itemsPerPage).ceil().clamp(1, 999999);

  Future<void> _handleExport(BuildContext context) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 120),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 280,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Export Data',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ForuiThemeConfig.textPrimary)),
                const SizedBox(height: 4),
                const Text('Pilih format export:',
                    style: TextStyle(
                        fontSize: 12, color: ForuiThemeConfig.textSecondary)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, 'excel'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: Color(0xFFDDE4DE)),
                          foregroundColor: ForuiThemeConfig.textPrimary,
                        ),
                        child: const Text('Excel',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, 'csv'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: Color(0xFFDDE4DE)),
                          foregroundColor: ForuiThemeConfig.textPrimary,
                        ),
                        child:
                            const Text('CSV', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: ForuiThemeConfig.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Batal', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (choice == null || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final exportData = filteredFamilyCards
        .map((c) => {
              'nik': c.nik,
              'nama_lengkap': c.name,
              'jumlah_anggota': c.totalMembers,
            })
        .toList();

    final filePath = choice == 'excel'
        ? await ExportService.exportFamilyCardsToExcel(exportData)
        : await ExportService.exportFamilyCardsToCsv(exportData);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(filePath != null
            ? 'File berhasil disimpan: $filePath'
            : 'Gagal mengekspor data'),
        backgroundColor: filePath != null
            ? ForuiThemeConfig.primaryGreen
            : ForuiThemeConfig.errorColor,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyCardsProvider);
    final isDesktop = AppShell.isDesktop(context);

    return AppShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDesktop),
          _buildToolbar(context, isDesktop),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? _buildErrorState(context)
                    : state.familyCards.isEmpty
                        ? _buildEmptyState(context)
                        : isDesktop
                            ? _buildDataTable(context)
                            : _buildCardList(context),
          ),
          if (!state.isLoading) _buildPagination(context, isDesktop),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
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
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Data Kartu Keluarga',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ForuiThemeConfig.textPrimary)),
                Text('Data Terpadu Desa',
                    style: TextStyle(
                        fontSize: 12,
                        color: ForuiThemeConfig.textSecondary)),
              ],
            ),
          ),
          // Quick add button (always visible)
          ElevatedButton.icon(
            onPressed: () => context.push('/family-cards/add'),
            icon: const Icon(Icons.add, size: 16),
            label: Text(isDesktop ? 'Tambah KK' : 'Tambah'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ForuiThemeConfig.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16 : 12, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, bool isDesktop) {
    final searchField = TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari nama / NIK...',
        hintStyle:
            const TextStyle(fontSize: 13, color: ForuiThemeConfig.textHint),
        prefixIcon: const Icon(Icons.search_rounded,
            size: 18, color: ForuiThemeConfig.textHint),
        filled: true,
        fillColor: const Color(0xFFF4F7F5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8EDE9))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: ForuiThemeConfig.primaryGreen, width: 1.5)),
        isDense: true,
      ),
      onChanged: (v) => setState(() {
        searchQuery = v;
        currentPage = 1;
      }),
    );

    final exportBtn = OutlinedButton.icon(
      onPressed: () => _handleExport(context),
      icon: const Icon(Icons.download_outlined, size: 16),
      label: const Text('Export'),
      style: OutlinedButton.styleFrom(
        foregroundColor: ForuiThemeConfig.textSecondary,
        side: const BorderSide(color: Color(0xFFDDE4DE)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (isDesktop) {
      return Container(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
        color: Colors.white,
        child: Row(
          children: [
            SizedBox(width: 280, child: searchField),
            const SizedBox(width: 12),
            exportBtn,
          ],
        ),
      );
    }

    // Mobile: stacked
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: exportBtn),
            ],
          ),
        ],
      ),
    );
  }

  // ── Desktop: table ──────────────────────────────────────────────────────────

  Widget _buildDataTable(BuildContext context) {
    final paginated = paginatedFamilyCards;
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 16, 28, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            color: const Color(0xFFF8FAF8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Checkbox(
                    value: selectedNiks.length == paginated.length &&
                        paginated.isNotEmpty,
                    activeColor: ForuiThemeConfig.primaryGreen,
                    onChanged: (v) => setState(() => v == true
                        ? selectedNiks =
                            paginated.map((c) => c.nik as String).toSet()
                        : selectedNiks.clear()),
                  ),
                ),
                const Expanded(
                    flex: 2,
                    child: Text('NO KK',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ForuiThemeConfig.textSecondary,
                            letterSpacing: 0.5))),
                const Expanded(
                    flex: 3,
                    child: Text('KEPALA KELUARGA',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ForuiThemeConfig.textSecondary,
                            letterSpacing: 0.5))),
                const Expanded(
                    flex: 2,
                    child: Text('ANGGOTA',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ForuiThemeConfig.textSecondary,
                            letterSpacing: 0.5))),
                const SizedBox(
                    width: 72,
                    child: Text('AKSI',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ForuiThemeConfig.textSecondary,
                            letterSpacing: 0.5))),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: paginated.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (_, i) {
                final card = paginated[i];
                final selected = selectedNiks.contains(card.nik);
                return InkWell(
                  onTap: () => context.push('/family-cards/${card.nik}'),
                  child: Container(
                    color: selected
                        ? ForuiThemeConfig.surfaceGreen
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Checkbox(
                            value: selected,
                            activeColor: ForuiThemeConfig.primaryGreen,
                            onChanged: (v) => setState(() => v == true
                                ? selectedNiks.add(card.nik)
                                : selectedNiks.remove(card.nik)),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(card.nik,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  color: ForuiThemeConfig.textSecondary)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              AvatarCircle(name: card.name, size: 30),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(card.name,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: ForuiThemeConfig.textPrimary),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('${card.totalMembers} orang',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: ForuiThemeConfig.textSecondary)),
                        ),
                        SizedBox(
                          width: 72,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.open_in_new_rounded,
                                    size: 17),
                                color: ForuiThemeConfig.primaryGreen,
                                onPressed: () =>
                                    context.push('/family-cards/${card.nik}'),
                                tooltip: 'Detail',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile: card list ───────────────────────────────────────────────────────

  Widget _buildCardList(BuildContext context) {
    final paginated = paginatedFamilyCards;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      itemCount: paginated.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final card = paginated[i];
        return InkWell(
          onTap: () => context.push('/family-cards/${card.nik}'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                AvatarCircle(name: card.name, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ForuiThemeConfig.textPrimary)),
                      const SizedBox(height: 2),
                      Text('NIK: ${card.nik}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: ForuiThemeConfig.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ForuiThemeConfig.surfaceGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${card.totalMembers} org',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ForuiThemeConfig.primaryGreen)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: ForuiThemeConfig.textHint, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Pagination ──────────────────────────────────────────────────────────────

  Widget _buildPagination(BuildContext context, bool isDesktop) {
    final filtered = filteredFamilyCards;
    final start = filtered.isEmpty ? 0 : (currentPage - 1) * itemsPerPage + 1;
    final end = (currentPage * itemsPerPage).clamp(0, filtered.length);

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 28 : 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isDesktop)
            Text('Menampilkan $start–$end dari ${filtered.length} data',
                style: const TextStyle(
                    fontSize: 12, color: ForuiThemeConfig.textSecondary))
          else
            Text('$start–$end / ${filtered.length}',
                style: const TextStyle(
                    fontSize: 12, color: ForuiThemeConfig.textSecondary)),
          Row(
            children: [
              _PageBtn(
                label: '← Prev',
                enabled: currentPage > 1,
                onTap: () => setState(() => currentPage--),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ForuiThemeConfig.primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$currentPage / $totalPages',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
              const SizedBox(width: 8),
              _PageBtn(
                label: 'Next →',
                enabled: currentPage < totalPages,
                onTap: () => setState(() => currentPage++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final error = ref.watch(familyCardsProvider).error;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 56, color: ForuiThemeConfig.errorColor),
          const SizedBox(height: 12),
          Text(error ?? 'Terjadi kesalahan'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(familyCardsProvider.notifier).refresh(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.family_restroom, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Belum ada data kartu keluarga',
              style: TextStyle(color: ForuiThemeConfig.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/family-cards/add'),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Kartu Keluarga'),
            style: ElevatedButton.styleFrom(
                backgroundColor: ForuiThemeConfig.primaryGreen,
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _PageBtn(
      {required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF4F7F5) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE8EDE9)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: enabled
                    ? ForuiThemeConfig.textPrimary
                    : ForuiThemeConfig.textHint)),
      ),
    );
  }
}
