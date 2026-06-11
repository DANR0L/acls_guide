// ─────────────────────────────────────────────────────────
//  AlgorithmNode — nó de uma árvore de decisão clínica
// ─────────────────────────────────────────────────────────
enum NodeType {
  question,   // Pergunta com opções
  info,       // Informação / instrução
  action,     // Ação a executar (ex: desfibrilar)
  drug,       // Administrar medicamento
  end,        // Fim do algoritmo (ROSC / TOR)
  loop,       // Retorno a ponto anterior (ciclos CPR)
  timer,      // Iniciar/parar cronômetro
}

class AlgorithmOption {
  final String label;
  final String nextNodeId;
  final String? sublabel;

  const AlgorithmOption({
    required this.label,
    required this.nextNodeId,
    this.sublabel,
  });
}

class AlgorithmNode {
  final String id;
  final NodeType type;
  final String title;
  final String? subtitle;
  final String? body;
  final List<AlgorithmOption>? options;
  final String? nextNodeId;       // Para nós sem opções (info/action/drug/timer)
  final DrugInfo? drug;
  final int? timerSeconds;        // Para type == timer
  final String? alertLevel;       // 'danger' | 'warning' | 'info' | 'success'
  final List<String>? bullets;    // Lista de pontos de ação

  const AlgorithmNode({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.body,
    this.options,
    this.nextNodeId,
    this.drug,
    this.timerSeconds,
    this.alertLevel,
    this.bullets,
  });
}

// ─────────────────────────────────────────────────────────
//  DrugInfo — informações sobre medicamento
// ─────────────────────────────────────────────────────────
class DrugInfo {
  final String name;
  final String dose;
  final String route;
  final String? frequency;
  final String? maxDose;
  final String? notes;
  final String color; // hex para card colorido

  const DrugInfo({
    required this.name,
    required this.dose,
    required this.route,
    this.frequency,
    this.maxDose,
    this.notes,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────
//  Algorithm — algoritmo completo
// ─────────────────────────────────────────────────────────
class Algorithm {
  final String id;
  final String title;
  final String subtitle;
  final String iconEmoji;
  final String color;         // hex color do card
  final String startNodeId;
  final Map<String, AlgorithmNode> nodes;

  const Algorithm({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconEmoji,
    required this.color,
    required this.startNodeId,
    required this.nodes,
  });
}

// ─────────────────────────────────────────────────────────
//  AlgorithmSession — sessão de atendimento ativo
// ─────────────────────────────────────────────────────────
class AlgorithmSession {
  final String algorithmId;
  final List<String> history;   // IDs de nós visitados
  final String currentNodeId;
  final DateTime startTime;

  const AlgorithmSession({
    required this.algorithmId,
    required this.history,
    required this.currentNodeId,
    required this.startTime,
  });

  AlgorithmSession copyWith({
    String? currentNodeId,
    List<String>? history,
  }) {
    return AlgorithmSession(
      algorithmId: algorithmId,
      history: history ?? this.history,
      currentNodeId: currentNodeId ?? this.currentNodeId,
      startTime: startTime,
    );
  }
}
