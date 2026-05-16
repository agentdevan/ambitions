<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MANIFEST-RERUN-SA29-01 — Hash / Signature / Revocation Tooling

## Batch ID

MANIFEST-RERUN-SA29-01

## Objective

Complete SA29 — Hash / Signature / Revocation Tooling — under the active manifest-rerun directive.

SA29 must implement or repair the Source Atlas hash/signature/revocation/rollback tooling according to the manifest. Existing commits may be retained as supporting evidence, but prior Green status does not count unless current validation proves the manifest acceptance criteria.

Do not proceed to SA30.

Do not continue to FCP27.

## Active source truth to inspect first

Read in this exact order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `docs/codex/ANTIGRAVITY_MANIFEST_RERUN_START_HERE.md`
9. `docs/codex/SA28_LDI15_AOS24_MANIFEST_RERUN_DIRECTIVE.md`
10. `.codex/state/active-batch.yml`
11. `.codex/reports/current-batch-train-state.md`
12. `.codex/reports/current-run-state.md`
13. `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
14. `docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md`
15. any existing `docs/audits/sa29-batch-closeout-report.md`
16. existing Source Atlas tooling under `tools/source-atlas/`
17. existing Source Atlas models/tests under `Native/Ambitions/Domain/` and `Native/AmbitionsTests/Domain/` only if needed

## Manifest requirement

From the Source Atlas manifest:

SA29 — Hash / Signature / Revocation Tooling

Goal:
- SHA-256 validation now
- signature/revocation/rollback path
- invalid/revoked/corrupt packs are quarantined
- old pack remains safe

## Allowed scope

You may modify or add only files required for SA29:

- `tools/source-atlas/**`
- `tools/source-atlas/tests/**`
- `docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md`
- `docs/audits/sa29-batch-closeout-report.md`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-batch-train-state.md`
- `.codex/reports/current-run-state.md`
- `prompts/batches/MANIFEST-RERUN-SA29-01.md`

You may touch Source Atlas Swift domain/test files only if the manifest requires runtime contracts and the change is tightly scoped.

## Forbidden scope

Do not modify:

- unrelated Swift files
- frontend UI files
- SwiftUI surfaces
- widgets
- Live Activities
- App Intents presentation
- project files
- `.github/workflows/**`
- release/signing/App Store files
- LDI files
- AOS files
- FCP files

Do not delete prior commits or files by default.

Do not advance to SA30 until SA29 is Green or Accepted Yellow with explicit owner/blocker.

Do not unblock FCP27.

## Required implementation

1. Inspect prior SA29 evidence.

If a prior SA29 closeout/report exists, classify it in:

`docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md`

as one of:

- valid evidence
- partial/supporting evidence
- wrong-scope substitution
- build-risk evidence
- stale-state evidence

2. Implement or repair SA29 tooling.

SA29 must support, at minimum:

- computing SHA-256 for pack files
- validating expected hash against actual file bytes
- representing signature status without claiming production signing infrastructure
- representing revocation status
- representing rollback pointer / last-known-good pack behavior
- quarantining invalid, corrupt, revoked, or hash-mismatched packs
- preserving old pack as safe fallback when a new pack is invalid/revoked/corrupt

3. Add tests.

Tests must cover:

- valid hash passes
- hash mismatch quarantines pack
- corrupt JSON or unreadable pack is quarantined
- revoked pack is blocked/quarantined
- rollback/last-known-good reference remains available
- no production signing or official-source claim is implied

4. Update audit.

Update:

`docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md`

SA29 section must include:

- manifest requirement
- prior evidence retained
- classification of prior work
- files inspected
- files changed
- validation commands/results
- final status

If Green, update state mirrors so next eligible is:

`SA30 Freshness Broker Manifest Contract`

If Accepted Yellow or Blocked, do not advance.

## Required validation

Run or record exact Windows equivalent:

```bash
git status --short
git diff --check
git diff --cached --check
python --version
python -m unittest discover -s tools/source-atlas/tests -p "*hash*"
python -m unittest discover -s tools/source-atlas/tests
scripts/codex-forbidden-claim-scan.sh tools/source-atlas docs/audits/sa28-ldi15-aos30-manifest-rerun-audit.md 2>/dev/null || true
python scripts/ambitions-source-atlas-title-check.py --strict
bash scripts/ambitions-codex-train.sh --self-check
```

If make is unavailable, state that and use runner self-check as the Windows equivalent.

## Visual proof expectations

None unless SA29 unexpectedly touches frontend. If frontend is touched, stop unless explicitly justified and inherit the frontend encyclopedia.

## Hard Red stop conditions

Stop and do not close Green if:

- FCP27 is unblocked or started
- SA30 starts before SA29 closeout
- hash mismatch does not quarantine
- revoked/corrupt pack does not block use
- rollback/last-known-good behavior is missing
- production signing is falsely claimed
- official/current source certainty is falsely claimed
- release/device/App Store/accessibility/privacy/legal claims are added
- unrelated files are modified

## Rollback expectations

If SA29 repairs cause problems, rollback only SA29 changes. Do not revert prior SA28 repair or prior historical commits by default.

## Closeout response format

Return:

```text
Status: Green / Accepted Yellow / Blocked

Files changed:
- ...

Validation:
- command: result

SA29 final classification:
- prior evidence:
- current rerun evidence:
- remaining blockers:

Queue state:
- current batch:
- next eligible batch:
- FCP27 blocked: yes/no

Claims not made:
- release readiness
- device validation
- public accessibility conformance
- privacy/legal approval
- TestFlight/App Store readiness
- performance proof
- sync/cloud readiness
- hosted AI proof
- global train completion
```

## Runner command

```bash
scripts/ambitions-codex-train.sh MANIFEST-RERUN-SA29-01 prompts/batches/MANIFEST-RERUN-SA29-01.md
```
