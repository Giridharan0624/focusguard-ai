import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../viewmodels/checkin_viewmodel.dart';
import '../widgets/mic_button.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatVM = context.read<ChatViewModel>();
      final checkinVM = context.read<CheckInViewModel>();
      final result = checkinVM.result;
      chatVM.initialize(
        currentScore: result?.score ?? 0,
        riskLevel: result?.riskLevel ?? 'unknown',
        todayInput: result != null ? checkinVM.buildCurrentInput() : null,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<ChatViewModel>().sendMessage(text);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ══ Header ══
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.card(context),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.outline(context)),
                      ),
                      child: Icon(Icons.arrow_back_rounded, size: 18,
                          color: AppTheme.tp(context)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 38, height: 38,
                    decoration: const BoxDecoration(
                        color: AppTheme.accent, shape: BoxShape.circle),
                    child: const Icon(Icons.psychology_rounded,
                        size: 20, color: AppTheme.onAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Wellness Coach',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('AI-powered · Online',
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ══ Messages ══
            Expanded(
              child: vm.messages.isEmpty
                  ? _EmptyState(onQuickTap: (text) {
                      _controller.text = text;
                      _send();
                    })
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      itemCount: vm.messages.length + (vm.isTyping ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == vm.messages.length && vm.isTyping) {
                          return const _TypingBubble();
                        }
                        final msg = vm.messages[i];
                        return _MessageBubble(text: msg.text, isUser: msg.isUser);
                      },
                    ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: VoiceListeningOverlay(),
            ),

            // ══ Input bar ══
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 16),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                border: Border(top: BorderSide(color: AppTheme.outline(context))),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.sl(context),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: const InputDecoration(
                            hintText: 'Ask something...',
                            border: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    MicButton(size: 40, onResult: (text) {
                      final cur = _controller.text;
                      _controller.text = cur.isEmpty ? text : '$cur $text';
                      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
                    }),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: vm.isTyping ? null : _send,
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                          color: AppTheme.accent, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_upward_rounded,
                            size: 18, color: AppTheme.onAccent),
                      ),
                    ),
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

class _EmptyState extends StatelessWidget {
  final void Function(String) onQuickTap;
  const _EmptyState({required this.onQuickTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    blurRadius: 20, spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.psychology_rounded,
                  size: 36, color: AppTheme.onAccent),
            ),
            const SizedBox(height: 20),
            const Text('AI Wellness Coach',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Ask anything about burnout, sleep, or wellness',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8, runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _QuickChip('Why is my score high?',
                    onTap: () => onQuickTap('Why is my burnout score high?')),
                _QuickChip('How to sleep better?',
                    onTap: () => onQuickTap('How can I improve my sleep?')),
                _QuickChip('Reduce screen time',
                    onTap: () => onQuickTap('Tips to reduce my screen time?')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _MessageBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.accent : AppTheme.sl(context),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 14, height: 1.4,
                color: isUser ? AppTheme.onAccent : AppTheme.tp(context))),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.sl(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: SizedBox(
          width: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [_Dot(delay: 0), _Dot(delay: 200), _Dot(delay: 400)],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_ctrl),
      child: Container(
        width: 7, height: 7,
        decoration: BoxDecoration(color: AppTheme.th(context), shape: BoxShape.circle),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 12, color: AppTheme.ts(context))),
      ),
    );
  }
}
