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

  final _screens = const [
    DashboardScreen(),
    CheckInScreen(),
    NutritionScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final hasCheckin = context.watch<CheckInViewModel>().result != null;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          // Schedule data reload after build completes
          if (i == 2) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<NutritionViewModel>().loadToday();
            });
          }
          if (i == 3) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<HistoryViewModel>().load();
            });
          }
        },
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
