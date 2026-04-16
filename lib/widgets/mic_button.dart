import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';

/// A mic button that listens for speech and returns the result.
/// Use anywhere: chat input, check-in, nutrition.
class MicButton extends StatelessWidget {
  final void Function(String text) onResult;
  final double size;

  const MicButton({super.key, required this.onResult, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final voice = context.watch<VoiceService>();

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (voice.isListening) {
          voice.stopListening();
        } else {
          voice.startListening(onResult: onResult);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: voice.isListening
              ? AppTheme.riskCritical.withValues(alpha: 0.15)
              : AppTheme.accent.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: voice.isListening ? AppTheme.riskCritical : AppTheme.accent,
            width: voice.isListening ? 2 : 1,
          ),
        ),
        child: Icon(
          voice.isListening ? Icons.stop_rounded : Icons.mic_rounded,
          size: size * 0.5,
          color: voice.isListening ? AppTheme.riskCritical : AppTheme.accent,
        ),
      ),
    );
  }
}

/// A listening overlay that shows partial speech results.
class VoiceListeningOverlay extends StatelessWidget {
  const VoiceListeningOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final voice = context.watch<VoiceService>();
    if (!voice.isListening) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.riskCritical.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.riskCritical.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _PulsingDot(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              voice.partialResult.isNotEmpty
                  ? voice.partialResult
                  : 'Listening...',
              style: TextStyle(
                fontSize: 13,
                color: voice.partialResult.isNotEmpty
                    ? AppTheme.textPrimary
                    : AppTheme.textHint,
                fontStyle: voice.partialResult.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => voice.cancel(),
            child: const Icon(Icons.close, size: 16, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_controller),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppTheme.riskCritical,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
