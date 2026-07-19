import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/drug_card.dart';
import '../../models/algorithm_node.dart';

// ── Categorias disponíveis ─────────────────────────────────────────────
const _categories = [
  'Todos',
  'Vasopressores/Inotrópicos',
  'Antiarrítmicos',
  'Anticoagulantes',
  'Trombolíticos',
  'Eletrólitos',
  'Reversores',
  'Sedativos/Analgésicos',
  'Anti-hipertensivos',
];

// ── Banco completo de fármacos ACLS (AHA 2025) ────────────────────────
const _allDrugs = [

  // ──────────────────────────────────────────────────────
  //  VASOPRESSORES / PCR
  // ──────────────────────────────────────────────────────
  DrugInfo(
    name: 'Epinefrina (Adrenalina)',
    category: 'Vasopressores/Inotrópicos',
    dose: 'PCR: 1 mg IV/IO bolus\nBradicardia/Choque: infusão 2–10 mcg/min',
    route: 'IV push (PCR) / Infusão contínua',
    frequency: 'PCR: a cada 3–5 minutos. Infusão: titular para efeito.',
    notes: 'PCR: preparar 1 mg em 10 mL SF. Flush 20 mL após. Sem dose máxima.\nDiluição padrão (BIC): 4 mg (4 amp de 1mg) em 250 mL SG5% (16 mcg/mL).',
    color: '#EF4444',
    indications: [
      'PCR (VF, pVT, Assistolia, AESP) — 1ª linha',
      'Anafilaxia grave / choque anafilático',
      'Bradicardia refratária à atropina e marcapasso',
    ],
    contraindications:
        'Taquiarritmias não tratadas. Usar com cautela em IAMCSST (pode aumentar consumo de O₂).',
  ),
  DrugInfo(
    name: 'Vasopressina',
    category: 'Vasopressores/Inotrópicos',
    dose: '40 UI IV/IO (dose única)',
    route: 'IV / IO push',
    frequency: 'Dose única — pode substituir a 1ª ou 2ª dose de Epinefrina',
    notes:
        'Alternativa não adrenérgica à Epinefrina em PCR. AHA 2025: sem benefício adicional comprovado. Meia-vida ~10–20 min.',
    color: '#EF4444',
    indications: [
      'PCR refratária como alternativa ou adjuvante à Epinefrina',
      'Choque vasodilatatório / sepse (doses baixas: 0,03–0,04 UI/min)',
    ],
    contraindications:
        'Doença arterial coronariana grave (relativo). Insuficiência renal grave.',
  ),
  DrugInfo(
    name: 'Norepinefrina',
    category: 'Vasopressores/Inotrópicos',
    dose: '0,1–1 mcg/kg/min (titular)',
    route: 'Infusão IV contínua — acesso central preferencial',
    notes: 'Vasopressor de 1ª escolha no choque séptico. Titular para PAM ≥ 65 mmHg.\nDiluição padrão (BIC): 16 mg (4 amp de 4mg) em 250 mL SG5% (64 mcg/mL).',
    color: '#EF4444',
    indications: [
      'Choque séptico',
      'Hipotensão refratária a volume pós-ROSC',
      'Choque cardiogênico (em associação)',
    ],
    contraindications:
        'Hipovolemia não corrigida. Extravasamento causa necrose tecidual.',
  ),
  DrugInfo(
    name: 'Dopamina',
    category: 'Vasopressores/Inotrópicos',
    dose: '5–20 mcg/kg/min',
    route: 'Infusão IV contínua',
    notes:
        '5–10 mcg/kg/min: inotrópico/cronotrópico (β1). >10 mcg/kg/min: vasoconstricção (α1).\nDiluição padrão (BIC): 250 mg (5 amp de 50mg/10mL) em 200 mL SG5% (1 mg/mL).',
    color: '#EF4444',
    indications: [
      'Bradicardia sintomática refratária à Atropina (2ª linha — preferir MP)',
      'Choque cardiogênico com hipotensão moderada',
    ],
    contraindications:
        'Fibrilação ventricular. Taquiarritmias. Feocromocitoma.',
  ),
  DrugInfo(
    name: 'Dobutamina',
    category: 'Vasopressores/Inotrópicos',
    dose: '2–20 mcg/kg/min',
    route: 'Infusão IV contínua',
    notes:
        'Inotrópico positivo sem efeito vasopressor. Pode reduzir PA — associar vasopressor se necessário.\nDiluição padrão (BIC): 250 mg (1 amp de 250mg/20mL) em 230 mL SG5% (1 mg/mL).',
    color: '#EF4444',
    indications: [
      'Choque cardiogênico com PA preservada (PAM >65)',
      'Insuficiência cardíaca aguda com baixo débito',
      'Suporte inotrópico pós-ROSC',
    ],
    contraindications:
        'Hipotensão sem suporte vasopressor. Cardiomiopatia obstrutiva hipertrófica.',
  ),
  DrugInfo(
    name: 'Fenilefrina',
    category: 'Vasopressores/Inotrópicos',
    dose: 'Bolus: 50–200 mcg IV\nInfusão: 0,5–5 mcg/kg/min',
    route: 'IV push (bolus) ou infusão contínua',
    notes:
        'Agonista alfa-1 puro — sem efeito cronotrópico. Útil quando a taquicardia reflexa é indesejada.',
    color: '#EF4444',
    indications: [
      'Hipotensão com taquicardia reflexa indesejada',
      'Hipotensão perioperatória',
    ],
    contraindications:
        'Bradicardia. Bloqueio AV. Insuficiência cardíaca congestiva.',
  ),

  // ──────────────────────────────────────────────────────
  //  ANTIARRÍTMICOS
  // ──────────────────────────────────────────────────────
  DrugInfo(
    name: 'Amiodarona',
    category: 'Antiarrítmicos',
    dose: 'PCR: 300 mg IV push → 150 mg (2ª dose)\nEstável: 150 mg IV em 10 min',
    route: 'IV / IO push (PCR) · IV lento (ritmo estável)',
    frequency: 'Manutenção: 1 mg/min × 6h → 0,5 mg/min × 18h',
    maxDose: 'Máx 2,2 g/24h',
    notes:
        'Antiarrítmico de 1ª escolha em PCR com FV/TV. Pode causar hipotensão e bradicardia. Monitorar QTc.\n'
        'Diluição p/ manutenção (Bomba de Infusão): 900 mg em 500 mL SG5% (1,8 mg/mL).',
    color: '#A855F7',
    indications: [
      'VF / pVT refratária após 3º choque — 1ª linha',
      'TV com pulso estável',
      'FA / Flutter com alta resposta ventricular',
      'TSV refratária à adenosina',
    ],
    contraindications:
        'BAV 2º/3º grau sem MP, bradicardia sinusal grave, hipotireoidismo, QTc muito prolongado, alergia ao iodo.',
  ),
  DrugInfo(
    name: 'Lidocaína',
    category: 'Antiarrítmicos',
    dose: '1–1,5 mg/kg (1ª dose)\n0,5–0,75 mg/kg (doses subsequentes)',
    route: 'IV / IO push',
    frequency: 'Repetir a cada 5–10 min. Manutenção: 1–4 mg/min',
    maxDose: 'Máx 3 mg/kg total',
    notes:
        'Alternativa à Amiodarona em FV/TV. Menor evidência de melhora de sobrevida a longo prazo.\nDiluição padrão (BIC): 1 g (50 mL a 2%) em 200 mL SG5% (4 mg/mL).',
    color: '#A855F7',
    indications: [
      'VF / pVT refratária — alternativa à Amiodarona',
      'TV monomórfica com pulso',
      'Supressão de ectopias ventriculares frequentes',
    ],
    contraindications:
        'BAV avançado sem marcapasso. Síndrome de Stokes-Adams. Hipersensibilidade a anestésicos tipo amida.',
  ),
  DrugInfo(
    name: 'Procainamida',
    category: 'Antiarrítmicos',
    dose: 'Ataque: 20–50 mg/min até 17 mg/kg total\nManutenção: 1–4 mg/min',
    route: 'IV lento (infusão controlada)',
    maxDose: '17 mg/kg total na dose de ataque',
    notes:
        'Monitorar QRS e PA continuamente. Parar se QRS alargar >50%, hipotensão ou dose máxima atingida.',
    color: '#A855F7',
    indications: [
      'TV monomórfica estável — opção eficaz',
      'FA / Flutter com pré-excitação (WPW)',
      'TSV refratária à adenosina',
    ],
    contraindications:
        'QTc prolongado, Torsades de Pointes, BAV 2º/3º grau, lúpus induzido por drogas, insuficiência renal grave.',
  ),
  DrugInfo(
    name: 'Adenosina',
    category: 'Antiarrítmicos',
    dose: '6 mg → 12 mg → 12 mg',
    route: 'IV push MUITO RÁPIDO + flush 20 mL SF imediato',
    frequency: 'Intervalos de 1–2 min entre doses',
    maxDose: '30 mg total',
    notes:
        'Meia-vida <10 seg. Acesso antecubital ou proximal obrigatório. Avisar aperto torácico e dispneia transitórios.',
    color: '#A855F7',
    indications: [
      'TSV (TRAV, TRNAV) — cardioversão química de 1ª linha',
      'Diagnóstico diferencial de taquicardias de QRS estreito',
    ],
    contraindications:
        'Asma grave / DPOC grave, BAV 2º/3º grau sem MP, FA/Flutter com WPW (risco de FV), síndrome do nó sinusal.',
  ),
  DrugInfo(
    name: 'Atropina',
    category: 'Antiarrítmicos',
    dose: '1 mg IV push',
    route: 'IV rápido (bolus)',
    frequency: 'Repetir a cada 3–5 min',
    maxDose: '3 mg total (0,04 mg/kg)',
    notes:
        '1ª linha em bradicardia sinusal sintomática. INEFICAZ em BAV infranodal (Mobitz II, BAVT) — prefira MP transcutâneo.',
    color: '#A855F7',
    indications: [
      'Bradicardia sinusal sintomática',
      'BAV 1º grau e Mobitz I com instabilidade hemodinâmica',
      'Intoxicação colinérgica por organofosforados (doses muito maiores)',
    ],
    contraindications:
        'Corações transplantados (ineficaz). BAV infranodal (Mobitz II, BAVT). Glaucoma de ângulo fechado.',
  ),
  DrugInfo(
    name: 'Sulfato de Magnésio',
    category: 'Antiarrítmicos',
    dose: 'Urgência: 2 g IV em 1–2 min\nEletivo: 1–2 g IV em 15 min',
    route: 'IV',
    frequency: 'Manutenção: 1–2 g/h conforme nível sérico',
    notes:
        'Indicação clássica em Torsades de Pointes. Antídoto para toxicidade: Gluconato de Cálcio 1 g IV.',
    color: '#A855F7',
    indications: [
      'Torsades de Pointes (TV polimórfica com QT longo) — 1ª linha',
      'Hipomagnesemia sintomática com arritmias',
      'VF/TV refratária com suspeita de hipomagnesemia',
    ],
    contraindications:
        'Insuficiência renal grave (acúmulo). BAV. Miastenia gravis.',
  ),
  DrugInfo(
    name: 'Ibutilida',
    category: 'Antiarrítmicos',
    dose: '>60 kg: 1 mg IV em 10 min\n<60 kg: 0,01 mg/kg IV em 10 min',
    route: 'IV (infusão em 10 min)',
    frequency: 'Repetir 1 dose após 10 min se sem reversão',
    maxDose: '2 mg total',
    notes:
        'Alta eficácia para cardioversão farmacológica de FA/Flutter (<48h). Monitorar QTc por 4h após (risco de Torsades).',
    color: '#A855F7',
    indications: [
      'FA de início recente (<48h) — cardioversão farmacológica',
      'Flutter atrial — cardioversão farmacológica',
    ],
    contraindications:
        'QTc >440 ms, hipopotassemia, hipomagnesemia, uso concomitante de agentes que prolongam QT, FA crônica.',
  ),
  DrugInfo(
    name: 'Verapamil',
    category: 'Antiarrítmicos',
    dose: '2,5–5 mg IV em 2 min\nRepetir 5–10 mg a cada 15–30 min',
    route: 'IV lento',
    maxDose: '20 mg total',
    notes:
        'BCC não-dihidropiridínico. NUNCA usar em TV com QRS largo ou FA+WPW (risco de FV).',
    color: '#A855F7',
    indications: [
      'TSV com QRS estreito refratária à adenosina',
      'Controle de frequência em FA/Flutter hemodinamicamente estável',
    ],
    contraindications:
        'TV com QRS largo, WPW+FA (risco fatal), FE reduzida grave, BAV, hipotensão, betabloqueador IV simultâneo.',
  ),
  DrugInfo(
    name: 'Diltiazem',
    category: 'Antiarrítmicos',
    dose: 'Ataque: 0,25 mg/kg IV em 2 min\n2ª dose: 0,35 mg/kg após 15 min\nManutenção: 5–15 mg/h',
    route: 'IV lento',
    notes:
        'BCC não-dihidropiridínico. Menos inotrópico negativo que o Verapamil — preferível em disfunção ventricular leve.',
    color: '#A855F7',
    indications: [
      'Controle de frequência em FA/Flutter estável',
      'TSV com QRS estreito',
    ],
    contraindications:
        'WPW+FA, TV com QRS largo, hipotensão, ICC descompensada, BAV 2º/3º grau.',
  ),
  DrugInfo(
    name: 'Metoprolol',
    category: 'Antiarrítmicos',
    dose: 'IV: 5 mg a cada 5 min (até 3 doses)\nVO manutenção: 25–100 mg 2x/dia',
    route: 'IV lento / VO',
    maxDose: '15 mg IV na fase aguda',
    notes:
        'Betabloqueador β1-seletivo. Controle de frequência e prevenção de arritmias pós-IAM.',
    color: '#A855F7',
    indications: [
      'Controle de FC em FA/Flutter estável',
      'TSV com QRS estreito',
      'TV polimórfica em contexto isquêmico (tempestade elétrica)',
      'Redução de mortalidade em SCA',
    ],
    contraindications:
        'FC <60 bpm, BAV 2º/3º grau, broncoespasmo ativo, hipotensão, ICC descompensada (relativo).',
  ),
  DrugInfo(
    name: 'Esmolol',
    category: 'Antiarrítmicos',
    dose: 'Ataque: 500 mcg/kg IV em 1 min\nManutenção: 50–200 mcg/kg/min',
    route: 'IV bolus + infusão contínua',
    notes:
        'Betabloqueador de ação ultrarrápida — meia-vida ~9 min. Ideal para titulação fina em ambiente de urgência.',
    color: '#A855F7',
    indications: [
      'Controle agudo de FC em FA/Flutter',
      'TSV perioperatória',
      'Crise hipertensiva com taquicardia',
    ],
    contraindications:
        'Bradicardia sinusal, BAV 2º/3º grau, ICC descompensada, broncoespasmo, hipotensão.',
  ),
  DrugInfo(
    name: 'Sotalol',
    category: 'Antiarrítmicos',
    dose: 'IV: 75 mg em 5h (1,5 mg/kg)\nVO: 80–160 mg 2x/dia',
    route: 'IV lento / VO',
    maxDose: 'Máx 320 mg/dia (VO)',
    notes:
        'Betabloqueador com propriedades classe III (prolongamento de QT). Ajustar em insuficiência renal.',
    color: '#A855F7',
    indications: [
      'TV monomórfica sustentada estável',
      'Manutenção de ritmo sinusal em FA/Flutter',
      'Arritmias ventriculares recorrentes',
    ],
    contraindications:
        'QTc >450 ms, hipopotassemia, hipomagnesemia, ClCr <40 mL/min, bradicardia, BAV.',
  ),

  // ──────────────────────────────────────────────────────
  //  ANTICOAGULANTES / ANTIAGREGANTES
  // ──────────────────────────────────────────────────────
  DrugInfo(
    name: 'AAS (Ácido Acetilsalicílico)',
    category: 'Anticoagulantes',
    dose: '300 mg — mascar',
    route: 'VO — mascar para absorção mais rápida',
    notes:
        'Primeira dose em SCA. Mascar acelera absorção em ~50%. Manter 100 mg/dia indefinidamente após evento.',
    color: '#F97316',
    indications: [
      'SCA (IAMCSST, IAMSST, AI) — 1ª linha imediata',
      'Angina instável',
    ],
    contraindications:
        'Alergia comprovada ao AAS, sangramento ativo GI, úlcera péptica ativa, hemofilia.',
  ),
  DrugInfo(
    name: 'Ticagrelor',
    category: 'Anticoagulantes',
    dose: '180 mg (ataque) → 90 mg 2x/dia (manutenção)',
    route: 'VO / SNG',
    notes:
        'P2Y12 preferencial (menor variabilidade de resposta, início mais rápido que Clopidogrel). Usar sempre com AAS.',
    color: '#F97316',
    indications: [
      'SCA (IAMCSST, IAMSST, AI)',
      'ICP primária ou eletiva',
    ],
    contraindications:
        'AVC hemorrágico prévio, sangramento ativo grave, insuficiência hepática grave, uso de anticoagulante oral (relativo).',
  ),
  DrugInfo(
    name: 'Clopidogrel',
    category: 'Anticoagulantes',
    dose: '300–600 mg (ataque) → 75 mg/dia (manutenção)',
    route: 'VO / SNG',
    notes:
        'Pró-fármaco — depende do CYP2C19. Alternativa ao Ticagrelor (menor custo, maior variabilidade genética).',
    color: '#F97316',
    indications: [
      'SCA quando Ticagrelor/Prasugrel é contraindicado',
      'Stent coronariano',
      'AVC/AIT isquêmico (75 mg/dia)',
    ],
    contraindications:
        'Sangramento ativo, úlcera péptica ativa, metabolizadores lentos de CYP2C19 (redução de eficácia).',
  ),
  DrugInfo(
    name: 'Prasugrel',
    category: 'Anticoagulantes',
    dose: '60 mg (ataque) → 10 mg/dia\n5 mg/dia se <60 kg ou >75 anos',
    route: 'VO',
    notes:
        'Mais potente e de início mais rápido que Clopidogrel. Maior risco hemorrágico — selecionar pacientes.',
    color: '#F97316',
    indications: [
      'IAMCSST com ICP primária planejada',
      'IAMSST com ICP planejada',
    ],
    contraindications:
        'AVC/AIT prévio (CONTRAINDICAÇÃO ABSOLUTA), >75 anos (risco/benefício cuidadoso), sangramento ativo, cirurgia recente.',
  ),
  DrugInfo(
    name: 'Heparina não Fracionada (HNF)',
    category: 'Anticoagulantes',
    dose: 'Bolus: 60–70 UI/kg IV (máx 5.000 UI)\nManutenção: 12–15 UI/kg/h (máx 1.000 UI/h)',
    route: 'IV bolus + infusão contínua',
    notes:
        'Titular pelo TTPa (1,5–2,5× o controle). Antídoto: Protamina 1 mg por 100 UI de heparina recebida.',
    color: '#F97316',
    indications: [
      'IAMCSST — adjuvante à trombólise ou ICP',
      'TEP maciço — anticoagulação inicial',
      'FA com risco tromboembólico',
      'IAMSST / AI',
    ],
    contraindications:
        'Sangramento ativo incontrolável, TIH (trombocitopenia induzida por heparina), AVC hemorrágico recente.',
  ),
  DrugInfo(
    name: 'Enoxaparina (HBPM)',
    category: 'Anticoagulantes',
    dose: '1 mg/kg SC 2x/dia ou 1,5 mg/kg/dia\nIdosos >75 anos: 0,75 mg/kg SC 2x/dia\nIV em IAMCSST: 0,5 mg/kg bolus',
    route: 'SC / IV (bolus em IAMCSST)',
    maxDose: 'Máx 100 mg/dose SC',
    notes:
        'Prefira à HNF em SCA — não necessita monitoramento de TTPa rotineiro. Ajustar em ClCr <30 mL/min.',
    color: '#F97316',
    indications: [
      'IAMSST / Angina Instável',
      'IAMCSST com estratégia fibrinolítica',
      'TEP hemodinamicamente estável',
    ],
    contraindications:
        'ClCr <30 mL/min (ajustar ou trocar por HNF), TIH, sangramento ativo.',
  ),

  // ──────────────────────────────────────────────────────
  //  TROMBOLÍTICOS
  // ──────────────────────────────────────────────────────
  DrugInfo(
    name: 'Tenecteplase (TNK)',
    category: 'Trombolíticos',
    dose: '<60 kg: 30 mg\n60–70 kg: 35 mg\n70–80 kg: 40 mg\n80–90 kg: 45 mg\n>90 kg: 50 mg',
    route: 'IV bolus em 5–10 seg',
    notes:
        'Trombólise em IAMCSST quando ICP não disponível em <120 min. Administrar sempre com HNF.',
    color: '#F97316',
    indications: [
      'IAMCSST sem acesso a ICP primária em <120 min',
    ],
    contraindications:
        'AVC hemorrágico prévio, AVC isquêmico <3 meses, neoplasia intracraniana, TCE grave <3 meses, sangramento interno ativo, PA >185/110 mmHg não controlada.',
  ),
  DrugInfo(
    name: 'Alteplase (rt-PA)',
    category: 'Trombolíticos',
    dose: 'TEP maciço: 100 mg IV em 2h\nPCR por TEP: 50 mg bolus IV',
    route: 'IV infusão ou bolus',
    notes:
        'PCR por TEP: continuar RCP por 60–90 min após administração. Menor especificidade fibrinolítica que TNK.',
    color: '#F97316',
    indications: [
      'TEP maciço com choque / PCR',
      'AVC isquêmico agudo <4,5h (protocolo neurológico específico)',
      'IAMCSST (protocolo alternativo)',
    ],
    contraindications:
        'AVC hemorrágico prévio, neoplasia intracraniana, cirurgia intracraniana <3 meses, PA não controlada, sangramento interno ativo.',
  ),

  // ──────────────────────────────────────────────────────
  //  ELETRÓLITOS / METABÓLICOS
  // ──────────────────────────────────────────────────────
  DrugInfo(
    name: 'Bicarbonato de Sódio',
    category: 'Eletrólitos',
    dose: '1–2 mEq/kg IV\n(fórmula: HCO₃ desejado − atual × 0,3 × peso)',
    route: 'IV lento (nunca misturar com cálcio — precipita)',
    notes:
        'Não usar rotineiramente em PCR. Indicado apenas em situações específicas.',
    color: '#EAB308',
    indications: [
      'Acidose metabólica grave (pH <7,1)',
      'Hipercalemia grave com instabilidade hemodinâmica',
      'Intoxicação por antidepressivos tricíclicos (QRS alargado)',
      'PCR por hipercalemia documentada',
    ],
    contraindications:
        'Alcalose metabólica, hipocalemia, edema pulmonar grave. NUNCA administrar junto ao cálcio (precipita).',
  ),
  DrugInfo(
    name: 'Gluconato de Cálcio',
    category: 'Eletrólitos',
    dose: '1–2 g IV em 2–5 min',
    route: 'IV lento (periférico ou central)',
    notes:
        'Contém 93 mg de Ca²⁺ elementar/g. Menos irritante que CaCl₂ — pode ser periférico. Antídoto para toxicidade por magnésio.',
    color: '#EAB308',
    indications: [
      'Hipercalemia com alterações no ECG',
      'Hipocalcemia sintomática',
      'Overdose de bloqueador de canal de cálcio (BCC)',
      'Toxicidade por sulfato de magnésio',
    ],
    contraindications:
        'Hipercalcemia, intoxicação digitálica (pode precipitar arritmias), hiperfosfatemia grave.',
  ),
  DrugInfo(
    name: 'Cloreto de Cálcio (CaCl₂)',
    category: 'Eletrólitos',
    dose: '500–1000 mg IV em 5 min',
    route: 'IV lento — acesso central obrigatório (muito irritante)',
    notes:
        'Contém 272 mg de Ca²⁺ elementar/g — 3× mais biodisponível que Gluconato. 1ª escolha em emergências graves.',
    color: '#EAB308',
    indications: [
      'Hipercalemia grave com PCR iminente',
      'Overdose grave de BCC com choque refratário',
      'Hipocalcemia grave com instabilidade hemodinâmica',
    ],
    contraindications:
        'Hipercalcemia, intoxicação digitálica, FV. NUNCA administrar junto ao bicarbonato.',
  ),
  DrugInfo(
    name: 'Glicose 50% (SG 50%)',
    category: 'Eletrólitos',
    dose: '25–50 mL IV (12,5–25 g de glicose)',
    route: 'IV lento (acesso calibroso — irritante)',
    notes:
        'Verificar glicemia antes e após. Sempre seguida de glicose oral se possível.',
    color: '#EAB308',
    indications: [
      'Hipoglicemia grave (<50 mg/dL) com alteração neurológica ou inconsciência',
      'PCR em contexto de hipoglicemia documentada',
    ],
    contraindications:
        'Hiperglicemia confirmada. AVC isquêmico agudo sem hipoglicemia (piora prognóstico neurológico).',
  ),
  DrugInfo(
    name: 'Insulina Regular',
    category: 'Eletrólitos',
    dose: '0,1–0,25 UI/kg IV bolus (hipercalemia)\nMáx 10 UI sem monitorização contínua',
    route: 'IV push',
    frequency: 'Seguida de SG 50% para evitar hipoglicemia. Monitorar glicemia a cada 30–60 min',
    notes:
        'Insulina + Glicose 50% é um dos tratamentos mais eficazes da hipercalemia aguda. Ação: 15–30 min.',
    color: '#EAB308',
    indications: [
      'Hipercalemia aguda (K+ >6,0 mEq/L com sintomas ou ECG alterado)',
      'Cetoacidose diabética (protocolo específico)',
    ],
    contraindications:
        'Hipoglicemia não corrigida. Administrar sempre glicose concomitantemente em não-diabéticos.',
  ),
  DrugInfo(
    name: 'Cloreto de Potássio (KCl)',
    category: 'Eletrólitos',
    dose: 'Reposição: 10–20 mEq/h IV\nMáx 40 mEq/h com monitorização cardíaca contínua',
    route: 'IV diluído em infusão (NUNCA IV push concentrado)',
    notes:
        '⚠️ NUNCA administrar IV rápido ou concentrado — risco de parada cardíaca imediata. Diluir sempre em SF ou SG.',
    color: '#EAB308',
    indications: [
      'Hipopotassemia grave (K+ <3,0 mEq/L) com arritmias',
      'Hipopotassemia associada a Torsades de Pointes',
    ],
    contraindications:
        'Hipercalemia, insuficiência renal anúrica, administração IV rápida não diluída (FATAL).',
  ),

  // ──────────────────────────────────────────────────────
  //  REVERSORES / ANTÍDOTOS
  // ──────────────────────────────────────────────────────
  DrugInfo(
    name: 'Naloxona',
    category: 'Reversores',
    dose: '0,4–2 mg IV/IM/IN\nIntoxicação grave: titular até 10 mg total',
    route: 'IV / IM / Intranasal (IN)',
    frequency: 'Repetir a cada 2–3 min se sem resposta',
    maxDose: '10 mg total',
    notes:
        'Meia-vida ~30–90 min (menor que opioides). Monitorar por 2–4h — risco de re-sedação. Titular dose em dependentes.',
    color: '#22C55E',
    indications: [
      'Overdose por opioides com depressão respiratória',
      'PCR em contexto de intoxicação opioide',
      'Depressão respiratória pós-operatória por opioides',
    ],
    contraindications:
        'Dependência de opioides — usar dose baixa titulada para evitar síndrome de abstinência aguda.',
  ),
  DrugInfo(
    name: 'Flumazenil',
    category: 'Reversores',
    dose: '0,2 mg IV em 30 seg → 0,3 mg → 0,5 mg (intervalos de 1 min)',
    route: 'IV push lento',
    maxDose: '3 mg total em 1 hora',
    notes:
        'Meia-vida muito curta (~1h) — risco de re-sedação. Pode precipitar convulsões em usuários crônicos de BZD.',
    color: '#22C55E',
    indications: [
      'Reversão de sedação por benzodiazepínicos (procedimento)',
      'Diagnóstico / tratamento de intoxicação por BZD',
    ],
    contraindications:
        'Uso crônico de BZD (risco de convulsões severas), TCE grave, epilepsia em controle com BZD, coingesta com antidepressivos tricíclicos.',
  ),
  DrugInfo(
    name: 'Protamina',
    category: 'Reversores',
    dose: '1 mg IV por cada 100 UI de HNF recebida nas últimas 2–3h\nMáx 50 mg por dose',
    route: 'IV lento (máx 5 mg/min)',
    notes:
        'Antídoto específico da heparina não fracionada. Reverte parcialmente HBPM (~60%). Risco de hipotensão — infundir lentamente.',
    color: '#22C55E',
    indications: [
      'Reversão de anticoagulação com HNF em sangramento grave',
      'Reversão pré-cirúrgica de HNF',
      'Reversão parcial de enoxaparina em emergência',
    ],
    contraindications:
        'Alergia à protamina ou ao peixe (risco de anafilaxia). Hipotensão não corrigida.',
  ),

  // ──────────────────────────────────────────────────────
  //  SEDATIVOS / ANALGÉSICOS
  // ──────────────────────────────────────────────────────
  DrugInfo(
    name: 'Fentanil',
    category: 'Sedativos/Analgésicos',
    dose: 'Bolus: 1–2 mcg/kg IV\nInfusão: 1–3 mcg/kg/h',
    route: 'IV lento / Infusão',
    notes: 'Ação rápida (1-2 min). Causa menos hipotensão que a morfina.',
    color: '#3B82F6',
    indications: [
      'Analgesia pré-cardioversão / intubação',
      'Dor isquêmica refratária',
      'Sedação contínua pós-PCR (TTM)',
    ],
    contraindications: 'Choque não reanimado, depressão respiratória não ventilada.',
  ),
  DrugInfo(
    name: 'Midazolam',
    category: 'Sedativos/Analgésicos',
    dose: 'Bolus: 1–5 mg IV lento\nInfusão: 0,02–0,1 mg/kg/h',
    route: 'IV lento / Infusão',
    notes: 'Ação rápida (2-3 min). Risco de hipotensão severa em hipovolêmicos.',
    color: '#3B82F6',
    indications: [
      'Sedação pré-cardioversão',
      'Controle de crises convulsivas',
    ],
    contraindications: 'Hipotensão severa, choque refratário, miastenia gravis.',
  ),
  DrugInfo(
    name: 'Propofol',
    category: 'Sedativos/Analgésicos',
    dose: 'Bolus: 1–2 mg/kg IV\nInfusão: 5–50 mcg/kg/min',
    route: 'IV restrito a via calibrosa',
    notes: 'Desperta rápido. Causa intensa vasodilatação e depressão miocárdica.',
    color: '#3B82F6',
    indications: [
      'Indução para intubação orotraqueal',
      'Sedação profunda em neurointensivismo',
    ],
    contraindications: 'Choque cardiogênico ou hipovolêmico grave, alergia a ovo/soja.',
  ),
  DrugInfo(
    name: 'Cetamina',
    category: 'Sedativos/Analgésicos',
    dose: 'Bolus: 1–2 mg/kg IV',
    route: 'IV lento',
    notes: 'Preserva PA (efeito simpatomimético) e drive respiratório.',
    color: '#3B82F6',
    indications: [
      'Intubação em pacientes hipotensos/chocados',
      'Asma grave (broncodilatador)',
    ],
    contraindications: 'Emergência hipertensiva, esquizofrenia. Cautela em coronariopatas.',
  ),

  // ──────────────────────────────────────────────────────
  //  ANTI-HIPERTENSIVOS / DIURÉTICOS
  // ──────────────────────────────────────────────────────
  DrugInfo(
    name: 'Nitroprussiato de Sódio (Nipride)',
    category: 'Anti-hipertensivos',
    dose: '0,25–10 mcg/kg/min',
    route: 'Infusão IV contínua (fotossensível)',
    notes: 'Vasodilatador arterial/venoso potente. Risco de intoxicação por cianeto.',
    color: '#06B6D4',
    indications: [
      'Emergências hipertensivas graves',
      'Edema Agudo de Pulmão (com PA elevada)',
    ],
    contraindications: 'Insuficiência renal/hepática grave (intoxicação), PIC elevada.',
  ),
  DrugInfo(
    name: 'Labetalol',
    category: 'Anti-hipertensivos',
    dose: 'Bolus: 10–20 mg IV\nInfusão: 2–8 mg/min',
    route: 'IV push / Infusão',
    notes: 'Bloqueador misto (alfa e beta). Reduz PA sem taquicardia reflexa.',
    color: '#06B6D4',
    indications: [
      'Controle de PA no AVC isquêmico agudo',
      'Dissecção aguda de aorta',
    ],
    contraindications: 'Asma severa, BAV 2º/3º grau, bradicardia acentuada, ICC.',
  ),
  DrugInfo(
    name: 'Hidralazina',
    category: 'Anti-hipertensivos',
    dose: '5–10 mg IV (bolus)',
    route: 'IV lento (1-2 min)',
    frequency: 'Pode repetir a cada 20-30 min',
    notes: 'Vasodilatador arterial direto. Causa taquicardia reflexa e aumenta consumo de O2.',
    color: '#06B6D4',
    indications: [
      'Emergência hipertensiva na gestação (Pré-eclâmpsia grave / Eclâmpsia)',
    ],
    contraindications: 'SCA, dissecção de aorta, lúpus.',
  ),
  DrugInfo(
    name: 'Nitroglicerina SL (Isossorbida / Nitrato)',
    category: 'Anti-hipertensivos',
    dose: '0,4 mg (nitroglicerina) ou 5 mg (isossorbida)',
    route: 'Sublingual (SL)',
    frequency: 'A cada 5 min (máx 3 doses)',
    notes: 'Ação rápida. Avaliar PA e dor antes de cada nova dose.',
    color: '#06B6D4',
    indications: [
      'Angina / Dor torácica isquêmica aguda (SCA)',
    ],
    contraindications: 'Infarto de VD, PAS < 90 mmHg, uso de inibidores da fosfodiesterase (ex: Sildenafila nas últimas 24h).',
  ),
  DrugInfo(
    name: 'Nitroglicerina IV (Tridil)',
    category: 'Anti-hipertensivos',
    dose: '5–100 mcg/min (titular)',
    route: 'Infusão IV contínua',
    notes: 'Venodilatadora predominante. Melhora fluxo coronariano.',
    color: '#06B6D4',
    indications: [
      'SCA com dor refratária',
      'Edema Agudo de Pulmão (EAP)',
    ],
    contraindications: 'Infarto de VD, PAS < 90 mmHg, uso de Sildenafila < 24h.',
  ),
  DrugInfo(
    name: 'Furosemida (Lasix)',
    category: 'Anti-hipertensivos',
    dose: '0,5–1 mg/kg IV (habitual 20-40 mg)',
    route: 'IV direto (máx 4 mg/min para evitar ototoxicidade)',
    notes: 'Diurético de alça rápido (5-15 min).',
    color: '#06B6D4',
    indications: [
      'Edema Agudo de Pulmão',
      'Congestão por Insuficiência Cardíaca aguda',
    ],
    contraindications: 'Hipovolemia, desidratação, anúria refratária.',
  ),
  DrugInfo(
    name: 'Milrinona',
    category: 'Vasopressores/Inotrópicos',
    dose: 'Ataque: 50 mcg/kg em 10 min\nManutenção: 0,375–0,75 mcg/kg/min',
    route: 'IV lento / Infusão',
    notes: 'Inodilatador (aumenta contratilidade e reduz resistência).',
    color: '#EF4444',
    indications: [
      'Choque cardiogênico refratário',
      'Insuficiência de VD isolada',
    ],
    contraindications: 'Hipotensão severa, doença valvar obstrutiva severa.',
  ),
];

// ── Screen ─────────────────────────────────────────────────────────────
class DrugsScreen extends StatefulWidget {
  const DrugsScreen({super.key});

  @override
  State<DrugsScreen> createState() => _DrugsScreenState();
}

class _DrugsScreenState extends State<DrugsScreen> {
  String _search = '';
  String _selectedCategory = 'Todos';

  List<DrugInfo> get _filtered {
    var drugs = _allDrugs.toList();

    // Filtro por categoria
    if (_selectedCategory != 'Todos') {
      drugs = drugs.where((d) => d.category == _selectedCategory).toList();
    }

    // Filtro por busca
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      drugs = drugs.where((d) {
        final nameMatch = d.name.toLowerCase().contains(q);
        final notesMatch = d.notes?.toLowerCase().contains(q) ?? false;
        final indicationsMatch =
            d.indications?.any((i) => i.toLowerCase().contains(q)) ?? false;
        return nameMatch || notesMatch || indicationsMatch;
      }).toList();
    }

    return drugs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '💊 Fármacos ACLS',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
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
                hintText: 'Buscar medicamento, indicação...',
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Chips de categoria ──────────────────────────────
          _CategoryChips(
            categories: _categories,
            selected: _selectedCategory,
            onSelected: (cat) => setState(() => _selectedCategory = cat),
          ),
          // ── Contador de resultados ──────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} '
                  '${_filtered.length == 1 ? 'medicamento' : 'medicamentos'}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // ── Lista de fármacos ───────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? _EmptyState(search: _search)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      return DrugCard(drug: _filtered[i])
                          .animate()
                          .fadeIn(
                              delay:
                                  Duration(milliseconds: i * 30),
                              duration: 250.ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Category Chips ─────────────────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onSelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Text(
                cat,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String search;
  const _EmptyState({required this.search});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Nenhum resultado para\n"$search"',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
