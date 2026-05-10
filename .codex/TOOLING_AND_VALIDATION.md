<!-- markdownlint-disable MD013 -->

# Codex Tooling And Validation

Status: Active Codex tooling map
Date updated: 2026-05-10

## Authority

This file maps local tools and validation routes. It is subordinate to
`docs/truth/*`, `AGENTS.md`, `.codex/OPERATING_SYSTEM.md`,
`.codex/GLOBAL_BATCH_TRAIN.md`, and current raw evidence.

Tool existence is not proof. A validation command becomes evidence only when
its exact output/log is captured and cited in the relevant status, report, or
proof packet.

## MCP Tooling Map

| Path | Classification | Use | Limits |
| --- | --- | --- | --- |
| `tools/mcp/ambitions_repo_mcp` | Active optional read-only Codex tooling | Active batch, EFC, source-truth, claim scan, closeout shape, changed-file impact | Repo-derived aid only; current source-truth stack output lags `docs/truth/*` and must not override truth files |
| `tools/mcp/ambitions_proof_mcp` | Active optional allowlisted proof tooling | Named local validation only | Not a generic shell; no write, network, secrets, signing, App Store, hosted CI, or git mutation |
| `tools/mcp/ambitions_release_truth_mcp` | Candidate/supporting release-truth tooling | Release claim boundary inspection | Not release proof unless raw evidence is current and cited |
| `tools/mcp/ambitions_visual_mcp` | Candidate visual QA tooling | Screenshot/visual packet support | Not public accessibility or visual approval proof by itself |
| `tools/mcp/ambitions_accessibility_mcp` | Candidate accessibility QA tooling | Accessibility evidence support | Not public accessibility conformance proof by itself |
| `tools/mcp/ambitions_source_atlas_mcp` | Candidate source/freshness tooling | Source atlas evidence support | Not implementation proof by itself |
| `tools/mcp/ambitions_fixture_mcp` | Planned/supporting fixture tooling | Fixture proof support | Not runtime product proof by itself |

MCP hard rule: do not add write-capable, network-capable, secret-reading,
signing, hosted-CI, App Store upload, or git-mutating MCP tools without
explicit approval and a security review.

## Script Map

| Family | Examples | Classification | Proof strength |
| --- | --- | --- | --- |
| Build/test | `scripts/build-local.sh`, `scripts/test-local.sh`, focused test discovery | Active local validation | Proof only with captured logs and current source state |
| Docs QA | `scripts/run-doc-qa.sh` | Active advisory docs validation | Exit `0` may still include advisory findings |
| Claim/privacy/copy scans | `release-claim-safety-scan.sh`, `no-unsupported-ai-claim-scan.sh`, `privacy-boundary-scan.sh`, `canon-language-drift-scan.sh` | Active advisory gates | Finding-free output helps claim boundary but does not prove release readiness |
| Batch train gates | `batch-train-preflight.sh`, `batch-train-gate-check.sh`, `global-train-next-batch.sh`, `global-train-status-summary.sh` | Active operating support | Process evidence only |
| Dirty-worktree gate | `codex-post-pk03-dirty-reconciliation.sh` | Active post-PK03 gate | Blocks continuation when exit code requires classification |
| FET/SI/DAV/SIG/PXEQ visual QA scans | `fet-*`, `si-*`, `dav-*`, `sig-*`, `pxeq-*` | Active/advisory by batch | Visual QA support only; not public conformance proof |
| Source Atlas scans | `sa-*` | Active/advisory by batch | Source/freshness evidence support only |
| LDI/AOS/EB scans | `ldi-*`, `eb-*` | Active/advisory by batch | Owner-specific evidence support |
| AI/ACX scripts | `scripts/ai/acx*` | Candidate/supporting local repair and evidence helpers | Do not treat as autonomous authority |
| Setup scripts | `setup-ambitions-repo-mcp.sh`, `setup_macos_ios_dev.sh` | Potentially mutating local setup | Run only when the user explicitly asks |
| Icon generation | `generate_ios_app_icons.ps1` | Asset mutation tool | Forbidden in cleanup unless explicitly approved |

## GitHub / CI Policy

`.github/` is absent in the current checkout. Hosted workflow files are not
active proof.

`docs/codex/workflow-templates/*.example` files are examples only:

- `codeql-swift-policy-gated.yml.example`
- `docs-and-claims.yml.example`
- `mcp-self-test.yml.example`

No hosted CI workflow may be added or activated without explicit approval and a
recorded provider, cost/quota, trigger, artifact-retention, permission, and
release-claim statement.

## Validation By Task Type

| Task type | Minimum validation |
| --- | --- |
| Docs-only cleanup | `git diff --check`, claim scan for changed docs, `scripts/run-doc-qa.sh` when safe |
| Codex OS cleanup | Repo MCP EFC/claim checks, docs QA when safe, no source build required |
| Skill metadata | Claim scan, routing-map check, no auto-load overclaim |
| Archive/delete | Inbound `rg`, replacement authority, rollback note, path-limited commit |
| Source implementation | Exact batch prompt, source/test ownership, focused tests/build, EFC applicability |
| UI/visual QA | FET/SI/DAV/SIG gates, screenshots where required, Dynamic Type/Reduce Motion/VoiceOver evidence where claimed |
| Release/proof work | Release truth, evidence packet, raw logs, claim firewall, human/device/legal gates where required |

## Safe Commands

Safe for control-plane cleanup when scoped and read-only:

- `git status --short --branch`
- `git log --oneline`
- `git diff --check`
- `rg`
- `find`
- `sed -n`
- `scripts/run-doc-qa.sh`
- Repo MCP read-only claim/EFC/impact checks

Safe only for implementation batches with explicit scope:

- `xcodegen generate`
- `scripts/build-local.sh`
- `scripts/test-local.sh`
- focused `xcodebuild` tests
- proof MCP allowlisted validation names

## Dangerous Commands And Actions

Dangerous unless explicitly approved and gated:

- `git reset --hard`, `git clean`, broad checkout/restore, broad delete/move
- `git add .`, `git add -A`, `git commit -a`
- unscoped `rm -rf`
- dependency installation or package/project mutation
- hosted CI activation
- signing, App Store upload, TestFlight upload, notarization
- source/runtime mutation during docs/control-plane cleanup
- provider/backend/auth/sync/analytics/telemetry/cloud/LLM activation
- write/network/secrets/git MCP expansion

## Evidence Rules

- Running a command is not proof unless the output is captured and cited.
- Local simulator evidence does not prove validation on real hardware.
- Local build/test evidence is not TestFlight or App Store readiness.
- Batch completion is not implementation completion unless current source/test
  evidence supports it.
- Docs-only plans are not implementation proof.
- Tooling maps and repo inventory are routing aids, not proof.

## Phase 6 Gate Result

Phase 6 result: Green with accepted Yellow items.

EFC applicability: invoked for governance and release-claim boundary routing.
No app implementation, build, release, accessibility, performance, device,
legal/privacy, hosted CI, App Store, or TestFlight proof is claimed.

Accepted Yellow:

- Some scripts are advisory and noisy by design.
- Repo MCP source-truth stack freshness remains a later repair item.
- Candidate MCPs remain classified, not proven production tools.

## Release Evidence Firewall

Local tools can support evidence packets only when their logs are captured and
cited. Tooling output alone does not prove release status, validation on real
hardware, public accessibility conformance, performance, legal/privacy signoff,
hosted CI, TestFlight, App Store submission, backend/provider activation, or
implementation completeness.
