/// Application configuration
///
/// Controls various app settings including API mode (mock vs real)
class AppConfig {
  /// Toggle between mock API and real API
  ///
  /// Set to `true` to use mock data (no backend required)
  /// Set to `false` to use real backend API
  ///
  /// Mock mode is useful for:
  /// - Offline development
  /// - Testing without backend
  /// - Demos and presentations
  /// - UI development
  static const bool useMockApi = false;

  /// Enable debug logging
  static const bool enableDebugLogging = true;

  /// App version
  static const String appVersion = '1.0.0';

  /// App name
  static const String appName = 'Apps I-Desa';

  /// Where SIMPOI (the surat-generator app) is served from.
  ///
  /// SIMPOI is a separate app in its own repo (github.com/shinnwlfrd/simpoi) that
  /// i-Desa links out to; it is not built into this bundle.
  ///
  /// Points at its GitHub Pages deploy, so it needs internet. To make it work
  /// during the desa office's outages, serve a local copy and override this:
  ///   flutter build windows --dart-define=SIMPOI_URL=http://localhost:4173
  static const String simpoiUrl = String.fromEnvironment(
    'SIMPOI_URL',
    defaultValue: 'https://shinnwlfrd.github.io/simpoi/',
  );

  /// Get current mode as string
  static String get currentMode => useMockApi ? 'Mock Mode' : 'Live Mode';

  /// Check if in development mode
  static bool get isDevelopment => useMockApi;

  /// Check if in production mode
  static bool get isProduction => !useMockApi;
}
