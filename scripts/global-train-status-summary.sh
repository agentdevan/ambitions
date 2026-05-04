#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "global-train-status-summary.sh: Codex OS deterministic status summary"
completed() {
  local id="$1"
  rg -q "Complete: $id|$id is complete|\| [0-9]{3} \| $id \| [^|]* \| [^|]* \| [^|]* \| [^|]* \| [^|]* \| No; complete" docs/codex/BATCH_REGISTRY.md .codex/reports/current-run-state.md docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md 2>/dev/null
}
for id in EB01 EB13 EB25 EB19 EB02 EB07 EB31 EB32 DAV01 DAV02 DAV03 DAV04 DAV05 DAV06 DAV07 DAV08 DAV09 DAV10 DAV11 DAV12 DAV13 DAV14 DAV15 EB20 EB21 EB22 EB23 EB24 EB03A EB03B EB04 EB05 EB06 EB14 EB15 EB16 EB17 EB18 EB26 EB27 EB28 EB29 EB30; do
  if ! completed "$id"; then
    case "$id" in
    EB01) name="External Brain Source Truth And Kernel Architecture"; global="047" ;;
    EB13) name="Trust Privacy User Control Canon"; global="048" ;;
    EB25) name="Accessibility Cognitive Load Canon"; global="049" ;;
    EB19) name="Product Maturity Onboarding Canon"; global="050" ;;
    EB02) name="Universal Capture Canon And Domain Model"; global="051" ;;
    EB07) name="Life Memory Graph Canon And Domain Model"; global="052" ;;
    EB31) name="Cross Kernel Primitives And Event Receipts"; global="053" ;;
    EB32) name="Cross Kernel Dependency And Gate Integration"; global="054" ;;
    DAV01) name="Dynamic Visual Source Truth And Surface Map"; global="055" ;;
    DAV02) name="Reusable Living Visual Primitives Implementation"; global="056" ;;
    DAV03) name="Today DayTimelineRail And HeroStepPanel Implementation"; global="057" ;;
    DAV04) name="Capture AtmosphereComposer And RoutingReceipts Implementation"; global="058" ;;
    DAV05) name="Plan LifeShapeMap And CapacityVisuals Implementation"; global="059" ;;
    DAV06) name="Goals MissionControlLanes Implementation"; global="060" ;;
    DAV07) name="You SystemProfilePanel And GroupedNavigation Implementation"; global="061" ;;
    DAV08) name="Memory ContextRecall And MemoryConstellation Implementation"; global="062" ;;
    DAV09) name="TrustReceiptStack EvidenceLabels And ProofPulse Implementation"; global="063" ;;
    DAV10) name="AdaptiveMotion ReduceMotion And StateTransitions"; global="064" ;;
    DAV11) name="DynamicType VoiceOver And VisualAccessibility Closeout"; global="065" ;;
    DAV12) name="SurfacePreviewFixtures And ScenarioGallery"; global="066" ;;
    DAV13) name="VisualPerformance Rendering And BatteryRisk"; global="067" ;;
    DAV14) name="VisualRegression And ProductExperience QA"; global="068" ;;
    DAV15) name="Dynamic Adaptive Visual System Closeout"; global="069" ;;
    EB20) name="Value Based Onboarding And First Week Success"; global="070" ;;
    EB21) name="Concierge Setup And Planning Defaults Onboarding"; global="071" ;;
    EB22) name="Privacy Setup And Trust Onboarding"; global="072" ;;
    EB23) name="Maturity Levels Progressive Disclosure And Life Season Templates"; global="073" ;;
    EB24) name="Onboarding Receipts Skip Later And Setup Recovery"; global="074" ;;
    EB03A) name="Universal Capture Composer Routing Owner Map"; global="075A" ;;
    EB03B) name="Universal Capture Composer Routing Implementation"; global="075B" ;;
    EB04) name="Capture Classification And Clarification"; global="076" ;;
    EB05) name="Capture Clusters Review Bundles And Open Loops"; global="077" ;;
    EB06) name="Capture Receipts Undo And Reclassification"; global="078" ;;
    EB14) name="Trust Center And Data Map"; global="079" ;;
    EB15) name="Recommendation Evidence And Inference Boundaries"; global="080" ;;
    EB16) name="Private Mode And Sensitive Area Controls"; global="081" ;;
    EB17) name="Undo Correction Audit Trail And Export"; global="082" ;;
    EB18) name="Source Freshness Privacy Receipts And Non Claims"; global="083" ;;
    EB26) name="Cognitive Load Modes"; global="084" ;;
    EB27) name="Dynamic Type VoiceOver Reduce Motion"; global="085" ;;
    EB28) name="Plain Language Anxiety Safe Copy And Explain This Screen"; global="086" ;;
    EB29) name="Voice First Operation And Motor Accessibility"; global="087" ;;
    EB30) name="Overloaded Day Adaptation And Low Cognitive Load Flows"; global="088" ;;
      *) name="Unknown"; global="unknown" ;;
    esac
    echo "Active train: Ambitions 4.0 External Brain Foundation"
    echo "Total planned batches: 168"
    echo "Next eligible batch: $id $name"
    echo "Global order: $global"
    echo "Working tree:"
    git status --short
    exit 0
  fi
done
echo "Next eligible batch: EB08 Memory Source Confidence And Trust Decay"
echo "Global order: 089"
echo "Total planned batches: 168"
echo "Working tree:"
git status --short
