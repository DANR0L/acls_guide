import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/algorithm_provider.dart';

class TimerWidget extends ConsumerStatefulWidget {
  final int seconds;
  final VoidCallback? onComplete;

  const TimerWidget({
    super.key,
    required this.seconds,
    this.onComplete,
  });

  @override
  ConsumerState<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ConsumerState<TimerWidget>
    with SingleTickerProviderStateMixin {
  Timer? _ticker;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Auto start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cprTimerProvider.notifier).start(widget.seconds);
      _startTicker();
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      ref.read(cprTimerProvider.notifier).tick();
      final timer = ref.read(cprTimerProvider);

      if (timer.secondsRemaining <= 10 && timer.secondsRemaining > 0) {
        HapticFeedback.selectionClick();
      }
      if (timer.isFinished) {
        HapticFeedback.heavyImpact();
        t.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(cprTimerProvider);
    final mins = timer.secondsRemaining ~/ 60;
    final secs = timer.secondsRemaining % 60;
    final isUrgent = timer.secondsRemaining <= 10 && timer.isRunning;
    final timerColor = isUrgent ? AppColors.danger : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: timerColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Icon(
                  Icons.timer_rounded,
                  color: timerColor.withOpacity(
                      timer.isRunning ? 0.5 + _pulseController.value * 0.5 : 1),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'CPR — ${widget.seconds == 120 ? '2 min' : '${widget.seconds}s'}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: timerColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
            style: GoogleFonts.inter(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: timerColor,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: timer.progress,
              backgroundColor: timerColor.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TimerButton(
                  label: 'Reiniciar',
                  icon: Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                  onTap: () {
                    ref.read(cprTimerProvider.notifier).reset();
                    _startTicker();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimerButton(
                  label: timer.isRunning ? 'Pausar' : 'Retomar',
                  icon: timer.isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: timerColor,
                  onTap: () {
                    if (timer.isRunning) {
                      _ticker?.cancel();
                      ref.read(cprTimerProvider.notifier).pause();
                    } else {
                      _startTicker();
                      ref.read(cprTimerProvider.notifier).resume();
                    }
                  },
                ),
              ),
            ],
          ),
          if (timer.isFinished) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.secondary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Ciclo completo! Verificar ritmo.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TimerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
