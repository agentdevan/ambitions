# 08 — Implementation / Codex / Repo Integration

Status: locked implementation-planning canon, docs-only.

Purpose:

- implementation readiness gate
- SwiftUI architecture / file boundaries
- Codex prompt rules
- repo integration order
- proof artifacts
- release-claim safety

This phase does not start implementation.

Do not implement Ambitions UI from this document until repo orientation, source-truth cleanup, file-boundary approval, and scoped implementation prompts exist.

---

## 1. Source-Truth Priority

1. Ambitions Design System
2. Canon Index / 10-10 Maturity Gate
3. Product Canon
4. Continuity Layer & Chrome
5. Signature Object Specs
6. Trust / Privacy / Automation
7. Accessibility / Motion / Performance
8. QA / Preview / Visual Drift
9. Native Shell / Tokens / Materials
10. Implementation / Codex / Repo Integration
11. Visual references
12. Existing repo convenience

If this document conflicts with a higher-priority source, the higher-priority source wins.

If repo convenience conflicts with any canon document, canon wins.

---

## 2. Implementation Thesis

Ambitions must be implemented as a governed Signature Interface System, not as ad hoc SwiftUI screens, a generic component library, a stack of cards, or a visual mock translated directly into code.

Implementation maturity means:

- source-truth discipline
- narrow file boundaries
- first-class Signature Objects
- centralized tokens/materials
- continuity signal routing
- accessibility and reduced-motion coverage
- preview fixtures
- proof artifacts
- Green / Yellow / Red status honesty

---

## 3. Implementation Readiness Gate

A design or Codex batch may proceed only when it has:

1. source-truth file references
2. object spec
3. native iPhone contract coverage
4. token/material mapping
5. Continuity Layer signal behavior
6. accessibility requirements
7. reduced-motion behavior
8. trust/receipt behavior where relevant
9. preview fixture requirements
10. visual QA criteria
11. rollback plan
12. proof artifacts required

Hard Red:

- implementation starts from visual inspiration alone
- broad refactor without file-boundary authorization
- claims completion without proof
- source-truth conflict unresolved
- accessibility or trust path missing

---

## 4. Recommended Module / Folder Structure

```text
AmbitionsDesignSystem/
  Tokens/
  Materials/
  Typography/
  Motion/
  Haptics/
  Iconography/

AmbitionsInterface/
  Shell/
  ContinuityLayer/
  Primitives/
  Compounds/
  SignatureObjects/

Features/
  Today/
  Goals/
  Capture/
  Plan/
  You/

PreviewFixtures/
  TodayFixtures
  GoalsFixtures
  CaptureFixtures
  PlanFixtures
  YouFixtures

VisualQA/
  ReferenceBoards/
  SnapshotBaselines/
  DriftReports/

Docs/
  ProductCanon/
  DesignSystem/
  Continuity/
  SignatureObjects/
  TrustPrivacyAutomation/
  AccessibilityMotionPerformance/
  QA/
  Implementation/
```

This structure is recommended, not rigid, but the architectural separation is mandatory.

---

## 5. Dependency Direction

Allowed dependency flow:

```text
DesignSystem → Interface Primitives → Compound Controls → Signature Objects → Features
```

Feature screens may compose Signature Objects.

Feature screens may not define:

- raw color values
- material recipes
- continuity signals
- global chrome behavior
- Signature Object internals
- source-truth copy variants
- trust behavior
- accessibility meaning

---

## 6. Top-Level Screen Composition

Required model:

```text
TodayScreen = AmbitionsShell + RealityMeridian + StartHereSurface
GoalsScreen = AmbitionsShell + ConstellationAtlas + OrbitalLens
CaptureScreen = AmbitionsShell + AtmosphereComposer
PlanScreen = AmbitionsShell + LifeShapeField
YouScreen = AmbitionsShell + UserSystemProfile
```

Top-level screens should be thin composition layers.

Hard Red:

- feature screen owns everything
- top-level surface becomes custom pile of cards
- primary object is not dominant
- top-level IA changes to accommodate implementation convenience

---

## 7. File Boundary Rules

Recommended limits:

- primitive view: under 150 lines
- compound control: under 250 lines
- Signature Object root: under 400 lines
- feature screen: under 250 lines
- fixtures separated from implementation
- model/state separated from view when state complexity grows

Rules:

- no broad refactor without source-truth reason
- no feature-local token invention
- no duplicated material modifier
- no generic Card component as default product structure
- no business logic buried in SwiftUI body
- no continuity signal routing outside Continuity Layer

Hard Red:

- giant feature views own everything
- feature code invents visual language
- Continuity signals appear randomly
- source-truth copy is scattered
- accessibility state exists only inside visual view logic

---

## 8. Component Ownership

| Layer | Owns | Must not own |
| --- | --- | --- |
| Tokens | values and semantic aliases | feature decisions |
| Materials | visual substances | screen layouts |
| Primitives | small reusable parts | product identity |
| Compounds | common controls | top-level object behavior |
| Signature Objects | Ambitions product inventions | global shell |
| Features | composition and routing | raw materials/tokens |
| Continuity Layer | state routing and chrome signals | feature-specific clutter |
| Trust Layer | source, receipts, automation policy | chatbot persona |
| PreviewFixtures | canonical states | random demo filler |

---

## 9. Codex Prompt Rules

Every Codex prompt must include:

1. objective
2. source-truth files to inspect first
3. files allowed to edit
4. files forbidden to edit
5. canon rules enforced
6. Hard Red stop conditions
7. implementation steps
8. accessibility requirements
9. reduced-motion requirements
10. preview/test requirements
11. proof artifacts required
12. final Green / Yellow / Red report format

Codex must not improvise product direction.

---

## 10. Codex Hard Red Stop Conditions

Codex must stop and report Red if:

- source-truth file is missing
- requested change contradicts Design System
- top-level IA changes are required
- Mission Control would become top-level tab
- Capture becomes busy board/feed/chat
- Today loses Reality Meridian / Start Here relationship
- Time becomes calendar clone
- Goals becomes KPI/habit/dashboard model
- You becomes social/admin profile
- broad refactor is required but not authorized
- accessibility path cannot be preserved
- trust/source/receipt behavior is missing for automation
- tests/previews cannot be run or inspected

---

## 11. Codex Proof Artifacts

Required final report format:

```text
Status: Green / Yellow / Red

Files inspected:
- ...

Files changed:
- ...

Canon enforced:
- ...

Accessibility notes:
- ...

Reduced Motion notes:
- ...

Preview/test evidence:
- ...

Screenshots / visual QA:
- ...

Known limitations:
- ...

Follow-up required:
- ...
```

Green requires proof.

Yellow means the implementation direction is acceptable but proof/maturity is incomplete.

Red blocks completion claims.

---

## 12. Repo Integration Sequence

When the repo is reintroduced, implementation must proceed through audit, canon cleanup, architecture hardening, then object implementation.

Do not jump straight to visual polish.

Required order:

1. Repo orientation
2. Canon/source-truth cleanup
3. Token/material inventory
4. Native shell and tab audit
5. Continuity signal audit
6. Signature Object mapping
7. Preview/test inventory
8. Accessibility/motion/trust gap audit
9. P0 cleanup batch
10. Token/material implementation
11. Shell/Continuity Dock implementation
12. Context Crown / Trust Seam foundation
13. Today Reality Meridian / Start Here implementation
14. Capture Atmosphere Composer implementation
15. You Automation & Trust implementation
16. Plan LifeShape Field implementation
17. Goals Constellation Atlas implementation
18. QA gates and visual drift prevention

---

## 13. Initial Repo Audit Outputs

Required Phase 0 repo audit output:

- repo map
- app entry points
- design-system folders
- feature folders
- shell/tab implementation
- existing components/primitives
- screenshots/previews
- tests/CI/gates
- old/conflicting canon
- P0/P1/P2 issue list
- current top-level IA evidence
- current accessibility/motion/trust posture
- visual drift risks

No implementation begins before this audit.

---

## 14. Repo Integration Hard Reds

Hard Red if:

- repo uses different top-level IA
- Mission Control is top-level
- Capture is plus-tab or feed-first
- Time is calendar clone
- Goals is dashboard/habit/KPI model
- You is social/admin profile
- raw visual styles dominate
- source-truth docs conflict unresolved
- completion claims lack proof
- no preview path for primary objects
- accessibility state is missing
- trust/receipt behavior missing for adaptive surfaces

---

## 15. Implementation Sequencing Plan

### Batch 0 — Canon Packaging

Objective: place split canon docs into repo-ready Markdown structure.

Acceptance:

- docs exist separately
- source-truth hierarchy clear
- old conflicting docs marked deprecated or listed for follow-up

### Batch 1 — Repo Canon Cleanup

Objective: remove or deprecate conflicting old canon and establish source-truth read order.

Hard Red:

- old Chrome & Behavior overrides Continuity Layer
- visual references treated above Design System

### Batch 2 — Token / Material Foundation

Objective: implement semantic tokens and material recipes.

Acceptance:

- no raw feature colors
- locked materials exist centrally
- candidate values clearly marked until visual QA

### Batch 3 — Native Shell + Continuity Dock

Objective: establish five-tab shell and Dock behavior.

Acceptance:

- Today, Goals, Capture, Plan, You only
- Capture icon not plus
- Plan icon not menu
- no red badges

### Batch 4 — Context Crown + Trust Seam Foundations

Objective: implement orientation and trust chrome.

Acceptance:

- Context Crown one phrase max
- Trust Seam supports Closed/Peek/Open/Route
- no assistant drawer

### Batch 5 — Today Reality Meridian + Start Here

Objective: implement flagship Today object.

Acceptance:

- Start Here emerges from active node
- Why this? source path exists
- no task-list dominance

### Batch 6 — Capture Atmosphere Composer

Objective: implement quiet composer-first Capture.

Acceptance:

- keyboard-native composer
- route reveal only after input
- no feed/chat/category board

### Batch 7 — You Automation & Trust

Objective: expose trust, privacy, permissions, automation level, receipt archive.

Acceptance:

- Automation & Trust visible
- Manual/Suggest/Preview Reflow available
- privacy controls visible

### Batch 8 — Time LifeShape Field

Objective: implement capacity shaping without calendar clone.

Acceptance:

- Week default
- open/goal/protected/pressure readable
- reflow preview

### Batch 9 — Goals Constellation Atlas + Orbital Lens

Objective: implement life-area atlas and selected area depth.

Acceptance:

- equal-weight life areas
- reorder/pin/hide/rename
- no KPI/habit/astrology drift

### Batch 10 — QA / Accessibility / Performance Hardening

Objective: complete preview coverage, visual QA, accessibility, reduced motion, performance tuning.

Acceptance:

- required fixtures exist
- Visual QA 95+ top-level, Today/Capture target 98+
- no Hard Reds

---

## 16. Rollback Rules

Every implementation batch needs rollback plan:

- files changed
- feature flag or revert strategy when possible
- state migration risk if data model changes
- visual fallback if material/performance issue appears
- accessibility fallback if custom object fails review

Hard Red:

- irreversible change without proof
- data model mutation without migration path
- broad refactor with no rollback strategy

---

## 17. Release Claim Safety

Do not claim:

- implemented
- complete
- production-ready
- shipped
- merged
- accepted
- tested
- accessible
- performant
- release-ready

unless proof artifacts support the claim.

Required proof for release-like claims:

- files changed
- tests/checks run
- previews/screenshot evidence
- accessibility notes
- reduced-motion proof
- visual QA score
- known limitations
- no unresolved Hard Reds

---

## 18. Pre-Repo / Pre-Codex 10/10 Gate

Before repo or Codex work begins, the split canon must have:

1. Product Canon complete
2. Continuity Layer & Chrome complete
3. Signature Object Specs complete
4. Trust / Privacy / Automation complete
5. Accessibility / Motion / Performance complete
6. QA / Preview / Visual Drift complete
7. Native Shell / Tokens / Materials complete
8. Implementation / Codex / Repo Integration complete
9. overall maturity score assessed
10. remaining unresolved items explicitly labeled as validation tasks, not canon gaps

Repo/Codex may begin only when unresolved items are implementation-proof tasks, visual QA tasks, or device-validation tasks — not product-direction gaps.

---

## 19. Implementation Hard Reds

Stop and repair if any are true:

1. source-truth hierarchy unresolved
2. implementation starts before canon is packaged
3. Codex prompt lacks source-truth inspection
4. broad refactor not authorized
5. top-level IA changes
6. feature code invents tokens/materials
7. continuity signals bypass approved surfaces
8. accessibility omitted
9. reduced motion omitted
10. trust/source/receipt omitted for adaptive behavior
11. previews missing for primary object
12. screenshots not reviewed for UI work
13. completion claimed without proof

---

## 20. Next Safe Step

After this docs-only canon packaging phase, the next safe phase is:

```text
Repo Phase 0 — Orientation Audit
```

Repo Phase 0 may inspect app code and produce an evidence-based map. It must still not implement features.
