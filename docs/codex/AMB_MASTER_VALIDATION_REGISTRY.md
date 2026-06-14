# Ambitions Master Build Validation Registry

Status: Active validation registry for `amb-master`
Authority posture: Supporting registry subordinate to `docs/truth/*`, current source, and current logs

## Registry Rules

- Do not invent commands to satisfy an issue.
- Do not treat listed commands as proof unless run for the current issue/current commit.
- Record command, exit code, artifact path, scope, and non-claims in issue reports.
- Unknown lanes stay Yellow or Red depending on whether that proof is required for the scoped claim.
- Keep build/test proof separate from release readiness.

## Structural Commands

| Lane | Command | Green boundary |
|---|---|---|
| Master readiness | `python3 scripts/codex/amb-master-readiness-validate.py` | Structural proof that `amb-master` artifacts exist, bind to the new Linear project, and contain AMB issue IDs for active trains. |
| Canon IA lock | `python3 scripts/codex/amb-master-canon-ia-validate.py` | Regression proof that active authority, app shell locks, preview fixtures, support reports, and focused tests agree on Today / Goals / Time / Motion / You with global Capture. |
| Repository wiring / quarantine | `python3 scripts/codex/amb-master-repository-wiring-validate.py` | Regression proof that the live AMB master adapter is wired through registry/scripts/closeout validators, current state is not stale, script-output logs remain ignored and untracked, and AMB master artifacts do not reuse PLOS labels or train labels as Linear IDs. |
| Program preflight | `scripts/codex/program-preflight.sh amb-master` | Required files exist and forbidden dirty source/project paths are absent at run time. |
| Program phase gate | `scripts/codex/program-phase-gate.sh amb-master <phase>` | Requested phase is declared and readiness validator passes for that phase. |
| Closeout | `python3 scripts/codex/linear-closeout-validate.py --program amb-master --scope child <file>` | Required closeout fields exist and forbidden overclaims/identifier drift are absent. |
| Proof index | `bash scripts/codex/program-proof-index.sh amb-master` | Produces proof index from proof ledger; does not prove behavior by itself. |

## Source-Changing Commands

Use existing repo commands selected by the active issue and changed paths:

- `xcodegen generate`
- `./scripts/build-local.sh`
- focused `xcodebuild` build/test commands
- `scripts/ambitions-xcode-test-focused.sh`
- `scripts/ambitions-accessibility-contract-check.py`
- `python3 scripts/ambitions_validate_accessibility_gates.py`
- `python3 scripts/ambitions_validate_runtime_authority.py`
- `python3 scripts/ambitions_validate_trust_privacy.py`
- `scripts/privacy-boundary-scan.sh`
- `scripts/ambitions-performance-budget-check.py`
- issue-specific validators under `scripts/`

Green requires exact command output for the current issue/current commit. Zero-test or skipped-test output is not Green.

## Unknown Proof Lanes

VoiceOver traversal, physical-device proof, StoreKit sandbox purchase proof, App Store Connect validation, CloudKit production environment proof, R2 production publication proof, and legal/privacy approval are unknown/unavailable until current artifacts prove them. Do not claim them from source presence or structural validators.
