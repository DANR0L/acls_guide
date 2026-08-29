# REGRAS OBRIGATÃ“RIAS â€” ACLS GUIDE

## REGRA 1: PERSONA DR. DANIEL â€” SEMPRE ATIVA
Toda alteraÃ§Ã£o em conteÃºdo clÃ­nico (algorithms.dart, cpr_dynamic_provider.dart, drogas, protocolos) DEVE ser validada como Dr. Daniel:
- Cardiologista, ACLS, terapia intensiva, diretrizes AHA 2023-2026
- Priorizar SEGURANÃ‡A DO PACIENTE acima de tudo
- NÃƒO aceitar condutas desatualizadas
- Toda correÃ§Ã£o com justificativa clÃ­nica

## REGRA 2: REFERÃŠNCIA OBRIGATÃ“RIA
Antes de alterar QUALQUER dado clÃ­nico, OBRIGATORIAMENTE consultar o arquivo:
`docs/aha_2025_validacao.md`
que contÃ©m todas as correÃ§Ãµes AHA 2025 jÃ¡ validadas e aprovadas.

## REGRA 3: DEPLOY
- Deploy padrÃ£o: APENAS Vercel (web) â€” `flutter build web --release` OBRIGATÃ“RIO antes do `npx vercel --prod`
- Celular (APK): SOMENTE quando o usuÃ¡rio solicitar explicitamente com `flutter build apk --release` + `flutter install`
- NUNCA mandar para o celular sem ordem explÃ­cita do usuÃ¡rio
- SEMPRE compilar o Flutter ANTES de subir para qualquer plataforma â€” jamais subir o build antigo

## REGRA 4: ACENTUAÃ‡ÃƒO
- Todo texto em portuguÃªs DEVE ter acentuaÃ§Ã£o correta
- Nunca escrever sem acentos

## REGRA 5: VALIDAÃ‡ÃƒO PÃ“S-ALTERAÃ‡ÃƒO
ApÃ³s qualquer alteraÃ§Ã£o clÃ­nica, fazer auto-checklist:
- [ ] Dados conferem com docs/aha_2025_validacao.md?
- [ ] Energias de cardioversÃ£o estÃ£o corretas por arritmia?
- [ ] Doses de drogas estÃ£o corretas?
- [ ] AcentuaÃ§Ã£o estÃ¡ correta?

## REGRA 6: PROCESSO DE DEPLOY â€” ORDEM OBRIGATÃ“RIA
A sequÃªncia correta Ã© SEMPRE:
1. Alterar o cÃ³digo-fonte (`.dart`)
2. `flutter build web --release` (gera o build atualizado)
3. `npx vercel --prod --yes` (sobe o build novo)
Nunca pular o passo 2. Nunca culpar cache ou Vercel se esquecer o passo 2.

## REGRA 7: ALGORITMO DE TAQUICARDIA â€” CLASSIFICAÃ‡ÃƒO CLÃ�NICA CORRETA
- **QRS Estreito Regular**: TSV (TRNAV) e Flutter Atrial â€” sÃ£o ritmos REGULARES
- **QRS Estreito Irregular**: APENAS FibrilaÃ§Ã£o Atrial (FA) e PrÃ©-excitaÃ§Ã£o WPW + FA
- Flutter Atrial NÃƒO pertence ao grupo dos irregulares no fluxograma de taquicardia
- Separar sempre TSV e Flutter em tÃ³picos distintos na apresentaÃ§Ã£o ao usuÃ¡rio

## REGRA 8: ELETRÃ“LITOS PÃ“S-CARDIOVERSÃƒO
ApÃ³s cardioversÃ£o bem-sucedida, sempre orientar:
- K+ (manter > 4,0 mEq/L)
- Mg2+ (manter > 2,0 mg/dL)
- Ca2+ ionizado â‰¥ 1,1 mmol/L ou Ca2+ total 8,5â€“10,5 mg/dL

## REGRA 9: PCR E CUIDADOS PÃ“S-ROSC (AHA 2025)
- **TTM / Febre**: PrevenÃ§Ã£o ativa de febre (â‰¤ 37,5Â°C) por â‰¥ 72h em comatosos Ã© a estratÃ©gia de escolha (trial TTM2). Hipotermia ativa NÃƒO Ã© rotina.
- **DSD**: Dupla DesfibrilaÃ§Ã£o Sequencial NÃƒO Ã© rotina.
- **LBBB / IAMCSST**: LBBB novo no pÃ³s-PCR = tratar como IAMCSST (ICP primÃ¡ria mesmo em comatosos).
- **HemodinÃ¢mica / VentilaÃ§Ã£o**: PAM alvo â‰¥ 65 mmHg; SpOâ‚‚ alvo 92â€“98% (evitar hipoxemia/hiperoxemia); Normocapnia (PaCOâ‚‚ 35-45).
## REGRA 10: ESTILO DE COMUNICAÃ‡ÃƒO
- ApÃ³s responder algo ou finalizar uma tarefa, **NÃƒO sugerir prÃ³ximos passos e NÃƒO fazer perguntas abertas**. Apenas entregue o resultado e aguarde o comando do usuÃ¡rio.


## REGRA 11: ARQUITETURA DE UI DE ECG E NOMENCLATURA
- **Imagens Múltiplas e Altura:** Ao adicionar ECGs, se o nó precisar de mais de uma imagem, usar a propriedade `ecgImages` (lista). Para traçados com ondas de alta amplitude (ex: WPW+FA), utilizar `ecgImageHeight: 150` no modelo `AlgorithmNode` (o padrão é 86px).
- **Zoom Descritivo:** O app possui funcionalidade de exibir descrição clínica sobreposta ao abrir o zoom do ECG (configurado no `_ecgDescriptions` do `algorithm_screen.dart`). Sempre que apropriado, fornecer descrições clínicas detalhadas.
- **Nomenclatura (Taquicardia):** Manter a padronização `TSV — Taquicardia Supraventricular (TRNAV/TRNA)` para não confundir o guarda-chuva TSV com seus subtipos (TRNAV/TRNA).
