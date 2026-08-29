const fs = require('fs');
let t = fs.readFileSync('lib/data/algorithms.dart', 'utf8');

// 1. Update evt_eval option labels
t = t.replace(
  "AlgorithmOption(label: 'SIM — Elegível', nextNodeId: 'evt_action')",
  "AlgorithmOption(label: 'SIM — LVO confirmada, elegível', nextNodeId: 'evt_action')"
);
t = t.replace(
  "AlgorithmOption(label: 'NÃO', nextNodeId: 'stroke_unit')",
  "AlgorithmOption(label: 'NÃO — Sem LVO ou fora dos critérios', nextNodeId: 'stroke_unit')"
);

// 2. Update evt_action bullets
t = t.replace(
  "'Ativar neurorradiologia intervencionista',",
  "'Se em centro COM EVT → ativar neurorradiologia intervencionista',\n        'Se em centro SEM EVT → transferência IMEDIATA (drip-and-ship)',"
);
t = t.replace(
  "'PA pós-EVT: < 180/105 mmHg (se reperfusão bem-sucedida)',",
  ""
);

// 3. Add LVO discovery card to evt_eval
t = t.replace(
  "      didacticCards: {\n        'Critérios para EVT (AHA 2025)':",
  "      didacticCards: {\n        'LVO descoberta no hospital': 'Mesmo que o FAST-ED pré-hospitalar tenha sido < 4 (sem suspeita de LVO), a Angio-TC hospitalar é DEFINITIVA.\\n\\nSe a Angio-TC confirmar LVO:\\n• Paciente em centro COM trombectomia (TSC/CSC) → EVT no local\\n• Paciente em centro SEM trombectomia (ASRH/PSC) → TRANSFERÊNCIA IMEDIATA\\n\\nEstratégia Drip-and-Ship:\\n1. Iniciar trombólise IV no centro atual (drip)\\n2. Transferir para TSC/CSC durante ou após a infusão (ship)\\n3. NÃO esperar efeito da trombólise para decidir transferir\\n4. Notificar centro receptor com dados de imagem\\n\\n⚠️ A descoberta de LVO na imagem hospitalar MUDA toda a conduta — mesmo em pacientes inicialmente encaminhados ao centro mais próximo.',\n        'Critérios para EVT (AHA 2025)':"
);

// 4. Add drip-and-ship card to evt_action
t = t.replace(
  "      didacticCards: {\n        'Pós-Trombectomia':",
  "      didacticCards: {\n        'Drip-and-Ship (Transferência)': 'Quando o paciente está em centro SEM trombectomia (ASRH ou PSC):\\n\\n1. DRIP — Iniciar trombólise IV no centro atual\\n   • NÃO atrasar a trombólise esperando transferência\\n   • TNK (bolus único) é ideal para drip-and-ship\\n\\n2. SHIP — Transferir DURANTE ou APÓS o bolus\\n   • Contatar centro receptor (TSC/CSC) com imagens\\n   • Enviar dados: NIHSS, LKW, hora da trombólise, Angio-TC\\n   • Acompanhamento médico durante transporte\\n   • Monitorizar PA < 180/105 durante transferência\\n\\n⚠️ NÃO esperar efeito da trombólise para decidir transferir.\\nA decisão de transferir é tomada NO MOMENTO da descoberta da LVO.\\n\\nMotherShip (alternativa):\\nSe o paciente já está em centro COM trombectomia → EVT direta.',\n        'Pós-Trombectomia':"
);

fs.writeFileSync('lib/data/algorithms.dart', t, 'utf8');
console.log('All replacements done!');
