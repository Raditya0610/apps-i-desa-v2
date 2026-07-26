import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True while the Import Data screen has a previewed-but-not-yet-committed
/// import (fetched via /import/preview, not written to the database).
///
/// This lives outside ImportDataScreen's own State because navigation away
/// from that screen — the sidebar's `context.go(...)` calls in particular —
/// doesn't go through Navigator.pop, so a PopScope on the screen itself
/// can't intercept it. Widgets that navigate (AppSidebar) read this flag and
/// confirm with the operator before actually navigating, and ImportDataScreen
/// keeps it in sync with its own preview state.
final hasUnsavedImportPreviewProvider = StateProvider<bool>((ref) => false);
