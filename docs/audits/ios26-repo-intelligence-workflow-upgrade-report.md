# iOS 26 Repo Intelligence Workflow Upgrade Report

Batch ID: `AMB-IOS26-REPO-INTELLIGENCE-WORKFLOW-UPGRADE-01`
Date: 2026-05-24
Status: GREEN for workflow safety; optional Understand Anything remains manual/sandbox-only.

## Primary Front Door Preserved

Primary iOS 26 runner preserved: `scripts/ios26-flagship-run-sequential.sh`.

The sequential runner still calls each `run_batch IOS26-... prompts/batches/...` entry in manifest order and still preserves:

1. `python3 scripts/ios26-flagship-preflight.py --batch "$batch_id"`
2. `scripts/ambitions-codex-train.sh "$batch_id" "$prompt"`
3. `python3 scripts/ios26-flagship-proof-packet-check.py --batch "$batch_id"`

`NEXT_FAILED_BATCH=$batch_id` remains emitted on preflight, child runner, proof-packet, or repo-intelligence hygiene Red stops.

## Files Changed

- `.gitignore`
- `.codex/AGENTS.md`
- `.codex/schemas/repo-intelligence-evidence.schema.json`
- `AGENTS.md`
- `Makefile`
- `docs/codex/LOCAL_REPO_INTELLIGENCE_POLICY.md`
- `docs/codex/REPO_INTELLIGENCE_WORKFLOW.md`
- `docs/codex/REPO_INTELLIGENCE_CONTROL_PLANE.md`
- `docs/audits/ios26-repo-intelligence-workflow-upgrade-report.md`
- `scripts/ios26-sequential-runner-shape-check.py`
- `scripts/ambitions-repo-intelligence-preflight.py`
- `scripts/ambitions-repo-intelligence-evidence-check.py`
- `scripts/ambitions-repo-intelligence-snapshot.py`
- `scripts/ambitions-repo-intelligence-local-setup.sh`
- `scripts/ios26-flagship-run-sequential.sh`
- `scripts/ambitions-codex-train.sh`
- `scripts/ambitions-global-train-supervisor.sh`
- `scripts/ambitions-autonomous-train-fastpath.py`
- `scripts/ambitions-speed-train.sh`

## What Was Installed

- Stdlib-only iOS 26 sequential runner shape check.
- Stdlib-only repo-intelligence preflight, snapshot, evidence check, and local setup helper.
- Repo-intelligence evidence schema.
- Policy, workflow, and control-plane docs.
- Make targets for preflight, snapshot, evidence check, setup, and shape check.
- Advisory iOS 26 sequential runner preflight/snapshot hooks.
- Canonical child runner prompt guidance and final fields.
- Local ignored CodeGraph install under `.codex/repo-intelligence/tools/`.
- Local ignored Semble install under `.codex/repo-intelligence/tools/`.

## What Was Intentionally Not Installed

- Understand Anything was not installed because the currently discovered install paths use curl-piped installer or plugin/global configuration flows. It remains optional sandbox-only human architecture/onboarding tooling.
- No `.codegraph/` index was created.
- No Semble project index was created.
- No global Codex, Claude, Cursor, VS Code, shell, or AGENTS config was mutated.
- No app runtime dependency, Xcode project dependency, Swift package dependency, hosted CI, telemetry, analytics, cloud service, API key, or secret was added.

## Tool Roles

- CodeGraph: advisory source graph, impact, callers/callees, trace, file structure, and affected-test hints.
- Semble: advisory local code/docs/config retrieval and related-snippet discovery.
- Understand Anything: optional sandbox-only human dashboard; never proof, source truth, or runner gate.

## Runner / Front-Door Matrix

| Entry point | Role | Primary? | Delegates to canonical runner? | Modified? | Risk | Proof / validation |
|---|---|---:|---:|---:|---|---|
| `scripts/ios26-flagship-run-sequential.sh` | iOS 26 sequential front door | Yes | Yes | Yes | Medium | Shape check Green; bash syntax Green |
| `scripts/ambitions-codex-train.sh` | Canonical child batch runner | No | N/A | Yes | Medium | bash syntax Green; prompt-only guidance added |
| `scripts/ambitions-global-train-supervisor.sh` | Global train supervisor | No | Yes, via `make batch` | Yes | Low | bash syntax Green; status text only |
| `scripts/ambitions-autonomous-train.sh` | Compatibility entry point | No | Indirectly via fastpath/make | No | Low | bash syntax Green |
| `scripts/ambitions-autonomous-train-fastpath.py` | Fastpath wrapper | No | Yes, via `make batch`/`batch-push` | Yes | Low | py_compile Green; status fields only |
| `scripts/ambitions-speed-train.sh` | Speed wrapper/final gate | No | Yes, via autonomous wrapper | Yes | Low | bash syntax Green; final-gate preflight only |
| `Makefile batch` | Canonical make child runner | No | Yes | No behavior change | Low | Existing target preserved |
| `Makefile global-*` | Global supervisor wrappers | No | Yes | No behavior change | Low | Existing targets preserved |
| `Makefile autonomous-*` | Autonomous wrappers | No | Indirectly | No behavior change | Low | Existing targets preserved |
| `Makefile speed-*` | Speed wrappers | No | Indirectly | No behavior change | Low | Existing targets preserved |

## Validation Commands Run

Passed:

- `git diff --check`
- `bash -n scripts/ambitions-repo-intelligence-local-setup.sh`
- `bash -n scripts/ios26-flagship-run-sequential.sh`
- `bash -n scripts/ambitions-codex-train.sh`
- `bash -n scripts/ambitions-global-train-supervisor.sh`
- `bash -n scripts/ambitions-autonomous-train.sh`
- `bash -n scripts/ambitions-speed-train.sh`
- `PYTHONPYCACHEPREFIX=/private/tmp/ambitions-repo-intelligence-pycache python3 -m py_compile scripts/ios26-sequential-runner-shape-check.py scripts/ambitions-repo-intelligence-preflight.py scripts/ambitions-repo-intelligence-evidence-check.py scripts/ambitions-repo-intelligence-snapshot.py scripts/ambitions-autonomous-train-fastpath.py`
- `python3 scripts/ios26-sequential-runner-shape-check.py`
- `python3 scripts/ios26-sequential-runner-shape-check.py --json`
- `python3 scripts/ambitions-repo-intelligence-preflight.py`
- `python3 scripts/ambitions-repo-intelligence-preflight.py --json`
- `python3 scripts/ambitions-repo-intelligence-snapshot.py --batch AMB-IOS26-REPO-INTELLIGENCE-WORKFLOW-UPGRADE-01 --status GREEN --phase post --note "workflow upgrade validation"`
- `python3 scripts/ambitions-repo-intelligence-evidence-check.py build/reports/repo-intelligence/AMB-IOS26-REPO-INTELLIGENCE-WORKFLOW-UPGRADE-01-repo-intelligence.json`
- `make ios26-sequential-runner-shape-check`
- `make repo-intelligence-preflight`
- `make repo-intelligence-preflight-json`
- `make repo-intelligence-snapshot BATCH=AMB-IOS26-REPO-INTELLIGENCE-WORKFLOW-UPGRADE-01`
- `make repo-intelligence-evidence-check BATCH=AMB-IOS26-REPO-INTELLIGENCE-WORKFLOW-UPGRADE-01`
- `make batch-self-check`
- `make prompt-audit`

Initial environment issue repaired:

- Plain `python3 -m py_compile ...` attempted to write bytecode under `/Users/devan/Library/Caches/com.apple.python/...` and failed with `PermissionError`. Re-run with `PYTHONPYCACHEPREFIX=/private/tmp/ambitions-repo-intelligence-pycache` passed.

Failed due unrelated generated report dirt:

- `python3 scripts/ambitions-codex-os-validate.py`
- `make ambitions-codex-os-validate`

Both reported only disallowed untracked report changes under `build/reports/parallel-implementation-guard/AMB-CHAMPION-MERGE-GOALS-01-pre.*`. Those files were not created or modified by this repo-intelligence workflow upgrade and were left untouched.

Not run:

- Xcode build/test validation.

Reason: this batch is tooling/governance only and does not change app runtime behavior.

## Green Yellow Red Result

GREEN:

- iOS 26 shape check installed and passing.
- iOS 26 batch order preserved against manifest.
- iOS 26 preflight -> canonical runner -> proof-packet order preserved.
- Repo-intelligence policy docs, schema, helpers, Make targets, and audit report installed.
- CodeGraph and Semble are locally installed in ignored repo-local tooling paths and detected by preflight.
- Generated local tool artifacts are ignored.

YELLOW:

- Understand Anything is unavailable and intentionally not installed automatically because safe installation without remote shell/plugin/global config mutation was not established. Policy keeps it optional sandbox-only.

RED:

- None found in the installed workflow.

## Known Limitations

- CodeGraph index creation was not run; `.codegraph/` is ignored and may be created manually.
- Semble index creation was not run; `.codex/local-indexes/` is ignored and may be created manually.
- Understand Anything remains manual/sandbox-only.
- Repo-intelligence evidence is workflow evidence only, not product or release proof.

## Safety Boundaries

- No app runtime behavior changed.
- No Swift app source changed by this workflow upgrade.
- No Xcode project/package dependency mutation was made.
- No hosted CI, analytics, telemetry, tracking, paid service, cloud service, API key, secret, or release automation was added.
- Advisory tool output is not source truth and cannot approve Green.

## Rollback Command

```bash
git checkout -- \
  scripts/ios26-flagship-run-sequential.sh \
  scripts/ambitions-codex-train.sh \
  scripts/ambitions-global-train-supervisor.sh \
  scripts/ambitions-autonomous-train-fastpath.py \
  scripts/ambitions-speed-train.sh \
  scripts/ios26-sequential-runner-shape-check.py \
  scripts/ambitions-repo-intelligence-preflight.py \
  scripts/ambitions-repo-intelligence-evidence-check.py \
  scripts/ambitions-repo-intelligence-snapshot.py \
  scripts/ambitions-repo-intelligence-local-setup.sh \
  docs/codex/LOCAL_REPO_INTELLIGENCE_POLICY.md \
  docs/codex/REPO_INTELLIGENCE_WORKFLOW.md \
  docs/codex/REPO_INTELLIGENCE_CONTROL_PLANE.md \
  .codex/schemas/repo-intelligence-evidence.schema.json \
  Makefile \
  AGENTS.md \
  .codex/AGENTS.md \
  .gitignore \
  docs/audits/ios26-repo-intelligence-workflow-upgrade-report.md 2>/dev/null || true
rm -rf build/reports/repo-intelligence
rm -rf build/reports/ios26-sequential-runner-shape
rm -rf .codex/repo-intelligence/tools
```

## Non-Claims

- No release readiness claim.
- No TestFlight/App Store readiness claim.
- No accessibility verification claim.
- No privacy/legal approval claim.
- No performance improvement claim.
- No Ambitions-specific speed/cost gain claim.
- No app behavior implementation claim.
