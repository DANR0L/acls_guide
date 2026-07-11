import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

class CprLogEvent {
  final String timeText;
  final DateTime realTime;
  final String message;
  final String colorHex;
  final bool isAlert;

  CprLogEvent({
    required this.timeText,
    required this.realTime,
    required this.message,
    required this.colorHex,
    this.isAlert = false,
  });
}

class CprDynamicState {
  final bool isRunning;
  final DateTime? startTime;
  final int elapsedSeconds;
  final int cycleSecondsRemaining;
  // epiElapsedSeconds: 0 = not given yet.
  // 1-180 = cooldown phase (button disabled, shows countdown 3:00→00:00).
  // 181-300 = overdue phase (button blinks, shows elapsed 3:01→5:00).
  final int epiElapsedSeconds;

  final int shockCount;
  final int epiCount;
  final int amioLidoCount;
  final bool? isShockableRhythm;
  final int totalCprSeconds;
  final List<CprLogEvent> logs;
  final bool isRosc;
  final bool isTor;
  final String? tachycardiaRhythm;

  CprDynamicState({
    this.isRunning = false,
    this.startTime,
    this.elapsedSeconds = 0,
    this.cycleSecondsRemaining = 120,
    this.epiElapsedSeconds = 0,
    this.shockCount = 0,
    this.epiCount = 0,
    this.amioLidoCount = 0,
    this.isShockableRhythm,
    this.totalCprSeconds = 0,
    this.logs = const [],
    this.isRosc = false,
    this.isTor = false,
    this.tachycardiaRhythm,
  });

  CprDynamicState copyWith({
    bool? isRunning,
    DateTime? startTime,
    int? elapsedSeconds,
    int? cycleSecondsRemaining,
    int? epiElapsedSeconds,
    int? shockCount,
    int? epiCount,
    int? amioLidoCount,
    bool? isShockableRhythm,
    int? totalCprSeconds,
    bool clearShockableRhythm = false,
    List<CprLogEvent>? logs,
    bool? isRosc,
    bool? isTor,
    String? tachycardiaRhythm,
  }) {
    return CprDynamicState(
      isRunning: isRunning ?? this.isRunning,
      startTime: startTime ?? this.startTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      cycleSecondsRemaining: cycleSecondsRemaining ?? this.cycleSecondsRemaining,
      epiElapsedSeconds: epiElapsedSeconds ?? this.epiElapsedSeconds,
      shockCount: shockCount ?? this.shockCount,
      epiCount: epiCount ?? this.epiCount,
      amioLidoCount: amioLidoCount ?? this.amioLidoCount,
      isShockableRhythm: clearShockableRhythm ? null : (isShockableRhythm ?? this.isShockableRhythm),
      totalCprSeconds: totalCprSeconds ?? this.totalCprSeconds,
      logs: logs ?? this.logs,
      isRosc: isRosc ?? this.isRosc,
      isTor: isTor ?? this.isTor,
      tachycardiaRhythm: tachycardiaRhythm ?? this.tachycardiaRhythm,
    );
  }

  /// True when epi is available to give (not in cooldown)
  bool get epiAvailable => epiElapsedSeconds == 0 || epiElapsedSeconds > 180;

  bool get isEpiDisabled {
    if (isShockableRhythm == true) return true; // Preparando choque

    // AHA: Epi apenas APÓS o 2º choque em ritmos chocáveis (VF/pVT).
    // Se mudou para Assistolia/PEA (isShockableRhythm == false), libera imediatamente.
    if (isShockableRhythm != false && shockCount == 1 && epiCount == 0) return true; 

    // Bloqueia durante o "cooldown" de 3 minutos para não ser administrada várias vezes
    if (!epiAvailable) return true;

    return false;
  }

  bool get isAmioDisabled {
    if (isShockableRhythm == true) return true; // Preparando choque
    if (isShockableRhythm == false) return true; // Assistolia/AESP não usa Amio
    if (amioLidoCount >= 2) return true; // Doses máximas já dadas
    if (shockCount < 3) return true; // AHA: 1ª dose apenas APÓS o 3º choque
    if (amioLidoCount == 1 && shockCount < 5) return true; // AHA: 2ª dose apenas APÓS o 5º choque
    return false;
  }

  /// Label to display on the epi button
  String get epiButtonLabel {
    if (epiElapsedSeconds >= 1 && epiElapsedSeconds <= 180) {
      // Fase 1 — Contagem decrescente: 03:00 → 00:01
      // elapsed=1 → 181-1=180s → "03:00"
      // elapsed=180 → 181-180=1s → "00:01"
      return 'Epi (${formatTime(181 - epiElapsedSeconds)})';
    } else if (epiElapsedSeconds > 180) {
      // Fase 2 — Após zerar: conta de 03:00 → 05:00
      // elapsed=181 → 181-181=0+180=180s → "03:00"
      // elapsed=182 → "03:01" ... elapsed=301 → "05:00"
      final overdue = epiElapsedSeconds - 181; // 0, 1, 2 ...
      final display = overdue > 120 ? 120 : overdue; // cap at 2min extra = 5:00 total
      return 'Epi ⚠️ ${formatTime(180 + display)}';
    }
    return '💉 Epinefrina';
  }

  String get suggestion {
    if (!isRunning && !isRosc && !isTor && tachycardiaRhythm == null) return 'Aperte INICIAR ao confirmar PCR.';
    
    if (tachycardiaRhythm != null) {
      switch (tachycardiaRhythm) {
        case 'TSV':
          return '📌 TSV ESTÁVEL: 1) Manobra Vagal (Valsalva/carotídea). '
              '2) Adenosina 6mg IV em acesso proximal + flush 20mL rápido. '
              '3) Se falhar: Adenosina 12mg IV (repetir 12mg mais 1x se necessário). '
              '4) Alternativas: Metoprolol 2,5-5mg IV lento (até 3x) ou Diltiazem 0,25mg/kg IV lento. '
              '⚡ TSV INSTÁVEL: Cardioversão Sincronizada 50-100 J bifásico.';
        case 'FA / Flutter':
          return '📌 FA/FLUTTER ESTÁVEL: Controle de frequência: Metoprolol 2,5-5mg IV (até 3x) ou '
              'Diltiazem 0,25mg/kg IV lento (manutenção: 5-15mg/h). '
              'Alternativa: Amiodarona 150mg IV em 10min + 1mg/min por 6h. '
              '⚡ FA INSTÁVEL → Cardioversão Sincronizada 120-200 J bifásico. '
              '⚡ FLUTTER INSTÁVEL → Cardioversão Sincronizada 50-100 J bifásico.';
        case 'Monomórfica':
          return '📌 TV MONOMÓRFICA ESTÁVEL: '
              'Amiodarona 150mg IV em 10min + 1mg/min (6h) + 0,5mg/min (18h). '
              'Alternativa: Procainamida 20-50mg/min IV (máx 17mg/kg). '
              'Ou Sotalol 100mg (1,5mg/kg) IV em 5min. '
              '⚡ TV MONOMÓRFICA INSTÁVEL → Cardioversão Sincronizada 100 J bifásico '
              '(se falhar, aumentar para 200 J).';
        case 'Polimórfica':
          return '🚨 TV POLIMÓRFICA / TORSADES: '
              '⚡ Desfibrilação NÃO-sincronizada imediata: 200 J bifásico (mesma dose da FV). '
              '💉 Sulfato de Magnésio 2g IV em 15min (se Torsades/QT longo). '
              '🛑 Suspender drogas que prolongam QT (amiodarona, sotalol, azitromicina). '
              '💊 Isoproterenol ou Lidocaína 1-1,5mg/kg IV se TV recorrente. '
              'Tratar causa base: hipopotassemia, hipomagnesemia.';
        default:
          return 'Avalie estabilidade hemodinâmica. Se instável: Cardioversão Sincronizada.';
      }
    }
    
    if (isRosc) return 'ROSC Obtido. Inicie cuidados pós-parada (se usou Amiodarona, inicie manutenção).';
    if (isTor) return 'Ressuscitação encerrada. Comunique a família e equipe.';
    if (cycleSecondsRemaining <= 5) return 'Prepare-se para pausar e Checar Ritmo!';
    
    if (isShockableRhythm == null) {
      if (shockCount >= 3 && amioLidoCount == 0) {
        return 'CPR em andamento. Administre Amiodarona 300mg IV AGORA.';
      } else if (shockCount >= 5 && amioLidoCount == 1) {
        return 'CPR em andamento. Administre Amiodarona 150mg IV (2ª dose) AGORA.';
      } else if (shockCount >= 2 && epiAvailable) {
        return 'CPR em andamento. Administre Epinefrina 1mg IV AGORA.';
      } else if (shockCount >= 1) {
        return 'CPR em andamento (2 min). Prepare-se para a próxima checagem.';
      }
      return 'Inicie CPR 30:2. Cheque o ritmo assim que o DEA/Monitor estiver pronto.';
    }

    if (isShockableRhythm == true) {
      // Momento de checagem do ritmo: guia o próximo passo conforme AHA 2020
      if (shockCount == 0) {
        return '⚡ DESFIBRILAR AGORA! 1º Choque (120-200 J bifásico). Retome CPR imediatamente após.';
      }
      if (shockCount == 1) {
        return '⚡ 2º Choque (120-200 J). Após o choque: CPR 2 min + Epinefrina 1mg IV durante a CPR.';
      }
      if (shockCount == 2) {
        return '⚡ 3º Choque (120-200 J). Após: CPR 2 min + Amio 300mg IV + Epi 1mg.';
      }
      if (shockCount == 3) {
        return '⚡ 4º Choque (120-200 J) OU considere DSD/Mudança de Vetor. Após: Amio 150mg IV.';
      }
      return '⚡ Choque ${shockCount + 1} (120-200 J) OU DSD. Continue Epi a cada 3-5 min. Pesquise causas (5H e 5T).';
    } else {
      if (epiAvailable) return '💉 Administre Epinefrina 1mg IV O MAIS RÁPIDO POSSÍVEL. CPR contínua.';
      return 'Continue CPR contínua. Epi a cada 3-5 min. Investigue causas reversíveis (5H e 5T).';
    }
  }

  /// Which buttons should pulse based on current ACLS protocol state
  Set<String> get pulsingButtons {
    if (!isRunning || isRosc || isTor || tachycardiaRhythm != null) return {};
    final pulses = <String>{};

    // Rhythm check buttons pulse when rhythm is unknown OR cycle almost done
    if (isShockableRhythm == null || cycleSecondsRemaining <= 15) {
      pulses.add('rhythm');
    }

    if (isShockableRhythm == true) {
      // 🚨 VF/pVT DETECTED: AHA says SHOCK IMMEDIATELY. NO DRUGS YET!
      // Only the shock button pulses here. Drugs are given DURING CPR AFTER the shock.
      pulses.add('shock');
    } else if (isShockableRhythm == null) {
      // ♻️ CPR PHASE: This is when drugs are administered!
      // Epi: AHA protocol — give during CPR AFTER 2nd shock
      if (shockCount >= 2 && epiAvailable) {
        pulses.add('epi');
      }

      // Amio: AHA protocol — give during CPR AFTER 3rd shock
      if (shockCount >= 3 && amioLidoCount == 0) {
        pulses.add('amio');
      }
      // 2nd dose Amio after 5th shock
      if (shockCount >= 5 && amioLidoCount == 1) {
        pulses.add('amio');
      }
    } else if (isShockableRhythm == false) {
      // ❌ NON-SHOCKABLE (Asystole/PEA): Give Epi ASAP
      if (epiAvailable) {
        pulses.add('epi');
      }
    }

    // Epi overdue (timer > 3 min after last dose) — always pulse
    if (epiElapsedSeconds > 180) {
      pulses.add('epi');
    }

    return pulses;
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class CprDynamicNotifier extends StateNotifier<CprDynamicState> {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  CprDynamicNotifier() : super(CprDynamicState());

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void reset() {
    _timer?.cancel();
    state = CprDynamicState();
  }

  void start() {
    state = CprDynamicState(
      isRunning: true,
      startTime: DateTime.now(),
      logs: [
        _createLog('Parada Iniciada (CPR 30:2)', '#EF4444', isAlert: true),
      ],
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!state.isRunning) return;

    int newCycle = state.cycleSecondsRemaining - 1;
    int newTotal = state.totalCprSeconds + 1;
    // epiElapsedSeconds: 0 = not used yet, 1-301 = counting up (capped at 301 = 5:00)
    int newEpiElapsed = state.epiElapsedSeconds;
    if (newEpiElapsed > 0 && newEpiElapsed <= 301) newEpiElapsed++;

    if (newCycle > 0 && newCycle <= 5) {
      _audioPlayer.play(AssetSource('audio/beep.wav'));
    }

    List<CprLogEvent> newLogs = List.from(state.logs);

    if (newCycle <= 0) {
      newCycle = 120;
      newLogs.insert(0, _createLog('Fim de ciclo (2 min). CHECAR RITMO.', '#F59E0B', isAlert: true));
    }

    // Transition from cooldown → overdue: log alert when elapsed crosses 180s
    if (state.epiElapsedSeconds == 180 && newEpiElapsed == 181) {
      newLogs.insert(0, _createLog('⚠️ Epinefrina disponível! Administrar AGORA.', '#10B981', isAlert: true));
    }

    state = state.copyWith(
      elapsedSeconds: state.elapsedSeconds + 1,
      totalCprSeconds: newTotal,
      cycleSecondsRemaining: newCycle,
      epiElapsedSeconds: newEpiElapsed,
      clearShockableRhythm: newCycle == 120,
      logs: newLogs,
    );
  }

  void registerRhythm(bool isShockable) {
    final type = isShockable ? 'Chocável (VF/pVT)' : 'Não Chocável (Assistolia/AESP)';
    final color = isShockable ? '#EF4444' : '#F59E0B';
    
    state = state.copyWith(
      isShockableRhythm: isShockable,
      cycleSecondsRemaining: 120, // Resume CPR
      logs: [_createLog('Ritmo checado: $type', color), ...state.logs],
    );
  }

  void registerShock() {
    final nextCount = state.shockCount + 1;
    // After shock: reset rhythm to null — team must re-check after 2 min CPR
    state = CprDynamicState(
      isRunning: state.isRunning,
      startTime: state.startTime,
      elapsedSeconds: state.elapsedSeconds,
      cycleSecondsRemaining: 120,      // Restart CPR cycle immediately
      epiElapsedSeconds: state.epiElapsedSeconds,
      shockCount: nextCount,
      epiCount: state.epiCount,
      amioLidoCount: state.amioLidoCount,
      isShockableRhythm: null,         // Must re-confirm rhythm after CPR!
      totalCprSeconds: state.totalCprSeconds,
      logs: [_createLog('${nextCount}º Choque administrado — Retome CPR!', '#EF4444', isAlert: true), ...state.logs],
      isRosc: state.isRosc,
      isTor: state.isTor,
      tachycardiaRhythm: state.tachycardiaRhythm,
    );
  }

  void registerEpi() {
    state = state.copyWith(
      epiCount: state.epiCount + 1,
      epiElapsedSeconds: 1, // Inicia contagem: 1 → 180 (cooldown) → 181+ (overdue)
      logs: [_createLog('Epinefrina 1mg administrada', '#A855F7'), ...state.logs],
    );
  }

  void registerAmioLido() {
    final nextCount = state.amioLidoCount + 1;
    final logMessage = nextCount == 1 
      ? 'Amiodarona 300mg administrada' 
      : 'Amiodarona 150mg administrada (2ª dose)';
      
    state = state.copyWith(
      amioLidoCount: nextCount,
      logs: [_createLog(logMessage, '#A855F7'), ...state.logs],
    );
  }
  
  void registerCustom(String action, String colorHex) {
     state = state.copyWith(
      logs: [_createLog(action, colorHex), ...state.logs],
    );
  }

  void registerRosc() {
    _timer?.cancel();
    final totalTimeFormatted = state.formatTime(state.totalCprSeconds);
    state = state.copyWith(
      isRunning: false,
      isRosc: true,
      isTor: false,
      tachycardiaRhythm: null, // Clear tachy state if they explicitly hit ROSC
      logs: [_createLog('ROSC OBTIDO. Tempo total de RCP: $totalTimeFormatted', '#10B981', isAlert: true), ...state.logs],
    );
  }

  void registerTor() {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      isRosc: false,
      isTor: true,
      tachycardiaRhythm: null,
      logs: [_createLog('🛑 TÉRMINO DA RESSUSCITAÇÃO (TOR)', '#111827', isAlert: true), ...state.logs],
    );
  }

  void registerTachycardia(String rhythm) {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      tachycardiaRhythm: rhythm,
      isRosc: false, // It replaces ROSC state as the active mode
      isTor: false,
      logs: [_createLog('Ritmo: Taquicardia ($rhythm)', '#F59E0B', isAlert: true), ...state.logs],
    );
  }

  void registerAdenosine(String dose) {
    state = state.copyWith(
      logs: [_createLog('Adenosina $dose IV Rápido administrada', '#8B5CF6'), ...state.logs],
    );
  }

  void registerCardioversion() {
    final isPolymorphic = state.tachycardiaRhythm == 'Polimórfica';
    final actionName = isPolymorphic ? 'Desfibrilação NÃO-sincronizada' : 'Cardioversão Sincronizada';
    state = state.copyWith(
      logs: [_createLog('⚡ $actionName realizada', '#EF4444', isAlert: true), ...state.logs],
    );
  }

  void registerDrug(String description) {
    state = state.copyWith(
      logs: [_createLog('💊 $description administrado', '#A855F7'), ...state.logs],
    );
  }

  CprLogEvent _createLog(String message, String colorHex, {bool isAlert = false}) {
    final now = DateTime.now();
    return CprLogEvent(
      timeText: state.formatTime(state.elapsedSeconds),
      realTime: now,
      message: message,
      colorHex: colorHex,
      isAlert: isAlert,
    );
  }
}

final cprDynamicProvider = StateNotifierProvider<CprDynamicNotifier, CprDynamicState>((ref) {
  return CprDynamicNotifier();
});
