# Layer Ownership Import Matrix

Status: Active SCG review authority  
Scope: Senior-code import and dependency boundaries for Ambitions layers  
Issue: AMB-1284 / SCG-001  

This matrix is a review aid for import direction and ownership. It does not replace `docs/truth/PRODUCT_DESIGN_TRUTH.md`.

## Layer Direction

Allowed dependency direction should generally move from outer presentation layers toward stable domain, design, interaction, rendering, trust, diagnostics, and quality support. Cycles, hidden runtime reach-through, and feature-owned policy are Red unless a scoped architecture decision explicitly approves them.

## Ownership Matrix

| Owner | Owns | May depend on | Must not own |
| --- | --- | --- | --- |
| `App` | Launch, root scene, dependencies, feature flags | `Stage`, `Core`, `DesignSystem` | Product policy, runtime internals, surface-specific behavior |
| `Stage` | Shell, chrome, route, overlays, safe areas, Motion behavior | `Core`, `Projection`, `Interaction`, `DesignSystem`, `Rendering`, `Trust` | Surface domain models, private persistence details |
| `Stage/Motion` | Cross-surface motion state, event, renderer, accessibility, reduction policy | `Core`, `Interaction`, `Rendering`, `DesignSystem` | Root tab, destination, analytics feed, XP/streak behavior |
| `Core` | Domain, clock, runtime, persistence, permissions, privacy boundary | Foundation and approved Apple frameworks | SwiftUI surface anatomy, shell UI, copy policy |
| `Projection` | Lenses, scenes, commands, mutations, receipts, undo | `Core`, `Language`, `Trust` | Persistence storage mechanics, visual shell ownership |
| `Language` | Vocabulary, copy policy, forbidden terms, copy budget | Product truth docs, generated static data where scoped | Runtime mutation or UI layout |
| `Trust` | Proof, Source, Privacy, History, Receipts, explanations | `Core`, `Projection`, `Language`, `DesignSystem` | Root navigation, scoring, dashboard analytics |
| `Interaction` | Gestures, keyboard, haptics, direct manipulation | `Core`, `Stage`, `DesignSystem` | Domain persistence or copy authority |
| `Rendering` | Canvas renderers and semantic mirrors | `Core`, `Projection`, `DesignSystem` | Runtime policy, persistence, user data transport |
| `DesignSystem` | Tokens, accessibility policies, primitives, product object components | Foundation, SwiftUI, approved Apple frameworks | Surface routing, persistence, runtime learning |
| `Surfaces` | Today, Goals, Time, You root surface composition | `Projection`, `DesignSystem`, `Stage`, `Interaction`, `Trust` | Capture, Motion destination, Core persistence |
| `Composer/Capture` | Global Capture composer and routing preview | `Projection`, `Core`, `Language`, `DesignSystem`, `Trust` | Root tab, inbox/feed, chatbot shell |
| `Scenarios` | Scenario catalogs and stress matrices | `Core`, `Projection`, `Surfaces`, `Composer` | Production mutations outside scenario/test context |
| `Diagnostics` | Runtime, stage, render, store diagnostics | `Core`, `Stage`, `Rendering` | User-facing product value or release claims |
| `Quality` | Audits, gates, review harnesses, proof validators | Docs, source tree, scripts, tests | Production app behavior |

## Import Red Flags

Flag these for SCG review:

- production code importing from `Quality`
- `Core` importing from SwiftUI surfaces
- `Surfaces` directly owning persistence write policy
- `DesignSystem` owning route or runtime mutation policy
- `Trust` becoming dashboard analytics
- `Composer/Capture` added to root navigation
- `Stage/Motion` exposed as a root surface
- new `Features/` implementation
- app code importing starter audit scripts or docs

## Review Output

When a boundary violation is found, record:

- actual import/path
- expected owner
- risk severity
- whether current behavior is affected
- migration owner
- minimum proof required to close
