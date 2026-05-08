# 07 — Native Shell / Tokens / Materials

Status: locked structure. Semantic tokens are locked. Exact numeric values are candidate until visual QA validates Today, Capture, and You.

Purpose:

- native iPhone contract
- shell rules
- navigation/sheet/keyboard rules
- semantic tokens
- candidate foundation token values
- materials
- trace/glow limits
- material redlines

Locked materials:

1. Celestial Field
2. Graphite Recess
3. Luminous Trace
4. Quiet Glass

Semantic token names are locked. Exact numeric values remain candidate until visual QA.

This document does not implement app behavior.

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

---

## 2. Native iPhone Thesis

Ambitions may be visually proprietary inside Signature Objects, materials, traces, and continuity behavior.

It may not be experimental at the shell, navigation, safe-area, keyboard, sheet, hit-target, or system-behavior level.

The shell should feel familiar. The invention belongs inside Ambitions-specific objects and the Continuity Layer.

---

## 3. Native Shell Non-Negotiables

1. Top-level navigation is five-tab bottom navigation only.
2. The tabs are Today, Goals, Capture, Time, You.
3. The bottom tab system is the Continuity Dock.
4. Basic navigation must be immediately understandable.
5. All primary controls are obvious, tappable, and thumb-zone aware.
6. Keyboard behavior must feel native.
7. Sheets, pushes, and detents preserve orientation.
8. Safe areas are respected at top, bottom, and home indicator.
9. Dynamic Type, Reduce Motion, Increase Contrast, and Differentiate Without Color are product requirements.
10. Invention may not hide navigation or primary action.

Hard Red:

- Mission Control top-level
- hidden experimental navigation
- non-native keyboard behavior
- web/SaaS/admin shell
- status-feed chrome
- assistant tab/chrome

---

## 4. AmbitionsShell Contract

AmbitionsShell owns:

- root background material
- safe-area treatment
- Context Crown placement
- Continuity Dock placement
- per-tab top-level composition slot
- global continuity signal routing
- status bar contrast
- one-handed reach constraints

AmbitionsShell does not own:

- feature-specific business logic
- arbitrary badges
- generic banners
- assistant chrome
- notification feeds
- decorative overlays

---

## 5. Navigation Contract

Only these tabs may exist:

- Today
- Goals
- Capture
- Time
- You

Forbidden top-level destinations:

- Mission Control
- Dashboard
- Assistant
- Calendar
- Inbox
- Settings replacing You as label

Allowed depth:

- push for durable detail
- sheet/detent for focused adjustment
- inline expansion for object-local detail
- Trust Seam for explanation/receipt
- Quiet Reflow for plan adjustment choices

Forbidden depth:

- mystery gesture-only depth
- full-screen modals from nowhere
- desktop sidebars
- nested dashboards
- buried recovery paths

---

## 6. Sheet / Detent Contract

Use sheets for:

- adjust plan
- review pressure
- edit automation setting
- inspect receipt history
- place capture
- choose blocked/waiting/still counts

Rules:

- origin must be clear
- cancellation is safe
- destructive changes require confirmation or undo
- large content supports scrolling
- detents feel native
- meaningful change leaves receipt

Hard Red:

- modal automation without receipt
- sheet stack buries recovery
- concept panel with unclear close behavior

---

## 7. Keyboard Contract

Capture is the strictest keyboard surface.

Atmosphere Composer behavior:

- composer remains bottom-oriented
- keyboard rise is native
- field stays visible
- mic remains inside composer context
- atmosphere compresses calmly
- route reveal appears only after input/capture

Hard Red:

- keyboard covers primary input
- composer jumps unpredictably
- Capture becomes notes feed/inbox/chat/category board
- plus is top-level Capture tab icon

---

## 8. Hit Target Contract

Minimum:

- 44 x 44 pt for all tappable controls
- 48 x 48 pt preferred for primary actions
- small proof marks open through larger accessible target
- tappable traces/nodes use invisible hit expansion

Hard Red:

- tiny constellation nodes require precision tapping
- receipt marks cannot be reliably opened
- Dock markers become separate tiny targets

---

## 9. Token Philosophy

Ambitions uses a hybrid token canon:

- exact values for candidate foundation tokens
- semantic aliases for product use
- bounded ranges for expressive atmospheric tokens
- hard redlines for glow, blur, trace, and tint

Semantic token names are locked. Exact visual values remain candidates until visual QA validates Today, Capture, and You.

Feature code must use semantic tokens, not raw values.

---

## 10. Candidate Foundation Color Tokens

These values are candidate until visual QA locks them.

| Token | Candidate value | Purpose |
| --- | ---: | --- |
| Graphite.980 | #050609 | deepest base |
| Graphite.950 | #07080B | app black |
| Graphite.900 | #0B0D12 | Celestial Field base |
| Graphite.850 | #10131A | recessed field |
| Graphite.800 | #151923 | raised/recess contrast |
| Graphite.700 | #232936 | hairline / seam |
| Mist.100 | #F1F5FB | primary text |
| Mist.300 | #C9D1DD | strong secondary text |
| Mist.500 | #9BA4B3 | metadata text |
| Mist.700 | #697382 | quiet labels |
| Blue.200 | #D8E5FF | luminous highlight |
| Blue.300 | #BFD4FF | trace highlight |
| Blue.400 | #9DBDFF | Ambitions Blue |
| Cyan.300 | #9DDAE8 | Still Counts / recovery |
| Amber.300 | #D8A85F | pressure |
| Slate.300 | #8FA4BE | protected |
| Rose.300 | #C996A7 | relationships accent |
| Green.300 | #8FB99B | health / fitness accent |
| Violet.300 | #A9A0E8 | creative / music accent |
| Gold.300 | #C9A768 | money accent |

---

## 11. Locked Semantic Color Tokens

| Semantic token | Candidate mapping | Use |
| --- | --- | --- |
| Surface.celestialField | Graphite.900 | main atmospheric background |
| Surface.celestialFieldDeep | Graphite.950 | depth / edges |
| Surface.graphiteRecess | Graphite.850 | embedded panels |
| Surface.quietGlass | Graphite.800 with material opacity | controls |
| Stroke.hairline | Graphite.700 | dividers / seams |
| Text.primary | Mist.100 | primary readable text |
| Text.secondary | Mist.300 | secondary content |
| Text.tertiary | Mist.500 | metadata |
| Text.quiet | Mist.700 | low-priority labels |
| Accent.primary | Blue.400 | selected / primary action |
| Trace.active | Blue.300 | active traces |
| Trace.receipt | Blue.200 | proof marks |
| State.pressure | Amber.300 | pressure |
| State.protected | Slate.300 | protected time |
| State.stillCounts | Cyan.300 | closure / recovery |
| State.waiting | Mist.700 | waiting |
| State.blocked | Amber.300 muted | blocked |
| State.relationships | Rose.300 | relationships |
| State.healthFitness | Green.300 | health / fitness |
| State.creativeMusic | Violet.300 | creative / music |
| State.money | Gold.300 | money |

---

## 12. Typography Tokens

Ambitions uses two typographic voices:

- Native Sans for control and operation
- Editorial Serif for sparse meaning moments

Native Sans scale:

| Token | Size | Weight | Use |
| --- | ---: | --- | --- |
| Type.crown | 15 | semibold | Context Crown identity |
| Type.body | 17 | regular | default iOS body |
| Type.bodyStrong | 17 | semibold | row titles / primary labels |
| Type.caption | 13 | regular | metadata |
| Type.captionStrong | 13 | semibold | state labels |
| Type.control | 15 | semibold | buttons / pills |
| Type.largeTitle | 28–34 | semibold | sparse native titles only |

Editorial Serif scale:

| Token | Size | Weight | Use |
| --- | ---: | --- | --- |
| Type.meaningTitle | 30–38 | regular/medium | Capture hero, selected goal, Time meaning title |
| Type.meaningPhrase | 22–28 | regular | reflective moments |

Rules:

- Sans is for control.
- Serif is for meaning.
- Operational UI must not use serif.
- Serif must never reduce clarity.

---

## 13. Spacing Tokens

| Token | Value |
| --- | ---: |
| Spacing.2 | 2 pt |
| Spacing.4 | 4 pt |
| Spacing.6 | 6 pt |
| Spacing.8 | 8 pt |
| Spacing.12 | 12 pt |
| Spacing.16 | 16 pt |
| Spacing.20 | 20 pt |
| Spacing.24 | 24 pt |
| Spacing.32 | 32 pt |
| Spacing.44 | 44 pt |
| Spacing.screenEdge | 20 pt |
| Spacing.objectGap | 16 pt |
| Spacing.groupGap | 12 pt |
| Spacing.controlGap | 8 pt |

---

## 14. Radius Tokens

| Token | Value | Use |
| --- | ---: | --- |
| Radius.small | 10 pt | small controls |
| Radius.control | 14 pt | buttons / fields |
| Radius.recess | 20 pt | Graphite Recess groups |
| Radius.object | 28 pt | Signature Object surfaces |
| Radius.sheet | 32 pt | large sheets |
| Radius.full | 999 pt | pills / round nodes |

---

## 15. Trace Tokens

| Token | Value / Range | Use |
| --- | ---: | --- |
| Trace.hairline | 1 pt | quiet line |
| Trace.standard | 1.5 pt | primary trace |
| Trace.active | 2 pt | active trace |
| Trace.max | 2.5 pt | never exceed |
| Trace.nodeSmall | 5 pt | small proof/node |
| Trace.nodeStandard | 7 pt | standard node |
| Trace.nodeActive | 9 pt | active node |
| Trace.glowOpacity | 8–22% | bounded glow |
| Trace.glowBlur | 6–18 pt | bounded glow blur |

Hard Red:

- neon trace
- decorative trace
- trace thicker than 2.5 pt
- glow competing with text
- color-only state

---

## 16. Material System

Ambitions uses four primary materials:

1. Celestial Field
2. Graphite Recess
3. Luminous Trace
4. Quiet Glass

Every material must do product work.

### Celestial Field

Purpose: atmospheric operating surface, quiet orientation, depth, and life-scale mood.

Allowed ranges:

- base: Graphite.900–Graphite.950
- grain opacity: 2–7%
- star density: sparse only
- horizon glow opacity: 4–14%
- blur: static or extremely restrained

Allowed uses:

- root backgrounds
- open fields
- Capture atmosphere
- Goals/Time/Today atmosphere

Forbidden:

- wallpaper
- galaxy art
- fantasy space
- astrology patterns
- particles competing with UI
- decorative stars with no product work

### Graphite Recess

Purpose: embedded product surface, settings groups, receipt seams, Start Here regions, contextual drawers.

Candidate recipe:

- base: Graphite.850
- edge stroke: Graphite.700 at 35–60%
- inner shadow: subtle only
- radius: Radius.recess or Radius.object

Forbidden:

- stacked cards
- floating SaaS panels
- dashboard tiles
- generic card architecture

### Luminous Trace

Purpose: continuity, state, relationship, proof, active nodes, goal threads, Meridian Edge, Trust Seam markers.

Allowed:

- Reality Meridian
- constellations
- LifeShape curves
- selected nodes
- proof marks
- Cross-Object Threads

Forbidden:

- decorative line art
- neon HUD
- random separators
- unmeaningful glow
- color-only state

### Quiet Glass

Purpose: touch control material and restrained interactive chrome.

Allowed:

- composer field
- CTA pills
- segmented control
- compact utility buttons
- selected controls
- Trust Seam controls
- Context Crown states

Candidate recipe:

- base: Graphite.800 with material translucency
- stroke: Mist.500 at 8–18%
- active highlight: Blue.300 at 4–10%
- blur: bounded by platform material performance

Forbidden:

- generic glassmorphism
- shiny cards
- full-screen glass panels
- decorative glass surfaces

---

## 17. Ambient State Tint Rules

Tint may touch only:

- active dock icon
- trace nodes
- selected object point
- small proof marks
- CTA edge
- Context Crown micro-state
- Trust Seam marker

Per-tab direction:

| Tab | Tint direction |
| --- | --- |
| Today | dawn blue-white / warm current trace |
| Goals | cool constellation blue |
| Capture | violet-blue open sky |
| Time | amber-cyan pressure/capacity |
| You | graphite amber / system trust |

Hard Red:

- full-screen recolor
- dashboard color coding
- color-only state
- bright category palette dominance

---

## 18. Token / Material Enforcement Gate

Hard Red failures:

- raw hex in feature surface code
- unapproved glow
- unapproved material
- color-only state
- more than one primary accent competing on a surface
- decorative celestial element with no product meaning
- token invented in a feature folder
- generic Card component becomes primary structure
- ad hoc glass modifier appears outside material layer

## 18A. AFI04 Material Proof Matrix

AFI04 locks the material proof rules for active AFI work. It does not lock final
numeric token values and does not claim the current app has rendered these
materials correctly.

| Material | Product job | Pass evidence | Yellow until | Hard Red |
| --- | --- | --- | --- | --- |
| Celestial Field | orientation, atmosphere, life-scale calm | screenshot/preview shows sparse depth supporting the primary object | rendered proof exists for each affected top-level surface | wallpaper, galaxy art, decorative stars, sci-fi HUD, or atmosphere competing with controls |
| Graphite Recess | embedded seams, grouped settings, receipts, contextual drawers | screenshot/preview shows embedded depth without card-pile dominance | grouped surfaces and receipts are rendered and reviewed | floating SaaS panels, dashboard tiles, generic card architecture |
| Luminous Trace | continuity, current state, relationships, proof | screenshot/preview shows trace meaning with non-color equivalent | accessibility equivalent and rendered state proof exist | neon line art, color-only state, glow competing with text, random separators |
| Quiet Glass | restrained controls, composer field, compact utility chrome | screenshot/preview shows native-feeling controls with readable contrast | performance/accessibility review confirms blur/tint does not harm use | generic glassmorphism, shiny cards, full-screen glass panels, decorative glass |

AFI04 acceptance rules:

- Semantic token names and material purposes are locked.
- Candidate values remain candidate until visual QA validates screenshots or
  previews.
- No final-token, material-complete, or visual-Green claim is allowed without
  rendered proof.
- Feature code must use approved semantic tokens/material layers; raw values in
  feature surfaces remain a material-gate Red unless an owning migration report
  explicitly parks the compatibility risk.

---

## 19. Native Believability Gate

A screen passes only if all are true:

1. User knows where they are within two seconds.
2. User knows the primary object within two seconds.
3. User sees one obvious next action when action is expected.
4. Navigation feels familiar.
5. Keyboard, sheets, and pushes behave predictably.
6. Primary controls meet hit target rules.
7. Dynamic Type does not break the primary task.
8. Reduced Motion preserves meaning.
9. The screen does not resemble SaaS, dashboard, task manager, calendar clone, notes app, chatbot, or concept art.
10. Invention is inside Ambitions-specific objects, not basic navigation.

---

## 20. Validation Remaining

Exact token values, Ambient State Tint values, material screenshots, keyboard behavior, safe-area behavior, and final material recipes remain validation tasks until visual QA and implementation proof exist.
