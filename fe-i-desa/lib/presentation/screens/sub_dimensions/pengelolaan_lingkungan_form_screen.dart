import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/form_options.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../data/models/sub_dimensions/pengelolaan_lingkungan.dart';
import '../../../providers/pengelolaan_lingkungan_provider.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/sub_dimension_dropdown.dart';

class PengelolaanLingkunganFormScreen extends ConsumerStatefulWidget {
  const PengelolaanLingkunganFormScreen({super.key});

  @override
  ConsumerState<PengelolaanLingkunganFormScreen> createState() => _PengelolaanLingkunganFormScreenState();
}

class _PengelolaanLingkunganFormScreenState extends ConsumerState<PengelolaanLingkunganFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _year = DateTime.now().year;

  // Dropdown state variables
  String? _upayaMenjagaKelestarianLingkungan;
  String? _regulasiPelestarianLingkungan;
  String? _kegiatanPelestarianLingkungan;
  String? _pemanfaatanEnergiTerbarukan;
  String? _tempatPembuananganSampah;
  String? _pengelolaanSampah;
  String? _pemanfaatanSampah;
  String? _kejadianPencemaranLingkungan;
  String? _ketersediaanJamban;
  String? _keberfungsianJamban;
  String? _ketersediaanSepticTank;
  String? _pembuanganAirLimbahCairRumah;

  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final data = PengelolaanLingkungan(
      villageId: '',
      year: _year,
      upayaMenjagaKelestarianLingkungan: _upayaMenjagaKelestarianLingkungan ?? '',
      regulasiPelestarianLingkungan: _regulasiPelestarianLingkungan ?? '',
      kegiatanPelestarianLingkungan: _kegiatanPelestarianLingkungan ?? '',
      pemanfaatanEnergiTerbarukan: _pemanfaatanEnergiTerbarukan ?? '',
      tempatPembuananganSampah: _tempatPembuananganSampah ?? '',
      pengelolaanSampah: _pengelolaanSampah ?? '',
      pemanfaatanSampah: _pemanfaatanSampah ?? '',
      kejadianPencemaranLingkungan: _kejadianPencemaranLingkungan ?? '',
      ketersediaanJamban: _ketersediaanJamban ?? '',
      keberfungsianJamban: _keberfungsianJamban ?? '',
      ketersediaanSepticTank: _ketersediaanSepticTank ?? '',
      pembuanganAirLimbahCairRumah: _pembuanganAirLimbahCairRumah ?? '',
    );

    final result = await ref.read(pengelolaanLingkunganProvider).createPengelolaanLingkungan(data);

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: ForuiThemeConfig.successColor,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: ForuiThemeConfig.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Column(
        children: [
          _buildTopHeader(context, 'Indikator Pengelolaan Lingkungan', 'Input data pengelolaan lingkungan'),
          Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
          child: Card(
            elevation: ForuiThemeConfig.elevationMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(ForuiThemeConfig.spacingXLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(ForuiThemeConfig.spacingMedium),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                          ),
                          child: const Icon(Icons.eco, size: 32, color: Colors.teal),
                        ),
                        const SizedBox(width: ForuiThemeConfig.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Pengelolaan Lingkungan',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Isi data indikator pengelolaan lingkungan desa',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: ForuiThemeConfig.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Year Selector
                    DropdownButtonFormField<int>(
                      initialValue: _year,
                      decoration: const InputDecoration(
                        labelText: 'Tahun *',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: List.generate(
                        101,
                        (index) => DropdownMenuItem(
                          value: 2000 + index,
                          child: Text('${2000 + index}'),
                        ),
                      ),
                      onChanged: (value) => setState(() => _year = value!),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Pelestarian Lingkungan Section
                    _buildSectionHeader('Pelestarian Lingkungan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Upaya Menjaga Kelestarian Lingkungan',
                      value: _upayaMenjagaKelestarianLingkungan,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.eco,
                      onChanged: (value) => setState(() => _upayaMenjagaKelestarianLingkungan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Regulasi Pelestarian Lingkungan',
                      value: _regulasiPelestarianLingkungan,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.policy,
                      onChanged: (value) => setState(() => _regulasiPelestarianLingkungan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kegiatan Pelestarian Lingkungan',
                      value: _kegiatanPelestarianLingkungan,
                      options: FormOptions.frekuensiMusyawarah,
                      prefixIcon: Icons.work,
                      onChanged: (value) => setState(() => _kegiatanPelestarianLingkungan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Energi Terbarukan Section
                    _buildSectionHeader('Energi Terbarukan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Pemanfaatan Energi Terbarukan',
                      value: _pemanfaatanEnergiTerbarukan,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.solar_power,
                      onChanged: (value) => setState(() => _pemanfaatanEnergiTerbarukan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Pengelolaan Sampah Section
                    _buildSectionHeader('Pengelolaan Sampah'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Tempat Pembuangan Sampah',
                      value: _tempatPembuananganSampah,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.delete,
                      onChanged: (value) => setState(() => _tempatPembuananganSampah = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Pengelolaan Sampah',
                      value: _pengelolaanSampah,
                      options: FormOptions.kualitas,
                      prefixIcon: Icons.assignment,
                      onChanged: (value) => setState(() => _pengelolaanSampah = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Pemanfaatan Sampah',
                      value: _pemanfaatanSampah,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.recycling,
                      onChanged: (value) => setState(() => _pemanfaatanSampah = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Pencemaran Lingkungan Section
                    _buildSectionHeader('Pencemaran Lingkungan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kejadian Pencemaran Lingkungan',
                      value: _kejadianPencemaranLingkungan,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.warning,
                      onChanged: (value) => setState(() => _kejadianPencemaranLingkungan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Sanitasi Section
                    _buildSectionHeader('Sanitasi'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Jamban',
                      value: _ketersediaanJamban,
                      options: FormOptions.ketersediaan,
                      prefixIcon: Icons.wc,
                      onChanged: (value) => setState(() => _ketersediaanJamban = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Keberfungsian Jamban',
                      value: _keberfungsianJamban,
                      options: FormOptions.keberfungsian,
                      prefixIcon: Icons.verified,
                      onChanged: (value) => setState(() => _keberfungsianJamban = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Septic Tank',
                      value: _ketersediaanSepticTank,
                      options: FormOptions.ketersediaan,
                      prefixIcon: Icons.home,
                      onChanged: (value) => setState(() => _ketersediaanSepticTank = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Pembuangan Air Limbah Cair Rumah',
                      value: _pembuanganAirLimbahCairRumah,
                      options: FormOptions.kualitas,
                      prefixIcon: Icons.water,
                      onChanged: (value) => setState(() => _pembuanganAirLimbahCairRumah = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : () => context.pop(),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Batal'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: ForuiThemeConfig.spacingMedium + 4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: ForuiThemeConfig.spacingMedium),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleSubmit,
                            icon: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Data'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: ForuiThemeConfig.spacingMedium + 4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, String title, String subtitle) {
    final isDesktop = AppShell.isDesktop(context);
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
      child: Row(
        children: [
          if (!isDesktop)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
            color: const Color(0xFF1A2E1F),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2E1F))),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7C74))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ForuiThemeConfig.spacingMedium,
        vertical: ForuiThemeConfig.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.teal.shade700,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
