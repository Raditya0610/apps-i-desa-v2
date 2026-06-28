import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/forui_theme.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedVillageId;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, String>> _villages = [
    {'id': '83eb95cc-e9ac-425f-8cef-2c3db0e0c24a', 'name': 'Ohoi Iso'},
    {'id': '9caa4ba3-3d4a-4fad-a5a0-6ca8ebc41ef7', 'name': 'Ohoi Disuk'},
    {'id': 'ce964e83-4a13-45eb-a2e5-9b903b0c9033', 'name': 'Ohoi Wain Baru'},
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ref.read(authStateProvider.notifier).register(
          _usernameController.text.trim(),
          _passwordController.text,
          _selectedVillageId!,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      context.go('/login');
    } else {
      setState(() {
        _errorMessage = result['message']?.toString().isNotEmpty == true
            ? result['message']
            : 'Pendaftaran gagal. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 700;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Page background ───────────────────────────
          Image.asset(
            'assets/images/login_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF132820), Color(0xFF1B3A2D), Color(0xFF2D6A4F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.38)),
          Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 960),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 50,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: isDesktop
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 45,
                          child: _RegisterFormPanel(
                            formKey: _formKey,
                            usernameController: _usernameController,
                            passwordController: _passwordController,
                            confirmPasswordController: _confirmPasswordController,
                            obscurePassword: _obscurePassword,
                            obscureConfirmPassword: _obscureConfirmPassword,
                            selectedVillageId: _selectedVillageId,
                            villages: _villages,
                            isLoading: _isLoading,
                            errorMessage: _errorMessage,
                            onTogglePassword: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            onToggleConfirmPassword: () => setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                            onVillageChanged: (v) =>
                                setState(() => _selectedVillageId = v),
                            onRegister: _handleRegister,
                            onLogin: () => context.go('/login'),
                          ),
                        ),
                        const Expanded(flex: 55, child: _ImagePanel()),
                      ],
                    ),
                  )
                : _RegisterFormPanel(
                    formKey: _formKey,
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    obscurePassword: _obscurePassword,
                    obscureConfirmPassword: _obscureConfirmPassword,
                    selectedVillageId: _selectedVillageId,
                    villages: _villages,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onToggleConfirmPassword: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                    onVillageChanged: (v) =>
                        setState(() => _selectedVillageId = v),
                    onRegister: _handleRegister,
                    onLogin: () => context.go('/login'),
                  ),
          ),
        ),
          ),
        ],
      ),
    );
  }
}

// ─── Register Form Panel ──────────────────────────────────────────────────────

class _RegisterFormPanel extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? selectedVillageId;
  final List<Map<String, String>> villages;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final ValueChanged<String?> onVillageChanged;
  final VoidCallback onRegister;
  final VoidCallback onLogin;

  const _RegisterFormPanel({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.selectedVillageId,
    required this.villages,
    required this.isLoading,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onVillageChanged,
    required this.onRegister,
    required this.onLogin,
  });

  static final _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE8EDE9)),
  );

  static final _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide:
        const BorderSide(color: ForuiThemeConfig.primaryGreen, width: 1.5),
  );

  static final _errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: ForuiThemeConfig.errorColor),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Logo ─────────────────────────────────
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ForuiThemeConfig.darkGreen,
                        ForuiThemeConfig.lightGreen,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.eco_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'i-Desa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ForuiThemeConfig.primaryGreen,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Headline ──────────────────────────────
            const Text(
              'Buat akun baru',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: ForuiThemeConfig.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Daftarkan akun untuk mengakses sistem.',
              style: TextStyle(
                fontSize: 14,
                color: ForuiThemeConfig.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // ── Error banner ──────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: errorMessage != null
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 18, color: ForuiThemeConfig.errorColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: ForuiThemeConfig.errorColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // ── Username ──────────────────────────────
            TextFormField(
              controller: usernameController,
              style: const TextStyle(
                  fontSize: 14, color: ForuiThemeConfig.textPrimary),
              decoration: InputDecoration(
                hintText: 'Username',
                hintStyle: const TextStyle(
                    fontSize: 14, color: ForuiThemeConfig.textHint),
                prefixIcon: const Icon(Icons.person_outline_rounded,
                    size: 18, color: ForuiThemeConfig.textHint),
                filled: true,
                fillColor: const Color(0xFFF6F8F6),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                border: _fieldBorder,
                enabledBorder: _fieldBorder,
                focusedBorder: _focusedBorder,
                errorBorder: _errorBorder,
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: ForuiThemeConfig.errorColor, width: 1.5),
                ),
                errorStyle: const TextStyle(fontSize: 12),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Username harus diisi'
                  : null,
            ),

            const SizedBox(height: 12),

            // ── Village dropdown ──────────────────────
            DropdownButtonFormField<String>(
              initialValue: selectedVillageId,
              style: const TextStyle(
                  fontSize: 14, color: ForuiThemeConfig.textPrimary),
              decoration: InputDecoration(
                hintText: 'Pilih desa',
                hintStyle: const TextStyle(
                    fontSize: 14, color: ForuiThemeConfig.textHint),
                prefixIcon: const Icon(Icons.location_on_outlined,
                    size: 18, color: ForuiThemeConfig.textHint),
                filled: true,
                fillColor: const Color(0xFFF6F8F6),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                border: _fieldBorder,
                enabledBorder: _fieldBorder,
                focusedBorder: _focusedBorder,
                errorBorder: _errorBorder,
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: ForuiThemeConfig.errorColor, width: 1.5),
                ),
                errorStyle: const TextStyle(fontSize: 12),
              ),
              items: villages
                  .map((v) => DropdownMenuItem<String>(
                        value: v['id'],
                        child: Text(v['name']!),
                      ))
                  .toList(),
              onChanged: onVillageChanged,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Desa harus dipilih' : null,
            ),

            const SizedBox(height: 12),

            // ── Password ──────────────────────────────
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: const TextStyle(
                  fontSize: 14, color: ForuiThemeConfig.textPrimary),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(
                    fontSize: 14, color: ForuiThemeConfig.textHint),
                prefixIcon: const Icon(Icons.lock_outline_rounded,
                    size: 18, color: ForuiThemeConfig.textHint),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: ForuiThemeConfig.textHint,
                  ),
                  onPressed: onTogglePassword,
                ),
                filled: true,
                fillColor: const Color(0xFFF6F8F6),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                border: _fieldBorder,
                enabledBorder: _fieldBorder,
                focusedBorder: _focusedBorder,
                errorBorder: _errorBorder,
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: ForuiThemeConfig.errorColor, width: 1.5),
                ),
                errorStyle: const TextStyle(fontSize: 12),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password harus diisi';
                if (v.length < 6) return 'Password minimal 6 karakter';
                return null;
              },
            ),

            const SizedBox(height: 12),

            // ── Confirm Password ──────────────────────
            TextFormField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              style: const TextStyle(
                  fontSize: 14, color: ForuiThemeConfig.textPrimary),
              decoration: InputDecoration(
                hintText: 'Konfirmasi password',
                hintStyle: const TextStyle(
                    fontSize: 14, color: ForuiThemeConfig.textHint),
                prefixIcon: const Icon(Icons.lock_outline_rounded,
                    size: 18, color: ForuiThemeConfig.textHint),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: ForuiThemeConfig.textHint,
                  ),
                  onPressed: onToggleConfirmPassword,
                ),
                filled: true,
                fillColor: const Color(0xFFF6F8F6),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                border: _fieldBorder,
                enabledBorder: _fieldBorder,
                focusedBorder: _focusedBorder,
                errorBorder: _errorBorder,
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: ForuiThemeConfig.errorColor, width: 1.5),
                ),
                errorStyle: const TextStyle(fontSize: 12),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Konfirmasi password harus diisi';
                }
                if (v != passwordController.text) {
                  return 'Password tidak cocok';
                }
                return null;
              },
            ),

            const SizedBox(height: 22),

            // ── Register button ───────────────────────
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : onRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ForuiThemeConfig.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor:
                      ForuiThemeConfig.primaryGreen.withValues(alpha: 0.6),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 18),

            // ── Login link ────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sudah punya akun? ',
                  style: TextStyle(
                    fontSize: 13,
                    color: ForuiThemeConfig.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: onLogin,
                  child: const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ForuiThemeConfig.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Image Panel (sama dengan login screen) ───────────────────────────────────

class _ImagePanel extends StatelessWidget {
  static const String _imagePath = 'assets/images/login_bg.jpg';

  const _ImagePanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _PlaceholderBg(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.50),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 32,
            left: 28,
            child: _FloatingCard(
              icon: Icons.how_to_reg_rounded,
              title: 'Akses Mudah',
              subtitle: 'Kelola data desa kapan saja',
            ),
          ),
          const Positioned(
            bottom: 100,
            right: 28,
            child: _FloatingCard(
              icon: Icons.security_rounded,
              title: 'Data Aman',
              subtitle: 'Terenkripsi & terlindungi',
              alignRight: true,
            ),
          ),
          const Positioned(
            bottom: 36,
            left: 28,
            right: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ohoi Elaar Ngursoin,\nLamagorang, dan Let',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Sistem Informasi Manajemen Desa Terpadu',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _PlaceholderBg extends StatelessWidget {
  const _PlaceholderBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF132820),
            Color(0xFF1B3A2D),
            Color(0xFF2D6A4F),
            Color(0xFF52B788),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.account_balance_rounded,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tempatkan foto desa di:\nassets/images/login_bg.jpg',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool alignRight;

  const _FloatingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    );
    final textWidget = Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        Text(subtitle,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
      ],
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignRight
            ? [textWidget, const SizedBox(width: 10), iconWidget]
            : [iconWidget, const SizedBox(width: 10), textWidget],
      ),
    );
  }
}
