# Motion and Microinteraction Spec

## Purpose

Define concrete motion grammar, interaction meaning, and haptic intent for transformed Ambitions surfaces.

## Motion Philosophy

- motion explains structure
- motion confirms causality
- motion relieves cognitive load
- motion must never exist only to look premium

## Core Motion Meanings

- `Upward reveal`: gaining context or entering a larger framing view
- `Forward slide`: moving deeper into owned detail
- `Downward settle`: completing or resolving
- `Lateral shift`: deferring, rescheduling, or moving through time
- `Soft expansion`: revealing supporting detail without leaving the current context
- `Soft collapse`: returning to primary truth after inspecting detail

## Transition Grammar

### Tab change

- quick, low-drama continuity
- header rail adapts
- hero zone transitions first, supporting modules follow

### Tab to detail

- preserve anchor relationship
- hero-origin card or row should feel like it expands into detail

### Object-persistent transition

- if the same goal, block, capture, or review object appears on the source and destination surface, preserve its identity anchor through motion, stable framing, or both
- the transition should suggest "same object, deeper context" rather than "new screen, similar data"

### Detail to edit

- sheet or full-screen cover should emerge from the owning region

### External entry to app

- landing motion must reinforce the owning tab and destination relationship

## Completion Feedback

### Meaning

The user changed real state successfully.

### Visual behavior

- subtle compression on press
- confirmation glow or tonal shift
- item settles or exits with closure motion

### Haptic intent

- light confirmation haptic only for meaningful task completion, correction save, or focus start

## Reschedule and Recovery Motion

- deferring and rescheduling move laterally or slightly backward in time-oriented motion
- recovery overlays bloom open softly, never snap like an error dialog
- protect-later actions should feel calm and reversible

### Recovery Bloom deepening

When a plan breaks:

1. the current structure remains visible but softens in emphasis
2. the safer path appears in the foreground, not as a replacement that erases prior context
3. the user sees one clearer recovery lane before optional alternatives
4. explanation expands only after the safer lane is visible

The visual result should feel like the app is reorganizing a broken day into a believable shape, not announcing failure.

## Trust Disclosure Motion

- whisper-level trust detail expands inline or via compact sheet
- reasoning layers should unfold progressively
- audit and contradiction views open with seriousness, not alarming shake or red flash

## Shell Motion

- header rail shifts role, not just text
- compose surface rises from shell context
- shell state changes should preserve calm, especially when driven by notifications or external entry
- continuity ribbon enters and exits as a carried thread, not like a toast
- Quiet Command Sheet should feel like the shell is revealing capability, not dropping a menu on top

## Microinteractions

### Tap

- compression plus subtle tone change

### Long press

- used only when it reveals meaningful secondary actions
- never hide critical daily actions behind long press only

### Swipe

- permitted for high-frequency actions such as complete, defer, archive
- destructive-looking red swipe language should be rare

### Expand / collapse

- preserve local context
- do not disorient screen position

### Quiet Command Sheet

- opens with calm upward reveal
- search or action focus is ready immediately
- category changes should feel editorial, not tab-like

### Semantic Zoom

- zooming between `Now`, `This week`, `This phase`, and `Full path` should preserve the active goal anchor
- detail should compress and expand in place where possible

### Window Magnetism

- attraction of work into a suitable open window should feel suggestive, not magnetic in a game sense
- if the suggestion is accepted, the commit motion should read as work settling into available room

### Continuity Ribbon

- ribbon updates should crossfade or slide minimally, not pulse

### Review Constellation

- clusters should expand outward softly from the chosen proof group
- collapse should return to the summary constellation without losing orientation

## Reduce Motion Guidance

- preserve hierarchy change through opacity, tone, and layout rather than large travel
- remove decorative parallax or exaggerated scale
- keep state-change feedback but shorten travel distance

## Screen-Specific Notes

### Today

- hero truth updates should feel like replacing the current thesis
- Recovery Bloom should open as a relieving state change

### Goals

- reordering cards should explain changing pressure or relevance
- semantic zoom transitions should compress or expand goal structure without dropping the user into a new list identity

### Goal Detail

- Path Filmstrip should progress directionally
- correction confirmation should be precise and quiet
- Path Preview Drawer should expand as a shallow future reveal, not a modal interruption

### Plan

- Elastic Week View must visibly expand density where pressure concentrates
- scrubbing pressure should update immediately but remain smooth
- open windows should attract suitable work suggestions through subtle proximity and settling motion

## Anti-Patterns

- no bounce-heavy playful motion
- no gamified confetti
- no modal pop-ins for serious recovery or trust flows
- no gratuitous glassy movement
