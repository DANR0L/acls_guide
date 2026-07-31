import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cpr_dynamic_provider.dart';
import '../../services/pdf_export_service.dart';

class CprDashboardScreen extends ConsumerStatefulWidget {
  const CprDashboardScreen({super.key});

  @override
  ConsumerState<CprDashboardScreen> createState() => _CprDashboardScreenState();
}

class _CprDashboardScreenState extends ConsumerState<CprDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(cprDynamicProvider);
      if (!state.isRunning && !state.isRosc) {
        ref.read(cprDynamicProvider.notifier).start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cprDynamicProvider);
    final notifier = ref.read(cprDynamicProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PCR — Dinâmico',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '🚨 Emergência',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.danger,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Ask for confirmation to prevent accidental resets
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Novo Caso'),
                  content: const Text('Deseja descartar o log atual e iniciar uma nova RCP?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        notifier.reset();
                        Navigator.pop(ctx); // fecha o alert dialog
                        context.pop();      // volta pra tela inicial (go_router pop)
                      },
                      child: const Text('Sim', style: TextStyle(color: AppColors.danger)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Novo Caso'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
      body: !state.isRunning && !state.isRosc && !state.isTor && state.tachycardiaRhythm == null
          ? _buildStartScreen(notifier)
          : _buildDashboard(context, state, notifier),
    );
  }

  Widget _buildStartScreen(CprDynamicNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_rounded, size: 80, color: AppColors.danger),
          const SizedBox(height: 24),
          Text(
            'Parada Cardiorrespiratória',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Aperte o botão abaixo no exato momento em que identificar a parada para registrar o horário real.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              notifier.start();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
            ),
            child: Text(
              'INICIAR CÓDIGO AGORA',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, CprDynamicState state, CprDynamicNotifier notifier) {
    return Column(
      children: [
        // ── Topo: Tempos ──
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tempo Total', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                      Text(
                        state.formatTime(state.elapsedSeconds),
                        style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -1),
                      ),
                      if (state.startTime != null)
                        Text(
                          'Início: ${state.startTime!.hour.toString().padLeft(2, '0')}:${state.startTime!.minute.toString().padLeft(2, '0')}:${state.startTime!.second.toString().padLeft(2, '0')}',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                  Container(width: 1, height: 60, color: AppColors.border),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Próxima Checagem', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                      Text(
                        state.formatTime(state.cycleSecondsRemaining),
                        style: GoogleFonts.inter(
                          fontSize: 36, 
                          fontWeight: FontWeight.w900, 
                          color: state.cycleSecondsRemaining <= 10 ? AppColors.danger : AppColors.primary, 
                          letterSpacing: -1
                        ),
                      ),
                      Text(
                        'Ciclo CPR',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Sugestão Ativa
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates_rounded, color: AppColors.warning, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSuggestionText(context, state.suggestion),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Botões de Ação ──
        if (!state.isRosc && state.tachycardiaRhythm == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'VF / pVT',
                        icon: Icons.monitor_heart_rounded,
                        color: AppColors.danger,
                        pulsing: state.pulsingButtons.contains('rhythm'),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          notifier.registerRhythm(true);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Asistolia / AESP',
                        icon: Icons.show_chart_rounded,
                        color: AppColors.warning,
                        pulsing: state.pulsingButtons.contains('rhythm'),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          notifier.registerRhythm(false);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: '⚡ Choque (120-200 J)',
                        icon: Icons.flash_on_rounded,
                        color: AppColors.shock,
                        disabled: state.isShockableRhythm != true,
                        pulsing: state.pulsingButtons.contains('shock'),
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          notifier.registerShock();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionBtn(
                        label: state.epiButtonLabel,
                        icon: Icons.vaccines_rounded,
                        color: AppColors.secondary,
                        disabled: state.isEpiDisabled,
                        pulsing: state.pulsingButtons.contains('epi'),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          notifier.registerEpi();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: '💊 Amiodarona/Lido',
                        icon: Icons.medication_rounded,
                        color: const Color(0xFFA855F7),
                        disabled: state.isAmioDisabled,
                        pulsing: state.pulsingButtons.contains('amio'),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          notifier.registerAmioLido();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionBtn(
                        label: '💊 Outras Drogas',
                        icon: Icons.local_pharmacy_rounded,
                        color: const Color(0xFF0EA5E9),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _showOtherDrugsModal(context, notifier);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: '🌬️ Via Aérea',
                        icon: Icons.air_rounded,
                        color: const Color(0xFF14B8A6),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _showAirwayModal(context, notifier);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionBtn(
                        label: '✅ ROSC',
                        icon: Icons.favorite_rounded,
                        color: AppColors.info,
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          notifier.registerRosc();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: '🛑 TOR',
                        icon: Icons.cancel_rounded,
                        color: AppColors.textSecondary,
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          notifier.registerTor();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionBtn(
                        label: '📈 Taquicardia',
                        icon: Icons.trending_up_rounded,
                        color: const Color(0xFFF97316),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _showTachycardiaModal(context, notifier);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
        if (state.tachycardiaRhythm != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // ── Cardioversão com energia correta por ritmo ──
                _ActionBtn(
                  label: state.tachycardiaRhythm == 'Polimórfica'
                      ? '⚡ Desfibrila (200 J)'
                      : state.tachycardiaRhythm == 'FA / Flutter'
                          ? '⚡ Cardiov. FA (120-200 J)'
                          : state.tachycardiaRhythm == 'Monomórfica'
                              ? '⚡ Cardiov. TV (100 J)'
                              : '⚡ Cardiov. TSV (50-100 J)',
                  icon: Icons.flash_on_rounded,
                  color: AppColors.danger,
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    notifier.registerCardioversion();
                  },
                ),

                // ── Adenosina: apenas para TSV ──
                if (state.tachycardiaRhythm == 'TSV') ...[
                  _ActionBtn(
                    label: '💉 Adenosina 6mg IV',
                    icon: Icons.vaccines_rounded,
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerAdenosine('6mg');
                    },
                  ),
                  _ActionBtn(
                    label: '💉 Adenosina 12mg IV',
                    icon: Icons.vaccines_rounded,
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerAdenosine('12mg');
                    },
                  ),
                  _ActionBtn(
                    label: '💊 Metoprolol 2,5mg IV',
                    icon: Icons.medication_rounded,
                    color: AppColors.warning,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerDrug('Metoprolol 2,5mg IV lento');
                    },
                  ),
                  _ActionBtn(
                    label: '💊 Diltiazem 0,25mg/kg',
                    icon: Icons.medication_rounded,
                    color: AppColors.warning,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerDrug('Diltiazem 0,25mg/kg IV lento');
                    },
                  ),
                ],

                // ── Drogas para FA / Flutter ──
                if (state.tachycardiaRhythm == 'FA / Flutter') ...[
                  _ActionBtn(
                    label: '💊 Metoprolol 5mg IV',
                    icon: Icons.medication_rounded,
                    color: AppColors.warning,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerDrug('Metoprolol 5mg IV lento');
                    },
                  ),
                  _ActionBtn(
                    label: '💊 Diltiazem 0,25mg/kg',
                    icon: Icons.medication_rounded,
                    color: AppColors.warning,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerDrug('Diltiazem 0,25mg/kg IV (15 min)');
                    },
                  ),
                  _ActionBtn(
                    label: '💊 Amiodarona 150mg/10min',
                    icon: Icons.medication_rounded,
                    color: const Color(0xFFA855F7),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerDrug('Amiodarona 150mg IV em 10min');
                    },
                  ),
                ],

                // ── Drogas para TV Monomórfica ──
                if (state.tachycardiaRhythm == 'Monomórfica') ...[
                  _ActionBtn(
                    label: '💊 Amiodarona 150mg/10min',
                    icon: Icons.medication_rounded,
                    color: const Color(0xFFA855F7),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerDrug('Amiodarona 150mg IV em 10min');
                    },
                  ),
                  _ActionBtn(
                    label: '💊 Procainamida 20-50mg/min',
                    icon: Icons.medication_rounded,
                    color: AppColors.warning,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerDrug('Procainamida 20-50mg/min IV (máx 17mg/kg)');
                    },
                  ),
                  _ActionBtn(
                    label: '💊 Sotalol 100mg IV/5min',
                    icon: Icons.medication_rounded,
                    color: AppColors.warning,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerDrug('Sotalol 100mg (1,5mg/kg) IV em 5min');
                    },
                  ),
                ],

                // ── Drogas para TV Polimórfica / Torsades ──
                if (state.tachycardiaRhythm == 'Polimórfica') ...[
                  _ActionBtn(
                    label: '💉 MgSO₄ 2g IV/15min',
                    icon: Icons.vaccines_rounded,
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerDrug('Sulfato de Magnésio 2g IV em 15min (Torsades)');
                    },
                  ),
                  _ActionBtn(
                    label: '💊 Lidocaína 1mg/kg IV',
                    icon: Icons.medication_rounded,
                    color: AppColors.warning,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerDrug('Lidocaína 1-1,5mg/kg IV bolus');
                    },
                  ),
                  _ActionBtn(
                    label: '💊 Isoproterenol 2-10mcg/min',
                    icon: Icons.medication_rounded,
                    color: AppColors.warning,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.registerDrug('Isoproterenol 2-10mcg/min IV (TV recorrente)');
                    },
                  ),
                ],

                // ── Ações comuns ──
                _ActionBtn(
                  label: '⬅️ Voltar PCR',
                  icon: Icons.arrow_back_rounded,
                  color: AppColors.textSecondary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    notifier.start();
                  },
                ),
                _ActionBtn(
                  label: '✅ Exportar (PDF)',
                  icon: Icons.picture_as_pdf_rounded,
                  color: AppColors.info,
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    PdfExportService.exportCprLog(
                      state,
                      onError: (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro: $error'), backgroundColor: AppColors.danger),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        
        if (state.isRosc || state.isTor)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () async {
                HapticFeedback.heavyImpact();
                await PdfExportService.exportCprLog(
                  state,
                  onError: (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao exportar PDF: $error'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  },
                );
              },
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: Text(
                'EXPORTAR RELATÓRIO PDF',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

        const SizedBox(height: 16),
        const Divider(height: 1),

        // ── Log Histórico ──
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: state.logs.length,
            itemBuilder: (context, index) {
              final log = state.logs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.timeText,
                      style: GoogleFonts.robotoMono(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        log.message,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: log.isAlert ? FontWeight.w700 : FontWeight.w500,
                          color: _hexToColor(log.colorHex),
                        ),
                      ),
                    ),
                    Text(
                      '${log.realTime.hour.toString().padLeft(2, '0')}:${log.realTime.minute.toString().padLeft(2, '0')}:${log.realTime.second.toString().padLeft(2, '0')}',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionText(BuildContext context, String text) {
    if (!text.contains('5H e 5T')) {
      return Text(
        text,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      );
    }
    
    final parts = text.split('5H e 5T');
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: '5H e 5T',
            style: const TextStyle(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = () {
              HapticFeedback.mediumImpact();
              _show5Hs5TsModal(context);
            },
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }

  void _show5Hs5TsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Causas Reversíveis (5H / 5T)',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('🅗 Hipovolemia → SF/RL IV rápido', style: GoogleFonts.inter(fontSize: 14)),
              const Divider(),
              Text('🅗 Hipóxia → Ventilar, IOT, O₂ 100%', style: GoogleFonts.inter(fontSize: 14)),
              const Divider(),
              Text('🅗 Hidrogênio (acidose) → Bicarbonato se pH < 7,1', style: GoogleFonts.inter(fontSize: 14)),
              const Divider(),
              Text('🅗 Hipo/Hipercalemia → ECG, corrigir K⁺', style: GoogleFonts.inter(fontSize: 14)),
              const Divider(),
              Text('🅗 Hipotermia → Reaquecimento ativo', style: GoogleFonts.inter(fontSize: 14)),
              const Divider(),
              Text('🅣 Tensão (pneumotórax) → Descompressão agulha', style: GoogleFonts.inter(fontSize: 14)),
              const Divider(),
              Text('🅣 Tamponamento → Pericardiocentese', style: GoogleFonts.inter(fontSize: 14)),
              const Divider(),
              Text('🅣 Toxinas → Naloxona, flumazenil, etc', style: GoogleFonts.inter(fontSize: 14)),
              const Divider(),
              Text('🅣 Trombose coronária (IAM) → ICP emergência', style: GoogleFonts.inter(fontSize: 14)),
              const Divider(),
              Text('🅣 Trombose pulmonar (TEP) → Trombólise', style: GoogleFonts.inter(fontSize: 14)),
            ],
          ),
        );
      },
    );
  }

  void _showTachycardiaModal(BuildContext context, CprDynamicNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecione o Ritmo da Taquicardia',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Fibrilação Atrial / Flutter Atrial'),
                leading: const Icon(Icons.show_chart_rounded, color: AppColors.warning),
                onTap: () {
                  notifier.registerTachycardia('FA / Flutter');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Taquicardia Supraventricular (TSV)'),
                leading: const Icon(Icons.trending_up_rounded, color: AppColors.danger),
                onTap: () {
                  notifier.registerTachycardia('TSV');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('TV Monomórfica (com pulso)'),
                leading: const Icon(Icons.monitor_heart_rounded, color: Color(0xFFA855F7)),
                onTap: () {
                  notifier.registerTachycardia('Monomórfica');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('TV Polimórfica (Torsades)'),
                leading: const Icon(Icons.polyline_rounded, color: AppColors.danger),
                onTap: () {
                  notifier.registerTachycardia('Polimórfica');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

    void _showOtherDrugsModal(BuildContext context, CprDynamicNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _AdvancedDrugsModal(notifier: notifier),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class _ActionBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool disabled;
  final bool pulsing;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.disabled = false,
    this.pulsing = false,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.pulsing) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_ActionBtn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulsing && !oldWidget.pulsing) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulsing && oldWidget.pulsing) {
      _controller.stop();
      _controller.value = 0;
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
      animation: _blinkAnimation,
      builder: (context, child) {
        final opacity = widget.pulsing ? _blinkAnimation.value : 1.0;
        return Opacity(
          opacity: opacity,
          child: Material(
            color: widget.disabled
                ? AppColors.surfaceVariant
                : widget.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: widget.disabled ? null : widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.disabled
                        ? Colors.transparent
                        : widget.color.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, size: 18,
                        color: widget.disabled ? AppColors.textMuted : widget.color),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: widget.disabled ? AppColors.textMuted : widget.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
class _AdvancedDrugsModal extends StatefulWidget {
  final CprDynamicNotifier notifier;
  const _AdvancedDrugsModal({required this.notifier});

  @override
  State<_AdvancedDrugsModal> createState() => _AdvancedDrugsModalState();
}

class _AdvancedDrugsModalState extends State<_AdvancedDrugsModal> {
  final TextEditingController _customDrugCtrl = TextEditingController();
  final TextEditingController _customDoseCtrl = TextEditingController();

  final List<Map<String, dynamic>> _drugs = [
    {'name': 'Bicarbonato 8,4%', 'sug': '1 mEq/kg', 'icon': Icons.medication_liquid_rounded, 'color': AppColors.info},
    {'name': 'Gluconato Cálcio 10%', 'sug': '15-30 mL', 'icon': Icons.medication_liquid_rounded, 'color': AppColors.info},
    {'name': 'Cloreto Cálcio 10%', 'sug': '5-10 mL', 'icon': Icons.medication_liquid_rounded, 'color': AppColors.info},
    {'name': 'Sulfato Magnésio 10%', 'sug': '1-2 g', 'icon': Icons.medication_liquid_rounded, 'color': AppColors.info},
    {'name': 'Insulina Regular', 'sug': '10 UI', 'icon': Icons.vaccines_rounded, 'color': AppColors.warning},
    {'name': 'KCl (Cloreto Potássio)', 'sug': '10-20 mEq/h', 'icon': Icons.medication_liquid_rounded, 'color': AppColors.danger},
    {'name': 'SF 0.9%', 'sug': '500-1000 mL', 'icon': Icons.water_drop_rounded, 'color': AppColors.info},
    {'name': 'Ringer Lactato', 'sug': '500-1000 mL', 'icon': Icons.water_drop_rounded, 'color': AppColors.info},
    {'name': 'Plasma-Lyte', 'sug': '500-1000 mL', 'icon': Icons.water_drop_rounded, 'color': AppColors.info},
    {'name': 'Glicose 50%', 'sug': '20-50 mL', 'icon': Icons.medication_liquid_rounded, 'color': AppColors.info},
    {'name': 'Naloxona (Narcan)', 'sug': '0,4-2 mg', 'icon': Icons.vaccines_rounded, 'color': AppColors.warning},
  ];

  late List<TextEditingController> _doseCtrls;

  @override
  void initState() {
    super.initState();
    _doseCtrls = List.generate(_drugs.length, (index) => TextEditingController());
  }

  @override
  void dispose() {
    _customDrugCtrl.dispose();
    _customDoseCtrl.dispose();
    for (var ctrl in _doseCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Administrar Drogas',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              
              // Custom Drug Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _customDrugCtrl,
                        decoration: InputDecoration(
                          hintText: 'Droga Customizada',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _customDoseCtrl,
                        decoration: InputDecoration(
                          hintText: 'Dose',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 32),
                      onPressed: () {
                        if (_customDrugCtrl.text.isNotEmpty) {
                          String dose = _customDoseCtrl.text.isNotEmpty ? ' (Dose: ${_customDoseCtrl.text})' : '';
                          widget.notifier.registerDrug('${_customDrugCtrl.text}$dose');
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              
              // Predefined Drugs List
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _drugs.length,
                  itemBuilder: (ctx, i) {
                    final drug = _drugs[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(drug['icon'] as IconData, color: drug['color'] as Color),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  drug['name'] as String,
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                                Text(
                                  'Sugestão: ${drug['sug']}',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _doseCtrls[i],
                              decoration: InputDecoration(
                                hintText: 'Dose Real',
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                isDense: true,
                              ),
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                            onPressed: () {
                              String doseStr = _doseCtrls[i].text.trim();
                              String finalLog = doseStr.isNotEmpty
                                  ? '${drug['name']} (Dose administrada: $doseStr)'
                                  : '${drug['name']} (Dose sugerida: ${drug['sug']})';
                              
                              widget.notifier.registerDrug(finalLog);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showAirwayModal(BuildContext context, CprDynamicNotifier notifier) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.cardBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.air_rounded, color: Color(0xFF14B8A6), size: 28),
                const SizedBox(width: 12),
                Text(
                  'Manejo de Via Aérea',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                notifier.registerCustom('Via Aérea: Intubação Orotraqueal (TOT)', '#14B8A6');
                Navigator.pop(context);
              },
              icon: const Icon(Icons.medical_services_rounded),
              label: const Text('Intubação Orotraqueal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                notifier.registerCustom('Via Aérea: Máscara Laríngea', '#14B8A6');
                Navigator.pop(context);
              },
              icon: const Icon(Icons.masks_rounded),
              label: const Text('Máscara Laríngea'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );
}
