# TLIN — contexto de trabalho

## Produto

- Tlin é um fork MIT do Chatwoot, com marca própria, operado como serviço de atendimento com IA.
- A engine é o serviço externo `fazer-ai/agents`; **não construir nem copiar engine de IA para este repo**.
- O chassi Chatwoot cuida de conversas, inboxes, contatos e multi-conta. Mudança nova só quando um cliente real pedir.

## Regras de ouro

- Visual: use somente tema/tokens/Tailwind. Nunca recrie `_tlin_custom.scss` nem use overrides com `!important`.
- Não editar componente/view core por estética; exceções já aprovadas ficam em `docs/divida-visual.md` e toda nova exceção deve ser registrada lá.
- `DISABLE_ENTERPRISE=true` e `CAPTAIN_ENABLED=false`: não ativar, editar ou depender de `enterprise/`/Captain.
- Preserve compatibilidade com upstream; mudanças mínimas, sem refatoração fora do escopo.

## Marca

- DM Sans self-hosted; cores: lilás `#B597FF`, ciano `#38E3FF`; gradiente `135deg` lilás → ciano.
- Reutilize os tokens `--tlin-*`, `theme/colors.js`, `tailwind.config.js` e `app/javascript/dashboard/assets/scss/_next-colors.scss`.
- Assets oficiais: `public/brand-assets/`; fontes: `app/javascript/shared/assets/fonts/dm-sans.scss`.

## Dev local (WSL)

- Repositório em `~/tlin-app`; abra `http://127.0.0.1:3001` (não `localhost`).
- Use `./dev.sh up`, `./dev.sh preview` e `./dev.sh build-preview`; prefira `build-preview` para ajustes visuais e F5 rápidos.
- Instruções e troubleshooting: `docs/dev-local.md`.

## Mapa rápido

- Tema: `theme/`, `tailwind.config.js`, `app/javascript/dashboard/assets/scss/`.
- Sidebar: `app/javascript/dashboard/components-next/sidebar/Sidebar.vue`.
- Login/auth: `app/javascript/v3/views/login/`, `app/javascript/v3/views/auth/`, `app/javascript/components/Auth/`.
- Conversas: `app/javascript/dashboard/components-next/message/` e `app/javascript/dashboard/routes/dashboard/conversation/`.
- Backend: `app/controllers/api/v1/accounts/`, `app/controllers/api/v1/accounts_controller.rb`, `app/models/account.rb`.
- Decisões, setup e dívida visual: `docs/decisoes.md`, `docs/dev-local.md`, `docs/divida-visual.md`.

## Fluxo

- Uma tarefa = um PR. Comite apenas o escopo pedido; documente dívida e surpresas relevantes.
- Não reconstruir a engine, não editar `enterprise/`, não reintroduzir marca/upsell Chatwoot/fazer.ai, nem quebrar o rebase futuro com upstream.
