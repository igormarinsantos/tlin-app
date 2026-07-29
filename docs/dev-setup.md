# Desenvolvimento local

Este guia foi conferido contra os arquivos atuais do repositório. O caminho mais simples no Windows é Docker Compose; o fluxo nativo exige PostgreSQL 16 com pgvector, Redis e Node/Ruby nas versões do projeto.

## Dependências

- Docker Desktop e Docker Compose, **ou** PostgreSQL 16 + pgvector e Redis locais.
- Ruby `3.4.4` (`.ruby-version`) e Bundler para execução nativa.
- Node `24.13.0` (`.nvmrc`) e **pnpm 10.x** (`packageManager` fixa `10.2.0`; o lockfile é `pnpm-lock.yaml`). Use `corepack enable` antes de `pnpm install` se o pnpm global não for 10.x.

## Variáveis mínimas

Copie `.env.example` para `.env`, gere um `SECRET_KEY_BASE` próprio e defina ao menos:

```dotenv
SECRET_KEY_BASE=<saída de bundle exec rails secret>
FRONTEND_URL=http://localhost:3000
POSTGRES_HOST=postgres
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=
POSTGRES_DATABASE=chatwoot
REDIS_URL=redis://redis:6379
REDIS_PASSWORD=
RAILS_ENV=development
DISABLE_ENTERPRISE=true
CAPTAIN_ENABLED=false
```

`DISABLE_ENTERPRISE=true` é o modo Tlin; `CAPTAIN_ENABLED=false` é redundante nesse modo, mas deixa a intenção explícita. Não configure chaves de OpenAI/Captain para a etapa 0. Depois de carregar as variáveis de branding, execute `bundle exec rails branding:update` para gravar a configuração Tlin na instalação.

## Subir com Docker (recomendado)

```sh
docker compose up --build
```

O compose inicia Postgres (`5432`), Redis (`6379`), MailHog (`8025`), Rails (`3000`), Sidekiq e Vite (`3036`). O entrypoint Rails aguarda o banco e executa `db:chatwoot_prepare`; abra `http://localhost:3000` após os logs indicarem que Rails está pronto.

Para encerrar:

```sh
docker compose down
```

Use `docker compose down -v` somente quando quiser descartar os volumes locais de banco/Redis.

## Fluxo nativo

```sh
bundle install
corepack pnpm install
bundle exec rails db:prepare
pnpm dev
```

`pnpm dev` inicia `Procfile.dev`: Rails em `3000`, Sidekiq e Vite. Para esse fluxo, aponte `POSTGRES_HOST=localhost`, `REDIS_URL=redis://localhost:6379` e use um banco local separado (`POSTGRES_DATABASE=tlin_app_dev`).

## Verificação básica

```sh
corepack pnpm exec vite build
corepack pnpm test
bundle exec rspec spec/lib/chatwoot_app_spec.rb
```

Os testes Ruby requerem o banco de teste configurado; mantenha um `POSTGRES_DATABASE` próprio para teste antes de executar a suíte completa.
