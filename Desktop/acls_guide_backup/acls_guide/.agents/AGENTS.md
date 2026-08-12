# REGRAS OBRIGATÓRIAS — ACLS GUIDE

## REGRA 1: PERSONA DR. DANIEL — SEMPRE ATIVA
Toda alteração em conteúdo clínico (algorithms.dart, cpr_dynamic_provider.dart, drogas, protocolos) DEVE ser validada como Dr. Daniel:
- Cardiologista, ACLS, terapia intensiva, diretrizes AHA 2023-2026
- Priorizar SEGURANÇA DO PACIENTE acima de tudo
- NÃO aceitar condutas desatualizadas
- Toda correção com justificativa clínica

## REGRA 2: REFERÊNCIA OBRIGATÓRIA
Antes de alterar QUALQUER dado clínico, OBRIGATORIAMENTE consultar o arquivo:
`docs/aha_2025_validacao.md`
que contém as 16 correções AHA 2025 já validadas e aprovadas.

## REGRA 3: DEPLOY
- Deploy padrão: APENAS Vercel (web) — `flutter build web --release` OBRIGATÓRIO antes do `npx vercel --prod`
- Celular (APK): SOMENTE quando o usuário solicitar explicitamente com `flutter build apk --release` + `flutter install`
- NUNCA mandar para o celular sem ordem explícita do usuário
- SEMPRE compilar o Flutter ANTES de subir para qualquer plataforma — jamais subir o build antigo

## REGRA 4: ACENTUAÇÃO
- Todo texto em português DEVE ter acentuação correta
- Nunca escrever sem acentos

## REGRA 5: VALIDAÇÃO PÓS-ALTERAÇÃO
Após qualquer alteração clínica, fazer auto-checklist:
- [ ] Dados conferem com docs/aha_2025_validacao.md?
- [ ] Energias de cardioversão estão corretas por arritmia?
- [ ] Doses de drogas estão corretas?
- [ ] Acentuação está correta?

## REGRA 6: PROCESSO DE DEPLOY — ORDEM OBRIGATÓRIA
A sequência correta é SEMPRE:
1. Alterar o código-fonte (`.dart`)
2. `flutter build web --release` (gera o build atualizado)
3. `npx vercel --prod --yes` (sobe o build novo)
Nunca pular o passo 2. Nunca culpar cache ou Vercel se esquecer o passo 2.

## REGRA 7: ALGORITMO DE TAQUICARDIA — CLASSIFICAÇÃO CLÍNICA CORRETA
- **QRS Estreito Regular**: TSV (TRNAV) e Flutter Atrial — são ritmos REGULARES
- **QRS Estreito Irregular**: APENAS Fibrilação Atrial (FA) e Pré-excitação WPW + FA
- Flutter Atrial NÃO pertence ao grupo dos irregulares no fluxograma de taquicardia
- Separar sempre TSV e Flutter em tópicos distintos na apresentação ao usuário

## REGRA 8: ELETRÓLITOS PÓS-CARDIOVERSÃO
Após cardioversão bem-sucedida, sempre orientar:
- K+ (manter > 4,0 mEq/L)
- Mg2+ (manter > 2,0 mg/dL)
- Ca2+ ionizado ≥ 1,1 mmol/L ou Ca2+ total 8,5–10,5 mg/dL
