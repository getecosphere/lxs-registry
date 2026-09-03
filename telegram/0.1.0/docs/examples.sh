#!/usr/bin/env bash
# telegram — executable smoke test. Requires a live domain + a bound chat.
#   BASE=<internal-url> TELEGRAM_KEY=<bound-key> ./examples.sh
set -euo pipefail
BASE="${BASE:-http://127.0.0.1:8086}"
KEY="${TELEGRAM_KEY:-smoke:test}"
TOKEN_ONLY="${TOKEN_ONLY:-0}"

jreq() { curl -sf -X POST "$BASE$1" -H 'Content-Type: application/json' -d "$2"; }

echo "== health =="
curl -sf "$BASE/api/telegram/health"

echo; echo "== bind (self) =="
jreq /api/telegram/bind "{\"key\":\"$KEY\",\"kind\":\"private\",\"chat_id\":0,\"telegram_user_id\":0}" || true

echo; echo "== bindings =="
curl -sf "$BASE/api/telegram/bindings"

if [ "$TOKEN_ONLY" = "1" ]; then
  echo; echo "== (skip live send: TOKEN_ONLY=1) =="
  exit 0
fi

echo; echo "== send =="
jreq /api/telegram/send "{\"key\":\"$KEY\",\"text\":\"smoke test from telegram LXS\"}" || true

echo; echo "== ask =="
ASK=$(jreq /api/telegram/ask "{\"key\":\"$KEY\",\"text\":\"smoke: reply to confirm\",\"timeout_secs\":60}")
echo "$ASK"
CID=$(echo "$ASK" | python3 -c 'import sys,json;print(json.load(sys.stdin)["conversation_id"])' 2>/dev/null || true)

echo; echo "== conversation =="
[ -n "$CID" ] && curl -sf "$BASE/api/telegram/conversations/$CID" || true

echo; echo "== done =="
