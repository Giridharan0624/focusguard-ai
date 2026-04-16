import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_screen.dart';
import 'checkin_screen.dart';
import 'nutrition_screen.dart';
import 'history_screen.dart';
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
        context.read<HistoryViewModel>().load();
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
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchTab,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: !hasCheckin,
              backgroundColor: AppTheme.riskCritical,
              smallSize: 8,
              child: const Icon(Icons.add_circle_outline_rounded),
            ),
            label: 'Check-In',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_rounded),
            label: 'Nutrition',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
