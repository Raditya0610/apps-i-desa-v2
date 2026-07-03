import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../data/services/auth_service.dart';
import '../../widgets/common/app_shell.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await AuthService().changePassword(
      _oldPasswordController.text.trim(),
      _newPasswordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] == true
            ? ForuiThemeConfig.successColor
            : ForuiThemeConfig.errorColor,
      ));
      if (result['success'] == true) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ForuiThemeConfig.spacingLarge),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(ForuiThemeConfig.spacingMedium),
                                  decoration: BoxDecoration(
                                    color: ForuiThemeConfig.surfaceGreen,
                                    borderRadius: BorderRadius.circular(ForuiThemeConfig.borderRadiusMedium),
                                  ),
                                  child: const Icon(Icons.lock_outline, size: 28, color: ForuiThemeConfig.primaryGreen),
                                ),
                                const SizedBox(width: ForuiThemeConfig.spacingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Ganti Password',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                                      Text('Masukkan password lama dan baru',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ForuiThemeConfig.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: ForuiThemeConfig.spacingXLarge),
                            TextFormField(
                              controller: _oldPasswordController,
                              obscureText: _obscureOld,
                              decoration: InputDecoration(
                                labelText: 'Password Lama *',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureOld ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Password lama wajib diisi' : null,
                            ),
                            const SizedBox(height: ForuiThemeConfig.spacingLarge),
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: _obscureNew,
                              decoration: InputDecoration(
                                labelText: 'Password Baru *',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password baru wajib diisi';
                                if (v.length < 6) return 'Password minimal 6 karakter';
                                return null;
                              },
                            ),
                            const SizedBox(height: ForuiThemeConfig.spacingLarge),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              decoration: InputDecoration(
                                labelText: 'Konfirmasi Password Baru *',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                                if (v != _newPasswordController.text) return 'Password tidak cocok';
                                return null;
                              },
                            ),
                            const SizedBox(height: ForuiThemeConfig.spacingXLarge),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isLoading ? null : () => context.pop(),
                                    icon: const Icon(Icons.cancel_outlined),
                                    label: const Text('Batal'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: ForuiThemeConfig.spacingMedium + 4),
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
                                            height: 20, width: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                          )
                                        : const Icon(Icons.save),
                                    label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Password'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ForuiThemeConfig.primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: ForuiThemeConfig.spacingMedium + 4),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ganti Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2E1F))),
                Text('Keamanan Akun', style: TextStyle(fontSize: 12, color: Color(0xFF6B7C74))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
