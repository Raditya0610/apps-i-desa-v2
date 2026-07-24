import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../providers/family_card_detail_provider.dart';
import '../../../data/models/family_card_detail.dart';
import '../../../data/repositories/villager_repository.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/offline_banner.dart';
import '../../widgets/villagers/avatar_circle.dart';
import '../../widgets/family_cards/villager_form_dialog.dart';

class FamilyCardDetailScreen extends ConsumerWidget {
  final String nik;

  const FamilyCardDetailScreen({
    super.key,
    required this.nik,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(familyCardDetailProvider(nik));

    return AppShell(
      child: detailState.when(
              data: (result) {
                final familyCardDetail = result.data;
                if (familyCardDetail == null) {
                  return _buildNotFoundState(context);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, ref, familyCardDetail.name),

                    if (result.isFromCache)
                      OfflineBanner(
                        cachedAt: result.cachedAt,
                        onRetry: () => ref.invalidate(familyCardDetailProvider(nik)),
                      ),

                    // Scrollable Content
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(familyCardDetailProvider(nik));
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Family Info Card
                              _buildFamilyInfoCard(context, ref, familyCardDetail),
                              const SizedBox(height: ForuiThemeConfig.spacingLarge),

                              // Members Section Header with Add Button
                              _buildMembersSectionHeader(context, ref),
                              const SizedBox(height: ForuiThemeConfig.spacingMedium),

                              // Members Table
                              _buildMembersTable(context, ref, familyCardDetail.familyMembers),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer
                    _buildFooter(),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(context, ref, error),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, String familyHeadName) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Detail Kartu Keluarga',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isDesktop ? 26 : 18,
                    fontWeight: FontWeight.bold,
                    color: ForuiThemeConfig.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  familyHeadName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(familyCardDetailProvider(nik));
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyInfoHeader(BuildContext context, dynamic familyCardDetail) {
    final isMobile = AppShell.isMobile(context);

    final avatar = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: ForuiThemeConfig.surfaceGreen,
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
      ),
      child: const Icon(
        Icons.family_restroom,
        size: 32,
        color: ForuiThemeConfig.primaryGreen,
      ),
    );

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          familyCardDetail.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ForuiThemeConfig.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        // No. KK on its own line so the long number stays on one row.
        Row(
          children: [
            Icon(Icons.badge_outlined, size: 15, color: Colors.grey[500]),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'No. KK: ${familyCardDetail.nik}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final memberBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: ForuiThemeConfig.surfaceGreen,
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people, size: 18, color: ForuiThemeConfig.primaryGreen),
          const SizedBox(width: 8),
          Text(
            '${familyCardDetail.totalMembers} Anggota',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ForuiThemeConfig.primaryGreen,
            ),
          ),
        ],
      ),
    );

    // On phones the badge would squeeze the name/No. KK into a tiny column;
    // drop it onto its own line below instead.
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              avatar,
              const SizedBox(width: ForuiThemeConfig.spacingMedium),
              Expanded(child: titleBlock),
            ],
          ),
          const SizedBox(height: ForuiThemeConfig.spacingMedium),
          memberBadge,
        ],
      );
    }

    return Row(
      children: [
        avatar,
        const SizedBox(width: ForuiThemeConfig.spacingMedium),
        Expanded(child: titleBlock),
        const SizedBox(width: ForuiThemeConfig.spacingMedium),
        memberBadge,
      ],
    );
  }

  Widget _buildFamilyInfoCard(BuildContext context, WidgetRef ref, dynamic familyCardDetail) {
    return Container(
      padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFamilyInfoHeader(context, familyCardDetail),
          const SizedBox(height: ForuiThemeConfig.spacingMedium),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: ForuiThemeConfig.spacingMedium),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 20,
                color: ForuiThemeConfig.primaryGreen,
              ),
              const SizedBox(width: ForuiThemeConfig.spacingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alamat',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      familyCardDetail.address,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ForuiThemeConfig.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 20, color: ForuiThemeConfig.primaryGreen),
                onPressed: () => _navigateToEditFamilyCard(context, ref, familyCardDetail),
                tooltip: 'Edit Kartu Keluarga',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEditFamilyCard(
      BuildContext context, WidgetRef ref, FamilyCardDetail familyCardDetail) async {
    await context.push('/family-cards/add', extra: familyCardDetail);
    if (context.mounted) {
      ref.invalidate(familyCardDetailProvider(nik));
    }
  }

  Widget _buildMembersSectionHeader(BuildContext context, WidgetRef ref) {
    final addButton = ElevatedButton.icon(
      onPressed: () => _showAddVillagerDialog(context, ref),
      icon: const Icon(Icons.person_add, size: 18),
      label: const Text('Tambah Anggota'),
      style: ElevatedButton.styleFrom(
        backgroundColor: ForuiThemeConfig.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
        ),
      ),
    );

    const title = Text(
      'Anggota Keluarga',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ForuiThemeConfig.textPrimary,
      ),
    );

    // On phones the title + button do not fit side by side; stack them and let
    // the button span the full width so its label never clips.
    if (AppShell.isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: ForuiThemeConfig.spacingMedium),
          addButton,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(child: title),
        const SizedBox(width: ForuiThemeConfig.spacingMedium),
        addButton,
      ],
    );
  }

  void _showAddVillagerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VillagerFormDialog(
        familyCardId: nik,
        onSuccess: () {
          ref.invalidate(familyCardDetailProvider(nik));
        },
      ),
    );
  }

  Future<void> _showEditVillagerDialog(
      BuildContext context, WidgetRef ref, Map<String, dynamic> member) async {
    final memberNik = member['nik'] as String?;
    if (memberNik == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NIK tidak ditemukan'),
          backgroundColor: ForuiThemeConfig.errorColor,
        ),
      );
      return;
    }

    // Fetch the full record first. The family-card detail response only carries a
    // few fields per member, so building the edit form from it left birth date,
    // religion and marital status blank — and saving that form wrote the blanks
    // back, quietly erasing data the operator never touched.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final full = await VillagerRepository().getVillagerByNik(memberNik);

    if (!context.mounted) return;
    Navigator.of(context).pop(); // dismiss the loader

    if (full == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data penduduk. Periksa koneksi.'),
          backgroundColor: ForuiThemeConfig.errorColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VillagerFormDialog(
        familyCardId: nik,
        existingMember: full,
        onSuccess: () {
          ref.invalidate(familyCardDetailProvider(nik));
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref, Map<String, dynamic> member) async {
    final memberName = member['name'] ?? member['nama_lengkap'] ?? 'Anggota';
    final memberNik = member['nik'];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ForuiThemeConfig.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: ForuiThemeConfig.errorColor,
              ),
            ),
            const SizedBox(width: ForuiThemeConfig.spacingMedium),
            const Text('Hapus Anggota'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus anggota keluarga ini?'),
            const SizedBox(height: ForuiThemeConfig.spacingMedium),
            Container(
              padding: const EdgeInsets.all(ForuiThemeConfig.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
              ),
              child: Row(
                children: [
                  AvatarCircle(name: memberName, size: 40),
                  const SizedBox(width: ForuiThemeConfig.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memberName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (memberNik != null)
                          Text(
                            'NIK: $memberNik',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ForuiThemeConfig.spacingMedium),
            Text(
              'Data yang dihapus tidak dapat dikembalikan.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ForuiThemeConfig.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && memberNik != null) {
      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      final repository = VillagerRepository();
      final result = await repository.deleteVillager(memberNik);

      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Anggota berhasil dihapus'),
              backgroundColor: ForuiThemeConfig.successColor,
            ),
          );
          ref.invalidate(familyCardDetailProvider(nik));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal menghapus anggota'),
              backgroundColor: ForuiThemeConfig.errorColor,
            ),
          );
        }
      }
    }
  }

  Widget _buildMembersTable(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> members) {
    if (members.isEmpty) {
      return _buildEmptyMembersState(context, ref);
    }

    // The 8-column table only fits on wide screens; below the table breakpoint
    // each column would collapse and wrap text letter-by-letter. Render a card
    // list there instead.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppShell.kTableBreakpoint) {
          return _buildMembersCards(context, ref, members);
        }
        return _buildMembersDataTable(context, ref, members);
      },
    );
  }

  // === Mobile / narrow layout: one card per member ===
  Widget _buildMembersCards(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> members) {
    return Column(
      children: List.generate(members.length, (index) {
        final member = members[index];
        final isHead = member['status_hubungan'] == 'Kepala Keluarga';

        return Container(
          margin: const EdgeInsets.only(bottom: ForuiThemeConfig.spacingMedium),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
            border: Border.all(
              color: isHead
                  ? ForuiThemeConfig.primaryGreen.withValues(alpha: 0.35)
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header strip: avatar, name, status badge, actions
              Container(
                color: isHead ? ForuiThemeConfig.surfaceGreen : Colors.white,
                padding: const EdgeInsets.all(ForuiThemeConfig.spacingMedium),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AvatarCircle(name: member['name'] ?? 'Unknown', size: 44),
                    const SizedBox(width: ForuiThemeConfig.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member['name'] ?? '-',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isHead ? FontWeight.bold : FontWeight.w600,
                              color: ForuiThemeConfig.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _statusBadge(isHead, member['status_hubungan']),
                        ],
                      ),
                    ),
                    _memberActions(context, ref, member),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              // Detail grid
              Padding(
                padding: const EdgeInsets.all(ForuiThemeConfig.spacingMedium),
                child: Column(
                  children: [
                    _memberInfoRow('NIK', member['nik'] ?? '-', mono: true),
                    _memberInfoRow(
                      'Jenis Kelamin',
                      member['jenis_kelamin'] ?? '-',
                    ),
                    _memberInfoRow(
                      'Usia',
                      member['age'] != null ? '${member['age']} tahun' : '-',
                    ),
                    _memberInfoRow('Pendidikan', member['pendidikan'] ?? '-'),
                    _memberInfoRow('Pekerjaan', member['pekerjaan'] ?? '-',
                        isLast: true),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _statusBadge(bool isHead, String? status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHead
            ? ForuiThemeConfig.primaryGreen.withValues(alpha: 0.12)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHead) ...[
            const Icon(Icons.star_rounded,
                size: 14, color: ForuiThemeConfig.primaryGreen),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              status ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHead ? FontWeight.bold : FontWeight.w500,
                color: isHead
                    ? ForuiThemeConfig.primaryGreen
                    : ForuiThemeConfig.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberInfoRow(String label, String value,
      {bool mono = false, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(width: ForuiThemeConfig.spacingSmall),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ForuiThemeConfig.textPrimary,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberActions(BuildContext context, WidgetRef ref, Map<String, dynamic> member) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined,
              size: 20, color: ForuiThemeConfig.primaryGreen),
          onPressed: () => _showEditVillagerDialog(context, ref, member),
          tooltip: 'Edit',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline,
              size: 20, color: ForuiThemeConfig.errorColor),
          onPressed: () => _showDeleteConfirmation(context, ref, member),
          tooltip: 'Hapus',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }

  // === Wide layout: the classic data table ===
  Widget _buildMembersDataTable(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> members) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text('NO', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('NIK', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('NAMA', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 1,
                  child: Text('USIA', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('PENDIDIKAN', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('PEKERJAAN', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 100,
                  child: Text('AKSI', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          // Data Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final member = members[index];
              final isHead = member['status_hubungan'] == 'Kepala Keluarga';
              return Container(
                color: isHead ? Colors.green.shade50 : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        member['nik'] ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          AvatarCircle(
                            name: member['name'] ?? 'Unknown',
                            size: 32,
                          ),
                          const SizedBox(width: ForuiThemeConfig.spacingSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member['name'] ?? '-',
                                  style: TextStyle(
                                    fontWeight: isHead ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                                if (member['jenis_kelamin'] != null)
                                  Text(
                                    member['jenis_kelamin'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isHead
                              ? ForuiThemeConfig.primaryGreen.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member['status_hubungan'] ?? '-',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isHead ? FontWeight.bold : FontWeight.w500,
                            color: isHead ? ForuiThemeConfig.primaryGreen : ForuiThemeConfig.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        member['age'] != null ? '${member['age']} thn' : '-',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        member['pendidikan'] ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        member['pekerjaan'] ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: ForuiThemeConfig.primaryGreen,
                            ),
                            onPressed: () => _showEditVillagerDialog(context, ref, member),
                            tooltip: 'Edit',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: ForuiThemeConfig.errorColor,
                            ),
                            onPressed: () => _showDeleteConfirmation(context, ref, member),
                            tooltip: 'Hapus',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMembersState(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(ForuiThemeConfig.spacingXLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: ForuiThemeConfig.spacingMedium),
            const Text(
              'Belum ada anggota keluarga',
              style: TextStyle(color: ForuiThemeConfig.textSecondary),
            ),
            const SizedBox(height: ForuiThemeConfig.spacingMedium),
            ElevatedButton.icon(
              onPressed: () => _showAddVillagerDialog(context, ref),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Tambah Anggota Pertama'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ForuiThemeConfig.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      alignment: Alignment.center,
      child: Text(
        '© 2025 Apps I-Desa. Hak Cipta Dilindungi.',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: ForuiThemeConfig.spacingMedium),
          const Text(
            'Data tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              color: ForuiThemeConfig.textSecondary,
            ),
          ),
          const SizedBox(height: ForuiThemeConfig.spacingMedium),
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ForuiThemeConfig.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: ForuiThemeConfig.errorColor,
          ),
          const SizedBox(height: ForuiThemeConfig.spacingMedium),
          Text(
            'Terjadi kesalahan: $error',
            style: const TextStyle(color: ForuiThemeConfig.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ForuiThemeConfig.spacingMedium),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(familyCardDetailProvider(nik));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ForuiThemeConfig.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
