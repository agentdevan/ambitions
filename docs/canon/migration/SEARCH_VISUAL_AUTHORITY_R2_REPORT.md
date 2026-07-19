# Search visual authority R2 owner approval record

Status: exact frozen Search visual authority owner-approved; shadow and
non-authoritative; Gate B Red/pending; approval-record review complete 0/0/0

Prepared: 2026-07-17

Canon commit: `295889c9f76528d398fce8d54b155d3285705f29`

Freeze ID: `SEARCH-AUTHORITY-R2-2026-07-17T110150Z`

Figma file: `Oik7612LSTUHWsNRFoTlTJ`

Candidate page: `215:2`

Additive section: `375:2805`

## Outcome

The eight additive Search R2 states were repaired in place into one shared,
componentized, auto-layout family. Every 393x852 frame now contains the same
six visible reusable component instances, preserves deterministic local
results, and exposes the exact state-owner control. Semantic labels in the
additive family are at least 10pt. No production Swift changed.

The owner approved the exact freeze and eight exact frames as the final Search
visual authority. The mapping remains behaviorally `future_gated` by
`SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001`. This repair does not activate
Ask or Capture handoff, authorize source work, select a task pack, approve the
broader visual-authority corpus, or make Gate B Green.

## Exact owner approval

Recorded at `2026-07-17T11:46:05Z`:

> I approve SEARCH-AUTHORITY-R2-2026-07-17T110150Z and frames 375:2806, 375:2880, 375:2972, 375:3063, 375:3159, 375:3245, 375:3326, and 375:3402 as the final Search visual authority.

This approval is exact and Search-only. It does not change the overall
manifest from `shadow`, does not change Gate B from Red/pending, does not
authorize source work or task-pack selection, and does not change any of the
eight states from `future_gated`.

The frozen design bundle had a terminal independent review verdict of
Critical 0 / Important 0 / Minor 0:

- package: `.superpowers/sdd/review-search-visual-authority-r2-295889c9-working-tree.diff`
- package SHA-256: `8786427a72b6a3cf3d874261ce5c920ef25bfb52bc4ff7c0a76f07adcf9bb80a`
- package bytes: `995426`
- synthetic tree: `ff43e51eb389865f0aa42fcd8788490f113fccc8`
- entries: `24`

The exact owner-approval record was then independently reviewed with Critical
0 / Important 0 / Minor 0:

- package: `.superpowers/sdd/review-search-visual-authority-r2-295889c9-working-tree.diff`
- package SHA-256: `0771b42183a8e57df60dac3ae28047b5d5708eb211fa02f1eead397ea379f926`
- package bytes: `1034935`
- synthetic tree: `b1a3445ba4d6f30682d69d2514e6d06acdc34e2e`
- entries: `24`
- authenticated base: `295889c9f76528d398fce8d54b155d3285705f29`
- package/base authentication: exact SHA-256, size, tree, entry count, and
  base apply check complete
- live Figma metadata verification: read-only exact section and eight-frame
  verification complete

## Shared anatomy

| Component | Figma node | Layout |
| --- | --- | --- |
| Search R2 / Shared / Header | `389:2770` | Vertical |
| Search R2 / Shared / State Banner | `390:2773` | Vertical |
| Search R2 / Shared / Deterministic Results | `390:2777` | Vertical |
| Search R2 / Shared / Evidence Stack | `391:2773` | Vertical |
| Search R2 / Shared / Owner Action | `391:2783` | Horizontal |
| Search R2 / Shared / Contextual Inspector | `391:2785` | Vertical |

Each state frame has six direct visible instances in that order. The Header
reuses the existing magnifier instance. The visible family uses resilient
auto layout and retains one hidden, non-rendering repair-history group per
frame; no legacy or prior additive source nodes were deleted.

## Exact frozen frames

| State | Frame | Visible control | Product-only screenshot SHA-256 |
| --- | --- | --- | --- |
| Ask failed | `375:3063` | `Retry Ask` | `21c120eb0f8de6ebe88ff2693f962655ea16a740b96e1f0fe56325e0abebfe27` |
| Ask interrupted | `375:3159` | `Resume Ask` | `315798e0bbeb093fad695efae14a284f0380e46f5c77b98e7a91af430e4c0ade` |
| Ask recovered | `375:3326` | `Inspect Source` | `472e13f495c1d46f592a3c2f9283296d1c8f39721b89f338ed05beaddcdb87cf` |
| Ask resumed | `375:3245` | `Cancel Ask` | `ab9788a0828f20aa13e95d13ce01aec7d9632c4a383eaa5cde14a8e7d969ed2c` |
| Ask unavailable / offline | `375:2972` | `Inspect Privacy` | `0133d0914a6ee6fd6c5ab11ff8e5b1ad5ced384788b2019dbbedb1ca45d1c549` |
| Capture handoff | `375:3402` | `Open Capture` | `642068d82d43c392fed92a04a4b29902425996beebd88f93c60061950fb23b48` |
| Grounded answer | `375:2806` | `Inspect Source` | `2c30f3974896a685ce5d1c06fcbeaa42268af4b27575c8e1200f2ee67971ed24` |
| Synthesis in progress | `375:2880` | `Cancel Ask` | `c38a95f1c1aa75aeaea0464e0466b6e65faf3cfad64bac5b22bcb455e66430a2` |

Tracked screenshots are under
`docs/qa/evidence/2026-07-17-canon-search-authority-r2/screens/product-only/`.
They were exported once after the complete Figma repair. All eight renders are
393x852 RGBA PNGs. The Figma API exposed no file-version identifier, so the
freeze binds the exact file, page, section, component IDs, frame IDs, capture
time, controls, and screenshot bytes without claiming a Figma file version.

## Content contract retained

- Deterministic results remain visible in progress, offline, failed,
  interrupted, resumed, recovered, grounded, and Capture-handoff states.
- Grounded and recovered states separate retrieved fact, interpretation,
  uncertainty, and proposed Time ownership. Their Time preview states that
  nothing changes until review.
- Offline states preserve local Find, Act, and Inspect and route to Privacy.
- Failed, interrupted, and resumed states retain local sources and do not
  imply that synthesis made a lasting change.
- Capture handoff says wording and context move, remains session-local until
  save, and that Open Capture saves nothing.
- Contextual inspection retains Source, Privacy, History, Proof, and Receipts.
- No visible state uses generic `Cancel` or a generic inspect label as its sole
  owner control.

These statements describe the exact owner-approved Search Figma renders only.
They remain shadow and non-authoritative while Gate B is Red/pending. Native
focus order, VoiceOver output, Dynamic Type behavior, contrast compliance,
device rendering, and runtime behavior remain unproven.

## Figma approval-metadata receipt

Only shared plugin metadata in namespace `ambitions.canon` changed on section
`375:2805` and the eight approved frames. No visible property, shared
component, or protected legacy node changed; no node was created, deleted, or
renamed. Every changed key/value was read back in the write transaction,
producing these canonical metadata digests:

| Node | Shared keys | Readback SHA-256 |
| --- | ---: | --- |
| `375:2805` | 33 | `0d68e5d2cd7df8e0602d8f3e6793f15362f9b79dc2bae0a51c7777d19386e099` |
| `375:2806` | 42 | `20acd59575a2df41bc27d4d6186065e1302b7e3bbe1f81499cb905129dae9572` |
| `375:2880` | 42 | `a628fcfc8c120f98a71f11b886719badd7d1a542ffbf9fd6df9c6cded7929ecc` |
| `375:2972` | 42 | `5d4b14fe4a2788d243fdb2c20a55e08d6f75b74e6737f8ad92327bae1a5c1d76` |
| `375:3063` | 42 | `81ce45d0ead649c55017a2261b9692c46283c7119d59162d3d83b30dfb04655c` |
| `375:3159` | 42 | `115f261ca6e37cb33508a45499f2105a3cc77e8880068ea668b26b9473b831f6` |
| `375:3245` | 42 | `19cb3bb0cc05303181a9c182cb55233bb16b96f63d539820e7137a2714162992` |
| `375:3326` | 42 | `ac29a9ac3793f5d4af5769fd4eb917a566899793b4e25592bc44eb6a9ec59013` |
| `375:3402` | 42 | `80fb955bdece775b3e642e11c2391cbae37cdc6c0cf696cfb9ae214155ad23fe` |

Before and after the metadata write, Figma exported each approved frame as a
contents-only scale-1 PNG. Pure-JavaScript SHA-256 produced the frozen digest
shown above in both passes, with byte lengths `56362`, `52894`, `52496`,
`50924`, `51983`, `52916`, `55954`, and `55773` in approved-frame order.
Thus the metadata write has exact render-byte identity proof for all eight
frames without a Figma file-version claim.

## Protected legacy evidence

The protected legacy Search `288:41`, Trust `288:156`, and Capture `281:1465`
nodes were not mutation targets. Fresh isolated post-repair exports were
byte-identical to pre-write exports:

| Node | Live identity | Live descendants | Pre/post render SHA-256 |
| --- | --- | ---: | --- |
| `288:41` | Search / Results / Dark / v1, 393x852 FRAME | 47 | `365fb42edb5a2b613318a9ee208ae66fb4da150313d642e7b62bcdfb218c0f81` |
| `288:156` | Trust / Receipt Undo / Light / v1, 393x852 FRAME | 32 | `ff94201fe6e379b596a3e16738efcd609e16adf9b204f6be9e899fff1e97538a` |
| `281:1465` | Capture / Compact Composer / Light / v1, 393x852 FRAME | 24 | `8684664e80fc6bbee087e7fa85fe9ade32064f622e757bc903462f38987f198e` |

The durable pre/post images are under the sibling `legacy-integrity/`
evidence directory. A post-write recursive closed-property snapshot also
records FNV-1a fingerprints `e8d9222c`, `bb835d60`, and `dbed5fbd` with
canonical lengths 50357, 33032, and 23213. The earlier pre-write record used a
property list that was not retained, so its recorded fingerprints
`4fb4a231`, `c88da1db`, and `58b443cd` are preserved as history but are not
misrepresented as directly comparable. The supported legacy claim is limited
to byte-identical isolated renders plus stable live identity, dimensions, and
descendant counts; it is not a full hidden-property identity claim.

The post-write fingerprint algorithm is deterministic: recursively visit each
node in child order and serialize these properties in this exact order:
`id`, `type`, `name`, `visible`, `locked`, `x`, `y`, `width`, `height`,
`rotation`, `opacity`, `blendMode`, `constraints`, `layoutMode`,
`primaryAxisSizingMode`, `counterAxisSizingMode`, `itemSpacing`, `paddingTop`,
`paddingRight`, `paddingBottom`, `paddingLeft`, `layoutAlign`, `layoutGrow`,
`layoutPositioning`, `minWidth`, `maxWidth`, `minHeight`, `maxHeight`,
`clipsContent`, `fills`, `strokes`, `strokeWeight`, `strokeAlign`,
`dashPattern`, `strokeCap`, `strokeJoin`, `cornerRadius`, `topLeftRadius`,
`topRightRadius`, `bottomRightRadius`, `bottomLeftRadius`, `cornerSmoothing`,
`effects`, `characters`, `fontName`, `fontSize`, `fontWeight`, `textCase`,
`textDecoration`, `letterSpacing`, `lineHeight`, `textAlignHorizontal`,
`textAlignVertical`, `textAutoResize`, `paragraphIndent`, `paragraphSpacing`,
`listSpacing`, `hyperlink`, `componentPropertyReferences`, and
`componentProperties`. Undefined properties are omitted, nested object keys
are sorted, arrays retain order, symbols stringify, the recursive snapshot is
JSON-stringified, and 32-bit FNV-1a runs over JavaScript UTF-16 code units.

## Focused TDD evidence

The repair contract was written first. Focused RED failed because the old
snapshot had no `shared_anatomy_components` binding:

```text
KeyError: 'shared_anatomy_components'
Ran 1 test
FAILED (errors=1)
```

After the Figma family, snapshot, validator, and schema were bound, the exact
component/control repair tests passed:

```text
Ran 2 tests in 0.599s
OK
```

The approval contract then started RED for the intended reasons: the snapshot
still recorded pending approval and the validator still accepted that stale
posture. After the exact owner statement, terminal review receipt, Figma
metadata receipt, and closed validation were added, the four focused approval,
substitution-rejection, metadata-receipt, and exact-frame tests passed:

```text
Ran 4 tests in 0.602s
OK
```

The proof-honesty Minor began RED because durable owner approval still carried
the completed rereview as `next_required_action`. After replacing that
transient action with the closed approval-record receipt, the three focused
approval/substitution/Figma-receipt tests passed in `0.540s`.

The focused five-test mapping, arbitrary-ID rejection, component/control
contract, generic-control rejection, and R1 snapshot validation set then
passed:

```text
Ran 5 tests in 6.719s
OK
```

The proportional Search amendment plus visual-authority rebaseline modules
then passed `52` tests in `65.142s`. The final post-repair Python 3.12 covering
rerun is recorded in
`.superpowers/sdd/search-visual-authority-owner-approved-python312-covering-final.log`:

```text
Ran 132 tests in 157.944s
OK
```

No general build, UX gate, device test, or accessibility test was run. The
schema and snapshot JSON both parsed
successfully; standalone Draft 2020-12 library validation was not run because
the default Python environment has no `jsonschema` module.

## Deterministic posture

- Exact eight-state set: mapped and still `future_gated`.
- Exact eight frame IDs and six component IDs: bound.
- Screenshot bytes: fresh and digest-bound.
- Legacy protected renders: pre/post byte-identical.
- Destructive Figma actions: none.
- Ask/Capture activation: unchanged.
- Gate B: pending/Red.
- Exact Search visual authority owner approval: recorded.
- Frozen pre-approval design-bundle review: terminal clean, 0/0/0.
- Approval-record independent review: terminal clean, 0/0/0, exact package
  and base authenticated, live Figma readback complete.
- Overall Gate B semantic/visual review: pending.

## Claim ceiling

This evidence supports only the owner-approved final Search visual authority
for the exact frozen nodes and screenshot bytes above, still shadow and
non-authoritative while Gate B is Red/pending. It does not prove production
source, runtime behavior, accessibility, native/device rendering,
privacy/legal approval, release readiness, Visual Green, Gate B Green, or
canon Governance Green.
