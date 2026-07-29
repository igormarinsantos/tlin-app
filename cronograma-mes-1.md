# Cronograma — Mês 1 (meta: piloto rodando no mês que vem)

**Definição de "pronto":** 1-2 clientes piloto operando de verdade (WhatsApp conectado, SDR + Agendamento ativos, deals no kanban, handoff funcionando). NÃO é lançamento público.

**Disparar no dia 1 (independem de código, têm fila de terceiros):**
- [ ] Criar repo novo (fork fazer-ai/chatwoot atual)
- [ ] Cadastrar app no Google Cloud + iniciar verificação OAuth (piloto roda em modo teste sem verificação concluída)
- [ ] Submeter templates Meta (confirmação de reunião, lembrete 24h/2h) pra aprovação
- [ ] Escolher os 1-2 clientes piloto e combinar expectativa (produto em construção, acompanhamento próximo)

## Semana 1 — Fase 0 completa
- Portões 0.0: licenças no repo novo, teste da Cloud API nativa (decisão do proxy), Captain via flag OFF
- Inventário do repo antigo (tarefa 1) → revisão conjunta do que migra
- Repo novo rodando em dev + migração do funcional necessário
- IDV reaplicada via tokens — **timebox de 2 dias**: bom o suficiente pro piloto; refinamento estético é mês 2
- SaaS-ficação: modo community confirmado + branding tlin via variáveis + varredura de resíduos Chatwoot (etapa 0.4b — maior parte é config, cabe na semana)
- Baseline de performance + merge de teste do upstream

## Semana 2 — Fundação da engine
- Models: Deal/Pipeline/agent_runs/créditos/opt-out/TlinPlan (PR 1)
- Estados humano↔IA + pausa automática (PR 2)
- Runner + debounce + trava + dedupe, com agente fake nos testes (PR 3)
- Créditos: ledger + débito + kill switch (alertas: painel simples; e-mail fica pro mês 2) (PR 4)
- Toolbox + tools de CRM (PR 5)

## Semana 3 — Os agentes
- Agente SDR + prompts base + FAQ na config + suíte golden inicial (PR 6)
- Captura de atribuição CTWA/utm na entrada (PR 7 — pequeno, não adiar: dado perdido não volta)
- Google Calendar (modo teste) + agente de Agendamento + timezone (PR 8)
- Transcrição de áudio opcional (PR 9 — se a semana apertar, é O corte permitido; cai pro mês 2)

## Semana 4 — Fechar o piloto
- Kanban de deals (versão funcional; polish é mês 2) (PR 10)
- Formulário de config + playground (PR 11)
- Devolver-para-IA (v1 pode retomar sem resumo sofisticado) (PR 12)
- Ensaio geral: configurar um negócio real completo, rodar TODOS os critérios de aceite da Fase 1 e a suíte golden
- Onboarding do(s) piloto(s): config junto com o cliente, IA em produção com supervisão

## Cortes já decididos pro mês 2 (não discutir de novo durante a corrida)
Wizard com IA · motor de agenda próprio · follow-up/campanhas · envio de conversões (captura já feita) · RAG · relatórios além do básico · billing automatizado de créditos (mês 1: concessão e compra manuais) · polish visual

## Regras da corrida
- 1 tarefa por vez no Codex, revisão + commit entre cada uma. Sem exceção — retrabalho é o que mata prazo de 1 mês.
- Sexta-feira: checkpoint semanal (o que fechou, o que travou, replanejar sábado se precisar).
- Escopo novo durante o mês → anota no plano do mês 2, não entra na corrida.
- Critério de aceite reprovou → conserta antes de abrir tarefa nova.
