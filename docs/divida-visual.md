# Dívida visual e de marca

Esta etapa aplicou somente assets, Tailwind e variáveis CSS. Os itens abaixo exigiriam editar componentes ou views do core, ou não possuem configuração/feature flag; por isso foram deliberadamente deixados fora.

- `app/javascript/v3/views/login/Index.vue`: a rotação de imagens por segmento do legado depende de lógica e markup da tela de login. Os assets foram disponibilizados em `public/login/`, mas a tela não foi alterada.
- `app/javascript/dashboard/components-next/message/bubbles/Base.vue`: a bolha enviada usa `bg-n-solid-blue`; para aplicar `bg-tlin-gradient` apenas a mensagens de agente seria necessário editar o componente core. O token de gradiente está disponível, mas não foi forçado por seletor global.
- `app/javascript/dashboard/components-next/sidebar/SidebarGroupLeaf.vue`: exceção cirúrgica à regra de tema: o estado ativo recebeu `bg-tlin-gradient`, `rounded-full` e `text-white`, para que itens como “All Conversations” usem a marca com contraste. Outros estados e a estrutura do componente core permanecem intactos.
- `app/javascript/dashboard/components-next/tabbar/TabBar.vue`: a aba ativa usa `bg-n-solid-active`; para aplicar o gradiente apenas ao indicador ativo seria necessário alterar o componente core. O token de gradiente está disponível, mas não foi aplicado por seletor global.
- `app/javascript/dashboard/components-next/button/Button.vue`: o botão primário usa `bg-n-brand`; ele recebe o gradiente pela utility de tema. Torná-lo pílula exigiria alterar sua classe `rounded-lg`, o que permanece fora do escopo de tema.
- `app/javascript/dashboard/routes/dashboard/kanban/Index.vue`: permanece fora do registro de rotas por ser paywall da fazer.ai; não foi redesenhado nem ativado.
- `app/views/super_admin/settings/show.html.erb`: texto de billing, alerta de upgrade com `sales@chatwoot.com` e cartão de suporte; criar uma configuração de suporte/community e condicionar todo o bloco ao modo Tlin.
- `app/views/super_admin/settings/_upgrade_button_community.html.erb`: CTA “Switch to Enterprise edition”; introduzir um feature flag de upsell e não renderizar o partial quando o modo community estiver fixado.
- `app/views/super_admin/application/_navigation.html.erb` e `app/views/super_admin/devise/sessions/new.html.erb`: rótulos/alt text do upstream; usar `INSTALLATION_NAME` e `BRAND_NAME` nas views.
- `app/views/installation/onboarding/index.html.erb`: título, alt text e saudação hard-coded; substituir por `INSTALLATION_NAME`/`BRAND_NAME`.
- `app/views/layouts/vueapp.html.erb`: `meta generator` aponta para fazer.ai; tornar a tag configurável ou removê-la para instalações Tlin.
- `app/javascript/dashboard/i18n/locale/en/signup.json` e `app/javascript/dashboard/i18n/locale/pt_BR/signup.json`: links hard-coded de termos e privacidade; o formulário deve receber `TERMS_URL` e `PRIVACY_URL` da configuração global em vez de depender das traduções.
- `app/javascript/dashboard/i18n/locale/en/kanban.json` e `app/javascript/dashboard/i18n/locale/pt_BR/kanban.json`: paywall fazer.ai; a rota já deve permanecer indisponível no modo community, e qualquer retorno futuro exige uma tela Tlin própria, não este componente core.
