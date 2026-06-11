import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

// ──────────────────────────────────────────────────────────────────────────────
//  Calculadora de Doses Pediátricas — PALS / AHA 2020
//  Baseada nas Diretrizes de RCP Pediátrica da AHA 2020
// ──────────────────────────────────────────────────────────────────────────────

class PalsCalculatorScreen extends StatefulWidget {
  const PalsCalculatorScreen({super.key});

  @override
  State<PalsCalculatorScreen> createState() => _PalsCalculatorScreenState();
}

class _PalsCalculatorScreenState extends State<PalsCalculatorScreen> {
  double _weight = 20.0;
  final _weightController = TextEditingController(text: '20');
  bool _editingManually = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  // ── Cálculos PALS ─────────────────────────────────────────────────────────

  // Epinefrina 0,01 mg/kg IV/IO (max 1 mg)
  String get _epiDose {
    double d = _weight * 0.01;
    double dMax = d.clamp(0, 1.0);
    double vol = dMax / 0.1; // diluição 1:10.000 (0,1 mg/mL)
    return '${_fmt(dMax)} mg  (${_fmt(vol)} mL da solução 1:10.000)';
  }

  // Atropina 0,02 mg/kg IV/IO (min 0,1 mg — max 0,5 mg)
  String get _atropineDose {
    double d = (_weight * 0.02).clamp(0.1, 0.5);
    return '${_fmt(d)} mg IV/IO';
  }

  // Adenosina 0,1 mg/kg IV rápido (max 6 mg 1ª dose / 12 mg 2ª dose)
  String get _adenosineDose {
    double d1 = (_weight * 0.1).clamp(0, 6.0);
    double d2 = (_weight * 0.2).clamp(0, 12.0);
    return '${_fmt(d1)} mg (1ª) → ${_fmt(d2)} mg (2ª)\nIV push RÁPIDO + flush 20 mL SF';
  }

  // Amiodarona 5 mg/kg IV/IO (max 300 mg)
  String get _amiodaroneDose {
    double d = (_weight * 5).clamp(0, 300.0);
    return '${_fmtInt(d)} mg IV/IO em 20–60 min\n(PCR: bolus rápido)';
  }

  // Lidocaína 1 mg/kg IV/IO (max 100 mg)
  String get _lidocaineDose {
    double d = (_weight * 1).clamp(0, 100.0);
    return '${_fmtInt(d)} mg IV/IO bolus';
  }

  // Bicarbonato de sódio 1 mEq/kg IV
  String get _bicarbonateDose {
    double d = _weight * 1;
    double vol = d / 0.5; // NaHCO3 8,4% = 1 mEq/mL → diluir 1:1 = 0,5 mEq/mL
    return '${_fmtInt(d)} mEq IV lento\n(${_fmtInt(vol)} mL NaHCO₃ 8,4% diluído 1:1)';
  }

  // Glicose 0,5–1 g/kg IV (D10%: 5 mL/kg)
  String get _glucoseDose {
    double vol = _weight * 5;
    return '${_fmtInt(vol)} mL D10% IV\n(ou ${_fmtInt(_weight * 2)} mL D25% diluído)';
  }

  // Sulfato de Magnésio 25–50 mg/kg IV (max 2 g) — Torsades
  String get _magnesiumDose {
    double d = (_weight * 50).clamp(0, 2000.0);
    return '${_fmtInt(d)} mg (${_fmt(d / 1000)} g) IV em 15–20 min';
  }

  // Naloxona 0,01 mg/kg IV (max 2 mg)
  String get _naloxoneDose {
    double d = (_weight * 0.01).clamp(0, 2.0);
    return '${_fmt(d)} mg IV/IO/IM/IN';
  }

  // Desfibrilação: 2 J/kg → 4 J/kg (max 360 J)
  String get _defib1 {
    double j = min(_weight * 2, 200.0);
    return '${_fmtInt(j)} J  (2 J/kg)';
  }
  String get _defib2 {
    double j = min(_weight * 4, 360.0);
    return '${_fmtInt(j)} J  (4 J/kg)';
  }

  // Fluido: 20 mL/kg em bolus (repetir até 60 mL/kg)
  String get _fluid20 => '${_fmtInt(_weight * 20)} mL SF 0,9% ou RL em 5–20 min';
  String get _fluid60 => '${_fmtInt(_weight * 60)} mL total máximo (sepse)';

  // Tubo orotraqueal (sem cuff): (idade + 4) / 4  → estimar idade por peso
  // Com cuff: 0,5 tamanho menor
  String get _ettSize {
    if (_weight < 3) return '2,5 mm (sem cuff) — neonato';
    if (_weight < 5) return '3,0 mm (sem cuff)';
    if (_weight < 8) return '3,5 mm (sem cuff)';
    if (_weight < 11) return '4,0 mm (com cuff: 3,5)';
    if (_weight < 14) return '4,5 mm (com cuff: 4,0)';
    if (_weight < 18) return '5,0 mm (com cuff: 4,5)';
    if (_weight < 24) return '5,5 mm (com cuff: 5,0)';
    if (_weight < 32) return '6,0 mm com cuff';
    return '6,5–7,0 mm com cuff';
  }

  // Profundidade de inserção do TOT (cm na comissura labial) ≈ diâmetro × 3
  String get _ettDepth {
    if (_weight < 5) return '9–10 cm';
    if (_weight < 10) return '10–11 cm';
    if (_weight < 20) return '12–14 cm';
    if (_weight < 30) return '14–16 cm';
    return '16–18 cm';
  }

  // Fita de Broselow
  String get _broselowColor {
    if (_weight < 5) return '🟤 Cinza';
    if (_weight < 7) return '🔴 Rosa';
    if (_weight < 9) return '🔴 Vermelho';
    if (_weight < 11) return '🟣 Roxo';
    if (_weight < 14) return '🟡 Amarelo';
    if (_weight < 18) return '⬜ Branco';
    if (_weight < 25) return '🔵 Azul';
    if (_weight < 36) return '🟠 Laranja';
    return '🟢 Verde (adulto)';
  }

  String _fmt(double v) => v.toStringAsFixed(v < 10 ? 2 : 1).replaceAll(RegExp(r'\.?0+$'), '');
  String _fmtInt(double v) => v.round().toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: AppColors.textPrimary, size: 20),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calculadora PALS',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Doses pediátricas · AHA 2020',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _broselowColor,
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // ── Weight Selector ───────────────────────────────────
            _WeightSelector(
              weight: _weight,
              controller: _weightController,
              onChanged: (v) => setState(() {
                _weight = v;
                if (!_editingManually) {
                  _weightController.text = v.round().toString();
                }
              }),
            ),

            // ── Cards de dose ─────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  // Desfibrilação (destaque máximo)
                  _SectionHeader(label: '⚡ Desfibrilação', color: AppColors.danger),
                  _DefibCard(first: _defib1, second: _defib2, weight: _weight),
                  const SizedBox(height: 8),

                  // Fluidos
                  _SectionHeader(label: '💧 Ressuscitação Volêmica', color: AppColors.info),
                  _DoseCard(label: 'Bolus 20 mL/kg', value: _fluid20, color: AppColors.info),
                  _DoseCard(label: 'Máximo sepse 60 mL/kg', value: _fluid60, color: AppColors.info, subtle: true),
                  const SizedBox(height: 8),

                  // Via aérea
                  _SectionHeader(label: '🫁 Via Aérea', color: AppColors.purple),
                  _DoseCard(label: 'Tubo Orotraqueal (TOT)', value: _ettSize, color: AppColors.purple),
                  _DoseCard(label: 'Profundidade de inserção', value: _ettDepth, color: AppColors.purple, subtle: true),
                  const SizedBox(height: 8),

                  // Drogas vasoativas
                  _SectionHeader(label: '💊 Drogas de Emergência', color: AppColors.danger),
                  _DoseCard(label: 'Epinefrina 0,01 mg/kg', value: _epiDose, color: AppColors.danger, highlight: true),
                  _DoseCard(label: 'Atropina 0,02 mg/kg', value: _atropineDose, color: AppColors.warning),
                  _DoseCard(label: 'Adenosina 0,1 mg/kg', value: _adenosineDose, color: AppColors.success),
                  _DoseCard(label: 'Amiodarona 5 mg/kg', value: _amiodaroneDose, color: AppColors.purple),
                  _DoseCard(label: 'Lidocaína 1 mg/kg', value: _lidocaineDose, color: AppColors.purple, subtle: true),
                  const SizedBox(height: 8),

                  // Metabólico
                  _SectionHeader(label: '🔬 Correção Metabólica', color: AppColors.warning),
                  _DoseCard(label: 'Bicarbonato 1 mEq/kg', value: _bicarbonateDose, color: AppColors.warning),
                  _DoseCard(label: 'Glicose D10% 5 mL/kg', value: _glucoseDose, color: AppColors.warning, subtle: true),
                  _DoseCard(label: 'MgSO₄ 50 mg/kg (Torsades)', value: _magnesiumDose, color: AppColors.success, subtle: true),
                  _DoseCard(label: 'Naloxona 0,01 mg/kg', value: _naloxoneDose, color: AppColors.info, subtle: true),

                  const SizedBox(height: 16),
                  // Aviso clínico
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '⚠️  Doses baseadas nas Diretrizes AHA/PALS 2020. Confirmar com farmacêutico e ajustar conforme resposta clínica. Doses máximas aplicadas automaticamente.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Weight Selector Widget
// ──────────────────────────────────────────────────────────────────────────────

class _WeightSelector extends StatefulWidget {
  final double weight;
  final TextEditingController controller;
  final ValueChanged<double> onChanged;

  const _WeightSelector({
    required this.weight,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_WeightSelector> createState() => _WeightSelectorState();
}

class _WeightSelectorState extends State<_WeightSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Peso do Paciente',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              // Input manual
              Container(
                width: 80,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (v) {
                          final n = double.tryParse(v);
                          if (n != null && n >= 1 && n <= 100) {
                            widget.onChanged(n);
                          }
                        },
                      ),
                    ),
                    Text(
                      ' kg',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.secondary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.secondary,
              overlayColor: AppColors.secondary.withValues(alpha: 0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 5,
            ),
            child: Slider(
              value: widget.weight.clamp(1.0, 80.0),
              min: 1,
              max: 80,
              divisions: 79,
              onChanged: (v) {
                widget.controller.text = v.round().toString();
                widget.onChanged(v.roundToDouble());
              },
            ),
          ),

          // Marcadores de faixa etária
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AgeMarker(label: 'RN', kg: '1–3'),
              _AgeMarker(label: 'Lactente', kg: '3–10'),
              _AgeMarker(label: 'Pré-escolar', kg: '10–20'),
              _AgeMarker(label: 'Escolar', kg: '20–40'),
              _AgeMarker(label: 'Adol.', kg: '40+'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _AgeMarker extends StatelessWidget {
  final String label;
  final String kg;
  const _AgeMarker({required this.label, required this.kg});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 9, fontWeight: FontWeight.w600,
                color: AppColors.textMuted)),
        Text(kg,
            style: GoogleFonts.inter(
                fontSize: 8, color: AppColors.textMuted)),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Componentes visuais
// ──────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 6),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DoseCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool subtle;
  final bool highlight;

  const _DoseCard({
    required this.label,
    required this.value,
    required this.color,
    this.subtle = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: highlight
            ? color.withValues(alpha: 0.12)
            : AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: subtle
              ? AppColors.border
              : color.withValues(alpha: 0.35),
          width: highlight ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: subtle ? AppColors.textSecondary : color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: highlight ? 15 : 13,
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                color: highlight ? color : AppColors.textPrimary,
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _DefibCard extends StatelessWidget {
  final String first;
  final String second;
  final double weight;

  const _DefibCard({
    required this.first,
    required this.second,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.40), width: 1.5),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DefibRow(label: '1º choque (2 J/kg)', value: first),
                const SizedBox(height: 6),
                _DefibRow(label: 'Choques seguintes (4 J/kg)', value: second),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _DefibRow extends StatelessWidget {
  final String label;
  final String value;
  const _DefibRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.danger)),
      ],
    );
  }
}
