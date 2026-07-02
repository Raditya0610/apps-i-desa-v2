import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/form_options.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/sub_dimensions/kesehatan.dart';
import '../../../providers/kesehatan_provider.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/sub_dimension_dropdown.dart';
import '../../widgets/common/percentage_input.dart';

class KesehatanFormScreen extends ConsumerStatefulWidget {
  const KesehatanFormScreen({super.key});

  @override
  ConsumerState<KesehatanFormScreen> createState() => _KesehatanFormScreenState();
}

class _KesehatanFormScreenState extends ConsumerState<KesehatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _year = DateTime.now().year;

  // Dropdown state variables
  String? _kemudahanAksesSaranaKesehatan;
  String? _ketersediaanFasilitasKesehatan;
  String? _kemudahanAksesFasilitasKesehatan;
  String? _ketersediaanPosyandu;
  String? _kemudahanAksesPosyandu;
  String? _ketersediaanLayananDokter;
  String? _hariOperasionalLayananDokter;
  String? _penyediaTransportasiLayananDokter;
  String? _ketersediaanLayananBidan;
  String? _hariOperasionalLayananBidan;
  String? _penyediaTransportasiLayananBidan;
  String? _ketersediaanLayananTenagaKesehatan;
  String? _hariOperasionalLayananTenagaKesehatan;
  String? _penyediaTransportasiLayananTenagaKesehatan;
  String? _kegiatanSosialisasiJaminanKesehatan;

  // Controllers for text and percentage fields
  final _jumlahAktivitasPosyanduController = TextEditingController();
  final _penyediaLayananDokterController = TextEditingController();
  final _penyediaLayananBidanController = TextEditingController();
  final _penyediaLayananTenagaKesehatanController = TextEditingController();
  final _persentasePesertaJaminanKesehatanController = TextEditingController();

  bool _isLoading = false;
  String? _editingId;

  @override
  void dispose() {
    _jumlahAktivitasPosyanduController.dispose();
    _penyediaLayananDokterController.dispose();
    _penyediaLayananBidanController.dispose();
    _penyediaLayananTenagaKesehatanController.dispose();
    _persentasePesertaJaminanKesehatanController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final data = Kesehatan(
      villageId: '',
      year: _year,
      kemudahanAksesSaranaKesehatan: _kemudahanAksesSaranaKesehatan,
      ketersediaanFasilitasKesehatan: _ketersediaanFasilitasKesehatan,
      kemudahanAksesFasilitasKesehatan: _kemudahanAksesFasilitasKesehatan,
      ketersediaanPosyandu: _ketersediaanPosyandu,
      jumlahAktivitasPosyandu: _jumlahAktivitasPosyanduController.text,
      kemudahanAksesPosyandu: _kemudahanAksesPosyandu,
      ketersediaanLayananDokter: _ketersediaanLayananDokter,
      hariOperasionalLayananDokter: _hariOperasionalLayananDokter,
      penyediaLayananDokter: _penyediaLayananDokterController.text,
      penyediaTransportasiLayananDokter: _penyediaTransportasiLayananDokter,
      ketersediaanLayananBidan: _ketersediaanLayananBidan,
      hariOperasionalLayananBidan: _hariOperasionalLayananBidan,
      penyediaLayananBidan: _penyediaLayananBidanController.text,
      penyediaTransportasiLayananBidan: _penyediaTransportasiLayananBidan,
      ketersediaanLayananTenagaKesehatan: _ketersediaanLayananTenagaKesehatan,
      hariOperasionalLayananTenagaKesehatan: _hariOperasionalLayananTenagaKesehatan,
      penyediaLayananTenagaKesehatan: _penyediaLayananTenagaKesehatanController.text,
      penyediaTransportasiLayananTenagaKesehatan: _penyediaTransportasiLayananTenagaKesehatan,
      persentasePesertaJaminanKesehatan: _persentasePesertaJaminanKesehatanController.text,
      kegiatanSosialisasiJaminanKesehatan: _kegiatanSosialisasiJaminanKesehatan,
    );

    final Map<String, dynamic> result;
    if (_editingId != null) {
      result = await ref.read(kesehatanProvider.notifier).update(_editingId!, data);
    } else {
      result = await ref.read(kesehatanProvider.notifier).create(data);
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
          _buildTopHeader(context, 'Indikator Kesehatan', 'Input data indikator kesehatan desa'),
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
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                          ),
                          child: const Icon(Icons.local_hospital, size: 32, color: Colors.red),
                        ),
                        const SizedBox(width: ForuiThemeConfig.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Kesehatan',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Isi data indikator kesehatan desa',
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

                    // Sarana Kesehatan Section
                    _buildSectionHeader('Sarana Kesehatan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kemudahan Akses Sarana Kesehatan',
                      value: _kemudahanAksesSaranaKesehatan,
                      options: FormOptions.kemudahanAkses,
                      prefixIcon: Icons.accessibility,
                      onChanged: (value) => setState(() => _kemudahanAksesSaranaKesehatan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Fasilitas Kesehatan Section
                    _buildSectionHeader('Fasilitas Kesehatan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Fasilitas Kesehatan',
                      value: _ketersediaanFasilitasKesehatan,
                      options: FormOptions.ketersediaan,
                      prefixIcon: Icons.local_hospital_outlined,
                      onChanged: (value) => setState(() => _ketersediaanFasilitasKesehatan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kemudahan Akses Fasilitas Kesehatan',
                      value: _kemudahanAksesFasilitasKesehatan,
                      options: FormOptions.kemudahanAkses,
                      prefixIcon: Icons.directions_walk,
                      onChanged: (value) => setState(() => _kemudahanAksesFasilitasKesehatan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Posyandu Section
                    _buildSectionHeader('Posyandu'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Posyandu',
                      value: _ketersediaanPosyandu,
                      options: FormOptions.ketersediaan,
                      prefixIcon: Icons.health_and_safety,
                      onChanged: (value) => setState(() => _ketersediaanPosyandu = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    TextFormField(
                      controller: _jumlahAktivitasPosyanduController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Aktivitas Posyandu *',
                        hintText: 'Jumlah aktivitas per bulan',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.required(value, 'Jumlah Aktivitas Posyandu'),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kemudahan Akses Posyandu',
                      value: _kemudahanAksesPosyandu,
                      options: FormOptions.kemudahanAkses,
                      prefixIcon: Icons.directions_walk,
                      onChanged: (value) => setState(() => _kemudahanAksesPosyandu = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Layanan Dokter Section
                    _buildSectionHeader('Layanan Dokter'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Layanan Dokter',
                      value: _ketersediaanLayananDokter,
                      options: FormOptions.ketersediaan,
                      prefixIcon: Icons.person_outline,
                      onChanged: (value) => setState(() => _ketersediaanLayananDokter = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Hari Operasional Layanan Dokter',
                      value: _hariOperasionalLayananDokter,
                      options: FormOptions.hariOperasional,
                      prefixIcon: Icons.calendar_month,
                      onChanged: (value) => setState(() => _hariOperasionalLayananDokter = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    TextFormField(
                      controller: _penyediaLayananDokterController,
                      decoration: const InputDecoration(
                        labelText: 'Penyedia Layanan Dokter *',
                        hintText: 'Contoh: Puskesmas, Rumah Sakit',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) => Validators.required(value, 'Penyedia Layanan Dokter'),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Penyedia Transportasi Layanan Dokter',
                      value: _penyediaTransportasiLayananDokter,
                      options: FormOptions.ketersediaan,
                      prefixIcon: Icons.directions_car,
                      onChanged: (value) => setState(() => _penyediaTransportasiLayananDokter = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Layanan Bidan Section
                    _buildSectionHeader('Layanan Bidan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Layanan Bidan',
                      value: _ketersediaanLayananBidan,
                      options: FormOptions.ketersediaan,
                      prefixIcon: Icons.person_outline,
                      onChanged: (value) => setState(() => _ketersediaanLayananBidan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Hari Operasional Layanan Bidan',
                      value: _hariOperasionalLayananBidan,
                      options: FormOptions.hariOperasional,
                      prefixIcon: Icons.calendar_month,
                      onChanged: (value) => setState(() => _hariOperasionalLayananBidan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    TextFormField(
                      controller: _penyediaLayananBidanController,
                      decoration: const InputDecoration(
                        labelText: 'Penyedia Layanan Bidan *',
                        hintText: 'Contoh: Puskesmas, Klinik',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) => Validators.required(value, 'Penyedia Layanan Bidan'),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Penyedia Transportasi Layanan Bidan',
                      value: _penyediaTransportasiLayananBidan,
                      options: FormOptions.ketersediaan,
                      prefixIcon: Icons.directions_car,
                      onChanged: (value) => setState(() => _penyediaTransportasiLayananBidan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Layanan Tenaga Kesehatan Section
                    _buildSectionHeader('Layanan Tenaga Kesehatan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Ketersediaan Layanan Tenaga Kesehatan',
                      value: _ketersediaanLayananTenagaKesehatan,
                      options: FormOptions.ketersediaan,
                      prefixIcon: Icons.person_outline,
                      onChanged: (value) => setState(() => _ketersediaanLayananTenagaKesehatan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Hari Operasional Layanan Tenaga Kesehatan',
                      value: _hariOperasionalLayananTenagaKesehatan,
                      options: FormOptions.hariOperasional,
                      prefixIcon: Icons.calendar_month,
                      onChanged: (value) => setState(() => _hariOperasionalLayananTenagaKesehatan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    TextFormField(
                      controller: _penyediaLayananTenagaKesehatanController,
                      decoration: const InputDecoration(
                        labelText: 'Penyedia Layanan Tenaga Kesehatan *',
                        hintText: 'Contoh: Puskesmas, Klinik',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) => Validators.required(value, 'Penyedia Layanan Tenaga Kesehatan'),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Penyedia Transportasi Layanan Tenaga Kesehatan',
                      value: _penyediaTransportasiLayananTenagaKesehatan,
                      options: FormOptions.ketersediaan,
                      prefixIcon: Icons.directions_car,
                      onChanged: (value) => setState(() => _penyediaTransportasiLayananTenagaKesehatan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Jaminan Kesehatan Section
                    _buildSectionHeader('Jaminan Kesehatan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    PercentageInput(
                      label: 'Persentase Peserta Jaminan Kesehatan',
                      controller: _persentasePesertaJaminanKesehatanController,
                      hintText: 'Masukkan persentase (0-100)',
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Kegiatan Sosialisasi Jaminan Kesehatan',
                      value: _kegiatanSosialisasiJaminanKesehatan,
                      options: FormOptions.dilakukan,
                      prefixIcon: Icons.campaign,
                      onChanged: (value) => setState(() => _kegiatanSosialisasiJaminanKesehatan = value),
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
    _kemudahanAksesSaranaKesehatan = null;
    _ketersediaanFasilitasKesehatan = null;
    _kemudahanAksesFasilitasKesehatan = null;
    _ketersediaanPosyandu = null;
    _kemudahanAksesPosyandu = null;
    _ketersediaanLayananDokter = null;
    _hariOperasionalLayananDokter = null;
    _penyediaTransportasiLayananDokter = null;
    _ketersediaanLayananBidan = null;
    _hariOperasionalLayananBidan = null;
    _penyediaTransportasiLayananBidan = null;
    _ketersediaanLayananTenagaKesehatan = null;
    _hariOperasionalLayananTenagaKesehatan = null;
    _penyediaTransportasiLayananTenagaKesehatan = null;
    _kegiatanSosialisasiJaminanKesehatan = null;
    _jumlahAktivitasPosyanduController.clear();
    _penyediaLayananDokterController.clear();
    _penyediaLayananBidanController.clear();
    _penyediaLayananTenagaKesehatanController.clear();
    _persentasePesertaJaminanKesehatanController.clear();
  }

  void _prefillForm(Kesehatan record) {
    setState(() {
      _editingId = record.id;
      _year = record.year;
      _kemudahanAksesSaranaKesehatan = record.kemudahanAksesSaranaKesehatan;
      _ketersediaanFasilitasKesehatan = record.ketersediaanFasilitasKesehatan;
      _kemudahanAksesFasilitasKesehatan = record.kemudahanAksesFasilitasKesehatan;
      _ketersediaanPosyandu = record.ketersediaanPosyandu;
      _kemudahanAksesPosyandu = record.kemudahanAksesPosyandu;
      _ketersediaanLayananDokter = record.ketersediaanLayananDokter;
      _hariOperasionalLayananDokter = record.hariOperasionalLayananDokter;
      _penyediaTransportasiLayananDokter = record.penyediaTransportasiLayananDokter;
      _ketersediaanLayananBidan = record.ketersediaanLayananBidan;
      _hariOperasionalLayananBidan = record.hariOperasionalLayananBidan;
      _penyediaTransportasiLayananBidan = record.penyediaTransportasiLayananBidan;
      _ketersediaanLayananTenagaKesehatan = record.ketersediaanLayananTenagaKesehatan;
      _hariOperasionalLayananTenagaKesehatan = record.hariOperasionalLayananTenagaKesehatan;
      _penyediaTransportasiLayananTenagaKesehatan = record.penyediaTransportasiLayananTenagaKesehatan;
      _kegiatanSosialisasiJaminanKesehatan = record.kegiatanSosialisasiJaminanKesehatan;
      _jumlahAktivitasPosyanduController.text = record.jumlahAktivitasPosyandu;
      _penyediaLayananDokterController.text = record.penyediaLayananDokter;
      _penyediaLayananBidanController.text = record.penyediaLayananBidan;
      _penyediaLayananTenagaKesehatanController.text = record.penyediaLayananTenagaKesehatan;
      _persentasePesertaJaminanKesehatanController.text = record.persentasePesertaJaminanKesehatan;
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
    final provState = ref.watch(kesehatanProvider);
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

  Widget _buildRecordRow(Kesehatan record) {
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

  Future<void> _confirmDelete(Kesehatan record) async {
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
    final result = await ref.read(kesehatanProvider.notifier).delete(record.id!);
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
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
