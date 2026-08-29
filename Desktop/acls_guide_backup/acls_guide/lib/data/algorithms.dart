import '../models/algorithm_node.dart';

// ═══════════════════════════════════════════════════════════════
//  ALGORITMO PCR — Parada Cardiorrespiratória (AHA 2025)
//  Inclui: VF/pVT (chocável) e Assistolia/PEA (não chocável)
// ═══════════════════════════════════════════════════════════════

final cardiacArrestAlgorithm = Algorithm(
  id: 'cardiac_arrest',
  title: 'PCR — Parada Cardiorrespiratória',
  subtitle: 'VF · pVT · Assistolia · PEA',
  iconEmoji: '🫀',
  color: '#EF4444',
  startNodeId: 'start',
  nodes: {
    // ── INÍCIO ──────────────────────────────────────────────
    'start': const AlgorithmNode(
      id: 'start',
      type: NodeType.question,
      title: 'Confirmar Parada Cardiorrespiratória',
      subtitle: 'Verifique os critérios de PCR',
      bullets: [
        'Sem resposta ao estímulo tátil/verbal',
        'Sem respiração ou respiração agônica (gasping)',
        'Sem pulso central (≤10 segundos de checagem)',
      ],
      options: [
        AlgorithmOption(label: '✅ PCR confirmada', nextNodeId: 'activate_team'),
        AlgorithmOption(label: '⚠️ Paciente com pulso', nextNodeId: 'has_pulse_redirect'),
      ],
    ),

    'has_pulse_redirect': const AlgorithmNode(
      id: 'has_pulse_redirect',
      type: NodeType.end,
      title: 'Paciente com Pulso Detectado',
      subtitle: 'Use outro algoritmo',
      body: 'Se o paciente tem pulso, avalie frequência cardíaca e pressão arterial para escolher o algoritmo correto.',
      alertLevel: 'info',
      options: [
        AlgorithmOption(label: '🔵 Ir para Bradicardia', nextNodeId: '__goto_bradycardia'),
        AlgorithmOption(label: '🔴 Ir para Taquicardia', nextNodeId: '__goto_tachycardia'),
      ],
    ),

    // ── ATIVAR EQUIPE ────────────────────────────────────────
    'activate_team': const AlgorithmNode(
      id: 'activate_team',
      type: NodeType.action,
      title: 'Ativar Equipe de Ressuscitação',
      alertLevel: 'danger',
      bullets: [
        'Acionar código / time de ressuscitação',
        'Solicitar DEA / desfibrilador imediatamente',
        'Anotar hora da parada',
        'Iniciar CPR de alta qualidade AGORA',
      ],
      nextNodeId: 'cpr_quality',
    ),

    // ── CPR DE ALTA QUALIDADE ────────────────────────────────
    'cpr_quality': const AlgorithmNode(
      id: 'cpr_quality',
      type: NodeType.info,
      title: 'CPR de Alta Qualidade',
      alertLevel: 'danger',
      bullets: [
        '💪 Profundidade: ≥ 5 cm (adulto)',
        '⚡ Frequência: 100–120 compressões/min',
        '🔄 Reexpansão torácica completa entre compressões',
        '⏱️ Minimizar interrupções (< 10 seg)',
        '🫁 Ventilação: 30:2 até via aérea avançada',
        '🔋 Trocar compressor a cada 2 min (ou se fadiga)',
      ],
      nextNodeId: 'start_timer_2min',
    ),

    // ── TIMER 2 MIN ──────────────────────────────────────────
    'start_timer_2min': const AlgorithmNode(
      id: 'start_timer_2min',
      type: NodeType.action,
      title: 'Iniciar Ciclo de CPR',
      subtitle: '2 minutos de CPR contínua',
      timerSeconds: 120,
      nextNodeId: 'rhythm_check_1',
    ),

    // ── CHECAGEM DE RITMO 1 ──────────────────────────────────
    'rhythm_check_1': const AlgorithmNode(
      id: 'rhythm_check_1',
      type: NodeType.question,
      title: 'Verificar Ritmo Cardíaco',
      subtitle: 'Pausar CPR brevemente (< 10 seg) para checar ritmo',
      options: [
        AlgorithmOption(
          label: '⚡ Chocável — VF / pVT',
          sublabel: 'Fibrilação Ventricular ou TV sem pulso',
          nextNodeId: 'shock_1',
        ),
        AlgorithmOption(
          label: '📉 Não Chocável — Assistolia',
          sublabel: 'Linha reta no monitor',
          nextNodeId: 'asystole_path',
        ),
        AlgorithmOption(
          label: '🔲 Não Chocável — PEA',
          sublabel: 'Atividade Elétrica Sem Pulso (PEA)',
          nextNodeId: 'pea_path',
        ),
        AlgorithmOption(
          label: '✅ ROSC — Retorno da Circulação',
          sublabel: 'Pulso central detectado',
          nextNodeId: 'rosc_detected',
        ),
      ],
    ),

    // ══════════════════════════════════════════════════════════
    //  BRAÇO CHOCÁVEL — VF / pVT
    // ══════════════════════════════════════════════════════════
    'shock_1': const AlgorithmNode(
      id: 'shock_1',
      type: NodeType.action,
      title: '⚡ 1º Choque — Desfibrilar',
      subtitle: 'Ritmo chocável identificado — VF / pVT',
      alertLevel: 'danger',
      isShockNode: true,
      bullets: [
        'Bifásico: 200 J (faixa recomendada 120–200 J)',
        'Monofásico: 360 J',
        'Afastar todos antes do choque',
        'Retomar CPR IMEDIATAMENTE após choque',
      ],
      nextNodeId: 'post_shock_1',
    ),

    'post_shock_1': const AlgorithmNode(
      id: 'post_shock_1',
      type: NodeType.action,
      title: 'Retomar CPR + Estabelecer Acesso',
      alertLevel: 'warning',
      bullets: [
        'Reiniciar CPR imediatamente (2 min)',
        'Acesso IV preferencial (1ª tentativa); IO se IV falhar (AHA 2025)',


      ],
      nextNodeId: 'start_timer_2min_2',
    ),

    'start_timer_2min_2': const AlgorithmNode(
      id: 'start_timer_2min_2',
      type: NodeType.action,
      title: 'Ciclo CPR — 2 minutos',
      timerSeconds: 120,
      nextNodeId: 'rhythm_check_2',
    ),

    'rhythm_check_2': const AlgorithmNode(
      id: 'rhythm_check_2',
      type: NodeType.question,
      title: 'Verificar Ritmo (2º checagem)',
      subtitle: 'Pausar CPR brevemente para análise',
      options: [
        AlgorithmOption(
          label: '⚡ Chocável — VF / pVT persiste',
          nextNodeId: 'shock_2',
        ),
        AlgorithmOption(
          label: '📉 Não Chocável',
          nextNodeId: 'pea_asystole_mid',
        ),
        AlgorithmOption(
          label: '✅ ROSC',
          nextNodeId: 'rosc_detected',
        ),
      ],
    ),

    'shock_2': const AlgorithmNode(
      id: 'shock_2',
      type: NodeType.action,
      title: '⚡ 2º Choque + Epinefrina',
      alertLevel: 'danger',
      isShockNode: true,
      bullets: [
        'Desfibrilar: 200–360 J',
        'Retomar CPR imediatamente',
        '💊 Epinefrina 1 mg IV/IO — AGORA',
        'Repetir Epi a cada 3–5 minutos',
        'Considerar via aérea avançada (intubação ou supraglótico)',
        'Monitorizar ETCO₂ se disponível',
      ],
      nextNodeId: 'epi_1',
    ),

    'epi_1': const AlgorithmNode(
      id: 'epi_1',
      type: NodeType.drug,
      title: 'Epinefrina',
      drug: DrugInfo(
        name: 'Epinefrina (Adrenalina)',
        dose: '1 mg',
        route: 'IV / IO',
        frequency: 'A cada 3–5 minutos',
        maxDose: 'Sem dose máxima definida',
        notes: 'Preparar: 1 mg em 10 mL SF 0,9%. Flush com 20 mL SF após.',
        color: '#EF4444',
      ),
      nextNodeId: 'start_timer_2min_3',
    ),

    'start_timer_2min_3': const AlgorithmNode(
      id: 'start_timer_2min_3',
      type: NodeType.action,
      title: 'Ciclo CPR — 2 minutos',
      timerSeconds: 120,
      nextNodeId: 'rhythm_check_3',
    ),

    'rhythm_check_3': const AlgorithmNode(
      id: 'rhythm_check_3',
      type: NodeType.question,
      title: 'Verificar Ritmo (3ª checagem)',
      options: [
        AlgorithmOption(
          label: '⚡ Chocável — VF / pVT persiste',
          nextNodeId: 'shock_3_antiarritmico',
        ),
        AlgorithmOption(
          label: '📉 Não Chocável',
          nextNodeId: 'pea_asystole_mid',
        ),
        AlgorithmOption(
          label: '✅ ROSC',
          nextNodeId: 'rosc_detected',
        ),
      ],
    ),

    'shock_3_antiarritmico': const AlgorithmNode(
      id: 'shock_3_antiarritmico',
      type: NodeType.action,
      title: '⚡ 3º Choque + Antiarrítmico',
      alertLevel: 'danger',
      isShockNode: true,
      bullets: [
        'Desfibrilar: 200–360 J',
        'Retomar CPR imediatamente',
        '💊 Antiarrítmico — AGORA (ver opções)',
      ],
      nextNodeId: 'antiarrhythmic_choice',
    ),

    'antiarrhythmic_choice': const AlgorithmNode(
      id: 'antiarrhythmic_choice',
      type: NodeType.question,
      title: 'Escolha do Antiarrítmico',
      subtitle: 'Após 3º choque sem sucesso (VF/pVT refratária)',
      options: [
        AlgorithmOption(
          label: '💊 Amiodarona (1ª escolha)',
          sublabel: 'Preferencial se disponível',
          nextNodeId: 'amiodarone_drug',
        ),
        AlgorithmOption(
          label: '💊 Lidocaína (alternativa)',
          sublabel: 'Usar se Amiodarona indisponível',
          nextNodeId: 'lidocaine_drug',
        ),
      ],
    ),

    'amiodarone_drug': const AlgorithmNode(
      id: 'amiodarone_drug',
      type: NodeType.drug,
      title: 'Amiodarona — 1ª Dose',
      drug: DrugInfo(
        name: 'Amiodarona',
        dose: '300 mg (1ª dose)',
        route: 'IV / IO push',
        frequency: '1ª dose: após 3º choque.',
        notes: 'Diluir em 20 mL de SG5% ou SF. Após reversão, iniciar manutenção: 1 mg/min nas primeiras 6h, depois 0,5 mg/min por 18h.',
        color: '#A855F7',
      ),
      nextNodeId: 'start_timer_2min_4',
    ),

    'lidocaine_drug': const AlgorithmNode(
      id: 'lidocaine_drug',
      type: NodeType.drug,
      title: 'Lidocaína — 1ª Dose',
      drug: DrugInfo(
        name: 'Lidocaína',
        dose: '1–1,5 mg/kg (1ª dose)',
        route: 'IV / IO push',
        frequency: '1ª dose: após 3º choque.',
        maxDose: 'Máx 3 mg/kg total',
        notes: 'Alternativa à Amiodarona em VF/pVT refratária.',
        color: '#A855F7',
      ),
      nextNodeId: 'start_timer_2min_4',
    ),

    'start_timer_2min_4': const AlgorithmNode(
      id: 'start_timer_2min_4',
      type: NodeType.action,
      title: 'Ciclo CPR — 2 minutos',
      timerSeconds: 120,
      nextNodeId: 'rhythm_check_4',
    ),

    'rhythm_check_4': const AlgorithmNode(
      id: 'rhythm_check_4',
      type: NodeType.question,
      title: 'Verificar Ritmo (4ª checagem)',
      options: [
        AlgorithmOption(
          label: '⚡ Chocável — VF / pVT persiste',
          nextNodeId: 'shock_4',
        ),
        AlgorithmOption(
          label: '⚡ Chocável refratária — DSD (Não rotineiro)',
          nextNodeId: 'dsd_shock',
        ),
        AlgorithmOption(
          label: '📉 Não Chocável',
          nextNodeId: 'pea_asystole_mid',
        ),
        AlgorithmOption(
          label: '✅ ROSC',
          nextNodeId: 'rosc_detected',
        ),
      ],
    ),

    'dsd_shock': const AlgorithmNode(
      id: 'dsd_shock',
      type: NodeType.action,
      title: '⚡ Choque Sequencial Duplo (DSD) — NÃO ROTINA',
      alertLevel: 'danger',
      isShockNode: true,
      bullets: [
        'Utilidade NÃO bem estabelecida — NÃO realizar rotineiramente (AHA 2025)',
        'Aplicar 2 DEAs simultaneamente (cargas máximas)',
        'Retomar CPR imediatamente',
        '💊 Epinefrina 1 mg IV/IO — AGORA',
      ],
      nextNodeId: 'epi_2',
    ),

    'shock_4': const AlgorithmNode(
      id: 'shock_4',
      type: NodeType.action,
      title: '⚡ 4º Choque + Epinefrina',
      alertLevel: 'danger',
      isShockNode: true,
      bullets: [
        'Desfibrilar: 200–360 J',
        'Considere Mudança de Vetor ou Desfibrilação Dupla Sequencial (DSD)',
        'Retomar CPR imediatamente',
        '💊 Epinefrina 1 mg IV/IO — AGORA',
      ],
      nextNodeId: 'epi_2',
    ),

    'epi_2': const AlgorithmNode(
      id: 'epi_2',
      type: NodeType.drug,
      title: 'Epinefrina',
      drug: DrugInfo(
        name: 'Epinefrina (Adrenalina)',
        dose: '1 mg',
        route: 'IV / IO',
        frequency: 'A cada 3–5 minutos',
        notes: 'Dose sequencial (4º choque). Flush com 20 mL SF após.',
        color: '#EF4444',
      ),
      nextNodeId: 'start_timer_2min_5',
    ),

    'start_timer_2min_5': const AlgorithmNode(
      id: 'start_timer_2min_5',
      type: NodeType.action,
      title: 'Ciclo CPR — 2 minutos',
      timerSeconds: 120,
      nextNodeId: 'rhythm_check_5',
    ),

    'rhythm_check_5': const AlgorithmNode(
      id: 'rhythm_check_5',
      type: NodeType.question,
      title: 'Verificar Ritmo (5ª checagem)',
      options: [
        AlgorithmOption(
          label: '⚡ Chocável — VF / pVT persiste',
          nextNodeId: 'shock_5_antiarritmico',
        ),
        AlgorithmOption(
          label: '📉 Não Chocável',
          nextNodeId: 'pea_asystole_mid',
        ),
        AlgorithmOption(
          label: '✅ ROSC',
          nextNodeId: 'rosc_detected',
        ),
      ],
    ),

    'shock_5_antiarritmico': const AlgorithmNode(
      id: 'shock_5_antiarritmico',
      type: NodeType.action,
      title: '⚡ 5º Choque + Antiarrítmico (2ª Dose)',
      alertLevel: 'danger',
      isShockNode: true,
      bullets: [
        'Desfibrilar: 200–360 J',
        'Retomar CPR imediatamente',
        '💊 Antiarrítmico (2ª dose) — AGORA',
      ],
      nextNodeId: 'antiarrhythmic_choice_2',
    ),

    'antiarrhythmic_choice_2': const AlgorithmNode(
      id: 'antiarrhythmic_choice_2',
      type: NodeType.question,
      title: 'Escolha da 2ª Dose do Antiarrítmico',
      subtitle: 'Use o mesmo fármaco da 1ª dose, com posologia reduzida',
      options: [
        AlgorithmOption(
          label: '💊 Amiodarona (150 mg)',
          nextNodeId: 'amiodarone_drug_2',
        ),
        AlgorithmOption(
          label: '💊 Lidocaína (0,5 a 0,75 mg/kg)',
          nextNodeId: 'lidocaine_drug_2',
        ),
      ],
    ),

    'amiodarone_drug_2': const AlgorithmNode(
      id: 'amiodarone_drug_2',
      type: NodeType.drug,
      title: 'Amiodarona — 2ª Dose',
      drug: DrugInfo(
        name: 'Amiodarona',
        dose: '150 mg',
        route: 'IV / IO push',
        frequency: '2ª dose: após 5º choque',
        notes: 'Infundir em bolus. Após reversão, iniciar infusão contínua: 1 mg/min por 6h, seguido de 0,5 mg/min por 18h.',
        color: '#A855F7',
      ),
      nextNodeId: 'vf_continuous_timer',
    ),

    'lidocaine_drug_2': const AlgorithmNode(
      id: 'lidocaine_drug_2',
      type: NodeType.drug,
      title: 'Lidocaína — 2ª Dose',
      drug: DrugInfo(
        name: 'Lidocaína',
        dose: '0,5 – 0,75 mg/kg',
        route: 'IV / IO push',
        frequency: '2ª dose: após 5º choque',
        maxDose: 'Máx 3 mg/kg total',
        notes: 'Metade da dose inicial.',
        color: '#A855F7',
      ),
      nextNodeId: 'vf_continuous_timer',
    ),

    'vf_continuous_timer': const AlgorithmNode(
      id: 'vf_continuous_timer',
      type: NodeType.action,
      title: 'Ciclo CPR — 2 minutos',
      timerSeconds: 120,
      nextNodeId: 'vf_continuous_check',
    ),

    'vf_continuous_check': const AlgorithmNode(
      id: 'vf_continuous_check',
      type: NodeType.question,
      title: 'Verificar Ritmo (Ciclos Contínuos)',
      options: [
        AlgorithmOption(
          label: '⚡ Chocável — VF / pVT',
          nextNodeId: 'shock_continuous',
        ),
        AlgorithmOption(
          label: '📉 Não Chocável (Assistolia/PEA)',
          nextNodeId: 'pea_asystole_mid',
        ),
        AlgorithmOption(
          label: '✅ ROSC (Pulso Detectado)',
          nextNodeId: 'rosc_detected',
        ),
      ],
    ),

    'shock_continuous': const AlgorithmNode(
      id: 'shock_continuous',
      type: NodeType.action,
      title: '⚡ Choque + Fármacos (Protocolo Contínuo)',
      alertLevel: 'danger',
      isShockNode: true,
      bullets: [
        'Desfibrilar (carga máxima)',
        'Retomar CPR imediatamente (2 min)',
        'Epinefrina 1 mg a cada 3–5 min',
        'Considere 2ª dose de Amiodarona (150 mg) se não feita',
        'Tratar causas reversíveis (5H5T)',
      ],
      nextNodeId: 'vf_continuous_timer',
    ),

    // ══════════════════════════════════════════════════════════
    //  BRAÇO NÃO CHOCÁVEL — ASSISTOLIA
    // ══════════════════════════════════════════════════════════
    'asystole_path': const AlgorithmNode(
      id: 'asystole_path',
      type: NodeType.action,
      title: 'Assistolia — Protocolo',
      alertLevel: 'danger',
      bullets: [
        'Confirmar cabos e conexões do monitor (excluir artefato/desconexão)',
        'CPR contínua de alta qualidade',
        '💊 Epinefrina 1 mg IV/IO — O MAIS RÁPIDO POSSÍVEL (Prioridade AHA)',
        'Repetir Epi a cada 3–5 min',
        'Não desfibrilar — NÃO é ritmo chocável',
      ],
      nextNodeId: 'epi_asystole',
    ),

    'epi_asystole': const AlgorithmNode(
      id: 'epi_asystole',
      type: NodeType.drug,
      title: 'Epinefrina — Assistolia/PEA',
      drug: DrugInfo(
        name: 'Epinefrina (Adrenalina)',
        dose: '1 mg',
        route: 'IV / IO',
        frequency: 'A cada 3–5 minutos',
        notes: 'Administrar o mais precocemente possível (inclusive antes da 1ª checagem). Flush 20 mL SF após cada dose.',
        color: '#EF4444',
      ),
      nextNodeId: 'hs_ts_asystole',
    ),

    'hs_ts_asystole': const AlgorithmNode(
      id: 'hs_ts_asystole',
      type: NodeType.action,
      title: 'Tratar Causas Reversíveis (5H5T)',
      subtitle: 'Pesquisar e tratar TODAS as causas reversíveis',
      alertLevel: 'warning',
      bullets: [
        '🅗 Hipovolemia → reposição volêmica',
        '🅗 Hipóxia → otimizar ventilação/oxigenação',
        '🅗 Hidrogênio (acidose) → Bicarbonato apenas se pH < 7,1 ou hipercalemia persistente',
        '🅗 Hipo/Hipercalemia → corrigir eletrólitos',
        '🅗 Hipotermia → aquecer paciente',
        '🅣 Tensão pneumotórax → descompressão imediata',
        '🅣 Tamponamento cardíaco → pericardiocentese',
        '🅣 Toxinas → antídotos específicos',
        '🅣 Trombose coronária → IAM → ICP/trombólise',
        '🅣 Trombose pulmonar → TEP → trombólise',
      ],
      nextNodeId: 'asystole_cycle',
    ),

    'asystole_cycle': const AlgorithmNode(
      id: 'asystole_cycle',
      type: NodeType.action,
      title: 'Ciclo CPR — Assistolia (2 min)',
      timerSeconds: 120,
      nextNodeId: 'rhythm_check_asystole',
    ),

    'rhythm_check_asystole': const AlgorithmNode(
      id: 'rhythm_check_asystole',
      type: NodeType.question,
      title: 'Verificar Ritmo',
      options: [
        AlgorithmOption(
          label: '⚡ Ritmo chocável agora (VF/pVT)',
          nextNodeId: 'shock_1',
        ),
        AlgorithmOption(
          label: '📉 Não chocável — continuar',
          nextNodeId: 'asystole_continue',
        ),
        AlgorithmOption(
          label: '✅ ROSC',
          nextNodeId: 'rosc_detected',
        ),
      ],
    ),

    'asystole_continue': const AlgorithmNode(
      id: 'asystole_continue',
      type: NodeType.question,
      title: 'Considerar Término da Ressuscitação (TOR)',
      subtitle: 'Avaliar após múltiplos ciclos sem resposta',
      alertLevel: 'info',
      bullets: [
        'Duração da ressuscitação',
        'ETCO₂ > 10 mmHg após 20 min sugere ROSC; < 10 mmHg diminui a probabilidade, mas não é definitivo',
        'Causas reversíveis identificadas e tratadas?',
        'Desejo do paciente (diretivas antecipadas)',
        'Condição clínica prévia',
      ],
      options: [
        AlgorithmOption(
          label: '🔄 Continuar ressuscitação',
          nextNodeId: 'asystole_cycle',
        ),
        AlgorithmOption(
          label: '🛑 Encerrar ressuscitação',
          nextNodeId: 'tor',
        ),
      ],
    ),

    // ══════════════════════════════════════════════════════════
    //  BRAÇO NÃO CHOCÁVEL — PEA
    // ══════════════════════════════════════════════════════════
    'pea_path': const AlgorithmNode(
      id: 'pea_path',
      type: NodeType.action,
      title: 'PEA — Atividade Elétrica Sem Pulso',
      alertLevel: 'danger',
      bullets: [
        'CPR de alta qualidade contínua',
        '💊 Epinefrina 1 mg IV/IO — O MAIS RÁPIDO POSSÍVEL',
        'Investigar causas reversíveis URGENTE (5H5T)',
        'PEA de complexo estreito → pensar em tamponamento',
        'PEA de complexo largo → pensar hipercalemia/toxinas',
      ],
      nextNodeId: 'epi_pea',
    ),

    'epi_pea': const AlgorithmNode(
      id: 'epi_pea',
      type: NodeType.drug,
      title: 'Epinefrina — PEA',
      drug: DrugInfo(
        name: 'Epinefrina (Adrenalina)',
        dose: '1 mg',
        route: 'IV / IO',
        frequency: 'A cada 3–5 minutos',
        notes: 'Administrar o mais precocemente possível (inclusive antes da 1ª checagem). Flush 20 mL SF após cada dose.',
        color: '#EF4444',
      ),
      nextNodeId: 'pea_ultrasound',
    ),

    'pea_ultrasound': const AlgorithmNode(
      id: 'pea_ultrasound',
      type: NodeType.question,
      title: 'USG Point-of-Care (POCUS) disponível?',
      subtitle: 'Ultrassom durante PCR para identificar causas reversíveis',
      options: [
        AlgorithmOption(
          label: '✅ Sim — realizar POCUS',
          nextNodeId: 'pocus_findings',
        ),
        AlgorithmOption(
          label: '❌ Não disponível',
          nextNodeId: 'hs_ts',
        ),
      ],
    ),

    'pocus_findings': const AlgorithmNode(
      id: 'pocus_findings',
      type: NodeType.question,
      title: 'Achados no POCUS',
      subtitle: 'Interromper CPR < 10 seg para avaliação',
      options: [
        AlgorithmOption(
          label: '💧 Derrame pericárdico → Tamponamento',
          nextNodeId: 'tamponade_action',
        ),
        AlgorithmOption(
          label: '🫁 Pneumotórax → Tórax hiperecogênico',
          nextNodeId: 'pneumothorax_action',
        ),
        AlgorithmOption(
          label: '📉 VD dilatado → TEP',
          nextNodeId: 'pe_action',
        ),
        AlgorithmOption(
          label: '🫀 Hipovolemia grave',
          nextNodeId: 'hypovolemia_action',
        ),
        AlgorithmOption(
          label: '⬜ Sem achados específicos',
          nextNodeId: 'hs_ts',
        ),
      ],
    ),

    'tamponade_action': const AlgorithmNode(
      id: 'tamponade_action',
      type: NodeType.action,
      title: '💧 Tamponamento Cardíaco',
      alertLevel: 'danger',
      bullets: [
        'Pericardiocentese de emergência — IMEDIATA',
        'Acesso subxifoide guiado por USG preferível',
        'Aspirar 20–50 mL pode restaurar débito',
        'Contato com cirurgia cardíaca se disponível',
      ],
      nextNodeId: 'hs_ts',
    ),

    'pneumothorax_action': const AlgorithmNode(
      id: 'pneumothorax_action',
      type: NodeType.action,
      title: '🫁 Pneumotórax Hipertensivo',
      alertLevel: 'danger',
      bullets: [
        'Descompressão imediata — não aguardar RX',
        'Punção de alívio: 2º EIC, linha MCL',
        'Agulha 14G × 3,5 cm',
        'Drenagem torácica subsequente',
      ],
      nextNodeId: 'hs_ts',
    ),

    'pe_action': const AlgorithmNode(
      id: 'pe_action',
      type: NodeType.action,
      title: '📉 TEP Maciço — Trombólise em PCR',
      alertLevel: 'danger',
      bullets: [
        'Considerar trombólise empírica se TEP provável',
        'Alteplase 50 mg IV em bolus',
        'Continuar CPR por 60–90 min após trombólise',
        'Contato com hemodinâmica para trombectomia',
        'Considerar ECMO-CPR',
      ],
      nextNodeId: 'alteplase_drug',
    ),

    'alteplase_drug': const AlgorithmNode(
      id: 'alteplase_drug',
      type: NodeType.drug,
      title: 'Alteplase — TEP em PCR',
      drug: DrugInfo(
        name: 'Alteplase (rt-PA)',
        dose: '50 mg',
        route: 'IV bolus',
        notes: 'Manter CPR por 60–90 min após administração. Não interromper ressuscitação após trombólise.',
        color: '#3B82F6',
      ),
      nextNodeId: 'asystole_cycle',
    ),

    'hypovolemia_action': const AlgorithmNode(
      id: 'hypovolemia_action',
      type: NodeType.action,
      title: '🫀 Hipovolemia Grave',
      alertLevel: 'warning',
      bullets: [
        'Expansão volêmica rápida: 1–2L SF 0,9% / RL',
        'Se trauma: transfusão de CH + PFC (1:1)',
        'Controle do sangramento se origem identificada',
        'Clampeamento aórtico (REBOA) se disponível em trauma',
      ],
      nextNodeId: 'hs_ts',
    ),

    // ── 5H5T ────────────────────────────────────────────────
    'hs_ts': const AlgorithmNode(
      id: 'hs_ts',
      type: NodeType.info,
      title: '5H5T — Causas Reversíveis de PCR',
      subtitle: 'Identificar e tratar SIMULTANEAMENTE à ressuscitação',
      alertLevel: 'warning',
      bullets: [
        '🅗 Hipovolemia → SF/RL IV rápido',
        '🅗 Hipóxia → Ventilar, IOT, O₂ 100%',
        '🅗 Hidrogênio (acidose) → Bicarbonato apenas se pH < 7,1 ou hipercalemia resistente',
        '🅗 Hipo/Hipercalemia → ECG, corrigir K⁺',
        '🅗 Hipotermia → Reaquecimento ativo',
        '🅣 Tensão (pneumotórax) → Descompressão agulha',
        '🅣 Tamponamento → Pericardiocentese',
        '🅣 Toxinas → Naloxona (opioide), Intralipid 20% (anest. local/BCC), Gluconato de Ca²⁺ (hiperK/BCC), NaHCO₃ (tricíclicos, cocaína)',
        '🅣 Trombose coronária → IAMCSST → ICP emergência',
        '🅣 Trombose pulmonar → TEP → trombólise',
      ],
      nextNodeId: 'asystole_cycle',
    ),

    'pea_asystole_mid': const AlgorithmNode(
      id: 'pea_asystole_mid',
      type: NodeType.action,
      title: 'Não Chocável — Continuar Protocolo',
      alertLevel: 'warning',
      bullets: [
        'CPR contínua de alta qualidade',
        'Epinefrina 1mg IV/IO a cada 3–5 min',
        'Tratar causas reversíveis (5H5T)',
      ],
      nextNodeId: 'hs_ts',
    ),

    // ── ROSC ─────────────────────────────────────────────────
    'rosc_detected': const AlgorithmNode(
      id: 'rosc_detected',
      type: NodeType.action,
      title: '✅ ROSC — Retorno da Circulação Espontânea',
      alertLevel: 'success',
      subtitle: 'Iniciar cuidados pós-PCR IMEDIATAMENTE',
      bullets: [
        'Confirmar: pulso central palpável + PA mensurável',
        'Checar SpO₂, ETCO₂ (aumento súbito > 40 mmHg sugere ROSC)',
        'Suspender compressões',
      ],
      options: [
        AlgorithmOption(
          label: '🟢 Ir para Cuidados Pós-PCR',
          nextNodeId: 'post_rosc_care',
        ),
      ],
    ),

    'post_rosc_care': const AlgorithmNode(
      id: 'post_rosc_care',
      type: NodeType.end,
      title: 'Cuidados Pós-PCR (ROSC)',
      subtitle: 'Protocolo AHA 2025',
      alertLevel: 'info',
      bullets: [
        'Prevenção ativa de febre — alvo ≤ 37,5°C (NÃO induzir hipotermia ativa em todos os pacientes — AHA 2025, trial TTM2)',
        'Otimizar hemodinâmica (PAM (MAP) ≥ 65 mmHg) (evitar hipotensão)',
        'Otimizar ventilação/oxigenação (SpO₂ 92–98%) e evitar hiperoxemia',
        'Normocapnia (PaCO₂ 35–45 mmHg)',
        'Glicemia 110–180 mg/dL',
        'Realizar ECG 12 derivações (buscar supra de ST) e considerar cine coronariana de urgência se suspeita de causa isquêmica',
        'Manter antiarrítmicos contínuos (ex: Amiodarona) se utilizado',
        'Avançar para algoritmo Pós-PCR completo',
      ],
      options: [
        AlgorithmOption(
          label: 'Ir para Algoritmo Pós-PCR',
          nextNodeId: '__goto_post_rosc',
        ),
      ],
    ),

    // ── TÉRMINO DA RESSUSCITAÇÃO ─────────────────────────────
    'tor': const AlgorithmNode(
      id: 'tor',
      type: NodeType.end,
      title: '🛑 Término da Ressuscitação (TOR)',
      alertLevel: 'info',
      subtitle: 'Critérios AHA 2025',
      bullets: [
        'Ausência de ROSC após ressuscitação adequada',
        'Causas reversíveis identificadas e tratadas',
        'ETCO₂ < 10 mmHg após 20 min (coadjuvante)',
        'Decisão compartilhada com equipe',
        'Registrar hora do óbito',
        'Comunicar família com suporte emocional',
      ],
    ),
  },
);

// ═══════════════════════════════════════════════════════════════
//  ALGORITMO BRADICARDIA — AHA 2025
// ═══════════════════════════════════════════════════════════════

final bradycardiaAlgorithm = Algorithm(
  id: 'bradycardia',
  title: 'Bradicardia com Pulso',
  subtitle: 'FC < 50 bpm · Avaliação e Tratamento',
  iconEmoji: '🐢',
  color: '#3B82F6',
  startNodeId: 'brady_start',
  nodes: {
    'brady_start': const AlgorithmNode(
      id: 'brady_start',
      type: NodeType.question,
      title: 'Frequência Cardíaca',
      subtitle: 'Bradicardia clinicamente significativa: FC < 50 bpm',
      options: [
        AlgorithmOption(
          label: '🔵 FC < 50 bpm — prosseguir avaliação',
          nextNodeId: 'brady_symptoms',
        ),
        AlgorithmOption(
          label: '⚠️ FC 50–60 bpm — assintomático',
          sublabel: 'Bradicardia relativa — observar',
          nextNodeId: 'brady_monitor',
        ),
      ],
    ),

    'brady_monitor': const AlgorithmNode(
      id: 'brady_monitor',
      type: NodeType.info,
      title: 'Bradicardia Assintomática',
      alertLevel: 'info',
      bullets: [
        'Monitorização contínua (ECG, SpO₂, PA)',
        'Investigar causa subjacente',
        'Revisar medicamentos bradicardizantes',
        'Avaliar: hipotireoidismo, distúrbios eletrolíticos, IAM inferior',
      ],
      nextNodeId: 'brady_symptoms',
    ),

    'brady_symptoms': const AlgorithmNode(
      id: 'brady_symptoms',
      type: NodeType.question,
      title: 'Sinais e Sintomas de Instabilidade?',
      subtitle: 'A bradicardia está causando comprometimento hemodinâmico?',
      options: [
        AlgorithmOption(
          label: '🔴 SIM — Instável',
          sublabel: 'Hipotensão · AMS · Sinais de choque · Dor precordial isquêmica · IC aguda',
          nextNodeId: 'brady_atropine',
        ),
        AlgorithmOption(
          label: '🟡 Não — Estável com sintomas leves',
          sublabel: 'Tontura, cansaço, síncope isolada',
          nextNodeId: 'brady_type',
        ),
        AlgorithmOption(
          label: '🟢 Sem sintomas',
          nextNodeId: 'brady_type',
        ),
      ],
    ),

    'brady_atropine': const AlgorithmNode(
      id: 'brady_atropine',
      type: NodeType.drug,
      title: '🔴 Atropina — 1ª linha',
      subtitle: 'Bradicardia sintomática/instável',
      drug: DrugInfo(
        name: 'Atropina',
        dose: '1 mg',
        route: 'IV push',
        frequency: 'Repetir a cada 3–5 min se necessário',
        maxDose: 'Máx 3 mg (0,04 mg/kg)',
        notes: 'Administrar rapidamente (push). Atualização AHA 2025: dose passou de 0,5mg para 1mg. Não usar em transplantados cardíacos. Ineficaz em BAV infranodal. ⚠️ Se suspeita de BAV de alto grau / infranodal (Mobitz II ou BAVT), preparar MCP transcutâneo em paralelo — a atropina é provavelmente ineficaz nesses bloqueios.',
        color: '#3B82F6',
      ),
      nextNodeId: 'brady_atropine_response',
    ),

    'brady_atropine_response': const AlgorithmNode(
      id: 'brady_atropine_response',
      type: NodeType.question,
      title: 'Resposta à Atropina?',
      subtitle: 'Aguardar 1–2 min após cada dose',
      options: [
        AlgorithmOption(
          label: '✅ Boa resposta — FC aumentou, estabilizou',
          nextNodeId: 'brady_stable_after_atropine',
        ),
        AlgorithmOption(
          label: '❌ Sem resposta após 3 mg total',
          nextNodeId: 'brady_pacing',
        ),
        AlgorithmOption(
          label: '⚠️ Resposta parcial — instável ainda',
          nextNodeId: 'brady_pacing',
        ),
      ],
    ),

    'brady_stable_after_atropine': const AlgorithmNode(
      id: 'brady_stable_after_atropine',
      type: NodeType.info,
      title: 'Paciente Estabilizado',
      alertLevel: 'success',
      bullets: [
        'Monitorização contínua',
        'Investigar e tratar causa de base',
        'Causas reversíveis a investigar: isquemia/infarto (IAM inferior), drogas (bloqueador de canal de cálcio, betabloqueador, digoxina), hipóxia, distúrbios eletrolíticos (hipercalemia), hipotireoidismo, aumento da PIC, vagotonia.',
        'Avaliar necessidade de marcapasso definitivo',
        'Solicitar avaliação de cardiologia',
      ],
      nextNodeId: 'brady_type',
    ),

    'brady_pacing': const AlgorithmNode(
      id: 'brady_pacing',
      type: NodeType.action,
      title: '⚡ Marcapasso Transcutâneo (MCP)',
      alertLevel: 'danger',
      bullets: [
        'Sedoanalgesia antes: Midazolam + Fentanil',
        'Frequência: 60–80 bpm',
        'Iniciar corrente: 50–100 mA, aumentar até captura',
        'Confirmar captura elétrica + mecânica (pulso)',
        'Preparar marcapasso transvenoso se MCP ineficaz',
      ],
      nextNodeId: 'brady_infusion_while_pacing',
    ),

    'brady_infusion_while_pacing': const AlgorithmNode(
      id: 'brady_infusion_while_pacing',
      type: NodeType.question,
      title: 'Infusão Contínua como Ponte',
      subtitle: 'Enquanto aguarda marcapasso transvenoso',
      options: [
        AlgorithmOption(
          label: '💉 Dopamina',
          sublabel: 'Bradicardia + hipotensão',
          nextNodeId: 'dopamine_brady',
        ),
        AlgorithmOption(
          label: '💉 Epinefrina',
          sublabel: 'Bradicardia refratária',
          nextNodeId: 'epi_brady',
        ),
      ],
    ),

    'dopamine_brady': const AlgorithmNode(
      id: 'dopamine_brady',
      type: NodeType.drug,
      title: 'Dopamina — Bradicardia',
      drug: DrugInfo(
        name: 'Dopamina',
        dose: '5–20 mcg/kg/min',
        route: 'Infusão IV contínua',
        notes: 'Titular para FC e PA alvo. Efeito cronotrópico positivo > 5 mcg/kg/min.',
        color: '#3B82F6',
      ),
      nextNodeId: 'brady_type',
    ),

    'epi_brady': const AlgorithmNode(
      id: 'epi_brady',
      type: NodeType.drug,
      title: 'Epinefrina — Bradicardia Refratária',
      drug: DrugInfo(
        name: 'Epinefrina',
        dose: '2–10 mcg/min',
        route: 'Infusão IV contínua',
        notes: 'Titular para efeito. Iniciar 2 mcg/min e aumentar conforme resposta.',
        color: '#EF4444',
      ),
      nextNodeId: 'brady_type',
    ),

    'brady_type': const AlgorithmNode(
      id: 'brady_type',
      type: NodeType.question,
      title: 'Identificar Tipo de Bradicardia',
      subtitle: 'Análise do ECG de 12 derivações',
      options: [
        AlgorithmOption(
          label: '1️⃣ BAV 1º Grau',
          sublabel: 'PR > 200ms, todos conduzidos',
          nextNodeId: 'bav1_info',
        ),
        AlgorithmOption(
          label: '2️⃣ BAV 2º Grau — Mobitz I (Wenckebach)',
          sublabel: 'PR progressivo → bloqueio',
          nextNodeId: 'mobitz1_info',
        ),
        AlgorithmOption(
          label: '2️⃣ BAV 2º Grau — Mobitz II',
          sublabel: 'Bloqueio súbito sem alteração do PR',
          nextNodeId: 'mobitz2_info',
        ),
        AlgorithmOption(
          label: '3️⃣ BAV Total (BAVT)',
          sublabel: 'Dissociação AV completa',
          nextNodeId: 'bavt_info',
        ),
        AlgorithmOption(
          label: '🌿 Bradicardia Sinusal',
          nextNodeId: 'sinus_brady_info',
        ),
      ],
    ),

    'bav1_info': const AlgorithmNode(
      id: 'bav1_info',
      type: NodeType.info,
      title: 'BAV 1º Grau',
      alertLevel: 'info',
      bullets: [
        'Geralmente benigno e assintomático',
        'Causas: vagotonia, atletas, digoxina, hipotireoidismo, IAM inferior',
        'Não requer tratamento específico',
        'Monitorização + investigar causa',
      ],
    ),

    'mobitz1_info': const AlgorithmNode(
      id: 'mobitz1_info',
      type: NodeType.info,
      title: 'BAV 2º Grau — Mobitz I (Wenckebach)',
      alertLevel: 'info',
      bullets: [
        'Bloqueio nodal (suprahissiano) — geralmente benigno',
        'Causas comuns: IAM inferior, miocardite, drogas',
        'Raramente sintomático',
        'Atropina geralmente eficaz se necessário',
        'Seguimento cardiológico recomendado',
      ],
    ),

    'mobitz2_info': const AlgorithmNode(
      id: 'mobitz2_info',
      type: NodeType.info,
      title: 'BAV 2º Grau — Mobitz II ⚠️',
      alertLevel: 'warning',
      bullets: [
        'Bloqueio infranodal (infrahissiano) — instável',
        'Alto risco de progressão para BAVT',
        'Causas: IAM anterior, doença degenerativa',
        'Atropina INEFICAZ (bloqueio distal)',
        'Indicação frequente de marcapasso permanente',
        'Preparar MCP transcutâneo de standby',
      ],
    ),

    'bavt_info': const AlgorithmNode(
      id: 'bavt_info',
      type: NodeType.action,
      title: 'BAV Total (BAVT) — Conduta',
      alertLevel: 'danger',
      bullets: [
        'Dissociação AV completa — bloqueio mais grave',
        'Se instável: MCP TRANSCUTÂNEO IMEDIATO',
        'Atropina pode ser tentada (eficaz apenas no nodal)',
        'Dopamina/Epinefrina como ponte',
        'Cardiologia urgente — marcapasso transvenoso/definitivo',
        'Investigar: IAM, miocardite, Doença de Lyme, drogas',
      ],
    ),

    'sinus_brady_info': const AlgorithmNode(
      id: 'sinus_brady_info',
      type: NodeType.info,
      title: 'Bradicardia Sinusal',
      alertLevel: 'info',
      bullets: [
        'Comum em atletas, vagotônicos, durante sono',
        'Causas patológicas: hipotireoidismo, doença do nó sinusal, IAM inferior, drogas (betabloqueador, BCC, digoxina)',
        'Tratar se sintomática: Atropina 1mg IV',
        'Investigar e tratar causa de base',
      ],
    ),
  },
);

// ═══════════════════════════════════════════════════════════════
//  ALGORITMO TAQUICARDIA — AHA 2025
// ═══════════════════════════════════════════════════════════════

final tachycardiaAlgorithm = Algorithm(
  id: 'tachycardia',
  title: 'Taquicardia com Pulso',
  subtitle: 'FC > 100 bpm · Narrow vs Wide QRS',
  iconEmoji: '⚡',
  color: '#EAB308',
  startNodeId: 'tachy_start',
  nodes: {
    'tachy_start': const AlgorithmNode(
      id: 'tachy_start',
      type: NodeType.question,
      title: 'Taquicardia com Pulso',
      subtitle: 'FC > 150 bpm geralmente causa sintomas',
      options: [
        AlgorithmOption(
          label: '🔴 INSTÁVEL — sinais de comprometimento',
          sublabel: 'Hipotensão · Alteração de consciência · Choque · Dor precordial · IC aguda',
          nextNodeId: 'tachy_unstable',
        ),
        AlgorithmOption(
          label: '🟡 ESTÁVEL — sem comprometimento hemodinâmico',
          nextNodeId: 'tachy_qrs_width',
        ),
      ],
    ),

    // ── INSTÁVEL ─────────────────────────────────────────────
    'tachy_unstable': const AlgorithmNode(
      id: 'tachy_unstable',
      type: NodeType.action,
      title: 'Cardioversão Sincronizada — IMEDIATA',
      alertLevel: 'danger',
      bullets: [
        'SEDOANALGESIA (se tempo permitir, NÃO atrasar cardioversão):',
        '   - Midazolam 2-5 mg IV (0,02-0,1 mg/kg) + Fentanil 50-100 mcg IV',
        '   - Alternativas: Propofol 0,5-1 mg/kg IV ou Etomidato 0,2 mg/kg IV',
        '   - Manter material de via aérea e BVM prontos',
        '',
        'TÉCNICA DE CARDIOVERSÃO:',
        '   1. Confirmar SYNC ativado no monitor (verificar marcadores nos QRS)',
        '   2. Posicionar pás: anteroposterior (preferencial) ou anterolateral',
        '   3. Afastar todos do paciente antes do choque',
        '   4. Manter botão pressionado até disparar (há atraso pelo sync)',
        '',
        'ENERGIA INICIAL POR ARRITMIA (AHA 2025):',
        '   - FA: 200 J bifásico (energia inicial de escolha — AHA 2025)',
        '   - Flutter Atrial: 200 J bifásico (AHA 2025 padronizou)',
        '   - TSV/TRNAV: 100 J bifásico (AHA 2025)',
        '   - TV monomórfica com pulso: 100 J bifásico',
        '',
        'ATENÇÃO — TV POLIMÓRFICA / TORSADES:',
        '   - Tratar como FV: DESFIBRILAÇÃO (modo NÃO sincronizado)',
        '   - Energia: 200 J bifásico (dose de desfibrilação)',
        '   - Sincronismo pode falhar (QRS aberrantes enganam o monitor)',
        '',
        'Se falhar o 1o choque: escalonar energia e verificar contato das pás',
      ],
      nextNodeId: 'cardioversion_response',
    ),

    'cardioversion_response': const AlgorithmNode(
      id: 'cardioversion_response',
      type: NodeType.question,
      title: 'Resposta à Cardioversão?',
      options: [
        AlgorithmOption(
          label: '✅ Converteu para ritmo sinusal',
          nextNodeId: 'tachy_post_cardioversion',
        ),
        AlgorithmOption(
          label: '❌ Não converteu — refratário',
          nextNodeId: 'tachy_refractory',
        ),
        AlgorithmOption(
          label: '⚡ Deteriorou → PCR',
          nextNodeId: '__goto_cardiac_arrest',
        ),
      ],
    ),

    'tachy_post_cardioversion': const AlgorithmNode(
      id: 'tachy_post_cardioversion',
      type: NodeType.info,
      title: 'Converteu — Ritmo Sinusal',
      alertLevel: 'success',
      bullets: [
        'MONITORIZAÇÃO PÓS-CARDIOVERSÃO:',
        '   - ECG 12 derivações imediatamente',
        '   - Monitorização contínua por pelo menos 2-4 horas',
        '   - PA, FC, SpO2 a cada 15 min na 1a hora',
        '',
        'INVESTIGAR CAUSA DE BASE:',
        '   - Eletrólitos: K+ (manter > 4,0), Mg2+ (manter > 2,0), Ca2+ (ionizado ≥ 1,1 mmol/L ou total 8,5–10,5 mg/dL)',
        '   - Função tireoidiana (hipertireoidismo)',
        '   - Ecocardiograma (função VE, valvulopatias)',
        '   - Troponina se suspeita de SCA',
        '',
        'ANTICOAGULAÇÃO (se FA/Flutter):',
        '   - CHA2DS2-VASc >= 2 (homens) ou >= 3 (mulheres): anticoagular',
        '   - DOAC preferencial (Apixaban, Rivaroxaban, Edoxaban, Dabigatrana)',
        '   - Manter anticoagulação por mínimo 4 semanas após cardioversão',
        '',
        'PROFILAXIA DE RECORRÊNCIA:',
        '   - FA/Flutter: considerar antiarrítmico de manutenção',
        '   - Consulta com cardiologista/eletrofisiologista eletiva',
        '   - Avaliar indicação de ablação por cateter',
      ],
    ),

    'tachy_refractory': const AlgorithmNode(
      id: 'tachy_refractory',
      type: NodeType.action,
      title: 'Cardioversão Refratária',
      alertLevel: 'danger',
      bullets: [
        'DEFINIÇÃO: Persistência da arritmia após >= 1 choque sincronizado adequado.',
        '',
        'PASSO 1 - OTIMIZAR O CHOQUE:',
        '   - Aumentar energia para MÁXIMO do desfibrilador (tipicamente 360 J monofásico / 200 J bifásico)',
        '   - Trocar posição das pás: se anterolateral, mudar para anteroposterior',
        '   - Verificar e melhorar contato das pás (gel, pressão firme)',
        '   - Aplicar técnica de dupla cardioversão sequencial (double sequential) se disponível 2 desfibriladores',
        '',
        'PASSO 2 — ANTIARRÍTMICO IV ANTES DE NOVA TENTATIVA:',
        '   A escolha depende do tipo de arritmia:',
        '',
        '   FA/Flutter refratários:',
        '     - 1a opção: Amiodarona 150 mg IV em 10 min',
        '     - (Procainamida é alternativa na TV monomórfica, NÃO na FA refratária)',
        '     - Em Torsades/hipoMg: Sulfato de Magnésio 2 g IV em 10 min',
        '',
        '   TSV refratária (pós-adenosina e pós-choque):',
        '     - Diltiazem 20 mg IV em 2 min (se não houver hipotensão)',
        '     - Ou Verapamil 5 mg IV em 2 min',
        '',
        '   TV monomórfica refratária:',
        '     - 1a opção: Amiodarona 150 mg IV em 10 min',
        '     - 2a opção: Lidocaína 1-1,5 mg/kg IV em bolus',
        '     - 3a opção: Procainamida 20 mg/min IV',
        '',
        '   TV polimórfica / Torsades (QT longo):',
        '     - MgSO4 2 g IV em 2-5 min (1a linha obrigatória)',
        '     - Isoproterenol ou overdrive pacing se bradicardia-dependente',
        '     - NAO usar amiodarona (prolonga QT e piora Torsades)',
        '',
        'PASSO 3 — REPETIR CARDIOVERSÃO:',
        '   - Aguardar 10-15 min após infusão do antiarrítmico',
        '   - Repetir choque na energia máxima com posição otimizada',
        '   - Máximo 3 tentativas de cardioversão antes de reavaliar estratégia',
        '',
        'PASSO 4 — SE AINDA REFRATÁRIO:',
        '   - Consulta eletrofisiologista URGENTE',
        '   - Considerar controle de frequência e aceitar a arritmia',
        '   - Excluir causas reversíveis: hipocalemia, hipomagnesemia, hipertireoidismo, isquemia',
        '   - UTI para monitorização e infusão contínua de antiarrítmico',
      ],
      nextNodeId: 'amio_cardioversion',
    ),

    'amio_cardioversion': const AlgorithmNode(
      id: 'amio_cardioversion',
      type: NodeType.drug,
      title: 'Amiodarona — Cardioversão Refratária',
      drug: DrugInfo(
        name: 'Amiodarona',
        dose: '150 mg diluídos em 100 mL de SG 5%',
        route: 'IV em 10 minutos (bomba de infusão)',
        frequency: 'Pode repetir 150 mg IV a cada 10 min (máx 6 doses). Após controle: manutenção 1 mg/min por 6h, depois 0,5 mg/min por 18h.',
        maxDose: 'Máx 2,2 g em 24h',
        notes: 'CUIDADOS: (1) Usar acesso venoso central ou veia calibrosa (flebite se periférico). (2) Monitorar PA (hipotensão e bradicardia). (3) Após infusão do antiarrítmico, aguardar 10-15 min e REPETIR cardioversão elétrica na energia máxima com pás em posição anteroposterior. (4) Se TV polimórfica com QT longo (Torsades): NÃO usar amiodarona — preferir MgSO4 2 g IV.',
        color: '#A855F7',
      ),
      nextNodeId: 'tachy_qrs_width',
    ),

    // ── ESTÁVEL — AVALIAÇÃO POR QRS ──────────────────────────
    'tachy_qrs_width': const AlgorithmNode(
      id: 'tachy_qrs_width',
      type: NodeType.question,
      title: 'Largura do QRS',
      subtitle: 'Medir em derivação com melhor visualização',
      options: [
        AlgorithmOption(
          label: '🔵 QRS Estreito < 120 ms',
          sublabel: 'TSV / Flutter / FA',
          nextNodeId: 'narrow_regular',
        ),
        AlgorithmOption(
          label: '🔴 QRS Largo ≥ 120 ms',
          sublabel: 'TV Monomórfica / Polimórfica',
          nextNodeId: 'wide_regular',
        ),
      ],
    ),

    // ── QRS ESTREITO ──────────────────────────────────────────
    'narrow_regular': const AlgorithmNode(
      id: 'narrow_regular',
      type: NodeType.question,
      title: 'QRS Estreito — Regular ou Irregular?',
      options: [
        AlgorithmOption(
          label: '📏 Regular',
          nextNodeId: 'narrow_regular_action',
        ),
        AlgorithmOption(
          label: '〰️ Irregular',
          sublabel: 'FA / Pré-excitação (WPW + FA)',
          nextNodeId: 'narrow_irregular',
        ),
      ],
    ),

    'narrow_regular_action': const AlgorithmNode(
      id: 'narrow_regular_action',
      type: NodeType.question,
      title: 'QRS Estreito Regular — Qual o Diagnóstico?',
      subtitle: 'Selecione o ritmo identificado',
      options: [
        AlgorithmOption(
          label: '🔵 TSV — Taquicardia Supraventricular (TRNAV/TRNA)',
          sublabel: 'Reentrada nodal (TRNAV) ou via acessória (TRNA) — onset/offset súbito, sem onda P visível (~60%) ou onda P retrógrada (~30%)',
          nextNodeId: 'tsv_strategy',
        ),
        AlgorithmOption(
          label: '🟠 Flutter Atrial',
          sublabel: 'Ondas F em "dente de serra" — Flutter 2:1 típico',
          nextNodeId: 'flutter_strategy',
        ),
      ],
    ),

    'tsv_strategy': const AlgorithmNode(
      id: 'tsv_strategy',
      type: NodeType.question,
      title: 'TSV — Estratégia de Tratamento',
      subtitle: 'Manobra Vagal → Adenosina → Cardioversão',
      ecgImages: ['assets/ecg/trnav.png', 'assets/ecg/tsv.png'],
      options: [
        AlgorithmOption(
          label: '🤸 Manobra Vagal primeiro',
          sublabel: 'Valsalva modificado ou massagem seio carotídeo',
          nextNodeId: 'vagal_maneuver',
        ),
        AlgorithmOption(
          label: '💊 Ir direto para Adenosina',
          nextNodeId: 'adenosine_drug',
        ),
      ],
    ),

    'vagal_maneuver': const AlgorithmNode(
      id: 'vagal_maneuver',
      type: NodeType.action,
      title: 'Manobra Vagal',
      alertLevel: 'info',
      bullets: [
        '✅ Valsalva Modificado (posição supina → pernas elevadas):',
        '   Expirar forçado 15 seg → decúbito dorsal imediato + elevar pernas 45°',
        '   Manter por 15 seg (mais eficaz que Valsalva clássico)',
        '⚠️ Massagem do Seio Carotídeo:',
        '   Auscultar antes (descartar sopro carotídeo)',
        '   Massagem unilateral 5–10 seg com monitorização',
        '   CI: história de AVC, sopro carotídeo, EP carotídeo',
      ],
      nextNodeId: 'vagal_response',
    ),

    'vagal_response': const AlgorithmNode(
      id: 'vagal_response',
      type: NodeType.question,
      title: 'Resposta à Manobra Vagal?',
      options: [
        AlgorithmOption(
          label: '✅ Converteu para sinusal',
          nextNodeId: 'tachy_post_cardioversion',
        ),
        AlgorithmOption(
          label: '❌ Sem conversão',
          nextNodeId: 'adenosine_drug',
        ),
      ],
    ),

    'adenosine_drug': const AlgorithmNode(
      id: 'adenosine_drug',
      type: NodeType.drug,
      title: 'Adenosina — QRS Estreito Regular',
      drug: DrugInfo(
        name: 'Adenosina',
        dose: '6 mg (1ª dose) → 12 mg (2ª dose) → 12 mg (3ª dose)',
        route: 'IV push RÁPIDO — acesso proximal + flush 20 mL rápido',
        frequency: '1–2 min entre doses',
        maxDose: 'Máx 30 mg total',
        notes: 'Avisar o paciente sobre sensação de aperto no peito (transitório). CI: asma grave, WPW+FA, BAV 2/3 grau.',
        color: '#22C55E',
      ),
      nextNodeId: 'adenosine_response',
    ),

    'adenosine_response': const AlgorithmNode(
      id: 'adenosine_response',
      type: NodeType.question,
      title: 'Resposta à Adenosina?',
      options: [
        AlgorithmOption(
          label: '✅ Converteu para sinusal — TRNAV/TRNA',
          nextNodeId: 'tachy_post_cardioversion',
        ),
        AlgorithmOption(
          label: '📉 Revelou Fibrilação Atrial',
          nextNodeId: 'narrow_irregular',
        ),
        AlgorithmOption(
          label: '📉 Revelou Flutter Atrial',
          nextNodeId: 'flutter_strategy',
        ),
        AlgorithmOption(
          label: '❌ Sem resposta — taquicardia atrial provável',
          nextNodeId: 'tachy_atrial',
        ),
      ],
    ),

    'tachy_atrial': const AlgorithmNode(
      id: 'tachy_atrial',
      type: NodeType.action,
      title: 'Taquicardia Atrial / Ectópica',
      alertLevel: 'info',
      bullets: [
        'ECG 12 derivações para confirmar',
        'Betabloqueador IV (Metoprolol 5 mg) OU Verapamil 5-10 mg — NUNCA ambos juntos (risco de assistolia)',
        'Evitar Verapamil/BCC se disfunção ventricular ou IC',
        'Consulta cardiológica/eletrofisiologia',
        'Investigar: hipóxia, sepse, tireotoxicose, digoxina',
      ],
    ),

    // ── QRS ESTREITO IRREGULAR ────────────────────────────────
    'narrow_irregular': const AlgorithmNode(
      id: 'narrow_irregular',
      type: NodeType.question,
      title: 'QRS Estreito Irregular — Tipo',
      options: [
        AlgorithmOption(
          label: '🔵 Fibrilação Atrial (FA)',
          sublabel: 'Linha de base irregular, sem ondas P',
          nextNodeId: 'afib_strategy',
        ),
        AlgorithmOption(
          label: '⚡ Pré-excitação (WPW + FA)',
          sublabel: 'QRS irregular + delta waves',
          nextNodeId: 'wpw_fa',
        ),
      ],
    ),

    'afib_strategy': const AlgorithmNode(
      id: 'afib_strategy',
      type: NodeType.question,
      title: 'FA — Estratégia de Tratamento',
      subtitle: 'Duração da FA é crucial para decisão',
      ecgImage: 'assets/ecg/fa.png',
      options: [
        AlgorithmOption(
          label: '⏱️ FA < 48h — Controle de ritmo',
          sublabel: 'Cardioversão possível sem anticoagulação prévia',
          nextNodeId: 'afib_rhythm_control',
        ),
        AlgorithmOption(
          label: '📅 FA > 48h ou duração desconhecida',
          sublabel: 'Controle de frequência + anticoagulação',
          nextNodeId: 'afib_rate_control',
        ),
      ],
    ),

    'afib_rhythm_control': const AlgorithmNode(
      id: 'afib_rhythm_control',
      type: NodeType.action,
      title: 'FA < 48h — Controle de Ritmo',
      alertLevel: 'warning',
      bullets: [
        '⚡ Cardioversão elétrica sincronizada: ≥ 200 J bifásico (AHA 2025)',
        '   • Sedar sempre que possível (midazolam, propofol, etomidato)',
        '   • NÃO atrasar cardioversão se instável por falta de sedação',
        '   • Se refratário: aumentar energia e repetir',
        '',
        '💊 Cardioversão química (alternativa):',
        '   • Propafenona 450–600 mg VO (pill-in-pocket)',
        '   • Ibutilide 1 mg IV em 10 min (monitorização de QT)',
        '   • Amiodarona 150 mg IV em 10 min',
        '',
        '🛡️ SEGURANÇA:',
        '   • Verificar K⁺ > 4,0 mEq/L e Mg²⁺ > 2,0 mg/dL',
        '   • ECG 12 derivações: descartar pré-excitação (WPW) antes',
        '',
        '📋 Anticoagulação:',
        '   • Iniciar heparina ou DOAC antes/durante cardioversão',
        '   • ETE se cardioversão eletiva sem anticoagulação prévia',
      ],
    ),

    'afib_rate_control': const AlgorithmNode(
      id: 'afib_rate_control',
      type: NodeType.action,
      title: 'FA/Flutter — Controle de Frequência',
      subtitle: 'Drogas em ordem de preferência (AHA 2025 / ACC/AHA 2023)',
      alertLevel: 'info',
      bullets: [
        '🎯 Meta: FC < 110 bpm em repouso (lenient); FC < 80 se sintomático (strict)',
        '',
        '🥇 1ª LINHA — Diltiazem IV (PREFERÍVEL — AHA 2025):',
        '   • Diltiazem 0,25 mg/kg IV em 2 min',
        '   • Se necessário: 2ª dose 0,35 mg/kg IV após 15 min',
        '   • Manutenção: 5–15 mg/h em BIC',
        '   • Reavaliar PA aos 2 min após bolus',
        '   ⚠️ CI: IC com FE reduzida, hipotensão, BAV 2–3º',
        '   💡 AHA 2025: Diltiazem IV é superior ao metoprolol IV para controle de FC em FA/Flutter',
        '',
        '🥇 1ª LINHA (alternativa) — Betabloqueadores IV:',
        '   • Metoprolol 2,5–5 mg IV em 2 min (repetir a cada 5 min, máx 15 mg)',
        '   • Esmolol 500 mcg/kg bolus → 50–200 mcg/kg/min (ultra-curto, ideal titular)',
        '   ⚠️ CI: IC descompensada, asma/DPOC grave, BAV 2–3º, bradicardia, cocaína',
        '   🚫 NUNCA combinar BCC IV + BB IV (risco de assistolia/bloqueio total)',
        '',
        '🥈 2ª LINHA — Digoxina (adjuvante):',
        '   • Digoxina 0,25–0,5 mg IV → repetir 0,25 mg a cada 6h (máx 1,5 mg/24h)',
        '   • Início de ação lento (1–4h): NÃO usar para controle agudo isolado',
        '   • Útil como adjuvante + BB/BCC, ou em IC com FE reduzida',
        '   ⚠️ CI: hipocalemia, insuficiência renal (ajustar dose)',
        '',
        '🥉 3ª LINHA — Amiodarona (reserva):',
        '   • Amiodarona 300 mg IV em 1h → manutenção 10–50 mg/h',
        '   • Usar APENAS se BCC, BB e Digoxina falharem ou CI',
        '   • Tem efeito de controle de ritmo E frequência',
        '   ⚠️ CI: QT longo, doença tireoidiana, hepatopatia',
        '',
        '🛡️ SEGURANÇA PRÉ-CARDIOVERSÃO:',
        '   • Verificar K⁺ > 4,0 mEq/L e Mg²⁺ > 2,0 mg/dL',
        '   • Corrigir eletrólitos antes da cardioversão',
        '',
        '📋 ANTICOAGULAÇÃO:',
        '   • Obrigatória ≥ 3 semanas antes de cardioversão eletiva',
        '   • ou ETE para excluir trombo atrial esquerdo',
        '   • Avaliar CHA₂DS₂-VASc para anticoagulação crônica',
        '   • Cardioversão elétrica sincronizada: 200 J bifásico (AHA 2025)',
      ],
    ),

    'flutter_strategy': const AlgorithmNode(
      id: 'flutter_strategy',
      type: NodeType.action,
      title: 'Flutter Atrial — Conduta (AHA 2025)',
      ecgImage: 'assets/ecg/flutter.png',
      alertLevel: 'warning',
      bullets: [
        '⚡ Cardioversão elétrica sincronizada: 200 J bifásico (AHA 2025)',
        '   • NÃO usar 50–100 J (subterapia — diretriz anterior)',
        '   • Se refratário: aumentar energia',
        '   • Sedar sempre que possível (NÃO atrasar se instável)',
        '',
        '💊 Controle de frequência (se estável):',
        '   • 1ª linha: Diltiazem 0,25 mg/kg IV (AHA 2025 — superior ao metoprolol)',
        '   • Alternativa: Metoprolol 2,5–5 mg IV',
        '   • Se CI a BCC/BB: Amiodarona 300 mg IV em 1h',
        '',
        '⚠️ Flutter com condução 1:1: instabilidade comum — cardioversão imediata',
        '',
        '📋 Anticoagulação:',
        '   • Mesmas regras da FA (CHA₂DS₂-VASc)',
        '   • Verificar K⁺ > 4,0 e Mg²⁺ > 2,0 antes de cardioverter',
        '',
        '🎯 Ablação por cateter: tratamento definitivo do flutter típico',
      ],
    ),

    'wpw_fa': const AlgorithmNode(
      id: 'wpw_fa',
      type: NodeType.action,
      title: '⚠️ WPW + FA — Situação de Risco!',
      ecgImage: 'assets/ecg/wpw_fa.png',
      ecgImageHeight: 150,
      alertLevel: 'danger',
      bullets: [
        '🚫 DROGAS PROIBIDAS: Adenosina, BCC, BB, Digoxina',
        '   • Bloqueiam nó AV → aceleram condução pela via acessória → FV',
        '',
        '⚡ SE INSTÁVEL:',
        '   • Cardioversão elétrica sincronizada 200 J IMEDIATA',
        '   • Sedar se possível, mas NÃO atrasar',
        '',
        '💊 SE ESTÁVEL:',
        '   • 1ª opção: Procainamida 20–50 mg/min IV (máx 17 mg/kg)',
        '     Parar se: hipotensão, QRS ↑ >50%, ou dose máxima',
        '   • 2ª opção: Amiodarona 150 mg IV em 10 min',
        '   • Alternativa: Ibutilide 1 mg IV em 10 min',
        '   • Cardioversão sincronizada se falha ou instabilização',
        '',
        '🎯 DEFINITIVO: Ablação da via acessória (encaminhamento urgente)',
        '',
        '⚠️ ECG 12 derivações: verificar delta waves + intervalo PR curto',
        '   antes de decidir medicação em QUALQUER taquicardia irregular',
      ],
    ),

    // ── QRS LARGO ─────────────────────────────────────────────
    'wide_regular': const AlgorithmNode(
      id: 'wide_regular',
      type: NodeType.question,
      title: 'QRS Largo — Taquicardia Ventricular?',
      subtitle: 'Tratar como TV até provar o contrário',
      options: [
        AlgorithmOption(
          label: '🔴 TV Monomórfica — Estável',
          sublabel: 'QRS uniformes, morfologia constante',
          nextNodeId: 'vt_stable',
        ),
        AlgorithmOption(
          label: '🔴 TV Polimórfica (Torsades)',
          sublabel: 'QRS variável, QTc longo',
          nextNodeId: 'torsades',
        ),
        AlgorithmOption(
          label: '🔵 TSV com Aberrância',
          sublabel: 'Critérios de Brugada/LBBB típico',
          nextNodeId: 'svt_aberrancy',
        ),
      ],
    ),

    'vt_stable': const AlgorithmNode(
      id: 'vt_stable',
      type: NodeType.action,
      title: 'TV Monomórfica Estável — Antiarrítmico',
      ecgImage: 'assets/ecg/tv_mono.png',
      alertLevel: 'warning',
      bullets: [
        'Infusão de Antiarrítmicos (1ª escolha se estável):',
        '   • Procainamida 20–50 mg/min (máx 17 mg/kg)',
        '   • Amiodarona 150 mg IV em 10 min',
        '   • Sotalol 100 mg (1,5 mg/kg) IV em 5 min',
        'Sequência: antiarrítmico IV → se falhar ou instabilizar, cardioversão elétrica sincronizada (100 J bifásico)',
        'Consultar Especialista (Cardiologia/Eletrofisiologia)',
        'Se FE reduzida ou IC: Amiodarona preferencial',
      ],
      nextNodeId: 'amio_vt',
    ),

    'amio_vt': const AlgorithmNode(
      id: 'amio_vt',
      type: NodeType.drug,
      title: 'Amiodarona — TV Estável',
      drug: DrugInfo(
        name: 'Amiodarona',
        dose: '150 mg IV em 10 min',
        route: 'IV lento',
        frequency: 'Manutenção: 1 mg/min por 6h, depois 0,5 mg/min por 18h',
        maxDose: 'Máx 2,2 g/24h',
        notes: 'Monitorizar PA (hipotensão) e QTc. Preferir em disfunção ventricular.',
        color: '#A855F7',
      ),
    ),

    'torsades': const AlgorithmNode(
      id: 'torsades',
      type: NodeType.action,
      title: 'Torsades de Pointes',
      ecgImage: 'assets/ecg/tv_poli.png',
      alertLevel: 'danger',
      bullets: [
        '💊 Sulfato de Magnésio 2 g IV em 1–2 min — AGORA',
        'Corrigir hipocalemia (K⁺ > 4,5 mEq/L)',
        'Suspender TODOS os medicamentos que prolongam QTc',
        'Overdrive pacing se recorrente',
        'Isoproterenol se FC muito baixa',
        'Se instável: desfibrilação (não sincronizado)',
      ],
      nextNodeId: 'magnesium_drug',
    ),

    'magnesium_drug': const AlgorithmNode(
      id: 'magnesium_drug',
      type: NodeType.drug,
      title: 'Sulfato de Magnésio — Torsades',
      drug: DrugInfo(
        name: 'Sulfato de Magnésio',
        dose: '2 g (4 mL MgSO₄ 50%)',
        route: 'IV em 1–2 min',
        frequency: 'Repetir 2g em 10 min se necessário; depois manutenção 1-2 g/h',
        notes: 'Monitorizar reflexos patelares (sinal de toxicidade). Antídoto: Gluconato de Cálcio.',
        color: '#22C55E',
      ),
    ),

    'svt_aberrancy': const AlgorithmNode(
      id: 'svt_aberrancy',
      type: NodeType.action,
      title: 'TSV com Aberrância — Conduta',
      ecgImages: ['assets/ecg/tsv_aberrancia_v1.png', 'assets/ecg/tsv_aberrancia_dii.png'],
      alertLevel: 'info',
      bullets: [
        'Se dúvida entre TV e TSV — tratar como TV',
        'Adenosina 6 mg IV pode ser diagnóstica/terapêutica',
        '   (Se TSV+BRE: converte. Se TV: sem efeito ou piora)',
        'Cardioversão sincronizada se deteriorar',
        'Evitar Verapamil em QRS largo (perigoso em TV)',
      ],
    ),
  },
);

// ═══════════════════════════════════════════════════════════════
//  ALGORITMO PÓS-PCR — AHA 2025
// ═══════════════════════════════════════════════════════════════

final postRoscAlgorithm = Algorithm(
  id: 'post_rosc',
  title: 'Cuidados Pós-PCR (ROSC)',
  subtitle: 'Otimização pós-ressuscitação · AHA 2025',
  iconEmoji: '🟢',
  color: '#22C55E',
  startNodeId: 'post_rosc_start',
  nodes: {
    'post_rosc_start': const AlgorithmNode(
      id: 'post_rosc_start',
      type: NodeType.info,
      title: 'ROSC Confirmado — Iniciar Protocolo Pós-PCR',
      alertLevel: 'success',
      subtitle: 'Tratar pós-PCR como continuação da ressuscitação',
      bullets: [
        '✅ Pulso central palpável confirmado',
        'Monitorização contínua: ECG, SpO₂, capnografia, PA invasiva',
        'Checar glicemia, gasometria arterial, eletrólitos',
        'Avançar para avaliação de via aérea',
      ],
      nextNodeId: 'post_airway',
    ),

    'post_airway': const AlgorithmNode(
      id: 'post_airway',
      type: NodeType.question,
      title: 'Manejo da Via Aérea',
      subtitle: 'Metas ventilatórias pós-PCR',
      options: [
        AlgorithmOption(
          label: '🫁 Paciente intubado — ajustar ventilador',
          nextNodeId: 'ventilator_settings',
        ),
        AlgorithmOption(
          label: '😮 Paciente acordado, ventilando',
          nextNodeId: 'conscious_post_rosc',
        ),
      ],
    ),

    'ventilator_settings': const AlgorithmNode(
      id: 'ventilator_settings',
      type: NodeType.info,
      title: '🫁 Parâmetros Ventilatórios Alvo',
      alertLevel: 'info',
      bullets: [
        '🩸 SpO₂: 92–98% (evitar hipoxemia < 92% e hiperoxemia)',
        '💨 FiO₂: titular para SpO₂ alvo (começar 100%, reduzir)',
        '📊 ETCO₂: 35–45 mmHg',
        '🌬️ PaCO₂: 35–45 mmHg (normocapnia)',
        '📏 Volume corrente: 6–8 mL/kg peso ideal',
        '⚠️ EVITAR hipocapnia (vasoconstricção cerebral)',
      ],
      nextNodeId: 'post_hemodynamics',
    ),

    'conscious_post_rosc': const AlgorithmNode(
      id: 'conscious_post_rosc',
      type: NodeType.info,
      title: 'Paciente Consciente Pós-ROSC',
      alertLevel: 'success',
      bullets: [
        'O₂ suplementar: manter SpO₂ 92–98%',
        'Monitorização contínua',
        'Avaliar nível de consciência (Escala de Glasgow)',
        'ECG 12 derivações — pesquisar IAM',
        'Avançar para avaliação hemodinâmica',
      ],
      nextNodeId: 'post_hemodynamics',
    ),

    'post_hemodynamics': const AlgorithmNode(
      id: 'post_hemodynamics',
      type: NodeType.info,
      title: '💉 Metas Hemodinâmicas',
      alertLevel: 'warning',
      bullets: [
        '🎯 PAM ≥ 65–70 mmHg',
        '🎯 PAS ≥ 90 mmHg',
        '💊 Norepinefrina: vasopressor de 1ª escolha',
        '💊 Dobutamina: se disfunção miocárdica + hipotensão',
        '💧 Expansão volêmica criteriosa (avaliar euvolemia)',
        '📊 Monitorizar débito cardíaco se disponível',
      ],
      nextNodeId: 'norepi_infusion',
    ),

    'norepi_infusion': const AlgorithmNode(
      id: 'norepi_infusion',
      type: NodeType.drug,
      title: 'Norepinefrina — Suporte Hemodinâmico Pós-PCR',
      drug: DrugInfo(
        name: 'Norepinefrina',
        dose: '0,05–1 mcg/kg/min',
        route: 'Infusão IV contínua (acesso central preferencial)',
        notes: 'Iniciar em 0,05–0,1 mcg/kg/min e titular para PAM ≥ 65 mmHg. Monitorização invasiva recomendada.',
        color: '#EF4444',
      ),
      nextNodeId: 'post_ecg',
    ),

    'post_ecg': const AlgorithmNode(
      id: 'post_ecg',
      type: NodeType.question,
      title: 'ECG Pós-ROSC — Elevação de ST?',
      subtitle: 'Realizar ECG 12 derivações IMEDIATAMENTE',
      options: [
        AlgorithmOption(
          label: '🔴 IAMCSST — Elevação de ST confirmada',
          nextNodeId: 'stemi_post_rosc',
        ),
        AlgorithmOption(
          label: '🟡 IAMSST / ECG não diagnóstico',
          nextNodeId: 'nstemi_post_rosc',
        ),
        AlgorithmOption(
          label: '🟢 ECG normal ou LBBB prévio documentado',
          sublabel: '⚠️ LBBB novo = tratar como IAMCSST',
          nextNodeId: 'ttm_decision',
        ),
      ],
    ),

    'stemi_post_rosc': const AlgorithmNode(
      id: 'stemi_post_rosc',
      type: NodeType.action,
      title: '🔴 IAMCSST + ROSC — ICP Primária',
      alertLevel: 'danger',
      bullets: [
        'Ativar hemodinâmica IMEDIATAMENTE',
        'ICP primária recomendada mesmo em pacientes comatosos',
        'Meta: D2B (porta-balão) ≤ 90 min',
        'Antiagregação: AAS 300 mg + Ticagrelor 180 mg (VO/SNG)',
        'Anticoagulação: Heparina 70–100 UI/kg IV',
        'Controle de temperatura alvo após ICP',
      ],
      nextNodeId: 'ttm_decision',
    ),

    'nstemi_post_rosc': const AlgorithmNode(
      id: 'nstemi_post_rosc',
      type: NodeType.action,
      title: '🟡 IAMSST Pós-PCR — Conduta',
      alertLevel: 'warning',
      bullets: [
        'Coronariografia precoce (< 24h) se causa cardíaca provável',
        'AAS 300 mg VO/SNG',
        'Anticoagulação com Heparina',
        'Decisão individualizada com cardiologia',
        'Ecocardiograma urgente: FE, motilidade, derrame',
      ],
      nextNodeId: 'ttm_decision',
    ),

    'ttm_decision': const AlgorithmNode(
      id: 'ttm_decision',
      type: NodeType.question,
      title: 'Controle de Temperatura Alvo (TTM)',
      subtitle: 'Para pacientes comatosos após PCR (GCS < 8)',
      options: [
        AlgorithmOption(
          label: '😴 Comatoso — Iniciar TTM',
          sublabel: 'Glasgow < 8 após ROSC',
          nextNodeId: 'ttm_protocol',
        ),
        AlgorithmOption(
          label: '😊 Acordado / responsivo',
          nextNodeId: 'post_rosc_monitoring',
        ),
      ],
    ),

    'ttm_protocol': const AlgorithmNode(
      id: 'ttm_protocol',
      type: NodeType.info,
      title: '❄️ Controle de Temperatura Alvo (TTM)',
      alertLevel: 'info',
      bullets: [
        'AHA 2025: Prevenção ativa de febre — alvo ≤ 37,5°C (tratar febre ≥ 37,7°C) por pelo menos 72 horas em pacientes comatosos (estratégia de escolha — trial TTM2)',
        'Hipotermia ativa 32–34°C: NÃO é rotina — individualizar caso a caso. Se optar por TTM ativo, manter a temperatura escolhida (32–37,5°C) por ≥ 24h após atingir o alvo',
        'Métodos de resfriamento (quando indicados):',
        '   • Bolsas de gelo nas axilas/virilhas',
        '   • Cateter endovascular / Cobertor refrescante',
        '   • ⚠️ NÃO usar soro gelado IV no pré-hospitalar',
        'Monitorizar: temperatura central (vesical/esofágica)',
        'Sedação + bloqueio neuromuscular para evitar tremores',
      ],
      nextNodeId: 'post_rosc_monitoring',
    ),

    'post_rosc_monitoring': const AlgorithmNode(
      id: 'post_rosc_monitoring',
      type: NodeType.info,
      title: '📊 Monitorização Contínua UTI',
      alertLevel: 'info',
      bullets: [
        '🧠 EEG contínuo: excluir crises subclínicas',
        '🩸 Glicemia: alvo 140–180 mg/dL (evitar hipoglicemia)',
        '💊 Profilaxia convulsões: não routineiramente',
        '🫀 Ecocardiograma: FE, avaliar disfunção miocárdica',
        '🧪 Biomarcadores: troponina, lactato serial',
        '🩻 TC crânio: excluir AVC isquêmico/hemorrágico',
      ],
      nextNodeId: 'neuroprognostication',
    ),

    'neuroprognostication': const AlgorithmNode(
      id: 'neuroprognostication',
      type: NodeType.info,
      title: '🧠 Neuroprognosticação',
      alertLevel: 'warning',
      bullets: [
        'NÃO prognosticar precocemente (≥ 72h após normotermia — AHA 2025)',
        'Aguardar: efeito de sedativos, TTM, temperatura normalizando',
        'Exames multimodais após 72–120h:',
        '   • Reflexos de tronco (pupilas, córnea)',
        '   • SSEP: ausência bilateral N20',
        '   • EEG: padrão supressão-surto, status epiléptico',
        '   • RM crânio: lesão anóxica difusa',
        '   • NSE sérica > 60 mcg/L (prognóstico desfavorável)',
        'Decisão compartilhada com família',
      ],
    ),
  },
);

// ═══════════════════════════════════════════════════════════════
//  ALGORITMO SCA — IAMCSST (AHA 2025)
// ═══════════════════════════════════════════════════════════════

final scaAlgorithm = Algorithm(
  id: 'sca',
  title: 'SCA — IAM com Supra de ST',
  subtitle: 'IAMCSST · Reperfusão Urgente',
  iconEmoji: '❤️‍🔥',
  color: '#F97316',
  startNodeId: 'sca_start',
  nodes: {
    'sca_start': const AlgorithmNode(
      id: 'sca_start',
      type: NodeType.question,
      title: 'Passo 1 — Suspeita Clínica',
      subtitle: 'Suspeita de Síndrome Coronariana Aguda',
      bullets: [
        'Dor precordial, peso, pressão',
        'Irradiação para braço E, mandíbula, dorso',
        'Dor em repouso > 20 min',
        'Equivalentes: dispneia, epigastralgia, síncope (idosos/diabéticos)',
      ],
      options: [
        AlgorithmOption(
          label: '🔴 Suspeita alta — obter ECG imediato',
          nextNodeId: 'ecg_sca',
        ),
        AlgorithmOption(
          label: '🟡 Baixa probabilidade',
          nextNodeId: 'sca_low_risk',
        ),
      ],
    ),

    'ecg_sca': const AlgorithmNode(
      id: 'ecg_sca',
      type: NodeType.action,
      title: 'Passo 2 — ECG (≤ 10 minutos)',
      alertLevel: 'danger',
      bullets: [
        'ECG 12 derivações nos primeiros 10 min da chegada',
        'Leitura por médico experiente',
        'Repetir em 15–30 min se o primeiro não diagnóstico',
        'Derivações adicionais: V3R, V4R (IAM inferior/VD)',
        'V7, V8, V9 (IAM posterior)',
        '🩸 Coletar: troponina hs, hemograma, creatinina, coagulograma, eletrólitos, glicemia',
        '⚠️ Troponina NÃO deve atrasar a decisão de reperfusão — tratar com base no ECG e na clínica',
      ],
      nextNodeId: 'ecg_result_sca',
    ),

    'ecg_result_sca': const AlgorithmNode(
      id: 'ecg_result_sca',
      type: NodeType.question,
      title: 'Passo 3 — Resultado do ECG',
      options: [
        AlgorithmOption(
          label: '🔴 Supradesnivelamento de ST ≥ 1mm em ≥ 2 derivações contíguas',
          sublabel: 'ou BRE novo / presumivelmente novo',
          nextNodeId: 'stemi_confirmed',
        ),
        AlgorithmOption(
          label: '🟡 Infradesnivelamento de ST ou inversão de T',
          nextNodeId: 'nstemi_path',
        ),
        AlgorithmOption(
          label: '🟢 ECG normal ou inespecífico',
          nextNodeId: 'sca_low_risk',
        ),
      ],
    ),

    'stemi_confirmed': const AlgorithmNode(
      id: 'stemi_confirmed',
      type: NodeType.question,
      title: 'Passo 4 — Conduta Inicial IAMCSST (STEMI)',
      alertLevel: 'danger',
      bullets: [
        '⏱️ TEMPO É MÚSCULO — iniciar tratamento EM PARALELO',
        '💊 AAS 300 mg VO (mascar) — AGORA',
        '💊 P2Y12: Se ICP → Ticagrelor 180mg ou Prasugrel 60mg. Se trombólise → Clopidogrel 300mg (75mg se ≥75a).',
        '💉 Anticoagulação: Se ICP → HNF 70-100 UI/kg IV. Se trombólise → HNF 60 UI/kg IV + infusão.',
        '💨 O₂ apenas se SpO₂ < 90%',
        '💉 Morfina se dor severa (cautela)',
        '💊 Nitrato se PA > 90 mmHg (CI: VD ou PDE5i)',
        '💊 Betabloqueador ORAL nas primeiras 24h se estável (sem choque/IC/BAV) — evitar IV rotineiro',
        '💊 Estatina de alta potência',
        '⚠️ Definir estratégia de reperfusão ANTES do 2º antiagregante e anticoagulação!',
      ],
      options: [
        AlgorithmOption(
          label: '➡️ Prosseguir para Estratégia de Reperfusão',
          nextNodeId: 'reperfusion_strategy',
        ),
        AlgorithmOption(
          label: '⚠️ Ver Manejo de Complicações',
          sublabel: 'IAM de VD, Posterior, Arritmias',
          nextNodeId: 'sca_complications',
        ),
      ],
    ),

    'sca_complications': const AlgorithmNode(
      id: 'sca_complications',
      type: NodeType.question,
      title: 'Manejo de Complicações no IAM',
      alertLevel: 'warning',
      bullets: [
        'Selecione a complicação identificada para ver o manejo específico:',
      ],
      options: [
        AlgorithmOption(
          label: '🫀 IAM de Ventrículo Direito (VD)',
          nextNodeId: 'sca_comp_vd',
        ),
        AlgorithmOption(
          label: '📉 IAM Posterior (V7, V8, V9)',
          nextNodeId: 'sca_comp_posterior',
        ),
        AlgorithmOption(
          label: '⚡ Arritmias na Fase Aguda',
          nextNodeId: 'sca_comp_arrhythmias',
        ),
        AlgorithmOption(
          label: '➡️ Voltar para Estratégia de Reperfusão',
          nextNodeId: 'reperfusion_strategy',
        ),
      ]
    ),

    'sca_comp_vd': const AlgorithmNode(
      id: 'sca_comp_vd',
      type: NodeType.action,
      title: 'Manejo: IAM de VD',
      alertLevel: 'danger',
      bullets: [
        '⚠️ Diagnóstico: Suspeitar em todo IAM inferior. Confirmar com V3R e V4R (>1mm de supra).',
        '❌ CONTRAINDICADOS: Nitratos (nitroglicerina), diuréticos e vasodilatadores — reduzem drasticamente a pré-carga, causando hipotensão severa.',
        '❌ Morfina: Usar com extrema cautela (efeito venodilatador).',
        '💧 Reposição Volêmica: Tratamento inicial para hipotensão. Dar alíquotas de 250-500 mL de SF 0,9% (guiado por ausculta pulmonar/congestão).',
        '💊 Inotrópicos: Se refratário a volume, iniciar Dobutamina para suporte inotrópico.',
        '⚡ Manter sincronia AV: O VD isquêmico depende muito da contração atrial. BAVs devem ser tratados precocemente.',
      ],
      nextNodeId: 'reperfusion_strategy',
    ),

    'sca_comp_posterior': const AlgorithmNode(
      id: 'sca_comp_posterior',
      type: NodeType.info,
      title: 'Manejo: IAM Posterior',
      alertLevel: 'warning',
      bullets: [
        '⚠️ Diagnóstico: Infra de ST isolado e persistente em V1-V3 + ondas R amplas e proeminentes nestas derivações.',
        '✅ Confirmação: Solicitar derivações posteriores (V7, V8, V9). Supra ≥ 0,5 mm confirma o diagnóstico (≥ 1 mm se homem < 40 anos).',
        '🔴 Tratamento: É um equivalente de IAM com Supra (STEMI). Acionar protocolo de ICP primária ou trombólise, não tratar como NSTEMI!',
      ],
      nextNodeId: 'reperfusion_strategy',
    ),

    'sca_comp_arrhythmias': const AlgorithmNode(
      id: 'sca_comp_arrhythmias',
      type: NodeType.action,
      title: 'Manejo: Arritmias Agudas no IAM',
      alertLevel: 'danger',
      bullets: [
        '⚡ Fibrilação Atrial (FA) Rápida:',
        '   • Instabilidade hemodinâmica → Cardioversão Elétrica Sincronizada IMEDIATA.',
        '   • Estável → Controle de frequência com Betabloqueador (preferencial se não houver CI) ou Amiodarona (se CI a BB ou IC aguda).',
        '',
        '⚡ Taquicardia Ventricular Não Sustentada (TVNS):',
        '   • Comum nas primeiras 24h. Em geral, não requer antiarrítmicos profiláticos.',
        '   • Otimizar K+ (> 4,0) e Mg2+ (> 2,0). Manter Betabloqueador se sem contraindicações.',
        '',
        '⚡ Bloqueio Atrioventricular (BAV) no IAM Inferior:',
        '   • Ocorre por isquemia do nó AV (a. coronária direita) ou aumento do tônus vagal.',
        '   • Se instável (hipotensão/choque): Atropina 1mg IV (máx 3mg).',
        '   • Se refratário: Marcapasso transcutâneo → Marcapasso transvenoso se persistir.',
      ],
      nextNodeId: 'reperfusion_strategy',
    ),

    'reperfusion_strategy': const AlgorithmNode(
      id: 'reperfusion_strategy',
      type: NodeType.question,
      title: 'Estratégia de Reperfusão',
      subtitle: 'Onde o paciente está? Quanto tempo para ICP?',
      alertLevel: 'warning',
      bullets: [
        '⚠️ Se INR > 1,7 ou plaquetas < 100.000: trombólise é CONTRAINDICADA (preferir ICP)',
        '⏱️ A decisão depende da disponibilidade de hemodinâmica e do tempo estimado de transferência (FMC-to-device)',
      ],
      options: [
        AlgorithmOption(
          label: '🏥 Hospital COM hemodinâmica',
          sublabel: 'ICP Primária — meta FMC-device ≤90 min',
          nextNodeId: 'pci_primary',
        ),
        AlgorithmOption(
          label: '🚑 Sem hemodinâmica — transferência ≤120 min factível',
          sublabel: 'Transferir para ICP — meta FMC-device ≤120 min',
          nextNodeId: 'pci_transfer',
        ),
        AlgorithmOption(
          label: '⏱️ Sem hemodinâmica — transferência >120 min',
          sublabel: 'Avaliar trombólise vs ICP tardia',
          nextNodeId: 'no_transfer_decision',
        ),
      ],
    ),

    'pci_primary': const AlgorithmNode(
      id: 'pci_primary',
      type: NodeType.action,
      title: '🏥 ICP Primária',
      alertLevel: 'danger',
      bullets: [
        'Ativar laboratório de hemodinâmica IMEDIATAMENTE',
        'Meta Porta-Balão (D2B): ≤ 90 min (≤ 60 min se IAM extenso ou grande área de risco)',
        '💊 Dose de ataque Inibidor P2Y12 (Ordem de Preferência):',
        '   1. Ticagrelor 180 mg (Preferencial)',
        '   2. Prasugrel 60 mg (CI absoluta: AVC/AIT prévio. Se >75 anos ou <60kg: dose manutenção reduzida 5 mg/dia)',
        '   3. Clopidogrel 600 mg (Alternativa)',
        '💉 HNF: 70–100 UI/kg IV bolus (ajustar por ACT na sala)',
        'Acesso radial preferencial (menos sangramentos)',
        '🔬 Imagem intracoronariana (IVUS/OCT) — Classe IIa em casos selecionados (AHA 2025)',
        '🔄 Revascularização completa recomendada (culpada + não-culpadas) — mesmo procedimento ou estagiado (Classe I, AHA 2025)',
        '⚠️ Inibidor GPIIb/IIIa (Tirofiban/Abciximab): uso BAILOUT/resgate apenas (alta carga trombótica, no-reflow). NÃO usar de rotina se já recebeu Ticagrelor ou Prasugrel.',
      ],
      nextNodeId: 'post_pci_care',
    ),

    'post_pci_care': const AlgorithmNode(
      id: 'post_pci_care',
      type: NodeType.info,
      title: 'Pós-ICP — Cuidados na UTI Coronariana',
      alertLevel: 'warning',
      bullets: [
        '💊 DAPT: AAS 75–100 mg/dia + P2Y12 (Ticagrelor 90mg 12/12h ou Prasugrel 10mg/dia). Manter por 12 meses (1–3 meses se alto risco hemorrágico)',
        '💊 Betabloqueador oral: Metoprolol 25–50 mg 12/12h ou Carvedilol 3,125–6,25 mg 12/12h — iniciar nas primeiras 24h (se estável, sem choque, IC ou BAV)',
        '💊 Estatina alta potência: Atorvastatina 80 mg ou Rosuvastatina 40 mg — iniciar nas primeiras 24h, independente do LDL (Classe I)',
        '💊 IECA/BRA: iniciar em 24h se FE ≤ 40%, HAS, DM ou IAM anterior (ex: Enalapril 2,5 mg VO)',
        '💊 Espironolactona 25 mg: se FE ≤ 40% + IC ou DM (Cr ≤ 2,5 homem / ≤ 2,0 mulher e K+ < 5,0 mEq/L)',
        '📊 Ecocardiograma para avaliar FE nas primeiras 24–48h',
        '🎯 Alvo de PA sistólica: 120–130 mmHg na UTI (evitar hipotensão)',
        '💧 Prevenção de nefropatia por contraste: hidratação com SF 1 mL/kg/h (se FE preservada). Minimizar volume de contraste em IRC, DM, idosos.',
        '📋 Monitorizar: sangramentos, ritmo, PA, acesso vascular',
      ],
    ),

    // ── TRANSFERÊNCIA PARA ICP (≤120 min) ─────────────────────
    'pci_transfer': const AlgorithmNode(
      id: 'pci_transfer',
      type: NodeType.action,
      title: '🚑 Transferência para ICP',
      subtitle: 'Meta FMC-to-device ≤120 min',
      alertLevel: 'danger',
      bullets: [
        '🚑 Acionar transporte (SAMU / UTI Móvel) IMEDIATAMENTE',
        '⏱️ Meta: FMC-to-device ≤120 min',
        '💊 AAS 300 mg já administrado (confirmar)',
        '💊 Ticagrelor 180 mg (preferencial) OU Prasugrel 60 mg (se sem AVC/AIT prévio, > 75a ou < 60kg: dose reduzida 5 mg/dia) — administrar ANTES da transferência',
        '💉 HNF: 70–100 UI/kg IV bolus (ajustar por ACT na chegada ao centro receptor)',
        '📞 Contatar centro receptor — ativar hemodinâmica antes da chegada',
        '📋 Enviar ECG por telemedicina ao centro receptor',
        '',
        '💡 CONSIDERAR TROMBÓLISE em vez da transferência se TODOS presentes:',
        '   • IAM inferior pequeno (supra limitado a DII, DIII, aVF)',
        '   • Sem extensão para VD (V3R, V4R negativos)',
        '   • Sem instabilidade hemodinâmica',
        '   • Sintomas com menos de 3 horas ("hora dourada" — CAPTIM Trial)',
        '   • Sem contraindicações à trombólise',
        '   → Nas primeiras 2-3h, trombólise tem eficácia equivalente à ICP',
      ],
      nextNodeId: 'post_pci_care',
    ),

    // ── SEM TRANSFERÊNCIA RÁPIDA (>120 min) ──────────────────
    'no_transfer_decision': const AlgorithmNode(
      id: 'no_transfer_decision',
      type: NodeType.question,
      title: '⏱️ Sem Transferência Rápida — Avaliar Conduta',
      subtitle: 'FMC-to-device estimado >120 min',
      alertLevel: 'warning',
      bullets: [
        'Regra geral: Trombólise se janela ≤12h e sem contraindicações',
        '⚠️ PORÉM: algumas situações exigem ICP mesmo com tempo >120 min',
      ],
      options: [
        AlgorithmOption(
          label: '💉 Trombólise — paciente estável, sem CI',
          sublabel: 'Janela ≤12h, meta porta-agulha ≤30 min',
          nextNodeId: 'thrombolysis_stemi',
        ),
        AlgorithmOption(
          label: '🚨 ICP mesmo >120 min — alto risco',
          sublabel: 'Choque, IAM anterior extenso, TV/FV, CI trombólise',
          nextNodeId: 'rescue_transfer',
        ),
      ],
    ),

    // ── ICP OBRIGATÓRIA MESMO >120 min ───────────────────────
    'rescue_transfer': const AlgorithmNode(
      id: 'rescue_transfer',
      type: NodeType.action,
      title: '🚨 ICP Obrigatória — Transferir Mesmo >120 min',
      alertLevel: 'danger',
      bullets: [
        '⚠️ A trombólise NÃO é opção neste cenário. Transferir para ICP é a única via.',
        '🚑 Acionar transporte de emergência para centro com hemodinâmica',
        '📞 Contatar centro receptor com urgência',
        '',
        '🔴 INDICAÇÕES (qualquer um presente):',
        '   🫀 Choque cardiogênico (PA <90 + hipoperfusão) — trombólise ineficaz no choque',
        '   ⚡ TV sustentada ou FV recorrente — restaurar fluxo mecanicamente',
        '   🔴 IAM anterior extenso (V1-V6 ou BRE novo) — ICP dramaticamente superior',
        '   🔴 IAM de VD (supra V3R/V4R) — trombólise menos eficaz em câmara de baixa pressão',
        '   💊 Anticoagulante oral (INR >2,5 ou DOAC) — CI absoluta à trombólise',
        '   🩸 INR >1,7 ou plaquetas <100.000 — risco hemorrágico proibitivo',
        '   ⛔ Qualquer contraindicação absoluta à trombólise',
        '   🔧 CABG prévio — trombólise menos eficaz em trombo de enxerto',
        '   ⏰ >12h de sintomas — trombólise fora da janela',
        '',
        '💡 Suporte circulatório no choque:',
        '   • Impella CP (Classe IIa, AHA 2025 — benefício demonstrado no DanGer-SHOCK)',
        '   • BIA (Classe IIb): opção se Impella indisponível — sem evidência de redução de mortalidade, usar como suporte de transição',
      ],
      nextNodeId: 'post_pci_care',
    ),

    'thrombolysis_stemi': const AlgorithmNode(
      id: 'thrombolysis_stemi',
      type: NodeType.question,
      title: 'Estratégia Fibrinolítica — Trombólise',
      subtitle: 'Terapia adjuvante + Contraindicações',
      alertLevel: 'warning',
      bullets: [
        '💊 Dose de ataque P2Y12 (exclusivo p/ Trombólise): Clopidogrel 300mg (75mg se > 75 anos)',
        '💉 HNF: 60 UI/kg IV em bolus (máx 4000 UI) + infusão de 12 UI/kg/h (máx 1000 UI/h)',
        '⚠️ Checar contraindicações absolutas ANTES de administrar o trombolítico!',
      ],
      options: [
        AlgorithmOption(
          label: '✅ Sem contraindicações — escolher fibrinolítico',
          nextNodeId: 'fibrinolytic_choice',
        ),
        AlgorithmOption(
          label: '❌ Contraindicação absoluta presente',
          nextNodeId: 'thrombolysis_ci',
        ),
      ],
    ),

    'fibrinolytic_choice': const AlgorithmNode(
      id: 'fibrinolytic_choice',
      type: NodeType.question,
      title: 'Escolha do Fibrinolítico',
      subtitle: 'TNK é preferencial (bolus único). Alteplase é alternativa válida.',
      options: [
        AlgorithmOption(
          label: '💉 Tenecteplase (TNK) — Preferencial',
          sublabel: 'Bolus único IV. Mais prático.',
          nextNodeId: 'tenecteplase_drug',
        ),
        AlgorithmOption(
          label: '💉 Alteplase (rt-PA) — Alternativa',
          sublabel: 'Infusão em 90 min',
          nextNodeId: 'alteplase_drug',
        ),
      ],
    ),

    'thrombolysis_ci': const AlgorithmNode(
      id: 'thrombolysis_ci',
      type: NodeType.info,
      title: '⚠️ Contraindicações Absolutas à Trombólise',
      alertLevel: 'danger',
      bullets: [
        'AVC hemorrágico prévio (qualquer época)',
        'AVC isquêmico < 3 meses',
        'Neoplasia ou lesão vascular intracraniana',
        'Traumatismo cranioencefálico grave < 3 meses',
        'Dissecção aórtica',
        'Sangramento interno ativo (exceto menstruação)',
        'Cirurgia/procedimento maior < 3 semanas',
        'PA sistólica > 180 mmHg ou diastólica > 110 mmHg não controlada (refratária)',
        'Endocardite infecciosa',
        '→ Se ALGUMA contraindicação absoluta presente: transferência urgente para ICP',
        '⚠️ Se INR ou plaquetas pendentes e história suspeita: considerar ICP como via mais segura',
      ],
    ),

    'tenecteplase_drug': const AlgorithmNode(
      id: 'tenecteplase_drug',
      type: NodeType.drug,
      title: 'Tenecteplase (TNK) — IAMCSST',
      drug: DrugInfo(
        name: 'Tenecteplase (TNK)',
        dose: 'Baseado no peso:\n< 60 kg: 30 mg\n60–70 kg: 35 mg\n70–80 kg: 40 mg\n80–90 kg: 45 mg\n> 90 kg: 50 mg\n⚠️ IDOSOS ≥75 anos: usar MEIA DOSE',
        route: 'IV bolus em 5–10 seg',
        notes: 'IDOSOS ≥75 anos: meia dose (STREAM Trial). Administrar junto com Heparina. Meta porta-agulha ≤ 30 min. Indicar se FMC-to-device previsto > 120 min (AHA 2025). Transferir para hemodinâmica após. Sinais de reperfusão: alívio da dor, ↓ST >50%, arritmias de reperfusão.',
        color: '#F97316',
      ),
      nextNodeId: 'post_thrombolysis',
    ),

    'alteplase_drug': const AlgorithmNode(
      id: 'alteplase_drug',
      type: NodeType.drug,
      title: 'Alteplase (rt-PA) — IAMCSST',
      drug: DrugInfo(
        name: 'Alteplase (rt-PA)',
        dose: '15 mg IV bolus\n+ 0,75 mg/kg IV em 30 min (máx 50 mg)\n+ 0,5 mg/kg IV em 60 min (máx 35 mg)\nDose total máxima: 100 mg',
        route: 'IV bolus + infusão (90 min total)',
        notes: 'Alternativa ao TNK. Esquema acelerado de 90 min. Administrar junto com HNF. Meta porta-agulha ≤ 30 min. Transferir para hemodinâmica após.',
        color: '#F97316',
      ),
      nextNodeId: 'post_thrombolysis',
    ),

    'post_thrombolysis': const AlgorithmNode(
      id: 'post_thrombolysis',
      type: NodeType.question,
      title: 'Pós-Trombólise — Avaliar Resposta (60-90 min)',
      alertLevel: 'warning',
      bullets: [
        '⏱️ Avaliar critérios de reperfusão 60-90 min após administração do trombolítico',
        '📊 ECG seriado — comparar supra ST com ECG inicial',
        '💉 Manter HNF: infusão contínua por 48h',
        '📋 Monitorizar: sangramentos, PA, ritmo cardíaco',
        '',
        '✅ Critérios de reperfusão:',
        '   • Redução do supra ST ≥50% em relação ao ECG inicial',
        '   • Alívio ou resolução da dor precordial',
        '   • Arritmias de reperfusão (RIVA — ritmo idioventricular acelerado)',
      ],
      options: [
        AlgorithmOption(
          label: '✅ Sucesso — ST caiu ≥50% + dor resolveu',
          sublabel: 'Reperfusão bem-sucedida',
          nextNodeId: 'thrombolysis_success',
        ),
        AlgorithmOption(
          label: '❌ Falha — ST não caiu ou dor persiste',
          sublabel: 'ICP de resgate IMEDIATA',
          nextNodeId: 'rescue_pci',
        ),
      ],
    ),

    // ── SUCESSO DA TROMBÓLISE ────────────────────────────────
    'thrombolysis_success': const AlgorithmNode(
      id: 'thrombolysis_success',
      type: NodeType.info,
      title: '✅ Trombólise Bem-Sucedida — Estratégia Fármaco-Invasiva',
      alertLevel: 'info',
      bullets: [
        '🏥 Coronariografia (cine) em 3–24 horas (Classe I, AHA 2025)',
        '💊 DAPT: AAS 75–100 mg/dia + P2Y12 de manutenção (Ticagrelor 90 mg 12/12h [preferencial] ou Prasugrel 10 mg/dia). *NÃO trocar o Clopidogrel para Ticagrelor/Prasugrel antes da cine*',
        '💉 Manter HNF em infusão contínua até a cine',
        '📊 ECG seriado a cada 6h nas primeiras 24h',
        '📋 Monitorizar sangramentos, especialmente no acesso vascular',
        '⚠️ Se reoclusão (retorno do supra ST + dor) → ICP de resgate imediata',
      ],
      nextNodeId: 'adjuvant_therapy_stemi',
    ),

    // ── ICP DE RESGATE (FALHA DA TROMBÓLISE) ─────────────────
    'rescue_pci': const AlgorithmNode(
      id: 'rescue_pci',
      type: NodeType.action,
      title: '🚨 FALHA da Trombólise — ICP de Resgate IMEDIATA',
      alertLevel: 'danger',
      bullets: [
        '⛔ NÃO repetir dose do trombolítico — risco hemorrágico proibitivo',
        '🚑 Ativar hemodinâmica / transferir COM URGÊNCIA',
        '⏱️ Não esperar — a cada minuto há perda de miocárdio',
        '📞 Contatar centro receptor — informar falha de trombólise',
        '💉 Manter HNF em infusão contínua durante o transporte',
        '💊 NÃO administrar novo P2Y12 antes da cine — risco de sangramento',
      ],
      nextNodeId: 'post_pci_care',
    ),

    'adjuvant_therapy_stemi': const AlgorithmNode(
      id: 'adjuvant_therapy_stemi',
      type: NodeType.info,
      title: 'Terapia Adjuvante Pós-Reperfusão',
      alertLevel: 'info',
      bullets: [
        '💊 DAPT: AAS 75–100 mg/dia + P2Y12 (Ticagrelor 90mg 12/12h ou Prasugrel 10mg/dia). Manter por 12 meses (1–3 meses se alto risco hemorrágico)',
        '💊 Betabloqueador oral: Metoprolol 25–50 mg VO 12/12h (se estável, sem IC descompensada)',
        '💊 Estatina alta potência: Atorvastatina 80 mg ou Rosuvastatina 40 mg',
        '💊 IECA/BRA: iniciar em 24h se FE ≤ 40% ou sinais de IC (ex: Enalapril 2,5 mg VO)',
        '💊 Espironolactona 25 mg: se FE ≤ 40% + IC ou DM (Cr ≤ 2,5 homem / ≤ 2,0 mulher e K+ < 5,0 mEq/L)',
        '📊 Ecocardiograma para avaliar FE nas primeiras 24–48h',
        '🎯 Alvo de PA sistólica: 120–130 mmHg na UTI (evitar hipotensão)',
      ],
    ),

    'nstemi_path': const AlgorithmNode(
      id: 'nstemi_path',
      type: NodeType.action,
      title: 'Passo 4 — Conduta IAMSST / Angina Instável (NSTEMI)',
      alertLevel: 'warning',
      bullets: [
        '💊 AAS 300 mg VO',
        '💊 P2Y12: Ticagrelor 180 mg na admissão (NÃO usar prasugrel antes da anatomia/cine)',
        '💉 Anticoagulação: Enoxaparina 1 mg/kg SC 12/12h (ajustar se ClCr < 30)',
        '💊 Betabloqueador: Metoprolol 25–50 mg VO 12/12h (se sem CI)',
        '💊 Nitroglicerina 0,4 mg SL a cada 5 min (máx 3x) se PA > 90 mmHg (CI: VD ou PDE5i)',
        '💊 Estatina de alta intensidade: Atorvastatina 80 mg VO ou Rosuvastatina 40 mg VO',
        '📊 Estratificação de risco: escore GRACE / TIMI',
        '🏥 Coronariografia: timing por risco (precoce < 24h se alto risco)',
      ],
    ),

    'sca_low_risk': const AlgorithmNode(
      id: 'sca_low_risk',
      type: NodeType.info,
      title: 'Baixo Risco — Avaliação Seriada',
      alertLevel: 'info',
      bullets: [
        'Troponina ultrassensível: coleta 0h e 1–3h',
        'Escore HEART / EDACS para estratificação',
        'ECG serial a cada 30 min nas primeiras 2h',
        'Se troponina negativa serial + ECG normal + baixo risco: alta com seguimento',
        'Se qualquer positivo: internação + estratificação',
      ],
    ),
  },
);

// ═══════════════════════════════════════════════════════════════
//  ALGORITMO AVC — Acidente Vascular Cerebral (AHA/ASA 2026)
//  Inclui: NIHSS passo a passo, Alteplase/TNK, Trombectomia, Basilar
// ═══════════════════════════════════════════════════════════════

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
        'FAST-ED ≥ 4 → alta probabilidade de LVO',
      ],
      didacticCards: {
        'FAST-ED — Como Aplicar': 'F — Face (0-1)\nPeça para sorrir.\n• 0 = simétrico\n• 1 = queda facial unilateral\n\nA — Arm (0-2)\nBraços estendidos por 10 seg.\n• 0 = normal\n• 1 = desvio ou fraqueza leve\n• 2 = queda total do braço\n\nS — Speech (0-2)\nPeça repetir frase simples.\n• 0 = normal\n• 1 = fala arrastada ou troca de palavras\n• 2 = não fala ou não compreende\n\nE — Eye deviation (0-2)\nObservar olhos em repouso.\n• 0 = normal\n• 1 = preferência do olhar (reversível)\n• 2 = desvio conjugado fixo\n\nD — Denial/Neglect (0-2)\nAvalia NEGLECT e ANOSOGNOSIA:\n\nNeglect tátil: toque ambas as mãos simultaneamente — percebe os dois lados?\nNeglect visual: mostre dedos nos dois campos visuais simultaneamente — vê ambos?\nAnosognosia: pergunte se tem fraqueza — nega o déficit óbvio?\n\n• 0 = percebe tudo, sem negação\n• 1 = ignora 1 modalidade (visual OU tátil) OU nega 1 déficit\n• 2 = ignora 2 modalidades OU nega completamente todos os déficits\n\nTotal: 0-9 pontos\n≥ 4 → alta probabilidade de LVO → rotear para TSC/CSC',
        'Alternativas: CPSSS, LAMS, RACE': 'CPSSS: olhar conjugado + pergunta + comando. ≥ 2 sugere LVO.\nLAMS: Los Angeles Motor Scale.\nRACE: Rapid Arterial oCclusion Evaluation.\n\nTodas identificam LVO para encaminhar à trombectomia.',
        'O que é LVO?': 'Oclusão de artéria cerebral proximal (carótida interna, M1, basilar).\nPacientes com LVO se beneficiam de trombectomia endovascular (EVT) além da trombólise IV.\nO FAST identifica o AVC. O FAST-ED tria o LVO — são etapas distintas.',
      },
      nextNodeId: 'lvo_q',
    ),
    'lvo_q': const AlgorithmNode(
      id: 'lvo_q',
      type: NodeType.question,
      title: 'Há suspeita de LVO?',
      options: [
        AlgorithmOption(label: 'NÃO', nextNodeId: 'route_nearest'),
        AlgorithmOption(label: 'SIM', nextNodeId: 'transport_q'),
      ],
    ),
    'route_nearest': const AlgorithmNode(
      id: 'route_nearest',
      type: NodeType.action,
      title: 'Centro de AVC Mais Próximo',
      bullets: [
        'Transportar para o centro certificado mais próximo (ASRH, PSC, TSC ou CSC)',
        'Fazer notificação pré-hospitalar',
      ],
      didacticCards: {
        'Classificação dos Centros de AVC': 'ASRH — Acute Stroke Ready Hospital:\n• Estabilização inicial e avaliação\n• Pode administrar trombolítico IV\n• Transfere para PSC/TSC/CSC se necessário\n\nPSC — Primary Stroke Center:\n• Trombólise IV 24/7\n• TC disponível 24h\n• Equipe de AVC treinada\n• Protocolos de transferência para EVT\n\nTSC — Thrombectomy-Capable Stroke Center:\n• Tudo do PSC + trombectomia mecânica 24/7\n• Neurorradiologia intervencionista\n\nCSC — Comprehensive Stroke Center:\n• Tudo do TSC + neurocirurgia\n• UTI neurológica dedicada\n• Capacidade de tratar AVCh e HSA\n• Pesquisa e ensino\n\nQuanto mais grave o AVC, mais alto o nível do centro necessário.',
      },
      nextNodeId: 'code_stroke',
    ),
    'transport_q': const AlgorithmNode(
      id: 'transport_q',
      type: NodeType.question,
      title: 'Centro com trombectomia (TSC/CSC) a < 30 min adicionais?',
      options: [
        AlgorithmOption(label: 'SIM — Levar direto ao TSC/CSC', nextNodeId: 'code_stroke'),
        AlgorithmOption(label: 'NÃO — Levar ao mais próximo (trombólise + transferir)', nextNodeId: 'route_nearest'),
      ],
    ),
    // ═══════════════════════════════════════════════
    // HOSPITAL
    // ═══════════════════════════════════════════════
    'code_stroke': const AlgorithmNode(
      id: 'code_stroke',
      type: NodeType.action,
      title: 'Código AVC — Chegada ao Hospital',
      alertLevel: 'danger',
      bullets: [
        'Ativar equipe de AVC imediatamente',
        'Avaliação geral: ≤ 10 min',
        'NIHSS + Imagem (TC/RM): ≤ 20 min',
        'Acesso IV, ECG, labs (glicemia, coagulograma)',
      ],
      didacticCards: {
        'Metas de Tempo (AHA 2025)': 'Avaliação geral imediata: ≤ 10 min\nAvaliação neurológica (NIHSS): ≤ 20 min\nAquisição de TC/RM de crânio: ≤ 20 min\nInterpretação da imagem: ≤ 45 min\nAdministração de trombolítico (porta-agulha): ≤ 60 min (ideal ≤ 30 min)\n\nIVT deve ser iniciado o mais rápido possível — cada minuto conta.',
        'Coletas e Exames': 'Glicemia capilar (IMEDIATA — não atrasar imagem)\nHemograma + plaquetas\nTP/INR e TTPa\nFunção renal (creatinina)\nTroponina\nECG 12 derivações (FA = causa cardioembólica em 25%)\n\n⚠️ Apenas a GLICEMIA deve ser obtida ANTES da trombólise. Os demais exames NÃO devem atrasar o tratamento (exceto se suspeita de coagulopatia).',
      },
      nextNodeId: 'ct_scan',
    ),
    'ct_scan': const AlgorithmNode(
      id: 'ct_scan',
      type: NodeType.action,
      title: 'Imagem de Crânio (TC + Angio-TC)',
      bullets: [
        'TC sem contraste (NCCT) — descartar hemorragia',
        'Angio-TC — recomendada para TODO AVC isquêmico agudo',
        'Interpretação: ≤ 45 min da chegada',
      ],
      didacticCards: {
        'O que avaliar na TC?': '1. Hemorragia intracraniana (exclui trombólise)\n2. Sinais precoces de isquemia (hipodensidade, apagamento de sulcos)\n3. ASPECTS — Alberta Stroke Program Early CT Score (0-10)\n   • ASPECTS ≥ 6 = território isquêmico limitado (favorável)\n   • ASPECTS < 6 = área extensa (avaliar individualmente)\n4. Sinal da artéria hiperdensa (trombo proximal → sugere LVO)',
        'Por que Angio-TC para TODOS?': 'A triagem pré-hospitalar (FAST-ED) tem sensibilidade de 60-80%.\nIsso significa que 20-40% das LVOs NÃO são detectadas no campo.\n\nA Angio-TC no hospital é o exame DEFINITIVO para:\n• Confirmar ou descobrir LVO (ACI, M1, M2, basilar)\n• Definir anatomia vascular e planejamento de EVT\n• Identificar estenoses, dissecções e variantes\n\n⚠️ A Angio-TC NÃO deve atrasar a trombólise IV.\nSe o paciente é elegível para trombólise → administrar PRIMEIRO, Angio-TC pode ser feita durante ou logo após.\n\nSe a Angio-TC revelar LVO em paciente que veio para centro SEM trombectomia → iniciar transferência IMEDIATA (drip-and-ship).',
      },
      nextNodeId: 'hemorrhage_q',
    ),
    'hemorrhage_q': const AlgorithmNode(
      id: 'hemorrhage_q',
      type: NodeType.question,
      title: 'Há hemorragia na imagem?',
      options: [
        AlgorithmOption(label: 'SIM — Hemorrágico', nextNodeId: 'hemorrhagic_stroke'),
        AlgorithmOption(label: 'NÃO — Isquêmico', nextNodeId: 'ischemic_eval'),
      ],
    ),
    'hemorrhagic_stroke': const AlgorithmNode(
      id: 'hemorrhagic_stroke',
      type: NodeType.action,
      title: 'AVC Hemorrágico',
      alertLevel: 'danger',
      bullets: [
        'NÃO usar trombolíticos ou antitrombóticos',
        'PA: redução RÁPIDA para < 140 mmHg (INTERACT-3)',
        'Consultar neurocirurgia imediatamente',
        'Reverter anticoagulantes se em uso',
      ],
      didacticCards: {
        'Reversão de Anticoagulantes': 'Varfarina (INR elevado):\n• Vitamina K 10 mg IV + CCP 4 fatores (25-50 UI/kg)\n\nDabigatrana:\n• Idarucizumab 5 g IV (antídoto específico)\n\nRivaroxabana / Apixabana / Edoxabana (anti-Xa):\n• Andexanet alfa (se disponível)\n• CCP 4 fatores 50 UI/kg (alternativa)\n\nHeparina:\n• Protamina 1 mg para cada 100 UI de HNF',
        'PA no AVCh': 'Meta: PAS < 140 mmHg o mais rápido possível (INTERACT-3)\n\nDrogas:\n• Nicardipina 5-15 mg/h\n• Labetalol 10-20 mg IV a cada 10-20 min\n• Nitroprussiato (se refratário)\n\n⚠️ A regra de "reduzir até 15% em 24h" é do AVC ISQUÊMICO sem reperfusão — NÃO se aplica ao hemorrágico!',
      },
      nextNodeId: 'stroke_unit',
    ),
    // ═══════════════════════════════════════════════
    // TROMBÓLISE IV
    // ═══════════════════════════════════════════════
    'ischemic_eval': const AlgorithmNode(
      id: 'ischemic_eval',
      type: NodeType.question,
      title: 'Elegível para Trombólise IV?',
      bullets: [
        'Avaliar janela terapêutica, contraindicações e NIHSS',
      ],
      didacticCards: {
        'Critérios de Elegibilidade': 'INCLUSÃO:\n• AVC isquêmico com déficit neurológico mensurável\n• LKW ≤ 4,5 horas (janela padrão)\n• Idade ≥ 18 anos\n• TC sem hemorragia\n\nJANELA ESTENDIDA 4,5-9h:\n• Se DWI-FLAIR mismatch na RM OU\n• CTP (perfusão por TC) mostrando penumbra salvável\n• Considerar em wake-up strokes\n\n⚠️ NIHSS 0 (sem déficit): NÃO trombólise\n⚠️ NIHSS 1-4 não incapacitante: NÃO rotineiramente (PRISMS)\n⚠️ Qualquer NIHSS com déficit incapacitante: TRATAR',
        'Contraindicações ABSOLUTAS': '• AVC hemorrágico prévio (qualquer época)\n• AVC isquêmico < 3 meses\n• Neoplasia intracraniana, MAV ou aneurisma\n• TCE grave < 3 meses\n• Cirurgia intracraniana ou espinhal < 3 meses\n• Sangramento interno ativo (exceto menstruação)\n• Dissecção aórtica conhecida\n• Diátese hemorrágica:\n  - Plaquetas < 100.000\n  - INR > 1,7 ou TP > 15 seg\n  - Uso de DOAC nas últimas 48h (com função renal normal)\n• PA > 185/110 mmHg refratária ao tratamento\n• Endocardite infecciosa\n• Glicemia < 50 mg/dL (corrigir e reavaliar)',
        'Contraindicações RELATIVAS': '• Sintomas menores ou em resolução rápida (avaliar incapacidade)\n• Gravidez\n• Cirurgia maior < 14 dias\n• Sangramento TGI ou TGU < 21 dias\n• IAM recente < 3 meses\n• Punção arterial em sítio não compressível < 7 dias\n• Convulsão no início dos sintomas (se déficit residual = tratar)\n• Glicemia extrema: CORRIGIR e reavaliar — não é exclusão absoluta (AHA/ASA 2026)',
        'PA pré-trombólise': 'ANTES de administrar o trombolítico:\n• PA deve estar < 185/110 mmHg\n\nDrogas para controle:\n• Labetalol 10-20 mg IV em 1-2 min (pode repetir 1x)\n• Nicardipina 5 mg/h IV (titular até 15 mg/h)\n• Clevidipina 1-2 mg/h IV\n\nSe PA não controlar abaixo de 185/110 → NÃO administrar trombolítico.',
      },
      options: [
        AlgorithmOption(label: 'SIM — Elegível', nextNodeId: 'thrombolysis_drug'),
        AlgorithmOption(label: 'NÃO — Contraindicado', nextNodeId: 'evt_eval'),
      ],
    ),
    'thrombolysis_drug': const AlgorithmNode(
      id: 'thrombolysis_drug',
      type: NodeType.drug,
      title: 'Trombólise IV — Administrar Trombolítico',
      alertLevel: 'danger',
      drug: DrugInfo(
        name: 'Trombolítico IV para AVC',
        dose: 'TENECTEPLASE (TNK) — preferencial AHA 2025:\n• 0,25 mg/kg IV bolus único (máx 25 mg)\n⚠️ DOSE DO AVC ≠ DOSE DO IAM (0,4 mg/kg)\n\nALTEPLASE (rt-PA) — alternativa:\n• 0,9 mg/kg IV (máx 90 mg total)\n• 10% em bolus IV em 1 min\n• 90% restante em infusão IV em 60 min',
        route: 'Intravenoso',
        notes: 'Meta porta-agulha: ≤ 60 min (ideal ≤ 30 min)\n\nJANELAS DE TEMPO:\n• ≤ 4,5h do LKW: janela padrão (Classe I)\n• 4,5-9h: se DWI-FLAIR mismatch ou CTP com penumbra\n\n⚠️ NUNCA usar a dose do IAM (0,4-0,5 mg/kg) no AVC — risco de transformação hemorrágica FATAL',
        color: '#F97316',
      ),
      nextNodeId: 'post_thrombolysis_stroke',
    ),
    'post_thrombolysis_stroke': const AlgorithmNode(
      id: 'post_thrombolysis_stroke',
      type: NodeType.action,
      title: 'Pós-Trombólise — Monitorização Intensiva',
      alertLevel: 'warning',
      bullets: [
        'PA < 180/105 mmHg nas primeiras 24h',
        'NIHSS seriado: a cada 15 min por 2h, depois a cada hora por 6h',
        'TC de controle em 24h (antes de iniciar antiagregação)',
        'NÃO usar antitrombóticos nas primeiras 24h pós-trombólise',
      ],
      didacticCards: {
        'Controle de PA pós-trombólise': 'Alvo: PA < 180/105 mmHg por 24h\n\nMonitorizar PA:\n• A cada 15 min por 2h\n• A cada 30 min por 6h\n• A cada 1h por 16h\n\nDrogas:\n• Labetalol 10 mg IV → titular\n• Nicardipina 5-15 mg/h IV\n\nSe PA > 180/105 persistente → ajustar infusão',
        'Complicações a monitorizar': 'TRANSFORMAÇÃO HEMORRÁGICA:\n• Piora súbita do NIHSS (≥ 4 pontos)\n• Cefaleia intensa / vômitos / rebaixamento\n→ PARAR infusão de alteplase (se em curso)\n→ TC de crânio URGENTE\n→ Hemograma + coagulograma + fibrinogênio\n→ Crioprecipitado 10 UI se fibrinogênio < 200\n→ Ácido tranexâmico 1 g IV em 10 min\n\nANGIOEDEMA OROLINGUAL:\n• 2-5% dos casos (mais comum com IECA)\n→ Suspender infusão, manter via aérea\n→ Adrenalina IM + anti-histamínico + corticóide',
        'Quando iniciar antiagregação?': 'AAS 160-300 mg VO:\n• Após 24h da trombólise\n• SOMENTE após TC de controle sem hemorragia\n• Se recebeu TNK ou rt-PA: esperar 24h\n\n⚠️ Anticoagulação plena: NÃO nas primeiras 24h',
      },
      nextNodeId: 'evt_eval',
    ),
    // ═══════════════════════════════════════════════
    // TROMBECTOMIA (EVT)
    // ═══════════════════════════════════════════════
    'evt_eval': const AlgorithmNode(
      id: 'evt_eval',
      type: NodeType.question,
      title: 'LVO confirmada na Angio-TC? Elegível para EVT?',
      bullets: [
        'Angio-TC revelou LVO? → Avaliar critérios para trombectomia',
        'Mesmo sem suspeita pré-hospitalar, a Angio-TC pode confirmar LVO',
      ],
      didacticCards: {
        'LVO descoberta no hospital': 'Mesmo que o FAST-ED pré-hospitalar tenha sido < 4 (sem suspeita de LVO), a Angio-TC hospitalar é DEFINITIVA.\n\nSe a Angio-TC confirmar LVO:\n• Paciente em centro COM trombectomia (TSC/CSC) → EVT no local\n• Paciente em centro SEM trombectomia (ASRH/PSC) → TRANSFERÊNCIA IMEDIATA\n\nEstratégia Drip-and-Ship:\n1. Iniciar trombólise IV no centro atual (drip)\n2. Transferir para TSC/CSC durante ou após a infusão (ship)\n3. NÃO esperar efeito da trombólise para decidir transferir\n4. Notificar centro receptor com dados de imagem\n\n⚠️ A descoberta de LVO na imagem hospitalar MUDA toda a conduta — mesmo em pacientes inicialmente encaminhados ao centro mais próximo.',
        'Critérios para EVT (AHA 2025)': 'CRITÉRIOS PADRÃO (Classe I, 0-6h):\n• LVO de circulação anterior (ACI, M1)\n• Idade ≥ 18 anos\n• NIHSS ≥ 6\n• ASPECTS ≥ 6\n• mRS pré-AVC 0-1 (funcionalidade prévia boa)\n• Pode ser feita COM ou SEM trombólise IV prévia\n\nJANELA ESTENDIDA (6-24h — DAWN/DEFUSE 3):\n• LVO confirmada por Angio-TC/RM\n• Mismatch clínico-radiológico (NIHSS alto vs core pequeno)\n• Core isquêmico < 70 mL (por CTP ou DWI)\n• Ou: idade ≥ 80 + NIHSS ≥ 10 + core < 21 mL\n\nTROMBECTOMIA BASILAR (AHA/ASA 2026):\n• Oclusão de artéria basilar\n• LKW ≤ 24h\n• NIHSS ≥ 10\n• Classe I (recomendação recente)',
        'ASPECTS — O que é?' : 'Alberta Stroke Program Early CT Score\nEscala de 0-10 na TC sem contraste\n\nAvalia 10 regiões do território da ACM:\n• C = Caudado\n• L = Lentiforme\n• IC = Cápsula interna\n• I = Ínsula\n• M1-M6 = Regiões corticais da ACM\n\nCada região com isquemia precoce = -1 ponto\n• 10 = TC normal\n• ≥ 6 = favorável para trombectomia\n• < 6 = área extensa (avaliar individualmente)\n\n⚠️ Core grande (ASPECTS 3-5 ou core ≥ 50 mL) NÃO é exclusão automática.\nRecomendada (Classe I) em selecionados: < 80 anos, NIHSS ≥ 6, mRS pré 0-1, LVO proximal, 6-24h.',
        'Janelas de Tempo para EVT': '0-6 horas do LKW:\n• Critérios padrão (ASPECTS ≥ 6, NIHSS ≥ 6)\n• Maior evidência de benefício\n\n6-24 horas (DAWN / DEFUSE 3):\n• Necessita imagem avançada (CTP ou DWI-perfusão)\n• Mismatch clínico-radiológico obrigatório\n• Core isquêmico limitado\n\nBasilar ≤ 24h (AHA/ASA 2026):\n• NIHSS ≥ 10\n• Oclusão confirmada\n\n⚠️ Trombólise e trombectomia são PARALELAS, não sequenciais.\nNÃO esperar efeito da trombólise para indicar EVT.\nSe elegível para ambas → iniciar trombólise E preparar EVT simultaneamente.',
      },
      options: [
        AlgorithmOption(label: 'SIM — LVO confirmada, elegível', nextNodeId: 'evt_action'),
        AlgorithmOption(label: 'NÃO — Sem LVO ou fora dos critérios', nextNodeId: 'stroke_unit'),
      ],
    ),
    'evt_action': const AlgorithmNode(
      id: 'evt_action',
      type: NodeType.action,
      title: 'Trombectomia Endovascular (EVT)',
      alertLevel: 'danger',
      bullets: [
        'Se em centro COM EVT → ativar neurorradiologia intervencionista',
        'Se em centro SEM EVT → transferência IMEDIATA (drip-and-ship)',
        'Meta porta-punção: ≤ 90 min (ideal ≤ 60 min)',
        'Anestesia: sedação consciente preferível (vs geral)',
        
      ],
      didacticCards: {
        'Drip-and-Ship (Transferência)': 'Quando o paciente está em centro SEM trombectomia (ASRH ou PSC):\n\n1. DRIP — Iniciar trombólise IV no centro atual\n   • NÃO atrasar a trombólise esperando transferência\n   • TNK (bolus único) é ideal para drip-and-ship\n\n2. SHIP — Transferir DURANTE ou APÓS o bolus\n   • Contatar centro receptor (TSC/CSC) com imagens\n   • Enviar dados: NIHSS, LKW, hora da trombólise, Angio-TC\n   • Acompanhamento médico durante transporte\n   • Monitorizar PA < 180/105 durante transferência\n\n⚠️ NÃO esperar efeito da trombólise para decidir transferir.\nA decisão de transferir é tomada NO MOMENTO da descoberta da LVO.\n\nMotherShip (alternativa):\nSe o paciente já está em centro COM trombectomia → EVT direta.',
        'Pós-Trombectomia': 'Monitorização:\n• NIHSS seriado pós-procedimento\n• TC de controle em 24h\n• PA < 180/105 mmHg (se reperfusão TICI ≥ 2b)\n• Se TICI < 2b (reperfusão incompleta): individualizar PA\n\nAntiagregação:\n• AAS 160-300 mg após 24h (se sem hemorragia na TC)\n• Se stent intracraniano: DAPT por 90 dias\n\nComplicações:\n• Transformação hemorrágica (5-7%)\n• Perfuração arterial\n• Dissecção\n• Embolização para novo território',
      },
      nextNodeId: 'stroke_unit',
    ),
    // ═══════════════════════════════════════════════
    // UNIDADE DE AVC
    // ═══════════════════════════════════════════════
    'stroke_unit': const AlgorithmNode(
      id: 'stroke_unit',
      type: NodeType.end,
      title: 'Unidade de AVC / UTI',
      bullets: [
        'Monitorização neurológica e hemodinâmica contínua',
        'Cabeceira a 30° (HeadPoST)',
        'Investigação etiológica e prevenção secundária',
      ],
      didacticCards: {
        'PA no AVC isquêmico (sem reperfusão)': 'Se NÃO recebeu trombólise/EVT:\n• PA < 220/120 → NÃO tratar (preservar perfusão da penumbra)\n• PA ≥ 220/120 ou complicação (IC, dissecção, IAM) → reduzir ATÉ 15% nas primeiras 24h\n\n⚠️ NUNCA redução agressiva no isquêmico sem reperfusão!\n\nSe RECEBEU trombólise/EVT:\n• PA < 180/105 mmHg por 24h',
        'Investigação Etiológica': 'ECG contínuo (mínimo 24h) → detecção de FA\nEcocardiograma TT (ou TE se suspeita cardioembólica)\nDoppler de carótidas e vertebrais\nHolter 24-72h (se ECG sem FA e suspeita)\nPerfil lipídico e HbA1c\nCoagulograma expandido (se < 55 anos ou sem fator de risco)\nVasculite / trombofilias (jovens)',
        'Prevenção Secundária': 'Antiagregação:\n• AAS 160-300 mg/dia (monoterapia crônica: 75-100 mg)\n• DAPT (AAS + Clopidogrel 75 mg) por 21-90 dias se AVC menor ou TIA (CHANCE/POINT)\n\nAnticoagulação (se FA):\n• Iniciar DOAC em 4-14 dias (regra 1-3-6-12 conforme NIHSS)\n\nEstatina de alta intensidade:\n• Atorvastatina 80 mg ou Rosuvastatina 40 mg\n\nControle de PA crônico:\n• Meta < 130/80 mmHg (após fase aguda)\n\nMudanças de estilo de vida:\n• Cessar tabagismo, atividade física, dieta, controle glicêmico',
      },
    ),
  },
);


final allAlgorithms = <String, Algorithm>{
  cardiacArrestAlgorithm.id: cardiacArrestAlgorithm,
  bradycardiaAlgorithm.id: bradycardiaAlgorithm,
  tachycardiaAlgorithm.id: tachycardiaAlgorithm,
  postRoscAlgorithm.id: postRoscAlgorithm,
  scaAlgorithm.id: scaAlgorithm,
  strokeAlgorithm.id: strokeAlgorithm,
};