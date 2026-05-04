#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "global-train-next-batch.sh: Codex OS deterministic next-batch calculation"
completed() {
  local id="$1"
  rg -q "Complete: $id|$id is complete|\| [0-9]{3} \| $id \| [^|]* \| [^|]* \| [^|]* \| [^|]* \| [^|]* \| No; complete" docs/codex/BATCH_REGISTRY.md .codex/reports/current-run-state.md docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md 2>/dev/null
}
for id in EB01 EB13 EB25 EB19 EB02 EB07 EB31 EB32 DAV01 DAV02 DAV03 DAV04 DAV05 DAV06 DAV07 DAV08 DAV09 DAV10 DAV11 DAV12 DAV13 DAV14 DAV15 EB20 EB21 EB22 EB23 EB24 EB03A EB03B EB04 EB05 EB06 EB14 EB15 EB16 EB17 EB18 EB26 EB27 EB28 EB29 EB30 EB08 EB09 EB10 EB11 EB12 EB33 EB34 EB35 EB36 EB37 EB38 EB39 EB40 CS10 SI01 SI02 SI03 SI04 SI05 SI06 SI07 SI08 SI09 SI10 SI11 SI12 SI13 SI14 SI15 SI16 SI17 SI18; do
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
    EB08) name="Memory Source Confidence And Trust Decay"; global="089" ;;
    EB09) name="Life Event Decision And Context Recall Memory"; global="090" ;;
    EB10) name="Personal Operating Manual And Preferences"; global="091" ;;
    EB11) name="Memory Correction Deletion And Rejection"; global="092" ;;
    EB12) name="Memory Receipts And Why Remembered This"; global="093" ;;
    EB33) name="Search Recall And Context Retrieval"; global="094" ;;
    EB34) name="External Brain Command Surface Integration"; global="095" ;;
    EB35) name="External Brain Preview Fixtures And Scenario Library"; global="096" ;;
    EB36) name="External Brain QA Regression And Risk Register"; global="097" ;;
    EB37) name="External Brain Privacy Threat Model"; global="098" ;;
    EB38) name="External Brain Accessibility Evidence Closeout"; global="099" ;;
    EB39) name="External Brain Handoff And RC Readiness Implications"; global="100" ;;
    EB40) name="Ambitions 4.0 External Brain Closeout"; global="101" ;;
    CS10) name="Compatibility Retirement Handoff"; global="102" ;;
    SI01) name="Signature Interface Architecture"; global="103" ;;
    SI02) name="Adaptive Panel Action And Module Foundation"; global="104" ;;
    SI03) name="App Shell IA And Navigation List System"; global="105" ;;
    SI04) name="DayTimelineRail 2.0"; global="106" ;;
    SI05) name="Hero Step Panel System"; global="107" ;;
    SI06) name="LifePath Visualization System"; global="108" ;;
    SI07) name="Mission Control Lane Components"; global="109" ;;
    SI08) name="LifeShape Time Capacity Map"; global="110" ;;
    SI09) name="Capture Atmosphere Composer"; global="111" ;;
    SI10) name="Trust Receipt Layer"; global="112" ;;
    SI11) name="Personal System Center Components"; global="113" ;;
    SI12) name="Interaction Motion Haptics System"; global="114" ;;
    SI13) name="Loading Empty Degraded State Primitives"; global="115" ;;
    SI14) name="Iconography Symbol And Status Grammar"; global="116" ;;
    SI15) name="Accessibility Adaptive Interface Pass"; global="117" ;;
    SI16) name="Preview Fixture And Visual QA Infrastructure"; global="118" ;;
    SI17) name="Top-Level Surface Composition Implementation"; global="119" ;;
    SI18) name="Signature Interface Handoff And Product Depth Readiness"; global="120" ;;
      *) name="Unknown"; global="unknown" ;;
    esac
    echo "Next eligible batch: $id $name"
    echo "Global order: $global"
    exit 0
  fi
done
echo "Next eligible batch: PD01 Product Depth Train"
echo "Global order: 121"
