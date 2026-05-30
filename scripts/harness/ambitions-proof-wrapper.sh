#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

die() {
  echo "RED: $*" >&2
  exit 1
}

batch_id=""
inventory_only=0
output_root="build/reports/harness"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --batch)
      [[ $# -ge 2 ]] || die "--batch requires a value"
      batch_id="$2"
      shift 2
      ;;
    --inventory-only)
      inventory_only=1
      shift
      ;;
    --output-root)
      [[ $# -ge 2 ]] || die "--output-root requires a value"
      output_root="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage: scripts/harness/ambitions-proof-wrapper.sh --batch <batch-id> [--inventory-only] [--output-root <dir>]

The wrapper is inventory-only by default. It does not build the app.
EOF
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

[[ -n "$batch_id" ]] || die "--batch is required"

timestamp_utc="$(date -u +%Y%m%dT%H%M%SZ)"
safe_batch_id="$(printf '%s' "$batch_id" | tr -c 'A-Za-z0-9._-' '-')"
run_dir="$output_root/$safe_batch_id/$timestamp_utc"
manifest_path="$run_dir/artifact-manifest.json"
summary_path="$run_dir/artifact-summary.md"
wrapper_json_path="$run_dir/wrapper-inventory.json"
wrapper_md_path="$run_dir/wrapper-inventory.md"

mkdir -p "$run_dir"

helper_command=(
  python3 scripts/harness/ambitions-artifact-helper.py
  --batch "$batch_id"
  --output-dir "$run_dir"
  --timestamp-utc "$timestamp_utc"
  --mode "inventory-only"
  --command "bash scripts/harness/ambitions-proof-wrapper.sh --inventory-only --batch $batch_id"
  --risk "No build is performed by this wrapper."
  --claim-not-made "No app build claim."
  --claim-not-made "No app test claim."
  --claim-not-made "No simulator claim."
  --claim-not-made "No accessibility claim."
  --claim-not-made "No performance claim."
  --claim-not-made "No device claim."
  --claim-not-made "No TestFlight claim."
  --claim-not-made "No App Store claim."
  --claim-not-made "No release readiness claim."
  --next-recommended-step "Run the static gates and review the manifest before any future batch widening."
)

if [[ "$inventory_only" -eq 1 ]]; then
  "${helper_command[@]}"
else
  "${helper_command[@]}"
fi

python3 - "$batch_id" "$timestamp_utc" "$manifest_path" "$summary_path" "$wrapper_json_path" "$wrapper_md_path" <<'PY'
from __future__ import annotations

import json
import sys
from pathlib import Path

batch_id, timestamp_utc, manifest_path, summary_path, wrapper_json_path, wrapper_md_path = sys.argv[1:7]
manifest_path = Path(manifest_path)
summary_path = Path(summary_path)
wrapper_json_path = Path(wrapper_json_path)
wrapper_md_path = Path(wrapper_md_path)

payload = {
    "schema_version": "1.0",
    "batch_id": batch_id,
    "mode": "inventory-only",
    "timestamp_utc": timestamp_utc,
    "output_dir": str(manifest_path.parent),
    "manifest_path": str(manifest_path.resolve().relative_to(Path.cwd())),
    "summary_path": str(summary_path.resolve().relative_to(Path.cwd())),
    "commands": [
        f"scripts/harness/ambitions-proof-wrapper.sh --inventory-only --batch {batch_id}",
    ],
    "claims_not_made": [
        "No build claim.",
        "No app test claim.",
        "No simulator claim.",
        "No accessibility claim.",
        "No performance claim.",
        "No device claim.",
        "No TestFlight claim.",
        "No App Store claim.",
        "No release readiness claim.",
    ],
}

wrapper_json_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
wrapper_md_path.write_text(
    "\n".join(
        [
            "# Harness Proof Wrapper Inventory",
            "",
            f"Batch ID: {batch_id}",
            f"Mode: inventory-only",
            f"Timestamp UTC: {timestamp_utc}",
            f"Manifest: {payload['manifest_path']}",
            f"Summary: {payload['summary_path']}",
            "",
            "## Claims Not Made",
            *[f"- {item}" for item in payload["claims_not_made"]],
            "",
        ]
    ),
    encoding="utf-8",
)
PY

printf '%s\n' "$manifest_path" "$summary_path" "$wrapper_json_path" "$wrapper_md_path"
echo "GREEN: harness proof wrapper inventory-only run completed"
echo "mode: inventory-only"
echo "build: skipped"
echo "tests: skipped"
echo "release claims: not made"
