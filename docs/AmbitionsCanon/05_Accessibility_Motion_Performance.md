# 05 — Accessibility / Motion / Performance

Status: locked direction, pre-device validation, docs-only.

Purpose:

- object-level nonvisual requirements
- VoiceOver summaries
- Dynamic Type
- Reduce Motion
- Increase Contrast
- Differentiate Without Color
- touch targets
- motion rules
- haptics
- performance budget

This document does not implement app behavior or prove accessibility/performance in code.

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

## 2. Accessibility Thesis

No Ambitions Signature Object is complete until it works nonvisually.

Celestial visuals, traces, tint, glow, constellation geometry, edge state, and motion may enrich the product. They may not be required to understand or operate it.

Accessibility is product architecture, not compliance polish.

---

## 3. Accessibility Hard Rules

1. No celestial visual may be required to understand meaning.
2. No trace, glow, tint, constellation, or edge may be the only indicator of state.
3. Every primary object needs a VoiceOver summary.
4. Every adaptive recommendation needs source and control.
5. Every closure/recovery state must be accessible.
6. Reduce Motion preserves meaning.
7. Increase Contrast preserves boundaries.
8. Differentiate Without Color preserves state meaning.
9. Minimum tap target is 44 x 44 pt.
10. Dynamic Type must preserve primary task completion.
11. Trust, receipt, and recovery paths must remain discoverable.
12. Small proof marks, nodes, and traces need expanded accessible targets if interactive.

---

## 4. Object-Level Nonvisual Requirements

| Object | Required nonvisual behavior |
| --- | --- |
| Reality Meridian | Now, Next, Later, active step, open capacity, closure states, receipts |
| Start Here Surface | recommendation, source, primary action, alternatives, receipt handoff |
| Constellation Atlas | ordered life areas, pinned/hidden/selected states, goal threads |
| Orbital Lens | selected area, active threads, Today connection, source path |
| Atmosphere Composer | input purpose, mic/add actions, route result, uncertainty |
| LifeShape Field | horizon, open time, goal time, protected time, pressure, shaping actions |
| User System Profile | grouped settings, automation level, privacy/source controls |
| Continuity Dock | tab, selected state, calm marker summary |
| Context Crown | current tab/depth and one context phrase |
| Meridian Edge | hidden unless actionable; meaning repeated elsewhere |
| Trust Seam | Closed/Peek/Open/Route state, source, controls |
| Quiet Reflow | mismatch, options, preview effect, confirmation, receipt |
| Receipt Surface | action taken, source, undo/revert, archive route |
| Cross-Object Threads | text relationship between source and destination objects |

---

## 5. VoiceOver Summary Examples

Today / Reality Meridian:

```text
Today. Now has 30 minutes open. Recommended step: Draft proposal outline, 25 minutes, connected to Career. Next: meeting at 2:00. Later: one protected block remains. One receipt available.
```

Start Here:

```text
Start Here. Recommended step: Draft proposal outline, 25 minutes. Source: Career goal and 30 minutes open now. Button: Start now. More information available: Why this?
```

Capture:

```text
Capture anything. Text field. Add a thought, task, plan, or idea. Button: dictate. Button: add.
```

After low-confidence capture:

```text
Captured. Needs a Place. You can place it later, grow it into a goal, or review suggested routes.
```

Plan:

```text
Plan. This week. 6 hours open, 3 hours goal time, 2 protected blocks. Pressure is highest Friday afternoon. Button: Review pressure. Button: Shape week.
```

Goals:

```text
Goals. Life areas. Music, pinned. Fitness. Money. Relationships. Career. Health. Learning. Home. Creative. Personal Growth. Music has one active goal thread feeding Today.
```

You:

```text
You. Planning Setup. Schedule & Availability. Planning Defaults. Vacation / Away Time. Automation & Trust. Current automation level: Preview Reflow.
```

---

## 6. Dynamic Type Contract

Dynamic Type must preserve:

- primary object identity
- primary action
- source/trust path
- recovery path
- tab identity
- readable labels
- touch target size

Rules:

- text wraps before shrinking below readability
- atmosphere/decorative density reduces before critical content truncates
- secondary metadata collapses before primary actions
- You follows native grouped settings behavior at large sizes
- Capture composer remains visible with keyboard and large text
- Today retains Now / Next / Later semantics even if visual density reduces

Hard Red:

- primary CTA clipped or hidden
- Trust Seam unreachable
- receipt/proof path inaccessible
- visual object preserved while text becomes unusable

---

## 7. Reduce Motion Contract

Reduce Motion may remove expressive movement. It may not remove meaning.

| Standard behavior | Reduce Motion equivalent |
| --- | --- |
| trace draw | instant line + fade or static relationship |
| active node breathing | static active marker + label |
| object-origin expansion | native push/sheet or fade |
| LifeShape morph | before/after summary |
| receipt seam open | disclosure expansion |
| ambient tint shift | immediate state update |
| route trace after capture | static route reveal |
| constellation focus transition | static selected state / native push |

Hard Red:

- motion is the only relationship cue
- reduced-motion mode makes object state unclear
- reflow preview loses before/after meaning
- active state is pulse-only

---

## 8. Increase Contrast Contract

Increase Contrast must preserve:

- text readability
- material boundaries
- active state
- selected state
- Trust Seam edges
- receipt/proof affordances
- pressure/protected distinction

Rules:

- Graphite Recess boundary strength may increase
- Quiet Glass strokes may increase
- Luminous Trace glow may reduce while line contrast increases
- Celestial Field atmosphere must recede before readability suffers

Hard Red:

- low-contrast graphite-on-graphite controls
- proof marks vanish
- pressure/protected states collapse into color-only distinctions

---

## 9. Differentiate Without Color Contract

Every color-coded state requires at least one additional channel:

- label
- icon/shape
- position
- line style
- VoiceOver state
- Trust Seam explanation

Examples:

| State | Non-color support |
| --- | --- |
| Pressure | label + field shape + VoiceOver pressure summary |
| Protected | protected label + block boundary + source explanation |
| Still Counts | closure label + receipt |
| Waiting | text state + muted boundary |
| Blocked | text state + boundary icon/shape |
| Active Now | selected/current semantics + label |

Hard Red:

- pressure only amber
- active node only glow
- receipt only pale dot
- selected life area only color

---

## 10. Touch Target Contract

Minimum:

- 44 x 44 pt for all controls
- 48 x 48 pt preferred for primary actions
- tappable nodes use invisible hit expansion
- proof marks open through a larger target
- Dock markers are not separate tiny tap targets

Hard Red:

- constellation nodes require precision tapping
- trace endpoints are tiny controls
- receipt marks cannot be reliably opened
- composer mic/add controls below minimum size

---

## 11. Cognitive Load Contract

Ambitions must feel calm because it is structured, not because it hides necessary control.

Rules:

- one primary object per top-level surface
- one primary action when action is expected
- max one visible secondary action by default in Start Here
- Trust Seam handles explanation depth
- Continuity signals are budgeted and suppressed
- Capture remains quiet until input exists

Hard Red:

- dashboard density
- competing CTAs
- many simultaneous signals
- copy overexplains adaptive behavior inline

---

## 12. Motion Thesis

Motion makes Ambitions feel alive through real state awareness, not animation spectacle.

Motion must clarify:

- object origin
- state change
- relationship
- receipt/proof
- reflow preview
- capture/composer focus

Motion must not be ornamental.

---

## 13. Allowed Motion Families

Allowed:

- active-node breathing only for genuinely live state
- subtle line draw for new relationship
- object-origin expansion
- Trust Seam opening
- LifeShape morph
- Capture composer rise
- Quiet Reflow preview
- Ambient State Tint shift

Forbidden:

- bounce
- excessive pulse
- dramatic zoom
- neon scan
- particle celebration
- parallax gimmick
- animation without product meaning
- chatbot typing animation

---

## 14. Motion Timing Tokens

| Motion | Timing |
| --- | ---: |
| Micro confirmation | 120–180ms |
| Control response | 180–240ms |
| Object expansion | 280–420ms |
| Receipt seam open | 260–360ms |
| Reflow preview | 420–650ms |
| Ambient tint shift | 600–900ms |

Rules:

- no more than one expressive motion per interaction
- no continuous animation unless state is genuinely live
- no motion longer than needed to clarify state
- native sheet/push timings should feel platform-aligned

---

## 15. Haptics Contract

| Event | Haptic posture |
| --- | --- |
| Start now | soft commit |
| Receipt recorded | light confirmation |
| Reflow accepted | medium-soft confirmation |
| Blocked / Waiting selected | soft boundary |
| Dock tab change | minimal selection |

Forbidden:

- gimmicky haptic texture
- repeated haptic feedback
- haptics as sole confirmation
- haptics for decorative celestial motion

---

## 16. Performance Thesis

Performance is part of taste.

Ambitions uses atmosphere, traces, blur, glow, and motion. These must feel premium and native, not heavy or theatrical.

Native responsiveness beats visual richness.

---

## 17. Rendering Budget

Rules:

- max one expressive glow system per top-level surface
- avoid nested translucent glass surfaces
- avoid animated background particles
- star/grain layer should be static or near-static
- trace animation localized to affected object
- Trust Seam and Dock remain lightweight
- LifeShape morph affects only the field, not the whole shell
- Capture atmosphere compresses without full-screen redraw theatrics

Hard Red:

- atmosphere causes sluggish tab switching
- blur/glow makes scrolling unstable
- continuous animation exists without live state meaning
- visual effect obscures text contrast

---

## 18. Interaction Responsiveness Targets

| Interaction | Target posture |
| --- | --- |
| Tab switch | immediate/native |
| Primary button press | instant perceived response |
| Trust Seam open | smooth, bounded |
| Sheet/detent open | native-feeling |
| Capture keyboard rise | native keyboard performance |
| Reflow preview | no visible stutter |
| Scroll | stable and readable |
| Dock state update | subtle, immediate |

---

## 19. Degradation Order

When performance is constrained, reduce in this order:

1. ambient grain motion
2. background glow strength
3. blur radius
4. trace glow
5. nonessential edge animation
6. object transition flourish
7. background depth layers

Never reduce first:

- text clarity
- primary action visibility
- source labels
- receipt path
- recovery controls
- accessible state labels

---

## 20. Object-Level Accessibility / Motion / Performance Matrix

| Object | Accessibility must prove | Motion must prove | Performance risk |
| --- | --- | --- | --- |
| Reality Meridian | Now/Next/Later nonvisual summary | active node and Start Here origin | trace/glow overload |
| Start Here | source/action alternatives | emergence from active node | dense card-like rendering |
| Atmosphere Composer | keyboard/mic/input route labels | native composer rise | keyboard stutter from atmosphere |
| LifeShape Field | capacity/pressure summary | reflow and field morph | heavy curves/blur |
| Constellation Atlas | ordered life areas | focus without spectacle | too many animated nodes |
| Orbital Lens | selected thread relation | expansion from selected area | decorative orbit effects |
| User System Profile | grouped settings semantics | native push only | low risk; must stay native |
| Trust Seam | source/control/undo labels | seam disclosure | nested materials |
| Continuity Dock | selected/marker labels | minimal selection | overanimated markers |

---

## 21. Hard Reds

Stop and repair if any are true:

1. A primary object requires visual interpretation.
2. Reduce Motion removes essential meaning.
3. Color is the only state indicator.
4. Dynamic Type hides primary action.
5. VoiceOver cannot complete top-level object flow.
6. Tappable nodes/proof marks are too small.
7. Trust/recovery path is inaccessible.
8. Animation is decorative or sci-fi.
9. Haptics are gimmicky or sole confirmation.
10. Atmosphere harms keyboard or tab performance.
11. Blur/glow compromises readability.
12. Performance fallback removes source, receipt, or recovery meaning.

---

## 22. Validation Remaining

This canon is complete at direction level. Implementation, preview, device, VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, and performance proof remain validation tasks.
