import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/algorithms.dart';
import '../../models/algorithm_node.dart';
import '../../providers/algorithm_provider.dart';
import '../widgets/drug_card.dart';
import '../widgets/timer_widget.dart';
import '../widgets/nihss_card.dart';
import '../widgets/node_action_card.dart';
import 'cpr_dashboard_screen.dart';

class AlgorithmScreen extends ConsumerStatefulWidget {
  final String algorithmId;
  const AlgorithmScreen({super.key, required this.algorithmId});

  @override
  ConsumerState<AlgorithmScreen> createState() => _AlgorithmScreenState();
}

class _AlgorithmScreenState extends ConsumerState<AlgorithmScreen> {
  Timer? _cprTicker;

  @override
  void dispose() {
    _cprTicker?.cancel();
    super.dispose();
  }

  void _startCprTicker() {
    _cprTicker?.cancel();
    _cprTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(cprTimerProvider.notifier).tick();
    });
  }

  void _handleOption(String nextNodeId) {
    HapticFeedback.lightImpact();

    // Handle special cross-algorithm navigation
    if (nextNodeId.startsWith('__goto_')) {
      final targetId = nextNodeId.replaceFirst('__goto_', '');
      final targetAlgo = allAlgorithms[targetId];
      if (targetAlgo != null) {
        ref
            .read(algorithmSessionProvider.notifier)
            .startSession(targetAlgo);
        context.pushReplacement('/algorithm/$targetId');
        return;
      }
    }

    ref.read(algorithmSessionProvider.notifier).goToNode(nextNodeId);

    // Se next node é timer E não está em modo estudo: iniciar automático
    final isStudyMode = ref.read(studyModeProvider);
    final algo = allAlgorithms[widget.algorithmId];
    final nextNode = algo?.nodes[nextNodeId];
    if (nextNode?.type == NodeType.timer && !isStudyMode) {
      final seconds = nextNode!.timerSeconds ?? 120;
      ref.read(cprTimerProvider.notifier).start(seconds);
      _startCprTicker();
    }
  }

  @override
  Widget build(BuildContext context) {
    final algorithm = allAlgorithms[widget.algorithmId];
    final session = ref.watch(algorithmSessionProvider);
    final currentNode = ref.watch(currentNodeProvider);
    final isStudyMode = ref.watch(studyModeProvider);

    if (algorithm == null || currentNode == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.algorithmId == 'cardiac_arrest' && !isStudyMode) {
      return const CprDashboardScreen();
    }

    final canGoBack = session?.history.isNotEmpty ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, ref, algorithm, canGoBack, isStudyMode),
      body: AnimatedSwitcher(
        duration: 350.ms,
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: KeyedSubtree(
          key: ValueKey(currentNode.id),
          child: _buildNodeContent(context, currentNode, algorithm, isStudyMode),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    Algorithm algorithm,
    bool canGoBack,
    bool isStudyMode,
  ) {
    final algoColor = _hexToColor(algorithm.color);
    final shockCount = ref.watch(shockCountProvider);
    
    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () {
          if (canGoBack) {
            HapticFeedback.selectionClick();
            ref.read(algorithmSessionProvider.notifier).goBack();
          } else {
            context.pop();
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            algorithm.title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              Text(
                algorithm.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: algoColor,
                ),
              ),
              const SizedBox(width: 8),
              // Badge do modo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isStudyMode
                      ? AppColors.info.withOpacity(0.2)
                      : AppColors.danger.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isStudyMode ? '📖 Estudo' : '🚨 Emergência',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isStudyMode ? AppColors.info : AppColors.danger,
                  ),
                ),
              ),
              if (shockCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '⚡ $shockCount',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            ref.read(algorithmSessionProvider.notifier).startSession(
                allAlgorithms[widget.algorithmId]!);
          },
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Reiniciar'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            textStyle: GoogleFonts.inter(fontSize: 12),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildNodeContent(
      BuildContext context, AlgorithmNode node, Algorithm algorithm, bool isStudyMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Progress indicator ───────────────────────────────
          _ProgressBreadcrumb(node: node),
          const SizedBox(height: 20),

          // ── Node Header ──────────────────────────────────────
          _NodeHeader(node: node),
          const SizedBox(height: 16),

          // ── Timer widget (for timer nodes) ─────────────────────
          if (node.type == NodeType.timer) ...[
            // Modo Estudo: mostrar card explicativo com opções
            if (isStudyMode)
              _StudyModeTimerCard(
                seconds: node.timerSeconds ?? 120,
                onStart: () {
                  ref.read(cprTimerProvider.notifier).start(node.timerSeconds ?? 120);
                  _startCprTicker();
                },
                onSkip: () {
                  if (node.nextNodeId != null) {
                    _handleOption(node.nextNodeId!);
                  }
                },
              ).animate().fadeIn(duration: 400.ms)
            else
              TimerWidget(
                seconds: node.timerSeconds ?? 120,
                onComplete: () {
                  if (node.nextNodeId != null) {
                    _handleOption(node.nextNodeId!);
                  }
                },
              ).animate().fadeIn(duration: 400.ms),
          ],

          // ── Drug card ────────────────────────────────────────
          if (node.drug != null) ...[
            DrugCard(drug: node.drug!),
            const SizedBox(height: 16),
          ],

          // ── Body text ────────────────────────────────────────
          if (node.body != null) ...[
            Text(
              node.body!,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Bullets ──────────────────────────────────────────
          if (node.bullets != null && node.bullets!.isNotEmpty)
            _BulletList(bullets: node.bullets!),

          const SizedBox(height: 24),

          // ── NIHSS interativo ──────────────────────────────────
          if (node.type == NodeType.nihss && node.nextNodeId != null)
            NihssCard(
              nextNodeId: node.nextNodeId!,
              isStudyMode: isStudyMode,
              onComplete: (nextId, score) => _handleOption(nextId),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

          // ── Action Button (for non-question nodes with nextNodeId)
          if (node.type != NodeType.question &&
              node.type != NodeType.end &&
              node.type != NodeType.timer &&
              node.type != NodeType.nihss &&
              node.nextNodeId != null)
            ElevatedButton.icon(
              onPressed: () => _handleOption(node.nextNodeId!),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Continuar'),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          // ── Options (for question nodes) ─────────────────────
          if (node.options != null) ...[
            ...node.options!.asMap().entries.map((entry) {
              final idx = entry.key;
              final option = entry.value;
              return _OptionButton(
                option: option,
                onTap: () => _handleOption(option.nextNodeId),
              )
                  .animate()
                  .fadeIn(
                      delay: Duration(milliseconds: 150 + idx * 80),
                      duration: 350.ms)
                  .slideX(
                      begin: 0.1,
                      end: 0,
                      delay: Duration(milliseconds: 150 + idx * 80),
                      duration: 350.ms,
                      curve: Curves.easeOutCubic);
            }),
          ],

          // ── End node ──────────────────────────────────────────
          if (node.type == NodeType.end) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Voltar ao Início'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Progress Breadcrumb ───────────────────────────────────────
class _ProgressBreadcrumb extends ConsumerWidget {
  final AlgorithmNode node;
  const _ProgressBreadcrumb({required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(algorithmSessionProvider);
    final steps = (session?.history.length ?? 0) + 1;

    return Row(
      children: [
        Icon(
          _iconForType(node.type),
          size: 14,
          color: _colorForAlert(node.alertLevel),
        ),
        const SizedBox(width: 6),
        Text(
          _labelForType(node.type),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _colorForAlert(node.alertLevel),
          ),
        ),
        const Spacer(),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Passo $steps',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconForType(NodeType type) {
    switch (type) {
      case NodeType.question:
        return Icons.help_outline_rounded;
      case NodeType.action:
        return Icons.flash_on_rounded;
      case NodeType.drug:
        return Icons.medication_rounded;
      case NodeType.timer:
        return Icons.timer_rounded;
      case NodeType.info:
        return Icons.info_outline_rounded;
      case NodeType.end:
        return Icons.flag_rounded;
      case NodeType.nihss:
        return Icons.assignment_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  String _labelForType(NodeType type) {
    switch (type) {
      case NodeType.question:
        return 'Avaliação Clínica';
      case NodeType.action:
        return 'Ação Imediata';
      case NodeType.drug:
        return 'Medicamento';
      case NodeType.timer:
        return 'Cronômetro';
      case NodeType.info:
        return 'Informação';
      case NodeType.end:
        return 'Conclusão';
      case NodeType.nihss:
        return 'Escala NIHSS';
      default:
        return 'Passo';
    }
  }

  Color _colorForAlert(String? alert) {
    switch (alert) {
      case 'danger':
        return AppColors.danger;
      case 'warning':
        return AppColors.warning;
      case 'success':
        return AppColors.secondary;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ── Node Header ───────────────────────────────────────────────
class _NodeHeader extends StatelessWidget {
  final AlgorithmNode node;
  const _NodeHeader({required this.node});

  @override
  Widget build(BuildContext context) {
    final alertColor = _colorForAlert(node.alertLevel);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: alertColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            node.title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          if (node.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              node.subtitle!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: alertColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _colorForAlert(String? alert) {
    switch (alert) {
      case 'danger':
        return AppColors.danger;
      case 'warning':
        return AppColors.warning;
      case 'success':
        return AppColors.secondary;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }
}

// ── Bullet List ───────────────────────────────────────────────
class _BulletList extends StatelessWidget {
  final List<String> bullets;
  const _BulletList({required this.bullets});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bullets
            .map((bullet) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          bullet,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── Option Button ─────────────────────────────────────────────
class _OptionButton extends StatelessWidget {
  final AlgorithmOption option;
  final VoidCallback onTap;

  const _OptionButton({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (option.sublabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        option.sublabel!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Study Mode Timer Card ─────────────────────────────────────
// Exibido no lugar do timer quando o app está em Modo Estudo.
// Permite iniciar o timer opcional ou pular direto para o próximo passo.
class _StudyModeTimerCard extends StatefulWidget {
  final int seconds;
  final VoidCallback onStart;
  final VoidCallback onSkip;

  const _StudyModeTimerCard({
    required this.seconds,
    required this.onStart,
    required this.onSkip,
  });

  @override
  State<_StudyModeTimerCard> createState() => _StudyModeTimerCardState();
}

class _StudyModeTimerCardState extends State<_StudyModeTimerCard> {
  bool _timerStarted = false;

  @override
  Widget build(BuildContext context) {
    final mins = widget.seconds ~/ 60;
    final secs = widget.seconds % 60;
    final timeLabel = mins > 0
        ? '${mins}min${secs > 0 ? " ${secs}s" : ""}'
        : '${secs}s';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.info.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Text(
                'Ciclo CPR — $timeLabel',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '📖 Modo Estudo',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Na prática clínica, realize $timeLabel de CPR contínua de alta qualidade antes de verificar o ritmo novamente.\n\nNo modo estudo você pode usar o timer ou avançar direto.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Buttons
          if (!_timerStarted) ...[
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _timerStarted = true);
                      widget.onStart();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.info.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded,
                              color: AppColors.info, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Usar Timer',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onSkip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.secondary.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.skip_next_rounded,
                              color: AppColors.secondary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Pular',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Timer iniciado — mostrar widget completo
            const _StudyTimerRunning(),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: widget.onSkip,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.secondary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.skip_next_rounded,
                          color: AppColors.secondary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Pular e continuar',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Mini display do timer quando iniciado manualmente no modo estudo
class _StudyTimerRunning extends ConsumerWidget {
  const _StudyTimerRunning();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(cprTimerProvider);
    final mins = timer.secondsRemaining ~/ 60;
    final secs = timer.secondsRemaining % 60;
    final isUrgent = timer.secondsRemaining <= 10;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: isUrgent ? AppColors.danger : AppColors.info,
            letterSpacing: -2,
          ),
        ),
      ],
    );
  }
}

Color _hexToColor(String hex) {
  final h = hex.replaceFirst('#', 'FF');
  return Color(int.parse(h, radix: 16));
}
