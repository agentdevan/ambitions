#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
STRICT="${CQS_STRICT:-0}"
PATTERN='API_KEY|SECRET|TOKEN|PRIVATE_KEY|password|sensitive data|tracked|monitored|surveillance|privacy compliant|HIPAA|GDPR compliant|App Store ready|TestFlight ready|release ready|physical device passed|accessibility compliant'

echo "CQS privacy security claim scan"
echo "Root: ${ROOT}"

set +e
rg -n -i --hidden --glob '!/.git/**' --glob '!Ambitions.xcodeproj/**' "${PATTERN}" "${ROOT}"
STATUS=$?
set -e

if [[ "${STATUS}" -eq 0 ]]; then
  echo "CQS_PRIVACY_SECURITY_CLAIM_HITS=1"
  [[ "${STRICT}" == "1" ]] && exit 1
  exit 0
fi

if [[ "${STATUS}" -eq 1 ]]; then
  echo "CQS_PRIVACY_SECURITY_CLAIM_HITS=0"
  exit 0
fi

echo "CQS_PRIVACY_SECURITY_CLAIM_SCAN_ERROR=${STATUS}"
exit "${STATUS}"
