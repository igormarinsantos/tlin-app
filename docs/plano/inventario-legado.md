# Inventário do legado — chatwoot-tlin

**Base comparada:** `v4.11.0-fazer-ai.30` (`fdde54f1a2c90dacc02721489a35cfa25a9cfd60`)

**Import atual:** `HEAD` da branch `main`. Este inventário foi produzido a partir de `git diff --stat v4.11.0-fazer-ai.30 HEAD` e da leitura dos arquivos referenciados. Caminhos marcados como removidos descrevem algo que existia na base e foi deliberadamente retirado deste import.

## A) ASSETS DE MARCA

| Grupo | Estado e caminhos |
| --- | --- |
| Logos principais | Alterados: `public/brand-assets/logo.svg`, `public/brand-assets/logo_dark.svg`, `public/brand-assets/logo_thumbnail.svg`; `app/javascript/dashboard/components-next/icon/Logo.vue`; `app/javascript/dashboard/assets/images/lock.svg`. |
| Favicons/PWA | Adicionados ou substituídos: `public/favicon.ico`, `public/favicon.svg`, `public/favicon-96x96.png`, `public/apple-touch-icon.png`, `public/web-app-manifest-192x192.png`, `public/web-app-manifest-512x512.png`, `public/manifest.json`. Os antigos `public/favicon-{16x16,32x32,512x512}.png`, `public/favicon-badge-*`, `public/apple-icon*`, `public/android-icon-*` e `public/ms-icon-*` foram removidos. |
| Login e imagens de segmento | Adicionados: `public/login/academia.png`, `assistencia-tecnica.png`, `clinicas.png`, `delivery.png`, `empreendedor.png`, `escolas.png`, `escritórios.png`, `estética.png`, `imobiliária.png`; usados pelo login em `app/javascript/v3/views/login/Index.vue`. |
| Ilustrações de produto | `public/dashboard/images/integrations/captain*.png` foi renomeado para `tlin*.png`; alterados/adicionados `public/dashboard/images/agent-bots/webhook.svg`, `app/javascript/widget/assets/images/defaultUser.png`, `message-send.svg`, `send.png`. O pacote grande de imagens genéricas de `public/assets/images/` foi removido do import. |
| Canais e integrações | Adicionado `public/google calendar.png`. Assets de canal, prioridade, editor, perfil e Z-API sob `public/assets/images/dashboard/` foram removidos junto com a cópia estática legada. |
| Fontes | Não há arquivos de fonte adicionados (`woff`, `woff2`, `ttf`, `otf`). A marca passa a requisitar **DM Sans** por CSS/Tailwind; o carregamento depende da cadeia já existente da aplicação, não de um asset local novo. |

## B) TOKENS VISUAIS

Fontes de verdade: `theme/colors.js`, `tailwind.config.js`, `app/javascript/dashboard/assets/scss/_tlin_custom.scss`, `_base.scss`, `_next-colors.scss`, `_woot.scss` e `super_admin/index.scss`. `theme/colors.js` continua delegando as escalas históricas ao pacote `@radix-ui/colors`; abaixo estão os valores explícitos introduzidos/consumidos pela marca, não uma falsa expansão dos tokens dinâmicos do Radix.

| Categoria | Token/valor consolidado | Onde aparece |
| --- | --- | --- |
| Marca | `#B597FF` (lilás), `#38E3FF` (ciano) | `theme/colors.js` (`n.brand` é `#B597FF`), `tailwind.config.js`, `_tlin_custom.scss` |
| Gradiente primário | `linear-gradient(135deg, #B597FF 0%, #38E3FF 100%)` | `tlin-gradient`, `bubble-gradient`, `login-button-gradient`, `bg-tlin-gradient`, borda premium |
| Gradiente animado | `linear-gradient(90deg, #38E3FF, #B597FF, #38E3FF)` | `tlin-shiny-gradient`; animações `tlin-gradient-move` e `shine` |
| Fundo/contraste | `#FFFFFF`, `#000000`; texto de bolha de marca força preto e bolha recebida no dark força branco | `_tlin_custom.scss`, `theme/colors.js` (`n.black`) |
| Grade e blobs | Lilás/ciano em `rgba(181,151,255,.05)` e `rgba(56,227,255,.05)`; blobs em `#B597FF`/`#38E3FF`, opacidade `.15`, blur `100px` | `_tlin_custom.scss` |
| Paleta estrutural | Escalas `woot`, `green`, `yellow`, `slate`, `black`, `red`, `violet` vêm de `@radix-ui/colors`; tokens `n.*` são variáveis CSS RGB (`--slate-*`, `--iris-*`, `--surface-*`, `--solid-*`, bordas e texto) | `theme/colors.js` |
| Tipografia | `DM Sans`, depois `-apple-system`, `system-ui`, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, Tahoma, Arial, sans-serif; alternativas `Inter` e `InterDisplay` | `tailwind.config.js`, `_base.scss`, `super_admin/index.scss` |
| Pesos/tamanho | Pesos extras 420, 440, 460 e 520; `xxs = .625rem`; texto de bolha 14px/line-height 1.6 | `tailwind.config.js` |
| Raios | Não foi introduzida uma escala global nova. O CSS próprio usa círculo `50%`, herda o raio na `.premium-border`, e mantém raios do core de `4px` (code) e `6px` (pre) | `_tlin_custom.scss`, `tailwind.config.js` |
| Sombras | Não há token ou `box-shadow` de marca introduzido; o efeito de destaque é gradiente na pseudoborda, não sombra | `_tlin_custom.scss` |

**Observação de migração:** `_tlin_custom.scss` contém muitos `!important` e seletores globais que forçam cor de descendentes. Ele é um override visual legado, não deve ser levado literalmente para a base limpa.

## C) CÓDIGO FUNCIONAL A MIGRAR

Itens abaixo são a parte não visual e não IA identificada no diff. Cada linha descreve o comportamento e suas dependências diretas; incluir a migração de banco e as rotas correspondentes quando aplicável.

| Item | O que faz; arquivos de implementação/dependência |
| --- | --- |
| Proxy de webhook Meta | Solução operacional externa para perdas de conexões da AS32934: nginx TLS recebe `/<upstream_host>/webhooks/whatsapp/...`, valida o host em allowlist e encaminha GET/POST preservando caminho e query. Especificação e instalação: `META-WEBHOOK-PROXY.md`; não há código Rails correspondente. |
| Pipelines/Kanban | Cria pipelines por conta, API de pipelines e UI Kanban/agenda (colunas, cartões, seleção de lead e modal de agendamento). Depende de `app/models/pipeline.rb`, `app/controllers/api/v1/accounts/pipelines_controller.rb`, `db/migrate/20260224021000_create_pipelines.rb`, `20260224022000_migrate_legacy_pipeline_data.rb`, `20260518191436_add_color_to_pipelines.rb`, `app/javascript/dashboard/routes/dashboard/kanban/` e store/API `pipelines`. |
| Agenda clínica (estado final) | Foram criadas e depois removidas as tabelas de agenda clínica; preserve somente a decisão/necessidade se for reimplementar, pois o estado final é remoção. Histórico: `20260225112000_create_clinic_agenda_tables.rb`, `20260225120000_update_clinic_agenda_tables.rb`, `20260225140000_drop_clinic_agenda_tables.rb`; modelos relacionados ainda alterados: `appointment.rb`, `availability_block.rb`, `hold.rb`, `procedure.rb`, `professional.rb`, `resource.rb`. |
| Rotas Agenda e Inbox dashboard | Expõe visão de agenda e dashboard de inbox, com componentes de calendário e painel operacional. Depende de `app/javascript/dashboard/routes/dashboard/agenda/`, `routes/dashboard/inbox/InboxDashboard.vue`, `routes/index.js`, `dashboard.routes.js` e `conversation.routes.js`. |
| CSAT por template | Permite escolher template existente, configura templates de CSAT por inbox e altera envio/registro da pesquisa. Depende de `app/controllers/api/v1/accounts/inbox_csat_templates_controller.rb`, `app/services/csat_template_management_service.rb`, `app/services/whatsapp/csat_template_service.rb`, `app/services/csat_survey_service.rb`, `app/models/csat_survey_response.rb`, `app/models/channel/whatsapp.rb`, `app/controllers/api/v1/accounts/inboxes_controller.rb` e `CustomerSatisfactionPage.vue`/`ExistingTemplateSelector.vue`. |
| Integração Google Calendar | Acrescenta entrada e tela de integração de calendário (inclui asset). Depende de `app/javascript/dashboard/routes/dashboard/settings/integrations/Calendar.vue`, `integrations.routes.js`, `Index.vue`, `public/google calendar.png` e `config/integration/apps.yml`. |
| Dados de contato/mensagem | Amplia serialização e atributos usados pelo produto (contact, conversation drop, message builder, janela de mensagens e reporting/outbox). Depende de `app/models/contact.rb`, `message.rb`, `custom_attribute_definition.rb`, `reporting_event.rb`, `outbox_event.rb`, `app/drops/conversation_drop.rb`, `app/builders/messages/message_builder.rb`, `app/services/conversations/message_window_service.rb` e `contacts_controller.rb`. |
| Autenticação e administração | Ajusta sessões Devise, permissões/dados de super-admin, dashboard e configurações de instalação. Depende de `app/controllers/devise_overrides/sessions_controller.rb`, `app/controllers/super_admin/{application_controller,dashboard_controller,app_configs_controller}.rb`, `app/controllers/super_admin/devise/sessions_controller.rb`, `app/models/{super_admin,user,installation_config}.rb`, `lib/global_config*.rb`, `lib/chatwoot_turnstile.rb` e locais/configs relacionados. |
| Mensageria WhatsApp/Meta | Alterações na entrega/recebimento oficial WhatsApp e no job de eventos webhook; migrar após comparar contrato com a nova base. Depende de `app/jobs/webhooks/whatsapp_events_job.rb`, `app/services/whatsapp/send_on_whatsapp_service.rb`, `app/services/whatsapp/send_on_whatsapp_service.rb`, `app/models/channel/whatsapp.rb` e `app/services/email/send_on_email_service.rb`. Não confundir com ZAPI, que está em “Não migra”. |
| Deploy/containers | Personaliza imagem, compose normal e Coolify, entrypoints Rails/Vite e cálculo da URL PostgreSQL; leva também `.dockerignore`, `.env.example` e `deployment/extract_brand_assets.sh`. Arquivos: `docker/Dockerfile`, `docker-compose.yaml`, `docker-compose.coolify.yaml`, `docker/entrypoints/{rails,vite}.sh`, `docker/entrypoints/helpers/pg_database_url.rb`, `vite.config.ts`. |
| Configuração de produto | Recursos, rotas, configurações de instalação/LLM e apps de integração foram alterados; migrar seletivamente, sem transportar a engine Tlin desta seção. Arquivos: `config/{features,installation_config,llm}.yml`, `config/routes.rb`, `config/integration/apps.yml`, `config/vite.json`, `app/models/{account,campaign,integrations/hook}.rb`, `lib/chatwoot_hub.rb`. |

## D) NÃO MIGRA

| Grupo | Exclusão |
| --- | --- |
| CSS visual duplicado | `app/javascript/dashboard/assets/scss/_tlin_custom.scss` e os overrides em `_base.scss`, `_next-colors.scss`, `_woot.scss`, `super_admin/index.scss`: são globais/duplicados, carregados de `!important` e devem ser redesenhados com tokens da nova base. |
| Core editado apenas por aparência | Alterações de cor, logo, classes, layout e texto de marca em `app/javascript/dashboard/components-next/`, `components/`, `widgets/`, `routes/`, `app/javascript/v3/`, `app/javascript/widget/`, assets e i18n visual. Reaproveitar somente a intenção de UI, não os patches. |
| ZAPI removida | Não reconstruir: canal e handlers ZAPI foram removidos (`app/jobs/channels/whatsapp/zapi_*`, `app/services/whatsapp/{incoming_message_zapi_service,providers/whatsapp_zapi_service,zapi_handlers/}`, `ZapiWhatsapp.vue` e specs/ícones correlatos). |
| Clinic removida | Não copiar a implementação de agenda clínica nem restaurar tabelas removidas; ver as três migrations de criar/alterar/remover em C. |
| Rascunhos/diagnósticos na raiz | Não migrar: `check_gems.rb`, `erp_architecture_plan.md.resolved`, `get_logs.rb`, `grep_captain_utf8.txt`, `test_ruby_llm.rb`, `Tlin_FRONTEND_SKILL.md`, nem diretórios avulsos `files/`, `scratch/` e o artefato `files.zip`. |
| Renomeação Captain → Tlin | Não copiar o renomeio mecânico em APIs, stores, rotas, modelos e specs. A nova engine deve nascer com contrato próprio; esta árvore é apenas referência comportamental abaixo. |

## E) SPEC DA ENGINE EXISTENTE

**Limite de licença:** esta seção descreve o comportamento observado. O código em `enterprise/lib/tlin/` não deve ser copiado para a nova base; `lib/tlin/` é a camada comunitária de chamadas/tarefas que completa o mesmo comportamento.

### Renderização, prompts e contrato

| Artefato | Especificação comportamental |
| --- | --- |
| `enterprise/lib/tlin/prompt_renderer.rb` | Carrega um `.liquid` de `enterprise/lib/tlin/prompts/`, converte chaves do contexto para string e o renderiza com Liquid. Entrada: nome e hash de contexto; saída: string de prompt, ou erro se o template não existir. |
| `enterprise/lib/tlin/prompts/assistant.liquid` | Prompt do orquestrador: recebe identidade, descrição, produto, cenários, guidelines, guardrails, conversa e contato. Prioriza handoff para cenário, consulta FAQ antes de fatos do produto e transfere para humano quando não resolve; saída esperada é uma resposta ou chamada de ferramenta. |
| `enterprise/lib/tlin/prompts/scenario.liquid` | Prompt do agente especializado: recebe título, instruções, nome do assistente, ferramentas, guidelines/guardrails e contexto. Trata o escopo do cenário e devolve ao orquestrador via handoff quando estiver fora do escopo. |
| `enterprise/lib/tlin/prompts/snippets/contact.liquid` | Fragmento de contexto de contato: ID, nome, email, telefone, identificador, tipo e atributos custom/adicionais. Entrada é o contato; saída é texto estruturado para interpolar no prompt. |
| `enterprise/lib/tlin/prompts/snippets/conversation.liquid` | Fragmento de conversa: display ID, contato, status, prioridade, labels e atributos custom/adicionais. Entrada é a conversa; saída é texto de contexto para o LLM. |
| `enterprise/lib/tlin/response_schema.rb` | Schema RubyLLM de resposta estruturada com campos `response` e `reasoning`, ambos string. É o contrato de saída quando um fluxo solicitar resposta tipada. |

### Ferramentas públicas e HTTP

| Artefato | Especificação comportamental |
| --- | --- |
| `tools/base_public_tool.rb` | Base de ferramentas do assistente: armazena assistant, declara-se sempre ativa, localiza conversation/contact limitados a `account_id` e registra uso em log. Subclasses recebem estado da tool context e devolvem texto de sucesso/erro. |
| `tools/add_contact_note_tool.rb` | Entrada `note`; encontra o contato no contexto e cria `contact.notes`. Saída: confirmação com nome/ID, ou “Contact not found”/conteúdo ausente; requer `contact_manage`. |
| `tools/add_label_to_conversation_tool.rb` | Entrada `label_name`; normaliza para minúsculas, busca label da conta e a associa à conversa contextual. Saída: confirmação com display ID, ou erro de conversa/label/nome ausente. |
| `tools/add_private_note_tool.rb` | Entrada `note`; cria mensagem outgoing e privada, associada a conta, inbox, assistant e conversa. Saída: confirmação/erro; requer permissões de gerenciamento de conversa. |
| `tools/faq_lookup_tool.rb` | Entrada `query`; executa busca semântica nos responses aprovados do assistant e formata pergunta/resposta, incluindo fonte externa exceto placeholder `PDF:`. Saída: bloco de FAQs ou mensagem de nenhum resultado. |
| `tools/handoff_tool.rb` | Entrada opcional `reason`; grava o motivo como nota privada, chama `bot_handoff!` e pode disparar template out-of-office (exceto campanha). Saída: confirmação para humano ou falha capturada. |
| `tools/update_priority_tool.rb` | Entrada `priority` (`low`, `medium`, `high`, `urgent` ou `nil`); valida contra enum de `Conversation` e atualiza a conversa contextual. Saída: prioridade confirmada ou lista de valores válidos; requer permissões de conversa. |
| `tools/http_tool.rb` | Encapsula uma custom tool habilitada: monta URL/body/headers/auth a partir dos parâmetros, aceita GET/POST e formata a resposta. Bloqueia IPs privados/loopback/link-local, timeout 10/30s, redirects e respostas >1 MB; saída é resposta formatada ou erro genérico. |

### Serviços de tarefas e observabilidade

| Artefato | Especificação comportamental |
| --- | --- |
| `lib/tlin/base_task_service.rb` | Base de tarefas LLM. Recebe conta e, opcionalmente, display ID da conversa; exige feature `tlin_tasks` e chave (hook OpenAI da conta ou InstallationConfig), normaliza endpoint `/v1`, escolhe provider/model, limita histórico a 400.000 caracteres e retorna `{message, usage, request_messages}` ou `{error, error_code}`. |
| `lib/tlin/reply_suggestion_service.rb` | Entrada: conta, conversa e usuário. Renderiza prompt `reply` com canal, nome e assinatura do agente e formata a conversa até o limite; saída é sugestão de resposta do LLM e contexto para refinamento. |
| `lib/tlin/summary_service.rb` | Entrada: conta e conversa. Envia prompt `summary` e `conversation.to_llm_text` sem detalhes de contato; saída é resumo e uso de tokens. |
| `lib/tlin/rewrite_service.rb` | Entrada: conta, conteúdo, operação e conversa opcional. Aceita correção ortográfica, melhoria ou tons casual/professional/friendly/confident/straightforward; usa prompts Liquid e devolve o texto reescrito ou erro de operação inválida. |
| `lib/tlin/label_suggestion_service.rb` | Entrada: conta e conversa. Com ao menos 3 mensagens recebidas e limites de volume, envia histórico + labels existentes ao prompt `label_suggestion`, remove prefixo “label(s):” e cacheia por conversa/última atividade no Redis; saída é sugestão ou erro. |
| `lib/tlin/follow_up_service.rb` | Entrada: conta, contexto de follow-up, mensagem do usuário e conversa opcional. Valida a ação original, recompõe original/resposta/histórico, pede refinamento conciso e devolve resposta com contexto atualizado; ações permitidas cobrem rewrite, summary, reply e labels. |
| `lib/tlin/tool_instrumentation.rb` | Instrumenta sessões com tools e gerações RubyLLM em OpenTelemetry/Langfuse quando habilitado. Entrada são metadados/mensagens/chat; saída preserva a resposta do fluxo e registra IDs, tags, input/output, tokens e erros sem quebrar a execução. |

### Dependências implícitas a reconstruir

- Os prompts de tarefa referenciados por `lib/tlin/` ficam fora de `lib/tlin`, em `lib/integrations/openai/openai_prompts/` (`reply`, `summary`, `fix_spelling_grammar`, `improve`, `tone_rewrite`, `label_suggestion`). A implementação nova precisa definir prompts equivalentes, não copiar os arquivos Enterprise.
- O contrato de tool context contém, no mínimo, `state[:conversation][:id]` e `state[:contact][:id]`; o escopo da conta é obrigatório antes de qualquer mutação.
- A integração suporta endpoint/chave/modelo por hook OpenAI da conta, com fallback para `TLIN_OPEN_AI_API_KEY`, `TLIN_OPEN_AI_ENDPOINT`, `TLIN_OPEN_AI_MODEL` e `TLIN_GEMINI_API_KEY` em `InstallationConfig`.
