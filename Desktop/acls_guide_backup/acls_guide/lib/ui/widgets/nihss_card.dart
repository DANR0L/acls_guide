import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/algorithm_provider.dart';

// ─────────────────────────────────────────────────────────
//  Modelo de item NIHSS
// ─────────────────────────────────────────────────────────
class _NihssItem {
  final String code;
  final String title;
  final String instruction;
  final List<String> scoreLabels; // index = pontuação
  const _NihssItem({
    required this.code,
    required this.title,
    required this.instruction,
    required this.scoreLabels,
  });
}

const _nihssItems = [
  _NihssItem(
    code: '1a',
    title: 'Nível de Consciência (LOC)',
    instruction: 'Observe a responsividade geral do paciente.',
    scoreLabels: [
      '0 — Alerta; vivo e responsivo',
      '1 — Desperta a estímulo mínimo (voz/toque)',
      '2 — Requer estímulo repetido ou doloroso',
      '3 — Sem resposta ou apenas reflexos (coma)',
    ],
  ),
  _NihssItem(
    code: '1b',
    title: 'Perguntas de Orientação',
    instruction: '"Que mês é este?" e "Quantos anos você tem?" — aceite só a 1ª resposta.',
    scoreLabels: [
      '0 — Responde AMBAS corretamente',
      '1 — Responde UMA corretamente',
      '2 — Nenhuma correta (afásico, intubado)',
    ],
  ),
  _NihssItem(
    code: '1c',
    title: 'Obedece a Comandos',
    instruction: '"Abra/feche os olhos" e "Abra/feche a mão" (mão não parética).',
    scoreLabels: [
      '0 — Realiza AMBOS corretamente',
      '1 — Realiza APENAS UM',
      '2 — Não realiza nenhum',
    ],
  ),
  _NihssItem(
    code: '2',
    title: 'Olhar Conjugado Horizontal',
    instruction: 'Observe movimentos oculares horizontais voluntários. Nistagmo puro = 0.',
    scoreLabels: [
      '0 — Normal',
      '1 — Paresia parcial (vencível pela manobra oculocefálica)',
      '2 — Desvio forçado, não vencível',
    ],
  ),
  _NihssItem(
    code: '3',
    title: 'Campos Visuais',
    instruction: 'Confrontação — dedos nos 4 quadrantes de cada olho.',
    scoreLabels: [
      '0 — Sem perda visual',
      '1 — Hemianopsia parcial ou extinção visual',
      '2 — Hemianopsia completa',
      '3 — Hemianopsia bilateral (cegueira cortical)',
    ],
  ),
  _NihssItem(
    code: '4',
    title: 'Paresia Facial',
    instruction: 'Mostre os dentes, levante as sobrancelhas, feche os olhos com força.',
    scoreLabels: [
      '0 — Movimentos normais e simétricos',
      '1 — Paresia leve (sulco nasolabial, sorriso assimétrico)',
      '2 — Paralisia parcial — porção inferior apenas',
      '3 — Paralisia completa — superior + inferior',
    ],
  ),
  _NihssItem(
    code: '5a',
    title: 'Motor Braço Direito (MSD)',
    instruction: 'Elevar a 90° (sentado) ou 45° (deitado) — manter 10 segundos.',
    scoreLabels: [
      '0 — Sem queda em 10 seg',
      '1 — Queda antes de 10 seg, não toca a cama',
      '2 — Algum esforço anti-gravitacional, toca a cama',
      '3 — Sem esforço contra a gravidade',
      '4 — Sem movimento algum',
    ],
  ),
  _NihssItem(
    code: '5b',
    title: 'Motor Braço Esquerdo (MSE)',
    instruction: 'Elevar a 90° (sentado) ou 45° (deitado) — manter 10 segundos.',
    scoreLabels: [
      '0 — Sem queda em 10 seg',
      '1 — Queda antes de 10 seg, não toca a cama',
      '2 — Algum esforço anti-gravitacional, toca a cama',
      '3 — Sem esforço contra a gravidade',
      '4 — Sem movimento algum',
    ],
  ),
  _NihssItem(
    code: '6a',
    title: 'Motor Perna Direita (MID)',
    instruction: 'Paciente deitado: elevar a 30° — manter 5 segundos.',
    scoreLabels: [
      '0 — Sem queda em 5 seg',
      '1 — Queda antes de 5 seg, não toca a cama',
      '2 — Algum esforço anti-gravitacional, toca a cama',
      '3 — Sem esforço contra a gravidade',
      '4 — Sem movimento algum',
    ],
  ),
  _NihssItem(
    code: '6b',
    title: 'Motor Perna Esquerda (MIE)',
    instruction: 'Paciente deitado: elevar a 30° — manter 5 segundos.',
    scoreLabels: [
      '0 — Sem queda em 5 seg',
      '1 — Queda antes de 5 seg, não toca a cama',
      '2 — Algum esforço anti-gravitacional, toca a cama',
      '3 — Sem esforço contra a gravidade',
      '4 — Sem movimento algum',
    ],
  ),
  _NihssItem(
    code: '7',
    title: 'Ataxia de Membros',
    instruction: 'Índex-nariz e calcanhar-joelho (olhos fechados). Zero se parético ou em coma.',
    scoreLabels: [
      '0 — Ausente',
      '1 — Presente em 1 membro',
      '2 — Presente em 2 ou mais membros',
    ],
  ),
  _NihssItem(
    code: '8',
    title: 'Sensibilidade',
    instruction: 'Alfinete ou beliscão — compare hemicorpos. Pontue 2 só se bilateral.',
    scoreLabels: [
      '0 — Normal — sem perda sensorial',
      '1 — Perda leve a moderada (sente, mas menos aguçado)',
      '2 — Perda grave ou total',
    ],
  ),
  _NihssItem(
    code: '9',
    title: 'Linguagem / Afasia',
    instruction: 'Nomeação de objetos + leitura de frases + descrição de figura padrão.',
    scoreLabels: [
      '0 — Normal',
      '1 — Afasia leve a moderada',
      '2 — Afasia grave (fragmentada, inferência necessária)',
      '3 — Mutismo ou afasia global',
    ],
  ),
  _NihssItem(
    code: '10',
    title: 'Disartria',
    instruction: 'Repetir palavras padrão. Apenas articulação — não pontuação de afasia aqui.',
    scoreLabels: [
      '0 — Normal',
      '1 — Leve a moderada: arrastado, compreensível',
      '2 — Grave: ininteligível ou anártrico',
    ],
  ),
  _NihssItem(
    code: '11',
    title: 'Extinção e Negligência',
    instruction: 'Estimulação simultânea bilateral (visual, cutânea). Toque ambas as mãos ao mesmo tempo.',
    scoreLabels: [
      '0 — Sem anormalidade',
      '1 — Extinção em 1 modalidade',
      '2 — Heminegligência grave ou anosognosia',
    ],
  ),
];

// ─────────────────────────────────────────────────────────
//  NihssCard — Widget principal
// ─────────────────────────────────────────────────────────
class NihssCard extends ConsumerStatefulWidget {
  final String nextNodeId;
  final void Function(String nextNodeId, int totalScore) onComplete;
  final bool isStudyMode;

  const NihssCard({
    super.key,
    required this.nextNodeId,
    required this.onComplete,
    this.isStudyMode = false,
  });

  @override
  ConsumerState<NihssCard> createState() => _NihssCardState();
}

class _NihssCardState extends ConsumerState<NihssCard> {
  int get _total => ref.read(nihssScoresProvider).fold(0, (sum, s) => sum + (s ?? 0));
  int get _answered => ref.read(nihssScoresProvider).where((s) => s != null).length;
  bool get _allAnswered => _answered == _nihssItems.length;

  String get _severity {
    if (!_allAnswered) return '—';
    final t = _total;
    if (t == 0) return 'Sem déficit';
    if (t <= 4) return 'Leve';
    if (t <= 15) return 'Moderado';
    if (t <= 20) return 'Moderado-Grave';
    return 'Grave';
  }

  Color get _severityColor {
    if (!_allAnswered) return AppColors.textSecondary;
    final t = _total;
    if (t == 0) return AppColors.secondary;
    if (t <= 4) return AppColors.info;
    if (t <= 15) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final _scores = ref.watch(nihssScoresProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Painel de Total Fixo ───────────────────────────────
        _TotalPanel(
          total: _total,
          answered: _answered,
          total_items: _nihssItems.length,
          severity: _severity,
          severityColor: _severityColor,
          allAnswered: _allAnswered,
        ),
        const SizedBox(height: 16),

        // ── Itens NIHSS ───────────────────────────────────────
        ..._nihssItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _NihssItemCard(
            item: item,
            selectedScore: _scores[index],
            onScoreSelected: (score) {
              HapticFeedback.selectionClick();
              final currentList = [...ref.read(nihssScoresProvider)];
              currentList[index] = score;
              ref.read(nihssScoresProvider.notifier).state = currentList;
            },
          );
        }),

        const SizedBox(height: 24),

        // ── Resumo Final ──────────────────────────────────────
        if (_allAnswered) _SummaryCard(
          total: _total,
          severity: _severity,
          severityColor: _severityColor,
          isStudyMode: widget.isStudyMode,
          onSimulateScore: (score) {
            HapticFeedback.mediumImpact();
            widget.onComplete(widget.nextNodeId, score);
          },
        ),
        const SizedBox(height: 16),

        // ── Botão Prosseguir ──────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _allAnswered
                ? () {
                    HapticFeedback.mediumImpact();
                    widget.onComplete(widget.nextNodeId, _total);
                  }
                : null,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              _allAnswered
                  ? 'Prosseguir — NIHSS $_total pts'
                  : 'Pontue todos os ${_nihssItems.length - _answered} itens restantes',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _allAnswered ? AppColors.danger : AppColors.surfaceVariant,
              foregroundColor: _allAnswered ? Colors.white : AppColors.textSecondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (!_allAnswered)
          Center(
            child: Text(
              '${_answered} de ${_nihssItems.length} itens pontuados',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Painel de Total
// ─────────────────────────────────────────────────────────
class _TotalPanel extends StatelessWidget {
  final int total;
  final int answered;
  final int total_items;
  final String severity;
  final Color severityColor;
  final bool allAnswered;

  const _TotalPanel({
    required this.total,
    required this.answered,
    required this.total_items,
    required this.severity,
    required this.severityColor,
    required this.allAnswered,
  });

  @override
  Widget build(BuildContext context) {
    final progress = answered / total_items;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surfaceVariant,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Score círculo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: severityColor.withOpacity(0.12),
                  border: Border.all(color: severityColor, width: 2.5),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$total',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: severityColor,
                        ),
                      ),
                      Text(
                        '/42',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PONTUAÇÃO NIHSS',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      severity,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: severityColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.border,
                        color: AppColors.primary,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$answered de $total_items itens pontuados',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Card de um item NIHSS
// ─────────────────────────────────────────────────────────
class _NihssItemCard extends StatelessWidget {
  final _NihssItem item;
  final int? selectedScore;
  final void Function(int score) onScoreSelected;

  const _NihssItemCard({
    required this.item,
    required this.selectedScore,
    required this.onScoreSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isScored = selectedScore != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isScored
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isScored ? AppColors.primary.withOpacity(0.4) : AppColors.border,
          width: isScored ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do item
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isScored
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Item ${item.code}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isScored ? AppColors.primary : AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isScored)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$selectedScore pt${selectedScore != 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Instrução
          Text(
            item.instruction,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // Botões de score
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.scoreLabels.asMap().entries.map((entry) {
              final score = entry.key;
              final label = entry.value;
              final isSelected = selectedScore == score;
              return _ScoreButton(
                score: score,
                label: label,
                isSelected: isSelected,
                onTap: () => onScoreSelected(score),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Botão de score individual
// ─────────────────────────────────────────────────────────
class _ScoreButton extends StatelessWidget {
  final int score;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScoreButton({
    required this.score,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  Color get _scoreColor {
    if (score == 0) return AppColors.secondary;
    if (score == 1) return AppColors.info;
    if (score == 2) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _scoreColor : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _scoreColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge numérico
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.25) : _scoreColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$score',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : _scoreColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label.replaceFirst(RegExp(r'^\d+ — '), ''),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Card de resumo final
// ─────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final int total;
  final String severity;
  final Color severityColor;
  final bool isStudyMode;
  final void Function(int simulatedScore)? onSimulateScore;

  const _SummaryCard({
    required this.total,
    required this.severity,
    required this.severityColor,
    this.isStudyMode = false,
    this.onSimulateScore,
  });

  String get _recommendation {
    if (total == 0) return 'AVC improvável ou TIA. Avalie TC e investigue.';
    if (total <= 4) return 'AVC leve. Avaliar elegibilidade para alteplase e trombectomia.';
    if (total <= 15) return 'AVC moderado. Candidato preferencial para terapia de reperfusão.';
    if (total <= 20) return 'AVC moderado-grave. Alta prioridade para reperfusão urgente.';
    return 'AVC grave. Reperfusão urgente se elegível. Monitorização intensiva.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: severityColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: severityColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'NIHSS CONCLUÍDO',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: severityColor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$total pontos',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: severityColor,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  severity,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _recommendation,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (isStudyMode) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Valores de Referência:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _ReferenceRow(label: '0', desc: 'Sem déficit / TIA', color: AppColors.secondary, isHighlighted: total == 0, onTap: () => onSimulateScore?.call(0)),
            _ReferenceRow(label: '1–4', desc: 'AVC leve', color: AppColors.info, isHighlighted: total >= 1 && total <= 4, onTap: () => onSimulateScore?.call(2)),
            _ReferenceRow(label: '5–15', desc: 'AVC moderado', color: AppColors.warning, isHighlighted: total >= 5 && total <= 15, onTap: () => onSimulateScore?.call(10)),
            _ReferenceRow(label: '16–20', desc: 'AVC moderado-grave', color: AppColors.danger, isHighlighted: total >= 16 && total <= 20, onTap: () => onSimulateScore?.call(18)),
            _ReferenceRow(label: '21–42', desc: 'AVC grave', color: AppColors.danger, isHighlighted: total >= 21, onTap: () => onSimulateScore?.call(25)),
          ],
        ],
      ),
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  final String label;
  final String desc;
  final Color color;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const _ReferenceRow({
    required this.label,
    required this.desc,
    required this.color,
    required this.isHighlighted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isHighlighted ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isHighlighted ? 8 : 4, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: isHighlighted ? Border.all(color: color.withOpacity(0.3)) : null,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 45,
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
                      color: isHighlighted ? color : AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
                      color: isHighlighted ? color : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: isHighlighted ? color : AppColors.textSecondary.withOpacity(0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
