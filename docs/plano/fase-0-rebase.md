# Fase 0 — Rebase: fork limpo + IDV como camada de tema

> Substitui a antiga `fase-0-performance.md`. Decisão: em vez de otimizar/mergear a base atual (107 commits de mudança visual feita por IA sem plano, base anterior ao kanban), refazemos a base a partir do fork atual da fazer.ai e reaplicamos a identidade visual de forma disciplinada.

**Por quê:** ganha kanban + scheduled messages + correções e melhorias do upstream; elimina o entulho que causa a lentidão; mantém o repo mergeável com o upstream pra sempre. O repo antigo vira gabarito visual, não é perdido.

**Regra permanente a partir daqui:** mudança visual SOMENTE via camada de tema/tokens (Tailwind config, CSS variables, `theme/`, assets). NUNCA editar componente Vue ou view do core para fins visuais. Isso é inegociável — é o que mantém o upstream acessível.

## Etapa 0.0 — Portões de entrada (resolver ANTES de qualquer código)

1. **Dados em produção?** Se a instância atual tem contas/conversas/números reais em uso, planejar migração de banco (dump → migrations da versão nova → validação). Se é só dev, seguir direto.
1b. **Desativar Captain por feature flag** no repo novo (UI + rotas), sem deletar código. Registrar em `docs/decisoes.md`.
2. **Auditoria de licença no repo novo:** ler `LICENSE` e mapear pastas com licença própria (ex.: `enterprise/`). Confirmar: (a) presença/ausência de código de kanban license-gated — se houver, manter desativado; (b) licença do Scheduled Messages antes de planejar uso comercial.
3. **Validar Cloud API nativa:** subir o provider oficial (Cloud API) do fork num número de teste e confirmar que cobre o fluxo atual ANTES de decidir aposentar o proxy Meta próprio. A decisão do proxy só se toma com esse teste feito.

## Etapa 0.1 — Inventário do repo antigo (não escrever código novo)

No repo atual (`chatwoot-tlin`), gerar `docs/inventario-legado.md` com:
1. **Assets de marca:** logos, favicons, ilustrações, fontes (listar caminhos).
2. **Decisões visuais:** paleta (hex), tipografia, raios/sombras — extrair de `theme/`, `tailwind.config.js` e CSS custom. Consolidar numa tabela de tokens.
3. **Código funcional próprio (não-visual) que precisa migrar:** proxy do webhook Meta (`META-WEBHOOK-PROXY.md` + código relacionado), qualquer config de deploy própria, e o que mais for identificado.
4. **Lista do que NÃO migra:** CSS duplicado, componentes editados do core, arquivos de rascunho.

Comando útil para achar tudo que foi tocado vs a base original:
`git diff --stat $(git merge-base HEAD <base-original>) HEAD`

## Etapa 0.2 — Novo repo

1. Fork/clone limpo do fork atual da fazer.ai → novo repo (ex.: `tlin-app`). Manter remote `upstream` apontando pra fazer.ai.
2. Subir em dev, confirmar que roda: conversas, kanban, scheduled messages, canal WhatsApp.
3. Commitar os planos em `docs/plano/` e o inventário.

## Etapa 0.3 — Migrar o funcional

- Portar o proxy do webhook Meta e demais itens do inventário (item 3), com teste manual do fluxo WhatsApp ponta a ponta.
- 1 PR por item migrado.

## Etapa 0.4 — Reaplicar a IDV (do jeito certo)

- Aplicar tokens (cores, fontes, raios) via Tailwind config + CSS variables. Usar `CUSTOM_BRANDING.md` do upstream como guia do que é suportado oficialmente.
- Substituir logos/assets pelos caminhos oficiais de branding.
- Comparar visualmente com o repo antigo (gabarito) tela a tela: login, inbox, dashboard, kanban.
- O que o sistema de tema não cobrir: anotar em `docs/divida-visual.md` e discutir antes de qualquer edição fora da camada de tema. Default: não editar core.

## Etapa 0.4b — SaaS-ficação da base (modo community + de-chatwoot-ização)

- Confirmar e documentar o mecanismo do fork pra rodar sem enterprise (detecção da pasta/flag — verificar como o código faz o check em `ChatwootApp`/config) e garantir que NENHUMA feature enterprise executa. Registrar em `docs/decisoes.md`.
- Aplicar as variáveis de branding documentadas no `CUSTOM_BRANDING.md` do fork: nome da instalação, logos, remetente de e-mail, links de ajuda/termos apontando pra tlin.
- Varrer a UI atrás de resíduos: banners de upgrade/paywall, menções a planos Chatwoot, links pra chatwoot.com, "powered by". Remover via config/tema; qualquer exceção que exija tocar core → anotar em `docs/divida-visual.md` e discutir antes.
- Preservar LICENSE e avisos exigidos pelo MIT no repositório.
- Teste: navegar todas as áreas do app como admin e como agente sem encontrar nenhuma referência a Chatwoot/upgrade.

## Etapa 0.5 — Verificação de saúde

- Lighthouse (mobile) em login, inbox e dashboard → `docs/perf-baseline.md`. (Vira o baseline oficial do produto; a expectativa é já nascer rápido.)
- `pnpm build` e specs verdes.
- Merge de teste do upstream (`git merge upstream/main`) para confirmar que a base continua mergeável sem conflito relevante.

## Critérios de aceite da fase

- [ ] Portões da etapa 0.0 resolvidos e documentados (dados, licenças, teste da Cloud API)
- [ ] Novo repo rodando com kanban, scheduled messages e WhatsApp funcionais
- [ ] Proxy Meta migrado e testado ponta a ponta
- [ ] IDV aplicada 100% via camada de tema; zero edição de componente core por motivo visual
- [ ] `docs/inventario-legado.md`, `docs/perf-baseline.md` e (se houver) `docs/divida-visual.md` commitados
- [ ] Merge de teste do upstream sem conflitos em código core
- [ ] Modo community confirmado (zero feature enterprise ativa) e experiência sem referência a Chatwoot/upsell
- [ ] Repo antigo arquivado como referência (README apontando pro novo)

## Fatiamento para o agente de código (1 tarefa = 1 PR)

1. "No repo antigo: gere `docs/inventario-legado.md` conforme etapa 0.1. Não altere código."
2. "No repo novo: suba o ambiente e valide kanban/scheduled messages/WhatsApp. Documente como rodar em `docs/dev-setup.md`."
3. "Migre o proxy do webhook Meta conforme inventário."
4. "Aplique os tokens de tema do inventário via Tailwind/CSS vars. Não edite componentes."
5. "Substitua os assets de marca. Compare com o gabarito e liste divergências."
6. "Rode a verificação de saúde da etapa 0.5 e escreva o baseline."

## Impacto nas fases seguintes (ajustes)

- **ATENÇÃO — Kanban da fazer.ai é LICENCIADO POR INSTÂNCIA (comercial), não MIT.** Não usar como base do CRM. A Fase 1 segue o plano original: `Deal`/`Pipeline` próprios (etapa 1.3 como escrita). O CRM é o coração do produto e deve ser 100% nosso. Ao subir o repo novo, verificar se há código de kanban license-gated e mantê-lo desativado.
- **Fase 2:** tool `schedule_followup` do agente de follow-up deve usar o Scheduled Messages nativo do fork (esse aparenta ser parte aberta — confirmar licença do código no repo antes de usar).
- **Proxy Meta:** o fork atual suporta Cloud API (oficial) nativamente como provider de WhatsApp. Durante o inventário (0.1), avaliar se o proxy próprio ainda é necessário ou se migra para o suporte nativo — menos código nosso pra manter é melhor.
