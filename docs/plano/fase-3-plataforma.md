# Fase 3 — Plataforma

**Objetivo:** abrir o produto para parceiros e Enterprise. Detalhar quando a Fase 2 estiver aceita.

## Escopo

1. **Custom Tools**
   - Cliente/parceiro cadastra endpoint HTTP com schema de entrada/saída (JSON Schema) + descrição em linguagem natural → vira tool disponível para os agentes da conta.
   - Sandbox de teste da tool antes de ativar; timeout e retry padronizados; log de cada chamada em `agent_runs`.
   - Limites por plano: Scale 1–2 tools, Enterprise ilimitado.
   - Evolução futura: suporte a MCP para plugar ecossistema externo.
2. **API pública + webhooks (as portas da plataforma)**
   - **Princípio de arquitetura (vale desde a Fase 1):** a engine emite eventos internos de negócio e a UI tlin consome a própria API. A plataforma é essa arquitetura exposta pra fora — não uma construção paralela.
   - **API REST tlin** documentada (OpenAPI, aproveitando o swagger do repo): deals/pipelines, agendamentos, créditos (saldo/extrato), status e controle dos agentes, atribuição — além de proxy do que o Chatwoot já expõe. Endpoints de ação: criar/mover deal, agendar, enviar template, pausar/retomar IA numa conversa. Regra: tudo que a UI faz, a API faz.
   - **Webhooks de saída:** `lead.created`, `deal.created`, `deal.stage_changed`, `deal.won`, `deal.lost`, `meeting.booked`, `meeting.rescheduled`, `meeting.no_show`, `ai.handoff`, `contact.opted_out`, `credits.low`, `credits.exhausted`. Assinatura HMAC, retry com backoff, painel de logs de entrega com replay.
   - Chaves de API por conta com escopos granulares (read/write por recurso) e rate limit.
   - **MCP server tlin:** expõe a API tlin como tools pra agentes de IA externos (estrutura inspirada no mcp-chatwoot, que é MIT). Posiciona o tlin pro consumo por IA, não só por código.
   - **Conectores de conveniência (após demanda comprovada):** node n8n próprio, templates Zapier/Make — embalagem das portas acima, não integrações profundas.
3. **Modo copiloto**
   - IA não responde sozinha: sugere resposta no console e o humano aprova/edita/envia. Configurável por inbox. Ótimo para onboarding de cliente desconfiado e para nichos sensíveis.
4. **Multi-agente avançado**
   - Agentes adicionais criáveis pela equipe tlin para Enterprise (ex.: pós-venda, cobrança leve), reusando a mesma engine.

5. **Radar (avaliar quando chegar aqui, não antes)**
   - Tool `send_payment_link` (Pix/gateway) pro fechamento direto na conversa.
   - Embedded Signup da Meta: cliente conecta o próprio número WhatsApp self-service.
   - White-label pra agências parceiras (revenda com marca própria, casada com o modelo de créditos).

## Critérios de aceite (alto nível)

- [ ] Parceiro de teste integra uma tool custom ("consultar estoque" fake) e o agente a usa corretamente em conversa
- [ ] App externo cria deal via API e recebe webhook quando o deal move
- [ ] Inbox em modo copiloto: nenhuma mensagem sai sem aprovação humana
