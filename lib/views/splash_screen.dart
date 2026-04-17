import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _totalDuration = Duration(milliseconds: 3000);

  late final AnimationController _intro;
  late final AnimationController _loop;
  late final Animation<double> _bgFade;
  late final Animation<double> _coreScale;
  late final Animation<double> _iconPop;
  late final Animation<double> _wordmarkFade;
  late final Animation<Offset> _wordmarkSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(vsync: this, duration: _totalDuration);
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _bgFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );
    _coreScale = Tween(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.05, 0.45, curve: Curves.easeOutBack),
      ),
    );
    _iconPop = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.2, 0.55, curve: Curves.elasticOut),
    );
    _wordmarkFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
    );
    _wordmarkSlide = Tween(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic),
    ));
    _taglineFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.55, 0.8, curve: Curves.easeOut),
    );
    _progress = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
    );

    _intro.forward();

    Future.delayed(_totalDuration, () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, b) => const AuthGate(),
          transitionsBuilder: (_, animation, b2, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_intro, _loop]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Ambient background: two drifting radial orbs ──
              Opacity(
                opacity: _bgFade.value,
                child: CustomPaint(
                  painter: _AmbientBackgroundPainter(
                    t: _loop.value,
                    accent: AppTheme.accent,
                    base: bg,
                    dark: isDark,
                  ),
                ),
              ),

              // ── Radar pulse rings + core ──
              Align(
                alignment: const Alignment(0, -0.15),
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Three staggered pulse rings
                      for (int i = 0; i < 3; i++)
                        _PulseRing(
                          phase: (_loop.value + i / 3) % 1.0,
                          color: AppTheme.accent,
                          maxRadius: 130,
                        ),

                      // Rotating radar arc
                      Transform.rotate(
                        angle: _loop.value * 2 * math.pi,
                        child: CustomPaint(
                          size: const Size(180, 180),
                          painter: _RadarSweepPainter(
                            color: AppTheme.accent,
                          ),
                        ),
                      ),

                      // Glowing core disc with shield icon
                      Transform.scale(
                        scale: _coreScale.value,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.accent,
                                AppTheme.accent.withValues(alpha: 0.85),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withValues(alpha: 0.55),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: AppTheme.accent.withValues(alpha: 0.3),
                                blurRadius: 80,
                                spreadRadius: 16,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Transform.scale(
                            scale: 0.6 + 0.4 * _iconPop.value,
                            child: Opacity(
                              opacity: _iconPop.value.clamp(0.0, 1.0),
                              child: const Icon(
                                Icons.shield_rounded,
                                size: 44,
                                color: AppTheme.onAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Wordmark + tagline + progress ──
              Align(
                alignment: const Alignment(0, 0.55),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _wordmarkFade,
                        child: SlideTransition(
                          position: _wordmarkSlide,
                          child: _ShimmerWordmark(
                            t: _loop.value,
                            textColor: AppTheme.tp(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FadeTransition(
                        opacity: _taglineFade,
                        child: Text(
                          'PREDICT  ·  PREVENT  ·  PERFORM',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.th(context),
                            letterSpacing: 3.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      FadeTransition(
                        opacity: _taglineFade,
                        child: SizedBox(
                          width: 140,
                          height: 2,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.outline(context),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: _progress.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent,
                                    borderRadius: BorderRadius.circular(1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accent
                                            .withValues(alpha: 0.6),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── A single outward-expanding pulse ring ──
class _PulseRing extends StatelessWidget {
  final double phase; // 0..1
  final Color color;
  final double maxRadius;
  const _PulseRing({
    required this.phase,
    required this.color,
    required this.maxRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Scale from 0.3 → 1.0; opacity 0.55 → 0 (ease-out)
    final eased = Curves.easeOut.transform(phase);
    final radius = 40 + (maxRadius - 40) * eased;
    final opacity = (1 - eased) * 0.55;
    return IgnorePointer(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

// ── Sweeping radar arc ──
class _RadarSweepPainter extends CustomPainter {
  final Color color;
  _RadarSweepPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Trailing arc with gradient (bright head, fading tail)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = math.pi * 0.55;
    final startAngle = -math.pi / 2;

    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweep,
      colors: [
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.35),
        color.withValues(alpha: 0.9),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweep, false, paint);

    // Bright leading dot
    final headAngle = startAngle + sweep;
    final dotCenter = Offset(
      center.dx + radius * math.cos(headAngle),
      center.dy + radius * math.sin(headAngle),
    );
    final dotPaint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(dotCenter, 5, dotPaint);
    canvas.drawCircle(dotCenter, 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RadarSweepPainter old) => old.color != color;
}

// ── Ambient background — two drifting radial orbs ──
class _AmbientBackgroundPainter extends CustomPainter {
  final double t; // 0..1, loops
  final Color accent;
  final Color base;
  final bool dark;
  _AmbientBackgroundPainter({
    required this.t,
    required this.accent,
    required this.base,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base fill
    canvas.drawRect(Offset.zero & size, Paint()..color = base);

    final angle = t * 2 * math.pi;
    final drift = 30.0;

    // Orb 1: accent, top-left, drifts
    final c1 = Offset(
      size.width * 0.25 + math.cos(angle) * drift,
      size.height * 0.25 + math.sin(angle) * drift,
    );
    final p1 = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: dark ? 0.22 : 0.18),
          accent.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: c1, radius: size.width * 0.55));
    canvas.drawCircle(c1, size.width * 0.55, p1);

    // Orb 2: subtle cool tint, bottom-right, opposite drift
    final coolTint =
        dark ? const Color(0xFF4A60FF) : const Color(0xFF7B8CFF);
    final c2 = Offset(
      size.width * 0.8 - math.cos(angle) * drift,
      size.height * 0.8 - math.sin(angle) * drift,
    );
    final p2 = Paint()
      ..shader = RadialGradient(
        colors: [
          coolTint.withValues(alpha: dark ? 0.14 : 0.08),
          coolTint.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: c2, radius: size.width * 0.55));
    canvas.drawCircle(c2, size.width * 0.55, p2);

    // Fine noise dots (static) — adds texture without a repaint cost concern
    final dotPaint = Paint()
      ..color = (dark ? Colors.white : Colors.black).withValues(alpha: 0.03);
    final rng = math.Random(42);
    for (int i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 1.2 + 0.3,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_AmbientBackgroundPainter old) =>
      old.t != t || old.dark != dark;
}

// ── Wordmark with a moving shimmer sweep ──
class _ShimmerWordmark extends StatelessWidget {
  final double t; // 0..1
  final Color textColor;
  const _ShimmerWordmark({required this.t, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        // Sweep a bright accent band across the text
        final x = (t * 2 - 0.5) * bounds.width;
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            textColor,
            textColor,
            AppTheme.accent,
            textColor,
            textColor,
          ],
          stops: [
            0.0,
            ((x - 60) / bounds.width).clamp(0.0, 1.0),
            (x / bounds.width).clamp(0.0, 1.0),
            ((x + 60) / bounds.width).clamp(0.0, 1.0),
            1.0,
          ],
        ).createShader(bounds);
      },
      child: Text(
        'FocusGuard AI',
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: -0.8,
          height: 1.0,
        ),
      ),
    );
  }
}
