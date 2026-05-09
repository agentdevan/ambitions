# 00 — Canon Index / 10-10 Maturity Gate

Status: canonical control document, docs-only.

Purpose:

- index all split Ambitions canon documents
- reconcile maturity scores
- distinguish canon gaps from validation tasks
- define what 10/10 pre-repo means
- define the gate for repo/Codex work

This document does not implement app behavior. It does not prove visual QA, accessibility, performance, tests, previews, release readiness, App Store readiness, or TestFlight readiness.

---

## 1. Source-Truth Priority

1. Ambitions Design System
2. `00_Canon_Index_10_10_Maturity_Gate.md`
3. `01_Product_Canon.md`
4. `02_Continuity_Layer_Chrome.md`
5. `03_Signature_Object_Specs.md`
6. `04_Trust_Privacy_Automation.md`
7. `05_Accessibility_Motion_Performance.md`
8. `06_QA_Preview_Visual_Drift.md`
9. `07_Native_Shell_Tokens_Materials.md`
10. `08_Implementation_Codex_Repo_Integration.md`
11. Visual references
12. Existing repo convenience

If lower-priority source truth conflicts with higher-priority source truth, the higher-priority source wins.

---

## 2. Complete Split Canon Set

| Canon document | Status | Role |
| --- | --- | --- |
| `Ambitions_Design_System.md` | Highest truth | visual, product, interaction, IA, implementation, shell, chrome, behavior, motion, image generation, and design-system source truth |
| `00_Canon_Index_10_10_Maturity_Gate.md` | Current | readiness gate and maturity reconciliation |
| `01_Product_Canon.md` | Locked | identity, IA, primary objects, launch scope, anti-drift |
| `02_Continuity_Layer_Chrome.md` | Locked | Context Crown, Dock, Edge, Trust Seam, Reflow, Receipts, Threads |
| `03_Signature_Object_Specs.md` | Locked direction | Today, Goals, Capture, Time, You primary objects |
| `04_Trust_Privacy_Automation.md` | Locked direction | source labels, permissions, receipts, automation levels |
| `05_Accessibility_Motion_Performance.md` | Locked direction | nonvisual behavior, motion, haptics, performance budget |
| `06_QA_Preview_Visual_Drift.md` | Locked direction | rubrics, fixtures, gates, drift prevention, copy QA |
| `07_Native_Shell_Tokens_Materials.md` | Locked structure | native contract, tokens, materials, shell behavior |
| `08_Implementation_Codex_Repo_Integration.md` | Locked planning | architecture, Codex rules, proof artifacts, repo sequence |

---

## 3. Maturity Score Reconciliation

| Domain | Score | Status |
| --- | ---: | --- |
| Product Canon | 10.0 | Green |
| Continuity Layer & Chrome | 9.7 | Green, visual/device validation later |
| Signature Object Specs | 9.6 | Green, visual/device validation later |
| Trust / Privacy / Automation | 9.7 | Green, launch copy/privacy wording later |
| Accessibility / Motion / Performance | 9.6 | Green, implementation/device validation later |
| QA / Preview / Visual Drift | 9.65 | Green, actual visual examples later |
| Native Shell / Tokens / Materials | 9.45 | Yellow-Green, exact values pending visual QA |
| Implementation / Codex / Repo Integration | 9.7 | Green, repo validation later |

Current aggregate pre-repo canon maturity: **9.68 / 10**.

Rounded operating score: **9.7 / 10** before classification.

Final pre-repo/pre-Codex canon maturity: **10 / 10** after remaining unresolved work is classified as validation/proof rather than product-direction uncertainty.

---

## 4. Why 10/10 Does Not Mean Release Readiness

10/10 pre-repo canon does not mean:

- app is implemented
- design is visually validated
- tokens are final hex values
- screenshots pass QA
- accessibility is proven in code
- performance is proven on device
- Codex can edit immediately without repo audit
- release readiness exists

10/10 pre-repo canon means:

- product direction is locked
- architecture rules are locked
- object specs are executable
- gates are explicit
- drift is blocked
- implementation can begin only through the prescribed audit-and-proof sequence when repo work is authorized

---

## 5. Canon Gaps vs Validation Tasks

### Canon Gaps

Current blocking canon gaps: **None**.

All required pre-repo canon domains now exist:

- product identity
- locked IA
- Signature Objects
- Continuity Layer
- native shell
- tokens/materials
- trust/privacy/automation
- accessibility
- motion/haptics
- performance
- QA gates
- preview matrix
- copy QA
- visual drift governance
- implementation/Codex rules
- repo integration plan

### Validation Tasks

These are not canon gaps. They are required before release-quality claims but do not block repo orientation or implementation planning.

| Validation task | Why not a canon gap | Required proof later |
| --- | --- | --- |
| Exact token values | semantic token system is locked | visual QA on Today, Capture, You |
| Ambient State Tint exact values | rules/ranges are locked | screenshot comparison and contrast review |
| Material visual pass/fail examples | gallery spec exists | visual drift gallery examples |
| Device performance | budget exists | device profiling |
| Dynamic Type validation | rules exist | screenshots/previews |
| VoiceOver flow validation | summaries exist | accessibility run-through |
| Reduce Motion validation | equivalents exist | preview/device proof |
| Dock icon geometry | icon meanings locked | visual QA |
| Trust Seam density | behavior locked | screenshot QA |
| Fixture payload exact values | fixture matrix exists | preview fixture files |

### Future Implementation Proof

These cannot be proven in canon:

- files inspected
- files changed
- tests run
- previews compiled
- screenshots captured
- CI passing
- accessibility inspector results
- performance profiling
- release readiness

Never claim these without repo evidence.

---

## 6. 10/10 Pre-Repo Canon Definition

Ambitions reaches 10/10 pre-repo canon maturity when all are true:

1. Complete split canon exists.
2. Source-truth hierarchy is explicit.
3. Product identity is locked.
4. Top-level IA is locked.
5. Primary objects are locked.
6. Continuity Layer is locked.
7. Trust/privacy/automation policy is locked.
8. Accessibility/motion/performance contracts are locked.
9. QA/preview/visual drift gates are locked.
10. Native shell/tokens/material rules are locked.
11. Implementation/Codex/repo rules are locked.
12. Remaining unresolved work is validation/proof, not canon uncertainty.
13. Hard Reds are explicit across all domains.
14. Repo/Codex work is gated by proof discipline.
15. No future work depends on an overloaded monolith.

---

## 7. 10/10 Gate Assessment

| Gate | Status | Evidence |
| --- | --- | --- |
| Split canon exists | Green | domain documents installed in `docs/AmbitionsCanon/` |
| Source-truth hierarchy explicit | Green | README and each domain document |
| Product identity locked | Green | Product Canon and Design System |
| IA locked | Green | Product Canon |
| Primary objects locked | Green | Product Canon + Signature Object Specs |
| Continuity Layer locked | Green | Continuity Layer & Chrome |
| Trust/privacy/automation locked | Green | Trust / Privacy / Automation |
| Accessibility/motion/performance locked | Green | Accessibility / Motion / Performance |
| QA/preview/drift locked | Green | QA / Preview / Visual Drift |
| Native shell/tokens/materials locked | Green with validation caveat | token names locked; exact values validation later |
| Implementation/Codex/repo rules locked | Green | Implementation / Codex / Repo Integration |
| Validation tasks separated from canon gaps | Green | this document |
| Hard Reds explicit | Green | all domain docs |

Gate result: **Green for pre-repo canon maturity with validation tasks labeled.**

---

## 8. Ready for Repo/Codex Gate

### Repo Audit May Begin When

Repo audit may begin after this package is installed and the user authorizes repo inspection.

Allowed first repo action:

```text
Repo Phase 0 — Orientation Audit
```

Required outputs:

- repo map
- app entry points
- feature folders
- design-system folders
- top-level tab implementation
- navigation structure
- preview fixtures
- design docs
- tests/CI
- accessibility coverage
- screenshots/references
- conflicting canon sources
- initial P0/P1/P2 issue list

No implementation during Phase 0.

### Codex Prompting May Begin When

Codex prompt drafting may begin after repo audit identifies actual file structure, or after the user explicitly requests repo-agnostic prompt templates.

Codex editing may begin only after source-truth docs are available, file boundaries are known, first batch scope is narrow, Hard Reds are included, and proof artifacts are required.

### Implementation May Begin When

Implementation may begin only after:

1. repo orientation is complete
2. conflicting canon is cleaned or marked deprecated
3. top-level IA audit is complete
4. token/material baseline is known
5. preview/test capability is known
6. first P0 batch is scoped with proof artifacts

---

## 9. First Repo Phase After Canon

Next permitted phase:

```text
Repo Phase 0 — Orientation Audit
```

Inspect only. Do not modify app code.

---

## 10. Pre-Repo Canon Hard Reds

Stop if any appear:

1. User asks to skip repo audit and directly implement broad changes.
2. Codex prompt lacks source-truth inspection.
3. Old visual reference is treated above Design System.
4. Exact token values are claimed final without visual QA.
5. Release readiness is claimed before proof.
6. Accessibility is deferred.
7. Trust/source/receipt behavior is deferred for adaptive features.
8. Mission Control is promoted to top-level.
9. Capture becomes feed/chat/board.
10. Product identity softens into generic productivity UI.

---

## 11. Final Decision

Ambitions is **10/10 pre-repo and pre-Codex at the canon level**.

The product direction is mature enough to proceed to Repo Phase 0 — Orientation Audit.

The product is not yet implemented, visually validated, tested, accessible in code, performant on device, or release-ready.
