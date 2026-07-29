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
