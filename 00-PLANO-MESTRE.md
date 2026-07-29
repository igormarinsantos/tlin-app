# TLIN — Plano Mestre Definitivo

> Documento único que define o produto amplamente. Substitui versões anteriores e consolida todas as decisões.
> Detalhes de execução: `fase-0` a `fase-3` + `cronograma-mes-1.md`. Em sessões de agente de código: carregar este arquivo + o da fase atual.
> Regra de vida do documento: quando a realidade contradisser o plano, atualizar o plano no mesmo dia.

---

## 1. Visão e posicionamento

**O que é:** plataforma comercial com IA — um CRM omnichannel (WhatsApp oficial nativo) onde agentes de IA trabalham como time comercial: qualificam leads, agendam, fazem follow-up, movem o pipeline e reportam conversões pras plataformas de anúncio. O dono abre o kanban e vê a máquina vendendo.

**Pra quem:** negócios brasileiros que vivem de lead no WhatsApp — clínicas, serviços, agências, comércio local — qualquer nicho via configuração, nunca via código.

**Diferencial (o pacote, não a peça):** concorrentes vendem peças (chatbot, ou kanban, ou disparo). O tlin vende a máquina montada: agentes prontos + CRM nativo + agenda + atribuição de marketing de ponta a ponta + controle humano total. E funciona como CRM completo mesmo com a IA desligada.

**O que a IA nunca faz:** contratos, jurídico, desconto fora do limite configurado, inventar informação (especialmente preço), contatar quem pediu opt-out.

## 2. Produto — as 10 verticais

1. **Atendimento omnichannel** — chassi Chatwoot: conversas, inboxes, times, multi-conta. WhatsApp oficial (Cloud API) como canal principal.
2. **Agentes de IA** — Triagem (roteia intenção), SDR (qualifica + objeções, funde o papel de qualificador), Agendamento, Follow-up/Reengajamento. Agente = prompt base fixo + config do cliente + tools + gatilhos. Nicho é config, nunca fork de prompt.
3. **CRM próprio** — Deal (valor, estágio, dono humano/IA, motivo de perda) + Pipeline configurável + kanban. Agentes movem deals sozinhos; humanos também operam 100% manualmente.
4. **Agendamento** — v1: Google Calendar por conta. v2: motor próprio (multi-profissional, serviços, buffers, sync bidirecional). Lembretes por template respeitando opt-out. Timezone por conta.
5. **Follow-up e campanhas** — cadências configuráveis (lead sumido, no-show, deal parado), disparos por segmento, sempre via template fora da janela de 24h, com throttling e opt-out.
6. **Marketing/conversões** — captura de atribuição na entrada (CTWA, utm, link rastreável próprio com gclid/fbclid pra lead vindo de site), envio server-side (Meta CAPI, Google Ads offline) mapeando estágio→evento com dedup e hash. Entrada de leads externos ("speed to lead"): form/Lead Ads → IA aborda por template em segundos.
7. **Base de conhecimento** — v1: FAQ na config como fonte única de fatos (não está lá → não afirma → handoff). v2: RAG com documentos.
8. **Créditos e billing** — ver §4.
9. **Plataforma aberta** — ver §6.
10. **Relatórios** — funil por período/origem/campanha, motivos de perda, métricas da IA (handoff, latência, custo), margem por cliente (interno).

## 3. Controle humano ↔ IA (feature central)

- Estados por conversa: `ai_active` / `human_active` / `ai_paused`. Conversa nova nasce com IA ativa (se plano/créditos permitem).
- Humano digitou → IA silencia na hora. "Devolver pra IA" → retoma com resumo do trecho humano.
- IA transfere sozinha: pedido explícito, frustração, assunto proibido, limite de turnos.
- Toggle por inbox; kill switch por conta e global. Futuro: modo copiloto (IA sugere, humano aprova).

## 4. Modelo de negócio

**Planos (entidade TlinPlan própria — o sistema de planos do Chatwoot não existe pra nós):**

| | Starter | Scale | Enterprise |
|---|---|---|---|
| Agentes | SDR + Agendamento | + Follow-up | Todos + custom |
| Campanhas/conversões | — | Sim | Sim |
| Tools custom | — | 1–2 | Ilimitadas |
| Créditos IA/mês | Cota | Cota maior | Negociado |
| Config | Formulário self-service | + ajuste fino | Onboarding tlin |

**Créditos (o motor de receita):** crédito é unidade abstrata tlin, nunca token cru. Tabela interna de custo por ação (turno, transcrição, mensagem ativa) ajustável sem mudar preço do cliente. Ledger imutável (concessão mensal expira no ciclo; compra avulsa não expira). Alertas 80/100%; zerou → IA para graciosamente, conversas vão pro humano, CRM segue 100%. Margem alvo: ≥3-4x o custo real (câmbio, conversa longa, retrabalho). `agent_runs` loga custo USD real → painel de margem por cliente. Motor: OpenAI via `ruby_llm` (provider abstraído; modelo barato pra triagem, superior pro SDR; troca é config).

## 5. Arquitetura — chassi e carroceria

**Chassi (Chatwoot community, fork fazer.ai):** conversas, inboxes, contatos, multi-conta, WhatsApp Cloud API nativo, scheduled messages. Atualiza pelo upstream pra sempre.

**Carroceria (código tlin, 100% próprio):** engine de agentes (`lib/tlin/agents/`), TlinPlan, créditos, Deal/Pipeline, agenda, marketing, plataforma. Todo o valor e a PI são nossos.

**Decisões estruturais:**
- Engine no Rails com `ruby_llm`, isolada com interface limpa (extraível pra serviço próprio se escalar).
- Captain: desativado por feature flag (UI + rotas). Nunca deletar código de core/enterprise — deletar quebra merges do upstream.
- **Modo community é regra legal inegociável:** `enterprise/` tem licença comercial da Chatwoot Inc.; nenhuma feature enterprise executa. LICENSE MIT preservado. Zero marca/upsell Chatwoot na experiência (via branding vars + tema).
- Mudança visual só via tema/tokens; nunca editar componente core por estética.
- Robustez de conversa é fundação: debounce (~6s, agrupa mensagens picadas), trava por conversa, dedupe de webhook por message_id. Áudio: transcrição opcional por conta (debita créditos; desligado → humano).
- Freios de custo sempre: limite de turnos/conversa/hora, orçamento de tokens por conta, kill switches.
- Engine emite eventos internos de negócio desde o dia 1; UI consome API própria. A plataforma pública é essa arquitetura exposta.
- Super admin = torre de controle do SaaS: contas, planos, créditos, kill switch.

## 6. Plataforma — as 6 portas

1. **API REST tlin** (chaves por conta, escopos, rate limit): deals, agenda, créditos, agentes, atribuição + ações (mover deal, agendar, enviar template, pausar IA). Regra: tudo que a UI faz, a API faz.
2. **Webhooks de saída** (HMAC, retry, logs, replay): lead.created, deal.stage_changed, deal.won/lost, meeting.booked/no_show, ai.handoff, contact.opted_out, credits.low/exhausted.
3. **Entrada de leads** — speed to lead (Fase 2).
4. **Custom Tools** — endpoint do cliente vira tool do agente (schema + sandbox + timeout; SSRF e segredos tratados).
5. **MCP server tlin** — a API como tools pra IAs externas.
6. **Conectores** (n8n, Zapier/Make) — após demanda comprovada.

## 7. Regras permanentes de engenharia e segurança

- 1 tarefa = 1 PR; revisão e commit entre tarefas; sem refatoração fora de escopo.
- Suíte golden de conversas (lead ideal, picado, áudio, grosso, desconto, contrato, prompt injection, opt-out) verde antes de qualquer mudança de prompt/engine.
- Opt-out é sagrado. LGPD: dados hasheados nos envios de conversão, consentimento registrável.
- Toolbox de produção é curada e mínima (guardrails); acesso amplo (MCP interno, admin) nunca exposto a agente que fala com lead.
- Performance: medir antes e depois; sem número, sem merge.

## 8. Roadmap

- **Fase 0** — Rebase: fork limpo fazer.ai atual, portões (licenças, Cloud API vs proxy próprio), Captain off, SaaS-ficação/branding, IDV via tokens, baseline. → `fase-0-rebase.md`
- **Fase 1** — MVP piloto: engine + robustez + créditos + planos + humano↔IA + Deal/kanban + SDR + Agendamento (Google) + FAQ + atribuição + formulário + playground + golden. → `fase-1-mvp.md`
- **Fase 2** — Scale: follow-up + campanhas + speed to lead + conversões (CAPI/Google) + link rastreável + motor de agenda + RAG + relatórios + billing automatizado. → `fase-2-scale.md`
- **Fase 3** — Plataforma: API pública + webhooks + custom tools + MCP + copiloto + radar (pagamento na conversa, Embedded Signup, white-label). → `fase-3-plataforma.md`
- **Mês 1** (meta: piloto rodando): → `cronograma-mes-1.md`. Fases 2-3 detalham-se quando a anterior fechar.

## 9. Decisões abertas

- [ ] Preço dos planos e do crédito (decidir com custo real medido do piloto)
- [ ] Nome/posicionamento final dos planos
- (Resolvidas: cobrança=créditos; config=formulário; deal nasce na qualificação; instância atual é só dev → sem migração)

## 10. Congelamento de escopo

Ideia nova durante a execução → uma linha em `docs/plano/backlog-ideias.md`, revisada só na sexta de checkpoint. O plano reabre apenas quando a execução provar que ele está errado.
