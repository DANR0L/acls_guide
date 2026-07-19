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
        'Bifásico: 120–200 J (seguir recomendação do fabricante; se desconhecida: dose máxima)',
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
          label: '⚡ Chocável refratária — DSD (Dupla Desfibrilação)',
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
      title: '⚡ Choque Sequencial Duplo (DSD)',
      alertLevel: 'danger',
      isShockNode: true,
      bullets: [
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
        'Confirmar: verificar cabos e eletrodos',
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
        'Controle de temperatura alvo (evitar febre, TTM 32–36 °C)',
        'Otimizar hemodinâmica (PAM ≥ 65 mmHg ou PAS ≥ 90 mmHg)',
        'Otimizar ventilação/oxigenação (SpO₂ 92–98%)',
        'Realizar ECG 12 derivações (buscar supra de ST)',
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
        notes: 'Administrar rapidamente (push). Atualização AHA 2025: dose passou de 0,5mg para 1mg. Não usar em transplantados cardíacos. Ineficaz em BAV infranodal.',
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
        '   - FA: >= 200 J bifásico (iniciar na energia máxima)',
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
        '   - Eletrólitos: K+ (manter > 4,0), Mg2+ (manter > 2,0), Ca2+',
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
        '     - 2a opção: Procainamida 20 mg/min IV (máx 17 mg/kg)',
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
          sublabel: 'Taquicardia supraventricular (TSV)',
          nextNodeId: 'narrow_regular',
        ),
        AlgorithmOption(
          label: '🔴 QRS Largo ≥ 120 ms',
          sublabel: 'TV ou TSV com aberrância',
          nextNodeId: 'wide_regular',
        ),
      ],
    ),

    // ── QRS ESTREITO ──────────────────────────────────────────
    'narrow_regular': const AlgorithmNode(
      id: 'narrow_regular',
      type: NodeType.question,
      title: 'TSV — Ritmo Regular ou Irregular?',
      options: [
        AlgorithmOption(
          label: '📏 Regular',
          nextNodeId: 'narrow_regular_action',
        ),
        AlgorithmOption(
          label: '〰️ Irregular',
          sublabel: 'FA, Flutter com condução variável, WPW',
          nextNodeId: 'narrow_irregular',
        ),
      ],
    ),

    'narrow_regular_action': const AlgorithmNode(
      id: 'narrow_regular_action',
      type: NodeType.question,
      title: 'TSV Regular — Estratégia',
      subtitle: 'TRNAV / TRAV / Taquicardia atrial',
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
      title: 'Adenosina — TSV Regular',
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
          label: '✅ Converteu para sinusal — TRNAV',
          nextNodeId: 'tachy_post_cardioversion',
        ),
        AlgorithmOption(
          label: '📉 Revelou Flutter/FA subjacente',
          nextNodeId: 'narrow_irregular',
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
        'Betabloqueador IV: Metoprolol 5 mg IV lento (3 doses)',
        'ou Verapamil 5–10 mg IV em 2 min',
        'Consulta cardiológica/eletrofisiologia',
        'Investigar: hipóxia, sepse, tireotoxicose, digoxina',
      ],
    ),

    // ── QRS ESTREITO IRREGULAR ────────────────────────────────
    'narrow_irregular': const AlgorithmNode(
      id: 'narrow_irregular',
      type: NodeType.question,
      title: 'Taquicardia Irregular — Tipo',
      options: [
        AlgorithmOption(
          label: '🔵 Fibrilação Atrial (FA)',
          sublabel: 'Linha de base irregular, sem ondas P',
          nextNodeId: 'afib_strategy',
        ),
        AlgorithmOption(
          label: '🔵 Flutter Atrial',
          sublabel: 'Ondas F em "dentes de serra"',
          nextNodeId: 'flutter_strategy',
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
      alertLevel: 'warning',
      bullets: [
        'Infusão de Antiarrítmicos (1ª escolha se estável):',
        '   • Procainamida 20–50 mg/min (máx 17 mg/kg)',
        '   • Amiodarona 150 mg IV em 10 min',
        '   • Sotalol 100 mg (1,5 mg/kg) IV em 5 min',
        'Consultar Especialista (Cardiologia/Eletrofisiologia)',
        'Cardioversão sincronizada se falha ou instabilização',
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
        '🩸 SpO₂: 94–98% (evitar hiperoxia)',
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
        'O₂ suplementar: manter SpO₂ 94–98%',
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
        dose: '0,1–1 mcg/kg/min',
        route: 'Infusão IV contínua (acesso central preferencial)',
        notes: 'Titular para PAM ≥ 65 mmHg. Monitorização invasiva recomendada.',
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
          label: '🟢 ECG normal / LBBB prévio',
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
        'Controle ativo de temperatura: 32–37,5°C por ≥ 36 horas (AHA 2025)',
        'PREVENIR FEBRE ativamente (> 37,5°C prejudicial)',
        'Individualizar: hipotermia (32–34°C) vs normotermia (36–37,5°C)',
        'Métodos de resfriamento:',
        '   • Bolsas de gelo nas axilas/virilhas',
        '   • Cateter endovascular (Artic Sun, Thermogard)',
        '   • Cobertor refrescante',
        '   • ⚠️ NÃO usar soro gelado IV pré-hospitalar (risco edema pulmonar/re-PCR)',
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
      title: 'Dor Precordial / Equivalente Isquêmico',
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
      title: '⚡ ECG em 10 minutos — URGENTE',
      alertLevel: 'danger',
      bullets: [
        'ECG 12 derivações nos primeiros 10 min da chegada',
        'Leitura por médico experiente',
        'Repetir em 15–30 min se o primeiro não diagnóstico',
        'Derivações adicionais: V3R, V4R (IAM inferior/VD)',
        'V7, V8, V9 (IAM posterior)',
      ],
      nextNodeId: 'ecg_result_sca',
    ),

    'ecg_result_sca': const AlgorithmNode(
      id: 'ecg_result_sca',
      type: NodeType.question,
      title: 'Resultado do ECG',
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
      type: NodeType.action,
      title: '🔴 IAMCSST Confirmado — Reperfusão URGENTE',
      alertLevel: 'danger',
      bullets: [
        '⏱️ TEMPO É MÚSCULO — iniciar tratamento EM PARALELO',
        '💊 AAS 300 mg VO (mascar) — AGORA',
        '💊 Dose de ataque do Inibidor P2Y12:',
        '   • ICP Primária: Clopidogrel 600mg, Ticagrelor 180mg ou Prasugrel 60mg',
        '   • Trombólise: Clopidogrel 300mg (75mg se > 75 anos)',
        '🚫 Evitar Prasugrel se AVC/AIT prévio',
        '💉 HNF: ICP → 70–100 UI/kg IV bolus (ajustar por ACT na sala); Trombólise → 60 UI/kg (máx 4000 UI) + infusão 12 UI/kg/h (máx 1000 UI/h)',
        '💨 O₂ apenas se SpO₂ < 90%',
        '💉 Morfina se dor severa (cautela)',
        '💊 Nitrato se PA > 90 mmHg (CI: VD ou PDE5i)',
      ],
      nextNodeId: 'reperfusion_strategy',
    ),

    'reperfusion_strategy': const AlgorithmNode(
      id: 'reperfusion_strategy',
      type: NodeType.question,
      title: 'Estratégia de Reperfusão',
      subtitle: 'Tempo do início dos sintomas + disponibilidade de hemodinâmica',
      options: [
        AlgorithmOption(
          label: '🏥 ICP disponível — D2B < 90 min possível',
          sublabel: 'ICP Primária (1ª escolha)',
          nextNodeId: 'pci_primary',
        ),
        AlgorithmOption(
          label: '⏱️ ICP não disponível ou D2B > 120 min',
          sublabel: 'Trombolítico + transfer',
          nextNodeId: 'thrombolysis_stemi',
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
        'Meta Porta-Balão (D2B): ≤ 90 min',
        'Acesso radial preferencial (menos sangramentos)',
        'Considerar Prasugrel 60 mg (se não em uso de ACO)',
        'Inibidor GPIIb/IIIa: Tirofiban/Abciximab (selecionado)',
        'Ecocardiograma pós-ICP para avaliar FE',
        'UTI coronariana após procedimento',
      ],
    ),

    'thrombolysis_stemi': const AlgorithmNode(
      id: 'thrombolysis_stemi',
      type: NodeType.question,
      title: 'Trombólise — Verificar Contraindicações',
      subtitle: 'OBRIGATÓRIO antes de administrar',
      options: [
        AlgorithmOption(
          label: '✅ Sem contraindicações absolutas — administrar',
          nextNodeId: 'tenecteplase_drug',
        ),
        AlgorithmOption(
          label: '❌ Contraindicação absoluta presente',
          nextNodeId: 'thrombolysis_ci',
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
        '→ Se todas presentes: transferência urgente para ICP',
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
        notes: 'IDOSOS ≥75 anos: meia dose (STREAM Trial). Administrar junto com Heparina. Fibrinólise em ≤10 min do diagnóstico se ICP >120 min (AHA 2025). Transferir para hemodinâmica após. Sinais de reperfusão: alívio da dor, ↓ST >50%, arritmias de reperfusão.',
        color: '#F97316',
      ),
      nextNodeId: 'post_thrombolysis',
    ),

    'post_thrombolysis': const AlgorithmNode(
      id: 'post_thrombolysis',
      type: NodeType.info,
      title: 'Pós-Trombólise — Monitorização',
      alertLevel: 'warning',
      bullets: [
        'Transferir para centro com ICP em até 24h',
        'ICP de resgate se: sem sinais de reperfusão em 90 min',
        'Monitorizar: hemorragias, PA, ritmo cardíaco',
        'Heparina: infusão contínua por 48h',
        'ECG a cada 90 min após trombólise',
        'Critérios de reperfusão: ↓ST > 50% + alívio da dor',
      ],
    ),

    'nstemi_path': const AlgorithmNode(
      id: 'nstemi_path',
      type: NodeType.action,
      title: 'IAMSST / Angina Instável — Conduta',
      alertLevel: 'warning',
      bullets: [
        '💊 AAS 300 mg VO',
        '💊 Inibidor P2Y12 (Ticagrelor/Clopidogrel) — discutir timing com hemodinâmica',
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
  subtitle: 'Isquêmico · Hemorrágico · NIHSS',
  iconEmoji: '🧠',
  color: '#8B5CF6',
  startNodeId: 'stroke_start',
  nodes: {

    // ── RECONHECIMENTO ───────────────────────────────────────
    'stroke_start': const AlgorithmNode(
      id: 'stroke_start',
      type: NodeType.question,
      title: 'Suspeita de AVC — Reconhecimento FAST',
      subtitle: 'Aplique os 4 critérios FAST imediatamente',
      bullets: [
        '🗣️ Face: desvio facial — peça para sorrir (assimétrico?)',
        '💪 Arms: fraqueza de braço — elevar ambos por 10 seg (queda?)',
        '🗨️ Speech: fala arrastada ou incompreensível?',
        '⏰ Time: anotar HORA EXATA do início dos sintomas',
      ],
      options: [
        AlgorithmOption(
          label: '🧠 AVC suspeito — prosseguir protocolo',
          nextNodeId: 'stroke_activate_team',
        ),
        AlgorithmOption(
          label: '❌ Diagnóstico improvável — outro quadro',
          nextNodeId: 'stroke_not_avc',
        ),
      ],
    ),

    'stroke_not_avc': const AlgorithmNode(
      id: 'stroke_not_avc',
      type: NodeType.end,
      title: 'AVC Descartado',
      body: 'Considere diagnósticos diferenciais: hipoglicemia, epilepsia (paralisia de Todd), enxaqueca hemiplégica, encefalopatia metabólica, intoxicação.',
      alertLevel: 'info',
    ),

    // ── ATIVAR EQUIPE ─────────────────────────────────────────
    'stroke_activate_team': const AlgorithmNode(
      id: 'stroke_activate_team',
      type: NodeType.action,
      title: 'Ativar Código AVC',
      alertLevel: 'danger',
      bullets: [
        '📞 Acionar neurologista de plantão IMEDIATAMENTE',
        '🖥️ Notificar TC: porta-TC ≤ 25 minutos',
        '⏰ Anotar hora de chegada (Door Time)',
        '🩺 Meta porta-agulha (Trombolítico): ≤ 45–60 minutos',
        '💉 Acesso venoso periférico (2 vias calibrosas)',
        '📊 Monitorização: ECG contínuo, SpO₂, PA, temperatura',
        '🧪 Coletas: glicemia capilar, hemograma, coagulação, função renal',
      ],
      nextNodeId: 'stroke_glucose',
    ),

    // ── GLICEMIA ──────────────────────────────────────────────
    'stroke_glucose': const AlgorithmNode(
      id: 'stroke_glucose',
      type: NodeType.question,
      title: 'Glicemia Capilar Imediata',
      subtitle: 'Hipoglicemia pode mimetizar AVC com fidelidade total',
      options: [
        AlgorithmOption(
          label: '✅ Normal (≥ 70 mg/dL) — prosseguir',
          nextNodeId: 'stroke_time_onset',
        ),
        AlgorithmOption(
          label: '🔴 Hipoglicemia (< 70 mg/dL)',
          sublabel: 'Tratar antes de prosseguir',
          nextNodeId: 'stroke_hypoglycemia',
        ),
      ],
    ),

    'stroke_hypoglycemia': const AlgorithmNode(
      id: 'stroke_hypoglycemia',
      type: NodeType.action,
      title: 'Tratar Hipoglicemia',
      alertLevel: 'warning',
      bullets: [
        'Glicose 50% — 25–50 mL IV push',
        'Se sem acesso: Glucagon 1 mg IM',
        'Reavalie sintomas após 10–15 minutos',
        'Glicemia normal + sintomas resolvidos = AVC descartado',
        'Glicemia normal + sintomas persistentes = prosseguir AVC',
      ],
      nextNodeId: 'stroke_hypoglycemia_reassess',
    ),

    'stroke_hypoglycemia_reassess': const AlgorithmNode(
      id: 'stroke_hypoglycemia_reassess',
      type: NodeType.question,
      title: 'Reavaliação Pós-Correção da Glicemia',
      options: [
        AlgorithmOption(
          label: '✅ Sintomas resolvidos — hipoglicemia era a causa',
          nextNodeId: 'stroke_hypoglycemia_resolved',
        ),
        AlgorithmOption(
          label: '⚠️ Sintomas persistem — prosseguir protocolo AVC',
          nextNodeId: 'stroke_time_onset',
        ),
      ],
    ),

    'stroke_hypoglycemia_resolved': const AlgorithmNode(
      id: 'stroke_hypoglycemia_resolved',
      type: NodeType.end,
      title: 'Hipoglicemia Resolvida — AVC Descartado',
      body: 'Monitorar glicemia seriada. Investigar causa da hipoglicemia (insulina, sulfonilureia, jejum prolongado). Acompanhamento ambulatorial.',
      alertLevel: 'info',
    ),

    // ── TEMPO DE INÍCIO ───────────────────────────────────────
    'stroke_time_onset': const AlgorithmNode(
      id: 'stroke_time_onset',
      type: NodeType.question,
      title: 'Tempo desde o Início dos Sintomas',
      subtitle: 'Use o ÚLTIMO momento em que o paciente estava sem sintomas',
      bullets: [
        '⚠️ Acordou com sintomas: use a hora que dormiu',
        '👁️ Última vez visto bem = hora de início para fins de protocolo',
        '📱 Câmeras, celulares e testemunhas ajudam a precisar o horário',
      ],
      options: [
        AlgorithmOption(
          label: '⏰ ≤ 4,5 horas',
          sublabel: 'Janela para trombolítico IV — avaliar NIHSS',
          nextNodeId: 'nihss_score',
        ),
        AlgorithmOption(
          label: '⏰ 4,5h a 9h (onset desconhecido)',
          sublabel: 'Janela estendida — imagem avançada (DWI-FLAIR mismatch)',
          nextNodeId: 'stroke_extended_thrombolysis',
        ),
        AlgorithmOption(
          label: '⏰ 9h a 24h',
          sublabel: 'Avaliar trombectomia (DAWN/DEFUSE)',
          nextNodeId: 'stroke_thrombectomy_window',
        ),
        AlgorithmOption(
          label: '⏰ > 24 horas',
          sublabel: 'Fora de todas as janelas terapêuticas',
          nextNodeId: 'stroke_out_of_window',
        ),
      ],
    ),

    // ════════════════════════════════════════════════════════════
    //  NIHSS — ESCALA NEUROLÓGICA (Interativa)
    // ════════════════════════════════════════════════════════════
    'nihss_score': const AlgorithmNode(
      id: 'nihss_score',
      type: NodeType.nihss,
      title: 'Avaliação NIHSS',
      nextNodeId: 'stroke_ct_scan',
    ),


    // ── TC DE CRÂNIO ──────────────────────────────────────────
    'stroke_ct_scan': const AlgorithmNode(
      id: 'stroke_ct_scan',
      type: NodeType.action,
      title: 'TC de Crânio Sem Contraste — URGENTE',
      alertLevel: 'danger',
      bullets: [
        '🎯 Meta porta-TC: ≤ 25 minutos',
        '🖥️ TC sem contraste é suficiente para excluir hemorragia',
        '🔬 Se candidato a trombectomia: adicionar angiotomografia',
        '⚡ NÃO atrasar TC para aguardar exames laboratoriais',
        '📋 Resultado interpretado em < 45 min do início',
      ],
      nextNodeId: 'stroke_ct_result',
    ),

    'stroke_ct_result': const AlgorithmNode(
      id: 'stroke_ct_result',
      type: NodeType.question,
      title: 'Resultado da TC de Crânio',
      options: [
        AlgorithmOption(
          label: '✅ Sem hemorragia — provável isquêmico',
          sublabel: 'TC normal ou hipodensidade precoce',
          nextNodeId: 'stroke_alteplase_criteria',
        ),
        AlgorithmOption(
          label: '🔴 Hemorragia intracraniana',
          sublabel: 'AVC hemorrágico confirmado',
          nextNodeId: 'stroke_hemorrhagic',
        ),
      ],
    ),

    // ── HEMORRÁGICO — NÓ DE ENCERRAMENTO ─────────────────────
    'stroke_hemorrhagic': const AlgorithmNode(
      id: 'stroke_hemorrhagic',
      type: NodeType.end,
      title: 'AVC Hemorrágico — Acionar Neurocirurgia',
      alertLevel: 'danger',
      bullets: [
        '🚫 CONTRAINDICADO: Alteplase/TNK, anticoagulantes, antiagregantes',
        '📞 Acionar Neurocirurgia IMEDIATAMENTE',
        '💉 Reversão de anticoagulação se em uso:',
        '   • Heparina → Protamina',
        '   • Warfarina → Vitamina K + CCP 4 fatores (Octaplex)',
        '   • Dabigatran → Idarucizumabe (Praxbind) 5g IV',
        '   • Rivaroxaban/Apixaban/Edoxaban → Andexanet alfa ou CCP 4 fatores 50 UI/kg',
        '📈 Alvo de PA: sistólica < 140 mmHg (AHA/ASA 2026 — INTERACT-3)',
        '🛏️ UTI ou unidade de AVC imediatamente',
        '🧠 Critérios cirúrgicos: hematoma > 30 mL, deterioração, hidrocefalia',
        '🌡️ Controle de temperatura, glicemia e convulsões',
      ],
    ),

    // ── CRITÉRIOS ALTEPLASE ───────────────────────────────────
    'stroke_alteplase_criteria': const AlgorithmNode(
      id: 'stroke_alteplase_criteria',
      type: NodeType.info,
      title: 'Critérios de Elegibilidade — Trombolítico (Alteplase / TNK)',
      alertLevel: 'warning',
      bullets: [
        '✅ INCLUSÃO:',
        '  • AVC isquêmico com déficit neurológico mensurável',
        '  • Início dos sintomas ≤ 4,5 horas',
        '  • Idade ≥ 18 anos',
        '',
        '🚫 EXCLUSÃO ABSOLUTA:',
        '  • TC com hemorragia intracraniana',
        '  • PA > 185/110 mmHg não controlada',
        '  • Glicemia < 50 ou > 400 mg/dL',
        '  • AVC isquêmico ou TCE grave < 3 meses',
        '  • Sangramento interno ativo',
        '  • Plaquetas < 100.000 | INR > 1,7 | TTPA > 40 s',
        '  • Anticoagulante oral sem reversão confirmada',
        '',
        '⚠️ EXCLUSÃO RELATIVA (risco/benefício individual):',
        '  • Cirurgia de grande porte < 14 dias',
        '  • NIHSS 0–1 ou melhora rápida',
        '  • Convulsão no início (se déficit residual: tratar)',
        '  • Gravidez (risco/benefício materno-fetal)',
      ],
      nextNodeId: 'stroke_alteplase_eligible',
    ),

    'stroke_alteplase_eligible': const AlgorithmNode(
      id: 'stroke_alteplase_eligible',
      type: NodeType.question,
      title: 'Paciente Elegível para Trombolítico?',
      options: [
        AlgorithmOption(
          label: '✅ Elegível — sem contraindicações',
          nextNodeId: 'stroke_bp_control',
        ),
        AlgorithmOption(
          label: '🚫 Contraindicado — não administrar',
          nextNodeId: 'stroke_no_alteplase',
        ),
      ],
    ),

    // Controle de PA pré-alteplase
    'stroke_bp_control': const AlgorithmNode(
      id: 'stroke_bp_control',
      type: NodeType.question,
      title: 'Pressão Arterial Pré-Trombolítico',
      subtitle: 'Deve estar ≤ 185/110 mmHg para iniciar o trombolítico',
      options: [
        AlgorithmOption(
          label: '✅ PA ≤ 185/110 mmHg — pronto para trombolítico',
          nextNodeId: 'stroke_give_alteplase',
        ),
        AlgorithmOption(
          label: '⚠️ PA > 185/110 mmHg — controlar primeiro',
          nextNodeId: 'stroke_bp_treatment',
        ),
      ],
    ),

    'stroke_bp_treatment': const AlgorithmNode(
      id: 'stroke_bp_treatment',
      type: NodeType.action,
      title: 'Controle de PA Pré-Trombolítico',
      alertLevel: 'warning',
      bullets: [
        'Labetalol 10–20 mg IV em 1–2 min (repetir 1x se necessário)',
        'Nicardipina 5 mg/h IV — titular 2,5 mg/h a cada 5 min (máx 15 mg/h)',
        'Clevidipina 1,25 mg/h IV — titular (máx 21 mg/h)',
        'Meta: PA ≤ 185/110 mmHg antes de iniciar',
        '⚠️ Se PA não controlável: NÃO administrar trombolítico',
      ],
      nextNodeId: 'stroke_bp_achieved',
    ),

    'stroke_bp_achieved': const AlgorithmNode(
      id: 'stroke_bp_achieved',
      type: NodeType.question,
      title: 'PA Controlada?',
      options: [
        AlgorithmOption(
          label: '✅ PA ≤ 185/110 mmHg atingida',
          nextNodeId: 'stroke_give_alteplase',
        ),
        AlgorithmOption(
          label: '🚫 PA não controlável — trombolítico contraindicado',
          nextNodeId: 'stroke_no_alteplase',
        ),
      ],
    ),

    // ── ADMINISTRAR ALTEPLASE ─────────────────────────────────
    'stroke_give_alteplase': const AlgorithmNode(
      id: 'stroke_give_alteplase',
      type: NodeType.drug,
      title: 'Administrar Trombolítico IV — AGORA',
      alertLevel: 'danger',
      drug: DrugInfo(
        name: 'Tenecteplase (TNK) OU Alteplase (rt-PA)',
        dose: 'TNK: 0,25 mg/kg IV (máx 25 mg) bolus único\nOU\nAlteplase: 0,9 mg/kg (máx 90 mg) → 10% bolus + 90% infusão em 60 min',
        route: 'IV (bolus único para TNK, infusão para rt-PA)',
        notes: 'TNK e Alteplase têm mesma eficácia (AHA/ASA 2026). TNK preferível: bolus único, logística mais simples, ideal se trombectomia subsequente. Meta porta-agulha: ≤ 45 min. PA < 180/105 mmHg durante e 24h após. NÃO usar antiagregantes/anticoagulantes nas primeiras 24h.',
        color: '#F97316',
      ),
      nextNodeId: 'stroke_post_alteplase',
    ),

    'stroke_post_alteplase': const AlgorithmNode(
      id: 'stroke_post_alteplase',
      type: NodeType.action,
      title: 'Monitorização Pós-Trombolítico',
      alertLevel: 'warning',
      bullets: [
        '🧠 Neurológico: a cada 15 min nas primeiras 2h, a cada 30 min × 6h',
        '📊 PA: a cada 15 min × 2h → a cada 30 min × 6h → a cada 60 min × 16h',
        '🎯 Meta de PA pós-trombolítico: < 180/105 mmHg',
        '🚫 NÃO iniciar anticoagulantes ou antiagregantes nas primeiras 24h',
        '🚫 NÃO inserir cateter urinário, SNG ou acesso arterial por ≥ 30 min',
        '⚠️ Piora neurológica severa = reverter trombolítico + TC urgente',
      ],
      nextNodeId: 'stroke_thrombectomy_check',
    ),

    // Sem alteplase
    'stroke_no_alteplase': const AlgorithmNode(
      id: 'stroke_no_alteplase',
      type: NodeType.info,
      title: 'Trombolítico Contraindicado — Manejo Alternativo',
      alertLevel: 'warning',
      bullets: [
        'AAS 300 mg VO — iniciar em 24–48h (se não trombólise)',
        'Avaliar trombectomia mecânica se oclusão de grande vaso',
        'Suporte clínico: hidratação SF 0,9%, controle glicêmico, temperatura',
        'Monitorização: ECG contínuo (rastrear FA)',
        'Internação em unidade de AVC',
      ],
      nextNodeId: 'stroke_thrombectomy_check',
    ),

    // ── TROMBECTOMIA ──────────────────────────────────────────
    'stroke_thrombectomy_check': const AlgorithmNode(
      id: 'stroke_thrombectomy_check',
      type: NodeType.question,
      title: 'Indicação de Trombectomia Mecânica?',
      subtitle: 'Avalie oclusão de grande vaso (OGV) por imagem',
      bullets: [
        'Angiotomografia ou RM-angio para identificar OGV',
        'NIHSS ≥ 6 com OGV confirmada = candidato preferencial',
        'Circulação anterior: janela ≤ 6h (padrão) ou 6–24h (DAWN/DEFUSE)',
        'Oclusão basilar: janela ≤ 24h com NIHSS ≥ 10 (AHA/ASA 2026)',
        'Trombolítico NÃO é contraindicação — fazer os dois se elegível',
        'Não aguardar resposta ao trombolítico — prosseguir direto à trombectomia',
      ],
      options: [
        AlgorithmOption(
          label: '✅ Indicada — OGV confirmada, janela adequada',
          nextNodeId: 'stroke_thrombectomy_info',
        ),
        AlgorithmOption(
          label: '❌ Não indicada ou fora da janela',
          nextNodeId: 'stroke_post_care',
        ),
      ],
    ),

    'stroke_thrombectomy_info': const AlgorithmNode(
      id: 'stroke_thrombectomy_info',
      type: NodeType.action,
      title: 'Trombectomia Mecânica — Acionar Hemodinâmica',
      alertLevel: 'danger',
      bullets: [
        '📞 Ativar neurorradiologia intervencionista IMEDIATAMENTE',
        '🎯 Meta porta-punção: ≤ 90 min (idealmente < 60 min)',
        '🖼️ Angiotomografia crânio + pescoço se não realizada',
        '📊 Core isquêmico < 70 mL = critério favorável',
        '🔬 Critérios DAWN/DEFUSE para janela 6–24h',
        '💉 TNK/Alteplase + trombectomia: fazer os dois se elegível',
      ],
      nextNodeId: 'stroke_post_care',
    ),

    // ── JANELA ESTENDIDA TROMBÓLISE (4,5–9h) ───────────────────────
    'stroke_extended_thrombolysis': const AlgorithmNode(
      id: 'stroke_extended_thrombolysis',
      type: NodeType.action,
      title: 'Janela Estendida (4,5–9h) — Trombólise por Imagem',
      alertLevel: 'warning',
      bullets: [
        '💡 Indicada para onset desconhecido ou wake-up stroke',
        '🖥️ Solicitar RM: DWI-FLAIR mismatch',
        '   • DWI positivo (lesão aguda) + FLAIR negativo = lesão < 4,5h',
        '💊 TNK 0,25 mg/kg (máx 25 mg) IV bolus único (AHA/ASA 2026)',
        '   ou Alteplase 0,9 mg/kg (máx 90 mg) — 10% bolus + 90% em 1h',
        '⚠️ Mesmas contraindicações do trombolítico padrão',
        '🔬 Se OGV presente: avaliar trombectomia associada',
        '🛏️ Internação em unidade de AVC',
      ],
      nextNodeId: 'stroke_thrombectomy_check',
    ),

    // ── JANELA TROMBECTOMIA (9–24h) ─────────────────────────────
    'stroke_thrombectomy_window': const AlgorithmNode(
      id: 'stroke_thrombectomy_window',
      type: NodeType.action,
      title: 'Janela Trombectomia (9–24h) — Avaliação por Imagem',
      alertLevel: 'warning',
      bullets: [
        '🖥️ Solicitar TC + Angiotomografia ou RM de perfusão',
        '🔬 Critérios DAWN (6–24h):',
        '   • NIHSS ≥ 10 + OGV em circulação anterior',
        '   • Idade ≥ 80: core < 21 mL',
        '   • Idade < 80: core < 31 mL (NIHSS ≥ 10) ou core < 51 mL (NIHSS ≥ 20)',
        '🔬 Critérios DEFUSE 3 (6–16h):',
        '   • NIHSS ≥ 6 + OGV em circulação anterior',
        '   • Core < 70 mL, mismatch ratio ≥ 1.8, penumbra ≥ 15 mL',
        '🧠 Oclusão basilar: janela ≤ 24h com NIHSS ≥ 10 (AHA/ASA 2026)',
        '💊 Trombólise prévia NÃO contraindica trombectomia',
        '🛏️ Internação em unidade de AVC',
      ],
      nextNodeId: 'stroke_thrombectomy_check',
    ),

    'stroke_out_of_window': const AlgorithmNode(
      id: 'stroke_out_of_window',
      type: NodeType.info,
      title: 'Fora das Janelas Terapêuticas (> 24h)',
      alertLevel: 'info',
      bullets: [
        '🚫 Trombolítico e trombectomia não indicados de rotina',
        '💊 Antiagregação: AAS 300 mg VO (iniciar nas primeiras 24–48h)',
        '💊 AVC leve/TIA: dupla antiagregação AAS + Clopidogrel × 21 dias',
        '📈 PA inicial: não tratar se < 220/120 mmHg (manter perfusão)',
        '🧪 Investigação etiológica: ECG, Holter, ecocardiograma',
        '🛏️ Internação em unidade de AVC ou UTI',
      ],
      nextNodeId: 'stroke_post_care',
    ),

    // ── CUIDADOS PÓS-AVC ──────────────────────────────────────
    'stroke_post_care': const AlgorithmNode(
      id: 'stroke_post_care',
      type: NodeType.end,
      title: 'Cuidados Pós-AVC — Unidade de AVC / UTI',
      alertLevel: 'info',
      bullets: [
        '📊 Monitorização contínua: ECG, SpO₂, PA, temperatura',
        '🌡️ Temperatura: tratar febre (meta < 37,5°C)',
        '🍬 Glicemia: manter 140–180 mg/dL (evitar hipoglicemia)',
        '📈 PA pós-trombólise: < 180/105 mmHg',
        '📈 PA sem trombólise: < 220/120 nas primeiras 24h',
        '🛏️ Cabeceira elevada 30° (reduzir PIC — HeadPoST: posição plana sem benefício)',
        '💧 Hidratação: SF 0,9% (evitar SG — piora edema cerebral)',
        '🗣️ Fonoaudiologia: avaliar deglutição antes de qualquer via oral',
        '🧠 RM de difusão: confirmar topografia e extensão do infarto',
        '❤️ Holter 24h: rastrear FA paroxística (causa em 25% dos AVC)',
        '💊 Estatina de alta intensidade: iniciar precocemente',
        '🩺 Investigação etiológica TOAST completa',
      ],
    ),
  },
);

// ═══════════════════════════════════════════════════════════════
//  REGISTRO DE TODOS OS ALGORITMOS
// ═══════════════════════════════════════════════════════════════

final allAlgorithms = <String, Algorithm>{
  cardiacArrestAlgorithm.id: cardiacArrestAlgorithm,
  bradycardiaAlgorithm.id: bradycardiaAlgorithm,
  tachycardiaAlgorithm.id: tachycardiaAlgorithm,
  postRoscAlgorithm.id: postRoscAlgorithm,
  scaAlgorithm.id: scaAlgorithm,
  strokeAlgorithm.id: strokeAlgorithm,
};

