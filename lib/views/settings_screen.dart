import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/checkin_viewmodel.dart';
import '../viewmodels/history_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final checkinVM = context.watch<CheckInViewModel>();
    final historyVM = context.watch<HistoryViewModel>();
    final profile = authVM.userProfile;
    final result = checkinVM.result;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // ══ Header ══
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text('Profile',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ══ Profile hero card ══
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.22),
                    blurRadius: 20, offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.onAccent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (profile?.name ?? '?')[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700,
                              color: AppTheme.accent),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile?.name ?? 'User',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                                    color: AppTheme.onAccent)),
                            const SizedBox(height: 2),
                            Text(profile?.email ?? '',
                                style: const TextStyle(fontSize: 12, color: AppTheme.onAccent)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showEditProfile(context, authVM),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.onAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_rounded,
                              size: 16, color: AppTheme.onAccent),
                        ),
                      ),
                    ],
                  ),
                  if (profile?.age != null || profile?.occupation != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.onAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if (profile?.age != null) ...[
                            const Icon(Icons.cake_rounded, size: 14, color: AppTheme.onAccent),
                            const SizedBox(width: 4),
                            Text('${profile!.age} yrs',
                                style: const TextStyle(fontSize: 12, color: AppTheme.onAccent,
                                    fontWeight: FontWeight.w600)),
                          ],
                          if (profile?.occupation != null) ...[
                            if (profile?.age != null)
                              const SizedBox(width: 12),
                            const Icon(Icons.work_rounded, size: 14, color: AppTheme.onAccent),
                            const SizedBox(width: 4),
                            Text(profile!.occupation!,
                                style: const TextStyle(fontSize: 12, color: AppTheme.onAccent,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ══ Stats ══
            Text('Your Stats',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(
                  icon: Icons.event_note_rounded,
                  color: const Color(0xFF42A5F5),
                  value: '${historyVM.entries.length}',
                  label: 'Check-ins',
                )),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(
                  icon: Icons.speed_rounded,
                  color: result != null
                      ? AppTheme.riskColor(result.riskLevel)
                      : const Color(0xFFFFA726),
                  value: result != null ? '${result.score.round()}' : '--',
                  label: 'Latest',
                )),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  color: AppTheme.warmAccent,
                  value: '${historyVM.entries.length}',
                  label: 'Streak',
                )),
              ],
            ),
            const SizedBox(height: 20),

            // ══ Preferences ══
            Text('Preferences',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            _SettingRow(
              icon: themeVM.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              iconColor: AppTheme.warmAccent,
              label: 'Dark Mode',
              trailing: Switch.adaptive(
                value: themeVM.isDark,
                activeThumbColor: AppTheme.accent,
                onChanged: (_) => themeVM.toggle(),
              ),
            ),

            const SizedBox(height: 20),

            // ══ Account ══
            Text('Account',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            _SettingRow(
              icon: Icons.logout_rounded,
              iconColor: AppTheme.ts(context),
              label: 'Sign Out',
              onTap: () { authVM.signOut(); },
              showArrow: true,
            ),
            const SizedBox(height: 8),
            _SettingRow(
              icon: Icons.delete_outline_rounded,
              iconColor: AppTheme.riskCritical,
              label: 'Delete Account',
              labelColor: AppTheme.riskCritical,
              onTap: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete account?'),
                  content: const Text('All data will be permanently deleted. This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        authVM.deleteAccount();
                      },
                      child: const Text('Delete',
                          style: TextStyle(color: AppTheme.riskCritical)),
                    ),
                  ],
                ),
              ),
              showArrow: true,
            ),

            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_rounded,
                        size: 20, color: AppTheme.onAccent),
                  ),
                  const SizedBox(height: 8),
                  const Text('FocusGuard AI',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text('v1.0.0 · Predict. Prevent. Perform.',
                      style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context, AuthViewModel authVM) {
    final nameCtrl = TextEditingController(text: authVM.userProfile?.name ?? '');
    final ageCtrl = TextEditingController(text: authVM.userProfile?.age?.toString() ?? '');
    final occCtrl = TextEditingController(text: authVM.userProfile?.occupation ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.textHint, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    hintText: 'Name', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 12),
            TextField(controller: ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    hintText: 'Age', prefixIcon: Icon(Icons.cake_outlined))),
            const SizedBox(height: 12),
            TextField(controller: occCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    hintText: 'Occupation', prefixIcon: Icon(Icons.work_outline))),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                authVM.saveProfile(
                  name: nameCtrl.text.trim().isNotEmpty
                      ? nameCtrl.text.trim() : authVM.userProfile?.name ?? 'User',
                  age: int.tryParse(ageCtrl.text.trim()),
                  occupation: occCtrl.text.trim().isNotEmpty ? occCtrl.text.trim() : null,
                );
                Navigator.pop(ctx);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text('Save Profile',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                              color: AppTheme.onAccent)),
                    ),
                    Icon(Icons.check_rounded, color: AppTheme.onAccent),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value, label;
  const _StatCard({required this.icon, required this.color,
      required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppTheme.tp(context))),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showArrow;

  const _SettingRow({required this.icon, required this.iconColor, required this.label,
      this.labelColor, this.trailing, this.onTap, this.showArrow = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outline(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                      color: labelColor ?? AppTheme.tp(context))),
            ),
            if (trailing != null) trailing!,
            if (showArrow)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppTheme.th(context)),
          ],
        ),
      ),
    );
  }
}
