import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../providers/idm_score_provider.dart';
import '../../widgets/common/app_shell.dart';

class SubDimensionsHubScreen extends ConsumerStatefulWidget {
  const SubDimensionsHubScreen({super.key});

  @override
  ConsumerState<SubDimensionsHubScreen> createState() =>
      _SubDimensionsHubScreenState();
}

class _SubDimensionsHubScreenState
    extends ConsumerState<SubDimensionsHubScreen> {
  String _selectedCategory = 'pendidikan';

  final List<_CategoryItem> _categories = [
    const _CategoryItem(
      id: 'pendidikan',
      title: 'Pendidikan',
      description: 'Akses dan fasilitas pendidikan dasar hingga menengah.',
      icon: Icons.menu_book_outlined,
      route: '/sub-dimensions/pendidikan',
      scoreKey: 'pendidikan',
    ),
    const _CategoryItem(
      id: 'kesehatan',
      title: 'Kesehatan',
      description: 'Fasilitas dan layanan kesehatan masyarakat.',
      icon: Icons.favorite_border,
      route: '/sub-dimensions/kesehatan',
      scoreKey: 'kesehatan',
    ),
    const _CategoryItem(
      id: 'utilitas-dasar',
      title: 'Utilitas Dasar',
      description: 'Air bersih, listrik, dan sanitasi dasar.',
      icon: Icons.lightbulb_outline,
      route: '/sub-dimensions/utilitas-dasar',
      scoreKey: 'utilitas_dasar',
    ),
    const _CategoryItem(
      id: 'aktivitas',
      title: 'Aktivitas',
      description: 'Kegiatan sosial dan kemasyarakatan.',
      icon: Icons.auto_awesome_outlined,
      route: '/sub-dimensions/aktivitas',
      scoreKey: 'aktivitas',
    ),
    const _CategoryItem(
      id: 'fasilitas-masyarakat',
      title: 'Fasilitas Masyarakat',
      description: 'Balai desa, tempat ibadah, dan fasilitas umum.',
      icon: Icons.people_outline,
      route: '/sub-dimensions/fasilitas-masyarakat',
      scoreKey: 'fasilitas_masyarakat',
    ),
    const _CategoryItem(
      id: 'produksi-desa',
      title: 'Produksi Desa',
      description: 'Hasil pertanian, peternakan, dan industri desa.',
      icon: Icons.agriculture_outlined,
      route: '/sub-dimensions/produksi-desa',
      scoreKey: 'produksi_desa',
    ),
    const _CategoryItem(
      id: 'fasilitas-ekonomi',
      title: 'Fasilitas Ekonomi',
      description: 'Pasar, toko, dan infrastruktur perdagangan.',
      icon: Icons.store_outlined,
      route: '/sub-dimensions/fasilitas-ekonomi',
      scoreKey: 'fasilitas_pendukung_ekonomi',
    ),
    const _CategoryItem(
      id: 'pengelolaan-lingkungan',
      title: 'Pengelolaan Lingkungan',
      description: 'Kelestarian dan kebersihan lingkungan.',
      icon: Icons.eco_outlined,
      route: '/sub-dimensions/pengelolaan-lingkungan',
      scoreKey: 'pengelolaan_lingkungan',
    ),
    const _CategoryItem(
      id: 'penanggulangan-bencana',
      title: 'Penanggulangan Bencana',
      description: 'Mitigasi dan tanggap darurat bencana.',
      icon: Icons.warning_amber_outlined,
      route: '/sub-dimensions/penanggulangan-bencana',
      scoreKey: 'penanggulangan_bencana',
    ),
    const _CategoryItem(
      id: 'kondisi-akses-jalan',
      title: 'Kondisi Akses Jalan',
      description: 'Infrastruktur dan kondisi jalan desa.',
      icon: Icons.route_outlined,
      route: '/sub-dimensions/kondisi-akses-jalan',
      scoreKey: 'kondisi_akses_jalan',
    ),
    const _CategoryItem(
      id: 'kemudahan-akses',
      title: 'Kemudahan Akses',
      description: 'Transportasi dan komunikasi.',
      icon: Icons.directions_car_outlined,
      route: '/sub-dimensions/kemudahan-akses',
      scoreKey: 'kemudahan_akses',
    ),
    const _CategoryItem(
      id: 'kelembagaan-pelayanan',
      title: 'Kelembagaan Pelayanan',
      description: 'Layanan publik dan kelembagaan desa.',
      icon: Icons.business_outlined,
      route: '/sub-dimensions/kelembagaan-pelayanan',
      scoreKey: 'kelembagaan_pelayanan_desa',
    ),
    const _CategoryItem(
      id: 'tata-kelola-keuangan',
      title: 'Tata Kelola Keuangan',
      description: 'Pengelolaan dana dan keuangan desa.',
      icon: Icons.account_balance_outlined,
      route: '/sub-dimensions/tata-kelola-keuangan',
      scoreKey: 'tata_kelola_keuangan_desa',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final idmState = ref.watch(idmScoreProvider);
    final selectedCategoryData = _categories.firstWhere(
      (c) => c.id == _selectedCategory,
      orElse: () => _categories.first,
    );

    return AppShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(idmState),
                  const SizedBox(height: ForuiThemeConfig.spacingLarge),
                  _buildScoreCardsRow(context, idmState),
                  const SizedBox(height: ForuiThemeConfig.spacingLarge),
                  _buildDetailInputSection(selectedCategoryData, idmState),
                ],
              ),
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
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Indikator Desa Membangun',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ForuiThemeConfig.textPrimary,
                  ),
                ),
                Text(
                  'Data Terpadu Desa',
                  style: TextStyle(
                    fontSize: 12,
                    color: ForuiThemeConfig.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: ForuiThemeConfig.primaryGreen),
            tooltip: 'Perbarui skor',
            onPressed: () => ref.read(idmScoreProvider.notifier).refresh(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(IdmScoreState idmState) {
    final scores = idmState.scores;
    final idm = scores?.idmScore ?? 0.0;
    final status = scores?.status ?? '-';
    final year = scores?.year ?? 0;
    final isLoading = idmState.isLoading;

    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 500;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), ForuiThemeConfig.primaryGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius:
              BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
        ),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heroYearBadge(year),
                  const SizedBox(height: 12),
                  Text(
                    isLoading ? 'Menghitung...' : status,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Status Indeks Desa Membangun (IDM).',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      isLoading
                          ? const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : Text(
                              idm.toStringAsFixed(3),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  height: 1),
                            ),
                      const SizedBox(width: 10),
                      Text('Skor Indeks\nKomposit',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12)),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _heroYearBadge(year),
                        const SizedBox(height: 14),
                        Text(
                          isLoading ? 'Menghitung...' : status,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text('Status Indeks Desa Membangun (IDM).',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14)),
                        if (scores != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${scores.completedCount}/${scores.totalCount} sub-dimensi terisi',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      isLoading
                          ? const SizedBox(
                              width: 52,
                              height: 52,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3))
                          : Text(
                              idm.toStringAsFixed(3),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  height: 1),
                            ),
                      const SizedBox(height: 6),
                      Text('Skor Indeks Komposit',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
      );
    });
  }

  Widget _heroYearBadge(int year) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today,
              size: 12, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            year > 0 ? 'DATA TAHUN $year' : 'BELUM ADA DATA',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCardsRow(BuildContext context, IdmScoreState idmState) {
    final scores = idmState.scores;
    final isLoading = idmState.isLoading;

    final cards = [
      _ScoreCardData(
        title: 'Ketahanan Sosial',
        score: scores?.iksScore ?? 0.0,
        color: const Color(0xFF00897B),
        icon: Icons.people_alt_outlined,
        isLoading: isLoading,
      ),
      _ScoreCardData(
        title: 'Ketahanan Ekonomi',
        score: scores?.ikeScore ?? 0.0,
        color: const Color(0xFFFFA000),
        icon: Icons.monetization_on_outlined,
        isLoading: isLoading,
      ),
      _ScoreCardData(
        title: 'Ketahanan Lingkungan',
        score: scores?.iklScore ?? 0.0,
        color: const Color(0xFF43A047),
        icon: Icons.eco_outlined,
        isLoading: isLoading,
      ),
    ];

    if (AppShell.isDesktop(context)) {
      return Row(
        children: [
          Expanded(child: _ScoreCard(data: cards[0])),
          const SizedBox(width: ForuiThemeConfig.spacingMedium),
          Expanded(child: _ScoreCard(data: cards[1])),
          const SizedBox(width: ForuiThemeConfig.spacingMedium),
          Expanded(child: _ScoreCard(data: cards[2])),
        ],
      );
    }

    return Column(
      children: [
        _ScoreCard(data: cards[0]),
        const SizedBox(height: ForuiThemeConfig.spacingMedium),
        _ScoreCard(data: cards[1]),
        const SizedBox(height: ForuiThemeConfig.spacingMedium),
        _ScoreCard(data: cards[2]),
      ],
    );
  }

  Widget _buildDetailInputSection(
      _CategoryItem selectedCategoryData, IdmScoreState idmState) {
    final subScores = idmState.scores?.subDimensionScores ?? {};
    final completeness = idmState.scores?.dataCompleteness ?? {};

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail & Input Data IDM',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ForuiThemeConfig.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih kategori untuk mengisi atau memperbarui data.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Category Tabs
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(
                horizontal: ForuiThemeConfig.spacingLarge),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category.id == _selectedCategory;
                final hasDone = completeness[category.scoreKey] == true;
                return _CategoryChip(
                  icon: category.icon,
                  label: category.title,
                  isSelected: isSelected,
                  hasDone: hasDone,
                  onTap: () =>
                      setState(() => _selectedCategory = category.id),
                );
              },
            ),
          ),
          const SizedBox(height: ForuiThemeConfig.spacingLarge),

          Divider(height: 1, color: Colors.grey.shade200),

          Padding(
            padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  final compact = constraints.maxWidth < 480;
                  final categoryScore =
                      subScores[selectedCategoryData.scoreKey];
                  final isDone =
                      completeness[selectedCategoryData.scoreKey] == true;

                  final iconBox = Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ForuiThemeConfig.surfaceGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(selectedCategoryData.icon,
                        color: ForuiThemeConfig.primaryGreen, size: 22),
                  );
                  final infoCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(selectedCategoryData.title,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: ForuiThemeConfig.textPrimary)),
                          if (isDone && categoryScore != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.green.shade200),
                              ),
                              child: Text(
                                '${(categoryScore * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(selectedCategoryData.description,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[600])),
                    ],
                  );
                  final openBtn = OutlinedButton.icon(
                    onPressed: () =>
                        context.push(selectedCategoryData.route),
                    icon: const Icon(Icons.open_in_new_rounded, size: 15),
                    label: Text(isDone ? 'Edit Data' : 'Isi Data'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ForuiThemeConfig.primaryGreen,
                      side: const BorderSide(
                          color: ForuiThemeConfig.primaryGreen),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          iconBox,
                          const SizedBox(width: 12),
                          Expanded(child: infoCol),
                        ]),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: openBtn),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      iconBox,
                      const SizedBox(width: 12),
                      Expanded(child: infoCol),
                      const SizedBox(width: 12),
                      openBtn,
                    ],
                  );
                }),
                const SizedBox(height: ForuiThemeConfig.spacingLarge),

                if (subScores.containsKey(selectedCategoryData.scoreKey))
                  _buildScoreBar(
                    score: subScores[selectedCategoryData.scoreKey]!,
                    label: selectedCategoryData.title,
                  )
                else
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(ForuiThemeConfig.spacingXLarge),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(
                          ForuiThemeConfig.borderRadiusMedium),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(selectedCategoryData.icon,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(
                            height: ForuiThemeConfig.spacingMedium),
                        Text(
                          'Data ${selectedCategoryData.title} belum diisi.\nKlik "Isi Data" untuk mulai mengisi.',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar({required double score, required String label}) {
    final pct = (score * 100).clamp(0.0, 100.0);
    final color = score >= 0.8
        ? const Color(0xFF00897B)
        : score >= 0.6
            ? const Color(0xFF43A047)
            : score >= 0.4
                ? const Color(0xFFFFA000)
                : Colors.red.shade400;

    return Container(
      padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius:
            BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Skor Sub-Dimensi $label',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ForuiThemeConfig.textPrimary)),
              ),
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _scoreLabel(score),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _scoreLabel(double score) {
    if (score >= 0.8) return 'Sangat Baik — pertahankan kondisi ini';
    if (score >= 0.6) return 'Baik — masih ada ruang untuk peningkatan';
    if (score >= 0.4) return 'Cukup — perlu perhatian lebih';
    if (score > 0) return 'Perlu Peningkatan Segera';
    return 'Belum ada data yang dimasukkan';
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _ScoreCardData {
  final String title;
  final double score;
  final Color color;
  final IconData icon;
  final bool isLoading;

  const _ScoreCardData({
    required this.title,
    required this.score,
    required this.color,
    required this.icon,
    required this.isLoading,
  });
}

class _ScoreCard extends StatelessWidget {
  final _ScoreCardData data;

  const _ScoreCard({required this.data});

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, color: data.color, size: 20),
              ),
              data.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: data.color))
                  : Text(
                      data.score.toStringAsFixed(3),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ForuiThemeConfig.textPrimary,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: ForuiThemeConfig.spacingMedium),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ForuiThemeConfig.textPrimary,
            ),
          ),
          const SizedBox(height: ForuiThemeConfig.spacingSmall),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.score,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(data.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool hasDone;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.hasDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ForuiThemeConfig.primaryGreen : Colors.white,
          borderRadius:
              BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
          border: Border.all(
            color: isSelected
                ? ForuiThemeConfig.primaryGreen
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
            if (hasDone && !isSelected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_circle,
                  size: 14, color: Colors.green.shade400),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final String scoreKey;

  const _CategoryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.scoreKey,
  });
}
