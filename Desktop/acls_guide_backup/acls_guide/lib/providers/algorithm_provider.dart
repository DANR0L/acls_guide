import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/algorithms.dart';
import '../models/algorithm_node.dart';

// ─── Modo Estudo (sem timer automático) ─────────────────────────
// true = Modo Estudo: timers são opcionais/puláveis
// false = Modo Emergência: timer inicia automaticamente
final studyModeProvider = StateProvider<bool>((ref) => false);

// ─── Provider do algoritmo selecionado ──────────────────────────
final selectedAlgorithmProvider = StateProvider<Algorithm?>((ref) => null);

// ─── Provider da sessão ativa ────────────────────────────────────
final algorithmSessionProvider =
    StateNotifierProvider<AlgorithmSessionNotifier, AlgorithmSession?>((ref) {
  return AlgorithmSessionNotifier(ref);
});

class AlgorithmSessionNotifier extends StateNotifier<AlgorithmSession?> {
  final Ref ref;
  AlgorithmSessionNotifier(this.ref) : super(null);

  void startSession(Algorithm algorithm) {
    ref.invalidate(nihssScoresProvider);
    state = AlgorithmSession(
      algorithmId: algorithm.id,
      history: [],
      currentNodeId: algorithm.startNodeId,
      startTime: DateTime.now(),
    );
  }

  void goToNode(String nodeId) {
    if (state == null) return;
    final newHistory = [...state!.history, state!.currentNodeId];
    state = state!.copyWith(
      currentNodeId: nodeId,
      history: newHistory,
    );
  }

  void goBack() {
    if (state == null || state!.history.isEmpty) return;
    final newHistory = [...state!.history];
    final previousNodeId = newHistory.removeLast();
    state = state!.copyWith(
      currentNodeId: previousNodeId,
      history: newHistory,
    );
  }

  void reset() {
    state = null;
  }
}

// ─── Provider do nó atual ────────────────────────────────────────
final currentNodeProvider = Provider<AlgorithmNode?>((ref) {
  final session = ref.watch(algorithmSessionProvider);
  if (session == null) return null;

  final algorithm = allAlgorithms[session.algorithmId];
  if (algorithm == null) return null;

  return algorithm.nodes[session.currentNodeId];
});

// ─── Provider do algoritmo atual ─────────────────────────────────
final currentAlgorithmProvider = Provider<Algorithm?>((ref) {
  final session = ref.watch(algorithmSessionProvider);
  if (session == null) return null;
  return allAlgorithms[session.algorithmId];
});

// ─── Provider do Timer CPR ───────────────────────────────────────
final cprTimerProvider =
    StateNotifierProvider<CprTimerNotifier, CprTimerState>((ref) {
  return CprTimerNotifier();
});

class CprTimerState {
  final bool isRunning;
  final int secondsRemaining;
  final int totalSeconds;

  const CprTimerState({
    required this.isRunning,
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  double get progress =>
      totalSeconds > 0 ? (totalSeconds - secondsRemaining) / totalSeconds : 0;

  bool get isFinished => secondsRemaining <= 0;
}

class CprTimerNotifier extends StateNotifier<CprTimerState> {
  CprTimerNotifier()
      : super(const CprTimerState(
          isRunning: false,
          secondsRemaining: 120,
          totalSeconds: 120,
        ));

  void start(int seconds) {
    state = CprTimerState(
      isRunning: true,
      secondsRemaining: seconds,
      totalSeconds: seconds,
    );
  }

  void tick() {
    if (!state.isRunning || state.secondsRemaining <= 0) return;
    state = CprTimerState(
      isRunning: state.secondsRemaining > 1,
      secondsRemaining: state.secondsRemaining - 1,
      totalSeconds: state.totalSeconds,
    );
  }

  void pause() {
    state = CprTimerState(
      isRunning: false,
      secondsRemaining: state.secondsRemaining,
      totalSeconds: state.totalSeconds,
    );
  }

  void resume() {
    if (state.secondsRemaining > 0) {
      state = CprTimerState(
        isRunning: true,
        secondsRemaining: state.secondsRemaining,
        totalSeconds: state.totalSeconds,
      );
    } else {
      start(120);
    }
  }

  void reset() {
    state = CprTimerState(
      isRunning: false,
      secondsRemaining: state.totalSeconds,
      totalSeconds: state.totalSeconds,
    );
  }
}

// ─── Provider para o estado do NIHSS ────────────────────────────
final nihssScoresProvider = StateProvider<List<int?>>((ref) => List.filled(15, null));

// ─── Provider para contagem de choques na PCR ───────────────────
final shockCountProvider = Provider<int>((ref) {
  final session = ref.watch(algorithmSessionProvider);
  if (session == null) return 0;
  
  final algorithm = allAlgorithms[session.algorithmId];
  if (algorithm == null) return 0;
  
  int count = 0;
  final allVisitedNodes = [...session.history, session.currentNodeId];
  for (final nodeId in allVisitedNodes) {
    if (algorithm.nodes[nodeId]?.isShockNode == true) {
      count++;
    }
  }
  return count;
});
