import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/form_options.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../data/models/sub_dimensions/aktivitas.dart';
import '../../../providers/aktivitas_provider.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/sub_dimension_dropdown.dart';

class AktivitasFormScreen extends ConsumerStatefulWidget {
  const AktivitasFormScreen({super.key});

  @override
  ConsumerState<AktivitasFormScreen> createState() => _AktivitasFormScreenState();
}

class _AktivitasFormScreenState extends ConsumerState<AktivitasFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _year = DateTime.now().year;

  // State variables for dropdown fields
  String? _kearifanBudayaSosial;
  String? _kearifanBudayaSosialDipertahankan;
  String? _kegiatanGotongRoyong;
  String? _frekuensiGotongRoyong;
  String? _keterlibatanWargaGotongRoyong;
  String? _frekuensiKegiatanOlahraga;
  String? _penyelesaianKonflikSecaraDamai;
  String? _peranAparatKeamananMediator;
  String? _peranAparatPemerintah;
  String? _peranTokohMasyarakat;
  String? _peranTokohAgama;
  String? _satuanKeamananLingkungan;
  String? _aktivitasSatuanKeamananLingkungan;

  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final data = Aktivitas(
      villageId: '',
      year: _year,
      kearibanBudayaSosial: _kearifanBudayaSosial ?? '',
      kearibanBudayaSosialDipertahankan: _kearifanBudayaSosialDipertahankan ?? '',
      kegiatanGotongRoyong: _kegiatanGotongRoyong ?? '',
      frekuensiGotongRoyong: _frekuensiGotongRoyong ?? '',
      keterlibatanWargaGotongRoyong: _keterlibatanWargaGotongRoyong ?? '',
      frekuensiKegiatanOlahraga: _frekuensiKegiatanOlahraga ?? '',
      penyelesaianKonflikSecaraDamai: _penyelesaianKonflikSecaraDamai ?? '',
      peranAparatKeamananMediator: _peranAparatKeamananMediator ?? '',
      peranAparatPemerintah: _peranAparatPemerintah ?? '',
      peranTokohMasyarakat: _peranTokohMasyarakat ?? '',
      peranTokohAgama: _peranTokohAgama ?? '',
      satuanKeamananLingkungan: _satuanKeamananLingkungan ?? '',
      aktivitasSatuanKeamananLingkungan: _aktivitasSatuanKeamananLingkungan ?? '',
    );

    final result = await ref.read(aktivitasProvider).createAktivitas(data);

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
          _buildTopHeader(context, 'Indikator Aktivitas Sosial', 'Input data aktivitas sosial budaya'),
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
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                          ),
                          child: const Icon(Icons.groups, size: 32, color: Colors.orange),
                        ),
                        const SizedBox(width: ForuiThemeConfig.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Aktivitas Sosial',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Isi data indikator aktivitas sosial desa',
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

                    // Budaya dan Kearifan Lokal Section
                    _buildSectionHeader('Budaya dan Kearifan Lokal'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kearifan Budaya Sosial',
                      value: _kearifanBudayaSosial,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.temple_buddhist,
                      onChanged: (value) => setState(() => _kearifanBudayaSosial = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kearifan Budaya Sosial Dipertahankan',
                      value: _kearifanBudayaSosialDipertahankan,
                      options: FormOptions.dipertahankan,
                      prefixIcon: Icons.history,
                      onChanged: (value) => setState(() => _kearifanBudayaSosialDipertahankan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Gotong Royong Section
                    _buildSectionHeader('Gotong Royong'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kegiatan Gotong Royong',
                      value: _kegiatanGotongRoyong,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.handshake,
                      onChanged: (value) => setState(() => _kegiatanGotongRoyong = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Frekuensi Gotong Royong',
                      value: _frekuensiGotongRoyong,
                      options: FormOptions.frekuensi,
                      prefixIcon: Icons.repeat,
                      onChanged: (value) => setState(() => _frekuensiGotongRoyong = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Keterlibatan Warga Gotong Royong',
                      value: _keterlibatanWargaGotongRoyong,
                      options: FormOptions.tingkat,
                      prefixIcon: Icons.people,
                      onChanged: (value) => setState(() => _keterlibatanWargaGotongRoyong = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Kegiatan Olahraga Section
                    _buildSectionHeader('Kegiatan Olahraga'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Frekuensi Kegiatan Olahraga',
                      value: _frekuensiKegiatanOlahraga,
                      options: FormOptions.frekuensi,
                      prefixIcon: Icons.sports_basketball,
                      onChanged: (value) => setState(() => _frekuensiKegiatanOlahraga = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Penyelesaian Konflik Section
                    _buildSectionHeader('Penyelesaian Konflik'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Penyelesaian Konflik Secara Damai',
                      value: _penyelesaianKonflikSecaraDamai,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.balance,
                      onChanged: (value) => setState(() => _penyelesaianKonflikSecaraDamai = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Peran Aparat Keamanan Mediator',
                      value: _peranAparatKeamananMediator,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.security,
                      onChanged: (value) => setState(() => _peranAparatKeamananMediator = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Peran Aparat Pemerintah',
                      value: _peranAparatPemerintah,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.business,
                      onChanged: (value) => setState(() => _peranAparatPemerintah = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Peran Tokoh Masyarakat',
                      value: _peranTokohMasyarakat,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.person,
                      onChanged: (value) => setState(() => _peranTokohMasyarakat = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Peran Tokoh Agama',
                      value: _peranTokohAgama,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.whatshot,
                      onChanged: (value) => setState(() => _peranTokohAgama = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Satuan Keamanan Lingkungan Section
                    _buildSectionHeader('Satuan Keamanan Lingkungan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Satuan Keamanan Lingkungan',
                      value: _satuanKeamananLingkungan,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.security,
                      onChanged: (value) => setState(() => _satuanKeamananLingkungan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Aktivitas Satuan Keamanan Lingkungan',
                      value: _aktivitasSatuanKeamananLingkungan,
                      options: FormOptions.status,
                      prefixIcon: Icons.verified,
                      onChanged: (value) => setState(() => _aktivitasSatuanKeamananLingkungan = value),
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
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
