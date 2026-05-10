<!-- markdownlint-disable MD013 -->

# Codex Review Board

Status: Active review gate router  
Date updated: 2026-05-10  
Authority: Subordinate to `docs/truth/*` and `.codex/DEPARTMENT_REGISTRY.md`

This file defines role-based review gates for Codex work. It is not human
approval, release approval, legal/privacy signoff, or public accessibility
certification.

## 1. Review Rule

Every non-trivial change must name the review board lanes it affects and close
with pass, fail, not run, or not applicable for each required lane.

## 2. Review Matrix

| Work type | Required lanes | Optional lanes |
| --- | --- | --- |
| Product/design truth | Product, Design, Codex Process | Accessibility, Privacy |
| Source implementation | iOS Engineering, QA | Product, Design, Privacy, Accessibility |
| UI/visual work | Design, Accessibility, QA, iOS Engineering | Product, Performance |
| Accessibility/motion | Accessibility, Design, QA | iOS Engineering |
| Performance | iOS Engineering, QA, Performance/Build Systems | Design if UI |
| Privacy/trust/data | Privacy/Trust, iOS Engineering, QA | Release |
| Release/proof | Release, QA, Privacy/Trust if data claims | Build Systems |
| Build/tooling | Build Systems, QA, Codex Process | Privacy/Trust if tool can read secrets/data |
| Docs/control-plane | Codex Process, Repo Hygiene | Release if claims appear |
| Archive/delete | Repo Hygiene, Codex Process, owning department | Release if evidence/history involved |

## 3. Lane Criteria

### Product

Pass when:

- work maps to a current product object or journey
- no obsolete IA or generic product pattern is promoted
- user-facing language follows product truth

Fail when:

- Plan/Profile/Captures/Insights/Habits are revived as active top-level IA
- blocked chatbot/dashboard/task-app drift appears
- fake certainty or shame language appears

### Design

Pass when:

- primary object remains dominant
- layout is coherent at claimed states
- visual density supports object meaning
- visual proof is present when visual quality is claimed

Fail when:

- generic card stack or dashboard composition appears
- decorative motion/atmosphere replaces state
- visual proof is stale or missing for visual claims

### iOS Engineering

Pass when:

- source ownership is clear
- compatibility seams are named
- tests/build are run when source changes
- rollback is feasible

Fail when:

- source mutation happens outside allowed paths
- app behavior changes during docs-only work
- generated project/package/dependency changes appear without approval

### QA

Pass when:

- validation pack selection matches risk
- command outputs and exit codes are recorded
- failures are separated from not-run checks

Fail when:

- validation is implied but not run
- advisory findings are hidden
- no rollback or regression path exists

### Accessibility

Pass when:

- VoiceOver, Dynamic Type, Reduce Motion, contrast, touch target, and gesture
  alternatives are checked or explicitly not run
- no public conformance claim is made without evidence

Fail when:

- critical state is visual-only
- primary action is inaccessible
- accessibility proof is claimed from docs alone

### Privacy / Trust

Pass when:

- local-first/provider exclusion remains intact
- data/control/receipt implications are named
- no backend/cloud/user-data server assumption appears

Fail when:

- blocked provider/backend/auth/sync/analytics/telemetry/external LLM
  assumptions appear without approval
- privacy/legal approval is implied without human review

### Release

Pass when:

- release truth is followed
- hard claims not made are explicit
- proof has current command/log/artifact context

Fail when:

- release, TestFlight, App Store, device, accessibility, performance, legal, or
  hosted CI proof is claimed without current evidence

### Build Systems

Pass when:

- XcodeGen/build/test/tooling changes are scoped
- local commands are captured with exit codes
- hosted CI remains absent unless approved

Fail when:

- hosted workflow, dependency, signing, or runner changes appear without
  explicit approval

### Repo Hygiene / Codex Process

Pass when:

- truth files are read first
- stale/historical material is classified
- commits are path-limited
- Green/Yellow/Red is recorded

Fail when:

- lower-authority docs override truth files
- destructive cleanup lacks inbound refs and rollback
- old prompts are used as current authority

## 4. Review Board Closeout Template

```text
Review board:
- Product:
- Design:
- iOS Engineering:
- QA:
- Accessibility:
- Privacy/Trust:
- Release:
- Build Systems:
- Repo Hygiene:
- Codex Process:
```

Each lane should be `pass`, `fail`, `not run`, or `not applicable`, with one
short reason.

## 5. Phase 9 Gate Result

Phase 9 result: Green.

Validation:

- docs-only review board artifact
- no app/source/runtime files touched
- no release/accessibility/performance/legal approval claimed
