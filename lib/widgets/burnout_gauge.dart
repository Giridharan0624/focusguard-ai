import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../viewmodels/checkin_viewmodel.dart';

class BurnoutGauge extends StatefulWidget {
  final double score;
  final double size;
  final bool animate;

  const BurnoutGauge({
    super.key,
    required this.score,
    this.size = 200,
    this.animate = true,
  });

  @override
  State<BurnoutGauge> createState() => _BurnoutGaugeState();
}

class _BurnoutGaugeState extends State<BurnoutGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween(begin: 0.0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.animate) {
      _controller.forward();
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          HapticFeedback.mediumImpact();
        }
      });
    } else {
      _animation = AlwaysStoppedAnimation(widget.score);
    }
  }

  @override
  void didUpdateWidget(BurnoutGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      if (widget.animate) {
        _animation = Tween(begin: oldWidget.score, end: widget.score).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );
        _controller.forward(from: 0);
      } else {
        // No animation — just snap to new value
        _animation = AlwaysStoppedAnimation(widget.score);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final score = _animation.value;
        final riskLevel = CheckInViewModel.riskLevel(score);
        final color = AppTheme.riskColor(riskLevel);
        final label = CheckInViewModel.riskLabel(riskLevel);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GaugePainter(
                    score: score, color: color,
                    bgColor: AppTheme.sl(context)),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    score.round().toString(),
                    style: TextStyle(
                      fontSize: widget.size * 0.22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.tp(context),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: widget.size * 0.07,
                      color: AppTheme.ts(context),
                      fontFamily: 'Poppins',
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

class _GaugePainter extends CustomPainter {
  final double score;
  final Color color;
  final Color bgColor;

  _GaugePainter({required this.score, required this.color, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const startAngle = 135 * pi / 180;
    const totalSweep = 270 * pi / 180;

    // Background arc
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      bgPaint,
    );

    // Score arc with gradient
    if (score > 0) {
      final scoreSweep = totalSweep * (score / 100);
      final scorePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + scoreSweep,
          colors: [AppTheme.riskLow, color],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        scoreSweep,
        false,
        scorePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.score != score || old.color != color || old.bgColor != bgColor;
}
