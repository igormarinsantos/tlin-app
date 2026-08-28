# Deploy no Coolify

Este guia sobe o Tlin como uma stack Docker Compose: `rails` público, `sidekiq`, PostgreSQL e Redis privados. Ele serve tanto para staging quanto para produção. Nunca reutilize banco, Redis, volumes ou segredos entre os dois ambientes.

## O que já está pronto no repositório

- `docker-compose.coolify.yaml` faz build do código deste repositório pelo `docker/Dockerfile`; não usa imagem pronta da fazer.ai.
- O serviço `rails` é o único público e escuta internamente na porta `3000`. O compose declara `SERVICE_URL_RAILS_3000=/`, que permite ao proxy do Coolify encaminhar o domínio para essa porta sem expor portas do host.
- `postgres`, `redis` e `storage` são volumes nomeados e persistentes. O Coolify acrescenta o identificador do recurso aos volumes, evitando colisão com outros apps do VPS.
- O entrypoint do Rails aguarda o Postgres e executa `bundle exec rake db:chatwoot_prepare` antes de iniciar o Puma. Em banco novo, isso cria o schema, carrega as configurações e roda seeds de produção; em banco existente, roda as migrations pendentes.
- `DISABLE_ENTERPRISE=true` e `CAPTAIN_ENABLED=false` já são fixos no compose. Não há dependência de Captain ou de `enterprise/`.

## Antes de abrir o Coolify

1. Crie registros DNS `A` para `app.tlin.ai` e, se for usar staging, `staging.app.tlin.ai`, ambos apontando para o IP público do VPS.
2. Confirme que o proxy do Coolify (Traefik) está saudável e que as portas 80/443 do VPS estão liberadas.
3. Conecte o GitHub ao Coolify ou adicione uma deploy key com leitura ao repositório `igormarinsantos/tlin-app`.
4. Separe os segredos abaixo em um gerenciador de senhas. Não os salve no Git nem em screenshots.

## Criar o recurso no painel

1. No Coolify, crie ou abra o projeto **Tlin**. Crie os ambientes separados **staging** e **production**.
2. Em cada ambiente, clique em **New Resource** → **Docker Compose** → **Git Repository**.
3. Escolha o repositório `igormarinsantos/tlin-app`, a branch `main` e informe `docker-compose.coolify.yaml` como Compose file.
4. Salve para o Coolify ler a stack. Devem aparecer quatro serviços: `rails`, `sidekiq`, `postgres` e `redis`.
5. Abra o serviço **rails** e, em **Domains**, informe:
   - produção: `https://app.tlin.ai:3000`
   - staging: `https://staging.app.tlin.ai:3000`

   O `:3000` é a porta **interna do container**, não uma porta que ficará aberta na internet. O proxy entrega HTTPS normal em 443 e emite/renova o certificado TLS.
6. Não atribua domínio, porta publicada ou rota aos serviços `sidekiq`, `postgres` e `redis`; eles devem permanecer apenas na rede privada da stack.

## Variáveis de ambiente

Abra **Configuration** → **Environment Variables** do recurso. O Coolify mostra as variáveis interpoladas no compose. Preencha as indicadas abaixo e salve antes do primeiro deploy.

| Variável | Valor / origem | Obrigatória | Observação |
| --- | --- | --- | --- |
| `SERVICE_URL_RAILS_3000` | Gerada pelo Coolify a partir do domínio do serviço `rails` | Sim | Não editar manualmente; ela alimenta `FRONTEND_URL`. |
| `SERVICE_USER_POSTGRES` | Gerada pelo Coolify | Sim | Usuário interno do banco. |
| `SERVICE_PASSWORD_POSTGRES` | Gerada pelo Coolify | Sim, segredo | Senha do banco; o mesmo valor vai para Rails, Sidekiq e Postgres. |
| `SERVICE_PASSWORD_REDIS` | Gerada pelo Coolify | Sim, segredo | Senha do Redis. |
| `SERVICE_PASSWORD_64_SECRETKEYBASE` | Gerada pelo Coolify | Sim, segredo | É usada como `SECRET_KEY_BASE`; não a troque depois de haver sessões ativas. |
| `POSTGRES_DB` | `tlin_production` (produção) / `tlin_staging` (staging) | Sim | Nome exclusivo por ambiente. |
| `FRONTEND_URL` | Não preencher diretamente | Sim | O compose a deriva de `SERVICE_URL_RAILS_3000`; deve resultar no domínio HTTPS público, sem barra final. |
| `DISABLE_ENTERPRISE` | `true` | Sim | Já fixada no compose. |
| `CAPTAIN_ENABLED` | `false` | Sim | Já fixada no compose. |
| `INSTALLATION_NAME` | `Tlin` | Sim | Já fixada no compose; a identidade persistente também vem de `config/installation_config.yml`. |
| `DEFAULT_LOCALE` | `pt_BR` | Recomendado | Já fixada no compose. |
| `FORCE_SSL` | `true` | Recomendado | Já vem com default no compose; o certificado é terminado pelo proxy Coolify. |
| `RAILS_LOG_TO_STDOUT` | `true` | Recomendado | Já fixada para os logs aparecerem no painel. |
| `ENABLE_ACCOUNT_SIGNUP` | `true` | Sim para self-service | É entregue ao container; veja a etapa adicional de ativação persistente abaixo. |
| `OPENAI_API_KEY` | Chave de projeto da OpenAI | Sim para o Copiloto Tlin, segredo | Nunca expor no frontend, Git ou logs. Sem ela, apenas o Copiloto retorna “não configurado”; o restante do app inicia. |
| `TLIN_COPILOT_MODEL` | `gpt-4o-mini` | Opcional | Modelo do Copiloto. |
| `TLIN_COPILOT_TIMEOUT_SECONDS` | `20` | Opcional | Timeout por chamada do Copiloto. |
| `MAILER_SENDER_EMAIL` | `Tlin <suporte@tlin.ai>` | Sim | Remetente de confirmação, reset de senha e notificações. |
| `RESEND_API_KEY` | Chave da Resend | Escolha Resend **ou** SMTP, segredo | Caminho mais simples para e-mail transacional. |
| `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_DOMAIN`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_AUTHENTICATION`, `SMTP_ENABLE_STARTTLS_AUTO` | Credenciais do provedor SMTP | Escolha SMTP **ou** Resend; senha é segredo | Se `RESEND_API_KEY` estiver preenchida, ela tem precedência. Não preencha senha fictícia. |
| `ACTIVE_STORAGE_SERVICE` | `local` | Sim | `local` usa o volume `storage`, adequado a uma instância única com backup. |
| `STORAGE_ACCESS_KEY_ID`, `STORAGE_SECRET_ACCESS_KEY`, `STORAGE_REGION`, `STORAGE_BUCKET_NAME`, `STORAGE_ENDPOINT`, `STORAGE_FORCE_PATH_STYLE` | R2/S3 compatível | Somente se trocar storage | Mude `ACTIVE_STORAGE_SERVICE` para `s3_compatible`; não faça a troca sem plano de migração dos anexos existentes. |
| `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `S3_BUCKET_NAME` | Amazon S3 | Somente se trocar storage | Alternativa ao R2: use `ACTIVE_STORAGE_SERVICE=amazon`. As chaves são segredos. |
| `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_OAUTH_CALLBACK_URL`, `ENABLE_GOOGLE_OAUTH_LOGIN` | Credenciais Google OAuth | Opcional; secret é o client secret | Para produção, callback: `https://app.tlin.ai/auth/google_oauth2/callback`. Para staging use o domínio de staging e credenciais/callback próprios. |
| `BAILEYS_PROVIDER_DEFAULT_CLIENT_NAME`, `BAILEYS_PROVIDER_DEFAULT_URL`, `BAILEYS_PROVIDER_DEFAULT_API_KEY` | Serviço Baileys externo | Opcional | Só preencha se for usar a inbox “WhatsApp - Ambiente de Teste”. Para WhatsApp Oficial (Cloud API), configure a inbox no dashboard. |
| `BRAND_ASSETS_URL` | URL opcional de assets externos | Opcional | Deixe vazio: os assets Tlin já estão no código da imagem. |

`RAILS_ENV=production`, `NODE_ENV=production`, `INSTALLATION_ENV=docker`, hosts internos, portas e URLs Redis/Postgres já são definidos pelo compose. Não crie `DATABASE_URL`: o entrypoint e `database.yml` usam as variáveis `POSTGRES_*` da stack.

## Primeiro deploy e migrations

1. Clique em **Deploy**.
2. Acompanhe **Deployments** → logs do `rails`. O primeiro build pode demorar porque compila os assets. O sinal esperado é `Database preparation complete.` seguido de `Listening on http://0.0.0.0:3000`.
3. Confirme que `postgres` e `redis` estão healthy e que `sidekiq` está running. Não execute migrations manualmente em paralelo: o entrypoint já executa `db:chatwoot_prepare` antes de o Rails ficar saudável.
4. Abra `https://app.tlin.ai/app/login`. Confirme certificado válido, tela Tlin e ausência de erro 500.
5. Caso uma migration precise ser reaplicada em manutenção, abra o **Terminal** do serviço `rails` e execute somente:

   ```sh
   bundle exec rake db:chatwoot_prepare
   ```

   Espere terminar antes de reiniciar a stack. Em deploys normais, este comando é automático.

## Criar o primeiro super admin

No **Terminal** do serviço `rails`, execute. Substitua somente o e-mail e o nome; a senha será solicitada sem aparecer na tela:

```sh
export ADMIN_EMAIL='voce@tlin.ai'
export ADMIN_NAME='Administrador Tlin'
read -rsp 'Senha do super admin: ' ADMIN_PASSWORD; echo
export ADMIN_PASSWORD
bundle exec rails runner "admin = SuperAdmin.find_or_initialize_by(email: ENV.fetch('ADMIN_EMAIL')); admin.assign_attributes(name: ENV.fetch('ADMIN_NAME'), password: ENV.fetch('ADMIN_PASSWORD'), password_confirmation: ENV.fetch('ADMIN_PASSWORD'), confirmed_at: Time.current); admin.save!; puts admin.email"
unset ADMIN_PASSWORD ADMIN_EMAIL ADMIN_NAME
```

Faça login em `https://app.tlin.ai/super_admin` com essas credenciais. Não use `db:seed` em produção: o seed de produção não cria usuário administrador.

## Ativar cadastro público de forma persistente

Há uma particularidade do Chatwoot: `ENABLE_ACCOUNT_SIGNUP` é uma `InstallationConfig` persistida no banco. O compose entrega o valor `true`, mas uma instalação recém-criada carrega o default histórico `false` do arquivo de configuração antes de consultar o ambiente. Depois do primeiro deploy, rode uma vez no **Terminal** do `rails`:

```sh
bundle exec rails runner "config = InstallationConfig.find_or_initialize_by(name: 'ENABLE_ACCOUNT_SIGNUP'); config.update!(value: true, locked: false); GlobalConfig.clear_cache; puts config.value"
```

Depois faça logout e confirme `https://app.tlin.ai/app/auth/signup`. A partir daí, cada signup cria a própria Account isolada. O super admin também pode administrar esse valor posteriormente em `/super_admin`.

## Checklist após o deploy

- Crie uma conta de teste por `/app/auth/signup`, complete o onboarding e confirme que a conta não vê dados de outra Account.
- Solicite um reset de senha e confirme a entrega do e-mail. Sem Resend/SMTP funcional, confirmação e reset não funcionam em produção.
- Abra uma conversa e teste o Copiloto Tlin. Se a chave OpenAI estiver ausente, o erro deve ser apenas de configuração do Copiloto, não do dashboard.
- Configure uma inbox WhatsApp Oficial no dashboard e teste o webhook público pela URL do domínio de produção.
- Configure backup externo dos volumes `postgres` e `storage` antes de cadastrar clientes. Redis é descartável para dados de negócio, mas Postgres e storage não são.
- Para staging, repita a stack em ambiente próprio com domínio, banco, volumes, segredos e chave OpenAI separados. Nunca conecte staging ao Postgres de produção.

## O que é ação do painel e o que veio do código

Você precisa: criar o recurso, vincular GitHub, configurar DNS/domínio/SSL, preencher os segredos, disparar o deploy, criar o super admin, ativar persistentemente o signup e configurar backup.

O repositório já entrega: build local do código Tlin, migrations no boot, serviços privados, dados persistentes, rota pública para Rails, marca Tlin, locale pt-BR, cadastro disponível para ativação, enterprise/Captain desligados e suporte opcional ao Copiloto/OpenAI e Google OAuth.
