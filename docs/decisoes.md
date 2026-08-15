# Decisões de base

## Etapa 0.0 — portões

### Dados de produção

Não há evidência versionada neste repositório que determine se a instância antiga possui dados reais. Antes de qualquer migração de banco, o responsável pela operação deve confirmar contas, conversas e números ativos; até essa confirmação, este clone é tratado como ambiente de desenvolvimento.

### Licenças

- O `LICENSE` raiz licencia o conteúdo fora de diretórios com exceção explícita sob **MIT Expat**.
- `enterprise/` é a exceção: `enterprise/LICENSE` é a **Chatwoot Enterprise License**. Ela permite desenvolvimento/teste, mas uso, distribuição e exploração em produção requerem assinatura Enterprise válida da Chatwoot. Nenhum código desse diretório será ativado pelo Tlin.
- Componentes de terceiros mantêm as respectivas licenças, conforme o `LICENSE` raiz.
- Não foi encontrado código funcional de kanban sob `enterprise/`. O que existe em `app/javascript/dashboard/routes/dashboard/kanban/` está no core MIT, mas é somente uma rota/tela de paywall que aponta para `https://fazer.ai/kanban`; não há implementação de CRM/kanban reutilizável nesta base. A rota e a entrada de sidebar não são registradas pelo Tlin, sem apagar os arquivos. Portanto, não usar essa tela como base: o Deal/Pipeline do Tlin será próprio.
- Scheduled Messages está fora de `enterprise/` e, portanto, é MIT nesta base. Principais arquivos: `app/models/{scheduled_message,recurring_scheduled_message}.rb`, `app/jobs/scheduled_messages/`, `app/services/scheduled_messages/`, `app/policies/{scheduled_message_policy,recurring_scheduled_message_policy}.rb`, `config/routes.rb` e `config/schedule.yml`.

### Captain desligado

O mecanismo padrão do fork para Enterprise é `ChatwootApp.enterprise?`: ele detecta a pasta `enterprise/` e pode ser desativado integralmente com `DISABLE_ENTERPRISE=true`. Para não precisar ativar ou remover Enterprise, foi criada a flag de boot `CAPTAIN_ENABLED`.

- Default: `false`; Captain permanece desligado mesmo se `enterprise/` existir.
- Para habilitar explicitamente (não permitido para o Tlin), seria necessário `CAPTAIN_ENABLED=true` e uma edição Enterprise ativa.
- `ChatwootApp.captain_enabled?` exige as duas condições: Enterprise disponível e a flag booleana verdadeira.
- Com a flag desligada, as rotas Rails `/api/v1/accounts/:account_id/captain/**` não são registradas no boot e as rotas Vue de Captain, inclusive Settings, não são registradas. O código permanece intacto para não dificultar sincronizações do fork.

### Copiloto SDR próprio

O Copiloto Tlin é uma integração OSS própria e não depende de Captain ou de `enterprise/`. A rota `POST /api/v1/accounts/:account_id/tlin_copilot` resolve a conversa exclusivamente por `Current.account`, autoriza a leitura dela e envia no máximo as últimas 30 mensagens públicas para a OpenAI. As skills ficam em `app/services/tlin_copilot/skill_registry.rb`; o serviço retorna apenas uma sugestão para o atendente copiar ou inserir manualmente, sem qualquer envio automático.

Configure `OPENAI_API_KEY` somente no ambiente do servidor. `TLIN_COPILOT_MODEL` é opcional e usa `gpt-4o-mini` por padrão; `TLIN_COPILOT_TIMEOUT_SECONDS` usa 20 segundos. Os logs estruturados `tlin_copilot.usage` registram conta, conversa, skill, modelo e tokens, sem conteúdo da conversa.
- `DISABLE_ENTERPRISE=true` continua sendo o kill switch mais amplo e deve permanecer definido nos ambientes Tlin que não precisam de qualquer overlay comercial.

### WhatsApp Cloud API e o proxy Meta

O provider oficial é `Whatsapp::Providers::WhatsappCloudService`, em `app/services/whatsapp/providers/whatsapp_cloud_service.rb`, selecionado por `Channel::Whatsapp#provider_service` quando `provider = 'whatsapp_cloud'`. O recebimento usa `Whatsapp::IncomingMessageWhatsappCloudService` e o canal cria/verifica o token de webhook em `app/models/channel/whatsapp.rb`.

Configuração de teste:

1. Em **Settings → Inboxes → Add Inbox → WhatsApp**, selecionar **WhatsApp Cloud** (`app/javascript/dashboard/routes/dashboard/settings/inbox/channels/CloudWhatsapp.vue`).
2. Usar Embedded Signup da Meta ou informar as credenciais manuais do app/Phone Number ID/token; para configuração manual o canal gera `webhook_verify_token` e registra webhook automaticamente.
3. No app Meta, apontar o callback público diretamente para o endpoint mostrado no passo final do inbox e assinar os eventos de mensagens; `WHATSAPP_CLOUD_BASE_URL` só é necessário para trocar o padrão `https://graph.facebook.com`.
4. Validar GET de verificação e uma mensagem de entrada/saída num número de teste antes de aposentar o nginx.

O provider cobre a Cloud API oficial, mas esta tarefa não realizou o teste externo com credenciais/número Meta. Por isso o proxy de `META-WEBHOOK-PROXY.md` do legado não deve ser aposentado ainda; a decisão depende desse teste de conectividade e entrega ponta a ponta.

## Branding e modo community

O fork deve sempre iniciar com `DISABLE_ENTERPRISE=true`. `ChatwootApp.enterprise?` retorna `false` com essa variável, mesmo com o diretório `enterprise/` presente; por isso os fluxos e extensões enterprise não são carregados.

Após exportar as variáveis de `.env`, executar `bundle exec rails branding:update`. Esse comando grava os seguintes valores em `InstallationConfig`:

| Chave | Valor Tlin |
| --- | --- |
| `INSTALLATION_NAME` | `Tlin` |
| `BRAND_NAME` | `Tlin` |
| `BRAND_URL` | `https://tlin.ai` |
| `WIDGET_BRAND_URL` | `https://tlin.ai` |
| `TERMS_URL` | `https://tlin.ai/termos` |
| `PRIVACY_URL` | `https://tlin.ai/privacidade` |
| `DISPLAY_MANIFEST` | `false` |

`HELPCENTER_URL=https://tlin.ai/ajuda`, `MAILER_SENDER_EMAIL=Tlin <suporte@tlin.ai>` e `SMTP_DOMAIN=tlin.ai` são configurações de ambiente. Os assets continuam nos caminhos oficiais de `CUSTOM_BRANDING.md`.

`DISPLAY_MANIFEST=false` também impede o `UpdateBanner`, cujo link aponta para as release notes da fazer.ai. `DISABLE_ENTERPRISE=true` faz a instância deixar de ser cloud/enterprise: o banner de pagamento, a tela de upgrade e a rota de billing permanecem indisponíveis pelas verificações existentes.

## Auditoria de resíduos de marca

Foi executado `rg -n -i -e 'chatwoot|upgrade|billing|pricing|woot\\.com'` em `app/javascript`, `app/views`, `config/locales/en.yml`, `config/locales/pt_BR.yml` e `app/mailers`. A busca bruta encontra 1.343 arquivos porque inclui fixtures, testes, SDK/widget e todas as traduções distribuídas; esses identificadores e exemplos não são texto exibido no produto Tlin e não foram alterados.

| Classe | Ocorrências e tratamento |
| --- | --- |
| a — configuração/flag | Branding e links: `.env.example` e os valores de `InstallationConfig` acima. Update/banner comercial: `app/javascript/dashboard/components/app/UpdateBanner.vue` é ocultado por `DISPLAY_MANIFEST=false`. Pagamento, upgrade e billing: `app/javascript/dashboard/components/app/PaymentPendingBanner.vue`, `app/javascript/dashboard/routes/dashboard/upgrade/UpgradePage.vue` e `app/javascript/dashboard/routes/dashboard/settings/billing/billing.routes.js` já exigem instalação cloud; ficam indisponíveis com `DISABLE_ENTERPRISE=true`. Captain e seus paywalls ficam fora pelo mesmo modo community. |
| b — exige core | Itens com texto/markup comercial que não possuem configuração: listados em `docs/divida-visual.md`; não foram editados. As URLs hard-coded de termos em `app/javascript/dashboard/i18n/locale/en/signup.json` e `app/javascript/dashboard/i18n/locale/pt_BR/signup.json` também exigem que o formulário core passe a usar `TERMS_URL`/`PRIVACY_URL` dinamicamente. |
| c — interno/técnico | APIs do widget (`window.chatwoot*`), constantes/classes `Chatwoot*`, nomes de eventos, testes, fixtures, comentários e textos de exemplo de SDK. Mantidos por compatibilidade e sem impacto na marca apresentada ao usuário. |

As ocorrências de localização en/pt-BR restantes se dividem em: textos de produtos enterprise (Captain, Kanban, billing, SAML, SLA, roles e relatórios), que não são alcançáveis em modo community; e textos de produto que ainda citam o nome upstream, registrados como dívida em vez de alterar componentes ou fluxos do core.

`LICENSE` na raiz permanece MIT e não foi alterado. `enterprise/LICENSE` também permanece intacto; nenhum código enterprise foi ativado por esta configuração.

## Build no Coolify

`docker/Dockerfile` trata a geração de `/app/.git_sha` como opcional: quando o
contexto de build do Coolify não inclui `.git`, grava `unknown` em vez de falhar.
Esta é uma divergência mínima e intencional do upstream; revalidar esse trecho em
todo merge futuro do upstream.

## Cadastro self-service e isolamento de contas

O cadastro público está habilitado somente no ambiente local com `ENABLE_ACCOUNT_SIGNUP=true` em `.env.development`. A configuração efetiva também está gravada como `InstallationConfig[ENABLE_ACCOUNT_SIGNUP]=true`: `GlobalConfigService.load` consulta primeiro essa configuração persistida e usa a variável de ambiente para inicializá-la quando não houver valor. `GlobalConfigService.account_signup_enabled?` libera o endpoint quando o valor não é `false`.

A tela `/app/auth/signup` envia `POST /api/v1/accounts.json`. `Api::V1::AccountsController#create` usa `AccountBuilder`, que cria uma `Account` nova e associa o novo `User` por `AccountUser` com papel `administrator`. O cadastro web anônimo retorna apenas o e-mail e exige confirmação antes de autenticar; não cria uma sessão automaticamente.

O isolamento é nativo por `account_id` e pela associação `current_user.accounts`. O controlador busca a conta com `current_user.accounts.find(params[:id])`, portanto uma conta fora da associação resulta em 404. Teste local: uma usuária criada pelo endpoint recebeu somente a nova conta e papel `administrator`; autenticada, obteve 200 na própria conta e 404 ao requisitar uma conta preexistente de outro tenant.
## Google OAuth

O login e cadastro com Google já são nativos do Chatwoot. A estratégia `google_oauth2` é carregada em `config/initializers/omniauth.rb`; as callbacks ficam em `app/controllers/devise_overrides/omniauth_callbacks_controller.rb`; e o mesmo `GoogleOauth/Button.vue` é usado pelas telas V3 de login e cadastro. Não foi criada uma integração Tlin paralela.

Configure estes valores somente no ambiente, nunca no Git:

| Variável | Desenvolvimento local | Produção |
| --- | --- | --- |
| `FRONTEND_URL` | `http://127.0.0.1:3001` | URL pública final do app, por exemplo `https://app.tlin.ai` |
| `GOOGLE_OAUTH_CLIENT_ID` | Client ID do cliente OAuth Web | Client ID do cliente OAuth Web de produção |
| `GOOGLE_OAUTH_CLIENT_SECRET` | Client secret correspondente | Client secret correspondente |
| `GOOGLE_OAUTH_CALLBACK_URL` | `http://127.0.0.1:3001/auth/google_oauth2/callback` | `${FRONTEND_URL}/auth/google_oauth2/callback` |
| `ENABLE_GOOGLE_OAUTH_LOGIN` | `true` | `true` |

`FRONTEND_URL` é a origem usada pelo middleware OmniAuth. O botão lê `GOOGLE_OAUTH_CLIENT_ID` e `GOOGLE_OAUTH_CALLBACK_URL` em `app/views/layouts/vueapp.html.erb`; ambos precisam estar preenchidos para aparecer. `GOOGLE_OAUTH_REDIRECT_URI`, embora exista na configuração de instalação upstream, não é lida por este fluxo; a variável efetiva do botão é `GOOGLE_OAUTH_CALLBACK_URL`.

### Google Cloud Console

1. Criar (ou selecionar) um projeto Google Cloud exclusivo para Tlin e configurar a tela de consentimento como **External**. Preencher nome Tlin, e-mail de suporte, contatos de desenvolvedor e as URLs públicas de página inicial, termos e privacidade em `tlin.ai`.
2. Em **Google Auth Platform → Audience**, adicionar os e-mails de teste enquanto o app estiver em modo Testing. Em **Data Access**, manter somente os escopos básicos de identidade; o fluxo atual solicita `email` e `profile`.
3. Em **Google Auth Platform → Clients**, criar um cliente OAuth do tipo **Web application**. Em *Authorized redirect URIs*, cadastrar a URL exatamente como abaixo, sem barra final: `http://127.0.0.1:3001/auth/google_oauth2/callback` para este ambiente local e, quando existir, `https://app.tlin.ai/auth/google_oauth2/callback` (substituir pelo host real de `FRONTEND_URL`) para produção. Este fluxo não usa *Authorized JavaScript origins*.
4. Copiar o Client ID e Client Secret para `.env.development`, reiniciar o ambiente (`./dev.sh down && ./dev.sh up`) e abrir `/app/login` ou `/app/auth/signup`. Em instalação que já tenha gravado `ENABLE_GOOGLE_OAUTH_LOGIN=false` em `InstallationConfig`, alterar esse valor para `true`, pois a configuração persistida tem precedência sobre o ambiente.

No primeiro acesso de um e-mail Google novo, `OmniauthCallbacksController#sign_up_user` chama `AccountBuilder`, criando Account isolada, usuário e vínculo de administrador; em seguida direciona o usuário para definir uma senha local. Para um e-mail já existente, autentica a conta existente via token SSO interno.
## Trial por Account

O trial Tlin usa `Account#custom_attributes`, sem migration e sem dependência de Enterprise. `AccountBuilder` grava `trial_started_at`, `trial_ends_at` (sete dias) e `plan_active=false` para toda Account nova criada pelos fluxos nativos de cadastro, inclusive OAuth. O concern `AccountTrial` é a fonte única de cálculo; Accounts antigas sem `trial_ends_at` continuam ativas para não interromper ambientes legados.

Após o vencimento, o router exibe a tela `trial-ended` e as APIs autenticadas e escopadas pela Account retornam `402 Payment Required`; endpoints públicos e webhooks não são afetados. O botão de assinatura é deliberadamente um `mailto:` até a integração de checkout existir.

Operação manual pelo Rails console:

```ruby
account = Account.find(ACCOUNT_ID)
account.custom_attributes.merge!('plan_active' => true) # libera como pago
account.save!

account.custom_attributes['trial_ends_at'] = 7.days.from_now.iso8601 # estende teste
account.save!
```

## Atribuição Click-to-WhatsApp (CTWA)

O recebimento já captura passivamente o objeto `referral` da primeira mensagem de um anúncio Click-to-WhatsApp, sem qualquer chamada à Meta CAPI. O caminho oficial é `Whatsapp::IncomingMessageWhatsappCloudService` → `Whatsapp::IncomingMessageBaseService`; `Whatsapp::IncomingMessageServiceHelpers#normalize_cloud_referral` lê `ctwa_clid`, `source_id`, `source_type`, `source_url`, `headline`, `body` e mídia. O `headline` é normalizado como `title`, e mídia como `media_type`/`thumbnail_url`, para manter o mesmo formato do Baileys (`normalize_baileys_referral`).

O objeto normalizado é salvo na primeira mensagem em `Message#content_attributes['referral']` e, como atribuição de primeiro toque, em `Conversation#additional_attributes['referral']`. Se uma conversa existente ainda não tiver essa chave, ela é preenchida uma única vez; referrals posteriores não sobrescrevem o primeiro. Webhooks sem `referral` não gravam marcador algum. O contato não recebe uma cópia: a conversa é a fonte de atribuição, evitando que o mesmo contato misture campanhas diferentes.

Para conferir no painel, abra a primeira mensagem recebida da conversa: o card **“Veio de um anúncio”** mostra a criativa e agora também **ID do anúncio** (`source_id`) e **ID do clique** (`ctwa_clid`). Para leitura completa e para o futuro adaptador CAPI, use `Conversation.find(CONVERSATION_ID).additional_attributes['referral']` ou `Message.find(MESSAGE_ID).content_attributes['referral']` no Rails console. O próximo passo de CAPI deve apenas ler esses campos; esta base não envia, agenda nem registra conversões na Meta.
