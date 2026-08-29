final strokeAlgorithm = Algorithm(
  id: 'stroke',
  title: 'AVC — Acidente Vascular Cerebral',
  subtitle: 'Isquêmico / Hemorrágico — AHA 2025',
  iconEmoji: '🧠',
  color: '#8B5CF6',
  startNodeId: 'stroke_start',
  nodes: {
    // ── CAMADA 1: SUSPEITA E AVALIAÇÃO PRÉ-HOSPITALAR ──
    'stroke_start': const AlgorithmNode(
      id: 'stroke_start',
      type: NodeType.action,
      title: 'Suspeita de AVC — Avaliação Inicial FAST',
      subtitle: 'Reconhecimento rápido de sinais de AVC',
      bullets: [
        'Avaliar via aérea, respiração e circulação (ABC)',
        'Aplicar escala FAST ou escala pré-hospitalar equivalente',
        'Acionar o sistema de emergência médica (EMS)',
      ],
      didacticCards: {
        'O que é FAST?': 'Acrônimo para Face drooping (queda facial), Arm weakness (fraqueza no braço), Speech difficulty (dificuldade na fala), Time to call 9-1-1 (hora de ligar para emergência). É a ferramenta padrão para reconhecimento rápido de AVC.'
      },
      nextNodeId: 'stroke_ems_assess',
    ),

    'stroke_ems_assess': const AlgorithmNode(
      id: 'stroke_ems_assess',
      type: NodeType.action,
      title: 'Avaliação Primária e Suporte (EMS)',
      bullets: [
        'Fornecer O2 se SpO2 < 94%',
        'Checar glicemia e tratar se < 60 mg/dL',
        'Estabelecer o Last Known Well (LKW)',
        'Avisar o hospital receptor (Stroke Center)',
      ],
      didacticCards: {
        'O que é LKW (Last Known Well)?': 'É o último momento em que o paciente foi visto em seu estado normal/basal. É o marco zero para cálculo do tempo de janela terapêutica.',
        'Por que checar glicemia?': 'Hipoglicemia grave pode simular perfeitamente um AVC (stroke mimic) e deve ser descartada ou tratada imediatamente.'
      },
      nextNodeId: 'stroke_hospital_arrive',
    ),

    // ── CAMADA 2: HOSPITAL E IMAGEM ──
    'stroke_hospital_arrive': const AlgorithmNode(
      id: 'stroke_hospital_arrive',
      type: NodeType.action,
      title: 'Chegada ao Hospital e Imagem Urgente',
      subtitle: 'Ativação do time de AVC e TC Imediata',
      bullets: [
        'Ativar Time de AVC',
        'Avaliação neurológica (escala NIHSS)',
        'Tomografia Computadorizada (NCCT) ou RM imediata',
        'ECG (não deve atrasar a imagem)',
      ],
      didacticCards: {
        'O que é NCCT?': 'Non-Contrast Computed Tomography (Tomografia Computadorizada sem contraste). Exame padrão inicial para descartar hemorragia intracraniana.',
        'O que é LVO?': 'Large Vessel Occlusion (Oclusão de Grande Vaso). Exige imagem vascular (Angio-TC) e define indicação de Trombectomia Mecânica (EVT).',
        'Door-to-Needle': 'A meta AHA 2025 para avaliação e administração de trombolítico em candidatos elegíveis é de ≤ 60 minutos (idealmente ≤ 45 minutos) da porta à agulha.'
      },
      nextNodeId: 'stroke_ct_result',
    ),

    'stroke_ct_result': const AlgorithmNode(
      id: 'stroke_ct_result',
      type: NodeType.question,
      title: 'Resultado da Tomografia (NCCT)',
      options: [
        AlgorithmOption(
          label: '🔴 Hemorragia Intracraniana Presente',
          nextNodeId: 'stroke_hemorrhage',
        ),
        AlgorithmOption(
          label: '⚪ Sem Hemorragia (Isquemia)',
          nextNodeId: 'stroke_ischemic_path',
        ),
      ],
    ),

    'stroke_hemorrhage': const AlgorithmNode(
      id: 'stroke_hemorrhage',
      type: NodeType.end,
      title: 'Hemorragia Intracraniana Confirmada',
      alertLevel: 'warning',
      bullets: [
        'NÃO administrar trombolítico, heparina ou antiplaquetários',
        'Consultar neurologia/neurocirurgia imediatamente',
        'Controle de PA conforme protocolos de hemorragia',
        'Reverter anticoagulantes se em uso',
      ],
    ),

    // ── CAMADA 3: TRATAMENTO ISQUÊMICO (TROMBÓLISE E EVT) ──
    'stroke_ischemic_path': const AlgorithmNode(
      id: 'stroke_ischemic_path',
      type: NodeType.question,
      title: 'Isquemia — Janela para Trombolítico?',
      subtitle: 'Baseado no LKW (Last Known Well)',
      options: [
        AlgorithmOption(
          label: '⏱️ LKW < 4.5 horas',
          nextNodeId: 'stroke_tpa_eligible',
        ),
        AlgorithmOption(
          label: '⏱️ LKW 4.5h a 24h ou Desconhecido',
          nextNodeId: 'stroke_evt_path',
        ),
      ],
    ),

    'stroke_tpa_eligible': const AlgorithmNode(
      id: 'stroke_tpa_eligible',
      type: NodeType.question,
      title: 'Elegível para Trombolítico IV?',
      subtitle: 'Verificar contraindicações e PA',
      didacticCards: {
        'Contraindicações': 'TCE grave recente, sangramento ativo, cirurgia de grande porte recente, uso de DOAC nas últimas 48h (depende do caso), plaquetas < 100.000, INR > 1.7.'
      },
      options: [
        AlgorithmOption(
          label: '✅ Sim e PA ≤ 185/110 mmHg',
          nextNodeId: 'stroke_give_tpa',
        ),
        AlgorithmOption(
          label: '⚠️ Sim, mas PA > 185/110 mmHg',
          nextNodeId: 'stroke_bp_control',
        ),
        AlgorithmOption(
          label: '❌ Não elegível',
          nextNodeId: 'stroke_evt_path',
        ),
      ],
    ),

    'stroke_bp_control': const AlgorithmNode(
      id: 'stroke_bp_control',
      type: NodeType.action,
      title: 'Controle de PA para Trombolítico',
      subtitle: 'Alvo: PA ≤ 185/110 mmHg antes da infusão',
      bullets: [
        'Labetalol 10-20 mg IV (pode repetir 1x)',
        'Nicardipina 5 mg/h IV, titular',
        'Clevidipina 1-2 mg/h IV, titular',
      ],
      didacticCards: {
        'Opções de Drogas': 'Labetalol é a escolha clássica; bloqueadores de canal de cálcio como Nicardipina e Clevidipina permitem titulação mais fina. Se a PA não reduzir para ≤ 185/110, trombolítico é contraindicado.'
      },
      nextNodeId: 'stroke_tpa_eligible',
    ),

    'stroke_give_tpa': const AlgorithmNode(
      id: 'stroke_give_tpa',
      type: NodeType.action,
      title: 'Administrar Trombolítico IV',
      bullets: [
        'Alteplase ou Tenecteplase',
        'Manter PA ≤ 180/105 mmHg nas primeiras 24 horas',
        'Monitorar sinais de deterioração (Hemorragia)',
      ],
      didacticCards: {
        'Doses': 'Alteplase: 0.9 mg/kg (máximo 90 mg) - 10% em bolus, 90% em infusão de 1h. Tenecteplase: 0.25 mg/kg (máximo 25 mg) em bolus único (usado especialmente se planejado EVT).',
        'PA pós-trombólise': 'Manter estritamente ≤ 180/105 mmHg para evitar transformação hemorrágica.'
      },
      nextNodeId: 'stroke_evt_path',
    ),

    'stroke_evt_path': const AlgorithmNode(
      id: 'stroke_evt_path',
      type: NodeType.question,
      title: 'Avaliação para Trombectomia (EVT)',
      subtitle: 'Janela até 24h em LVO',
      options: [
        AlgorithmOption(
          label: '✅ LVO confirmada e critérios de Imagem (Mismatch)',
          nextNodeId: 'stroke_give_evt',
        ),
        AlgorithmOption(
          label: '❌ Sem LVO ou sem critérios / Imagem',
          nextNodeId: 'stroke_stroke_unit',
        ),
      ],
      didacticCards: {
        'O que é EVT?': 'Endovascular Thrombectomy (Trombectomia Endovascular). Remoção mecânica do coágulo por cateterismo, padrão-ouro para oclusão de grandes vasos (LVO) da circulação anterior.',
        'O que é Mismatch?': 'Diferença entre o tecido cerebral já infartado (core) e o tecido em risco mas salvável (penumbra). Avaliado por RM de difusão/perfusão ou TC com perfusão (DAWN e DEFUSE 3).'
      },
    ),

    'stroke_give_evt': const AlgorithmNode(
      id: 'stroke_give_evt',
      type: NodeType.action,
      title: 'Trombectomia Endovascular',
      bullets: [
        'Acionar equipe de Neurointervenção/Hemodinâmica',
        'Pode ser feito após/durante trombolítico IV (não atrasar EVT para esperar efeito do trombolítico)',
      ],
      nextNodeId: 'stroke_stroke_unit',
    ),

    // ── CAMADA 4: CUIDADOS PÓS-AVC ──
    'stroke_stroke_unit': const AlgorithmNode(
      id: 'stroke_stroke_unit',
      type: NodeType.end,
      title: 'Cuidados na Unidade de AVC',
      bullets: [
        'Internação em Unidade de AVC / UTI',
        'Triagem para disfagia antes de qualquer via oral',
        'Manejo de temperatura, PA e glicemia',
      ],
      didacticCards: {
        'Disfagia': 'Até 50% dos pacientes com AVC apresentam disfagia. A triagem fonoaudiológica previne pneumonia aspirativa.',
        'Febre / TTM': 'A hipertermia piora o desfecho neurológico. Tratar febre (T > 37.5°C) ativamente com antipiréticos nas primeiras 72h.'
      },
    ),
  },
);
