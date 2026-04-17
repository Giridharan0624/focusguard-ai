import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/checkin_viewmodel.dart';
import '../viewmodels/history_viewmodel.dart';
import 'chat_screen.dart';
import 'result_screen.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const DashboardScreen({super.key, required this.onSwitchTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final checkinVM = context.watch<CheckInViewModel>();
    final result = checkinVM.result;

    // Score: invert burnout (high burnout = low wellness)
    final wellness = result != null ? (100 - result.score).round() : 0;
    final moodValue = result != null ? checkinVM.mood : 0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            // ══ Welcome row ══
            Row(
              children: [
                _Avatar(name: authVM.userProfile?.name ?? '?'),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back,',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        authVM.userProfile?.name ?? 'there',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                _HeaderIcon(
                  icon: Icons.notifications_none_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _HeaderIcon(
                  icon: Icons.person_rounded,
                  onTap: () => widget.onSwitchTab(4),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ══ Daily Score (Yellow hero card) ══
            _DailyScoreCard(
              wellnessScore: wellness,
              hasCheckin: result != null,
              onTap: result != null
                  ? () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ResultScreen()))
                  : () => widget.onSwitchTab(1),
            ),
            const SizedBox(height: 20),

            // ══ Mood row ══
            Text('Choose your mood for today',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            _MoodRow(
              selectedMood: moodValue,
              onSelect: (m) {
                HapticFeedback.selectionClick();
                checkinVM.mood = m;
              },
            ),
            const SizedBox(height: 20),

            // ══ Bento grid ══
            _BentoGrid(
              sleepHours: result != null ? checkinVM.sleepHours : null,
              workHours: result != null ? checkinVM.workHours : null,
              screenTime: result != null ? checkinVM.screenTime : null,
              caffeine: result != null ? checkinVM.caffeine : null,
              onTapCard: () => widget.onSwitchTab(1),
            ),
            const SizedBox(height: 20),

            // ══ AI Chat CTA ══
            _ChatCTA(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChatScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  AVATAR
// ══════════════════════════════════════════
class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        name[0].toUpperCase(),
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.onAccent),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  HEADER ICON
// ══════════════════════════════════════════
class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.outline(context), width: 1),
        ),
        child: Icon(icon, size: 18, color: AppTheme.tp(context)),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  DAILY SCORE CARD (Yellow Hero)
// ══════════════════════════════════════════
class _DailyScoreCard extends StatelessWidget {
  final int wellnessScore;
  final bool hasCheckin;
  final VoidCallback onTap;

  const _DailyScoreCard({
    required this.wellnessScore,
    required this.hasCheckin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Score',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onAccent,
                        height: 1.1,
                      )),
                  const SizedBox(height: 6),
                  Text(
                    hasCheckin
                        ? '$wellnessScore% wellness today'
                        : 'Complete check-in to see your score',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.onAccent,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            _ScoreRing(percent: wellnessScore / 100),
          ],
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final double percent;
  const _ScoreRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(80, 80),
            painter: _RingPainter(percent: percent),
          ),
          Text(
            '${(percent * 100).round()}%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.onAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  _RingPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background ring
    final bg = Paint()
      ..color = AppTheme.onAccent.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);

    // Progress ring
    if (percent > 0) {
      final fg = Paint()
        ..color = AppTheme.onAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * percent,
        false,
        fg,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.percent != percent;
}

// ══════════════════════════════════════════
//  MOOD ROW
// ══════════════════════════════════════════
class _MoodRow extends StatelessWidget {
  final int selectedMood;
  final void Function(int) onSelect;

  const _MoodRow({required this.selectedMood, required this.onSelect});

  static const _moods = [
    (2, '😫'),
    (4, '😟'),
    (6, '😐'),
    (8, '🙂'),
    (10, '😄'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _moods.map((m) {
        final selected = (selectedMood - m.$1).abs() <= 1 && selectedMood > 0;
        return GestureDetector(
          onTap: () => onSelect(m.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.accent.withValues(alpha: 0.15)
                  : AppTheme.card(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppTheme.accent : AppTheme.outline(context),
                width: selected ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(m.$2,
                style: TextStyle(fontSize: selected ? 24 : 20)),
          ),
        );
      }).toList(),
    );
  }
}

// ══════════════════════════════════════════
//  BENTO GRID
// ══════════════════════════════════════════
class _BentoGrid extends StatelessWidget {
  final double? sleepHours;
  final double? workHours;
  final double? screenTime;
  final int? caffeine;
  final VoidCallback onTapCard;

  const _BentoGrid({
    required this.sleepHours,
    required this.workHours,
    required this.screenTime,
    required this.caffeine,
    required this.onTapCard,
  });

  String _hm(double? h) {
    if (h == null) return '--';
    final hours = h.floor();
    final mins = ((h - hours) * 60).round();
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _BentoCard(
                icon: Icons.nights_stay_rounded,
                iconColor: const Color(0xFF42A5F5),
                value: _hm(sleepHours),
                label: 'Sleep',
                subtitle: sleepHours != null && sleepHours! >= 7
                    ? 'Good start, keep going'
                    : 'Aim for 7-9 hours',
                onTap: onTapCard,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BentoCard(
                icon: Icons.work_rounded,
                iconColor: const Color(0xFFE07C54),
                value: _hm(workHours),
                label: 'Work',
                subtitle: workHours != null && workHours! > 10
                    ? 'Take a break'
                    : "You're on track",
                onTap: onTapCard,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _BentoCard(
                icon: Icons.phone_android_rounded,
                iconColor: const Color(0xFFFFA726),
                value: _hm(screenTime),
                label: 'Screen Time',
                subtitle: screenTime != null && screenTime! > 8
                    ? 'Too much screen'
                    : 'Keep it balanced',
                onTap: onTapCard,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BentoCard(
                icon: Icons.coffee_rounded,
                iconColor: const Color(0xFFAB47BC),
                value: caffeine != null ? '$caffeine' : '--',
                label: 'Caffeine',
                subtitle: caffeine != null && caffeine! > 4
                    ? 'Cut back today'
                    : 'Good amount',
                onTap: onTapCard,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _BentoCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outline(context), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(height: 14),
            Text(value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.tp(context),
                  height: 1.1,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.tp(context),
                )),
            const SizedBox(height: 6),
            Text(subtitle,
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  CHAT CTA
// ══════════════════════════════════════════
class _ChatCTA extends StatelessWidget {
  final VoidCallback onTap;
  const _ChatCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Talk to AI coach',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onAccent),
              ),
            ),
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(
                color: AppTheme.onAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  size: 18, color: AppTheme.accent),
            ),
          ],
        ),
      ),
    );
  }
}
