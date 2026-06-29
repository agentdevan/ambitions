# Figma Production Gate Addendum — Zero Ambiguity / Zero Skeleton Policy

Status: Canonical governance addendum for Ambitions Figma, VSP, SwiftUI UI, screenshot, and marketing-render work.

Linear source: https://linear.app/ambitionsos/document/figma-production-gate-addendum-zero-ambiguity-zero-skeleton-policy-4530fd0c785a

Related gate: `VSP North Star Production Quality Gate`

## Scope

This addendum applies to all Ambitions Figma work, VSP-01 through VSP-10, design-system primitives, SwiftUI UI work, Figma operating-model boards, marketing renders, shell authority frames, screenshot proof, and any repair/revision pass.

This addendum extends the existing VSP North Star Production Quality Gate. It exists to remove ambiguity around words like “polished,” “production-grade,” “marketing-ready,” “native,” “clean,” “done,” or “reviewable.”

A Figma artifact is not acceptable because it is organized, attractive, technically labeled, or internally consistent. It is acceptable only if it looks like a final Ambitions app surface or a governed production artifact that directly enables one.

## Non-negotiable standard

Every reviewable VSP hero must look like one of the following:

- a final native SwiftUI app screenshot;
- a production-grade App Store / launch-site hero image;
- a realistic flagship iPhone-first product surface;
- a mature Ambitions-native object built from reusable design-system primitives.

A VSP hero must never look like:

- a wireframe;
- a skeleton;
- a storyboard;
- a generated Figma board;
- a clean but shallow mockup;
- a design exercise;
- a component demo;
- a diagram pretending to be UI;
- a mini-screen collage;
- a generic productivity/dashboard/calendar/task app;
- a surface that needs side notes to be understood.

## Binary artifact labels

Every Figma page/frame must include one of these labels in its name:

- `AUTHORITY`
- `CANDIDATE`
- `EXPLORATION`
- `MARKETING_RENDER`
- `FAILURE_EVIDENCE`
- `ARCHIVE`

No unlabeled frame may be used for review.

A `CANDIDATE` frame is not authority.

A `FAILURE_EVIDENCE` frame must never be used as a source for production work except to avoid repeating the failure.

A `MARKETING_RENDER` frame may include atmospheric/polish details, but anything not SwiftUI-plausible must be tagged as marketing-only.

## Shell contamination gate

Any frame fails immediately if it invents shell chrome.

For VSP-02 through VSP-10, shell treatment is allowed only in two forms:

1. content-only, with no shell/header/dock/crown/search/Capture/status/nav approximation; or
2. mounted inside the exact approved VSP-01 shell authority.

Forbidden unless sourced from exact VSP-01 authority:

- header;
- status bar approximation;
- dock;
- tab bar;
- Context Crown;
- Capture affordance;
- search affordance;
- shell glass;
- shell safe-area treatment;
- nav selection treatment;
- Motion as destination;
- Trust / Proof / Source / Privacy / History / Receipts as persistent root surfaces.

Any invented shell approximation means `Needs Repair`.

## Skeleton detector gate

A frame fails as a skeleton if any of the following are true:

- the screen still reads as layout scaffolding instead of a final app surface;
- the primary object is mostly rectangles, panels, labels, or empty sections;
- visual richness comes from board labels instead of product content;
- the main UI would not make sense without explanatory side copy;
- content density is too sparse to feel like a real app state;
- visual hierarchy relies on placeholder cards instead of Ambitions objects;
- states are listed instead of embodied;
- the design looks like a clean wireframe with premium colors;
- the surface could belong to any productivity app after changing the labels.

Clean skeletons still fail.

## Final-app screenshot gate

Before `Ready For Review`, the main hero must pass this question:

> Could this image be placed on the Ambitions website, App Store page, investor deck, or launch announcement as a final-product screenshot without apology?

If the answer is no, the status remains `Needs Repair`.

A frame is not marketing-ready if it contains:

- review notes;
- spec labels;
- arrows;
- anatomy labels;
- visible grid notes;
- “Review result” copy;
- implementation jargon;
- placeholder data;
- explanatory captions required for comprehension;
- side panels competing with the product object.

Spec/anatomy boards are allowed, but they cannot substitute for the hero render.

## Typography gate

Hard fail if any screenshot or direct Figma inspection shows:

- clipped text;
- invisible text;
- collapsed text;
- cropped line height;
- unreadable small labels;
- labels compressed below useful width;
- text wrapping that damages hierarchy;
- chips where label/value/detail cannot breathe;
- title/subtitle collision;
- text hidden by material/blur/shader;
- mini-screen typography as primary read.

Minimum expectations:

- Primary headline must read at presentation scale.
- Main action/object labels must read without zooming into Figma.
- No primary functional label should rely on tiny annotation text.
- Text boxes must be sized to content with safe headroom.
- Dynamic Type stress must be considered before Visual Green.

If SF Pro or system fonts fail in Figma screenshot export, use a proven renderable fallback for proof while documenting that SwiftUI remains system-font aligned.

## Spatial correctness gate

Hard fail if any visible object has accidental:

- overlap;
- collision;
- cropped bottom edge;
- card/dock collision;
- card/safe-area collision;
- ambiguous layering;
- insufficient tap target;
- timeline/event overlap that is not intentionally designed;
- row text colliding with counters/chevrons;
- object clipped by the device frame;
- primary content hidden below viewport edge.

Minimum tap-target rule:

- Any interactive object represented as tappable must be at least 44 pt equivalent.
- Any primary action must be visually reachable and not crowded by competing elements.
- Bottom seams must reserve safe-area/dock clearance even in content-only renders.

## Native SwiftUI plausibility gate

Every major object must be tagged as one of:

- `Existing SwiftUI primitive`
- `New SwiftUI primitive required`
- `Figma-only exploration`
- `Marketing-only render detail`
- `Rejected / not implementation-plausible`

A frame fails if key meaning depends on:

- impossible shader effects;
- impossible blur/material layering;
- motion without static equivalent;
- non-native UI controls;
- web-app layout behavior;
- arbitrary absolute positioning that cannot survive device/Dynamic Type changes;
- Figma-only art that has no SwiftUI, static asset, Metal/Core Image, or marketing-only classification.

Unknown implementation provenance means `Needs Repair`.

## Material discipline gate

Ambitions material must be restrained, layered, and semantic.

Allowed material purposes:

- hierarchy;
- depth;
- state;
- privacy/trust;
- protected time;
- proof/receipt availability;
- source freshness;
- capacity pressure;
- changed-object emphasis;
- recovery softness.

Forbidden material failures:

- generic glass blobs;
- fantasy glow;
- sci-fi dashboard glow;
- decorative constellation noise;
- blue/purple generic AI sparkle;
- material that reduces readability;
- shader carrying required meaning without fallback;
- excessive blur hiding structure;
- glow used as active-state crutch.

Every shader/effect/motion must be tagged:

- `SwiftUI-native`
- `Metal/Core Image plausible`
- `Static asset plausible`
- `Marketing-only`
- `Rejected`

## Ambitions object gate

A VSP hero must be built around Ambitions-native objects, not generic UI.

Required object truth:

- Today uses Reality Meridian / Today Step / Recovery / Proof-after-action logic.
- Goals uses Direction Field / Life Area Row / completed-total relationship.
- Time uses LifeShape Field / Protected Time / Fixed Commitment / Open Window / Reflow Trace.
- Shell uses approved VSP-01 authority only.
- Inspection surfaces remain details, not root surfaces.

A VSP fails if it can be described accurately as:

- dashboard;
- task list;
- habit tracker;
- calendar clone;
- project board;
- chat UI;
- analytics panel;
- generic AI assistant screen;
- productivity card feed.

## Product-law gate

Hard fail if any frame violates:

- Today / Goals / Time / You are the only persistent surfaces.
- Capture is global composer, not a tab.
- Motion is behavior, not a destination.
- Proof / Source / Privacy / History / Receipts are inspection details.
- Offline core value remains usable without account sign-in.
- Source Atlas / R2 does not store the private life graph.

No visual polish can override product law.

## Figma feature gate

Figma features are tools, not permission to bypass production quality.

- Code Layers may be used only for design-code parity and SwiftUI plausibility.
- Figma Motion may be used only with a Reduce Motion equivalent.
- Shaders may be used only if readability and fallback are preserved.
- Weave/generative tools may be used for exploration or marketing polish, but output must be rebuilt into governed Ambitions primitives before becoming a candidate.
- Agent skills/plugins may assist, but cannot mark a frame Green without screenshot proof and owner approval.

## Screenshot proof gate

No screenshot proof, no review.

Each reviewable VSP must include persistent proof, not only a temporary local path.

Required proof:

1. canonical Figma frame link;
2. exported hero screenshot;
3. cropped viewport screenshot;
4. presentation-scale screenshot;
5. direct visual review note;
6. proof attached to Linear or saved in a durable project proof location.

Temporary `/tmp/...` paths are useful during Codex execution, but are not sufficient as durable proof unless the image is also attached or persisted.

A closeout that says “rendered screenshot proof” without durable proof is incomplete.

## Dynamic Type / accessibility gate

Before Visual Green, each VSP must have at least:

- standard text size frame;
- large text stress frame;
- accessibility-size stress frame or documented blocker;
- Reduce Motion equivalent;
- Reduce Transparency equivalent when materials matter;
- Increase Contrast check;
- VoiceOver reading-order notes for primary objects.

A beautiful hero without accessibility stress remains Yellow at best.

## Marketing board gate

A VSP marketing board must contain:

- one full hero screenshot;
- one close-up crop;
- one supporting state screenshot;
- one short production caption.

It must not contain:

- implementation notes;
- arrows;
- callout clutter;
- spec labels;
- proof tables;
- Linear status text;
- “Needs Repair” labels;
- wireframe annotations.

Marketing boards are not substitutes for implementation anatomy.

## Failure evidence gate

Any failed frame must be renamed immediately:

`FAILURE_EVIDENCE — [VSP] — [reason] — [date/pass]`

Examples:

- `FAILURE_EVIDENCE — VSP-04 — invented shell chrome — R2`
- `FAILURE_EVIDENCE — VSP-02 — typography collision — R1`
- `FAILURE_EVIDENCE — VSP-03 — skeleton list density — R3`

Failed frames must not remain with candidate-like names.

## Status gate

### Needs Repair

Use when:

- visual quality is below final-app grade;
- artifact is skeleton-like;
- proof missing or temporary only;
- owner has not seen a major repaired visual pass;
- typography/spatial/material/product-law defect exists;
- shell authority is ambiguous;
- VSP definition is missing or contradictory;
- candidate relies on side notes;
- screenshot export failed or was not reviewed.

### Ready For Review

Use only when:

- screenshot proof exists and is durable;
- primary hero clears all hard-fail checks;
- shell authority is preserved;
- artifact looks final-app/marketing-grade;
- owner review is the only remaining blocker.

### Accepted Yellow

Use only when:

- owner explicitly accepts a known risk;
- risk is documented;
- linked follow-up exists;
- it is never reported as Green.

### Done

Use only when:

- owner approves;
- Visual Green is explicitly granted;
- production handoff addendum exists;
- proof is durable;
- non-claims are recorded;
- no unresolved quality failure remains.

## Owner approval gate

No agent, Codex run, Figma plugin, screenshot, or self-review can mark Visual Green.

Owner approval is required.

Owner approval must reference:

- canonical frame ID;
- screenshot proof;
- accepted risk, if any;
- whether the approval is Green or Yellow.

## Closeout gate

Every Figma work closeout must include:

Status: Green / Yellow / Red  
Scope completed:  
Files / Figma frames changed:  
Frame labels:  
Approved shell authority preserved:  
Design-system primitives used:  
Screenshot proof:  
Durable proof location:  
Typography audit:  
Spatial audit:  
Product-law audit:  
Accessibility / Dynamic Type audit:  
SwiftUI plausibility audit:  
Figma-only / marketing-only effects:  
Failures found:  
Repairs made:  
Remaining risks:  
Follow-up required:  
Non-claims:  
Rollback plan:

A closeout missing any required section is incomplete.

## Zero-shortcut rule

The following phrases are not sufficient evidence:

- “looks good”;
- “polished”;
- “premium”;
- “clean”;
- “native-feeling”;
- “reviewed”;
- “screenshot proof rendered”;
- “no obvious issues”;
- “marketing-grade”;
- “SwiftUI plausible.”

Every claim must be supported by a frame ID, screenshot proof, audit note, or explicit owner approval.

## Final operating rule

Quality beats completion count.

One world-class VSP is better than ten weak boards.

If the process starts producing skeletons, stop. Leave unfinished VSPs in `Needs Repair`. Do not fill the board for completion optics.
