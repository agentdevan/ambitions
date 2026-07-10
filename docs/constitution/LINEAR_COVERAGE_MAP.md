# Wave 0 — Linear Coverage Map

Status: Initial repo/Linear mapping; requires owner-approved Linear control-plane update  
Registry: `docs/constitution/opportunity-register.json`

## Baseline

- P0 opportunities: 18
- P1 opportunities: 100
- Total mandatory launch opportunities: 118
- Current implementation claim: none from this registry

## Existing Project reuse

The registry intentionally maps work into existing Projects wherever their Epic boundary already fits. Examples include:

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

## Proposed missing Projects

The initial coverage audit identifies six probable portfolio gaps. Create only after confirming no existing active Project fully owns the scope:

- Ambitions Constitution Compliance + Implementation Program
- App Lifecycle + Background Execution Design
- CloudKit Continuity + Multi-Device Merge Design
- Dependency + Supply-Chain Governance Design
- Localization + Temporal Culture Design
- Swift Concurrency + Actor Isolation Design

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

1. Create or designate the Constitution compliance governance Project.
2. Attach existing Projects to the launch initiative as they are touched.
3. Resolve the six proposed gaps.
4. Create one Parent Feature per P0 acceptance domain.
5. Create P1 Parent Features in their owning Projects only after their design spec is Spec Ready.
6. Do not bulk rewrite active Projects; migrate them when next touched.
