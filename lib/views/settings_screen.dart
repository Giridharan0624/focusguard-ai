import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final profile = authVM.userProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Profile ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassCard(context),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (profile?.name ?? '?')[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile?.name ?? 'User',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(profile?.email ?? '',
                            style: TextStyle(fontSize: 13, color: AppTheme.th(context))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Theme toggle ──
            Container(
              decoration: AppTheme.glassCard(context),
              child: ListTile(
                leading: Icon(
                  themeVM.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppTheme.warmAccent,
                ),
                title: const Text('Theme', style: TextStyle(fontSize: 15)),
                trailing: Switch.adaptive(
                  value: themeVM.isDark,
                  activeThumbColor: AppTheme.accent,
                  onChanged: (_) => themeVM.toggle(),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Sign out ──
            _Tile(
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              color: AppTheme.ts(context),
              onTap: () {
                authVM.signOut();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),

            // ── Delete ──
            _Tile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Account',
              color: AppTheme.riskCritical,
              onTap: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete account?'),
                  content: const Text('All data will be permanently deleted.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        authVM.deleteAccount();
                        Navigator.pop(context);
                      },
                      child: const Text('Delete', style: TextStyle(color: AppTheme.riskCritical)),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),
            Text('FocusGuard AI v1.0.0',
                style: TextStyle(fontSize: 12, color: AppTheme.th(context))),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _Tile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.glassCard(context),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 15, color: color)),
          ],
        ),
      ),
    );
  }
}
