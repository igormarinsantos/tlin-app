# Desenvolvimento local no WSL

O caminho confiável do Tlin no WSL é o launcher do repositório. Ele inicia Docker, Postgres, Redis, Rails, Vite/HMR e Sidekiq em segundo plano; os processos sobrevivem ao fechamento do terminal.

Use sempre esta URL no navegador: [http://127.0.0.1:3001/app/login](http://127.0.0.1:3001/app/login). No Windows, `localhost` pode resolver primeiro para IPv6 (`::1`), enquanto o encaminhamento do WSL está em IPv4; isso aparenta uma página travada mesmo com a aplicação saudável.

## Preparar a cópia local

```bash
cd ~/tlin-app
cp .env.development.example .env.development
bundle exec rails secret
```

Cole a chave gerada em `SECRET_KEY_BASE` de `.env.development`. Depois instale as dependências uma única vez:

```bash
bundle install
corepack enable
corepack pnpm install
```

Com o Docker Engine nativo instalado, inicie o daemon caso a sessão WSL não o tenha iniciado:

```bash
sudo service docker start
```

Prepare o banco:

```bash
./dev.sh up
./dev.sh db:setup
```

## Dia a dia

Em qualquer terminal WSL, dentro de `~/tlin-app`:

```bash
./dev.sh up
```

Abra [http://127.0.0.1:3001/app/login](http://127.0.0.1:3001/app/login). Vite fica em modo de desenvolvimento na porta `3036`, com HMR; Rails e Vite fazem bind em `0.0.0.0` para que o encaminhamento Windows ↔ WSL e o acesso pelo IP interno do WSL funcionem. A URL IPv4 continua sendo a mais confiável no navegador Windows.

Para verificar tudo sem tentativa e erro:

```bash
./dev.sh status
```

Os logs persistentes ficam em `tmp/dev-local/rails.log`, `tmp/dev-local/vite.log` e `tmp/dev-local/sidekiq.log`. Para parar apenas o ambiente deste clone:

```bash
./dev.sh down
```

O launcher somente encerra processos cuja pasta de trabalho é este checkout. Se outra aplicação estiver usando a porta 3001 ou 3036, ele para com uma mensagem que informa PID e diretório, em vez de encerrá-la.

## Troubleshooting

- **`localhost:3001` não abre ou fica lento:** use `http://127.0.0.1:3001/app/login`. É a URL suportada no Windows + WSL para este ambiente.
- **Docker não responde:** execute `sudo service docker start` e depois `docker info`.
- **Postgres ou Redis não ficam saudáveis:** confira `./dev.sh status`; as credenciais e portas usadas localmente estão em `.env.development` (`5432` e `6380`).
- **Vite ficou pesado após atualização de dependências:** pare e suba de novo com `./dev.sh down && ./dev.sh up`; ele mantém um único servidor HMR, em vez de recompilar um processo por navegação.
- **Logs de queries deixando o Rails lento:** o exemplo local já usa `DISABLE_BULLET=true` e `VERBOSE_QUERY_LOGS=false`. Remova essas duas opções somente durante uma investigação de N+1.
- **Node fica sem memória:** inicie com `NODE_OPTIONS=--max-old-space-size=4096 ./dev.sh up`.
- **Vitest reclama de fuso horário:** rode `TZ=UTC pnpm test`.
