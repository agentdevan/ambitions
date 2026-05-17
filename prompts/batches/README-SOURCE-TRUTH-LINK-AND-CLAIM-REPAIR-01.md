<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

README-SOURCE-TRUTH-LINK-AND-CLAIM-REPAIR-01

## Objective

Repair README front-door truthfulness and navigation issues found by the audit: stale local `file:///c:/...` links, wording that overstates architecture/proof, and any unsupported claim that could mislead Codex or a human contributor.

## Active Source Truth To Inspect

- `docs/truth/README.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/README.md`
- `README.md`
- `docs/status/current-implementation-map.md`

## Allowed Scope

- `README.md`
- `docs/README.md` only if needed for link consistency
- `docs/status/current-implementation-map.md` only if the README repair reveals a direct status mismatch

## Required Work

- Convert local-machine `file:///c:/...` links to repo-relative Markdown links.
- Reword unsupported proof-like claims to source-backed orientation.
- Preserve active IA: `Today / Goals / Capture / Time / You`.
- Preserve conservative release posture.

## Validation Expectations

- `bash scripts/validate-repo-authority.sh .`
- `python3 scripts/ambitions-repo-authority-validate.py`
- `rg -n "file:///c:|release-ready|production-ready|Today / Goals / Capture / Plan / You" README.md docs/README.md docs/status/current-implementation-map.md || true`
- `git diff --check`

## Forbidden Scope

- No app source changes.
- No broad docs rewrite.
- No release/readiness claims.

## Runner Command

```bash
make batch BATCH=README-SOURCE-TRUTH-LINK-AND-CLAIM-REPAIR-01 PROMPT=prompts/batches/README-SOURCE-TRUTH-LINK-AND-CLAIM-REPAIR-01.md
```
