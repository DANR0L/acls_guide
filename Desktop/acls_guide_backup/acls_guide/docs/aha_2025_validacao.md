# VALIDAÇÃO AHA 2025 — REFERÊNCIA OFICIAL DO PROJETO
# Validado pelo Dr. Daniel em 17/Jul/2026
# NÃO ALTERAR este arquivo sem aprovação explícita do usuário

## 16 CORREÇÕES AHA 2025 APLICADAS E VALIDADAS

### algorithms.dart — 16 alterações:

1. **1º Choque PCR**: `120–200J (seguir fabricante)` (era 200J fixo)
2. **Acesso vascular**: `IV preferencial; IO se IV falhar` (AHA 2025)
3. **5H5T Toxinas**: Flumazenil REMOVIDO, antídotos específicos adicionados
4. **Flutter instável**: **200J bifásico** (era 50–100J)
5. **TSV instável**: **100J bifásico** (era 50–100J)
6. **Flutter estável**: **200J sincronizado** (era 50–100J)
7. **Procainamida WPW**: dose em mg/min com critérios de parada
8. **TTM**: **32–37,5°C por ≥36h** (era 32–36°C por ≥24h), soro gelado contraindicado
9. **Neuroprognosticação**: **≥72h após normotermia** (era <72h após ROSC)
10. **HNF STEMI**: doses diferenciadas ICP vs Trombólise
11. **TNK idosos**: **meia dose ≥75 anos** (STREAM Trial)
12. **AVC header**: atualizado para **AHA/ASA 2026**
13. **Janela AVC**: **4,5–9h com DWI-FLAIR mismatch** adicionada
14. **AVCh**: reversão DOAC separada (Dabigatran vs anti-Xa), PA para INTERACT-3
15. **Trombectomia**: **basilar ≤24h NIHSS≥10** (AHA/ASA 2026)
16. **Cabeceira AVC**: **30° fixa** (HeadPoST)

### cpr_dynamic_provider.dart — 5 alterações:

1. **TSV**: 100J (era 50–100J)
2. **Flutter**: 200J (era 50–100J), BCC+BB advertência
3. **Torsades**: MgSO4 bolus 1–2min (era 15min)
4. **4º choque**: Epi primeiro, Amio só após 5º choque
5. **Desfibrilação TV poli**: 120–200J (range correto)

---

## TABELA DE ENERGIAS DE CARDIOVERSÃO (AHA 2025)

| Arritmia | Energia | Modo |
|---|---|---|
| FA (instável) | ≥ 200 J bifásico | Sincronizado |
| Flutter Atrial (instável) | 200 J bifásico | Sincronizado |
| Flutter Atrial (estável) | 200 J bifásico | Sincronizado |
| TSV / TRNAV | 100 J bifásico | Sincronizado |
| TV Monomórfica com pulso | 100 J bifásico | Sincronizado |
| TV Polimórfica / Torsades | 120-200 J bifásico | NÃO sincronizado (desfibrilação) |
| FV / TV sem pulso (1º choque) | 120-200 J (seguir fabricante) | NÃO sincronizado |

## DROGAS — REFERÊNCIA RÁPIDA

| Droga | Dose | Via | Observação |
|---|---|---|---|
| Amiodarona (PCR) | 300 mg 1ª dose, 150 mg 2ª | IV/IO | Após 3º choque |
| Amiodarona (cardioversão refratária) | 150 mg em 10 min | IV | Máx 2,2g/24h |
| Lidocaína | 1-1,5 mg/kg bolus | IV | Alternativa à amiodarona |
| Procainamida (WPW) | 20 mg/min | IV | Máx 17 mg/kg, parar se QRS alargar >50% |
| Adenosina | 6 mg → 12 mg → 12 mg | IV push rápido | Flush com SF 20 mL |
| MgSO4 (Torsades) | 2 g em 1-2 min | IV bolus | 1ª linha obrigatória |
| Epinefrina (PCR) | 1 mg a cada 3-5 min | IV/IO | Iniciar imediatamente em ritmos não chocáveis |

## TTM PÓS-PCR

- Temperatura: **32–37,5°C por ≥36h** (AHA 2025)
- Soro gelado IV: **CONTRAINDICADO** para indução
- Neuroprognosticação: **≥72h após normotermia**

---

## MÓDULO AVC — 11 CORREÇÕES APLICADAS E VALIDADAS
### Validado pelo Dr. Daniel em 12/Ago/2026 — Baseado em AHA/ASA 2026

### algorithms.dart (strokeAlgorithm) — 11 alterações:

1. **[CRÍTICA] Glicemia extrema**: removida de exclusão absoluta → `"Glicemia extrema: CORRIGIR e reavaliar elegibilidade — não é exclusão absoluta (AHA/ASA 2026)"` (Nó 13)
2. **Porta-TC**: `≤ 25 min` → **`≤ 20 min`** (Nós 3 e 10 — meta AHA/ASA)
3. **Porta-agulha**: `≤ 45–60 min` → **`≤ 60 min (ideal ≤ 30 min)`** (Nó 3)
4. **Janela estendida**: adicionado **CTP/perfusão** como alternativa ao DWI-FLAIR mismatch (Nó 8)
5. **[CRÍTICA] Alerta TNK dose**: adicionado aviso explícito `"TNK 0,4 mg/kg = dose do IAM ≠ AVC (0,25 mg/kg máx 25 mg)"` (Nó 18)
6. **AVCh PA**: `"alvo < 140 mmHg"` → `"redução RÁPIDA e agressiva para < 140 mmHg (INTERACT-3)"` + alerta de que a regra dos 15%/h é do isquêmico, NÃO do hemorrágico (Nó 12)
7. **Trombólise + trombectomia**: reforçado que são **estratégias paralelas**, não sequenciais — NÃO aguardar efeito da trombólise (Nó 21)
8. **ASPECTS**: adicionado `"ASPECTS ≥ 6 E/OU core < 70 mL = critério favorável para trombectomia"` com distinção entre ASPECTS (TC sem contraste) e core por perfusão (janela estendida) (Nó 21)
9. **AVC posterior / FAST negativo**: adicionado alerta de que vertigem súbita, diplopia, disfagia, ataxia e drop attack sugerem AVC posterior — FAST normal NÃO exclui AVC posterior (Nó 1)
10. **PA sem reperfusão**: `"< 220/120 nas primeiras 24h"` → `"NÃO tratar se < 220/120; se ≥ 220/120 OU complicação: redução de ATÉ 15% nas primeiras 24h — NUNCA redução agressiva"` (Nó 26)
11. **LKW + ECG**: adicionados no Código AVC — `"Registrar LKW (último momento sem sintomas)"` e `"ECG de 12 derivações imediato (FA = causa cardioembólica em 25% dos AVC)"` (Nó 3)

### NIHSS (nihss_card.dart):
- Classificação completa (0 / 1–4 / 5–15 / 16–20 / 21–42) agora exibida **sempre** ao concluir a avaliação (não apenas no Modo Estudo) — fins didáticos
- NIHSS já possuía todos os 15 itens (1a, 1b, 1c, 2–11) — confirmado

### TABELA DE PA NO AVC (AHA/ASA 2026)

| Situação | Conduta |
|---|---|
| AVC isquêmico pós-trombólise/trombectomia | Manter PA < 180/105 mmHg |
| AVC isquêmico SEM reperfusão, PA < 220/120 | NÃO tratar (preservar penumbra) |
| AVC isquêmico SEM reperfusão, PA ≥ 220/120 | Reduzir ATÉ 15% nas primeiras 24h |
| AVC hemorrágico | Redução RÁPIDA e agressiva para SBP < 140 mmHg (INTERACT-3) |

### REFERÊNCIA DOSES TNK — ATENÇÃO CRÍTICA

| Indicação | Dose | Via |
|---|---|---|
| AVC isquêmico | **0,25 mg/kg** (máx 25 mg) | IV bolus único |
| IAM / STEMI | **0,4–0,5 mg/kg** (por faixa de peso) | IV bolus único |

> ⚠️ NUNCA usar a dose do IAM no AVC — superdose pode causar transformação hemorrágica fatal.

---

## MÓDULO SCA (IAMCSST) — 4 CORREÇÕES APLICADAS E VALIDADAS
### Validado pelo Dr. Daniel em 12/Ago/2026 — Baseado em AHA/ASA 2026

### algorithms.dart (scaAlgorithm) — 4 alterações:

1. **[CRÍTICA] CI Absolutas à Trombólise**: Adicionadas duas contraindicações vitais ao Nó 17: `"PA sistólica > 180 mmHg ou diastólica > 110 mmHg não controlada (refratária)"` e `"Endocardite infecciosa"`.
2. **IVUS/OCT (Imagem Intracoronariana)**: Corrigido de Classe I para `"Classe IIa em casos selecionados (AHA 2025)"` (Nó 10) para evitar superestimação.
3. **Betabloqueador no STEMI**: Especificada a via para `"Betabloqueador ORAL nas primeiras 24h se estável (sem choque/IC/BAV) — evitar IV rotineiro"` (Nó 4).
4. **Troponina e Reperfusão**: Adicionado o alerta `"⚠️ Troponina NÃO deve atrasar a decisão de reperfusão — tratar com base no ECG e na clínica"` (Nó 2) para garantir o cumprimento das metas de tempo porta-balão/porta-agulha.

