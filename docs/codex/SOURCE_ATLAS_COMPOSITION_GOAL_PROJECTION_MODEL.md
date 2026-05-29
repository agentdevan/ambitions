# Source Atlas Composition + Goal Projection Model

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-stale_or_unknown_active_status-40375966

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: source-truth lock for Source Atlas before runtime implementation.
Owner: Source Atlas / HPS / AOS / LDI integration.
Scope: architecture, gates, factory rules, projection contracts, and Codex OS enforcement.

## 1. Decision

Source Atlas must not become a one-pack-per-goal template library.

Source Atlas is a composable, source-backed world-knowledge graph. A user goal is compiled as a personalized projection through reusable domain, capability, level, requirement, role, path, proof, and option-value graph pieces.

Canonical rule:

```text
Source packs are reusable ingredients.
Goals are projection requests.
AOS/LDI compile personalized path instances.
Plan/Today generate concrete steps from user context.
```

## 2. Why this exists

One pack per goal would create sprawl, duplicated claims, stale duplicated requirements, static same-path outputs, and weak personalization.

The mature Source Atlas model supports:

- broad domain reuse
- narrow skill extraction
- highest-path reuse without duplication
- alternative pathing
- option value preservation
- source freshness at claim level
- user-specific path instances
- generated steps instead of static steps

## 3. Object model

Source Atlas must support these objects before pack creation scales:

| Object | Purpose |
|---|---|
| `DomainPack` | Broad domain knowledge, such as sports, music, career, education, civic, software, home-life. |
| `SpecificDomainPack` | Specific field, such as pickleball, football, iOS development, product management. |
| `CapabilityGraph` | Skills, capabilities, concepts, and their dependencies inside a domain. |
| `CapabilityNode` | Atomic skill/capability node, such as pickleball serve or football catching. |
| `CapabilityEdge` | Prerequisite, supports, conflicts, transfers-to, or adjacent-to relationship. |
| `LevelLadder` | Beginner through elite/pro/adjacent progression levels. |
| `RequirementOverlay` | Source-sensitive requirements: official rules, eligibility, equipment, certification, deadlines. |
| `RoleOverlay` | Position/role-specific logic: quarterback, product manager, singer, coach. |
| `PathOverlay` | High-level ambition overlays: make varsity, make NFL, become pickleball pro, become president. |
| `ProofMap` | Evidence/proof options mapped to capability and requirement nodes. |
| `AlternativePathSet` | Adjacent viable paths when the original path changes. |
| `OptionValueMap` | What still counts across pivots and abandoned goals. |
| `ProjectionRecipe` | Composable recipe that explains how to build a projection from graph pieces. |
| `GoalProjection` | Interpreted goal scope produced from user goal text. |
| `ProjectionProfile` | User starting position, constraints, seriousness, time, proof, privacy, and source state. |
| `PersonalPathInstance` | User-specific path instance created from a projection. |
| `StepCandidateSeed` | Seed for AOS/LDI/Plan to generate concrete steps. |

## 4. Pack hierarchy

### Domain pack

Examples:

```text
sports
career
education
music
software
public-office
home-life
finance
parenting
```

### Specific domain pack

Examples:

```text
sports.pickleball
sports.football
career.product-management
software.ios-development
music.independent-release
```

### Capability graph

Examples for pickleball:

```text
serve
return
dink
third-shot drop
footwork
court positioning
rules
scoring
equipment
match strategy
tournament prep
```

Examples for football:

```text
catching
route running
blocking
tackling
conditioning
film study
position IQ
strength
speed
team tryout prep
```

### Level ladder

Example:

```text
beginner
recreational
school / club
local competitive
regional competitive
elite amateur
college / professional pipeline
pro
coach / adjacent path
```

### Requirement overlay

Requirement overlays hold source-sensitive material:

```text
rules
eligibility
official equipment standards
deadlines
certifications
age/grade limits
jurisdiction / league / institution
```

### Path overlay

Path overlays are high-level ambition routes that point into reusable domain/capability/requirement graph pieces.

Examples:

```text
make varsity football
play college football
make it to the NFL
become pickleball pro
become pickleball coach
become product manager
become U.S. president
```

## 5. Goal Projection Engine

The Goal Projection Engine must transform user goals into source-backed, personalized projections.

Pipeline:

```text
user goal text
→ goal intent classification
→ domain detection
→ ambition level detection
→ skill/role/achievement/eligibility classification
→ relevant domain pack selection
→ relevant overlays
→ capability graph slice
→ missing starting-position questions
→ user constraints / proof / time / privacy
→ source/freshness filtering
→ path variants
→ proof options
→ step candidate seeds
→ source/projection receipt
```

Output is `PersonalPathInstance`, not a raw pack.

## 6. Goal intent taxonomy

| Intent | Example | Projection behavior |
|---|---|---|
| Skill improvement | Improve my pickleball serve | Select capability node slice plus drills/proof. |
| Starter goal | Learn pickleball | Starter kit plus beginner ladder. |
| Achievement goal | Make varsity football | School/team overlay plus proof/tryout/season path. |
| Elite ambition | Make it to the NFL | Full ladder plus elite/pro overlay and alternative paths. |
| Role goal | Become product manager | Career domain plus role, skill, proof, and market overlays. |
| Civic/legal goal | Become U.S. president | Official/legal-civic source overlay and strict no-claim handling. |
| Certification goal | Get certified as X | Certification overlay with strict source/freshness. |
| Creative project | Release an EP | Music release domain plus project/proof path. |
| Maintenance goal | Stay consistent with fitness | Non-proof thread, proof/recovery-aware recurring path. |
| Exploration goal | Maybe become a developer | Low-commitment exploratory projection. |

## 7. Personalization inputs

The same source projection must produce different personal path instances based on:

- starting skill
- age/grade/location when relevant
- available time
- schedule
- season of life
- budget
- equipment
- existing proof
- constraints
- energy/attention
- privacy sensitivity
- goal seriousness
- deadline proximity
- source freshness
- user preference
- risk class
- alternative paths

## 8. Steps are generated, not stored

Source packs may contain starter actions, common milestones, proof options, requirements, constraints, and source claims.

Final scheduled steps must be generated by AOS/LDI/Plan from user context.

Hard rule:

```text
Packs may seed steps.
Packs must not hardcode identical step plans for every user.
```

## 9. Alternative pathing and option value

Serious path overlays must include an `AlternativePathSet` when meaningful.

Example for NFL path:

```text
primary: varsity → college recruitment → college football → draft/free agent
alternatives: coaching, strength and conditioning, sports media, scouting, analytics, management, refereeing, youth coaching
```

Option Value Map must preserve transferable proof:

```text
film study → coaching / scouting / sports media
team leadership → coaching / management
training consistency → strength & conditioning
football IQ → commentary / analytics
```

User-facing language must preserve the Ambitions closure principle:

```text
This still counts.
```

## 10. Composition rules

1. No one-pack-per-goal.
2. Goal-specific objects must be overlays or projection recipes, not duplicate full packs.
3. Highest/pro paths reuse lower-level nodes.
4. Narrow skill goals must slice only relevant capability nodes.
5. Official/current requirements live in overlays.
6. User paths are projections.
7. Same ambition can produce different path instances.
8. Steps are generated from user context.
9. Alternative paths must be present or explicitly absent.
10. Duplicate claims/requirements across packs must be aliases, not copies.

## 11. Required gates

- No One-Pack-Per-Goal Gate
- Composable Pack Graph Gate
- Goal Projection Gate
- Skill Slice Gate
- Highest-Path Reuse Gate
- Personal Path Instance Gate
- Alternative Path / Option Value Gate
- Steps Are Generated, Not Stored Gate
- Source Overlay Gate
- Pack Duplication Gate
- Projection Receipt Gate

## 12. Examples

### Pickleball

Packs:

```text
sports.pickleball.domain
sports.pickleball.rules
sports.pickleball.equipment
sports.pickleball.skills
sports.pickleball.competition-ladder
sports.pickleball.pro-overlay
sports.pickleball.alternative-paths
```

Goal projections:

| Goal | Projection |
|---|---|
| learn pickleball | starter + rules + equipment + beginner ladder |
| improve serve | serve node only |
| improve dink | dink node only |
| play first tournament | beginner/intermediate + competition overlay |
| become pro | full ladder + pro overlay + proof/ranking path |

### Football

Packs:

```text
sports.football.domain
sports.football.rules
sports.football.skills
sports.football.positions
sports.football.school-team-overlay
sports.football.college-recruiting-overlay
sports.football.nfl-overlay
sports.football.alternative-careers
```

Goal projections:

| Goal | Projection |
|---|---|
| make varsity | school overlay + position + tryout + season timing |
| improve catching | catching node + proof drills |
| become quarterback | position overlay + leadership/throwing/film study |
| make NFL | full ladder + college/NFL overlay |
| become commentator | football knowledge + communication/media alternative |

## 13. Integration law

Source Atlas runtime, Pack Factory, AOS, and LDI must inherit this model before pack creation scales.

AOS/LDI may not produce real-world requirement paths from isolated one-off goal packs when a composable projection should be used.

## 14. No-claim boundary

This document does not implement runtime Swift, Source Atlas packs, Universal Source Binder, Pack Factory tooling, Freshness Broker, PDF/OCR, AOS runtime, LDI runtime, or production source-pack coverage. It locks source truth and gates for future implementation.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
