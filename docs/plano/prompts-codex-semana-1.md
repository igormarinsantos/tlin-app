# Kit de prompts — Codex (Semana 1 / Fase 0)

> Como usar: 1 prompt = 1 tarefa = 1 PR. Espere terminar, revise o diff, commite, só então mande o próximo.
> Repos: ANTIGO = github.com/igormarinsantos/chatwoot-tlin · NOVO = seu fork de github.com/fazer-ai/chatwoot (criar antes de tudo, ex.: igormarinsantos/tlin-app)

## Passo 0 — VOCÊ, manual (antes de qualquer prompt)

1. No GitHub: Fork de `fazer-ai/chatwoot` → nome `tlin-app`.
2. Commite os 8 arquivos deste plano no repo NOVO em `docs/plano/` (dá pra fazer pelo próprio site do GitHub: Add file → Upload files).
3. Aponte o Codex pro repo desejado em cada tarefa (ele clona sozinho no ambiente dele).

---

## PROMPT 1 — Inventário (repo ANTIGO: chatwoot-tlin)

Trabalhe no repositório igormarinsantos/chatwoot-tlin, branch principal.

Contexto: este repo é um fork modificado do Chatwoot da fazer.ai. Vamos migrar para uma base nova e limpa; antes, precisamos inventariar o que existe aqui. NÃO altere nenhum código de produção — sua única entrega é um arquivo novo: docs/inventario-legado.md.

Tarefa:
1. Identifique o commit-base do fork (git merge-base com o upstream fazer-ai/chatwoot; adicione o remote se necessário) e liste com `git diff --stat` tudo que foi alterado desde então.
2. Escreva docs/inventario-legado.md com 4 seções:
   A) ASSETS DE MARCA: todos os logos, favicons, ilustrações e fontes adicionados/alterados, com caminhos.
   B) TOKENS VISUAIS: tabela consolidada de cores (hex), tipografia, raios e sombras, extraída de theme/, tailwind.config.js e qualquer CSS custom.
   C) CÓDIGO FUNCIONAL A MIGRAR: tudo que NÃO é visual e é nosso — especialmente o proxy do webhook Meta (veja META-WEBHOOK-PROXY.md e código relacionado), configs de deploy próprias, e o que mais encontrar de lógica adicionada.
   D) NÃO MIGRA: CSS duplicado, componentes do core editados por motivo visual, arquivos de rascunho na raiz (scratch/, get_logs.rb, test_ruby_llm.rb etc.).
3. Para cada item da seção C, diga em 1 linha o que faz e de quais arquivos depende.

Restrições: nenhuma alteração fora de docs/. Nenhuma refatoração. Entregue como PR.

---

## PROMPT 2 — Portões + validação da base (repo NOVO: tlin-app)

Trabalhe no repositório [seu-usuario]/tlin-app (fork recente de fazer-ai/chatwoot).

Leia primeiro: docs/plano/00-PLANO-MESTRE.md e docs/plano/fase-0-rebase.md. Execute a etapa 0.0 (portões) e a preparação da etapa 0.2:

1. LICENÇAS: leia LICENSE e mapeie pastas com licença própria (ex.: enterprise/). Documente em docs/decisoes.md: qual é a licença do core, o que está sob licença comercial, se existe código de kanban e onde, e qual a licença do recurso de scheduled messages. NÃO ative nada enterprise.
2. CAPTAIN OFF: identifique o mecanismo para o app rodar sem features enterprise/Captain (procure por ChatwootApp.enterprise?, feature flags e configs de instalação). Implemente a desativação do Captain por configuração/flag (UI escondida e rotas desligadas), SEM deletar código. Documente o mecanismo em docs/decisoes.md.
3. SETUP DEV: garanta que o projeto builda e os testes básicos passam no ambiente. Escreva docs/dev-setup.md com o passo a passo real que funcionou (dependências, env vars mínimas, como subir web+worker+banco+redis).
4. WHATSAPP CLOUD API: localize o provider oficial (Cloud API) no código dos canais WhatsApp e documente em docs/decisoes.md como configurá-lo (env/campos), para avaliarmos aposentar nosso proxy próprio.

Restrições: mudanças mínimas (só a flag do Captain + docs). 1 PR. Liste no PR qualquer surpresa encontrada.

---

## PROMPT 3 — Migrar o proxy Meta (repo NOVO — rodar só DEPOIS de revisar o inventário)

Leia docs/plano/fase-0-rebase.md (etapa 0.3) e docs/inventario-legado.md seção C (copie este arquivo do repo antigo para docs/ se ainda não estiver).

Com base em docs/decisoes.md (item Cloud API): se o suporte nativo do fork cobrir o fluxo do nosso proxy Meta, NÃO migre o proxy — escreva a justificativa em docs/decisoes.md e configure o caminho nativo. Se não cobrir, migre do repo antigo (igormarinsantos/chatwoot-tlin) apenas o código do proxy listado no inventário, adaptando ao layout atual, com teste do fluxo de webhook.

1 PR, mudanças mínimas, sem refatorar código vizinho.

---

## PROMPT 4 — IDV via tokens (repo NOVO)

Leia docs/plano/fase-0-rebase.md (etapa 0.4) e docs/inventario-legado.md seções A e B.

Aplique a identidade visual tlin usando SOMENTE a camada de tema: tokens no tailwind/CSS variables conforme a tabela de tokens do inventário, e substituição dos assets de marca pelos caminhos oficiais de branding (consulte CUSTOM_BRANDING.md do próprio repo). PROIBIDO editar componentes Vue ou views do core por motivo estético — o que o sistema de tema não cobrir, liste em docs/divida-visual.md em vez de implementar.

Entregue com screenshots de login, inbox e dashboard no PR. Timebox: bom o suficiente, não pixel-perfect.

---

## PROMPT 5 — SaaS-ficação / de-chatwoot-ização (repo NOVO)

Leia docs/plano/fase-0-rebase.md (etapa 0.4b).

1. Aplique as variáveis de branding documentadas em CUSTOM_BRANDING.md: nome da instalação, remetente de e-mail, links de ajuda/termos → tudo tlin.
2. Varra a UI (grep por "chatwoot", "upgrade", "billing", "plan") atrás de banners de upgrade, menções a planos Chatwoot e links externos deles. Remova via config/feature flag/tema. O que exigir tocar core: NÃO faça — liste em docs/divida-visual.md com o local exato.
3. Confirme que o LICENSE (MIT) permanece intacto no repo.
4. No PR, liste cada ponto encontrado e como foi tratado.

---

## PROMPT 6 — Baseline de saúde (repo NOVO — fecha a Fase 0)

Leia docs/plano/fase-0-rebase.md (etapa 0.5).

1. Rode Lighthouse (mobile) em login, inbox e dashboard e escreva docs/perf-baseline.md com FCP/LCP/TBT e tamanho transferido.
2. Confirme build (pnpm build) e specs tocadas verdes.
3. Faça um merge de teste do upstream fazer-ai/chatwoot em uma branch descartável e reporte: houve conflito em código core? Onde? (Não mergeie na principal; só o relatório.)
4. Feche marcando na PR os critérios de aceite da Fase 0 que passaram e os que faltam.

---

## Depois disso

Fase 0 fechada → me traga o inventario-legado.md, o decisoes.md e o resultado dos critérios de aceite, e eu te entrego o kit de prompts da Semana 2 (Fase 1: models, estados humano↔IA, engine). Um kit por semana — prompt escrito antes da hora envelhece.
