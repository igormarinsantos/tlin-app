# Desenvolvimento local no WSL (Rails + Vite com hot-reload)

## Docker Engine nativo no WSL

Em uma nova sessao WSL, confirme que o daemon esta disponivel antes de subir os servicos:

```bash
docker info
```

Se ele nao estiver em execucao, inicie-o com:

```bash
sudo service docker start
```

Este fluxo executa somente PostgreSQL e Redis no Docker. Rails e Vite rodam diretamente no Ubuntu/WSL, tornando a alteração de Ruby, Vue e CSS imediata. A aplicação Tlin fica em `http://localhost:3001`; Vite/HMR permanece em `http://localhost:3036`.

> Execute todos os comandos a seguir no terminal Ubuntu/WSL, na raiz do clone Linux do repositório. Evite desenvolver em `/mnt/c/...`: manter o repositório no filesystem Linux reduz problemas de performance de watch e permissões.

## Pré-requisitos

- Docker Engine nativo e `docker compose` disponíveis no Ubuntu/WSL.
- Ruby `3.4.4` (veja `.ruby-version`) com as dependências de compilação do projeto.
- Node `24.13.0` (veja `.nvmrc`) e Corepack.
- PostgreSQL e Redis **não** precisam estar instalados no host: serão serviços Docker.

## Preparar a cópia local

O exemplo de ambiente desativa Bullet e os query traces detalhados apenas no desenvolvimento para manter a navegação local responsiva. Para investigar N+1 em uma sessão pontual, remova `DISABLE_BULLET=true` e defina `VERBOSE_QUERY_LOGS=true`.

O arquivo `.env.development` é local e ignorado pelo Git. Ele já foi preparado com `FRONTEND_URL=http://localhost:3001`, banco/Redis em `localhost`, modo community e branding Tlin. Caso recrie o arquivo, gere uma chave nova e preserve os placeholders comentados do Baileys:

```bash
cp .env.development.example .env.development
bundle exec rails secret
```

Use a saída do segundo comando em `SECRET_KEY_BASE` e mantenha, no mínimo, estes valores:

```dotenv
RAILS_ENV=development
SECRET_KEY_BASE=<chave-gerada>
FRONTEND_URL=http://localhost:3001
PORT=3001
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=
POSTGRES_DATABASE=tlin_app_dev
REDIS_URL=redis://localhost:6380
REDIS_PORT=6380
REDIS_PASSWORD=
DISABLE_ENTERPRISE=true
CAPTAIN_ENABLED=false
INSTALLATION_NAME=Tlin

# BAILEYS_PROVIDER_DEFAULT_CLIENT_NAME=
# BAILEYS_PROVIDER_DEFAULT_URL=
# BAILEYS_PROVIDER_DEFAULT_API_KEY=
# BAILEYS_WHATSAPP_GROUPS_ENABLED=
```

Instale as dependências do host:

```bash
bundle install
corepack enable
corepack pnpm install
```

## Subir somente banco e Redis

Não execute `docker compose up` sem serviços: ele também sobe Rails, Vite, Sidekiq e MailHog. Para este fluxo, suba exclusivamente as dependências:

```bash
ENV_FILE=.env.development docker compose up -d postgres redis
docker compose ps postgres redis
```

O Compose expõe PostgreSQL em `5432` e Redis em `6379`, acessíveis do WSL como `localhost`.

## Preparar o banco

Para um banco novo, `db:setup` cria o banco, carrega a estrutura e executa seeds:

```bash
bundle exec rails db:setup
```

Quando o banco já existir, aplique atualizações e rode seeds quando forem necessários:

```bash
bundle exec rails db:migrate
bundle exec rails db:seed
```

## Dia a dia: dois terminais

Terminal 1 — Rails, na porta reservada para o Tlin:

```bash
bundle exec rails server -p 3001 -b 0.0.0.0
```

Terminal 2 — Vite com hot-reload:

```bash
bin/vite dev
```

Abra `http://localhost:3001`. O browser recebe a página do Rails nessa porta e conecta o HMR ao Vite em `3036`; essa separação é esperada e não depende de deploy.

### Executar em background

Para manter os dois processos ativos após fechar o terminal WSL, execute na raiz do repositório:

```bash
setsid -f bundle exec rails server -p 3001 -b 0.0.0.0 > tmp/tlin-rails.log 2>&1
setsid -f pnpm vite dev > tmp/tlin-vite.log 2>&1
```

Valide a aplicação com `curl -s http://localhost:3001/app/login | grep -iE '<title>|chatwoot|tlin'`. Os logs ficam em `tmp/tlin-rails.log` e `tmp/tlin-vite.log`.

Para parar apenas as dependências Docker ao final do trabalho:

```bash
docker compose stop postgres redis
```

## Troubleshooting

### A porta 3001 está ocupada

Identifique o processo no WSL e encerre-o, ou escolha outra porta e atualize `FRONTEND_URL` com a mesma porta:

```bash
ss -ltnp | grep :3001
kill <PID>
```

### Vite/Rails não reflete mudanças

Confirme que Rails está em `3001` e Vite em `3036`. Reinicie somente o processo afetado. Se estiver trabalhando em `/mnt/c`, mova o clone para o filesystem Linux (`~/src/tlin-app`) para que o watcher tenha desempenho confiável.

### Build do frontend fica sem memória

Use um heap maior apenas no comando que precisa dele:

```bash
NODE_OPTIONS=--max-old-space-size=4096 corepack pnpm exec vite build
```

### `TZ=UTC vitest` falha no shell

No Bash/WSL o script funciona como está:

```bash
corepack pnpm test
```

No PowerShell, a atribuição POSIX não é reconhecida. Use:

```powershell
$env:TZ='UTC'; corepack pnpm exec vitest --no-watch --no-cache --no-coverage --logHeapUsage
```

### Rails não conecta ao banco ou Redis

Verifique se apenas os dois serviços estão saudáveis e se `.env.development` usa `localhost`, não os nomes de serviço Docker:

```bash
docker compose ps postgres redis
ENV_FILE=.env.development docker compose logs --tail=100 postgres redis
```
