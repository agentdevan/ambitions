# Repo Intelligence Workflow

Status: Supporting workflow for local advisory developer tooling.
Scope: Codex operator workflow only; subordinate to `docs/truth/*`.

## Operator Workflow

1. Optionally perform manual local setup.
2. Initialize CodeGraph locally with `codegraph init -i`.
3. Optionally use Semble query-time retrieval for local code/docs/config search.
4. Use `scripts/ios26-flagship-run-sequential.sh` as the primary iOS 26 execution path.
5. Let the sequential runner perform advisory repo-intelligence preflight, snapshot, and hygiene checks without changing iOS 26 stop rules.
6. Let the sequential runner generate a structured per-batch Implementation Intelligence Packet before each child batch.
7. Let child runner Phase 01 use the packet to narrow source discovery, owner classification, proof lookup, and wiring checks, then verify useful findings directly.
8. Let Phase 02 consume only the Phase 01 accepted bounded subset, not the full exploratory packet.
9. Final review verifies accepted tool-derived findings against direct file inspection, the actual diff, guard reports, validation output, tests, or existing Ambitions proof artifacts.

## Codex Phase Workflow

- Start with source truth: `docs/truth/*`, manifest, frozen prompt boundary, current runner state, source files, tests, scripts, and proof artifacts.
- Use CodeGraph for impact, callers, callees, trace, symbol context, and affected-test hints when it is already available.
- Use Semble for local code/docs/config retrieval when it is already available.
- Use `scripts/ambitions-repo-intelligence-context.py --batch <BATCH_ID> --prompt <PROMPT_FILE>` to create a bounded advisory packet when the sequential runner invokes a batch.
- Use direct file reads, `rg`, validation scripts, tests, and proof artifacts to verify important findings.
- Use Understand Anything only outside source-changing gates as optional human architecture/onboarding context.
- Do not install tools inside a Codex phase.
- Do not broaden batch scope because a tool suggests related files.

## Active Context Packet Flow

The sequential runner calls `scripts/ambitions-repo-intelligence-context.py`
before each child batch when repo intelligence is enabled. The script reads the
batch prompt, extracts allowed/forbidden/validation boundaries, asks CodeGraph
for source-graph context, asks Semble for scoped local retrieval, reads owner
and guard metadata, and writes:

```text
build/reports/repo-intelligence/<BATCH_ID>-repo-intelligence-context.md
build/reports/repo-intelligence/<BATCH_ID>-repo-intelligence-context.json
```

The packet is an Implementation Intelligence Packet with:

- `tool_suggestions`
- `direct_path_candidates`
- `owner_candidates`
- `rejected_owner_candidates`
- `proof_lookup_matrix`
- `runtime_wiring_checklist`
- `parallel_system_risks`
- `advisory_red_risks`
- `requires_direct_verification`

It reads `docs/codex/canonical-owner-map.yml`,
`docs/codex/existing-code-champion-coverage.yml`,
`docs/codex/concept-lock-registry.yml`, and proof roots to propose canonical
owners, classification maturity, related tests, proof paths, lock impact, and
runtime wiring hints.

The sequential runner exports the markdown path through
`AMBITIONS_REPO_INTELLIGENCE_CONTEXT` and validates the paired JSON shape with
`scripts/ambitions-repo-intelligence-packet-check.py`. The child runner injects
the full packet only into Phase 01 so planning starts from a compact candidate
map instead of broad rediscovery. Phase 02 receives only the Phase 01 accepted
bounded subset. Review/final gates verify that no advisory-only row was used as
proof.

The packet is advisory only. It must accelerate discovery, reduce repeated
search, and mitigate drift, but it cannot expand the frozen prompt boundary,
approve Green, replace direct file reads, replace guard reports, replace
validation, or become source/proof/release evidence.

Packet caching is keyed by batch id, prompt hash, current `HEAD`, and CodeGraph
availability/index status. A cache hit reuses the JSON/markdown packet across
Phase 01/02/03 unless one of those inputs changes. Semble retrieval remains
scoped to likely roots from the prompt and CodeGraph output.

## Manual Local Setup

Manual opt-in only. Do not run these commands automatically from validation, runners, or Codex phases.

CodeGraph:

```bash
npx @colbymchenry/codegraph
codegraph install --print-config codex
cd /Users/devan/Documents/GitHub/ambitions
codegraph init -i
codegraph status
```

Semble:

```bash
uv tool install "semble[mcp]"
cd /Users/devan/Documents/GitHub/ambitions
semble search "Reality Meridian" . --include-text-files -k 5
semble find-related Native/Ambitions/App/AmbitionsApp.swift 1 . --include-text-files -k 5
```

Current Semble exposes `search` and `find-related`; it builds its working index
at query time. The legacy `.codex/local-indexes/semble-ambitions` path remains
ignored as an optional sidecar path, but the current CLI does not create it.

Understand Anything:

```bash
# Optional sandbox only. Do not run during normal iOS 26 batch gates.
# Follow upstream install docs manually if desired.
/understand
/understand-dashboard
```

## Manual Codex MCP Config Snippets

Any MCP setup for these tools is manual opt-in only. Keep config local to the operator machine, avoid secrets, and do not add write-capable, shell-capable, network-capable, signing, App Store, hosted CI, or production-affecting MCP tools without explicit approval and security review.

## Fallback Behavior

If CodeGraph is unavailable, use `rg`, direct file reads, language-native compiler/test feedback, and existing Ambitions source-truth scripts.

If Semble is unavailable, use `rg`, `find`, direct file reads, docs indexes, and existing batch manifests.

If Understand Anything is unavailable, do nothing. It is not part of the execution path.

Optional tool absence is Yellow/fallback, not Red. Hygiene violations, staged sidecars, false proof, app dependency mutation, runner shape breakage, and global config mutation are Red.

## Packet Validation

Use these commands when changing the packet contract:

```bash
python3 scripts/ambitions-repo-intelligence-context.py --batch <BATCH_ID> --prompt <PROMPT_FILE>
python3 scripts/ambitions-repo-intelligence-packet-check.py build/reports/repo-intelligence/<BATCH_ID>-repo-intelligence-context.json
python3 scripts/ambitions-repo-intelligence-context-self-test.py
```

The packet checker validates required sections, output budgets, local-relative
paths, and advisory-only proof boundaries. Advisory Red findings are visible to
Phase 01 but do not fail the shape check by themselves.

## Proof Packet Expectations

Repo-intelligence snapshots and context packets may be written under `build/reports/repo-intelligence/`. They should capture tool availability, local index presence, advisory findings, direct verification status, runner integration, non-claims, and rollback notes.

These packets are workflow evidence only. They do not prove app behavior, release readiness, accessibility conformance, privacy/legal approval, performance, or device behavior.

## Rollback

Remove workflow upgrade changes with path-limited checkout of changed scripts, docs, schema, Makefile, AGENTS files, and `.gitignore`, then remove generated local reports:

```bash
rm -rf build/reports/repo-intelligence
rm -rf build/reports/ios26-sequential-runner-shape
```
