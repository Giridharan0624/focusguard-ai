import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_screen.dart';
import 'checkin_screen.dart';
import 'nutrition_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';
import '../viewmodels/checkin_viewmodel.dart';
import '../viewmodels/history_viewmodel.dart';
import '../viewmodels/nutrition_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
    if (index == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<NutritionViewModel>().loadToday();
      });
    }
    if (index == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HistoryViewModel>().load(forceServer: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCheckin = context.watch<CheckInViewModel>().result != null;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(onSwitchTab: _switchTab),
          const CheckInScreen(),
          const NutritionScreen(),
          const HistoryScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Home',
                  selected: _currentIndex == 0,
                  onTap: () => _switchTab(0),
                ),
                _NavItem(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Check-In',
                  selected: _currentIndex == 1,
                  onTap: () => _switchTab(1),
                  badge: !hasCheckin,
                ),
                _NavItem(
                  icon: Icons.restaurant_rounded,
                  label: 'Nutrition',
                  selected: _currentIndex == 2,
                  onTap: () => _switchTab(2),
                ),
                _NavItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  selected: _currentIndex == 3,
                  onTap: () => _switchTab(3),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  selected: _currentIndex == 4,
                  onTap: () => _switchTab(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool badge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(icon, size: 22,
                    color: selected ? AppTheme.accent : AppTheme.th(context)),
                if (badge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.riskCritical,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? AppTheme.accent : AppTheme.th(context))),
          ],
        ),
      ),
    );
  }
}
