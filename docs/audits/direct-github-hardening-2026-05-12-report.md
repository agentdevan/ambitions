# Direct GitHub Hardening Pass — 2026-05-12

Status: GitHub-side source/control-plane hardening complete; local runner validation not executed in this chat.

## Scope

This pass implements the ten requested narrow, high-confidence seams that can be patched from GitHub without pretending to run a full Ambitions implementation batch.

It intentionally does not claim:

- PK22 completion.
- local runner execution.
- xcodegen proof.
- xcodebuild proof.
- simulator/device proof.
- release/TestFlight/App Store readiness.
- public accessibility conformance.
- performance proof.
- privacy/legal approval.
- runtime visual canon completion.

## Completed direct patches

1. **PK22 prompt repair**
   - File: `prompts/batches/PK22.md`
   - Commit: `aa9074976e17f83ce68322a52fa1b9df5b8f8ccf`
   - Result: PK22 now reflects `executable_now`, PK21 Green dependency, exact owner seams, explicit PK22-only foundation scope, and hard blocks against collapsing PK23-PK25.

2. **Capture proof/constraint route mapping helper**
   - File: `Native/Ambitions/Domain/CaptureRouteCommandMapping.swift`
   - Commit: `591895d67466d0a4ef88b99cb5b2a4e472cada3a`
   - Result: Adds explicit mapping for `proof_item` and `constraint_item`, plus all existing safe route aliases.
   - Caveat: The large existing `AmbitionsCommandExecutor.route(for:)` body was not rewritten in this GitHub-side pass because that needs local compile proof.

3. **Capture route mapping tests**
   - File: `Native/AmbitionsTests/Domain/CaptureRouteCommandMappingTests.swift`
   - Commit: `978eec6095a4f14478426c7702e17111cf3ade1b`
   - Result: Locks proof/constraint route handling and legacy alias behavior.

4. **SideEffectLedger domain foundation**
   - File: `Native/Ambitions/Domain/SideEffectLedgerModels.swift`
   - Commit: `808461494a24c64a946e416eec6379250c65dfa4`
   - Result: Adds local-first SideEffectLedger record model, effect/status/boundary taxonomies, decision bridge from `SafeAutomationPolicyDecision`, command bridge from `AmbitionsCommand`, repository protocol, and in-memory repository.
   - Explicitly avoids SwiftData schema changes, NotificationCenter scheduling, EventKit writes, sync, export execution, and external snapshot execution.

5. **SideEffectLedger focused tests**
   - File: `Native/AmbitionsTests/Domain/SideEffectLedgerModelsTests.swift`
   - Commit: `287cacb3d0a7b96c03de84f63b8d83f3801d3760`
   - Result: Tests confirmation-required calendar decisions, draft-only export, sync safe failure, local-only reversible records, external-surface command records, and in-memory repository sorting/deduplication.

6. **Optional policy-guarded command executor seam**
   - File: `Native/Ambitions/Services/PolicyGuardedCommandExecutor.swift`
   - Commit: `4dc4e7636dd1470e68c15bc01e172430972dd89f`
   - Result: Adds an additive wrapper around any `CommandExecuting` implementation. It records a SideEffectLedger decision and blocks confirmation-required, unsupported, destructive, or external-effect behavior before delegating to the base executor.
   - This avoids risky broad edits to `AmbitionsCommandExecutor.swift` without local validation.

7. **Policy-guarded command executor tests**
   - File: `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift`
   - Commit: `b981938ea27d4d3261280346c57cbe2c00b23257`
   - Result: Tests external-surface archive mutation is recorded and not delegated, while local reversible capture archive is recorded and delegated.

8. **Stale state detector**
   - File: `scripts/ambitions-stale-state-check.py`
   - Commit: `9675e0270fec9a6d1ec2c128d567b7a9346c529c`
   - Result: Compares `.codex/state/active-batch.yml`, `.codex/reports/current-run-state.md`, `.codex/reports/current-batch-train-state.md`, and `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json` for current/next batch drift. Designed to catch the PK21-style stale mirror failure.

9. **Unsupported completion/readiness claim scanner**
   - File: `scripts/ambitions-unsupported-claim-scan.py`
   - Commit: `9409bc717f07b3ed3bef80bde6336d015daaf35d`
   - Result: Adds conservative advisory scanning for unsupported visual/global/release/accessibility completion claims unless explicit no-claim/deferred language is present.

10. **Shell placeholder / route marker guardrail**
    - File: `Native/Ambitions/App/AppShellRouteMarker.swift`
    - Commit: `ca5af6f2f987cf9396b6e931035b9058b22df568`
    - Result: Adds a typed marker that records temporary shell route status without treating placeholders as finished surfaces.

11. **Shell route marker tests**
    - File: `Native/AmbitionsTests/App/AppShellRouteMarkerTests.swift`
    - Commit: `72dc7cf5ea2576151bdcf86c4749e6618bca60db`
    - Result: Tests title normalization and the non-finished-surface state.

## Recommended local validation

Run these locally before treating this pass as Green:

```bash
git pull --ff-only
python3 scripts/ambitions-stale-state-check.py
python3 scripts/ambitions-unsupported-claim-scan.py docs prompts .codex
xcodegen generate
scripts/ambitions-xcode-validate.sh --batch DIRECT-GITHUB-HARDENING-2026-05-12 --lane focused-test --test CaptureRouteCommandMappingTests
scripts/ambitions-xcode-validate.sh --batch DIRECT-GITHUB-HARDENING-2026-05-12 --lane focused-test --test SideEffectLedgerModelsTests
scripts/ambitions-xcode-validate.sh --batch DIRECT-GITHUB-HARDENING-2026-05-12 --lane focused-test --test PolicyGuardedCommandExecutorTests
scripts/ambitions-xcode-validate.sh --batch DIRECT-GITHUB-HARDENING-2026-05-12 --lane focused-test --test AppShellRouteMarkerTests
```

## Next recommended implementation batch

After local validation of this hardening pass, run:

```bash
make batch BATCH=PK22 PROMPT=prompts/batches/PK22.md
```

PK22 should use these new seams but still stay Foundation-only. PK23, PK24, and PK25 remain separate.
