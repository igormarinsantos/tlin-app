# Baseline de performance — Fase 0.5

Data da verificação: 30/07/2026
Base avaliada: `main` em `da3fd5837`
Upstream consultado: `fazer-ai/main` em `97b60fd26`

## Lighthouse mobile

O baseline automatizado não foi coletado neste ambiente. Há um processo na porta `3000`, mas ele responde como **EmbarDaily · CRM**, e não como esta instância do Chatwoot/Tlin. Além disso, inbox e dashboard exigem uma sessão autenticada e uma conta/inbox existente. Registrar esses números contra a aplicação errada produziria uma baseline inválida.

| Tela | URL de referência | FCP | LCP | TBT | Tamanho transferido | Status |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Login | `http://localhost:3000/app/login` | N/D | N/D | N/D | N/D | Não executado: Tlin não estava servido em `localhost:3000`. |
| Inbox | `http://localhost:3000/app/accounts/<accountId>/inbox/<inboxId>` | N/D | N/D | N/D | N/D | Não executado: requer sessão e inbox de teste. |
| Dashboard | `http://localhost:3000/app/accounts/<accountId>/dashboard` | N/D | N/D | N/D | N/D | Não executado: requer sessão e conta de teste. |

### Como coletar no ambiente correto

1. Suba a instância do Tlin conforme `docs/dev-setup.md` (`docker compose up --build`) e confirme que `http://localhost:3000` é esta aplicação.
2. Abra o Chrome, autentique uma conta de teste e visite cada URL acima (substituindo os IDs reais).
3. Em cada tela, abra **DevTools → Lighthouse**, selecione **Mobile** e **Performance**, desative extensões e rode a auditoria em condições equivalentes de rede/CPU.
4. Registre `First Contentful Paint`, `Largest Contentful Paint`, `Total Blocking Time` e **Total Byte Weight**; atualize a tabela com o relatório JSON/HTML arquivado junto da execução.

Para a tela de login sem autenticação, a coleta também pode ser feita por CLI após iniciar a aplicação:

```powershell
corepack pnpm dlx lighthouse http://localhost:3000/app/login `
  --preset=perf --form-factor=mobile `
  --output=json --output-path=tmp/lighthouse/login.mobile.json
```

As telas autenticadas devem ser medidas no Chrome com a sessão de teste ativa (ou com um perfil do Chrome descartável autenticado), para que Lighthouse não meça o redirecionamento de login.

## Build e testes

| Verificação | Resultado | Evidência |
| --- | --- | --- |
| `pnpm build` | Não aplicável | O `package.json` não define script `build`. |
| Build documentado do frontend | Verde com ajuste de memória | `corepack pnpm exec vite build` excedeu o heap padrão do Node (~2 GB). Com `NODE_OPTIONS=--max-old-space-size=4096`, concluiu com sucesso em 1m39s (5.405 módulos transformados). Permaneceram avisos de Browserslist desatualizado e chunks acima de 500 kB. |
| `pnpm test` | Não executável diretamente no Windows | O script usa `TZ=UTC vitest ...`, sintaxe POSIX não reconhecida pelo PowerShell. |
| Equivalente Windows da suíte JS | Sem resultado conclusivo neste ambiente | `$env:TZ='UTC'; corepack pnpm exec vitest --no-watch --no-cache --no-coverage --logHeapUsage` foi iniciado, mas não concluiu em 5 minutos e foi encerrado por timeout. |
| Spec Ruby pontual documentada | Não executável neste ambiente | `bundle`/Bundler não está disponível no PATH do Windows. |

Esta PR altera apenas `docs/perf-baseline.md`; portanto, não há specs de produto tocadas. Antes de uma alteração de código, repetir a suíte no ambiente Linux/Docker com Bundler e com um limite de execução adequado.

## Merge de teste com `fazer-ai/chatwoot`

Foi feito fetch de `fazer-ai/main` e um merge de teste em uma branch descartável criada a partir de `main`:

```text
git merge --no-commit --no-ff fazer-ai/main
```

Resultado: **há conflitos**. O merge foi abortado e a branch descartável removida; `main` não recebeu nenhuma alteração.

| Arquivo em conflito | Classificação | Impacto |
| --- | --- | --- |
| `config/routes.rb` | Código core | Sim — requer reconciliação manual das rotas da aplicação. |
| `public/favicon-96x96.png` | Asset de marca | Não é código core; conflito binário de asset. |

Conclusão: o upstream não é mergeável automaticamente no estado atual por conflito em código core (`config/routes.rb`).
