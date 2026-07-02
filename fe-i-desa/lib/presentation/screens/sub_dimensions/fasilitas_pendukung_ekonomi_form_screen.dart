import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/form_options.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../data/models/sub_dimensions/fasilitas_pendukung_ekonomi.dart';
import '../../../providers/fasilitas_pendukung_ekonomi_provider.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/sub_dimension_dropdown.dart';

class FasilitasPendukungEkonomiFormScreen extends ConsumerStatefulWidget {
  const FasilitasPendukungEkonomiFormScreen({super.key});

  @override
  ConsumerState<FasilitasPendukungEkonomiFormScreen> createState() => _FasilitasPendukungEkonomiFormScreenState();
}

class _FasilitasPendukungEkonomiFormScreenState extends ConsumerState<FasilitasPendukungEkonomiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _year = DateTime.now().year;

  // Dropdown state variables
  String? _ketersediaanPendidikanNonFormal;
  String? _keterlibatanPendidikanNonFormal;
  String? _ketersediaanPasarRakyat;
  String? _kemudahanAksesPasarRakyat;
  String? _ketersediaanToko;
  String? _kemudahanAksesToko;
  String? _ketersediaanRumahMakan;
  String? _kemudahanAksesRumahMakan;
  String? _ketersediaanPenginapan;
  String? _kemudahanAksesPenginapan;
  String? _ketersediaanLogistik;
  String? _kemudahanAksesLogistik;
  String? _terdapatBumd;
  String? _bumdBerbadanHukum;
  String? _hariOperasionalLembagaEkonomi;
  String? _ketersediaanLembagaEkonomiLainnya;
  String? _ketersediaanKud;
  String? _ketersediaanUmkm;
  String? _layananPerbankan;
  String? _hariOperasionalKeuangan;
  String? _layananFasilitasKreditKur;
  String? _layananFasilitasKreditKkpE;
  String? _layananFasilitasKreditKuk;
  String? _statusLayananFasilitasKredit;

  bool _isLoading = false;
  String? _editingId;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final data = FasilitasPendukungEkonomi(
      villageId: '',
      year: _year,
      ketersediaanPendidikanNonFormal: _ketersediaanPendidikanNonFormal,
      keterlibatanPendidikanNonFormal: _keterlibatanPendidikanNonFormal,
      ketersediaanPasarRakyat: _ketersediaanPasarRakyat,
      kemudahanAksesPasarRakyat: _kemudahanAksesPasarRakyat,
      ketersediaanToko: _ketersediaanToko,
      kemudahanAksesToko: _kemudahanAksesToko,
      ketersediaanRumahMakan: _ketersediaanRumahMakan,
      kemudahanAksesRumahMakan: _kemudahanAksesRumahMakan,
      ketersediaanPenginapan: _ketersediaanPenginapan,
      kemudahanAksesPenginapan: _kemudahanAksesPenginapan,
      ketersediaanLogistik: _ketersediaanLogistik,
      kemudahanAksesLogistik: _kemudahanAksesLogistik,
      terdapatBumd: _terdapatBumd,
      bumdBerbadanHukum: _bumdBerbadanHukum,
      hariOperasionalLembagaEkonomi: _hariOperasionalLembagaEkonomi,
      ketersediaanLembagaEkonomiLainnya: _ketersediaanLembagaEkonomiLainnya,
      ketersediaanKud: _ketersediaanKud,
      ketersediaanUmkm: _ketersediaanUmkm,
      layananPerbankan: _layananPerbankan,
      hariOperasionalKeuangan: _hariOperasionalKeuangan,
      layananFasilitasKreditKur: _layananFasilitasKreditKur,
      layananFasilitasKreditKkpE: _layananFasilitasKreditKkpE,
      layananFasilitasKreditKuk: _layananFasilitasKreditKuk,
      statusLayananFasilitasKredit: _statusLayananFasilitasKredit,
    );

    final Map<String, dynamic> result;
    if (_editingId != null) {
      result = await ref.read(fasilitasPendukungEkonomiProvider.notifier).update(_editingId!, data);
    } else {
      result = await ref.read(fasilitasPendukungEkonomiProvider.notifier).create(data);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: ForuiThemeConfig.successColor,
          ),
        );
        if (_editingId != null) {
          _clearForm();
        } else {
          context.pop();
        }
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
          _buildTopHeader(context, 'Indikator Fasilitas Pendukung Ekonomi', 'Input data fasilitas pendukung ekonomi'),
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
                    _buildRecordsSectionHeader(),
                    const SizedBox(height: 12),
                    _buildRecordsList(),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),
                    const Divider(height: 1, color: Color(0xFFE8EDE9)),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(ForuiThemeConfig.spacingMedium),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                          ),
                          child: const Icon(Icons.storefront, size: 32, color: Colors.amber),
                        ),
                        const SizedBox(width: ForuiThemeConfig.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Fasilitas Pendukung Ekonomi',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Isi data indikator fasilitas pendukung ekonomi desa',
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

                    // Pendidikan Non Formal Section
                    _buildSectionHeader('Pendidikan Non Formal'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Pendidikan Non Formal',
                      value: _ketersediaanPendidikanNonFormal,
                      options: FormOptions.ketersediaan,
                      prefixIcon: Icons.school,
                      onChanged: (value) => setState(() => _ketersediaanPendidikanNonFormal = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Keterlibatan Pendidikan Non Formal',
                      value: _keterlibatanPendidikanNonFormal,
                      options: FormOptions.tingkat,
                      prefixIcon: Icons.people,
                      onChanged: (value) => setState(() => _keterlibatanPendidikanNonFormal = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Pasar Rakyat Section
                    _buildSectionHeader('Pasar Rakyat'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Pasar Rakyat',
                      value: _ketersediaanPasarRakyat,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.shopping_cart,
                      onChanged: (value) => setState(() => _ketersediaanPasarRakyat = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kemudahan Akses Pasar Rakyat',
                      value: _kemudahanAksesPasarRakyat,
                      options: FormOptions.kemudahanAkses,
                      prefixIcon: Icons.accessibility,
                      onChanged: (value) => setState(() => _kemudahanAksesPasarRakyat = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Toko Section
                    _buildSectionHeader('Toko'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Toko',
                      value: _ketersediaanToko,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.storefront,
                      onChanged: (value) => setState(() => _ketersediaanToko = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kemudahan Akses Toko',
                      value: _kemudahanAksesToko,
                      options: FormOptions.kemudahanAkses,
                      prefixIcon: Icons.accessibility,
                      onChanged: (value) => setState(() => _kemudahanAksesToko = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Rumah Makan Section
                    _buildSectionHeader('Rumah Makan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Rumah Makan',
                      value: _ketersediaanRumahMakan,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.restaurant,
                      onChanged: (value) => setState(() => _ketersediaanRumahMakan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kemudahan Akses Rumah Makan',
                      value: _kemudahanAksesRumahMakan,
                      options: FormOptions.kemudahanAkses,
                      prefixIcon: Icons.accessibility,
                      onChanged: (value) => setState(() => _kemudahanAksesRumahMakan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Penginapan Section
                    _buildSectionHeader('Penginapan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Penginapan',
                      value: _ketersediaanPenginapan,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.hotel,
                      onChanged: (value) => setState(() => _ketersediaanPenginapan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kemudahan Akses Penginapan',
                      value: _kemudahanAksesPenginapan,
                      options: FormOptions.kemudahanAkses,
                      prefixIcon: Icons.accessibility,
                      onChanged: (value) => setState(() => _kemudahanAksesPenginapan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Logistik Section
                    _buildSectionHeader('Logistik'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Logistik',
                      value: _ketersediaanLogistik,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.local_shipping,
                      onChanged: (value) => setState(() => _ketersediaanLogistik = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kemudahan Akses Logistik',
                      value: _kemudahanAksesLogistik,
                      options: FormOptions.kemudahanAkses,
                      prefixIcon: Icons.accessibility,
                      onChanged: (value) => setState(() => _kemudahanAksesLogistik = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // BUMD Section
                    _buildSectionHeader('BUMD'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Terdapat BUMD',
                      value: _terdapatBumd,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.business,
                      onChanged: (value) => setState(() => _terdapatBumd = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'BUMD Berbadan Hukum',
                      value: _bumdBerbadanHukum,
                      options: FormOptions.yaTidak,
                      prefixIcon: Icons.verified,
                      onChanged: (value) => setState(() => _bumdBerbadanHukum = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Lembaga Ekonomi Section
                    _buildSectionHeader('Lembaga Ekonomi'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Hari Operasional Lembaga Ekonomi',
                      value: _hariOperasionalLembagaEkonomi,
                      options: FormOptions.hariOperasional,
                      prefixIcon: Icons.calendar_month,
                      onChanged: (value) => setState(() => _hariOperasionalLembagaEkonomi = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Lembaga Ekonomi Lainnya',
                      value: _ketersediaanLembagaEkonomiLainnya,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.business,
                      onChanged: (value) => setState(() => _ketersediaanLembagaEkonomiLainnya = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan KUD',
                      value: _ketersediaanKud,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.agriculture,
                      onChanged: (value) => setState(() => _ketersediaanKud = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan UMKM',
                      value: _ketersediaanUmkm,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.work,
                      onChanged: (value) => setState(() => _ketersediaanUmkm = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Layanan Keuangan Section
                    _buildSectionHeader('Layanan Keuangan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Layanan Perbankan',
                      value: _layananPerbankan,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.account_balance,
                      onChanged: (value) => setState(() => _layananPerbankan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Hari Operasional Keuangan',
                      value: _hariOperasionalKeuangan,
                      options: FormOptions.hariOperasional,
                      prefixIcon: Icons.calendar_month,
                      onChanged: (value) => setState(() => _hariOperasionalKeuangan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Layanan Fasilitas Kredit KUR',
                      value: _layananFasilitasKreditKur,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.money,
                      onChanged: (value) => setState(() => _layananFasilitasKreditKur = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Layanan Fasilitas Kredit KKP-E',
                      value: _layananFasilitasKreditKkpE,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.money,
                      onChanged: (value) => setState(() => _layananFasilitasKreditKkpE = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Layanan Fasilitas Kredit KUK',
                      value: _layananFasilitasKreditKuk,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.money,
                      onChanged: (value) => setState(() => _layananFasilitasKreditKuk = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Status Layanan Fasilitas Kredit',
                      value: _statusLayananFasilitasKredit,
                      options: FormOptions.status,
                      prefixIcon: Icons.verified,
                      onChanged: (value) => setState(() => _statusLayananFasilitasKredit = value),
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
                            label: Text(_isLoading ? 'Menyimpan...' : (_editingId != null ? 'Perbarui Data' : 'Simpan Data')),
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


  void _resetFields() {
    _ketersediaanPendidikanNonFormal = null;
    _keterlibatanPendidikanNonFormal = null;
    _ketersediaanPasarRakyat = null;
    _kemudahanAksesPasarRakyat = null;
    _ketersediaanToko = null;
    _kemudahanAksesToko = null;
    _ketersediaanRumahMakan = null;
    _kemudahanAksesRumahMakan = null;
    _ketersediaanPenginapan = null;
    _kemudahanAksesPenginapan = null;
    _ketersediaanLogistik = null;
    _kemudahanAksesLogistik = null;
    _terdapatBumd = null;
    _bumdBerbadanHukum = null;
    _hariOperasionalLembagaEkonomi = null;
    _ketersediaanLembagaEkonomiLainnya = null;
    _ketersediaanKud = null;
    _ketersediaanUmkm = null;
    _layananPerbankan = null;
    _hariOperasionalKeuangan = null;
    _layananFasilitasKreditKur = null;
    _layananFasilitasKreditKkpE = null;
    _layananFasilitasKreditKuk = null;
    _statusLayananFasilitasKredit = null;
  }

  void _prefillForm(FasilitasPendukungEkonomi record) {
    setState(() {
      _editingId = record.id;
      _year = record.year;
      _ketersediaanPendidikanNonFormal = record.ketersediaanPendidikanNonFormal;
      _keterlibatanPendidikanNonFormal = record.keterlibatanPendidikanNonFormal;
      _ketersediaanPasarRakyat = record.ketersediaanPasarRakyat;
      _kemudahanAksesPasarRakyat = record.kemudahanAksesPasarRakyat;
      _ketersediaanToko = record.ketersediaanToko;
      _kemudahanAksesToko = record.kemudahanAksesToko;
      _ketersediaanRumahMakan = record.ketersediaanRumahMakan;
      _kemudahanAksesRumahMakan = record.kemudahanAksesRumahMakan;
      _ketersediaanPenginapan = record.ketersediaanPenginapan;
      _kemudahanAksesPenginapan = record.kemudahanAksesPenginapan;
      _ketersediaanLogistik = record.ketersediaanLogistik;
      _kemudahanAksesLogistik = record.kemudahanAksesLogistik;
      _terdapatBumd = record.terdapatBumd;
      _bumdBerbadanHukum = record.bumdBerbadanHukum;
      _hariOperasionalLembagaEkonomi = record.hariOperasionalLembagaEkonomi;
      _ketersediaanLembagaEkonomiLainnya = record.ketersediaanLembagaEkonomiLainnya;
      _ketersediaanKud = record.ketersediaanKud;
      _ketersediaanUmkm = record.ketersediaanUmkm;
      _layananPerbankan = record.layananPerbankan;
      _hariOperasionalKeuangan = record.hariOperasionalKeuangan;
      _layananFasilitasKreditKur = record.layananFasilitasKreditKur;
      _layananFasilitasKreditKkpE = record.layananFasilitasKreditKkpE;
      _layananFasilitasKreditKuk = record.layananFasilitasKreditKuk;
      _statusLayananFasilitasKredit = record.statusLayananFasilitasKredit;
    });
  }
  void _clearForm() {
    setState(() {
      _editingId = null;
      _year = DateTime.now().year;
      _resetFields();
    });
  }

  Widget _buildRecordsSectionHeader() {
    return Row(
      children: [
        const Text('Data Tersimpan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ForuiThemeConfig.textPrimary)),
        const Spacer(),
        if (_editingId != null)
          TextButton.icon(
            onPressed: _clearForm,
            icon: const Icon(Icons.add_circle_outline, size: 16),
            label: const Text('Batal Edit'),
            style: TextButton.styleFrom(foregroundColor: ForuiThemeConfig.textSecondary),
          ),
      ],
    );
  }

  Widget _buildRecordsList() {
    final provState = ref.watch(fasilitasPendukungEkonomiProvider);
    if (provState.isLoading) return const Center(child: CircularProgressIndicator());
    if (provState.records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
        child: const Center(child: Text('Belum ada data tersimpan', style: TextStyle(color: ForuiThemeConfig.textSecondary))),
      );
    }
    return Column(children: provState.records.map((r) => _buildRecordRow(r)).toList());
  }

  Widget _buildRecordRow(FasilitasPendukungEkonomi record) {
    final isEditing = _editingId == record.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isEditing ? ForuiThemeConfig.surfaceGreen : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isEditing ? ForuiThemeConfig.primaryGreen : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: ForuiThemeConfig.surfaceGreen, borderRadius: BorderRadius.circular(20)),
            child: Text(record.year.toString(), style: const TextStyle(fontWeight: FontWeight.w600, color: ForuiThemeConfig.primaryGreen, fontSize: 13)),
          ),
          const Spacer(),
          if (isEditing)
            TextButton.icon(
              onPressed: _clearForm,
              icon: const Icon(Icons.close, size: 14),
              label: const Text('Batal'),
              style: TextButton.styleFrom(foregroundColor: ForuiThemeConfig.textSecondary, padding: EdgeInsets.zero),
            )
          else ...[
            IconButton(icon: const Icon(Icons.edit_outlined, size: 17), color: ForuiThemeConfig.primaryGreen, onPressed: () => _prefillForm(record), tooltip: 'Edit', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            const SizedBox(width: 12),
            IconButton(icon: const Icon(Icons.delete_outline, size: 17), color: ForuiThemeConfig.errorColor, onPressed: () => _confirmDelete(record), tooltip: 'Hapus', padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(FasilitasPendukungEkonomi record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Data'),
        content: Text('Yakin ingin menghapus data tahun ${record.year}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: ForuiThemeConfig.errorColor, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await ref.read(fasilitasPendukungEkonomiProvider.notifier).delete(record.id!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] == true ? ForuiThemeConfig.successColor : ForuiThemeConfig.errorColor,
      ));
    }
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
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.amber.shade700,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
