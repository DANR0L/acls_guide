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

---

## MÓDULO TAQUICARDIA COM PULSO — 4 CORREÇÕES APLICADAS E VALIDADAS
### Validado pelo Dr. Daniel em 12/Ago/2026 — Baseado em AHA/ASA 2025

### algorithms.dart (tachycardiaAlgorithm) — 4 alterações:

1. **Energia da FA**: Substituído o termo impreciso "(máximo)" por `"200 J bifásico (energia inicial de escolha — AHA 2025)"` (Nó 2).
2. **Procainamida na Cardioversão Refratária**: Na FA refratária, estabelecido que a Amiodarona é a 1ª linha e clarificado que `"Procainamida é alternativa na TV monomórfica, NÃO na FA refratária"` (Nó 5).
3. **Taquicardia Atrial e BCC/BB**: Inserido alerta crítico de que `"Betabloqueador IV (Metoprolol 5 mg) OU Verapamil 5-10 mg — NUNCA ambos juntos (risco de assistolia)"` e para evitar Verapamil em disfunção ventricular/IC (Nó 13).
4. **TV Monomórfica Estável**: Reforçada a sequência correta: `"Sequência: antiarrítmico IV → se falhar ou instabilizar, cardioversão elétrica sincronizada (100 J bifásico)"` (Nó 21).

---

## MÓDULO BRADICARDIA COM PULSO — CORREÇÕES APLICADAS E VALIDADAS
### Validado pelo Dr. Daniel em 12/Ago/2026 — Baseado em AHA/ASA 2025

### algorithms.dart (bradycardiaAlgorithm) — 2 alterações clínicas e 2 ajustes formais:

1. **Aviso de Marcapasso Precoce (Nó 4 - Atropina)**: Adicionado o alerta crítico: `"⚠️ Se suspeita de BAV de alto grau / infranodal (Mobitz II ou BAVT), preparar MCP transcutâneo em paralelo — a atropina é provavelmente ineficaz nesses bloqueios."` para evitar atraso no tratamento definitivo conforme recomendação AHA 2025.
2. **Causas Reversíveis Completas (Nó 6/11)**: Incluída a lista detalhada para investigação: `"isquemia/infarto (IAM inferior), drogas (bloqueador de canal de cálcio, betabloqueador, digoxina), hipóxia, distúrbios eletrolíticos (hipercalemia), hipotireoidismo, aumento da PIC, vagotonia."`
3. **Ajustes Formais**: Contagem de nós atualizada para 16 e nota de erro interna removida do Nó 16.

---

## MÓDULO PCR (PARADA CARDIORRESPIRATÓRIA) — CORREÇÕES APLICADAS E VALIDADAS
### Validado pelo Dr. Daniel em 12/Ago/2026 — Baseado em AHA/ASA 2025

### algorithms.dart (cardiacArrestAlgorithm) — 1 alteração crítica, 3 ajustes de precisão e 2 complementos:

1. **[CRÍTICA] Temperatura Alvo Pós-ROSC**: A recomendação foi atualizada abandonando a hipotermia ativa, agora instruindo: `"Prevenção ativa de febre — alvo ≤ 37,5°C (NÃO induzir hipotermia ativa em todos os pacientes — AHA 2025, trial TTM2)"`. Esta é a principal mudança de diretriz da AHA 2025 para Cuidados Pós-PCR.
2. **Dupla Desfibrilação Sequencial (DSD)**: Avisado que a técnica não deve ser rotina: `"Utilidade NÃO bem estabelecida — NÃO realizar rotineiramente (AHA 2025)"` (Nó dsd_shock e rhythm_check_4).
3. **Alvo Pressórico**: Substituída a imprecisa "PAS ≥ 90" pela correta `"PAM (MAP) ≥ 65 mmHg (evitar hipotensão)"` no Cuidados Pós-PCR.
4. **Precisão de Linguagem**: A nota interna/coloquial ("cagada no monitor") foi corrigida para `"Confirmar cabos e conexões do monitor (excluir artefato/desconexão)"` na checagem de Assistolia.
5. **Energia do Choque**: Ajustada a indicação de energia inicial para choque bifásico para priorizar os 200 J: `"Bifásico: 200 J (faixa recomendada 120–200 J)"`.
6. **Cuidados Pós-ROSC**: Adicionados os parâmetros essenciais: normocapnia (PaCO₂ 35–45 mmHg), glicemia (110–180 mg/dL), evitar hiperoxemia e considerar cine coronariana.

---

## MÓDULO CUIDADOS PÓS-PCR (ROSC) — CORREÇÕES APLICADAS E VALIDADAS
### Validado pelo Dr. Daniel em 12/Ago/2026 — Baseado em AHA/ASA 2025

### algorithms.dart (postRoscAlgorithm) — 1 alteração de alta prioridade e 3 refinamentos:

1. **[ALTA] TTM e Duração (Nó 11)**: Detalhada a duração e a estratégia do controle de temperatura: `"AHA 2025: Prevenção ativa de febre — alvo ≤ 37,5°C (tratar febre ≥ 37,7°C) por pelo menos 72 horas em pacientes comatosos (estratégia de escolha — trial TTM2). Hipotermia ativa 32–34°C: NÃO é rotina."`
2. **LBBB Novo (Nó 7)**: Separou-se LBBB prévio documentado (ECG normal) do novo: `"🟢 ECG normal ou LBBB prévio documentado (⚠️ LBBB novo = tratar como IAMCSST)"`.
3. **Alvo de SpO₂ (Nó 3)**: Ajustado de 94-98% para `"92-98% (evitar hipoxemia < 92% e hiperoxemia)"`, alinhado com o restante do app.
4. **Faixa da Norepinefrina (Nó 6)**: Refinada a dosagem inicial: `"0,05–1 mcg/kg/min (Iniciar em 0,05–0,1 mcg/kg/min e titular para PAM ≥ 65 mmHg)"` para evitar dosagens hipertensivas de largada.

---

## MÓDULO AVC — ESTRATIFICAÇÃO POR GRAVIDADE E TROMBECTOMIA — CORREÇÕES APLICADAS E VALIDADAS
### Validado pelo Dr. Daniel em 15/Ago/2026 — Baseado em AHA/ASA 2025/2026

### algorithms.dart (strokeAlgorithm) — 2 alterações de alta prioridade e 1 refinamento:

1. **[ALTA] Estratificação Pós-NIHSS**: O fluxo único do NIHSS foi desmembrado. Inserido o *gate* decisivo `"Déficit incapacitante?"`. Agora o fluxo roteia pacientes adequadamente:
   - NIHSS 0: `🚫 NÃO indicar trombólise (risco de HIC sem benefício). Reavaliar diagnóstico (TIA, miméticos).`
   - NIHSS 1-4 Não Incapacitante: `Trombólise NÃO recomendada rotineiramente (PRISMS). Iniciar Dupla Antiagregação.`
   - Qualquer NIHSS Incapacitante: Segue para TC e janela de reperfusão.
2. **[ALTA] Trombectomia em Core Grande**: Removida a exclusão automática para pacientes com grande área isquêmica. Inserido: `"⚠️ Core grande (ASPECTS 3–5 ou core ≥ 50 mL) NÃO é exclusão automática. Recomendada (Classe I) em selecionados: < 80 anos, NIHSS ≥ 6, mRS pré 0–1, LVO proximal, 6–24h."`
3. **Apoio de Tela (NIHSS)**: Adicionada a instrução de que `"O NIHSS não define sozinho a reperfusão. O que importa: (1) déficit é incapacitante? (2) há janela? (3) há LVO? Score alto nunca contraindica; score 0 sem déficit não justifica trombolítico."`

