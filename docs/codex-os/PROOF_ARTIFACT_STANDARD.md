# Proof Artifact Standard

Status: Active Codex OS v2 standard
Authority: Proof-process standard, subordinate to `docs/truth/RELEASE_TRUTH.md`

## What It Is

A proof artifact binds a claim to commit, touched files, command, exit code, artifact path, scope, non-claims, freshness, program, Linear issue, and Green/Yellow/Red evidence status.

## What It Is Not

A proof artifact is not proof outside its scope. A script log is not app build proof. A screenshot path is not visual approval. A reviewer output is not owner approval or release readiness.

## Required Fields

- claim
- commit
- touched files
- command
- exit code
- artifact path
- screenshot path if visual
- scope
- non-claims
- freshness
- responsible program
- related Linear issue
- Green/Yellow/Red evidence status

## Evidence Gates

Green evidence is current, scoped, tied to commit or working tree state, and supports the exact claim.
Yellow evidence is useful but limited by missing human/device/release proof, unavailable external access, or non-blocking tool drift.
Red evidence is missing, stale, contradictory, unrelated, or produced by a failed command caused by the current patch.

## Visual Proof

Screenshots must be visually evaluated. A screenshot path alone is Yellow at best. UI proof must separate visual inspection, VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, safe areas, tap targets, and device/simulator scope.

## Repair / Rollback / Linear

Downgrade unsupported claims. Preserve failed logs unless unsafe. Linear closeout may cite proof paths and summaries but must not paste massive logs or claim release/owner approval without evidence.
