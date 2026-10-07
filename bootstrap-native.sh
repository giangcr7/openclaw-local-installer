#!/usr/bin/env bash
set -Eeuo pipefail
BUNDLE_URL=""; SHA256=""; NAME=""; OWNER_IDS=""; GROUP_ID=""; BASE_URL="https://provider.example/v1"; MODEL=""; PROFILE="basic-assistant-full"; MODULES=(); FULL_BUNDLE=0; DRY_RUN=0
usage(){ echo "Usage: $0 --bundle-url URL --sha256 HASH --name NAME --owner-ids ID[,ID] --model MODEL [--profile PROFILE] [--module ID] [--full-bundle] [--group-id ID] [--base-url URL] [--dry-run]"; }
while (($#)); do case "$1" in
  --bundle-url) BUNDLE_URL="$2"; shift 2;; --sha256) SHA256="$2"; shift 2;; --name) NAME="$2"; shift 2;;
  --owner-ids) OWNER_IDS="$2"; shift 2;; --group-id) GROUP_ID="$2"; shift 2;; --base-url) BASE_URL="$2"; shift 2;;
  --model) MODEL="$2"; shift 2;; --profile) PROFILE="$2"; shift 2;; --module) MODULES+=("$2"); shift 2;; --full-bundle) FULL_BUNDLE=1; shift;; --dry-run) DRY_RUN=1; shift;; *) usage; exit 2;; esac; done
[[ -n "$BUNDLE_URL" && -n "$SHA256" && -n "$NAME" && -n "$OWNER_IDS" && -n "$MODEL" ]] || { usage; exit 2; }
command -v curl >/dev/null || { echo 'curl is required'; exit 1; }
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
curl -fsSL --retry 3 --retry-delay 1 "$BUNDLE_URL" -o "$WORK/native-full-bundle.tar.gz"
printf '%s  %s\n' "$SHA256" "$WORK/native-full-bundle.tar.gz" | sha256sum -c -
tar -xzf "$WORK/native-full-bundle.tar.gz" -C "$WORK"
if [[ "$DRY_RUN" == 1 ]]; then echo "DRY-RUN: verified bundle for $NAME; native Unix installer is selected by OS."; exit 0; fi
case "$(uname -s)" in Darwin|Linux)
  ARGS=(--name "$NAME" --owner-ids "$OWNER_IDS" --group-id "$GROUP_ID" --base-url "$BASE_URL" --model "$MODEL" --profile "$PROFILE")
  for module in "${MODULES[@]}"; do ARGS+=(--module "$module"); done
  [[ "$FULL_BUNDLE" == 1 ]] && ARGS+=(--full-bundle)
  exec bash "$WORK/install-native-unix.sh" "${ARGS[@]}";;
  *) echo 'Unsupported OS'; exit 1;; esac
