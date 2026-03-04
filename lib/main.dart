import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const StrengthLabsApp());
}

class StrengthLabsApp extends StatelessWidget {
  const StrengthLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StrengthLabs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}

// ─────────────────────────────────────────────────────────
// MAIN SHELL — Bottom Navigation
// ─────────────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    _PlaceholderScreen(label: 'MÉTRICAS'),   // → MetricsScreen()
    _PlaceholderScreen(label: 'PLAN'),        // → PlanScreen()
    _PlaceholderScreen(label: 'PERFIL'),      // → ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _SLBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// CUSTOM BOTTOM NAV BAR
// ─────────────────────────────────────────────────────────
class _SLBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SLBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(Icons.grid_view_rounded, 'INICIO'),
      _NavItem(Icons.show_chart_rounded, 'MÉTRICAS'),
      _NavItem(Icons.calendar_month_rounded, 'PLAN'),
      _NavItem(Icons.person_rounded, 'PERFIL'),
    ];

    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(
            items.length,
            (i) => Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i].icon,
                      size: 20,
                      color: i == currentIndex
                          ? AppColors.accent
                          : AppColors.textMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        fontFamily: 'ShareTechMono',
                        fontSize: 8,
                        letterSpacing: 1,
                        color: i == currentIndex
                            ? AppColors.accent
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// Placeholder para pantallas pendientes
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'BarlowCondensed',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PRÓXIMAMENTE',
              style: TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 10,
                letterSpacing: 3,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
