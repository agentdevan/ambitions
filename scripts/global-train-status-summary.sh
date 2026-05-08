#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "global-train-status-summary.sh: Codex OS deterministic status summary"

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
    PK00) echo "Current Backend Proof Baseline" ;;
    PK01) echo "Package/Module Boundary Scaffold" ;;
    PK02) echo "Architecture Boundary Scanner" ;;
    PK03) echo "AppUnitOfWork Foundation" ;;
    PK04) echo "Atomic Goal Creation" ;;
    PK05) echo "Atomic Clarification / Materialization" ;;
    PK06) echo "Atomic Capture Promotion" ;;
    PK07) echo "Storage Schema Version Ledger" ;;
    PK08) echo "Migration Plan Scaffold" ;;
    PK09) echo "Unknown Persisted Value Degradation" ;;
    PK10) echo "Storage Invariant Checker" ;;
    PK11) echo "Pre-Migration Backup" ;;
    PK12) echo "Staged Portable Import Dry Run" ;;
    PK13) echo "Restore Rollback" ;;
    PK14) echo "Durable Command/Event Ledger" ;;
    PK15) echo "Receipt Backend" ;;
    PK16) echo "Trust History Query" ;;
    PK17) echo "Today Read Model Extraction" ;;
    PK18) echo "Today Command Handler Extraction" ;;
    PK19) echo "Goals Query/Projector Extraction" ;;
    PK20) echo "Capture Service Extraction" ;;
    PK21) echo "Plan Service Extraction" ;;
    PK22) echo "SideEffectLedger Foundation" ;;
    PK23) echo "Notifications Through SideEffectLedger" ;;
    PK24) echo "EventKit Through SideEffectLedger" ;;
    PK25) echo "External Snapshots Through SideEffectLedger" ;;
    PK26) echo "Privacy Classification System" ;;
    PK27) echo "Diagnostic Ledger" ;;
    PK28) echo "Data Control Commands" ;;
    PK29) echo "Entity Revision And Tombstones" ;;
    PK30) echo "Conflict Policy Engine" ;;
    PK31) echo "Manual Portable Sync Merge" ;;
    PK32) echo "Knowledge Claim Boundary Hardening" ;;
    PK33) echo "Recommendation Evidence Model" ;;
    PK34) echo "Intelligence Quarantine" ;;
    PK35) echo "Large-Store Fixture Generator" ;;
    PK36) echo "Performance Budgets" ;;
    PK37) echo "Derived Read-Model Cache" ;;
    PK38) echo "Move Domain To Package" ;;
    PK39) echo "Move Storage To Package" ;;
    PK40) echo "Move Runtime To Package" ;;
    PK41) echo "Move Feature Engines To Package" ;;
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

live_next="$(sed -n 's/^Next eligible batch: //p' .codex/reports/current-run-state.md 2>/dev/null | head -n 1 || true)"
if [[ -n "$live_next" ]]; then
  live_id="${live_next%% *}"
  if [[ "$live_id" =~ ^(PK|LDI|AOS|FCP|PFC|RHC)[0-9A-Z]+$ ]] && ! completed "$live_id"; then
    echo "Active train: Global full-stack execution"
    echo "Total planned batches: live full-stack overlay with PK insertion, not legacy 190"
    echo "Next eligible batch: $live_next"
    echo "Source: .codex/reports/current-run-state.md"
    echo "Queued cleanup train: RHC01-RHC06 after LDI/AOS/FCP/PFC tails unless blocking hygiene Red requires scoped repair"
    echo "Working tree:"
    git status --short
    exit 0
  fi
fi

ORDER=(
  PK00 PK01 PK02 PK03 PK04 PK05 PK06 PK07 PK08 PK09 PK10 PK11 PK12 PK13 PK14 PK15 PK16 PK17 PK18 PK19 PK20 PK21 PK22 PK23 PK24 PK25 PK26 PK27 PK28 PK29 PK30 PK31 PK32 PK33 PK34 PK35 PK36 PK37 PK38 PK39 PK40 PK41
  LDI05 LDI06 LDI07 LDI08 LDI09 LDI10 LDI11 LDI12 LDI13 LDI14 LDI15 LDI16 LDI17 LDI18 LDI19 LDI20 LDI21 LDI22
  AOS24 AOS25 AOS26 AOS27 AOS28 AOS29 AOS30
  FCP27 FCP28 FCP29 FCP30
  PFC31 PFC32 PFC33 PFC34 PFC35 PFC36 PFC37 PFC38 PFC39 PFC40
  RHC01 RHC02 RHC03 RHC04 RHC05 RHC06
)

for id in "${ORDER[@]}"; do
  if ! completed "$id"; then
    echo "Active train: Global full-stack execution"
    echo "Total planned batches: live full-stack overlay with PK insertion, not legacy 190"
    echo "Next eligible batch: $id $(batch_name "$id")"
    if [[ "$id" == RHC* ]]; then
      echo "Source: queued RHC after full-stack tails"
    else
      echo "Source: full-stack overlay fallback order"
    fi
    echo "Working tree:"
    git status --short
    exit 0
  fi
done

echo "Active train: Global full-stack execution"
echo "Total planned batches: live full-stack overlay with PK insertion, not legacy 190"
echo "Next eligible batch: none"
echo "Source: full-stack overlay and queued RHC appear complete"
echo "Working tree:"
git status --short
