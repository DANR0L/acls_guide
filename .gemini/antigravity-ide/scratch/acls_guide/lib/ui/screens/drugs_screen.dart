import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/drug_card.dart';
import '../../models/algorithm_node.dart';

// ── Drug reference data ──────────────────────────────────────────
const _allDrugs = [
  DrugInfo(
    name: 'Epinefrina (Adrenalina)',
    dose: '1 mg IV/IO',
    route: 'IV / IO',
    frequency: 'A cada 3–5 minutos durante PCR',
    notes: 'Preparo: 1 mg em 10 mL SF. Flush 20 mL após. Sem dose máxima em PCR.',
    color: '#EF4444',
  ),
  DrugInfo(
    name: 'Amiodarona',
    dose: '300 mg (1ª) → 150 mg (2ª) — PCR\n150 mg IV em 10 min — TV/FA',
    route: 'IV / IO push (PCR) · IV lento (estável)',
    frequency: 'PCR: após 3º choque. Manutenção: 1 mg/min × 6h',
    maxDose: 'Máx 2,2 g/24h',
    notes: 'Pode causar hipotensão em infusão rápida. Monitorizar QTc.',
    color: '#A855F7',
  ),
  DrugInfo(
    name: 'Lidocaína',
    dose: '1–1,5 mg/kg (1ª dose)\n0,5–0,75 mg/kg (doses subsequentes)',
    route: 'IV / IO push',
    frequency: 'Repetir a cada 5–10 min',
    maxDose: 'Máx 3 mg/kg total',
    notes: 'Alternativa à Amiodarona em VF/pVT. Menor evidência de benefício.',
    color: '#A855F7',
  ),
  DrugInfo(
    name: 'Atropina',
    dose: '1 mg IV push',
    route: 'IV rápido',
    frequency: 'Repetir a cada 3–5 min. Máx 3 mg',
    maxDose: '3 mg (0,04 mg/kg)',
    notes: 'CI: transplantados cardíacos, BAV infranodal. Ineficaz em Mobitz II / BAVT.',
    color: '#3B82F6',
  ),
  DrugInfo(
    name: 'Adenosina',
    dose: '6 mg → 12 mg → 12 mg',
    route: 'IV push RÁPIDO + flush 20 mL',
    frequency: 'Intervalos de 1–2 min entre doses',
    maxDose: '30 mg total',
    notes: 'Acesso proximal obrigatório. Avisar sobre sensação de aperto torácico. CI: asma, WPW+FA.',
    color: '#22C55E',
  ),
  DrugInfo(
    name: 'Dopamina',
    dose: '5–20 mcg/kg/min',
    route: 'Infusão IV contínua',
    notes: 'Efeito cronotrópico > 5 mcg/kg/min. Vasoconstrição > 10 mcg/kg/min.',
    color: '#3B82F6',
  ),
  DrugInfo(
    name: 'Norepinefrina',
    dose: '0,1–1 mcg/kg/min',
    route: 'Infusão IV contínua (acesso central)',
    notes: 'Vasopressor de 1ª escolha no choque. Titular para PAM ≥ 65 mmHg.',
    color: '#EF4444',
  ),
  DrugInfo(
    name: 'Sulfato de Magnésio',
    dose: '2 g IV em 1–2 min',
    route: 'IV',
    frequency: 'Repetir 2 g em 10 min. Manutenção 1–2 g/h',
    notes: 'Indicado em Torsades de Pointes. Antídoto: Gluconato de Cálcio 1 g IV.',
    color: '#22C55E',
  ),
  DrugInfo(
    name: 'Tenecteplase (TNK)',
    dose: '< 60 kg: 30 mg\n60–70 kg: 35 mg\n70–80 kg: 40 mg\n80–90 kg: 45 mg\n> 90 kg: 50 mg',
    route: 'IV bolus em 5–10 seg',
    notes: 'Trombólise IAMCSST. Administrar com heparina. CI absolutas: AVC hemorrágico, AVC isquêmico < 3 meses.',
    color: '#F97316',
  ),
  DrugInfo(
    name: 'Alteplase (rt-PA)',
    dose: '50 mg bolus',
    route: 'IV bolus',
    notes: 'PCR por TEP maciço. Continuar CPR por 60–90 min após administração.',
    color: '#F97316',
  ),
  DrugInfo(
    name: 'AAS (Ácido Acetilsalicílico)',
    dose: '300 mg (mascar)',
    route: 'VO',
    notes: 'Primeira dose em SCA. Mascar para absorção mais rápida. CI: alergia, sangramento ativo.',
    color: '#EF4444',
  ),
  DrugInfo(
    name: 'Ticagrelor',
    dose: '180 mg (dose de ataque)',
    route: 'VO / SNG',
    notes: 'Antiagregação em SCA. Preferencial ao Clopidogrel. CI: AVC hemorrágico prévio, sangramento ativo.',
    color: '#EF4444',
  ),
  DrugInfo(
    name: 'Bicarbonato de Sódio',
    dose: '1–2 mEq/kg',
    route: 'IV lento',
    notes: 'Usar apenas se pH < 7,1 ou hipercalemia grave. Não routineiro em PCR.',
    color: '#EAB308',
  ),
  DrugInfo(
    name: 'Gluconato de Cálcio',
    dose: '1 g IV em 2–3 min',
    route: 'IV lento',
    notes: 'Hipercalemia, hipocalcemia, overdose de BCC. Antídoto para toxicidade de magnésio.',
    color: '#EAB308',
  ),
  DrugInfo(
    name: 'Naloxona',
    dose: '0,4–2 mg',
    route: 'IV / IM / IN',
    frequency: 'Repetir a cada 2–3 min se necessário',
    maxDose: '10 mg total',
    notes: 'Reversão de opioides. Dose IM/IN pode ser maior. Duração curta — monitorizar.',
    color: '#22C55E',
  ),
];

class DrugsScreen extends StatefulWidget {
  const DrugsScreen({super.key});

  @override
  State<DrugsScreen> createState() => _DrugsScreenState();
}

class _DrugsScreenState extends State<DrugsScreen> {
  String _search = '';

  List<DrugInfo> get _filtered {
    if (_search.isEmpty) return _allDrugs;
    final q = _search.toLowerCase();
    return _allDrugs
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            (d.notes?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '💊 Fármacos ACLS',
          style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: GoogleFonts.inter(
                  color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar medicamento...',
                hintStyle: GoogleFonts.inter(
                    color: AppColors.textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          return DrugCard(drug: _filtered[i])
              .animate()
              .fadeIn(delay: Duration(milliseconds: i * 40), duration: 300.ms);
        },
      ),
    );
  }
}
