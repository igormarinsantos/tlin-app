#!/usr/bin/env bash

# Persistent WSL launcher for the local Tlin development environment.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$ROOT/.env.development"
LOG_DIR="$ROOT/tmp/dev-local"
MISE_BIN="${MISE_BIN:-$HOME/.local/bin/mise}"
RAILS_PORT=3001
VITE_PORT=3036

cd "$ROOT"

die() {
  echo "Erro: $*" >&2
  exit 1
}

require_env() {
  [[ -f "$ENV_FILE" ]] || die "crie .env.development com: cp .env.development.example .env.development"
  [[ -x "$MISE_BIN" ]] || die "mise não encontrado em $MISE_BIN"
}

compose() {
  ENV_FILE=.env.development docker compose --env-file .env.development "$@"
}

stop_app_port() {
  local port="$1" pid cwd
  pid="$(sudo lsof -ti ":$port" 2>/dev/null | head -n 1 || true)"
  [[ -n "$pid" ]] || return 0
  cwd="$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)"
  [[ "$cwd" == "$ROOT" ]] || die "a porta $port está ocupada por outro processo (PID $pid, diretório ${cwd:-desconhecido})"
  kill "$pid" 2>/dev/null || true
  for _ in {1..2}; do
    sudo lsof -ti ":$port" >/dev/null 2>&1 || return 0
    sleep 1
  done
  # Puma may be finishing in-flight requests. It is safe to force only this
  # checkout's process after the graceful grace period has elapsed.
  kill -KILL "$pid" 2>/dev/null || true
  for _ in {1..15}; do
    sudo lsof -ti ":$port" >/dev/null 2>&1 || return 0
    sleep 1
  done
  die "não foi possível liberar a porta $port"
}

port_is_owned_by_this_checkout() {
  local port="$1" pid cwd
  pid="$(sudo lsof -ti ":$port" 2>/dev/null | head -n 1 || true)"
  [[ -n "$pid" ]] || return 1
  cwd="$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)"
  [[ "$cwd" == "$ROOT" ]] || die "a porta $port está ocupada por outro processo (PID $pid, diretório ${cwd:-desconhecido})"
  return 0
}

stop_sidekiq() {
  local pid cwd
  while read -r pid; do
    cwd="$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)"
    [[ "$cwd" == "$ROOT" ]] && kill "$pid" 2>/dev/null || true
  done < <(pgrep -f 'sidekiq' || true)
}

sidekiq_is_owned_by_this_checkout() {
  local pid cwd
  while read -r pid; do
    cwd="$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)"
    [[ "$cwd" == "$ROOT" ]] && return 0
  done < <(pgrep -f 'sidekiq' || true)
  return 1
}

wait_for_port() {
  local port="$1" label="$2"
  for _ in {1..45}; do
    ss -tln | grep -q ":$port " && return 0
    sleep 1
  done
  die "$label não iniciou; veja os logs em $LOG_DIR"
}

start_processes() {
  mkdir -p "$LOG_DIR"

  # `up` is idempotent: a healthy process from this checkout remains running.
  # A different checkout on either reserved port is reported instead of killed.
  if ! port_is_owned_by_this_checkout "$RAILS_PORT"; then
    setsid -f "$MISE_BIN" exec ruby@3.4.4 node@24.13.0 -- \
      bundle exec rails server -b 127.0.0.1 -p "$RAILS_PORT" >"$LOG_DIR/rails.log" 2>&1
  fi
  if ! port_is_owned_by_this_checkout "$VITE_PORT"; then
    setsid -f "$MISE_BIN" exec ruby@3.4.4 node@24.13.0 -- \
      pnpm vite dev --host 127.0.0.1 --port "$VITE_PORT" >"$LOG_DIR/vite.log" 2>&1
  fi
  if ! sidekiq_is_owned_by_this_checkout; then
    setsid -f "$MISE_BIN" exec ruby@3.4.4 node@24.13.0 -- \
      bundle exec sidekiq -C config/sidekiq.yml >"$LOG_DIR/sidekiq.log" 2>&1
  fi

  wait_for_port "$RAILS_PORT" 'Rails'
  wait_for_port "$VITE_PORT" 'Vite'
}

up() {
  require_env
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
  command -v docker >/dev/null || die 'Docker Engine não está instalado'
  sudo service docker start >/dev/null 2>&1 || true
  docker info >/dev/null || die 'Docker daemon não está disponível; tente sudo service docker start'

  compose up -d postgres redis

  for _ in {1..45}; do
    if compose exec -T postgres pg_isready -U "$POSTGRES_USERNAME" -d "$POSTGRES_DATABASE" >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
  compose exec -T postgres pg_isready >/dev/null || die 'Postgres não ficou pronto'
  for _ in {1..20}; do
    compose exec -T redis redis-cli -a "$REDIS_PASSWORD" ping 2>/dev/null | grep -qx PONG && break
    sleep 1
  done
  compose exec -T redis redis-cli -a "$REDIS_PASSWORD" ping 2>/dev/null | grep -qx PONG || die 'Redis não ficou pronto'

  start_processes
  # Warm Rails once, then measure the user-facing login endpoint on the canonical IPv4 URL.
  curl --fail --silent --max-time 30 http://127.0.0.1:3001/app/login >/dev/null
  printf 'Tlin pronto: http://127.0.0.1:3001/app/login\n'
}

status() {
  require_env
  echo 'Containers:'
  compose ps postgres redis
  echo
  echo 'Processos:'
  ps -eo pid=,args= | grep -E '[p]uma|[v]ite|[s]idekiq' || true
  echo
  echo 'Portas:'
  ss -tlnp | grep -E ':3001|:3036|:5432|:6380' || true
  echo
  if curl --fail --silent --max-time 15 http://127.0.0.1:3001/app/login >/dev/null; then
    echo 'Login: OK — http://127.0.0.1:3001/app/login'
  else
    echo 'Login: indisponível (veja tmp/dev-local/rails.log)'
    return 1
  fi
}

db_setup() {
  require_env
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
  "$MISE_BIN" exec ruby@3.4.4 node@24.13.0 -- bundle exec rails db:setup
}

down() {
  require_env
  stop_app_port "$RAILS_PORT"
  stop_app_port "$VITE_PORT"
  stop_sidekiq
  compose stop postgres redis
  echo 'Processos locais e serviços de apoio parados.'
}

case "${1:-}" in
  up) up ;;
  status) status ;;
  down) down ;;
  db:setup) db_setup ;;
  *) echo 'Uso: ./dev.sh {up|status|down|db:setup}' >&2; exit 64 ;;
esac
