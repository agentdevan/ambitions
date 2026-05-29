<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-FE-BE-MOAT-SCENARIO-PROOF-98

## Mission

Create real end-to-end proof that Ambitions' Private Life Runtime can take the same user intent and, using two different local contexts, deterministically produce different Start Here / Reality Meridian recommendations with inspectable proof, freshness, receipt, closure, replay, protected-time, and local-only privacy evidence.

This batch exists to unblock `AMB-FE-BE-INTEGRATED-PROOF-99`. Do not mark anything Green by editing reports manually. Generate executable proof.

## Non-negotiable canon

Ambitions is a private, local-first Personal Life OS.

The moat claim being proven:

Same intent -> different users/contexts -> different daily steps -> local-only execution -> inspectable Start Here receipts -> proof/freshness -> closure/recovery adaptation -> deterministic replay after relaunch.

Canonical IA and language:
- Today / Goals / Capture / Time / You
- Today = Reality Meridian
- Start Here
- Recommended step
- Start now
- Open step
- Step
- Do not introduce generic task/dashboard/calendar/chatbot language.

## Required scenario

Create a bounded deterministic proof scenario:

### Shared intent

Use one identical goal/intent seed for both contexts:

> "Improve health consistency while maintaining work and relationship commitments."

### Context A

A user with:
- standard work block
- moderate available free time
- no protected recovery block
- fresh schedule data
- prior closure history showing successful short evening steps

Expected output:
- Start Here / Reality Meridian recommends a health consistency step that fits the available window.
- Receipt explains why now.
- Proof shows capacity fit and source freshness.

### Context B

Same intent, but different local context:
- protected recovery block or blocked time
- tighter capacity
- stale or constrained schedule source that must be surfaced
- prior closure history showing recent missed/blocked health step

Expected output:
- Different recommendation from Context A.
- It must respect protected time.
- It must not overwrite recovery.
- It should recommend a smaller recovery-aware step, reschedule/move, or closure prompt depending on runtime rules.
- Receipt explains the different decision.

## Implementation requirements

Add the smallest durable implementation needed to prove this through existing runtime seams.

Prefer tests, fixtures, and proof artifacts over new product surface work.

You may add:
- deterministic fixture data
- runtime scenario builder
- XCTest coverage
- proof-pack generation script
- JSON evidence output
- markdown summary evidence

Do not add:
- networking
- cloud LLM dependency
- analytics SDK
- backend service dependency
- cosmetic-only reports
- fake screenshots
- manually edited Green statuses

## Evidence artifacts required

Create a proof pack under:

`docs/proof/amb-fe-be/moat-scenario-proof-98/`

Required files:

1. `README.md`
   - scenario summary
   - exact command run
   - Green/Yellow/Red result
   - evidence index
   - limitations, if any

2. `same-intent-context-a.json`
   - shared intent id/text
   - local context summary
   - generated Start Here recommendation
   - Reality Meridian placement
   - proof/freshness/receipt payload
   - closure/replay fields

3. `same-intent-context-b.json`
   - same structure as context A
   - must show same intent but different local context and different recommendation

4. `diff-summary.json`
   - machine-readable comparison:
     - sameIntent: true
     - differentContext: true
     - differentRecommendation: true
     - protectedTimeRespected: true
     - localOnlyBoundaryPassed: true
     - receiptPresent: true
     - freshnessPresent: true
     - closureEvidencePresent: true
     - replayStable: true

5. `test-output.log`
   - captured XCTest or script output proving pass/fail

6. `privacy-boundary.log`
   - evidence that no network/cloud/LLM/backend path is required for the proof

7. `replay-output.json`
   - first run and replay run hashes/results
   - replay must be stable

## Test requirements

Add or update tests so this batch can be validated by command line.

Minimum test coverage:

1. Same intent produces context-specific recommendations.
2. Context A and Context B recommendations are deterministically different.
3. Protected time is not violated.
4. Receipts exist and include why-now / capacity / source freshness evidence.
5. Closure/recovery evidence affects Context B.
6. Replay returns stable output for both contexts.
7. Local-only boundary check passes.

Use existing test targets and validation conventions where possible.

If exact runtime APIs differ, adapt to the existing repository architecture instead of inventing parallel systems.

## Suggested names

Use these only if they fit existing conventions:

- `AmbitionsMoatScenarioProof98Tests`
- `MoatScenarioProof98Fixtures`
- `MoatScenarioProof98Exporter`
- `ambitions-moat-scenario-proof-98`
- `docs/proof/amb-fe-be/moat-scenario-proof-98/`

## Validation commands

Run the strongest available local validation path.

At minimum attempt:

```bash
git status --short
swift test
```

If this is an iOS/Xcode-only project, use the existing repo test command or runner convention instead.

Also run any Ambitions-specific validators that already exist, especially anything covering:

- local-only boundary
- canon language
- batch proof reports
- post-23 gating
- FE/BE integration

Capture command output into the proof pack.

## Acceptance gates

Return Green only if all are true:

- Real test or script output exists.
- Same intent is used in both contexts.
- Contexts differ materially.
- Recommendations differ deterministically.
- Reality Meridian / Start Here output is present.
- Receipt/proof/freshness evidence is present.
- Closure/recovery evidence is present.
- Protected time is respected.
- Replay is stable.
- Privacy/local-only boundary is checked.
- Evidence files are saved under `docs/proof/amb-fe-be/moat-scenario-proof-98/`.
- No report is manually edited to pretend success.

Return Yellow if:

- implementation exists but one proof dimension is partial.
- tests pass but evidence packaging is incomplete.
- evidence exists but integration into 99 still needs wiring.

Return Red if:

- output is fabricated.
- recommendations are not actually produced by runtime/test code.
- protected time is violated.
- local-only/privacy boundary fails.
- replay is not deterministic.

## Final response format

End with:

Status: GREEN/YELLOW/RED

Changed files:

- ...

Evidence:

- ...

Commands run:

- ...

Next required command:

```bash
scripts/ambitions-codex-train.sh \
  AMB-FE-BE-INTEGRATED-PROOF-99 \
  prompts/batches/amb-fe-be/AMB-FE-BE-INTEGRATED-PROOF-99.md
```

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
