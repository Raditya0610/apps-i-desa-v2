import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/app_shell.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final authState = ref.watch(authStateProvider);

    return AppShell(
      child: Column(
        children: [
          _TopBar(authState: authState),
          Expanded(
            child: _DashboardBody(dashboardState: dashboardState),
          ),
        ],
      ),
    );
  }
}

// ─── Top Bar ────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  final dynamic authState;
  const _TopBar({required this.authState});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 24),
        child: SizedBox(
          width: 280,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Color(0xFFD62828), size: 28),
                ),
                const SizedBox(height: 16),
                const Text('Keluar dari akun?',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2E1F))),
                const SizedBox(height: 8),
                const Text(
                  'Anda akan keluar dari sesi ini.\nPastikan semua data telah tersimpan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7C74)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7C74),
                          side: const BorderSide(color: Color(0xFFDDE4DE)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD62828),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Keluar',
                            style: TextStyle(fontWeight: FontWeight.w600)),
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
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = AppShell.isDesktop(context);
    final username = (authState.username as String?) ?? 'User';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 14),
      child: Row(
        children: [
          // Hamburger on mobile
          if (!isDesktop)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded,
                    color: ForuiThemeConfig.textPrimary),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),

          if (!isDesktop) const SizedBox(width: 4),

          // Search bar — desktop only
          if (isDesktop)
            Container(
              width: 260,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8EDE9)),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Cari data...',
                  hintStyle:
                      TextStyle(fontSize: 13, color: ForuiThemeConfig.textHint),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 17, color: ForuiThemeConfig.textHint),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),

          const Spacer(),

          // Notification bell
          _NotifButton(),

          const SizedBox(width: 8),

          // Divider
          if (isDesktop)
            Container(
                width: 1, height: 28, color: const Color(0xFFEEF0EE)),

          if (isDesktop) const SizedBox(width: 12),

          // Profile button + dropdown
          PopupMenuButton<String>(
            tooltip: '',
            offset: const Offset(0, 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 12,
            color: Colors.white,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            constraints: const BoxConstraints(minWidth: 220, maxWidth: 240),
            onSelected: (value) {
              if (value == 'logout') _confirmLogout(context, ref);
            },
            itemBuilder: (_) => [
              // ── Profile header ──
              PopupMenuItem(
                enabled: false,
                height: 80,
                padding: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ForuiThemeConfig.darkGreen,
                              ForuiThemeConfig.lightGreen,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: ForuiThemeConfig.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: ForuiThemeConfig.surfaceGreen,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Administrator',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ForuiThemeConfig.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(height: 1),
              // ── Logout ──
              PopupMenuItem(
                value: 'logout',
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: Color(0xFFD62828), size: 16),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Keluar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFD62828),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4EBE6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ForuiThemeConfig.darkGreen,
                          ForuiThemeConfig.lightGreen,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 8),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ForuiThemeConfig.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 16, color: ForuiThemeConfig.textSecondary),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: ForuiThemeConfig.textSecondary, size: 22),
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF4F7F5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const Positioned(
          right: 8,
          top: 8,
          child: _RedDot(),
        ),
      ],
    );
  }
}

class _RedDot extends StatelessWidget {
  const _RedDot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────────

class _DashboardBody extends ConsumerWidget {
  final dynamic dashboardState;
  const _DashboardBody({required this.dashboardState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (dashboardState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dashboardState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: ForuiThemeConfig.errorColor),
            const SizedBox(height: 16),
            Text(dashboardState.error!,
                style: const TextStyle(color: ForuiThemeConfig.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          final h = EdgeInsets.symmetric(
            horizontal: isWide ? 40 : 16,
            vertical: 28,
          );

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(isWide: isWide),
                const SizedBox(height: 24),
                if (dashboardState.dashboard != null)
                  _WelcomeCard(isWide: isWide),
                const SizedBox(height: 24),
                if (dashboardState.dashboard != null)
                  _StatisticsGrid(
                    dashboard: dashboardState.dashboard,
                    isWide: isWide,
                  ),
                const SizedBox(height: 24),
                if (dashboardState.dashboard != null)
                  _MainContentLayout(
                    dashboard: dashboardState.dashboard!,
                    isWide: isWide,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Page Header ─────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final bool isWide;
  const _PageHeader({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Demografi',
          style: TextStyle(
            fontSize: isWide ? 26 : 20,
            fontWeight: FontWeight.bold,
            color: ForuiThemeConfig.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Data Kependudukan Desa',
          style: TextStyle(fontSize: 14, color: ForuiThemeConfig.textSecondary),
        ),
      ],
    );
  }
}

// ─── Welcome Card ─────────────────────────────────────────────────────────────

class _WelcomeCard extends StatelessWidget {
  final bool isWide;
  const _WelcomeCard({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.file_download_outlined, size: 16),
        label: const Text('Export'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: BorderSide(color: Colors.grey.shade300),
          foregroundColor: ForuiThemeConfig.textPrimary,
        ),
      ),
      const SizedBox(width: 10, height: 10),
      FilledButton.icon(
        onPressed: () => context.push('/family-cards/add'),
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Tambah Penduduk'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: ForuiThemeConfig.primaryGreen,
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                const Expanded(child: _WelcomeText()),
                const SizedBox(width: 20),
                Row(children: buttons),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _WelcomeText(),
                const SizedBox(height: 16),
                Wrap(spacing: 10, runSpacing: 10, children: buttons),
              ],
            ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  const _WelcomeText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Halo, Admin! ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ForuiThemeConfig.textPrimary,
              ),
            ),
            Text('👋', style: TextStyle(fontSize: 20)),
          ],
        ),
        SizedBox(height: 6),
        Text(
          'Berikut laporan terkini kondisi demografi desa.',
          style: TextStyle(fontSize: 14, color: ForuiThemeConfig.textSecondary, height: 1.5),
        ),
      ],
    );
  }
}

// ─── Statistics Grid ──────────────────────────────────────────────────────────

class _StatisticsGrid extends StatelessWidget {
  final dynamic dashboard;
  final bool isWide;
  const _StatisticsGrid({required this.dashboard, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        title: 'Total Penduduk',
        value: dashboard.totalPenduduk.toString(),
        icon: Icons.group_outlined,
        iconColor: const Color(0xFF10B981),
        iconBg: const Color(0xFFD1FAE5),
        subtitle: '+2.4% bln ini',
        subtitleColor: const Color(0xFF10B981),
      ),
      _StatCard(
        title: 'Total Keluarga',
        value: dashboard.totalKeluarga.toString(),
        icon: Icons.home_outlined,
        iconColor: const Color(0xFF3B82F6),
        iconBg: const Color(0xFFDBEAFE),
        subtitle: 'KK: ${dashboard.kepalaKeluarga}',
      ),
      _StatCard(
        title: 'Rerata Umur',
        value: dashboard.rerataUmur.toStringAsFixed(1),
        icon: Icons.cake_outlined,
        iconColor: const Color(0xFFF59E0B),
        iconBg: const Color(0xFFFEF3C7),
        subtitle: 'Tahun',
      ),
      _StatCard(
        title: 'Rasio Keluarga',
        value: dashboard.rasioKeluarga.toStringAsFixed(3),
        icon: Icons.show_chart,
        iconColor: const Color(0xFF8B5CF6),
        iconBg: const Color(0xFFEDE9FE),
        subtitle: 'Index Kepadatan',
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .expand((c) => [Expanded(child: c), const SizedBox(width: 16)])
            .toList()
          ..removeLast(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? subtitle;
  final Color? subtitleColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.subtitle,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: ForuiThemeConfig.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ForuiThemeConfig.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: subtitleColor ?? ForuiThemeConfig.textSecondary,
                fontWeight: subtitleColor != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Main Content (chart + insight) ──────────────────────────────────────────

class _MainContentLayout extends StatelessWidget {
  final dynamic dashboard;
  final bool isWide;
  const _MainContentLayout({required this.dashboard, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final left = Column(
      children: [
        _GenderChart(dashboard: dashboard),
        const SizedBox(height: 20),
        _AdminStats(dashboard: dashboard),
      ],
    );

    final right = Column(
      children: [
        _InsightCard(dashboard: dashboard),
        const SizedBox(height: 20),
        const _RecentActivity(),
      ],
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: left),
          const SizedBox(width: 24),
          Expanded(flex: 3, child: right),
        ],
      );
    }

    return Column(
      children: [left, const SizedBox(height: 20), right],
    );
  }
}

// ─── Gender Chart ─────────────────────────────────────────────────────────────

class _GenderChart extends StatelessWidget {
  final dynamic dashboard;
  const _GenderChart({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Komposisi Gender',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ForuiThemeConfig.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Perbandingan Laki-laki dan Perempuan',
            style: TextStyle(fontSize: 13, color: ForuiThemeConfig.textSecondary),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final chartSize = constraints.maxWidth < 400 ? 160.0 : 200.0;
              return Row(
                children: [
                  // Donut chart with RepaintBoundary for performance
                  RepaintBoundary(
                    child: SizedBox(
                      width: chartSize,
                      height: chartSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: dashboard.lakiLaki.toDouble(),
                                  color: const Color(0xFF3B82F6),
                                  radius: 50,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  value: dashboard.perempuan.toDouble(),
                                  color: const Color(0xFFEC4899),
                                  radius: 50,
                                  showTitle: false,
                                ),
                              ],
                              centerSpaceRadius: 60,
                              sectionsSpace: 3,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ForuiThemeConfig.textSecondary,
                                ),
                              ),
                              Text(
                                dashboard.totalPenduduk.toString(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: ForuiThemeConfig.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _GenderLegend(
                          label: 'Laki-Laki',
                          value: dashboard.lakiLaki,
                          color: const Color(0xFF3B82F6),
                          ratio: dashboard.genderRatioMale / 100,
                        ),
                        const SizedBox(height: 28),
                        _GenderLegend(
                          label: 'Perempuan',
                          value: dashboard.perempuan,
                          color: const Color(0xFFEC4899),
                          ratio: dashboard.genderRatioFemale / 100,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GenderLegend extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final double ratio;

  const _GenderLegend({
    required this.label,
    required this.value,
    required this.color,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ForuiThemeConfig.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ForuiThemeConfig.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 7,
          ),
        ),
      ],
    );
  }
}

// ─── Administrative Stats ─────────────────────────────────────────────────────

class _AdminStats extends StatelessWidget {
  final dynamic dashboard;
  const _AdminStats({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('KECAMATAN', dashboard.kecamatan.toString()),
      ('KELURAHAN', dashboard.kelurahan.toString()),
      ('TOTAL RW', dashboard.rw.toString()),
      ('TOTAL RT', dashboard.rt.toString()),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Row(
        children: items
            .expand((item) => [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          item.$1,
                          style: TextStyle(
                            fontSize: 10,
                            color: ForuiThemeConfig.textSecondary.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: ForuiThemeConfig.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item != items.last)
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                ])
            .toList(),
      ),
    );
  }
}

// ─── Insight Card ─────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final dynamic dashboard;
  const _InsightCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final kkProgress = (dashboard.kepalaKeluarga / dashboard.totalKeluarga).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Insight Cepat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InsightProgress(
            label: 'Kepala Keluarga',
            detail: '${dashboard.kepalaKeluarga} / ${dashboard.totalKeluarga}',
            value: kkProgress,
            barColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 20),
          const _InsightProgress(
            label: 'Target Pendataan',
            detail: '85%',
            value: 0.85,
            barColor: Colors.white,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/sub-dimensions'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Lihat Analisis Lengkap',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightProgress extends StatelessWidget {
  final String label;
  final String detail;
  final double value;
  final Color barColor;

  const _InsightProgress({
    required this.label,
    required this.detail,
    required this.value,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            Text(
              detail,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 7,
          ),
        ),
      ],
    );
  }
}

// ─── Recent Activity ──────────────────────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ForuiThemeConfig.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 12,
                    color: ForuiThemeConfig.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _ActivityItem(
            title: 'Penduduk Baru',
            subtitle: 'Keluarga Bpk. Hartono ditambahkan.',
            time: '2 jam lalu',
            color: Color(0xFF10B981),
          ),
          const _ActivityDivider(),
          const _ActivityItem(
            title: 'Update Kartu Keluarga',
            subtitle: 'Perubahan data No. KK 09123...',
            time: '5 jam lalu',
            color: Color(0xFF3B82F6),
          ),
          const _ActivityDivider(),
          const _ActivityItem(
            title: 'Sistem Backup',
            subtitle: 'Pencadangan data otomatis berhasil.',
            time: '1 hari lalu',
            color: Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }
}

class _ActivityDivider extends StatelessWidget {
  const _ActivityDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Container(
        height: 20,
        width: 1,
        color: Colors.grey.shade200,
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ForuiThemeConfig.textPrimary,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: ForuiThemeConfig.textHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: ForuiThemeConfig.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared card decoration ───────────────────────────────────────────────────

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
