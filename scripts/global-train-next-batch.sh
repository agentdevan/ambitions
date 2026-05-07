#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "global-train-next-batch.sh: Codex OS deterministic next-batch calculation"

STATUS_SOURCES=(
  "docs/codex/BATCH_REGISTRY.md"
  ".codex/reports/current-run-state.md"
  ".codex/reports/current-batch-train-state.md"
  "docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md"
  "docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md"
)

completed() {
  local id="$1"
  rg -q "Complete: ${id}\b|${id} is complete|${id} .*complete / (Green|Accepted Yellow)|${id} .*complete Green|${id} .*closed Green|${id} .*closed Accepted Yellow|\| [0-9A-Z]+ \| ${id} \| [^|]* \| [^|]* \| [^|]* \| [^|]* \| [^|]* \| No; complete" "${STATUS_SOURCES[@]}" 2>/dev/null
}

batch_name() {
  case "$1" in
    LDI05) echo "Source Claim Graph" ;;
    LDI06) echo "Requirement Slot Mapping" ;;
    LDI07) echo "Safe Alternate Seed Generation" ;;
    LDI08) echo "Life Graph Projection Binding" ;;
    LDI09) echo "Plan Recompiler Boundary" ;;
    LDI10) echo "Dream Review And User Choice" ;;
    LDI11) echo "Pack Source Supply Chain" ;;
    LDI12) echo "Evaluation Fixtures And Red Team" ;;
    LDI13) echo "Local-First Runtime Integration" ;;
    LDI14) echo "Capture Surface Integration" ;;
    LDI15) echo "Goal Seed And Projection Integration" ;;
    LDI16) echo "Recommendation And Start Here Integration" ;;
    LDI17) echo "Trust Receipts And Explanation Integration" ;;
    LDI18) echo "Privacy Controls And Sensitive Dream Handling" ;;
    LDI19) echo "Professional Boundary And Regulated Domain Proof" ;;
    LDI20) echo "Accessibility And Cognitive Load Proof" ;;
    LDI21) echo "End-To-End Scenario Proof" ;;
    LDI22) echo "Living Dream Intelligence Closeout" ;;
    AOS24) echo "AmbitionsOS Runtime Tail Gate" ;;
    AOS25) echo "AmbitionsOS Integration Tail Gate" ;;
    AOS26) echo "AmbitionsOS Evaluation Tail Gate" ;;
    AOS27) echo "AmbitionsOS Privacy Safety Tail Gate" ;;
    AOS28) echo "AmbitionsOS Experience Tail Gate" ;;
    AOS29) echo "AmbitionsOS Handoff Tail Gate" ;;
    AOS30) echo "AmbitionsOS Closeout" ;;
    FCP27) echo "App-Wide Flagship Audit And Remediation" ;;
    FCP28) echo "Final Visual Proof Packet" ;;
    FCP29) echo "Accessibility And Dynamic Type Closeout" ;;
    FCP30) echo "Flagship Completion Handoff" ;;
    PFC31) echo "Architecture Extraction Closeout" ;;
    PFC32) echo "Build And Test Determinism Closeout" ;;
    PFC33) echo "External Surface Release Evidence" ;;
    PFC34) echo "Privacy Legal Review Reconciliation" ;;
    PFC35) echo "Security And Threat Model Reconciliation" ;;
    PFC36) echo "Performance And Observability Reconciliation" ;;
    PFC37) echo "Release Engineering Evidence" ;;
    PFC38) echo "Signed Candidate Preparation Gate" ;;
    PFC39) echo "Final Platform Handoff" ;;
    PFC40) echo "Platform Framework Compliance Closeout" ;;
    RHC01) echo "Repo Hygiene Triage And Owner Map" ;;
    RHC02) echo "Large File Extraction And Module Boundary" ;;
    RHC03) echo "Placeholder Stub And Compatibility Seam Cleanup" ;;
    RHC04) echo "Stale Copy Docs And Generated Artifact Hygiene" ;;
    RHC05) echo "Validation Script Noise And Allowlist Hardening" ;;
    RHC06) echo "Repo Hygiene Closeout And Handoff" ;;
    *) echo "Unknown" ;;
  esac
}

# Live state wins. This prevents stale legacy order files from overriding an
# already-advanced active run, while still letting the deterministic queue take
# over when run-state has no usable next pointer.
live_next="$(sed -n 's/^Next eligible batch: //p' .codex/reports/current-run-state.md 2>/dev/null | head -n 1 || true)"
if [[ -n "$live_next" ]]; then
  live_id="${live_next%% *}"
  if [[ "$live_id" =~ ^(LDI|AOS|FCP|PFC|RHC)[0-9A-Z]+$ ]] && ! completed "$live_id"; then
    echo "Next eligible batch: $live_next"
    echo "Source: .codex/reports/current-run-state.md"
    exit 0
  fi
fi

ORDER=(
  LDI05 LDI06 LDI07 LDI08 LDI09 LDI10 LDI11 LDI12 LDI13 LDI14 LDI15 LDI16 LDI17 LDI18 LDI19 LDI20 LDI21 LDI22
  AOS24 AOS25 AOS26 AOS27 AOS28 AOS29 AOS30
  FCP27 FCP28 FCP29 FCP30
  PFC31 PFC32 PFC33 PFC34 PFC35 PFC36 PFC37 PFC38 PFC39 PFC40
  RHC01 RHC02 RHC03 RHC04 RHC05 RHC06
)

for id in "${ORDER[@]}"; do
  if ! completed "$id"; then
    echo "Next eligible batch: $id $(batch_name "$id")"
    if [[ "$id" == RHC* ]]; then
      echo "Source: queued RHC after full-stack tails"
    else
      echo "Source: full-stack overlay fallback order"
    fi
    exit 0
  fi
done

echo "Next eligible batch: none"
echo "Source: full-stack overlay and queued RHC appear complete"
