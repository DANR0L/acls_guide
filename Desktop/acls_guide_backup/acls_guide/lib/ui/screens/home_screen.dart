import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/algorithms.dart';
import '../../models/algorithm_node.dart';
import '../../providers/algorithm_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: const Text('🫀',
                              style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACLS Guide',
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Diretrizes AHA 2025',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => context.push('/about'),
                          icon: const Icon(Icons.info_outline_rounded,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ── Mode Toggle ────────────────────────────────
                    _ModeToggle(),
                    const SizedBox(height: 20),
                    // Disclaimer
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.danger.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.danger, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Apoio clínico — não substitui julgamento médico.',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Selecione o Algoritmo',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Algorithm Cards ──────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final algo = allAlgorithms.values.toList()[index];
                    return _AlgorithmCard(
                      algorithm: algo,
                      index: index,
                      onTap: () {
                        ref
                            .read(algorithmSessionProvider.notifier)
                            .startSession(algo);
                        context.push('/algorithm/${algo.id}');
                      },
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: index * 80),
                          duration: 400.ms,
                        ).slideY(
                          begin: 0.2,
                          end: 0,
                          delay: Duration(milliseconds: index * 80),
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                  childCount: allAlgorithms.length,
                ),
              ),
            ),

            // ── Quick Links ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ferramentas Rápidas',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _QuickActionCard(
                      icon: '💊',
                      label: 'Fármacos',
                      sublabel: 'Doses e vias',
                      color: AppColors.purple,
                      onTap: () => context.push('/drugs'),
                    ),
                    const SizedBox(height: 10),
                    _QuickActionCard(
                      icon: '📟',
                      label: 'Ritmos ECG',
                      sublabel: '7 taquicardias com traçado',
                      color: const Color(0xFF00C853),
                      onTap: () => context.push('/ecg-ritmos'),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

// ── Mode Toggle ───────────────────────────────────────────────
class _ModeToggle extends ConsumerWidget {
  const _ModeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStudy = ref.watch(studyModeProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Iniciar Código (PCR)
          Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(studyModeProvider.notifier).state = false;
                
                // Set the session target to cardiac_arrest
                final targetAlgo = allAlgorithms['cardiac_arrest'];
                if (targetAlgo != null) {
                  ref.read(algorithmSessionProvider.notifier).startSession(targetAlgo);
                  context.push('/algorithm/cardiac_arrest');
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isStudy ? AppColors.danger : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🚨',
                      style: TextStyle(fontSize: !isStudy ? 16 : 13),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Iniciar Código',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: !isStudy ? FontWeight.w800 : FontWeight.w600,
                        color: !isStudy ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Estudo
          Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(studyModeProvider.notifier).state = true;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isStudy ? AppColors.info : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '📖',
                      style: TextStyle(fontSize: isStudy ? 16 : 13),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Estudo',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isStudy ? FontWeight.w800 : FontWeight.w600,
                        color: isStudy ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Algorithm Card ─────────────────────────────────────────────
class _AlgorithmCard extends StatelessWidget {
  final Algorithm algorithm;
  final int index;
  final VoidCallback onTap;

  const _AlgorithmCard({
    required this.algorithm,
    required this.index,
    required this.onTap,
  });

  Color get _color {
    final hex = algorithm.color.replaceFirst('#', 'FF');
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: _color.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(algorithm.iconEmoji,
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
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
                    const SizedBox(height: 3),
                    Text(
                      algorithm.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: _color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick Action Card ──────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final String icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              sublabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


