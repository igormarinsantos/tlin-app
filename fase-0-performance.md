# Fase 0 — Performance e saúde da base

**Objetivo:** app rápido e base limpa antes de construir a engine de agentes. A identidade visual foi aplicada por IA sem plano — presumir que existe código morto, CSS duplicado e componentes mal feitos até prova em contrário.

**Regra de ouro desta fase:** MEDIR → CORRIGIR → MEDIR DE NOVO. Nenhuma otimização entra sem número de antes/depois. Não "otimizar" nada que a medição não apontou.

## Etapa 0.1 — Diagnóstico (não muda código de produção)

1. **Frontend:**
   - Lighthouse (mobile) nas 3 telas principais: login, inbox/conversas, dashboard. Registrar FCP, LCP, TBT, tamanho total transferido.
   - `pnpm build` + análise de bundle (rollup-plugin-visualizer no Vite). Registrar os 10 maiores chunks.
   - Procurar: CSS do tema duplicando o CSS base do Chatwoot; imagens/logos sem otimização em `public/` e `theme/`; dependências adicionadas pelo tema que não são usadas.
2. **Backend:**
   - `rack-mini-profiler` em dev nas mesmas 3 telas. Registrar tempo de cada request > 300ms.
   - Log de queries: procurar N+1 nas telas de conversa (gem `bullet`).
3. **Entregável:** `docs/perf-baseline.md` com todos os números. Sem esse arquivo, a fase não avança.

## Etapa 0.2 — Correções de frontend (ordenadas por impacto medido)

Candidatos prováveis (confirmar no diagnóstico antes):
- Deduplicar CSS do tema: o tema deve **sobrescrever variáveis** (tokens do Tailwind/CSS vars), não redeclarar componentes inteiros.
- Comprimir/converter imagens do branding (WebP, tamanhos corretos, `loading="lazy"` onde couber).
- Code-splitting: rotas pesadas do dashboard em `defineAsyncComponent`/import dinâmico se o bundle principal estiver inflado.
- Remover dependências e componentes órfãos que o rework visual deixou (verificar com busca de referências antes de apagar).

## Etapa 0.3 — Correções de backend (se o diagnóstico apontar)

- Corrigir N+1 com `includes`/`preload` pontuais.
- Cache fragmentado ou HTTP cache em endpoints quentes, se houver endpoint > 500ms recorrente.
- NÃO mexer em Sidekiq/infra nesta fase salvo gargalo comprovado.

## Etapa 0.4 — Limpeza de base

- Remover arquivos de rascunho da raiz que não pertencem ao produto (`scratch/`, `grep_captain_utf8.txt`, `get_logs.rb`, `test_ruby_llm.rb` → mover o que for útil para `lib/tlin/` ou `docs/`, apagar o resto).
- Garantir que `pnpm build` e a suíte de specs tocada pelas mudanças passam.

## Critérios de aceite da fase

- [ ] `docs/perf-baseline.md` e `docs/perf-after.md` existem com números comparáveis
- [ ] LCP da tela de conversas melhorou de forma mensurável (meta: < 2,5s em conexão média)
- [ ] Bundle principal reduzido vs baseline (meta: −20% ou justificativa por escrito)
- [ ] Zero N+1 conhecido nas telas principais
- [ ] Raiz do repo limpa; build e specs verdes

## Como fatiar para o agente de código (1 tarefa = 1 PR)

1. "Rode o diagnóstico da etapa 0.1 e escreva `docs/perf-baseline.md`. Não altere código de produção."
2. "Com base no baseline, corrija APENAS o item X (ex.: deduplicação do CSS do tema). Meça de novo e reporte antes/depois."
3. Repetir o padrão por item, do maior impacto para o menor.
