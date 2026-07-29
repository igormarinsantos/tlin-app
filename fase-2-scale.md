# Fase 2 — Scale

**Objetivo:** transformar o MVP em máquina de receita recorrente: recuperar leads perdidos, campanhas ativas e visibilidade de resultado. Detalhar cada etapa só quando a Fase 1 estiver aceita (evitar plano detalhado que envelhece).

## Escopo

1. **Agente de Follow-up/Reengajamento**
   - Gatilhos: lead sumiu na qualificação (X horas), no-show de reunião, deal parado em estágio (Y dias), lead frio de campanha.
   - Fora da janela de 24h da Meta → SEMPRE via template aprovado. Tool `send_template(name, params)` + tool `schedule_followup(when, playbook)`.
   - Cadências configuráveis por conta (ex.: 3 toques em 7 dias, depois desiste e marca perdido).
2. **Campanhas**
   - Disparo em massa por segmento de contatos usando templates Meta, com resposta caindo direto no fluxo de triagem→SDR.
   - Controle de rate limit e qualidade (Meta pune número com muito bloqueio — throttling e opt-out obrigatórios).
2b. **Entrada de leads externos ("speed to lead")**
   - Endpoint público autenticado por conta pra receber leads de fora (formulário de site, landing page, Meta Lead Ads via webhook).
   - Cria contato + deal com atribuição (utm/origem do payload) e dispara abordagem ativa da IA via template Meta em segundos, caindo no fluxo normal de SDR quando o lead responde.
   - Respeita opt-out e créditos; falha de template → fila pro humano.
3. **Motor de agenda próprio**
   - Agenda por profissional/recurso, duração por serviço, buffers, bloqueios, sync bidirecional Google/Outlook. Substitui a v1 (Google-only) da Fase 1.
   - Lembretes automáticos 24h/2h antes via template; resposta de "quero remarcar" volta pro agente de Agendamento.
4. **Marketing / Conversões (envio pras plataformas)**
   - Cadastro de integrações por conta: Meta Conversions API (dataset + token) e Google Ads (conversões offline). Arquitetura extensível pra outras plataformas.
   - Mapeamento configurável estágio do deal → evento (ex.: Qualificado → Lead, Agendado → Schedule, Fechado → Purchase com valor do deal). Disparo automático quando o deal move (por IA ou humano).
   - Deduplicação por event_id; dados pessoais hasheados (SHA-256) conforme exigência das plataformas e LGPD.
   - Usa a atribuição capturada desde a Fase 1 (ctwa_clid/utm) pra fechar o ciclo: IA move deal → evento sobe → plataforma otimiza → lead melhor entra.
   - **Link rastreável tlin (site → WhatsApp):** redirect próprio que captura gclid/fbclid/utm do navegador, gera código curto na mensagem pré-preenchida do WhatsApp e casa com a conversa na primeira mensagem do lead. Obrigatório pro Google Ads (conversão offline exige gclid) e pra atribuição de leads vindos do site do cliente.
   - **Compatibilidade com plataformas de track de terceiros (UTMify e similares):** via webhooks de eventos de conversão (deal movido/agendado/fechado com atribuição no payload). Antecipar da Fase 3 os webhooks desses eventos se houver demanda de cliente.
5. **Base de conhecimento com documentos (RAG)**
   - Evolução da FAQ da Fase 1: upload de documentos (cardápio, tabela de serviços, políticas) indexados pra consulta dos agentes, mantendo o guardrail "não achou → não inventa → handoff".
6. **Relatórios**
   - Funil: recebidos → qualificados → agendados → compareceram → fechados, por período e **por origem/campanha/anúncio** (via atribuição capturada).
   - Motivos de perda agregados (registrados pela IA).
   - Métricas da IA: taxa de handoff, motivo de handoff, tempo médio de resposta, custo em tokens por conversa.

## Critérios de aceite (alto nível)

- [ ] Lead que parou de responder recebe cadência via template e, ao responder, volta ao fluxo sem intervenção humana
- [ ] Campanha de teste disparada para segmento com opt-out funcionando
- [ ] Clínica de teste opera 2 profissionais com serviços de durações diferentes sem conflito de agenda
- [ ] Dashboard de funil batendo com os dados de deals
- [ ] Deal movido pra Fechado → evento Purchase recebido no Gerenciador de Eventos da Meta com valor e dedup corretos
- [ ] Lead de teste vindo de link rastreável com gclid → conversão offline registrada no Google Ads
- [ ] Lead enviado via endpoint externo → abordado pela IA por template em < 60s e qualificado ao responder
