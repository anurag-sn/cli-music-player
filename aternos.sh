#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

for cmd in curl jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}Error: $cmd is not installed.${NC}"
        exit 1
    fi
done

usage() {
    cat <<'EOF'
Usage: ./aternos.sh <status|on|off>

Required environment variables:
  ATERNOS_SESSION   Your aternos.org session cookie value
  ATERNOS_SERVER    Your server id (from panel requests)
  ATERNOS_SEC       Security token used by panel AJAX requests

Optional:
  ATERNOS_BASE_URL  Default: https://aternos.org
EOF
}

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

ACTION="$1"
ATERNOS_BASE_URL="${ATERNOS_BASE_URL:-https://aternos.org}"

for var in ATERNOS_SESSION ATERNOS_SERVER ATERNOS_SEC; do
    if [ -z "${!var:-}" ]; then
        echo -e "${RED}Missing required env var: $var${NC}"
        usage
        exit 1
    fi
done

call_api() {
    local endpoint="$1"
    local payload
    payload="SEC=${ATERNOS_SEC}&SERVER=${ATERNOS_SERVER}"

    curl -sS "${ATERNOS_BASE_URL}${endpoint}" \
        -H "Cookie: ATERNOS_SESSION=${ATERNOS_SESSION}" \
        -H "X-Requested-With: XMLHttpRequest" \
        -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
        --data "$payload"
}

print_status() {
    local response="$1"
    local status_value
    status_value="$(echo "$response" | jq -r '.status // empty' 2>/dev/null || true)"

    if [ -n "$status_value" ]; then
        echo -e "${CYAN}Server status:${NC} ${status_value}"
    else
        echo -e "${YELLOW}Raw response:${NC} $response"
    fi
}

case "$ACTION" in
    status)
        RESPONSE="$(call_api "/panel/ajax/status.php")"
        print_status "$RESPONSE"
        ;;
    on)
        RESPONSE="$(call_api "/panel/ajax/start.php")"
        echo -e "${GREEN}Start request sent.${NC}"
        print_status "$(call_api "/panel/ajax/status.php")"
        ;;
    off)
        RESPONSE="$(call_api "/panel/ajax/stop.php")"
        echo -e "${GREEN}Stop request sent.${NC}"
        print_status "$(call_api "/panel/ajax/status.php")"
        ;;
    *)
        usage
        exit 1
        ;;
esac
