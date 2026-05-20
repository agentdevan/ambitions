<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Frontend Implementation Prompt: TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01

Batch ID: `TODAY-REALITY-MERIDIAN-FLAGSHIP-IMPLEMENTATION-01`
Surface ID: `today_root_reality_meridian`
Objective: Implement only within the declared source scope for Today Root / Reality Meridian.
Packet path: `build/reports/frontend-authority-packets/today_root_reality_meridian.md`
Preflight path: `build/reports/frontend-authority-preflight/today_root_reality_meridian.md`

## Active Source Truth to Inspect
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `frontend/visual-encyclopedia/ENCYCLOPEDIA_TO_FRONTEND_OS.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `frontend/visual-encyclopedia/SIGNATURE_VISUAL_INSTRUMENTS.md`
- `frontend/visual-encyclopedia/trace/SIGNATURE_VISUAL_INSTRUMENTS_MATRIX.yaml`
- `frontend/visual-encyclopedia/recipes/today/today_root_reality_meridian.md`
- `frontend/visual-encyclopedia/surfaces/TODAY_REALITY_MERIDIAN_BIBLE.md`

## Signature Visual Instrument Requirements
- owning instrument id: `reality_meridian_instrument`
- owning instrument name: `Reality Meridian Instrument`
- instrument required: `True`
- instrument implementation status before this batch: `intended_authority_pending_source_proof`
- guidance: Use or create a dedicated visual-object SwiftUI component rather than burying this instrument inside a root screen file.

### Shared Instrument Primitives
- `LivingBackground`
- `LiveTelemetryPanel`
- `ContextualDrilldownHeader`
- `MetricInstrumentChart`

### Future Dedicated Visual Object Files
- `Native/Ambitions/Features/Today/RealityMeridianSurface.swift`
- `Native/Ambitions/Features/Today/RealityMeridianLiveStatePanel.swift`
- `Native/Ambitions/Features/Today/RealityMeridianContinuitySpine.swift`

### Native SwiftUI Technique Candidates
- `Canvas`
- `Shape`
- `Path`
- `GeometryReader`
- `TimelineView`
- `matchedGeometryEffect`

### Visual Regression Guardrails
- `generic task list`
- `generic dashboard`
- `disconnected card stack`
- `shame language`
- `opaque model-certainty language`

## Instrument Implementation Rules
- Do not implement this surface as a generic card stack, static form, or list-only screen when it owns a signature instrument.
- Prefer a dedicated SwiftUI visual-object component file for high-end instruments instead of burying the visual object inside the root screen.
- Back the instrument with typed ViewState and preview fixtures.
- Use AmbitionTheme and generated tokens; do not introduce hardcoded visual values when tokens exist.
- Synthesize the instrument principles from the encyclopedia. Do not copy external app layouts, wording, brand marks, or mechanics.

## Allowed Source Targets
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayViewModel.swift`
- `Native/Ambitions/Features/Today/TodayExecutionViewState.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`

## Forbidden Scope
- unrelated surfaces
- top-level IA changes
- Plan as an active destination
- chatbot UI
- generic dashboard/card/task-list fallback
- persistence changes
- routing changes
- release or device proof claims

## Source Binding Requirements
- Use only the source files declared by the packet or explicitly extend scope with a reason in the receipt.
- Do not treat packet generation as implementation proof.
- Record instrument source binding status in the implementation receipt.

## Token and Contract Requirements
- `Sources/Theme/AmbitionObjectTokens.generated.swift`
- `Sources/Theme/AmbitionStateTokens.generated.swift`
- `frontend/visual-encyclopedia/primitives/RECEIPT_PRIMITIVES.md`
- `frontend/visual-encyclopedia/contracts/PROOF_CHIP_CONTRACT.md`
- `frontend/visual-encyclopedia/contracts/RECEIPT_CONTRACT.md`
- `frontend/visual-encyclopedia/contracts/TRUST_SEAM_CONTRACT.md`

## Scenario Proof Requirements
- Preserve the required scenario coverage for the surface.
- Do not claim proof without the matching receipt and preview/proof artifacts.

## Interaction Grammar Requirements
- Preserve the object-first interaction grammar.
- Keep visible alternatives for source, proof, receipt, and recovery.

## Accessibility Requirements
- Dynamic Type proof required where the surface changes layout.
- Reduce Motion proof required where motion exists.
- VoiceOver proof required for the object/state/action order.
- No color-only state meaning.

## Visual Proof Requirements
- Use previews or screenshots only when the surface implementation actually changes.
- Do not claim implementation proof from generated docs alone.

## Implementation Receipt Requirements
- Emit a receipt only after the changed files, proof, and drift results are known.
- Record known gaps explicitly.
- Include signature_instrument_id, shared_instrument_primitives, visual_object_source_file, and instrument_implementation_status.

## Drift Check Requirements
- Run the frontend drift checker after the change set lands.
- Keep the active IA labels exact.
- Ensure the instrument-owned surface does not regress to generic cards/lists/forms.

## Validation Commands
- `git diff --check`
- `python3 scripts/ambitions-frontend-authority-preflight.py --surface today_root_reality_meridian`
- `python3 scripts/ambitions-signature-visual-instruments-check.py`
- `python3 scripts/ambitions-frontend-source-bindings.py`
- `python3 scripts/ambitions-frontend-drift-check.py`
- `python3 scripts/ambitions-frontend-implementation-dashboard.py`
- `python3 scripts/ambitions-frontend-next-surface-queue.py`
- `python3 scripts/ambitions-frontend-receipt-check.py`
- `python3 scripts/ambitions-frontend-proof-contract-check.py`

## Hard Red Conditions
- Do not invent layout outside the packet.
- Do not touch unrelated surfaces.
- Do not add chatbot UI.
- Do not reintroduce Plan as a top-level destination.
- Do not claim implementation, accessibility, device, or release proof without evidence.
- Do not ship a generic card/list-only surface when this packet declares an owning signature instrument.

## Rollback Expectations
- Restore only the files touched by the batch.
- Remove any generated receipt or report that does not match the committed source.

## Final Response Format
- Report changed files, validation run, remaining gaps, and final status.
- End with `STATUS: GREEN|YELLOW|RED`.
