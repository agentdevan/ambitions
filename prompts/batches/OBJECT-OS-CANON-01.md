<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

OBJECT-OS-CANON-01

# Objective

Install and preserve the Ambitions Object OS canon as a docs/control-plane layer. This canon defines Action Slip System, Proof Vault, Ambition Graph / Orbital Lens, Atmosphere Composer / Meaning Router, Personal Runtime, Native Object Surfaces, Simulation & Reflow Lab, and Founder QA Overlay as the premium object-based product grammar for Ambitions.

This prompt exists so future Codex sessions can preserve and repair the Object OS canon. The canon may guide MRI25-MRI34, FCP, PFC, visual/runtime, native-surface, and QA work, but this batch itself must not implement runtime source.

# Active Source Truth To Inspect

- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/truth/RELEASE_TRUTH.md
- docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md
- docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md
- docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json
- docs/codex/AMBITIONS_OBJECT_OS_CANON.md
- docs/codex/OBJECT_OS_SURFACE_MAP.md
- docs/codex/OBJECT_OS_PRIMITIVES.md
- docs/codex/OBJECT_OS_MOTION_GRAMMAR.md
- docs/codex/OBJECT_OS_NATIVE_SURFACES.md
- docs/codex/OBJECT_OS_MRI25_34_UPGRADE_OVERLAY.md
- docs/codex/OBJECT_OS_ACCEPTANCE_GATES.md
- docs/codex/OBJECT_OS_INDEX.md

# Allowed Scope

- docs/codex/AMBITIONS_OBJECT_OS_CANON.md
- docs/codex/OBJECT_OS_SURFACE_MAP.md
- docs/codex/OBJECT_OS_PRIMITIVES.md
- docs/codex/OBJECT_OS_MOTION_GRAMMAR.md
- docs/codex/OBJECT_OS_NATIVE_SURFACES.md
- docs/codex/OBJECT_OS_MRI25_34_UPGRADE_OVERLAY.md
- docs/codex/OBJECT_OS_ACCEPTANCE_GATES.md
- docs/codex/OBJECT_OS_INDEX.md
- docs/audits/object-os-canon-01-report.md
- prompts/batches/OBJECT-OS-CANON-01.md

# Forbidden Scope

- No Native/Ambitions/** changes.
- No Native/AmbitionsTests/** changes.
- No Package.swift changes.
- No project.yml changes.
- No .github workflow changes.
- No signing, entitlement, release automation, hosted backend, analytics, telemetry, or app runtime OpenAI integration.
- No active SA/MRI queue state changes unless explicitly repairing this canon batch metadata.
- No runtime UI implementation.
- No native extension implementation.

# Required Preservation Rules

The Object OS canon must preserve these eight systems:

1. Action Slip System
2. Proof Vault
3. Ambition Graph / Orbital Lens
4. Atmosphere Composer / Meaning Router
5. Personal Runtime
6. Native Object Surfaces
7. Simulation & Reflow Lab
8. Founder QA Overlay

The canon must preserve the core product statement:

Ambitions does not manage tasks. Ambitions manages private life objects through proof-backed execution.

# Validation Expectations

Run and record exit codes:

```bash
git diff --check
make prompt-audit
python3 scripts/ambitions-unsupported-claim-scan.py \
  docs/codex/AMBITIONS_OBJECT_OS_CANON.md \
  docs/codex/OBJECT_OS_SURFACE_MAP.md \
  docs/codex/OBJECT_OS_PRIMITIVES.md \
  docs/codex/OBJECT_OS_MOTION_GRAMMAR.md \
  docs/codex/OBJECT_OS_NATIVE_SURFACES.md \
  docs/codex/OBJECT_OS_MRI25_34_UPGRADE_OVERLAY.md \
  docs/codex/OBJECT_OS_ACCEPTANCE_GATES.md \
  docs/codex/OBJECT_OS_INDEX.md \
  docs/audits/object-os-canon-01-report.md
```

No xcodegen or xcodebuild required because this is docs/control-plane only.

# Hard Red Stop Conditions

- Runtime app source is changed.
- Object OS is described as already implemented in runtime.
- Release/TestFlight/App Store/device/accessibility/performance/privacy/legal readiness is claimed.
- Generic task/calendar/dashboard/chatbot direction is introduced.
- External/cloud LLM runtime dependency is introduced.
- Native surfaces bypass command/event, side-effect, receipt, or trust boundaries.

# Final Report Requirements

Create or update:

```text
docs/audits/object-os-canon-01-report.md
```

Report must include:

- files created/updated
- Object OS systems preserved
- MRI25-MRI34 impact
- validation commands and outcomes
- no-claim boundaries
- rollback notes

# Claims Not Made

Do not claim:

- runtime Object OS implementation complete
- visual runtime complete
- widgets/Live Activities/App Intents implemented
- release readiness
- TestFlight readiness
- App Store readiness
- physical-device proof
- public accessibility conformance
- performance validation
- privacy/legal approval
- global train completion
