import '../models/algorithm_node.dart';

final strokeAlgorithm = Algorithm(
  id: 'stroke',
  title: 'AVC — Acidente Vascular Cerebral',
  subtitle: 'Algoritmo de AVC Agudo — AHA 2025',
  iconEmoji: '🧠',
  color: '#8B5CF6',
  startNodeId: 'suspect_stroke',
  nodes: {
    // PRE-HOSPITAL
    'suspect_stroke': const AlgorithmNode(
      id: 'suspect_stroke',
      type: NodeType.action,
      title: 'Suspeita de AVC (FAST)',
      bullets: [
        'Reconhecer sinais e sintomas de AVC',
        'Acionar EMS conforme protocolo regional',
      ],
      didacticCards: {
        'FAST': 'F — Face: queda facial (peça para sorrir)\nA — Arm: desvio de braço (peça levantar os 2 braços)\nS — Speech: fala anormal (peça repetir uma frase)\nT — Time: registrar o horário de início dos sintomas (LKW) e acionar o EMS imediatamente\n\nQualquer item alterado = suspeita de AVC.',
        'AVC posterior — FAST pode ser normal!': 'Vertigem súbita, diplopia, disfagia, ataxia e drop attack sugerem AVC de circulação posterior.\nFAST NORMAL NÃO EXCLUI AVC POSTERIOR.',
        'Os 8 Ds do AVC': '1. Detecção — reconhecer sinais\n2. Despacho — ativar EMS\n3. Delivery — avaliação e transporte\n4. Door — chegada ao hospital\n5. Data — imagem e labs\n6. Decision — elegibilidade\n7. Drug/Device — trombolítico e/ou trombectomia\n8. Disposition — UTI ou unidade de AVC\n\n"Tempo é cérebro" — atraso em qualquer D piora o prognóstico.',
      },
      nextNodeId: 'scene_eval',
    ),
    'scene_eval': const AlgorithmNode(
      id: 'scene_eval',
      type: NodeType.action,
      title: 'Avaliação na Cena (EMS)',
      bullets: [
        'ABC — sinais vitais e intervenções iniciais',
        'Entrevistar testemunhas e obter telefone',
        'Triagem pré-hospitalar validada (CPSS)',
        'Glicemia capilar (POC) — corrigir hipoglicemia',
      ],
      didacticCards: {
        'CPSS (Cincinnati Prehospital Stroke Scale)': '3 itens: (1) queda facial, (2) desvio de braço, (3) fala anormal.\nQualquer item alterado = suspeita de AVC.',
        'Glicemia capilar (POC)': 'Hipoglicemia (< 60 mg/dL) pode mimetizar AVC.\nCorrigir ANTES de confirmar o diagnóstico.\nSe sintomas persistirem após correção → manter suspeita de AVC e seguir o protocolo.',
      },
      nextNodeId: 'stroke_q',
    ),
    'stroke_q': const AlgorithmNode(
      id: 'stroke_q',
      type: NodeType.question,
      title: 'Há suspeita de AVC?',
      options: [
        AlgorithmOption(label: 'NÃO', nextNodeId: 'no_stroke'),
        AlgorithmOption(label: 'SIM', nextNodeId: 'get_lkw'),
      ],
    ),
    'no_stroke': const AlgorithmNode(
      id: 'no_stroke',
      type: NodeType.end,
      title: 'Sem Suspeita de AVC',
      bullets: [
        'Tratar e transportar conforme a apresentação clínica',
      ],
    ),
    'get_lkw': const AlgorithmNode(
      id: 'get_lkw',
      type: NodeType.action,
      title: 'Determinar LKW',
      bullets: [
        'Registrar Last Known Well (LKW) e horário de descoberta',
      ],
      didacticCards: {
        'LKW (Last Known Well)': 'Último momento em que o paciente estava em seu estado neurológico NORMAL.\n\nSe acordou com déficit → LKW = última vez visto bem ANTES de dormir.\nO LKW define a janela para trombólise (≤ 4,5h) e trombectomia (≤ 24h).',
      },
      nextNodeId: 'lkw_q',
    ),
    'lkw_q': const AlgorithmNode(
      id: 'lkw_q',
      type: NodeType.question,
      title: 'LKW < 24 horas?',
      options: [
        AlgorithmOption(label: 'NÃO', nextNodeId: 'late_presentation'),
        AlgorithmOption(label: 'SIM', nextNodeId: 'assess_lvo'),
      ],
    ),
    'late_presentation': const AlgorithmNode(
      id: 'late_presentation',
      type: NodeType.action,
      title: 'Apresentação Tardia (> 24h)',
      bullets: [
        'Fora da janela terapêutica de reperfusão aguda',
        'NÃO ativar Código AVC agudo',
        'Admitir para investigação e prevenção secundária'
      ],
      didacticCards: {
        'Conduta fora da janela': 'Pacientes com LKW > 24h não se beneficiam de terapias de reperfusão aguda.\nFoco:\n• Imagem de crânio e vascular (não urgente)\n• Investigação etiológica (ECG, Holter, Ecocardiograma)\n• Prevenção secundária (AAS, Estatina)\n• Controle de fatores de risco',
      },
      nextNodeId: 'stroke_unit',
    ),
    'assess_lvo': const AlgorithmNode(
      id: 'assess_lvo',
      type: NodeType.action,
      title: 'Avaliar LVO (FAST-ED)',
      bullets: [
        'Aplicar escala de severidade para triagem de LVO',
      ],
      didacticCards: {
        'FAST-ED (triagem de LVO)': 'F — Face (0-1)\nA — Arm (0-2)\nS — Speech (0-2)\nE — Eye deviation (0-2)\nD — Denial/Neglect (0-2)\nNeglect tátil, visual ou Anosognosia.\nTotal: 0-9 pontos\n≥ 4 → alta probabilidade de LVO.',
      },
      nextNodeId: 'lvo_q',
    ),
    'lvo_q': const AlgorithmNode(
      id: 'lvo_q',
      type: NodeType.question,
      title: 'Há suspeita de LVO?',
      options: [
        AlgorithmOption(label: 'NÃO', nextNodeId: 'route_nearest'),
        AlgorithmOption(label: 'SIM', nextNodeId: 'start_protocol'),
      ],
    ),
    'route_nearest': const AlgorithmNode(
      id: 'route_nearest',
      type: NodeType.action,
      title: 'Centro de AVC Mais Próximo',
      bullets: [
        'Transportar para o centro certificado mais próximo',
        'Fazer notificação pré-hospitalar',
      ],
      didacticCards: {
        'Centros de AVC': 'ASRH — Acute Stroke Ready: estabilização.\nPSC — Primary: trombólise IV.\nTSC — Thrombectomy-capable: trombectomia.\nCSC — Comprehensive: todos os recursos.',
      },
      nextNodeId: 'code_stroke',
    ),
    'start_protocol': const AlgorithmNode(
      id: 'start_protocol',
      type: NodeType.action,
      title: 'Iniciar Protocolo de AVC',
      bullets: [
        'Transporte rápido para centro com trombectomia (se < 30min adicional)',
        'Notificação pré-hospitalar urgente',
      ],
      nextNodeId: 'code_stroke',
    ),
    // HOSPITAL
    'code_stroke': const AlgorithmNode(
      id: 'code_stroke',
      type: NodeType.action,
      title: 'Chegada ao Hospital (Time zero)',
      bullets: [
        'Avaliação geral imediata: em até 10 minutos',
        'Avaliação neurológica e NIHSS: em até 20 minutos',
        'Realizar TC/RM de crânio: em até 20 minutos',
      ],
      didacticCards: {
        'Metas de Tempo': 'Avaliação geral: ≤ 10 min\nAvaliação neurológica: ≤ 20 min\nAquisição de Imagem (TC/RM): ≤ 20 min\nInterpretação da Imagem: ≤ 45 min\nAdministração de Trombolítico: ≤ 60 min (meta ideal ≤ 45 min)',
      },
      nextNodeId: 'ct_scan',
    ),
    'ct_scan': const AlgorithmNode(
      id: 'ct_scan',
      type: NodeType.action,
      title: 'Imagem de Crânio (TC/RM)',
      bullets: [
        'Interpretação da imagem: em até 45 minutos',
        'Descartar hemorragia intracraniana',
      ],
      nextNodeId: 'hemorrhage_q',
    ),
    'hemorrhage_q': const AlgorithmNode(
      id: 'hemorrhage_q',
      type: NodeType.question,
      title: 'Há hemorragia na imagem?',
      options: [
        AlgorithmOption(label: 'SIM', nextNodeId: 'hemorrhagic_stroke'),
        AlgorithmOption(label: 'NÃO (Isquemia)', nextNodeId: 'ischemic_stroke'),
      ],
    ),
    'hemorrhagic_stroke': const AlgorithmNode(
      id: 'hemorrhagic_stroke',
      type: NodeType.end,
      title: 'AVC Hemorrágico',
      alertLevel: 'danger',
      bullets: [
        'NÃO usar trombolíticos ou antitrombóticos',
        'Consultar neurocirurgia / neurologia',
        'Controlar PA intensivamente',
      ],
    ),
    'ischemic_stroke': const AlgorithmNode(
      id: 'ischemic_stroke',
      type: NodeType.question,
      title: 'Critérios para Trombólise IV?',
      options: [
        AlgorithmOption(label: 'SIM (Elegível)', nextNodeId: 'thrombolysis_drug'),
        AlgorithmOption(label: 'NÃO (Contraindicado)', nextNodeId: 'evt_eval'),
      ],
    ),
    'thrombolysis_drug': const AlgorithmNode(
      id: 'thrombolysis_drug',
      type: NodeType.drug,
      title: 'Trombólise IV (Tenecteplase / Alteplase)',
      drug: DrugInfo(
        name: 'Trombolítico',
        dose: 'Tenecteplase: 0,25 mg/kg IV bolus (máx 25 mg)\nAlteplase: 0,9 mg/kg (máx 90 mg) IV',
        route: 'Intravenoso',
        notes: 'Meta porta-agulha ≤ 60 min.',
        color: '#F97316',
      ),
      nextNodeId: 'evt_eval',
    ),
    'evt_eval': const AlgorithmNode(
      id: 'evt_eval',
      type: NodeType.question,
      title: 'Elegível para Trombectomia (EVT)?',
      options: [
        AlgorithmOption(label: 'SIM', nextNodeId: 'evt_action'),
        AlgorithmOption(label: 'NÃO', nextNodeId: 'stroke_unit'),
      ],
    ),
    'evt_action': const AlgorithmNode(
      id: 'evt_action',
      type: NodeType.action,
      title: 'Trombectomia Endovascular (EVT)',
      bullets: [
        'Ativar equipe de neurorradiologia intervencionista',
        'Transferir para hemodinâmica',
      ],
      nextNodeId: 'stroke_unit',
    ),
    'stroke_unit': const AlgorithmNode(
      id: 'stroke_unit',
      type: NodeType.end,
      title: 'Unidade de AVC / UTI',
      bullets: [
        'Monitorização neurológica e hemodinâmica',
        'Investigação etiológica',
        'Prevenção secundária',
      ],
    ),
  },
);
