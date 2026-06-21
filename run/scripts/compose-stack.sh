#!/usr/bin/env bash
# compose-stack.sh — control the kui-edge stack (Traefik + kiko + kui).
#
# Usage:
#   ./run/scripts/compose-stack.sh up          # start everything
#   ./run/scripts/compose-stack.sh down        # stop everything
#   ./run/scripts/compose-stack.sh up kiko     # start only kiko
#   ./run/scripts/compose-stack.sh up kui      # start only kui (implies kiko)
#   ./run/scripts/compose-stack.sh restart     # restart all services
#   ./run/scripts/compose-stack.sh restart kiko # restart only kiko
#   ./run/scripts/compose-stack.sh logs        # tail logs (all services)
#   ./run/scripts/compose-stack.sh logs kiko   # tail kiko logs only
#   ./run/scripts/compose-stack.sh pull        # pull latest images
#
# Environment: STACK_HOST_DATA must be set or exported before running.
# If unset, the script looks for .env in common locations.

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

COMPOSE_FILE="run/docker-compose/traefik/docker-compose.yml"

# Resolve STACK_HOST_DATA
if [ -z "${STACK_HOST_DATA:-}" ]; then
  if [ -f .env ]; then
    STACK_HOST_DATA=$(grep -E '^STACK_HOST_DATA=' .env | cut -d= -f2-)
  fi
  if [ -z "${STACK_HOST_DATA:-}" ]; then
    echo "ERROR: STACK_HOST_DATA is not set."
    echo "Set it in .env or export it:"
    echo "  export STACK_HOST_DATA=/home/kui/stack-data"
    exit 1
  fi
fi

ENV_FILE="${STACK_HOST_DATA}/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: .env not found at ${ENV_FILE}"
  echo "Create it from the template:"
  echo "  cp run/common/.env.example \"${ENV_FILE}\""
  exit 1
fi

COMPOSE_CMD="docker compose --env-file \"${ENV_FILE}\" -f \"${COMPOSE_FILE}\""

case "${1:-help}" in
  up)
    shift
    if [ $# -eq 0 ]; then
      echo "Starting full stack (traefik + kiko + kui)..."
      eval "$COMPOSE_CMD" up -d
    else
      echo "Starting service(s): $*"
      eval "$COMPOSE_CMD" up -d "$@"
    fi
    ;;
  down)
    shift
    if [ $# -eq 0 ]; then
      echo "Stopping full stack..."
      eval "$COMPOSE_CMD" down
    else
      echo "Stopping service(s): $*"
      eval "$COMPOSE_CMD" rm -sf "$@" 2>/dev/null || true
      eval "$COMPOSE_CMD" stop "$@"
    fi
    ;;
  restart)
    shift
    if [ $# -eq 0 ]; then
      echo "Restarting full stack..."
      eval "$COMPOSE_CMD" restart
    else
      echo "Restarting service(s): $*"
      eval "$COMPOSE_CMD" restart "$@"
    fi
    ;;
  logs)
    shift
    eval "$COMPOSE_CMD" logs -f "$@"
    ;;
  pull)
    echo "Pulling latest images..."
    eval "$COMPOSE_CMD" pull
    ;;
  ps)
    eval "$COMPOSE_CMD" ps
    ;;
  help|*)
    echo "Usage: $0 <command> [service...]"
    echo ""
    echo "Commands:"
    echo "  up [service..]     Start services (default: all)"
    echo "  down [service..]   Stop services"
    echo "  restart [service]  Restart services"
    echo "  logs [service]     Tail logs"
    echo "  pull               Pull latest images"
    echo "  ps                 List running services"
    echo ""
    echo "Services: traefik, kiko, kui"
    echo ""
    echo "Examples:"
    echo "  $0 up              Start stack (Traefik requests TLS cert on first run)"
    echo "  $0 up kiko         Start only the collector (no TLS cert request)"
    echo "  $0 up kiko kui     Start apps without restarting Traefik"
    echo "  $0 down            Stop everything"
    echo "  $0 logs kiko       Follow kiko logs"
    exit 0
    ;;
esac
