# 2026-06-22 Codex Remediation Law

## Purpose

This file is the global remediation law for the 2026-06-22 runtime QA remediation. Codex must read this file before any execution-bundle dossier. This is documentation / canon / control-plane installation law, not proof that any runtime defect is fixed.

## Source precedence

1. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
2. `docs/truth/2026-06-22-runtime-remediation-decision-register.md`
3. `docs/qa/remediation/2026-06-22-codex-remediation-law.md`
4. matching dossier in `docs/qa/remediation/dossiers/`
5. `docs/qa/KNOWN_ISSUES.md`
6. Linear execution bundle and QA leaves
7. evidence files in `docs/qa/evidence/2026-06-22-device-review/`

## Execution queue

1. `AMB-1191`
2. `AMB-1194`
3. `AMB-1192`
4. `AMB-1193`
5. `AMB-1195`
6. `AMB-1196`
7. `AMB-1197`
8. `AMB-1198`
9. `AMB-1199`
10. `AMB-1200`

## Codex authority / non-authority

Codex may decide:

- low-level Swift implementation mechanics
- local refactors required to make the scoped bundle compile
- test structure when equivalent proof is preserved
- small file reorganization inside the allowed bundle scope

Codex may not decide:

- product behavior
- IA
- visual direction
- copy density
- route behavior
- fake-state policy
- proof standards
- what “fixed” means

Do not implement from Linear issue title/body alone.

## Runtime honesty law

Runtime app paths must be real.

Forbidden:

- fake success
- fake placement
- fake proof
- fake “step placed”
- dead controls
- placeholder routes that pretend to work
- source-only closure of runtime-visible defects

If unavailable: build the real path, hide it, disable it honestly, or show an honest unavailable state.

## Copy / iconography law

Copy must be minimal, icon-first, and progressively disclosed.

Forbidden on root surfaces:

- raw runtime jargon
- internal architecture names
- debug trust language
- manifesto copy
- explanatory walls
- generic CTA stacks
- decorative nonsemantic icons

Semantic glyphs must have accessible labels.

## Visual law

Light and Dark must come from one semantic token model.

Visual direction for this remediation:

- native Apple luminous graphite-on-mist Light Mode
- restrained, high-contrast Dark Mode from the same semantic model
- full-bleed Stage backgrounds
- root surfaces that feel native, mature, and inspectable
- no bordered dock
- no visible root tab labels by default
- no generic grey utility UI

## Accessibility law

Accessibility is not deferred work.

Every train must preserve or improve:

- VoiceOver labels/actions
- Dynamic Type
- Reduce Motion
- Reduce Transparency
- Increase Contrast
- Differentiate Without Color
- honest focusable controls
- haptics only when system/user settings allow them

## File scope law

Codex must stay inside the dossier’s likely scope unless expansion is clearly justified in closeout.

When file names are unknown, inspect source first. Unexpected files must be justified in closeout.

Forbidden scope expansions:

- unrelated product canon rewrites
- unrelated backend/network/R2 changes
- opportunistic refactors outside the train
- weakening proof or owner-acceptance gates

## Stop conditions

Stop and report if:

- product truth and the dossier conflict
- required deletion touches unknown architecture risk
- the fix would require weakening runtime honesty or proof law
- the path would require cloud/LLM search or hosted personal-data runtime behavior
- a major scope jump is needed outside the bundle
- validation reveals missing required proof gates or dossier sections

## Status ceiling

- no validation = Red
- source/test only = Source Green / Runtime Yellow max
- simulator-only visual proof = Visual Yellow max
- device screenshot/video + tests + docs update = Candidate Runtime/Visual Green
- owner acceptance = Done

## Proof packet

Every bundle closeout must include:

- Status
- Bundle
- Linear issues covered
- Repo issue IDs covered
- Files changed
- Product law implemented
- Architecture law implemented
- Runtime honesty proof
- Validation run
- Validation not run
- Screenshots/videos
- Accessibility proof
- `docs/qa/KNOWN_ISSUES.md` updates
- Status ceiling
- Known risks
- Rollback plan

## Closeout template

```text
Status:

Bundle:

Linear issues covered:

Repo issue IDs covered:

Files changed:

Product law implemented:

Architecture law implemented:

Runtime honesty proof:

Validation run:

Validation not run:

Screenshots/videos:

Accessibility proof:

docs/qa/KNOWN_ISSUES.md updates:

Status ceiling:

Known risks:

Rollback plan:
```
