# 2026-06-22 Codex Remediation Law

**Status:** Active implementation law for the 2026-06-22 runtime QA remediation.  
**Linked decision register:** `docs/truth/2026-06-22-runtime-remediation-decision-register.md`  
**Linked Linear project:** `Ambitions Runtime QA Remediation — 2026-06-22 Device Review`  
**Evidence:** `docs/qa/evidence/2026-06-22-device-review/`

This file is the global law Codex must read before any execution-bundle dossier.

---

## 1. Codex scope law

Codex may decide:

- low-level Swift implementation mechanics,
- local refactors required for the scoped bundle to compile,
- test structure when equivalent proof is preserved,
- file organization when it remains inside the dossier’s allowed scope.

Codex may not decide:

- product behavior,
- IA,
- visual direction,
- route behavior,
- copy density,
- fake-state policy,
- proof standards,
- what “fixed” means.

Codex must not implement from Linear issue titles alone. The implementation authority is the matching repo dossier in `docs/qa/remediation/dossiers/` plus this law.

---

## 2. Execution queue

1. `AMB-1191` — Theme / Design System Tokens
2. `AMB-1194` — Shell / Stage OS
3. `AMB-1192` — Capture Route Graph + Composer
4. `AMB-1193` — Goals Root / Detail Rebuild
5. `AMB-1195` — Today Reality Window / Action Gating
6. `AMB-1196` — Search Find / Act / Inspect
7. `AMB-1197` — Time Native Life Calendar
8. `AMB-1198` — You Settings / Appearance / Privacy
9. `AMB-1199` — Final Proof / Accessibility / Release Gate
10. `AMB-1200` — Register Sync / Control Closeout

One execution bundle per Codex run, except tiny control-plane updates.

---

## 3. Runtime honesty law

Runtime app paths must be real. If a path is unavailable, the app must build the real path, hide it, disable it honestly, or show an honest unavailable state.

Forbidden:

- fake success,
- fake placement,
- fake proof,
- fake route certainty,
- dead controls,
- placeholder route success,
- source-only closure of runtime-visible defects.

Codex closeout must explicitly state whether scoped runtime paths are real, hidden, disabled, or honestly unavailable.

---

## 4. Visual / copy / glyph law

Root surfaces must be icon-first, spatial, and action-first. Copy is minimal and appears only when it changes a user decision or belongs in drilldown/inspection.

Forbidden on root surfaces:

- raw runtime jargon,
- internal object names in headers,
- debug trust language,
- product manifestos,
- explanatory paragraphs,
- generic CTA stacks,
- fake status chips,
- decorative nonsemantic icons.

Semantic glyphs must have accessible labels. Root UI must never rely on color alone.

---

## 5. Status ceiling

```text
No validation = Red
Source/test only = Source Green / Runtime Yellow max
Simulator-only visual proof = Visual Yellow max
Device screenshot/video + tests + docs update = Candidate Runtime/Visual Green
Owner acceptance = Done
```

Codex can move a bundle to In Review when source/tests/audits and required proof artifacts exist. Done requires owner acceptance.

---

## 6. Standard proof packet

Every bundle closeout must include:

- bundle ID,
- repo issue IDs covered,
- Linear QA leaves covered,
- files changed,
- product decisions implemented,
- validation run,
- validation not run,
- screenshots/videos produced,
- accessibility proof,
- audit output,
- persistence proof where relevant,
- route proof where relevant,
- `docs/qa/KNOWN_ISSUES.md` update summary,
- status ceiling,
- known risks,
- rollback plan.

---

## 7. docs/qa/KNOWN_ISSUES.md law

Codex must update `docs/qa/KNOWN_ISSUES.md` for every affected issue row.

Allowed status movement:

- still present → candidate resolved / proof pending,
- still present → source repaired / runtime proof required,
- candidate resolved → closed verified only with required proof and owner acceptance.

Do not mark `Closed - verified` from source-only work.

---

## 8. Stop conditions

Codex must stop and report instead of continuing if:

- the dossier conflicts with current product truth,
- required deletion touches unknown architecture risk,
- two same-root-cause failures occur,
- three total repair loops occur,
- a fix requires weakening runtime honesty or proof law,
- a feature would require hosted/cloud AI for core behavior,
- a path would upload private life graph data to R2 or any backend.

---

## 9. Closeout template

```text
Status:
Status ceiling:
Bundle:
Repo issue IDs covered:
Linear QA leaves covered:
Files changed:
Product decisions implemented:
Validation run:
Validation not run:
Screenshots/videos:
Accessibility proof:
Persistence proof:
Route proof:
Audits:
Known issues updated:
Known risks:
Rollback plan:
Owner review needed:
```
