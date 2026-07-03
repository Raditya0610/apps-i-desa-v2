import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/form_options.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../data/models/sub_dimensions/penanggulangan_bencana.dart';
import '../../../providers/penanggulangan_bencana_provider.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/sub_dimension_dropdown.dart';

class PenanggulanganBencanaFormScreen extends ConsumerStatefulWidget {
  const PenanggulanganBencanaFormScreen({super.key});

  @override
  ConsumerState<PenanggulanganBencanaFormScreen> createState() => _PenanggulanganBencanaFormScreenState();
}

class _PenanggulanganBencanaFormScreenState extends ConsumerState<PenanggulanganBencanaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _year = DateTime.now().year;

  // Dropdown state variables
  String? _aspekInformasiKebencanaan;
  String? _fasilitasMitigasiBencana;
  String? _aksesMenujuFasilitasMitigasiBencana;
  String? _aktivitasMitigasi;
  String? _fasilitasTanggapDaruratBencana;

  bool _isLoading = false;
  String? _editingId;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final data = PenanggulanganBencana(
      villageId: '',
      year: _year,
      aspekInformasiKebencanaan: _aspekInformasiKebencanaan ?? '',
      fasilitasMitigasiBencana: _fasilitasMitigasiBencana ?? '',
      aksesMenujuFasilitasMitigasiBencana: _aksesMenujuFasilitasMitigasiBencana ?? '',
      aktivitasMitigasi: _aktivitasMitigasi ?? '',
      fasilitasTanggapDaruratBencana: _fasilitasTanggapDaruratBencana ?? '',
    );

    final Map<String, dynamic> result;
    if (_editingId != null) {
      result = await ref.read(penanggulanganBencanaProvider.notifier).update(_editingId!, data);
    } else {
      result = await ref.read(penanggulanganBencanaProvider.notifier).create(data);
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
          _buildTopHeader(context, 'Indikator Penanggulangan Bencana', 'Input data penanggulangan bencana'),
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
                            color: Colors.deepOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                          ),
                          child: const Icon(Icons.warning, size: 32, color: Colors.deepOrange),
                        ),
                        const SizedBox(width: ForuiThemeConfig.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Penanggulangan Bencana',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Isi data indikator penanggulangan bencana desa',
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

                    // Informasi Kebencanaan Section
                    _buildSectionHeader('Informasi Kebencanaan'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Aspek Informasi Kebencanaan',
                      value: _aspekInformasiKebencanaan,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.info,
                      onChanged: (value) => setState(() => _aspekInformasiKebencanaan = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Mitigasi Bencana Section
                    _buildSectionHeader('Mitigasi Bencana'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Fasilitas Mitigasi Bencana',
                      value: _fasilitasMitigasiBencana,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.safety_check,
                      onChanged: (value) => setState(() => _fasilitasMitigasiBencana = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Akses Menuju Fasilitas Mitigasi Bencana',
                      value: _aksesMenujuFasilitasMitigasiBencana,
                      options: FormOptions.kemudahanAkses,
                      prefixIcon: Icons.accessibility,
                      onChanged: (value) => setState(() => _aksesMenujuFasilitasMitigasiBencana = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Aktivitas Mitigasi',
                      value: _aktivitasMitigasi,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.work,
                      onChanged: (value) => setState(() => _aktivitasMitigasi = value),
                    ),
                    const SizedBox(height: ForuiThemeConfig.spacingXLarge),

                    // Tanggap Darurat Bencana Section
                    _buildSectionHeader('Tanggap Darurat Bencana'),
                    const SizedBox(height: ForuiThemeConfig.spacingMedium),

                    SubDimensionDropdown(
                      label: 'Fasilitas Tanggap Darurat Bencana',
                      value: _fasilitasTanggapDaruratBencana,
                      options: FormOptions.keberadaan,
                      prefixIcon: Icons.emergency,
                      onChanged: (value) => setState(() => _fasilitasTanggapDaruratBencana = value),
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
    _aspekInformasiKebencanaan = null;
    _fasilitasMitigasiBencana = null;
    _aksesMenujuFasilitasMitigasiBencana = null;
    _aktivitasMitigasi = null;
    _fasilitasTanggapDaruratBencana = null;
  }

  void _prefillForm(PenanggulanganBencana record) {
    setState(() {
      _editingId = record.id;
      _year = record.year;
      _aspekInformasiKebencanaan = record.aspekInformasiKebencanaan;
      _fasilitasMitigasiBencana = record.fasilitasMitigasiBencana;
      _aksesMenujuFasilitasMitigasiBencana = record.aksesMenujuFasilitasMitigasiBencana;
      _aktivitasMitigasi = record.aktivitasMitigasi;
      _fasilitasTanggapDaruratBencana = record.fasilitasTanggapDaruratBencana;
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
    final provState = ref.watch(penanggulanganBencanaProvider);
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

  Widget _buildRecordRow(PenanggulanganBencana record) {
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

  Future<void> _confirmDelete(PenanggulanganBencana record) async {
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
    final result = await ref.read(penanggulanganBencanaProvider.notifier).delete(record.id!);
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
        color: Colors.deepOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusSmall),
        border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.3)),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.deepOrange.shade700,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
