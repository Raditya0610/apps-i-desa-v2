import 'package:flutter/material.dart';
import 'app_sidebar.dart';

/// Responsive layout shell.
/// ≥ 900px → permanent sidebar + content side-by-side.
/// <  900px → full-width content + sidebar inside Drawer.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const double kBreakpoint = 900.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= kBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= kBreakpoint) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: Row(
              children: [
                const AppSidebar(),
                Container(width: 1, color: const Color(0xFFE5E7EB)),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          drawer: const Drawer(
            width: 280,
            child: AppSidebar(),
          ),
          body: child,
        );
      },
    );
  }
}
