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
