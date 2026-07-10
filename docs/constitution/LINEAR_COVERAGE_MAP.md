# Wave 0 — Linear Coverage Map

Status: Wave 0 control plane installed; ongoing Project-by-Project coverage reconciliation required  
Registry: `docs/constitution/opportunity-register.json`

## Baseline

- P0 opportunities: 18
- P1 opportunities: 100
- Total mandatory launch opportunities: 118
- Current implementation claim: none from this registry

## Canonical launch control plane

- Initiative: **Ambitions Constitution → Market-Leading App Store Launch**
- Governance Project: **Ambitions Constitution Compliance + Implementation Program**
- Milestone: **Wave 0 — Constitution Enforcement**
- Acceptance document: **Wave 0 — Constitutional Enforcement Acceptance Packet**

A required Parent Issue could not be created because the Linear workspace issue limit was reached. The acceptance document temporarily preserves the packet but does not replace the canonical Parent Feature hierarchy. Create the Parent Issue when capacity is available.

## Existing Project reuse

The registry maps work into existing Projects wherever their Epic boundary already fits. Examples include:

- Domain Model Design
- SwiftData Persistence Design
- Repository + Unit of Work Design
- Command / Mutation / Receipt Spine Design
- Private Life Runtime Architecture Design
- Scenario Catalog + Golden Runtime Gates
- Threat Model + Abuse Case Design
- Build / Test / CI Validation Design
- Semantic Design Tokens Design
- Stage Primitives Design
- Product Object Visual Grammar Design
- Performance + Memory + Launch Time Design
- Store Health + Recovery Design
- Logging / Telemetry / Crash Privacy Design
- Release Train / TestFlight / App Store Design
- Entitlement + Subscription Design
- App Group + Multi-Process Data Design
- EventKit / Reminders Design
- WidgetKit, App Intents, Share Extension, and Deep Links design Projects

## Confirmed and created Project gaps

Wave 0 confirmed and created the six missing Project/Epic boundaries:

- Ambitions Constitution Compliance + Implementation Program
- App Lifecycle + Background Execution Design
- CloudKit Continuity + Multi-Device Merge Design
- Dependency + Supply-Chain Governance Design
- Localization + Temporal Culture Design
- Swift Concurrency + Actor Isolation Design

These Projects are Planned except the governance Project, which is In Progress. They contain no implementation claim and require full source-aware design specifications before Parent Features or Codex leaves.

## Control-plane rule

Do not create one Project per opportunity. Use:

```text
Initiative
→ Project / Epic
→ Milestone / Wave
→ Parent Feature acceptance object
→ bounded Codex leaf
```

Each opportunity remains traceable through its registry ID and may map to more than one Project, but it must have one primary acceptance owner.

## Next Linear pass

1. Attach existing Projects to the launch Initiative only when next touched.
2. Upgrade each owning Project to the constitutional Full Design Spec Standard.
3. Create one Parent Feature per P0 acceptance domain when issue capacity is available.
4. Create P1 Parent Features in their owning Projects only after the design spec is Spec Ready.
5. Do not bulk rewrite active Projects; migrate them when next touched.
6. Keep Accepted Yellow distinct from First-Class Green and forbidden as final launch acceptance.
