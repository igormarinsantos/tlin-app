# Operação SaaS — infra, confiabilidade e go-live

> O eixo operacional do tlin. Complementa o plano mestre (produto) e o cronograma (execução).
> Encaixe no mês 1: infra base na semana 1 (junto com a Fase 0), hardening na semana 4, checklist de go-live no dia do piloto.

## Infra (semana 1 — o repo novo já sobe em servidor, não só local)

- [ ] VPS produção + VPS/ambiente staging (4GB+ RAM; Hetzner/DO). Docker Compose com: Rails web, Sidekiq, Postgres, Redis
- [ ] Domínios + SSL: app.tlin.ai (produção), staging.tlin.ai
- [ ] Storage S3-compatível pra anexos (Cloudflare R2) via ActiveStorage
- [ ] SMTP transacional (Resend/SES): reset de senha, convites, alertas — testar entrega real
- [ ] Secrets só no servidor (.env fora do repo); SECRET_KEY_BASE, FRONTEND_URL e afins revisados
- [ ] CI (GitHub Actions): specs → deploy staging automático; deploy produção manual (1 clique)
- Custo alvo: R$ 300–500/mês + OpenAI variável

## Confiabilidade (semana 4 — antes do piloto)

- [ ] Backup diário automático do Postgres + UM RESTORE TESTADO documentado em docs/runbook.md
- [ ] Sentry ligado (suporte nativo do Chatwoot) — erros de produção chegam com stack trace
- [ ] Monitor de uptime com alerta no celular (UptimeRobot/BetterStack)
- [ ] docs/runbook.md: como deployar, como reverter, como restaurar backup, onde ver logs, quem é o kill switch

## Segurança operacional

- [ ] Rack::Attack ativo (rate limit — já vem no Chatwoot, conferir config)
- [ ] 2FA habilitado pros admins
- [ ] Merge mensal do upstream agendado (patch de segurança) — já é regra do plano
- [ ] Acesso ao servidor: chave SSH, sem senha, só você

## Jurídico/comercial (semana 4)

- [ ] CNPJ definido pra faturar o tlin
- [ ] Termos de Uso + Política de Privacidade (LGPD) publicados — listar subprocessadores: OpenAI, Meta, Google
- [ ] Contrato piloto de 1 página: escopo, tratamento de dados, sem SLA formal, condição comercial do piloto
- [ ] Cobrança mês 1: manual (Pix + nota). Automação = Fase 2

## Suporte e dogfooding

- [ ] Inbox de WhatsApp do próprio tlin rodando NO tlin (piloto zero somos nós)
- [ ] E-mail de suporte (suporte@tlin.ai) chegando em lugar monitorado

## Checklist GO-LIVE do piloto (imprimir e riscar no dia)

- [ ] Produção no ar com SSL, staging separado
- [ ] Backup + restore testados nesta semana
- [ ] Sentry sem erro crítico aberto; uptime monitor verde há 48h
- [ ] Suíte golden verde no build deployado
- [ ] Créditos do piloto concedidos; kill switch testado (liga/desliga de verdade)
- [ ] Templates Meta aprovados; número conectado; webhook validado ponta a ponta
- [ ] Opt-out testado com contato real
- [ ] Termos publicados; contrato piloto assinado
- [ ] Config do cliente feita junto com ele + playground aprovado POR ELE
- [ ] Primeira semana: você monitora TODAS as conversas da IA diariamente (15 min/dia) e anota padrões pro backlog
