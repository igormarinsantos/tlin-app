# Fase 1 — MVP vendável (Starter) — v2 pós-auditoria

**Objetivo:** cliente Starter conecta o WhatsApp, configura via formulário e tem SDR + Agendamento funcionando com handoff humano↔IA e pipeline de deals. Isso é o que se vende.

**Iniciar em paralelo no dia 1 da fase (processo demorado, não depende de código):** cadastro do app no Google Cloud Console e submissão à verificação OAuth (escopo Calendar). Se só iniciar quando chegar na etapa 1.5, trava a fase.

## Etapa 1.1 — Fundação da engine (`lib/tlin/agents/`)

- `Tlin::Agents::Runner`: recebe evento de mensagem, resolve qual agente atende, monta contexto (histórico + config da conta + estado do deal), chama o LLM via `ruby_llm`, executa tools, responde.
- **Robustez de conversa (obrigatório, não opcional):**
  - **Debounce:** aguardar N segundos (config, default ~6s) após a última mensagem do lead antes de processar; agrupar mensagens acumuladas num único turno.
  - **Trava por conversa:** no máximo 1 execução do Runner por conversa por vez (lock via Redis/Sidekiq); eventos duplicados de webhook são deduplicados por message_id.
  - **Áudio (opcional por conta):** toggle na config. Ligado → transcrição (Whisper ou equivalente) entra no contexto como texto e debita créditos. Desligado → áudio gera notificação pro humano assumir. A IA nunca responde em áudio.
- **Freios de custo (obrigatório):**
  - Limite de turnos de IA por conversa por hora (default ~20) → excedeu, handoff com motivo "limite".
  - Orçamento mensal de tokens por conta com corte automático + alerta ao admin.
  - Kill switch global e por conta (flag que silencia toda IA imediatamente).
- `Tlin::Agents::BaseAgent`: prompt base fixo + interpolação da config do cliente + tools permitidas + condições de saída.
- `Tlin::Agents::Toolbox`: registro de tools com schema JSON. Tools iniciais: `update_contact_attributes`, `add_label`, `create_or_update_deal`, `move_deal_stage`, `set_loss_reason`, `check_availability`, `book_slot`, `handoff_to_human(reason)`, `register_opt_out`.
- Guardrails no prompt base: nunca tratar contrato/jurídico; desconto só dentro do limite; informação não presente na config/FAQ → NUNCA inventar (especialmente preço) → handoff; em dúvida → handoff; respeitar pedido de parar contato.
- **Captura de atribuição (crítico — se não gravar na entrada, perde pra sempre):** ao criar conversa/contato vindo de anúncio Click-to-WhatsApp, gravar os dados de referral do webhook Meta (campanha, anúncio, ctwa_clid) e utm quando houver, no contato e propagado ao deal. Envio de conversões pras plataformas fica na Fase 2; a captura começa aqui.
- **Opt-out:** palavras de saída (parar/sair/cancelar, configurável) → `register_opt_out` no contato; contato com opt-out nunca recebe mensagem ativa (lembrete, follow-up, campanha).
- Toda execução logada em `agent_runs`: modelo, tokens, tools, latência, custo estimado.
- **Sistema de créditos (núcleo do modelo de negócio):**
  - Ledger imutável `credit_transactions` (concessão mensal, compra, débito por uso) + saldo derivado por conta.
  - Tabela interna de custo em créditos por ação (turno de agente, transcrição, mensagem ativa) — configurável sem deploy.
  - Débito automático a cada execução; `agent_runs` guarda também o custo real em USD (margem visível por cliente em painel interno).
  - Alertas em 80% e 100% da cota; saldo zerado → IA para graciosamente (conversas novas → humano com aviso no painel; nada de lead no vácuo). Compra avulsa de créditos via painel (checkout pode ser manual/link nesta fase; automação de billing fica pra Fase 2).
- **Relação com Captain:** ativar um agente tlin numa inbox desativa o Captain nela (regra do plano mestre). A engine tlin é independente do Captain.

## Etapa 1.1b — Sistema de planos tlin (estrutura mínima)

- Model `TlinPlan` por conta: nome do plano, feature flags (agentes habilitados, tools, campanhas), limites (inboxes, usuários) e cota mensal de créditos (integra com o ledger).
- Mês 1: um único plano "Piloto" com tudo do Starter; a estrutura de flags/limites já existe e é checada pela engine, o gating comercial completo (Starter×Scale) entra quando houver 2º plano à venda.
- Super admin gerencia: criar conta, atribuir plano, conceder créditos, kill switch por conta.

## Etapa 1.2 — Controle humano↔IA

- Estado por conversa: `ai_active` / `human_active` / `ai_paused`.
- Mensagem de agente humano em conversa `ai_active` → `human_active` automático (IA silencia).
- "Devolver para IA" → IA gera resumo interno do trecho humano e retoma.
- `handoff_to_human`: notifica time, registra motivo, muda estado.
- Toggle por inbox: IA ligada/desligada.

## Etapa 1.3 — CRM: Deals + pipeline (100% próprio; não usar o kanban licenciado da fazer.ai)

- Models: `Pipeline` (estágios ordenados configuráveis por conta), `Deal` (contact, pipeline, stage, valor opcional, owner humano ou `ai`, loss_reason, timestamps por estágio).
- Deal criado pela tool do SDR quando identifica interesse (não em toda conversa). Humanos também criam/movem deals manualmente pela UI — o CRM é completo sem IA.
- Kanban simples (Vue): colunas = estágios, drag manual, badge "movido pela IA".
- Vínculo deal ↔ conversa.

## Etapa 1.4 — Agentes SDR e Agendamento (Starter)

- **SDR:** perguntas de qualificação da config (campo: pergunta + tipo + obrigatoriedade), grava atributos, contorna objeções via config, decide qualificado/desqualificado por critérios configurados, cria deal e passa pro Agendamento ou encerra com motivo.
- **Agendamento (v1):** Google Calendar (OAuth por conta): `check_availability`, `book_slot` (cria evento + confirmação na conversa), reagendamento. **Timezone configurável por conta** aplicado em toda lógica de horário. Lembrete 24h/2h via template Meta, respeitando opt-out. (Motor de agenda próprio: Fase 2.)
- **Triagem embutida:** primeiro turno classifica intenção (lead / cliente / suporte / outro); só lead segue pro SDR.

## Etapa 1.5 — Configuração + Playground

- **v1 = formulário estruturado** (sem geração por IA): dados do negócio, tom, perguntas de qualificação, critérios, serviços/durações, horários, timezone, limites de desconto, assuntos proibidos, palavras de opt-out, e **seção de FAQ do negócio** (pergunta + resposta oficial) que entra no contexto dos agentes — é a fonte única de respostas factuais (preço, condições, políticas). O que não está na FAQ, o agente não afirma. Wizard com IA gerando config fica pra fase futura — os primeiros clientes serão configurados com acompanhamento (e isso é bom: é pesquisa de produto).
- **Playground (inegociável):** chat de teste contra o agente configurado antes de ativar na inbox real, obrigatório no fluxo de ativação.

## Suíte golden de conversas (prática permanente a partir daqui)

Roteiros fixos rodados a cada mudança de prompt/engine: lead ideal (fluxo completo), lead que manda 5 mensagens picadas, lead que manda áudio, lead grosso, lead que pede desconto acima do limite, lead que pergunta de contrato, lead que tenta prompt injection ("ignore suas instruções..."), lead que pede pra parar. Mudança de prompt sem a suíte verde não entra.

## Critérios de aceite da fase

- [ ] Ponta a ponta: lead entra → triagem → SDR qualifica → deal criado/movido → reunião no Google Calendar → confirmação enviada
- [ ] 5 mensagens picadas em 10s → UMA única resposta da IA (debounce + lock)
- [ ] Áudio de voz é transcrito e respondido corretamente
- [ ] Humano assume e devolve; IA retoma coerente
- [ ] IA transfere ao ser questionada sobre contrato; resiste ao roteiro de prompt injection sem vazar instruções nem violar limites
- [ ] "Parar" → opt-out registrado; nenhum lembrete/mensagem ativa é enviada depois
- [ ] Limite de turnos e kill switch funcionando (teste automatizado)
- [ ] Contador de conversas IA/mês batendo com a realidade
- [ ] Latência média de resposta < 15s no ambiente de teste
- [ ] Nenhuma resposta enviada quando estado ≠ `ai_active` (teste automatizado)
- [ ] Suíte golden verde
- [ ] Formulário de config gera agente funcional pra 2 negócios diferentes (clínica e agência)
- [ ] Lead perguntando preço que NÃO está na FAQ → agente não inventa, faz handoff (roteiro na suíte golden)
- [ ] Conversa simulada de anúncio CTWA → atribuição gravada no contato e no deal

## Fatiamento (1 tarefa = 1 PR)

1. Models + migrations `Deal`/`Pipeline`/`agent_runs`/opt-out/`TlinPlan` (sem UI)
2. Estados humano↔IA + pausa automática (specs)
3. Runner com debounce + lock + dedupe (agente fake nos testes, sem LLM)
4. Sistema de créditos (ledger + débitos + alertas + parada graciosa) + freios de custo + kill switch
5. Toolbox + tools de CRM
6. Agente SDR + prompts base + suíte golden inicial
7. Transcrição de áudio na recepção
8. Google Calendar + agente de Agendamento + timezone
9. Kanban de deals
10. Formulário de config + playground
11. Devolver-para-IA com resumo
