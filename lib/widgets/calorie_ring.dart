import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalorieRing extends StatefulWidget {
  final double consumed;
  final double goal;
  final double size;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    this.size = 160,
  });

  @override
  State<CalorieRing> createState() => _CalorieRingState();
}

class _CalorieRingState extends State<CalorieRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    final percent = widget.goal > 0
        ? (widget.consumed / widget.goal).clamp(0.0, 1.0)
        : 0.0;
    _animation = Tween(begin: 0.0, end: percent).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(CalorieRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumed != widget.consumed) {
      final oldPercent = oldWidget.goal > 0
          ? (oldWidget.consumed / oldWidget.goal).clamp(0.0, 1.0)
          : 0.0;
      final newPercent = widget.goal > 0
          ? (widget.consumed / widget.goal).clamp(0.0, 1.0)
          : 0.0;
      _animation = Tween(begin: oldPercent, end: newPercent).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (widget.goal - widget.consumed).clamp(0.0, widget.goal);
    final percentNum = widget.goal > 0
        ? (widget.consumed / widget.goal * 100).clamp(0.0, 100.0)
        : 0.0;
    final color = AppTheme.nutrientColor(percentNum);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  percent: _animation.value,
                  color: color,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.consumed.round().toString(),
                    style: TextStyle(
                      fontSize: widget.size * 0.18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: widget.size * 0.08,
                      color: AppTheme.th(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${remaining.round()} left',
                    style: TextStyle(
                      fontSize: widget.size * 0.07,
                      color: AppTheme.ts(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;

  _RingPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const startAngle = -pi / 2;
    const fullSweep = 2 * pi;

    final bgPaint = Paint()
      ..color = AppTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullSweep,
      false,
      bgPaint,
    );

    if (percent > 0) {
      final scorePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + fullSweep * percent,
          colors: [color.withValues(alpha: 0.6), color],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fullSweep * percent,
        false,
        scorePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percent != percent || old.color != color;
}
