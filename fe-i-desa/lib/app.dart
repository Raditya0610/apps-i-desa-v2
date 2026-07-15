import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'core/theme/forui_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/session.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ForuiThemeConfig.lightTheme;

    // Reset all village-scoped data whenever the logged-in identity changes.
    // The data providers fetch once in their constructor and live for the whole
    // session, so a new login would otherwise keep showing the previous user's
    // data (a cross-village PII leak) instead of re-fetching. Keyed on username:
    // it changes on login (null -> user), logout (user -> null), and account
    // switch (userA -> userB). MyApp is always mounted, so this listener never
    // misses a transition.
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (previous?.username != next.username) {
        invalidateSessionData(ref);
      }
    });

    return MaterialApp.router(
      title: 'Apps I-Desa',
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: FLocalizations.localizationsDelegates,
      theme: ForuiThemeConfig.materialLightTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => FTheme(
        data: theme,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
