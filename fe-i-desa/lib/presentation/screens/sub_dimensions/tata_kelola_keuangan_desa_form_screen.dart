import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/form_options.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../data/models/sub_dimensions/tata_kelola_keuangan_desa.dart';
import '../../../providers/tata_kelola_keuangan_desa_provider.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/sub_dimension_dropdown.dart';

class TataKelolaKeuanganDesaFormScreen extends ConsumerStatefulWidget {
  const TataKelolaKeuanganDesaFormScreen({super.key});

  @override
  ConsumerState<TataKelolaKeuanganDesaFormScreen> createState() => _TataKelolaKeuanganDesaFormScreenState();
}

class _TataKelolaKeuanganDesaFormScreenState extends ConsumerState<TataKelolaKeuanganDesaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _year = DateTime.now().year;

  // Dropdown state variables
  String? _pendapatanAsliDesa;
  String? _peningkatanPades;
  String? _penyertaanModalDdBumd;
  String? _asetTanahDesa;
  String? _asetKantorDesa;
  String? _asetPasarDesa;
  String? _asetLainnya;
  String? _produktivitasAsetDesa;
  String? _inventarisasiAsetDesa;

  bool _isLoading = false;
  String? _editingId;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final data = TataKelolaKeuanganDesa(
      villageId: '',
      year: _year,
      pendapatanAsliDesa: _pendapatanAsliDesa,
      peningkatanPades: _peningkatanPades,
      penyertaanModalDdBumd: _penyertaanModalDdBumd,
      asetTanahDesa: _asetTanahDesa,
      asetKantorDesa: _asetKantorDesa,
      asetPasarDesa: _asetPasarDesa,
      asetLainnya: _asetLainnya,
      produktivitasAsetDesa: _produktivitasAsetDesa,
      inventarisasiAsetDesa: _inventarisasiAsetDesa,
    );

    final Map<String, dynamic> result;
    if (_editingId != null) {
      result = await ref.read(tataKelolaKeuanganDesaProvider.notifier).update(_editingId!, data);
    } else {
      result = await ref.read(tataKelolaKeuanganDesaProvider.notifier).create(data);
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
          _buildTopHeader(context, 'Indikator Tata Kelola Keuangan', 'Input data tata kelola keuangan desa'),
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
                            color: Colors.pink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                          ),
                          child: const Icon(Icons.account_balance, size: 32, color: Colors.pink),
                        ),
                        const SizedBox(width: ForuiThemeConfig.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Tata Kelola Keuangan',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Isi data indikator tata kelola keuangan desa',
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

                    // Pendapatan Desa Section
                    _buildSectionHeader('Pendapatan Desa'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Pendapatan Asli Desa',
                      value: _pendapatanAsliDesa,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.money,
                      onChanged: (value) => setState(() => _pendapatanAsliDesa = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Peningkatan PADES',
                      value: _peningkatanPades,
                      options: FormOptions.peningkatan,
                      prefixIcon: Icons.trending_up,
                      onChanged: (value) => setState(() => _peningkatanPades = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Penyertaan Modal DD BUMD',
                      value: _penyertaanModalDdBumd,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.business,
                      onChanged: (value) => setState(() => _penyertaanModalDdBumd = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Aset Desa Section
                    _buildSectionHeader('Aset Desa'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Aset Tanah Desa',
                      value: _asetTanahDesa,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.landscape,
                      onChanged: (value) => setState(() => _asetTanahDesa = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Aset Kantor Desa',
                      value: _asetKantorDesa,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.apartment,
                      onChanged: (value) => setState(() => _asetKantorDesa = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Aset Pasar Desa',
                      value: _asetPasarDesa,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.shopping_cart,
                      onChanged: (value) => setState(() => _asetPasarDesa = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Aset Lainnya',
                      value: _asetLainnya,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.layers,
                      onChanged: (value) => setState(() => _asetLainnya = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Pengelolaan Aset Section
                    _buildSectionHeader('Pengelolaan Aset'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Produktivitas Aset Desa',
                      value: _produktivitasAsetDesa,
                      options: FormOptions.tingkat,
                      prefixIcon: Icons.assessment,
                      onChanged: (value) => setState(() => _produktivitasAsetDesa = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Inventarisasi Aset Desa',
                      value: _inventarisasiAsetDesa,
                      options: FormOptions.kelengkapan,
                      prefixIcon: Icons.assignment,
                      onChanged: (value) => setState(() => _inventarisasiAsetDesa = value),
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
    _pendapatanAsliDesa = null;
    _peningkatanPades = null;
    _penyertaanModalDdBumd = null;
    _asetTanahDesa = null;
    _asetKantorDesa = null;
    _asetPasarDesa = null;
    _asetLainnya = null;
    _produktivitasAsetDesa = null;
    _inventarisasiAsetDesa = null;
  }

  void _prefillForm(TataKelolaKeuanganDesa record) {
    setState(() {
      _editingId = record.id;
      _year = record.year;
      _pendapatanAsliDesa = record.pendapatanAsliDesa;
      _peningkatanPades = record.peningkatanPades;
      _penyertaanModalDdBumd = record.penyertaanModalDdBumd;
      _asetTanahDesa = record.asetTanahDesa;
      _asetKantorDesa = record.asetKantorDesa;
      _asetPasarDesa = record.asetPasarDesa;
      _asetLainnya = record.asetLainnya;
      _produktivitasAsetDesa = record.produktivitasAsetDesa;
      _inventarisasiAsetDesa = record.inventarisasiAsetDesa;
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
    final provState = ref.watch(tataKelolaKeuanganDesaProvider);
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

  Widget _buildRecordRow(TataKelolaKeuanganDesa record) {
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

  Future<void> _confirmDelete(TataKelolaKeuanganDesa record) async {
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
    final result = await ref.read(tataKelolaKeuanganDesaProvider.notifier).delete(record.id!);
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
        color: Colors.pink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
        border: Border.all(color: Colors.pink.withValues(alpha: 0.3)),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.pink.shade700,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
