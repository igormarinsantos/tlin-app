# Dívida visual

Esta etapa aplicou somente assets, Tailwind e variáveis CSS. Os itens abaixo exigiriam editar componentes ou views do core e, por isso, foram deliberadamente deixados fora.

- `app/javascript/v3/views/login/Index.vue`: a rotação de imagens por segmento do legado depende de lógica e markup da tela de login. Os assets foram disponibilizados em `public/login/`, mas a tela não foi alterada.
- `app/javascript/dashboard/components-next/message/bubbles/Base.vue`: a bolha com gradiente do legado exigiria uma classe/componente específico. Os tokens de gradiente existem no Tailwind, mas não foram aplicados ao componente core.
- `app/javascript/dashboard/components-next/sidebar/Sidebar.vue`: os ajustes de layout, dimensões e hierarquia visual do legado não foram portados; somente fontes, cores e logos de branding foram aplicados pela camada de tema.
- `app/javascript/dashboard/routes/dashboard/kanban/Index.vue`: permanece fora do registro de rotas por ser paywall da fazer.ai; não foi redesenhado nem ativado.
