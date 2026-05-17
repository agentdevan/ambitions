# Codex OS Repair Plan

Generated: 2026-05-17T19:24:47-04:00

## governance repair

Governance outputs are not fully reconciled.

### Signals

- repo_doctor_failures:0
- unresolved:151
- stale:1369

### Command

```bash
python3 scripts/governance/ambitions-repo-doctor.py --strict
```

## canon propagation repair

Canon inputs changed and propagation outputs require refresh.

### Signals

- retired:Native/Ambitions/Domain/GoalEngine/GoalEngineAdaptationService.swift
- retired:Native/Ambitions/Domain/HabitsModels.swift
- retired:Native/Ambitions/Domain/Planning/LivingPlanRecompiler.swift
- retired:Native/Ambitions/Domain/Planning/PlanningEvaluation.swift
- retired:Native/Ambitions/Domain/SafeAutomationPolicyModels.swift
- retired:Native/Ambitions/Domain/SmartAttachmentModels.swift
- retired:Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift
- retired:Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotBuilder.swift
- retired:Native/Ambitions/Features/Capture/CapturePlacementReviewState.swift
- retired:Native/Ambitions/Features/Goals/GoalsFeatureModels.swift

### Command

```bash
python3 scripts/governance/ambitions-canon-installer.py
```

## global train sequencing repair

Train sequencing should be refreshed when governance debt stays elevated.

### Signals

- debt_score:0
- cleanup_present:True

### Command

```bash
python3 scripts/governance/ambitions-global-train-resequencer.py
```

## archive/shrink repair

Archive and shrink recommendations are present.

### Signals

- cleanup plan output exists

### Command

```bash
python3 scripts/governance/ambitions-cleanup-action-plan.py
```
