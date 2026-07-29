# Medição: fork vs merge (decisão fechada com dados)

Data: 25/07/2026 · Analisado por clone real dos dois repos.

## Números

- Repo atual (chatwoot-tlin): "initial import" de 16/05/2026, **sem histórico git compartilhado** com fazer-ai/chatwoot → merge é git-impossível (sem ancestral comum). 107 commits próprios.
- Base do import: idêntica byte a byte à tag **v4.11.0-fazer-ai.30** (import limpo).
- Mudanças nossas sobre a base: **882 arquivos** — 317 em app/javascript (core), 253 em enterprise/, 21 models, 12 migrations, 10 controllers; remoções de features do core (ZAPI, clinic).
- Upstream desde a nossa base: **4.946 arquivos** mudados (4.11 → 4.16; 5 versões atrás).
- Colisão direta (nós ∩ upstream): **242 arquivos**, incluindo controllers, builders, SCSS base.

## Descoberta crítica

Existe uma engine de IA tlin já prototipada em `enterprise/lib/tlin/` (prompts liquid, tools: handoff, faq_lookup, http_tool, add_label, update_priority...; services: follow_up, reply_suggestion, summary) + `lib/tlin/` (7 services). **Está dentro/derivada da pasta `enterprise/`, que tem licença comercial da Chatwoot Inc.** — inviável para uso comercial sem licença.

## Decisão

**RE-FORK confirmado** (fork verdadeiro de fazer-ai/chatwoot atual, com histórico):
1. Merge no repo atual é impossível (sem ancestral comum).
2. Colisão de 242 arquivos torna transplante manual proibitivo.
3. A engine atual precisa ser reconstruída como código limpo em `lib/tlin/agents/` de qualquer forma (licença) — conforme Fase 1 já previa.

## Consequências no plano

- Repo antigo = **gabarito duplo**: visual (IDV) e funcional (a engine prototipada vira especificação da Fase 1 — REFERÊNCIA DE COMPORTAMENTO, nunca cópia de código derivado de enterprise/).
- Inventário (PROMPT 1) ganha seção E: mapear a engine tlin existente (tools, prompts, services e o que cada um faz) como spec funcional.
- Regra reforçada: no repo novo, TODO código tlin vive fora de enterprise/ (lib/tlin/, app/ próprios), MIT-clean.
