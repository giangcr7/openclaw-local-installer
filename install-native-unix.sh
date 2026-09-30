#!/usr/bin/env bash
set -Eeuo pipefail
NAME=""; OWNER_IDS=""; GROUP_ID=""; BASE_URL="https://provider.example/v1"; MODEL=""; DRY_RUN=0
while (($#)); do case "$1" in
  --name) NAME="$2"; shift 2;; --owner-ids) OWNER_IDS="$2"; shift 2;; --group-id) GROUP_ID="$2"; shift 2;;
  --base-url) BASE_URL="$2"; shift 2;; --model) MODEL="$2"; shift 2;; --dry-run) DRY_RUN=1; shift;; *) exit 2;; esac; done
[[ -n "$NAME" && -n "$OWNER_IDS" && -n "$MODEL" ]] || { echo 'name, owner-ids and model are required' >&2; exit 2; }
[[ "$(id -u)" == 0 ]] || { echo 'Run as root.' >&2; exit 1; }
if [[ -n "${OPENCLAW_ROOT:-}" ]]; then ROOT="$OPENCLAW_ROOT"
elif [[ "$(uname -s)" == Darwin ]]; then ROOT="/var/root/.openclaw"
else ROOT="/root/.openclaw"
fi
WORKSPACE="$ROOT/workspace"; BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ "$NAME" =~ ^[a-z][a-z0-9_-]{0,63}$ ]] || exit 2
if [[ "$DRY_RUN" == 1 ]]; then echo "DRY-RUN: native OpenClaw on $(uname -s) for $NAME; no changes made"; exit 0; fi
if command -v apt-get >/dev/null; then apt-get update -qq; apt-get install -y -qq ca-certificates curl python3 python3-pip ffmpeg >/dev/null; fi
if [[ "$(uname -s)" == Darwin && ! $(command -v brew >/dev/null 2>&1) ]]; then /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; fi
if [[ "$(uname -s)" == Darwin ]]; then command -v brew >/dev/null && brew install node python ffmpeg || true; fi
command -v node >/dev/null || { echo 'Node.js installation failed' >&2; exit 1; }
npm install -g openclaw@2026.9.4 >/dev/null
read -r -s -p 'Telegram Bot Token: ' TG; echo
read -r -s -p 'Provider API Key: ' KEY; echo
install -d -m 700 "$ROOT" "$WORKSPACE" "$WORKSPACE/skills"
export TG KEY
trap 'unset TG KEY; if [[ -f "$BASE/settings.json" ]]; then shred -u "$BASE/settings.json" 2>/dev/null || rm -f "$BASE/settings.json"; fi' EXIT
python3 - "$BASE/settings.json" <<PY
import json, os, sys
owners=[x.strip() for x in "$OWNER_IDS".split(',') if x.strip()]
json.dump({'member': "$NAME", 'assistant_name': 'Trợ lý OpenClaw', 'owner_ids': owners, 'group_id': "$GROUP_ID", 'telegram_token': os.environ['TG'], 'base_url': "$BASE_URL", 'api_key': os.environ['KEY'], 'api': 'openai-completions', 'model': "$MODEL"}, open(sys.argv[1], 'w'), ensure_ascii=False)
PY
chmod 600 "$BASE/settings.json"
openclaw onboard --non-interactive --accept-risk --mode local --auth-choice skip --skip-channels --skip-search --skip-skills --install-daemon --skip-health --workspace "$WORKSPACE" --gateway-bind loopback --gateway-auth token --gateway-port 18789 --gateway-token chatbot >/dev/null
python3 "$BASE/configure.py" --settings "$BASE/settings.json" --root "$ROOT" --workspace "$WORKSPACE"
rm -f "$BASE/settings.json"
for skill in "$BASE/native/skills"/*; do [[ -d "$skill" ]] || continue; cp -a "$skill" "$WORKSPACE/skills/"; done
ENSURE="$WORKSPACE/skills/tao-tro-ly-openclaw-windows-macos-linux/scripts/ensure_default_telegram_owner.py"
TRAIN="$WORKSPACE/skills/sync-openclaw-owner-training/scripts/sync_owner_training_policy.py"
ARGS=(--openclaw-root "$ROOT" --account-id "$NAME" --agent-id main --apply --backup-dir "$ROOT/backups/onboarding")
IFS=',' read -ra IDS <<< "$OWNER_IDS"; for owner in "${IDS[@]}"; do ARGS+=(--owner-id "${owner// /}"); done
python3 "$ENSURE" "${ARGS[@]}"
python3 "$TRAIN" --openclaw-root "$ROOT" --workspace "$WORKSPACE" --apply --backup-dir "$ROOT/backups/onboarding"
python3 "$BASE/native/finalize_permissions.py" --config "$ROOT/openclaw.json" --owners "$OWNER_IDS"
openclaw config validate --json
openclaw skills check
openclaw gateway restart >/dev/null
openclaw gateway status
echo "NATIVE INSTALL COMPLETE: $ROOT"
