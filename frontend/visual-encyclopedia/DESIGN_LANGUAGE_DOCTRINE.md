# Design Language Doctrine

Status: Active frontend design-language doctrine
Authority: subordinate to `docs/truth/*` and the current `frontend/visual-encyclopedia/` root

This doctrine freezes the Ambitions design language so visual implementation stays object-first, native iPhone-first, and aligned with the active truth files.

It does not prove implementation, accessibility conformance, visual completion, or release readiness.

## Purpose

The design language exists to keep the frontend from drifting into a generic productivity shell. Ambitions is a personal life operating system with a small number of dominant objects, a calm shell, inspectable proof, and recovery-aware language.

## Locked Rules

### 1. One-Primary-Object Law

Every surface must have one primary object.

- The primary object owns attention, structure, and the first decision.
- Supporting objects may clarify source, proof, state, or recovery, but they must not compete with the primary object.
- If a screen can be mistaken for a dashboard, card stack, or list-first productivity app, the design has drifted.

### 2. Five Signature Instruments

The mature frontend is organized around five active instruments:

- Today -> Reality Meridian
- Goals -> Constellation Atlas
- Capture -> Atmosphere Composer
- Time -> LifeShape Field
- You -> User System Profile

These instruments define the active design language. A surface that does not clearly belong to one of them needs review before implementation.

### 3. Native iPhone Rules

Ambitions should feel like a premium native iPhone app, not a web dashboard in disguise.

- Prefer quiet luxury over spectacle.
- Prefer one-handable primary actions.
- Prefer durable object depth over decorative chrome.
- Prefer local-first behavior and inspectable state over cloud theater.
- Preserve Dynamic Type, Reduce Motion, contrast, and clear VoiceOver structure.
- Keep the shell calm; reserve intensity for moments that actually need it.

### 4. Material Usage Is Semantic Only

Materials are not decoration.

- `QuietGlass` is for calm separation.
- `GraphiteRecess` is for grounded containment.
- `LuminousTrace` is for source, proof, or state attachment.
- `CelestialField` is for orientation, atmosphere, or contextual depth.

Use materials only when they communicate meaning that the object needs. Do not use blur, glow, translucency, or atmospheric treatment as cosmetic filler.

### 5. Proof and Receipt Language

Ambitions must speak in inspectable terms.

- Use `source`, `proof`, and `receipt` when the UI is explaining why something exists or what changed.
- Attach proof language to the object that changed or was inspected.
- A receipt is a closure artifact, not a generic confirmation toast.
- Do not use model-confidence language, AI theater, or vague explanation prose as a substitute for proof.

### 6. Calm Recovery Tone

Recovery is a first-class state, not a failure state.

- Use non-shaming language.
- Prefer `needs recovery`, `still counts`, `blocked`, `waiting`, `stale source`, or `not needed` where appropriate.
- Avoid panic, guilt, streak pressure, and punitive urgency.
- When something changes, the UI should show the next safe step instead of moralizing the miss.

### 7. Banned Counter-Patterns

These patterns are not part of the active design language:

- generic dashboard grids
- stacked card shells as the top-level structure
- calendar-clone root layouts
- chatbot or assistant-first UI
- score, streak, or badge-driven motivation
- fake AI confidence or AI explanation labels
- noisy neon spectacle
- hidden source/proof state
- shame-based recovery copy
- task-list surfaces that could ship unchanged in any productivity app

## Relationship To Other Docs

- `docs/truth/PRODUCT_DESIGN_TRUTH.md` sets the product and interaction authority.
- `SIGNATURE_VISUAL_INSTRUMENTS.md` defines the five instrument families in more detail.
- `CHROME_ENRICHMENT_DOCTRINE.md` defines shell and chrome behavior.
- `START_HERE_REALITY_RECOGNITION_DOCTRINE.md` governs Today state language and Start Here semantics.

If this doctrine conflicts with `docs/truth/*`, the truth files win.
