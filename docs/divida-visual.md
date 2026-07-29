# Dívida visual e de marca

Esta etapa aplicou somente assets, Tailwind e variáveis CSS. Os itens abaixo exigiriam editar componentes ou views do core, ou não possuem configuração/feature flag; por isso foram deliberadamente deixados fora.

- `app/javascript/v3/views/login/Index.vue`: a rotação de imagens por segmento do legado depende de lógica e markup da tela de login. Os assets foram disponibilizados em `public/login/`, mas a tela não foi alterada.
- `app/javascript/dashboard/components-next/message/bubbles/Base.vue`: a bolha com gradiente do legado exigiria uma classe/componente específico. Os tokens de gradiente existem no Tailwind, mas não foram aplicados ao componente core.
- `app/javascript/dashboard/components-next/sidebar/Sidebar.vue`: os ajustes de layout, dimensões e hierarquia visual do legado não foram portados; somente fontes, cores e logos de branding foram aplicados pela camada de tema.
- `app/javascript/dashboard/routes/dashboard/kanban/Index.vue`: permanece fora do registro de rotas por ser paywall da fazer.ai; não foi redesenhado nem ativado.
- `app/views/super_admin/settings/show.html.erb`: texto de billing, alerta de upgrade com `sales@chatwoot.com` e cartão de suporte; criar uma configuração de suporte/community e condicionar todo o bloco ao modo Tlin.
- `app/views/super_admin/settings/_upgrade_button_community.html.erb`: CTA “Switch to Enterprise edition”; introduzir um feature flag de upsell e não renderizar o partial quando o modo community estiver fixado.
- `app/views/super_admin/application/_navigation.html.erb` e `app/views/super_admin/devise/sessions/new.html.erb`: rótulos/alt text do upstream; usar `INSTALLATION_NAME` e `BRAND_NAME` nas views.
- `app/views/installation/onboarding/index.html.erb`: título, alt text e saudação hard-coded; substituir por `INSTALLATION_NAME`/`BRAND_NAME`.
- `app/views/layouts/vueapp.html.erb`: `meta generator` aponta para fazer.ai; tornar a tag configurável ou removê-la para instalações Tlin.
- `app/javascript/dashboard/i18n/locale/en/signup.json` e `app/javascript/dashboard/i18n/locale/pt_BR/signup.json`: links hard-coded de termos e privacidade; o formulário deve receber `TERMS_URL` e `PRIVACY_URL` da configuração global em vez de depender das traduções.
- `app/javascript/dashboard/i18n/locale/en/kanban.json` e `app/javascript/dashboard/i18n/locale/pt_BR/kanban.json`: paywall fazer.ai; a rota já deve permanecer indisponível no modo community, e qualquer retorno futuro exige uma tela Tlin própria, não este componente core.
