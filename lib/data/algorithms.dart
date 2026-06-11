import '../models/algorithm_node.dart';

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  ALGORITMO PCR â€” Parada CardiorrespiratÃ³ria (AHA 2025)
//  Inclui: VF/pVT (chocÃ¡vel) e Assistolia/AESP (nÃ£o chocÃ¡vel)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

final cardiacArrestAlgorithm = Algorithm(
  id: 'cardiac_arrest',
  title: 'PCR â€” Parada CardiorrespiratÃ³ria',
  subtitle: 'VF Â· pVT Â· Assistolia Â· AESP',
  iconEmoji: 'ðŸ«€',
  color: '#EF4444',
  startNodeId: 'start',
  nodes: {
    // â”€â”€ INÃCIO â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'start': const AlgorithmNode(
      id: 'start',
      type: NodeType.question,
      title: 'Confirmar Parada CardiorrespiratÃ³ria',
      subtitle: 'Verifique os critÃ©rios de PCR',
      bullets: [
        'Sem resposta ao estÃ­mulo tÃ¡til/verbal',
        'Sem respiraÃ§Ã£o ou respiraÃ§Ã£o agÃ´nica (gasping)',
        'Sem pulso central (â‰¤10 segundos de checagem)',
      ],
      options: [
        AlgorithmOption(label: 'âœ… PCR confirmada', nextNodeId: 'activate_team'),
        AlgorithmOption(label: 'âš ï¸ Paciente com pulso', nextNodeId: 'has_pulse_redirect'),
      ],
    ),

    'has_pulse_redirect': const AlgorithmNode(
      id: 'has_pulse_redirect',
      type: NodeType.end,
      title: 'Paciente com Pulso Detectado',
      subtitle: 'Use outro algoritmo',
      body: 'Se o paciente tem pulso, avalie frequÃªncia cardÃ­aca e pressÃ£o arterial para escolher o algoritmo correto.',
      alertLevel: 'info',
      options: [
        AlgorithmOption(label: 'ðŸ”µ Ir para Bradicardia', nextNodeId: '__goto_bradycardia'),
        AlgorithmOption(label: 'ðŸ”´ Ir para Taquicardia', nextNodeId: '__goto_tachycardia'),
      ],
    ),

    // â”€â”€ ATIVAR EQUIPE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'activate_team': const AlgorithmNode(
      id: 'activate_team',
      type: NodeType.action,
      title: 'Ativar Equipe de RessuscitaÃ§Ã£o',
      alertLevel: 'danger',
      bullets: [
        'Acionar cÃ³digo / time de ressuscitaÃ§Ã£o',
        'Solicitar DEA / desfibrilador imediatamente',
        'Anotar hora da parada',
        'Iniciar CPR de alta qualidade AGORA',
      ],
      nextNodeId: 'cpr_quality',
    ),

    // â”€â”€ CPR DE ALTA QUALIDADE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'cpr_quality': const AlgorithmNode(
      id: 'cpr_quality',
      type: NodeType.info,
      title: 'CPR de Alta Qualidade',
      alertLevel: 'danger',
      bullets: [
        'ðŸ’ª Profundidade: â‰¥ 5 cm (adulto)',
        'âš¡ FrequÃªncia: 100â€“120 compressÃµes/min',
        'ðŸ”„ ReexpansÃ£o torÃ¡cica completa entre compressÃµes',
        'â±ï¸ Minimizar interrupÃ§Ãµes (< 10 seg)',
        'ðŸ« VentilaÃ§Ã£o: 30:2 atÃ© via aÃ©rea avanÃ§ada',
        'ðŸ”‹ Trocar compressor a cada 2 min (ou se fadiga)',
      ],
      nextNodeId: 'start_timer_2min',
    ),

    // â”€â”€ TIMER 2 MIN â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'start_timer_2min': const AlgorithmNode(
      id: 'start_timer_2min',
      type: NodeType.timer,
      title: 'Iniciar Ciclo de CPR',
      subtitle: '2 minutos de CPR contÃ­nua',
      timerSeconds: 120,
      nextNodeId: 'rhythm_check_1',
    ),

    // â”€â”€ CHECAGEM DE RITMO 1 â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'rhythm_check_1': const AlgorithmNode(
      id: 'rhythm_check_1',
      type: NodeType.question,
      title: 'Verificar Ritmo CardÃ­aco',
      subtitle: 'Pausar CPR brevemente (< 10 seg) para checar ritmo',
      ecgImageAsset: 'vf',
      ecgTitle: 'Ritmo ChocÃ¡vel â€” FibrilaÃ§Ã£o Ventricular',
      ecgFindings: [
        'Ondas caÃ³ticas sem P, QRS ou T reconhecÃ­veis',
        'Amplitude e frequÃªncia variÃ¡veis e irregulares',
        'Ritmo Ãºnico que exige desfibrilaÃ§Ã£o imediata',
        'VF grosseira (amplitude >1mm) â€” melhor resposta ao choque',
      ],
      options: [
        AlgorithmOption(
          label: 'âš¡ ChocÃ¡vel â€” VF / pVT',
          sublabel: 'FibrilaÃ§Ã£o Ventricular ou TV sem pulso',
          nextNodeId: 'shock_1',
        ),
        AlgorithmOption(
          label: 'ðŸ“‰ NÃ£o ChocÃ¡vel â€” Assistolia',
          sublabel: 'Linha reta no monitor',
          nextNodeId: 'asystole_path',
        ),
        AlgorithmOption(
          label: 'ðŸ”² NÃ£o ChocÃ¡vel â€” AESP',
          sublabel: 'Atividade ElÃ©trica Sem Pulso',
          nextNodeId: 'pea_path',
        ),
        AlgorithmOption(
          label: 'âœ… ROSC â€” Retorno da CirculaÃ§Ã£o',
          sublabel: 'Pulso central detectado',
          nextNodeId: 'rosc_detected',
        ),
      ],
    ),

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  BRAÃ‡O CHOCÃVEL â€” VF / pVT
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    'shock_1': const AlgorithmNode(
      id: 'shock_1',
      type: NodeType.action,
      title: 'âš¡ DESFIBRILAR AGORA',
      subtitle: 'Ritmo chocÃ¡vel identificado â€” VF / pVT',
      alertLevel: 'danger',
      bullets: [
        'BifÃ¡sico: 200 J (ou mÃ¡ximo do equipamento)',
        'MonofÃ¡sico: 360 J',
        'Afastar todos antes do choque',
        'Retomar CPR IMEDIATAMENTE apÃ³s choque',
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
        'Acesso IV ou IO â€” estabelecer AGORA',
        'Considerar via aÃ©rea avanÃ§ada (IOT ou supraglÃ³tico)',
        'Monitorizar ETCOâ‚‚ se disponÃ­vel',
      ],
      nextNodeId: 'start_timer_2min_2',
    ),

    'start_timer_2min_2': const AlgorithmNode(
      id: 'start_timer_2min_2',
      type: NodeType.timer,
      title: 'Ciclo CPR â€” 2 minutos',
      timerSeconds: 120,
      nextNodeId: 'rhythm_check_2',
    ),

    'rhythm_check_2': const AlgorithmNode(
      id: 'rhythm_check_2',
      type: NodeType.question,
      title: 'Verificar Ritmo (2Âº checagem)',
      subtitle: 'Pausar CPR brevemente para anÃ¡lise',
      options: [
        AlgorithmOption(
          label: 'âš¡ ChocÃ¡vel â€” VF / pVT persiste',
          nextNodeId: 'shock_2',
        ),
        AlgorithmOption(
          label: 'ðŸ“‰ NÃ£o ChocÃ¡vel',
          nextNodeId: 'pea_asystole_mid',
        ),
        AlgorithmOption(
          label: 'âœ… ROSC',
          nextNodeId: 'rosc_detected',
        ),
      ],
    ),

    'shock_2': const AlgorithmNode(
      id: 'shock_2',
      type: NodeType.action,
      title: 'âš¡ 2Âº Choque + Epinefrina',
      alertLevel: 'danger',
      bullets: [
        'Desfibrilar: 200â€“360 J',
        'Retomar CPR imediatamente',
        'ðŸ’Š Epinefrina 1 mg IV/IO â€” AGORA',
        'Repetir Epi a cada 3â€“5 minutos',
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
        frequency: 'A cada 3â€“5 minutos',
        maxDose: 'Sem dose mÃ¡xima definida',
        notes: 'Preparar: 1 mg em 10 mL SF 0,9%. Flush com 20 mL SF apÃ³s.',
        color: '#EF4444',
      ),
      nextNodeId: 'start_timer_2min_3',
    ),

    'start_timer_2min_3': const AlgorithmNode(
      id: 'start_timer_2min_3',
      type: NodeType.timer,
      title: 'Ciclo CPR â€” 2 minutos',
      timerSeconds: 120,
      nextNodeId: 'rhythm_check_3',
    ),

    'rhythm_check_3': const AlgorithmNode(
      id: 'rhythm_check_3',
      type: NodeType.question,
      title: 'Verificar Ritmo (3Âª checagem)',
      options: [
        AlgorithmOption(
          label: 'âš¡ ChocÃ¡vel â€” VF / pVT persiste',
          nextNodeId: 'shock_3_antiarritmico',
        ),
        AlgorithmOption(
          label: 'ðŸ“‰ NÃ£o ChocÃ¡vel',
          nextNodeId: 'pea_asystole_mid',
        ),
        AlgorithmOption(
          label: 'âœ… ROSC',
          nextNodeId: 'rosc_detected',
        ),
      ],
    ),

    'shock_3_antiarritmico': const AlgorithmNode(
      id: 'shock_3_antiarritmico',
      type: NodeType.action,
      title: 'âš¡ 3Âº Choque + AntiarrÃ­tmico',
      alertLevel: 'danger',
      bullets: [
        'Desfibrilar: 200â€“360 J',
        'Retomar CPR imediatamente',
        'ðŸ’Š AntiarrÃ­tmico â€” AGORA (ver opÃ§Ãµes)',
      ],
      nextNodeId: 'antiarrhythmic_choice',
    ),

    'antiarrhythmic_choice': const AlgorithmNode(
      id: 'antiarrhythmic_choice',
      type: NodeType.question,
      title: 'Escolha do AntiarrÃ­tmico',
      subtitle: 'ApÃ³s 3Âº choque sem sucesso (VF/pVT refratÃ¡ria)',
      options: [
        AlgorithmOption(
          label: 'ðŸ’Š Amiodarona (1Âª escolha)',
          sublabel: 'Preferencial se disponÃ­vel',
          nextNodeId: 'amiodarone_drug',
        ),
        AlgorithmOption(
          label: 'ðŸ’Š LidocaÃ­na (alternativa)',
          sublabel: 'Usar se Amiodarona indisponÃ­vel',
          nextNodeId: 'lidocaine_drug',
        ),
      ],
    ),

    'amiodarone_drug': const AlgorithmNode(
      id: 'amiodarone_drug',
      type: NodeType.drug,
      title: 'Amiodarona â€” PCR',
      drug: DrugInfo(
        name: 'Amiodarona',
        dose: '300 mg (1Âª dose) â†’ 150 mg (2Âª dose)',
        route: 'IV / IO push',
        frequency: '1Âª dose: apÃ³s 3Âº choque. 2Âª dose: apÃ³s 5Âº choque',
        notes: 'Diluir em 20 mL de SG5% ou SF. Infundir em bolus rÃ¡pido durante PCR.',
        color: '#A855F7',
      ),
      nextNodeId: 'continue_vf_cycles',
    ),

    'lidocaine_drug': const AlgorithmNode(
      id: 'lidocaine_drug',
      type: NodeType.drug,
      title: 'LidocaÃ­na â€” PCR',
      drug: DrugInfo(
        name: 'LidocaÃ­na',
        dose: '1â€“1,5 mg/kg (1Âª dose) â†’ 0,5â€“0,75 mg/kg (2Âª dose)',
        route: 'IV / IO push',
        frequency: '2Âª dose apÃ³s 5â€“10 min se necessÃ¡rio',
        maxDose: 'MÃ¡x 3 mg/kg total',
        notes: 'Alternativa Ã  Amiodarona em VF/pVT refratÃ¡ria.',
        color: '#A855F7',
      ),
      nextNodeId: 'continue_vf_cycles',
    ),

    'continue_vf_cycles': const AlgorithmNode(
      id: 'continue_vf_cycles',
      type: NodeType.action,
      title: 'Continuar Ciclos de CPR + Choque',
      subtitle: 'VF/pVT refratÃ¡ria â€” protocolo contÃ­nuo',
      alertLevel: 'warning',
      bullets: [
        'Manter ciclos de 2 min CPR â†’ choque â†’ checagem',
        'Epinefrina 1mg IV/IO a cada 3â€“5 minutos',
        'Investigar e tratar causas reversÃ­veis (5H5T)',
        'Considerar ECMO-CPR se disponÃ­vel e indicado',
      ],
      nextNodeId: 'hs_ts',
    ),

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  BRAÃ‡O NÃƒO CHOCÃVEL â€” ASSISTOLIA
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    'asystole_path': const AlgorithmNode(
      id: 'asystole_path',
      type: NodeType.action,
      title: 'Assistolia â€” Protocolo',
      alertLevel: 'danger',
      ecgImageAsset: 'asystole',
      ecgTitle: 'Assistolia â€” Linha IsoelÃ©trica',
      ecgFindings: [
        'Linha completamente plana ou com artefatos mÃ­nimos',
        'AusÃªncia de qualquer atividade elÃ©trica organizada',
        'CONFIRMAR: checar cabos, derivaÃ§Ãµes e contato dos eletrodos',
        'Verificar em DUAS derivaÃ§Ãµes antes de confirmar assistolia',
        'NÃ£o desfibrilar â€” nÃ£o Ã© ritmo chocÃ¡vel',
      ],
      bullets: [
        'Confirmar: verificar cabos e eletrodos',
        'CPR contÃ­nua de alta qualidade',
        'ðŸ’Š Epinefrina 1 mg IV/IO â€” O MAIS RÃPIDO POSSÃVEL',
        'Repetir Epi a cada 3â€“5 min',
        'NÃ£o desfibrilar â€” NÃƒO Ã© ritmo chocÃ¡vel',
      ],
      nextNodeId: 'epi_asystole',
    ),

    'epi_asystole': const AlgorithmNode(
      id: 'epi_asystole',
      type: NodeType.drug,
      title: 'Epinefrina â€” Assistolia/AESP',
      drug: DrugInfo(
        name: 'Epinefrina (Adrenalina)',
        dose: '1 mg',
        route: 'IV / IO',
        frequency: 'A cada 3â€“5 minutos',
        notes: 'Administrar o mais precocemente possÃ­vel. Flush 20 mL SF apÃ³s cada dose.',
        color: '#EF4444',
      ),
      nextNodeId: 'hs_ts_asystole',
    ),

    'hs_ts_asystole': const AlgorithmNode(
      id: 'hs_ts_asystole',
      type: NodeType.action,
      title: 'Tratar Causas ReversÃ­veis (5H5T)',
      subtitle: 'Pesquisar e tratar TODAS as causas reversÃ­veis',
      alertLevel: 'warning',
      bullets: [
        'ðŸ…— Hipovolemia â†’ reposiÃ§Ã£o volÃªmica',
        'ðŸ…— HipÃ³xia â†’ otimizar ventilaÃ§Ã£o/oxigenaÃ§Ã£o',
        'ðŸ…— HidrogÃªnio (acidose) â†’ bicarbonato se pH < 7,1',
        'ðŸ…— Hipo/Hipercalemia â†’ corrigir eletrÃ³litos',
        'ðŸ…— Hipotermia â†’ aquecer paciente',
        'ðŸ…£ TensÃ£o pneumotÃ³rax â†’ descompressÃ£o imediata',
        'ðŸ…£ Tamponamento cardÃ­aco â†’ pericardiocentese',
        'ðŸ…£ Toxinas â†’ antÃ­dotos especÃ­ficos',
        'ðŸ…£ Trombose coronÃ¡ria â†’ IAM â†’ ICP/trombÃ³lise',
        'ðŸ…£ Trombose pulmonar â†’ TEP â†’ trombÃ³lise',
      ],
      nextNodeId: 'asystole_cycle',
    ),

    'asystole_cycle': const AlgorithmNode(
      id: 'asystole_cycle',
      type: NodeType.timer,
      title: 'Ciclo CPR â€” Assistolia (2 min)',
      timerSeconds: 120,
      nextNodeId: 'rhythm_check_asystole',
    ),

    'rhythm_check_asystole': const AlgorithmNode(
      id: 'rhythm_check_asystole',
      type: NodeType.question,
      title: 'Verificar Ritmo',
      options: [
        AlgorithmOption(
          label: 'âš¡ Ritmo chocÃ¡vel agora (VF/pVT)',
          nextNodeId: 'shock_1',
        ),
        AlgorithmOption(
          label: 'ðŸ“‰ NÃ£o chocÃ¡vel â€” continuar',
          nextNodeId: 'asystole_continue',
        ),
        AlgorithmOption(
          label: 'âœ… ROSC',
          nextNodeId: 'rosc_detected',
        ),
      ],
    ),

    'asystole_continue': const AlgorithmNode(
      id: 'asystole_continue',
      type: NodeType.question,
      title: 'Considerar TÃ©rmino da RessuscitaÃ§Ã£o (TOR)',
      subtitle: 'Avaliar apÃ³s mÃºltiplos ciclos sem resposta',
      alertLevel: 'info',
      bullets: [
        'DuraÃ§Ã£o da ressuscitaÃ§Ã£o',
        'ETCOâ‚‚ < 10 mmHg apÃ³s 20 min (fator isolado nÃ£o suficiente)',
        'Causas reversÃ­veis identificadas e tratadas?',
        'Desejo do paciente (diretivas antecipadas)',
        'CondiÃ§Ã£o clÃ­nica prÃ©via',
      ],
      options: [
        AlgorithmOption(
          label: 'ðŸ”„ Continuar ressuscitaÃ§Ã£o',
          nextNodeId: 'asystole_cycle',
        ),
        AlgorithmOption(
          label: 'ðŸ›‘ Encerrar ressuscitaÃ§Ã£o',
          nextNodeId: 'tor',
        ),
      ],
    ),

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  BRAÃ‡O NÃƒO CHOCÃVEL â€” AESP
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    'pea_path': const AlgorithmNode(
      id: 'pea_path',
      type: NodeType.action,
      title: 'AESP â€” Atividade ElÃ©trica Sem Pulso',
      alertLevel: 'danger',
      ecgImageAsset: 'pea',
      ecgTitle: 'AESP â€” Ritmo Organizado Sem Pulso',
      ecgFindings: [
        'Qualquer ritmo organizado no monitor SEM pulso palpÃ¡vel',
        'Geralmente ritmo sinusal, bradicardia ou idioventricular lento',
        'QRS estreito â†’ pensar tamponamento, embolia pulmonar, hipovolemia',
        'QRS largo â†’ pensar hipercalemia, toxinas, IAM extenso',
        'NÃ£o confundir com fibrilaÃ§Ã£o ventricular fina',
      ],
      bullets: [
        'CPR de alta qualidade contÃ­nua',
        'ðŸ’Š Epinefrina 1 mg IV/IO â€” O MAIS RÃPIDO POSSÃVEL',
        'Investigar causas reversÃ­veis URGENTE (5H5T)',
        'AESP de complexo estreito â†’ pensar em tamponamento',
        'AESP de complexo largo â†’ pensar hipercalemia/toxinas',
      ],
      nextNodeId: 'epi_pea',
    ),

    'epi_pea': const AlgorithmNode(
      id: 'epi_pea',
      type: NodeType.drug,
      title: 'Epinefrina â€” AESP',
      drug: DrugInfo(
        name: 'Epinefrina (Adrenalina)',
        dose: '1 mg',
        route: 'IV / IO',
        frequency: 'A cada 3â€“5 minutos',
        notes: 'Administrar o mais precocemente possÃ­vel. Flush 20 mL SF apÃ³s cada dose.',
        color: '#EF4444',
      ),
      nextNodeId: 'pea_ultrasound',
    ),

    'pea_ultrasound': const AlgorithmNode(
      id: 'pea_ultrasound',
      type: NodeType.question,
      title: 'USG Point-of-Care (POCUS) disponÃ­vel?',
      subtitle: 'Ultrassom durante PCR para identificar causas reversÃ­veis',
      options: [
        AlgorithmOption(
          label: 'âœ… Sim â€” realizar POCUS',
          nextNodeId: 'pocus_findings',
        ),
        AlgorithmOption(
          label: 'âŒ NÃ£o disponÃ­vel',
          nextNodeId: 'hs_ts',
        ),
      ],
    ),

    'pocus_findings': const AlgorithmNode(
      id: 'pocus_findings',
      type: NodeType.question,
      title: 'Achados no POCUS',
      subtitle: 'Interromper CPR < 10 seg para avaliaÃ§Ã£o',
      options: [
        AlgorithmOption(
          label: 'ðŸ’§ Derrame pericÃ¡rdico â†’ Tamponamento',
          nextNodeId: 'tamponade_action',
        ),
        AlgorithmOption(
          label: 'ðŸ« PneumotÃ³rax â†’ TÃ³rax hiperecogÃªnico',
          nextNodeId: 'pneumothorax_action',
        ),
        AlgorithmOption(
          label: 'ðŸ“‰ VD dilatado â†’ TEP',
          nextNodeId: 'pe_action',
        ),
        AlgorithmOption(
          label: 'ðŸ«€ Hipovolemia grave',
          nextNodeId: 'hypovolemia_action',
        ),
        AlgorithmOption(
          label: 'â¬œ Sem achados especÃ­ficos',
          nextNodeId: 'hs_ts',
        ),
      ],
    ),

    'tamponade_action': const AlgorithmNode(
      id: 'tamponade_action',
      type: NodeType.action,
      title: 'ðŸ’§ Tamponamento CardÃ­aco',
      alertLevel: 'danger',
      bullets: [
        'Pericardiocentese de emergÃªncia â€” IMEDIATA',
        'Acesso subxifoide guiado por USG preferÃ­vel',
        'Aspirar 20â€“50 mL pode restaurar dÃ©bito',
        'Contato com cirurgia cardÃ­aca se disponÃ­vel',
      ],
      nextNodeId: 'hs_ts',
    ),

    'pneumothorax_action': const AlgorithmNode(
      id: 'pneumothorax_action',
      type: NodeType.action,
      title: 'ðŸ« PneumotÃ³rax Hipertensivo',
      alertLevel: 'danger',
      bullets: [
        'DescompressÃ£o imediata â€” nÃ£o aguardar RX',
        'PunÃ§Ã£o de alÃ­vio: 2Âº EIC, linha MCL',
        'Agulha 14G Ã— 3,5 cm',
        'Drenagem torÃ¡cica subsequente',
      ],
      nextNodeId: 'hs_ts',
    ),

    'pe_action': const AlgorithmNode(
      id: 'pe_action',
      type: NodeType.action,
      title: 'ðŸ“‰ TEP MaciÃ§o â€” TrombÃ³lise em PCR',
      alertLevel: 'danger',
      bullets: [
        'Considerar trombÃ³lise empÃ­rica se TEP provÃ¡vel',
        'Alteplase 50 mg IV em bolus',
        'Continuar CPR por 60â€“90 min apÃ³s trombÃ³lise',
        'Contato com hemodinÃ¢mica para trombectomia',
        'Considerar ECMO-CPR',
      ],
      nextNodeId: 'alteplase_drug',
    ),

    'alteplase_drug': const AlgorithmNode(
      id: 'alteplase_drug',
      type: NodeType.drug,
      title: 'Alteplase â€” TEP em PCR',
      drug: DrugInfo(
        name: 'Alteplase (rt-PA)',
        dose: '50 mg',
        route: 'IV bolus',
        notes: 'Manter CPR por 60â€“90 min apÃ³s administraÃ§Ã£o. NÃ£o interromper ressuscitaÃ§Ã£o apÃ³s trombÃ³lise.',
        color: '#3B82F6',
      ),
      nextNodeId: 'asystole_cycle',
    ),

    'hypovolemia_action': const AlgorithmNode(
      id: 'hypovolemia_action',
      type: NodeType.action,
      title: 'ðŸ«€ Hipovolemia Grave',
      alertLevel: 'warning',
      bullets: [
        'ExpansÃ£o volÃªmica rÃ¡pida: 1â€“2L SF 0,9% / RL',
        'Se trauma: transfusÃ£o de CH + PFC (1:1)',
        'Controle do sangramento se origem identificada',
        'Clampeamento aÃ³rtico (REBOA) se disponÃ­vel em trauma',
      ],
      nextNodeId: 'hs_ts',
    ),

    // â”€â”€ 5H5T â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'hs_ts': const AlgorithmNode(
      id: 'hs_ts',
      type: NodeType.info,
      title: '5H5T â€” Causas ReversÃ­veis de PCR',
      subtitle: 'Identificar e tratar SIMULTANEAMENTE Ã  ressuscitaÃ§Ã£o',
      alertLevel: 'warning',
      bullets: [
        'ðŸ…— Hipovolemia â†’ SF/RL IV rÃ¡pido',
        'ðŸ…— HipÃ³xia â†’ Ventilar, IOT, Oâ‚‚ 100%',
        'ðŸ…— HidrogÃªnio (acidose) â†’ Bicarbonato de Na 1â€“2 mEq/kg se pH<7,1',
        'ðŸ…— Hipo/Hipercalemia â†’ ECG, corrigir Kâº',
        'ðŸ…— Hipotermia â†’ Reaquecimento ativo',
        'ðŸ…£ TensÃ£o (pneumotÃ³rax) â†’ DescompressÃ£o agulha',
        'ðŸ…£ Tamponamento â†’ Pericardiocentese',
        'ðŸ…£ Toxinas â†’ Naloxona, flumazenil, Intralipid, glucagonato',
        'ðŸ…£ Trombose coronÃ¡ria â†’ IAMCSST â†’ ICP emergÃªncia',
        'ðŸ…£ Trombose pulmonar â†’ TEP â†’ trombÃ³lise',
      ],
      nextNodeId: 'asystole_cycle',
    ),

    'pea_asystole_mid': const AlgorithmNode(
      id: 'pea_asystole_mid',
      type: NodeType.action,
      title: 'NÃ£o ChocÃ¡vel â€” Continuar Protocolo',
      alertLevel: 'warning',
      bullets: [
        'CPR contÃ­nua de alta qualidade',
        'Epinefrina 1mg IV/IO a cada 3â€“5 min',
        'Tratar causas reversÃ­veis (5H5T)',
      ],
      nextNodeId: 'hs_ts',
    ),

    // â”€â”€ ROSC â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'rosc_detected': const AlgorithmNode(
      id: 'rosc_detected',
      type: NodeType.action,
      title: 'âœ… ROSC â€” Retorno da CirculaÃ§Ã£o EspontÃ¢nea',
      alertLevel: 'success',
      subtitle: 'Iniciar cuidados pÃ³s-PCR IMEDIATAMENTE',
      bullets: [
        'Confirmar: pulso central palpÃ¡vel + PA mensurÃ¡vel',
        'Checar SpOâ‚‚, ETCOâ‚‚ (aumento sÃºbito > 40 mmHg sugere ROSC)',
        'Suspender compressÃµes',
        'AvanÃ§ar para algoritmo PÃ³s-PCR',
      ],
      options: [
        AlgorithmOption(
          label: 'ðŸŸ¢ Ir para Cuidados PÃ³s-PCR',
          nextNodeId: '__goto_post_rosc',
        ),
      ],
    ),

    // â”€â”€ TÃ‰RMINO DA RESSUSCITAÃ‡ÃƒO â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'tor': const AlgorithmNode(
      id: 'tor',
      type: NodeType.end,
      title: 'ðŸ›‘ TÃ©rmino da RessuscitaÃ§Ã£o (TOR)',
      alertLevel: 'info',
      subtitle: 'CritÃ©rios AHA 2025',
      bullets: [
        'AusÃªncia de ROSC apÃ³s ressuscitaÃ§Ã£o adequada',
        'Causas reversÃ­veis identificadas e tratadas',
        'ETCOâ‚‚ < 10 mmHg apÃ³s 20 min (coadjuvante)',
        'DecisÃ£o compartilhada com equipe',
        'Registrar hora do Ã³bito',
        'Comunicar famÃ­lia com suporte emocional',
      ],
    ),
  },
);

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  ALGORITMO BRADICARDIA â€” AHA 2025
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

final bradycardiaAlgorithm = Algorithm(
  id: 'bradycardia',
  title: 'Bradicardia com Pulso',
  subtitle: 'FC < 50 bpm Â· AvaliaÃ§Ã£o e Tratamento',
  iconEmoji: 'ðŸ¢',
  color: '#3B82F6',
  startNodeId: 'brady_start',
  nodes: {
    'brady_start': const AlgorithmNode(
      id: 'brady_start',
      type: NodeType.question,
      title: 'FrequÃªncia CardÃ­aca',
      subtitle: 'Bradicardia clinicamente significativa: FC < 50 bpm',
      options: [
        AlgorithmOption(
          label: 'ðŸ”µ FC < 50 bpm â€” prosseguir avaliaÃ§Ã£o',
          nextNodeId: 'brady_symptoms',
        ),
        AlgorithmOption(
          label: 'âš ï¸ FC 50â€“60 bpm â€” assintomÃ¡tico',
          sublabel: 'Bradicardia relativa â€” observar',
          nextNodeId: 'brady_monitor',
        ),
      ],
    ),

    'brady_monitor': const AlgorithmNode(
      id: 'brady_monitor',
      type: NodeType.info,
      title: 'Bradicardia AssintomÃ¡tica',
      alertLevel: 'info',
      bullets: [
        'MonitorizaÃ§Ã£o contÃ­nua (ECG, SpOâ‚‚, PA)',
        'Investigar causa subjacente',
        'Revisar medicamentos bradicardizantes',
        'Avaliar: hipotireoidismo, distÃºrbios eletrolÃ­ticos, IAM inferior',
      ],
      nextNodeId: 'brady_symptoms',
    ),

    'brady_symptoms': const AlgorithmNode(
      id: 'brady_symptoms',
      type: NodeType.question,
      title: 'Sinais e Sintomas de Instabilidade?',
      subtitle: 'A bradicardia estÃ¡ causando comprometimento hemodinÃ¢mico?',
      options: [
        AlgorithmOption(
          label: 'ðŸ”´ SIM â€” InstÃ¡vel',
          sublabel: 'HipotensÃ£o Â· AMS Â· Sinais de choque Â· Dor precordial isquÃªmica Â· IC aguda',
          nextNodeId: 'brady_atropine',
        ),
        AlgorithmOption(
          label: 'ðŸŸ¡ NÃ£o â€” EstÃ¡vel com sintomas leves',
          sublabel: 'Tontura, cansaÃ§o, sÃ­ncope isolada',
          nextNodeId: 'brady_type',
        ),
        AlgorithmOption(
          label: 'ðŸŸ¢ Sem sintomas',
          nextNodeId: 'brady_type',
        ),
      ],
    ),

    'brady_atropine': const AlgorithmNode(
      id: 'brady_atropine',
      type: NodeType.drug,
      title: 'ðŸ”´ Atropina â€” 1Âª linha',
      subtitle: 'Bradicardia sintomÃ¡tica/instÃ¡vel',
      drug: DrugInfo(
        name: 'Atropina',
        dose: '1 mg',
        route: 'IV push',
        frequency: 'Repetir a cada 3â€“5 min se necessÃ¡rio',
        maxDose: 'MÃ¡x 3 mg (0,04 mg/kg)',
        notes: 'Administrar rapidamente (push). NÃ£o usar em transplantados cardÃ­acos. Ineficaz em BAV infranodal.',
        color: '#3B82F6',
      ),
      nextNodeId: 'brady_atropine_response',
    ),

    'brady_atropine_response': const AlgorithmNode(
      id: 'brady_atropine_response',
      type: NodeType.question,
      title: 'Resposta Ã  Atropina?',
      subtitle: 'Aguardar 1â€“2 min apÃ³s cada dose',
      options: [
        AlgorithmOption(
          label: 'âœ… Boa resposta â€” FC aumentou, estabilizou',
          nextNodeId: 'brady_stable_after_atropine',
        ),
        AlgorithmOption(
          label: 'âŒ Sem resposta apÃ³s 3 mg total',
          nextNodeId: 'brady_pacing',
        ),
        AlgorithmOption(
          label: 'âš ï¸ Resposta parcial â€” instÃ¡vel ainda',
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
        'MonitorizaÃ§Ã£o contÃ­nua',
        'Investigar e tratar causa de base',
        'Avaliar necessidade de marcapasso definitivo',
        'Solicitar avaliaÃ§Ã£o de cardiologia',
      ],
      nextNodeId: 'brady_type',
    ),

    'brady_pacing': const AlgorithmNode(
      id: 'brady_pacing',
      type: NodeType.action,
      title: 'âš¡ Marcapasso TranscutÃ¢neo (MCP)',
      alertLevel: 'danger',
      bullets: [
        'Sedoanalgesia antes: Midazolam + Fentanil',
        'FrequÃªncia: 60â€“80 bpm',
        'Iniciar corrente: 50â€“100 mA, aumentar atÃ© captura',
        'Confirmar captura elÃ©trica + mecÃ¢nica (pulso)',
        'Preparar marcapasso transvenoso se MCP ineficaz',
      ],
      nextNodeId: 'brady_infusion_while_pacing',
    ),

    'brady_infusion_while_pacing': const AlgorithmNode(
      id: 'brady_infusion_while_pacing',
      type: NodeType.question,
      title: 'InfusÃ£o ContÃ­nua como Ponte',
      subtitle: 'Enquanto aguarda marcapasso transvenoso',
      options: [
        AlgorithmOption(
          label: 'ðŸ’‰ Dopamina',
          sublabel: 'Bradicardia + hipotensÃ£o',
          nextNodeId: 'dopamine_brady',
        ),
        AlgorithmOption(
          label: 'ðŸ’‰ Epinefrina',
          sublabel: 'Bradicardia refratÃ¡ria',
          nextNodeId: 'epi_brady',
        ),
      ],
    ),

    'dopamine_brady': const AlgorithmNode(
      id: 'dopamine_brady',
      type: NodeType.drug,
      title: 'Dopamina â€” Bradicardia',
      drug: DrugInfo(
        name: 'Dopamina',
        dose: '5â€“20 mcg/kg/min',
        route: 'InfusÃ£o IV contÃ­nua',
        notes: 'Titular para FC e PA alvo. Efeito cronotrÃ³pico positivo > 5 mcg/kg/min.',
        color: '#3B82F6',
      ),
      nextNodeId: 'brady_type',
    ),

    'epi_brady': const AlgorithmNode(
      id: 'epi_brady',
      type: NodeType.drug,
      title: 'Epinefrina â€” Bradicardia RefratÃ¡ria',
      drug: DrugInfo(
        name: 'Epinefrina',
        dose: '2â€“10 mcg/min',
        route: 'InfusÃ£o IV contÃ­nua',
        notes: 'Titular para efeito. Iniciar 2 mcg/min e aumentar conforme resposta.',
        color: '#EF4444',
      ),
      nextNodeId: 'brady_type',
    ),

    'brady_type': const AlgorithmNode(
      id: 'brady_type',
      type: NodeType.question,
      title: 'Identificar Tipo de Bradicardia',
      subtitle: 'AnÃ¡lise do ECG de 12 derivaÃ§Ãµes',
      options: [
        AlgorithmOption(
          label: '1ï¸âƒ£ BAV 1Âº Grau',
          sublabel: 'PR > 200ms, todos conduzidos',
          nextNodeId: 'bav1_info',
        ),
        AlgorithmOption(
          label: '2ï¸âƒ£ BAV 2Âº Grau â€” Mobitz I (Wenckebach)',
          sublabel: 'PR progressivo â†’ bloqueio',
          nextNodeId: 'mobitz1_info',
        ),
        AlgorithmOption(
          label: '2ï¸âƒ£ BAV 2Âº Grau â€” Mobitz II',
          sublabel: 'Bloqueio sÃºbito sem alteraÃ§Ã£o do PR',
          nextNodeId: 'mobitz2_info',
        ),
        AlgorithmOption(
          label: '3ï¸âƒ£ BAV Total (BAVT)',
          sublabel: 'DissociaÃ§Ã£o AV completa',
          nextNodeId: 'bavt_info',
        ),
        AlgorithmOption(
          label: 'ðŸŒ¿ Bradicardia Sinusal',
          nextNodeId: 'sinus_brady_info',
        ),
      ],
    ),

    'bav1_info': const AlgorithmNode(
      id: 'bav1_info',
      type: NodeType.info,
      title: 'BAV 1Âº Grau',
      alertLevel: 'info',
      bullets: [
        'Geralmente benigno e assintomÃ¡tico',
        'Causas: vagotonia, atletas, digoxina, hipotireoidismo, IAM inferior',
        'NÃ£o requer tratamento especÃ­fico',
        'MonitorizaÃ§Ã£o + investigar causa',
      ],
    ),

    'mobitz1_info': const AlgorithmNode(
      id: 'mobitz1_info',
      type: NodeType.info,
      title: 'BAV 2Âº Grau â€” Mobitz I (Wenckebach)',
      alertLevel: 'info',
      ecgImageAsset: 'wenckebach',
      ecgTitle: 'Wenckebach â€” BAV Mobitz I',
      ecgFindings: [
        'PR progressivamente maior a cada batimento',
        'AtÃ© que uma onda P Ã© bloqueada (sem QRS)',
        'ApÃ³s o bloqueio, o ciclo recomeÃ§a com PR curto',
        'QRS geralmente estreito (bloqueio nodal)',
        'Ritmo ventricular irregular (pausa apÃ³s bloqueio)',
      ],
      bullets: [
        'Bloqueio nodal (suprahissiano) â€” geralmente benigno',
        'Causas comuns: IAM inferior, miocardite, drogas',
        'Raramente sintomÃ¡tico',
        'Atropina geralmente eficaz se necessÃ¡rio',
        'Seguimento cardiolÃ³gico recomendado',
      ],
    ),

    'mobitz2_info': const AlgorithmNode(
      id: 'mobitz2_info',
      type: NodeType.info,
      title: 'BAV 2Âº Grau â€” Mobitz II âš ï¸',
      alertLevel: 'warning',
      ecgImageAsset: 'mobitz2',
      ecgTitle: 'Mobitz II â€” Bloqueio Infranodal',
      ecgFindings: [
        'PR CONSTANTE (nÃ£o alonga) em todos os batimentos conduzidos',
        'Bloqueio sÃºbito de uma onda P sem aviso prÃ©vio',
        'QRS geralmente LARGO (BRE ou BRD â€” bloqueio distal)',
        'Alto risco de progressÃ£o para BAVT e assistolia',
        'Atropina INEFICAZ â€” bloqueio abaixo do nÃ³ AV',
      ],
      bullets: [
        'Bloqueio infranodal (infrahissiano) â€” instÃ¡vel',
        'Alto risco de progressÃ£o para BAVT',
        'Causas: IAM anterior, doenÃ§a degenerativa',
        'Atropina INEFICAZ (bloqueio distal)',
        'IndicaÃ§Ã£o frequente de marcapasso permanente',
        'Preparar MCP transcutÃ¢neo de standby',
      ],
    ),

    'bavt_info': const AlgorithmNode(
      id: 'bavt_info',
      type: NodeType.action,
      title: 'BAV Total (BAVT) â€” Conduta',
      alertLevel: 'danger',
      ecgImageAsset: 'avb3',
      ecgTitle: 'BAV 3Âº Grau â€” DissociaÃ§Ã£o AV Completa',
      ecgFindings: [
        'Ondas P regulares (ritmo atrial ~60â€“80 bpm)',
        'QRS regulares MAS com frequÃªncia MUITO mais lenta (~30â€“45 bpm)',
        'NENHUMA relaÃ§Ã£o entre ondas P e complexos QRS',
        'QRS largo â†’ escape ventricular (mais grave)',
        'QRS estreito â†’ escape juncional (nÃ³ AV, mais estÃ¡vel)',
        'P pode cair dentro do QRS ou da onda T',
      ],
      bullets: [
        'DissociaÃ§Ã£o AV completa â€” bloqueio mais grave',
        'Se instÃ¡vel: MCP TRANSCUTÃ‚NEO IMEDIATO',
        'Atropina pode ser tentada (eficaz apenas no nodal)',
        'Dopamina/Epinefrina como ponte',
        'Cardiologia urgente â€” marcapasso transvenoso/definitivo',
        'Investigar: IAM, miocardite, DoenÃ§a de Lyme, drogas',
      ],
    ),

    'sinus_brady_info': const AlgorithmNode(
      id: 'sinus_brady_info',
      type: NodeType.info,
      title: 'Bradicardia Sinusal',
      alertLevel: 'info',
      ecgImageAsset: 'bradycardia',
      ecgTitle: 'Bradicardia Sinusal',
      ecgFindings: [
        'FC < 60 bpm (significativa < 50 bpm)',
        'Onda P positiva antes de cada QRS (P sinusal)',
        'PR normal (120â€“200 ms)',
        'QRS estreito (normal) â€” complexo normal preservado',
        'Ritmo regular com intervalos RR prolongados',
      ],
      bullets: [
        'Comum em atletas, vagotonicos, durante sono',
        'Causas patolÃ³gicas: hipotireoidismo, doenÃ§a do nÃ³ sinusal, IAM inferior, drogas (betabloqueador, BCC, digoxina)',
        'Tratar se sintomÃ¡tica: Atropina 1mg IV',
        'Investigar e tratar causa de base',
      ],
    ),
  },
);

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  ALGORITMO TAQUICARDIA â€” AHA 2025
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

final tachycardiaAlgorithm = Algorithm(
  id: 'tachycardia',
  title: 'Taquicardia com Pulso',
  subtitle: 'FC > 100 bpm Â· Narrow vs Wide QRS',
  iconEmoji: 'âš¡',
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
          label: 'ðŸ”´ INSTÃVEL â€” sinais de comprometimento',
          sublabel: 'HipotensÃ£o Â· AlteraÃ§Ã£o de consciÃªncia Â· Choque Â· Dor precordial Â· IC aguda',
          nextNodeId: 'tachy_unstable',
        ),
        AlgorithmOption(
          label: 'ðŸŸ¡ ESTÃVEL â€” sem comprometimento hemodinÃ¢mico',
          nextNodeId: 'tachy_qrs_width',
        ),
      ],
    ),

    // â”€â”€ INSTÃVEL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'tachy_unstable': const AlgorithmNode(
      id: 'tachy_unstable',
      type: NodeType.action,
      title: 'âš¡ CardioversÃ£o Sincronizada â€” IMEDIATA',
      alertLevel: 'danger',
      bullets: [
        'Sedoanalgesia se tempo permitir (Midazolam + Fentanil)',
        'Sincronizar no monitor: botÃ£o SYNC',
        'Posicionar pÃ¡s: antero-posterior ou antero-lateral',
        'ðŸ”‹ Energia recomendada:',
        '   â€¢ FA: â‰¥ 200 J bifÃ¡sico (nova recomendaÃ§Ã£o 2025)',
        '   â€¢ Flutter/TSV: 50â€“100 J',
        '   â€¢ TV monomÃ³rfica: 100 J',
        'Se falhar: aumentar energia',
        'TV polimÃ³rfica (instÃ¡vel): desfibrilaÃ§Ã£o (nÃ£o sincronizado)',
      ],
      nextNodeId: 'cardioversion_response',
    ),

    'cardioversion_response': const AlgorithmNode(
      id: 'cardioversion_response',
      type: NodeType.question,
      title: 'Resposta Ã  CardioversÃ£o?',
      options: [
        AlgorithmOption(
          label: 'âœ… Converteu para ritmo sinusal',
          nextNodeId: 'tachy_post_cardioversion',
        ),
        AlgorithmOption(
          label: 'âŒ NÃ£o converteu â€” refratÃ¡rio',
          nextNodeId: 'tachy_refractory',
        ),
        AlgorithmOption(
          label: 'âš¡ Deteriorou â†’ PCR',
          nextNodeId: '__goto_cardiac_arrest',
        ),
      ],
    ),

    'tachy_post_cardioversion': const AlgorithmNode(
      id: 'tachy_post_cardioversion',
      type: NodeType.info,
      title: 'Converteu â€” Ritmo Sinusal',
      alertLevel: 'success',
      bullets: [
        'MonitorizaÃ§Ã£o contÃ­nua',
        'Investigar causa de base',
        'AnticoagulaÃ§Ã£o se FA/Flutter (avaliar risco)',
        'Consulta cardiolÃ³gica',
      ],
    ),

    'tachy_refractory': const AlgorithmNode(
      id: 'tachy_refractory',
      type: NodeType.action,
      title: 'CardioversÃ£o RefratÃ¡ria',
      alertLevel: 'danger',
      bullets: [
        'Aumentar energia de choque',
        'Considerar antiarrÃ­tmico IV antes de nova tentativa',
        'Amiodarona 150 mg IV em 10 min',
        'Repetir cardioversÃ£o',
        'Consultar eletrofisiologista/cardiologista urgente',
      ],
      nextNodeId: 'amio_cardioversion',
    ),

    'amio_cardioversion': const AlgorithmNode(
      id: 'amio_cardioversion',
      type: NodeType.drug,
      title: 'Amiodarona â€” CardioversÃ£o RefratÃ¡ria',
      drug: DrugInfo(
        name: 'Amiodarona',
        dose: '150 mg',
        route: 'IV em 10 min',
        frequency: 'Repetir 150 mg IV se necessÃ¡rio; depois 1 mg/min por 6h',
        maxDose: 'MÃ¡x 2,2 g/24h',
        notes: 'ApÃ³s cardioversÃ£o quÃ­mica, tentar cardioversÃ£o elÃ©trica novamente.',
        color: '#A855F7',
      ),
      nextNodeId: 'tachy_qrs_width',
    ),

    // â”€â”€ ESTÃVEL â€” AVALIAÃ‡ÃƒO POR QRS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'tachy_qrs_width': const AlgorithmNode(
      id: 'tachy_qrs_width',
      type: NodeType.question,
      title: 'Largura do QRS',
      subtitle: 'Medir em derivaÃ§Ã£o com melhor visualizaÃ§Ã£o',
      options: [
        AlgorithmOption(
          label: 'ðŸ”µ QRS Estreito < 120 ms',
          sublabel: 'Taquicardia supraventricular (TSV)',
          nextNodeId: 'narrow_regular',
        ),
        AlgorithmOption(
          label: 'ðŸ”´ QRS Largo â‰¥ 120 ms',
          sublabel: 'TV ou TSV com aberrÃ¢ncia',
          nextNodeId: 'wide_regular',
        ),
      ],
    ),

    // â”€â”€ QRS ESTREITO â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'narrow_regular': const AlgorithmNode(
      id: 'narrow_regular',
      type: NodeType.question,
      title: 'TSV â€” Ritmo Regular ou Irregular?',
      ecgImageAsset: 'svt',
      ecgTitle: 'Taquicardia Supraventricular (TSV)',
      ecgFindings: [
        'QRS ESTREITO < 120 ms (origem supraventricular)',
        'FC geralmente 150â€“250 bpm (regular)',
        'Ondas P canÃ³nicas ausentes ou apÃ³s o QRS',
        'InÃ­cio e tÃ©rmino abruptos (paroxÃ­stica)',
        'Responde a manobras vagais ou adenosina',
      ],
      options: [
        AlgorithmOption(
          label: 'ðŸ“ Regular',
          nextNodeId: 'narrow_regular_action',
        ),
        AlgorithmOption(
          label: 'ã€°ï¸ Irregular',
          sublabel: 'FA, Flutter com conduÃ§Ã£o variÃ¡vel, WPW',
          nextNodeId: 'narrow_irregular',
        ),
      ],
    ),

    'narrow_regular_action': const AlgorithmNode(
      id: 'narrow_regular_action',
      type: NodeType.question,
      title: 'TSV Regular â€” EstratÃ©gia',
      subtitle: 'TRNAV / TRAV / Taquicardia atrial',
      options: [
        AlgorithmOption(
          label: 'ðŸ¤¸ Manobra Vagal primeiro',
          sublabel: 'Valsalva modificado ou massagem seio carotÃ­deo',
          nextNodeId: 'vagal_maneuver',
        ),
        AlgorithmOption(
          label: 'ðŸ’Š Ir direto para Adenosina',
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
        'âœ… Valsalva Modificado (posiÃ§Ã£o supina â†’ pernas elevadas):',
        '   Expirar forÃ§ado 15 seg â†’ decÃºbito dorsal imediato + elevar pernas 45Â°',
        '   Manter por 15 seg (mais eficaz que Valsalva clÃ¡ssico)',
        'âš ï¸ Massagem do Seio CarotÃ­deo:',
        '   Auscultar antes (descartar sopro carotÃ­deo)',
        '   Massagem unilateral 5â€“10 seg com monitorizaÃ§Ã£o',
        '   CI: histÃ³ria de AVC, sopro carotÃ­deo, EP carotÃ­deo',
      ],
      nextNodeId: 'vagal_response',
    ),

    'vagal_response': const AlgorithmNode(
      id: 'vagal_response',
      type: NodeType.question,
      title: 'Resposta Ã  Manobra Vagal?',
      options: [
        AlgorithmOption(
          label: 'âœ… Converteu para sinusal',
          nextNodeId: 'tachy_post_cardioversion',
        ),
        AlgorithmOption(
          label: 'âŒ Sem conversÃ£o',
          nextNodeId: 'adenosine_drug',
        ),
      ],
    ),

    'adenosine_drug': const AlgorithmNode(
      id: 'adenosine_drug',
      type: NodeType.drug,
      title: 'Adenosina â€” TSV Regular',
      drug: DrugInfo(
        name: 'Adenosina',
        dose: '6 mg (1Âª dose) â†’ 12 mg (2Âª dose) â†’ 12 mg (3Âª dose)',
        route: 'IV push RÃPIDO â€” acesso proximal + flush 20 mL rÃ¡pido',
        frequency: '1â€“2 min entre doses',
        maxDose: 'MÃ¡x 30 mg total',
        notes: 'Avisar o paciente sobre sensaÃ§Ã£o de aperto no peito (transitÃ³rio). CI: asma grave, WPW+FA, BAV 2/3 grau.',
        color: '#22C55E',
      ),
      nextNodeId: 'adenosine_response',
    ),

    'adenosine_response': const AlgorithmNode(
      id: 'adenosine_response',
      type: NodeType.question,
      title: 'Resposta Ã  Adenosina?',
      options: [
        AlgorithmOption(
          label: 'âœ… Converteu para sinusal â€” TRNAV',
          nextNodeId: 'tachy_post_cardioversion',
        ),
        AlgorithmOption(
          label: 'ðŸ“‰ Revelou Flutter/FA subjacente',
          nextNodeId: 'narrow_irregular',
        ),
        AlgorithmOption(
          label: 'âŒ Sem resposta â€” taquicardia atrial provÃ¡vel',
          nextNodeId: 'tachy_atrial',
        ),
      ],
    ),

    'tachy_atrial': const AlgorithmNode(
      id: 'tachy_atrial',
      type: NodeType.action,
      title: 'Taquicardia Atrial / EctÃ³pica',
      alertLevel: 'info',
      bullets: [
        'ECG 12 derivaÃ§Ãµes para confirmar',
        'Betabloqueador IV: Metoprolol 5 mg IV lento (3 doses)',
        'ou Verapamil 5â€“10 mg IV em 2 min',
        'Consulta cardiolÃ³gica/eletrofisiologia',
        'Investigar: hipÃ³xia, sepse, tireotoxicose, digoxina',
      ],
    ),

    // â”€â”€ QRS ESTREITO IRREGULAR â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'narrow_irregular': const AlgorithmNode(
      id: 'narrow_irregular',
      type: NodeType.question,
      title: 'Taquicardia Irregular â€” Tipo',
      options: [
        AlgorithmOption(
          label: 'ðŸ”µ FibrilaÃ§Ã£o Atrial (FA)',
          sublabel: 'Linha de base irregular, sem ondas P',
          nextNodeId: 'afib_strategy',
        ),
        AlgorithmOption(
          label: 'ðŸ”µ Flutter Atrial',
          sublabel: 'Ondas F em "dentes de serra"',
          nextNodeId: 'flutter_strategy',
        ),
        AlgorithmOption(
          label: 'âš¡ PrÃ©-excitaÃ§Ã£o (WPW + FA)',
          sublabel: 'QRS irregular + delta waves',
          nextNodeId: 'wpw_fa',
        ),
      ],
    ),

    'afib_strategy': const AlgorithmNode(
      id: 'afib_strategy',
      type: NodeType.question,
      title: 'FA â€” EstratÃ©gia de Tratamento',
      subtitle: 'DuraÃ§Ã£o da FA Ã© crucial para decisÃ£o',
      ecgImageAsset: 'afib',
      ecgTitle: 'FibrilaÃ§Ã£o Atrial (FA)',
      ecgFindings: [
        'Linha de base irregularmente irregular (ondas fibrilatÃ³rias)',
        'AusÃªncia de ondas P distintas',
        'Intervalos RR completamente irregulares',
        'QRS estreito (< 120ms) salvo aberrÃ¢ncia ou WPW',
        'FC ventricular variÃ¡vel (100â€“170 bpm em FA nÃ£o controlada)',
      ],
      options: [
        AlgorithmOption(
          label: 'â±ï¸ FA < 48h â€” Controle de ritmo',
          sublabel: 'CardioversÃ£o possÃ­vel sem anticoagulaÃ§Ã£o prÃ©via',
          nextNodeId: 'afib_rhythm_control',
        ),
        AlgorithmOption(
          label: 'ðŸ“… FA > 48h ou duraÃ§Ã£o desconhecida',
          sublabel: 'Controle de frequÃªncia + anticoagulaÃ§Ã£o',
          nextNodeId: 'afib_rate_control',
        ),
      ],
    ),

    'afib_rhythm_control': const AlgorithmNode(
      id: 'afib_rhythm_control',
      type: NodeType.action,
      title: 'FA < 48h â€” Controle de Ritmo',
      alertLevel: 'warning',
      bullets: [
        'CardioversÃ£o elÃ©trica: â‰¥ 200 J bifÃ¡sico (AHA 2025)',
        'ou CardioversÃ£o quÃ­mica:',
        '   â€¢ Propafenona 450â€“600 mg VO (pill-in-pocket)',
        '   â€¢ Ibutilide 1 mg IV em 10 min (monitorizaÃ§Ã£o)',
        '   â€¢ Amiodarona 150 mg IV em 10 min',
        'AnticoagulaÃ§Ã£o antes/durante/apÃ³s cardioversÃ£o',
        'ETE se cardioversÃ£o eletiva sem anticoagulaÃ§Ã£o prÃ©via',
      ],
    ),

    'afib_rate_control': const AlgorithmNode(
      id: 'afib_rate_control',
      type: NodeType.action,
      title: 'FA > 48h â€” Controle de FrequÃªncia',
      alertLevel: 'info',
      bullets: [
        'Meta: FC < 110 bpm em repouso',
        'Betabloqueador: Metoprolol 5 mg IV (atÃ© 3 doses)',
        'ou BCC: Diltiazem 0,25 mg/kg IV em 2 min',
        'ou Digoxina (menos eficaz, Ãºtil em IC)',
        'ANTICOAGULAÃ‡ÃƒO obrigatÃ³ria â‰¥ 3 semanas antes da cardioversÃ£o',
        'ou ETE para excluir trombo',
        'Avaliar CHADSâ‚‚-VASc para anticoagulaÃ§Ã£o crÃ´nica',
      ],
    ),

    'flutter_strategy': const AlgorithmNode(
      id: 'flutter_strategy',
      type: NodeType.action,
      title: 'Flutter Atrial â€” Conduta',
      alertLevel: 'info',
      bullets: [
        'CardioversÃ£o elÃ©trica: 50â€“100 J (mais fÃ¡cil que FA)',
        'ou Controle de frequÃªncia: Betabloqueador / BCC',
        'Mesmas regras de anticoagulaÃ§Ã£o que FA',
        'AblaÃ§Ã£o por cateter: tratamento definitivo',
      ],
    ),

    'wpw_fa': const AlgorithmNode(
      id: 'wpw_fa',
      type: NodeType.action,
      title: 'âš ï¸ WPW + FA â€” SituaÃ§Ã£o de Risco!',
      alertLevel: 'danger',
      bullets: [
        'EVITAR: Adenosina, Betabloqueadores, BCC, Digoxina',
        'Podem acelerar conduÃ§Ã£o pela via acessÃ³ria â†’ FV',
        'SE INSTÃVEL: CardioversÃ£o elÃ©trica IMEDIATA',
        'SE ESTÃVEL: Procainamida 15â€“17 mg/kg IV em 30 min',
        'ou Ibutilide (alternativa)',
        'Consulta urgente a eletrofisiologista',
        'AblaÃ§Ã£o da via acessÃ³ria: tratamento definitivo',
      ],
    ),

    // â”€â”€ QRS LARGO â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    'wide_regular': const AlgorithmNode(
      id: 'wide_regular',
      type: NodeType.question,
      title: 'QRS Largo â€” Taquicardia Ventricular?',
      subtitle: 'Tratar como TV atÃ© provar o contrÃ¡rio',
      options: [
        AlgorithmOption(
          label: 'ðŸ”´ TV MonomÃ³rfica â€” EstÃ¡vel',
          sublabel: 'QRS uniformes, morfologia constante',
          nextNodeId: 'vt_stable',
        ),
        AlgorithmOption(
          label: 'ðŸ”´ TV PolimÃ³rfica (Torsades)',
          sublabel: 'QRS variÃ¡vel, QTc longo',
          nextNodeId: 'torsades',
        ),
        AlgorithmOption(
          label: 'ðŸ”µ TSV com AberrÃ¢ncia',
          sublabel: 'CritÃ©rios de Brugada/LBBB tÃ­pico',
          nextNodeId: 'svt_aberrancy',
        ),
      ],
    ),

    'vt_stable': const AlgorithmNode(
      id: 'vt_stable',
      type: NodeType.action,
      title: 'TV MonomÃ³rfica EstÃ¡vel â€” CardioversÃ£o ou Droga',
      alertLevel: 'warning',
      ecgImageAsset: 'vt',
      ecgTitle: 'TV MonomÃ³rfica â€” QRS Largo Regular',
      ecgFindings: [
        'QRS LARGO â‰¥ 120 ms com morfologia consistente',
        'FC 100â€“250 bpm, ritmo regular',
        'DissociaÃ§Ã£o AV: ondas P independentes do QRS',
        'Batimentos de fusÃ£o e captura (patognomÃ´nicos de TV)',
        'RBBB ou LBBB atÃ­picos â†’ favorecem TV',
        'Eixo extremo no plano frontal â†’ forte sinal de TV',
      ],
      bullets: [
        'CardioversÃ£o sincronizada: 100 J (1Âª escolha)',
        'ou AntiarrÃ­tmico:',
        '   â€¢ Amiodarona 150 mg IV em 10 min',
        '   â€¢ Procainamida 15â€“17 mg/kg em 30â€“60 min',
        '   â€¢ LidocaÃ­na 1â€“1,5 mg/kg IV push',
        'Solicitar ecocardiograma e avaliaÃ§Ã£o de FE',
        'Se FE reduzida: Amiodarona preferencial',
      ],
      nextNodeId: 'amio_vt',
    ),

    'amio_vt': const AlgorithmNode(
      id: 'amio_vt',
      type: NodeType.drug,
      title: 'Amiodarona â€” TV EstÃ¡vel',
      drug: DrugInfo(
        name: 'Amiodarona',
        dose: '150 mg IV em 10 min',
        route: 'IV lento',
        frequency: 'ManutenÃ§Ã£o: 1 mg/min por 6h, depois 0,5 mg/min por 18h',
        maxDose: 'MÃ¡x 2,2 g/24h',
        notes: 'Monitorizar PA (hipotensÃ£o) e QTc. Preferir em disfunÃ§Ã£o ventricular.',
        color: '#A855F7',
      ),
    ),

    'torsades': const AlgorithmNode(
      id: 'torsades',
      type: NodeType.action,
      title: 'Torsades de Pointes',
      alertLevel: 'danger',
      ecgImageAsset: 'torsades',
      ecgTitle: 'Torsades de Pointes â€” TV PolimÃ³rfica',
      ecgFindings: [
        'QRS largo com amplitude que OSCILA em padrÃ£o sinusoidal',
        'Eixo elÃ©trico vai rodando progressivamente ("torsion")',
        'FC 200â€“250 bpm, polimÃ³rfico (complexos mudam de forma)',
        'Iniciada por pausa + extrassÃ­stole (pausa-dependente)',
        'QTc prolongado no ritmo sinusal precede o episÃ³dio',
        'Confundir com FV â€” mas tem padrÃ£o tÃ­pico de torsÃ£o',
      ],
      bullets: [
        'ðŸ’Š Sulfato de MagnÃ©sio 2 g IV em 1â€“2 min â€” AGORA',
        'Corrigir hipocalemia (Kâº > 4,5 mEq/L)',
        'Suspender TODOS os medicamentos que prolongam QTc',
        'Overdrive pacing se recorrente',
        'Isoproterenol se FC muito baixa',
        'Se instÃ¡vel: desfibrilaÃ§Ã£o (nÃ£o sincronizado)',
      ],
      nextNodeId: 'magnesium_drug',
    ),

    'magnesium_drug': const AlgorithmNode(
      id: 'magnesium_drug',
      type: NodeType.drug,
      title: 'Sulfato de MagnÃ©sio â€” Torsades',
      drug: DrugInfo(
        name: 'Sulfato de MagnÃ©sio',
        dose: '2 g (4 mL MgSOâ‚„ 50%)',
        route: 'IV em 1â€“2 min',
        frequency: 'Repetir 2g em 10 min se necessÃ¡rio; depois manutenÃ§Ã£o 1-2 g/h',
        notes: 'Monitorizar reflexos patelares (sinal de toxicidade). AntÃ­doto: Gluconato de CÃ¡lcio.',
        color: '#22C55E',
      ),
    ),

    'svt_aberrancy': const AlgorithmNode(
      id: 'svt_aberrancy',
      type: NodeType.action,
      title: 'TSV com AberrÃ¢ncia â€” Conduta',
      alertLevel: 'info',
      bullets: [
        'Se dÃºvida entre TV e TSV â€” tratar como TV',
        'Adenosina 6 mg IV pode ser diagnÃ³stica/terapÃªutica',
        '   (Se TSV+BRE: converte. Se TV: sem efeito ou piora)',
        'CardioversÃ£o sincronizada se deteriorar',
        'Evitar Verapamil em QRS largo (perigoso em TV)',
      ],
    ),
  },
);

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  ALGORITMO PÃ“S-PCR â€” AHA 2025
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

final postRoscAlgorithm = Algorithm(
  id: 'post_rosc',
  title: 'Cuidados PÃ³s-PCR (ROSC)',
  subtitle: 'OtimizaÃ§Ã£o pÃ³s-ressuscitaÃ§Ã£o Â· AHA 2025',
  iconEmoji: 'ðŸŸ¢',
  color: '#22C55E',
  startNodeId: 'post_rosc_start',
  nodes: {
    'post_rosc_start': const AlgorithmNode(
      id: 'post_rosc_start',
      type: NodeType.info,
      title: 'ROSC Confirmado â€” Iniciar Protocolo PÃ³s-PCR',
      alertLevel: 'success',
      subtitle: 'Tratar pÃ³s-PCR como continuaÃ§Ã£o da ressuscitaÃ§Ã£o',
      bullets: [
        'âœ… Pulso central palpÃ¡vel confirmado',
        'MonitorizaÃ§Ã£o contÃ­nua: ECG, SpOâ‚‚, capnografia, PA invasiva',
        'Checar glicemia, gasometria arterial, eletrÃ³litos',
        'AvanÃ§ar para avaliaÃ§Ã£o de via aÃ©rea',
      ],
      nextNodeId: 'post_airway',
    ),

    'post_airway': const AlgorithmNode(
      id: 'post_airway',
      type: NodeType.question,
      title: 'Manejo da Via AÃ©rea',
      subtitle: 'Metas ventilatÃ³rias pÃ³s-PCR',
      options: [
        AlgorithmOption(
          label: 'ðŸ« Paciente intubado â€” ajustar ventilador',
          nextNodeId: 'ventilator_settings',
        ),
        AlgorithmOption(
          label: 'ðŸ˜® Paciente acordado, ventilando',
          nextNodeId: 'conscious_post_rosc',
        ),
      ],
    ),

    'ventilator_settings': const AlgorithmNode(
      id: 'ventilator_settings',
      type: NodeType.info,
      title: 'ðŸ« ParÃ¢metros VentilatÃ³rios Alvo',
      alertLevel: 'info',
      bullets: [
        'ðŸ©¸ SpOâ‚‚: 94â€“98% (evitar hiperoxia)',
        'ðŸ’¨ FiOâ‚‚: titular para SpOâ‚‚ alvo (comeÃ§ar 100%, reduzir)',
        'ðŸ“Š ETCOâ‚‚: 35â€“45 mmHg',
        'ðŸŒ¬ï¸ PaCOâ‚‚: 35â€“45 mmHg (normocapnia)',
        'ðŸ“ Volume corrente: 6â€“8 mL/kg peso ideal',
        'âš ï¸ EVITAR hipocapnia (vasoconstricÃ§Ã£o cerebral)',
      ],
      nextNodeId: 'post_hemodynamics',
    ),

    'conscious_post_rosc': const AlgorithmNode(
      id: 'conscious_post_rosc',
      type: NodeType.info,
      title: 'Paciente Consciente PÃ³s-ROSC',
      alertLevel: 'success',
      bullets: [
        'Oâ‚‚ suplementar: manter SpOâ‚‚ 94â€“98%',
        'MonitorizaÃ§Ã£o contÃ­nua',
        'Avaliar nÃ­vel de consciÃªncia (Escala de Glasgow)',
        'ECG 12 derivaÃ§Ãµes â€” pesquisar IAM',
        'AvanÃ§ar para avaliaÃ§Ã£o hemodinÃ¢mica',
      ],
      nextNodeId: 'post_hemodynamics',
    ),

    'post_hemodynamics': const AlgorithmNode(
      id: 'post_hemodynamics',
      type: NodeType.info,
      title: 'ðŸ’‰ Metas HemodinÃ¢micas',
      alertLevel: 'warning',
      bullets: [
        'ðŸŽ¯ PAM â‰¥ 65â€“70 mmHg',
        'ðŸŽ¯ PAS â‰¥ 90 mmHg',
        'ðŸ’Š Norepinefrina: vasopressor de 1Âª escolha',
        'ðŸ’Š Dobutamina: se disfunÃ§Ã£o miocÃ¡rdica + hipotensÃ£o',
        'ðŸ’§ ExpansÃ£o volÃªmica criteriosa (avaliar euvolemia)',
        'ðŸ“Š Monitorizar dÃ©bito cardÃ­aco se disponÃ­vel',
      ],
      nextNodeId: 'norepi_infusion',
    ),

    'norepi_infusion': const AlgorithmNode(
      id: 'norepi_infusion',
      type: NodeType.drug,
      title: 'Norepinefrina â€” Suporte HemodinÃ¢mico PÃ³s-PCR',
      drug: DrugInfo(
        name: 'Norepinefrina',
        dose: '0,1â€“1 mcg/kg/min',
        route: 'InfusÃ£o IV contÃ­nua (acesso central preferencial)',
        notes: 'Titular para PAM â‰¥ 65 mmHg. MonitorizaÃ§Ã£o invasiva recomendada.',
        color: '#EF4444',
      ),
      nextNodeId: 'post_ecg',
    ),

    'post_ecg': const AlgorithmNode(
      id: 'post_ecg',
      type: NodeType.question,
      title: 'ECG PÃ³s-ROSC â€” ElevaÃ§Ã£o de ST?',
      subtitle: 'Realizar ECG 12 derivaÃ§Ãµes IMEDIATAMENTE',
      options: [
        AlgorithmOption(
          label: 'ðŸ”´ IAMCSST â€” ElevaÃ§Ã£o de ST confirmada',
          nextNodeId: 'stemi_post_rosc',
        ),
        AlgorithmOption(
          label: 'ðŸŸ¡ IAMSST / ECG nÃ£o diagnÃ³stico',
          nextNodeId: 'nstemi_post_rosc',
        ),
        AlgorithmOption(
          label: 'ðŸŸ¢ ECG normal / LBBB prÃ©vio',
          nextNodeId: 'ttm_decision',
        ),
      ],
    ),

    'stemi_post_rosc': const AlgorithmNode(
      id: 'stemi_post_rosc',
      type: NodeType.action,
      title: 'ðŸ”´ IAMCSST + ROSC â€” ICP PrimÃ¡ria',
      alertLevel: 'danger',
      bullets: [
        'Ativar hemodinÃ¢mica IMEDIATAMENTE',
        'ICP primÃ¡ria recomendada mesmo em pacientes comatosos',
        'Meta: D2B (porta-balÃ£o) â‰¤ 90 min',
        'AntiagregaÃ§Ã£o: AAS 300 mg + Ticagrelor 180 mg (VO/SNG)',
        'AnticoagulaÃ§Ã£o: Heparina 70â€“100 UI/kg IV',
        'Controle de temperatura alvo apÃ³s ICP',
      ],
      nextNodeId: 'ttm_decision',
    ),

    'nstemi_post_rosc': const AlgorithmNode(
      id: 'nstemi_post_rosc',
      type: NodeType.action,
      title: 'ðŸŸ¡ IAMSST PÃ³s-PCR â€” Conduta',
      alertLevel: 'warning',
      bullets: [
        'Coronariografia precoce (< 24h) se causa cardÃ­aca provÃ¡vel',
        'AAS 300 mg VO/SNG',
        'AnticoagulaÃ§Ã£o com Heparina',
        'DecisÃ£o individualizada com cardiologia',
        'Ecocardiograma urgente: FE, motilidade, derrame',
      ],
      nextNodeId: 'ttm_decision',
    ),

    'ttm_decision': const AlgorithmNode(
      id: 'ttm_decision',
      type: NodeType.question,
      title: 'Controle de Temperatura Alvo (TTM)',
      subtitle: 'Para pacientes comatosos apÃ³s PCR (GCS < 8)',
      options: [
        AlgorithmOption(
          label: 'ðŸ˜´ Comatoso â€” Iniciar TTM',
          sublabel: 'Glasgow < 8 apÃ³s ROSC',
          nextNodeId: 'ttm_protocol',
        ),
        AlgorithmOption(
          label: 'ðŸ˜Š Acordado / responsivo',
          nextNodeId: 'post_rosc_monitoring',
        ),
      ],
    ),

    'ttm_protocol': const AlgorithmNode(
      id: 'ttm_protocol',
      type: NodeType.info,
      title: 'â„ï¸ Controle de Temperatura Alvo (TTM)',
      alertLevel: 'info',
      bullets: [
        'Meta: temperatura 32â€“36Â°C por â‰¥ 24 horas',
        'Evitar FEBRE ativamente (> 37,7Â°C prejudicial)',
        'MÃ©todos de resfriamento:',
        '   â€¢ Soro fisiolÃ³gico gelado IV (4Â°C, 30 mL/kg)',
        '   â€¢ Bolsas de gelo nas axilas/virilhas',
        '   â€¢ Cateter endovascular (Artic Sun, Thermogard)',
        '   â€¢ Cobertor refrescante',
        'Monitorizar: temperatura central (vesical/esofÃ¡gica)',
        'SedaÃ§Ã£o + bloqueio neuromuscular para evitar tremores',
      ],
      nextNodeId: 'post_rosc_monitoring',
    ),

    'post_rosc_monitoring': const AlgorithmNode(
      id: 'post_rosc_monitoring',
      type: NodeType.info,
      title: 'ðŸ“Š MonitorizaÃ§Ã£o ContÃ­nua UTI',
      alertLevel: 'info',
      bullets: [
        'ðŸ§  EEG contÃ­nuo: excluir crises subclÃ­nicas',
        'ðŸ©¸ Glicemia: alvo 140â€“180 mg/dL (evitar hipoglicemia)',
        'ðŸ’Š Profilaxia convulsÃµes: nÃ£o routineiramente',
        'ðŸ«€ Ecocardiograma: FE, avaliar disfunÃ§Ã£o miocÃ¡rdica',
        'ðŸ§ª Biomarcadores: troponina, lactato serial',
        'ðŸ©» TC crÃ¢nio: excluir AVC isquÃªmico/hemorrÃ¡gico',
      ],
      nextNodeId: 'neuroprognostication',
    ),

    'neuroprognostication': const AlgorithmNode(
      id: 'neuroprognostication',
      type: NodeType.info,
      title: 'ðŸ§  NeuroprognosticaÃ§Ã£o',
      alertLevel: 'warning',
      bullets: [
        'NÃƒO prognosticar precocemente (< 72h apÃ³s ROSC)',
        'Aguardar: efeito de sedativos, TTM, temperatura normalizando',
        'Exames multimodais apÃ³s 72â€“120h:',
        '   â€¢ Reflexos de tronco (pupilas, cÃ³rnea)',
        '   â€¢ SSEP: ausÃªncia bilateral N20',
        '   â€¢ EEG: padrÃ£o supressÃ£o-surto, status epilÃ©ptico',
        '   â€¢ RM crÃ¢nio: lesÃ£o anÃ³xica difusa',
        '   â€¢ NSE sÃ©rica > 60 mcg/L (prognÃ³stico desfavorÃ¡vel)',
        'DecisÃ£o compartilhada com famÃ­lia',
      ],
    ),
  },
);

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  ALGORITMO SCA â€” IAMCSST (AHA 2025)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

final scaAlgorithm = Algorithm(
  id: 'sca',
  title: 'SCA â€” IAM com Supra de ST',
  subtitle: 'IAMCSST Â· ReperfusÃ£o Urgente',
  iconEmoji: 'â¤ï¸â€ðŸ”¥',
  color: '#F97316',
  startNodeId: 'sca_start',
  nodes: {
    'sca_start': const AlgorithmNode(
      id: 'sca_start',
      type: NodeType.question,
      title: 'Dor Precordial / Equivalente IsquÃªmico',
      subtitle: 'Suspeita de SÃ­ndrome Coronariana Aguda',
      bullets: [
        'Dor precordial, peso, pressÃ£o',
        'IrradiaÃ§Ã£o para braÃ§o E, mandÃ­bula, dorso',
        'Dor em repouso > 20 min',
        'Equivalentes: dispneia, epigastralgia, sÃ­ncope (idosos/diabÃ©ticos)',
      ],
      options: [
        AlgorithmOption(
          label: 'ðŸ”´ Suspeita alta â€” obter ECG imediato',
          nextNodeId: 'ecg_sca',
        ),
        AlgorithmOption(
          label: 'ðŸŸ¡ Baixa probabilidade',
          nextNodeId: 'sca_low_risk',
        ),
      ],
    ),

    'ecg_sca': const AlgorithmNode(
      id: 'ecg_sca',
      type: NodeType.action,
      title: 'âš¡ ECG em 10 minutos â€” URGENTE',
      alertLevel: 'danger',
      bullets: [
        'ECG 12 derivaÃ§Ãµes nos primeiros 10 min da chegada',
        'Leitura por mÃ©dico experiente',
        'Repetir em 15â€“30 min se o primeiro nÃ£o diagnÃ³stico',
        'DerivaÃ§Ãµes adicionais: V3R, V4R (IAM inferior/VD)',
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
          label: 'ðŸ”´ Supradesnivelamento de ST â‰¥ 1mm em â‰¥ 2 derivaÃ§Ãµes contÃ­guas',
          sublabel: 'ou BRE novo / presumivelmente novo',
          nextNodeId: 'stemi_confirmed',
        ),
        AlgorithmOption(
          label: 'ðŸŸ¡ Infradesnivelamento de ST ou inversÃ£o de T',
          nextNodeId: 'nstemi_path',
        ),
        AlgorithmOption(
          label: 'ðŸŸ¢ ECG normal ou inespecÃ­fico',
          nextNodeId: 'sca_low_risk',
        ),
      ],
    ),

    'stemi_confirmed': const AlgorithmNode(
      id: 'stemi_confirmed',
      type: NodeType.action,
      title: 'ðŸ”´ IAMCSST Confirmado â€” ReperfusÃ£o URGENTE',
      alertLevel: 'danger',
      bullets: [
        'â±ï¸ TEMPO Ã‰ MÃšSCULO â€” iniciar tratamento EM PARALELO',
        'AAS 300 mg VO (mascar) â€” AGORA',
        'Ticagrelor 180 mg VO (preferencial) ou Clopidogrel 600 mg',
        'Heparina nÃ£o fracionada: bÃ³lus 70â€“100 UI/kg IV',
        'Oâ‚‚ apenas se SpOâ‚‚ < 90%',
        'Morfina 2â€“4 mg IV se dor intensa (usar com cautela)',
        'Nitroglicerina SL se PA > 90 mmHg (CI: uso de PDE5i)',
      ],
      nextNodeId: 'reperfusion_strategy',
    ),

    'reperfusion_strategy': const AlgorithmNode(
      id: 'reperfusion_strategy',
      type: NodeType.question,
      title: 'EstratÃ©gia de ReperfusÃ£o',
      subtitle: 'Tempo do inÃ­cio dos sintomas + disponibilidade de hemodinÃ¢mica',
      options: [
        AlgorithmOption(
          label: 'ðŸ¥ ICP disponÃ­vel â€” D2B < 90 min possÃ­vel',
          sublabel: 'ICP PrimÃ¡ria (1Âª escolha)',
          nextNodeId: 'pci_primary',
        ),
        AlgorithmOption(
          label: 'â±ï¸ ICP nÃ£o disponÃ­vel ou D2B > 120 min',
          sublabel: 'TrombolÃ­tico + transfer',
          nextNodeId: 'thrombolysis_stemi',
        ),
      ],
    ),

    'pci_primary': const AlgorithmNode(
      id: 'pci_primary',
      type: NodeType.action,
      title: 'ðŸ¥ ICP PrimÃ¡ria',
      alertLevel: 'danger',
      bullets: [
        'Ativar laboratÃ³rio de hemodinÃ¢mica IMEDIATAMENTE',
        'Meta Porta-BalÃ£o (D2B): â‰¤ 90 min',
        'Acesso radial preferencial (menos sangramentos)',
        'Considerar Prasugrel 60 mg (se nÃ£o em uso de ACO)',
        'Inibidor GPIIb/IIIa: Tirofiban/Abciximab (selecionado)',
        'Ecocardiograma pÃ³s-ICP para avaliar FE',
        'UTI coronariana apÃ³s procedimento',
      ],
    ),

    'thrombolysis_stemi': const AlgorithmNode(
      id: 'thrombolysis_stemi',
      type: NodeType.question,
      title: 'TrombÃ³lise â€” Verificar ContraindicaÃ§Ãµes',
      subtitle: 'OBRIGATÃ“RIO antes de administrar',
      options: [
        AlgorithmOption(
          label: 'âœ… Sem contraindicaÃ§Ãµes absolutas â€” administrar',
          nextNodeId: 'tenecteplase_drug',
        ),
        AlgorithmOption(
          label: 'âŒ ContraindicaÃ§Ã£o absoluta presente',
          nextNodeId: 'thrombolysis_ci',
        ),
      ],
    ),

    'thrombolysis_ci': const AlgorithmNode(
      id: 'thrombolysis_ci',
      type: NodeType.info,
      title: 'âš ï¸ ContraindicaÃ§Ãµes Absolutas Ã  TrombÃ³lise',
      alertLevel: 'danger',
      bullets: [
        'AVC hemorrÃ¡gico prÃ©vio (qualquer Ã©poca)',
        'AVC isquÃªmico < 3 meses',
        'Neoplasia ou lesÃ£o vascular intracraniana',
        'Traumatismo cranioencefÃ¡lico grave < 3 meses',
        'DissecÃ§Ã£o aÃ³rtica',
        'Sangramento interno ativo (exceto menstruaÃ§Ã£o)',
        'Cirurgia/procedimento maior < 3 semanas',
        'â†’ Se todas presentes: transferÃªncia urgente para ICP',
      ],
    ),

    'tenecteplase_drug': const AlgorithmNode(
      id: 'tenecteplase_drug',
      type: NodeType.drug,
      title: 'Tenecteplase (TNK) â€” IAMCSST',
      drug: DrugInfo(
        name: 'Tenecteplase (TNK)',
        dose: 'Baseado no peso:\n< 60 kg: 30 mg\n60â€“70 kg: 35 mg\n70â€“80 kg: 40 mg\n80â€“90 kg: 45 mg\n> 90 kg: 50 mg',
        route: 'IV bolus em 5â€“10 seg',
        notes: 'Administrar junto com Heparina. Transferir para hemodinÃ¢mica apÃ³s (ICP de resgate se falha). Monitorizar sinais de reperfusÃ£o: alÃ­vio da dor, supradesnivelamento de ST reduz > 50%, reperfusion arrhythmias.',
        color: '#F97316',
      ),
      nextNodeId: 'post_thrombolysis',
    ),

    'post_thrombolysis': const AlgorithmNode(
      id: 'post_thrombolysis',
      type: NodeType.info,
      title: 'PÃ³s-TrombÃ³lise â€” MonitorizaÃ§Ã£o',
      alertLevel: 'warning',
      bullets: [
        'Transferir para centro com ICP em atÃ© 24h',
        'ICP de resgate se: sem sinais de reperfusÃ£o em 90 min',
        'Monitorizar: hemorragias, PA, ritmo cardÃ­aco',
        'Heparina: infusÃ£o contÃ­nua por 48h',
        'ECG a cada 90 min apÃ³s trombÃ³lise',
        'CritÃ©rios de reperfusÃ£o: â†“ST > 50% + alÃ­vio da dor',
      ],
    ),

    'nstemi_path': const AlgorithmNode(
      id: 'nstemi_path',
      type: NodeType.action,
      title: 'IAMSST / Angina InstÃ¡vel â€” Conduta',
      alertLevel: 'warning',
      bullets: [
        'AAS 300 mg VO',
        'Ticagrelor 180 mg VO (preferencial)',
        'AnticoagulaÃ§Ã£o: Enoxaparina 1 mg/kg SC 12/12h',
        'Betabloqueador oral (se sem CI)',
        'Nitrato SL / IV se dor persistente',
        'Estatina de alta intensidade: Atorvastatina 80 mg',
        'EstratificaÃ§Ã£o de risco: escore GRACE/TIMI',
        'Coronariografia: timing por risco (precoce < 24h se alto risco)',
      ],
    ),

    'sca_low_risk': const AlgorithmNode(
      id: 'sca_low_risk',
      type: NodeType.info,
      title: 'Baixo Risco â€” AvaliaÃ§Ã£o Seriada',
      alertLevel: 'info',
      bullets: [
        'Troponina ultrassensÃ­vel: coleta 0h e 1â€“3h',
        'Escore HEART / EDACS para estratificaÃ§Ã£o',
        'ECG serial a cada 30 min nas primeiras 2h',
        'Se troponina negativa serial + ECG normal + baixo risco: alta com seguimento',
        'Se qualquer positivo: internaÃ§Ã£o + estratificaÃ§Ã£o',
      ],
    ),
  },
);

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  REGISTRO DE TODOS OS ALGORITMOS
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

final allAlgorithms = <String, Algorithm>{
  cardiacArrestAlgorithm.id: cardiacArrestAlgorithm,
  bradycardiaAlgorithm.id: bradycardiaAlgorithm,
  tachycardiaAlgorithm.id: tachycardiaAlgorithm,
  postRoscAlgorithm.id: postRoscAlgorithm,
  scaAlgorithm.id: scaAlgorithm,
};


