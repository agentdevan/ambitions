# Ambitions Onboarding Spec

Status: Active canon consolidation layer.

Purpose: Define the first-run experience clearly enough for product design, implementation, and QA. This document extracts existing onboarding doctrine from the Design Constitution and external-surface contracts and turns it into a screen-level spec. It reflects product decision Waves 1 and 4.

## Onboarding Thesis

Onboarding should get the user to one useful life object quickly.

Ambitions should not start by asking for permissions, forcing a giant setup questionnaire, or explaining the whole operating system. The first session should prove the product promise:

```text
My life feels organized, I know what matters now, and I know the next concrete step.
```

User-facing category:

```text
Life organization system
```

Internal ambition:

```text
Personal life operating system / external brain
```

## Locked Onboarding Decisions

### Wave 1

- Opening feeling: `My life feels organized`.
- Immediate proof: `I know what matters now` and `I know the next concrete step`.
- Life Areas are inferred/recommended and correctable, not required onboarding friction.
- Default Life Areas: Career, Creative, Finance, Health, Home, Relationships, Education, Personal, Admin.
- Default Life Areas can be renamed while preserving internal canonical type.
- `North Star` is deeper-view language; use `long-term ambition` earlier.
- A Goal is a meaningful outcome that may need a plan.
- User-facing standalone action language is `Task`; internal/design term is `One-Step Goal`.
- Tasks can exist without Goals, but Ambitions should suggest attaching/promoting when useful.
- System rule: every item has a place.
- Execution rules: every goal has a next step; every plan must be believable.
- Emotional rule: the user never feels punished for drifting.
- Product-shape rule: the app stays deep, not wide.

### Wave 4

- Onboarding should show a static premium product preview at launch.
- Animation can come later.
- First onboarding prompt: `What do you want to organize?`
- First object creation should show the receipt inside the destination.
- Do not ask for display density up front.
- Default display setting: `Balanced + Comfortable`.
- Display density and panel size can be adjusted later in `You`.
- Infer Life Area when possible.
- Ask for Life Area only when Ambitions is uncertain.
- Life Area assignment remains correctable from the receipt.
- Do not ask for notifications during onboarding.
- Notification permission should only be requested after the user sets a reminder or protected block.
- Do not ask for calendar access during onboarding.
- Calendar access should only be requested from Plan after the user asks for calendar-aware planning.
- Default onboarding examples should cover Career, Creative, Finance, Health, Home, and Relationships / Family.
- Baby/family examples can appear later when contextually relevant.
- If the user skips onboarding, land in Today with a strong empty state and Capture action.
- First-run success metric: user creates any useful object.

## First-Run Success Definition

A first-run session succeeds when the user has:

1. Created any useful object.
2. Seen where it went.
3. Seen a receipt inside the destination.
4. Understood the next step.
5. Been shown that Ambitions can organize life without requiring calendar, sync, notifications, account setup, display-density setup, or full planning upfront.

First-run success does not require:

- completing all onboarding screens
- connecting calendar
- enabling notifications
- creating a full plan
- building a complete goal hierarchy
- choosing display density

## Non-Negotiable Rules

- No upfront calendar permission request.
- No upfront notification permission request.
- No sync/account dependency for first value.
- No display-density prompt before first value.
- No chat-first AI framing.
- No giant preference questionnaire.
- No dense explanation of the full app model.
- No unverified accessibility, sync, automation, or memory claims.
- User can skip or exit setup and still land in a safe usable app state.
- Do not expose `North Star` too early; use simpler long-term ambition language if needed.
- Do not make first-run success depend on anything beyond one useful object, a visible destination, a receipt, and a next action.

## Default Onboarding Flow

### Step 1: Opening Promise + Static Preview

Purpose: Establish what Ambitions does in plain language and show one premium static preview of the product shape.

Primary content:

```text
Organize your life around what matters.
Turn goals, tasks, plans, and real life into clear next steps.
```

Alternate shorter option:

```text
Organize what matters.
Know what to do next.
```

Static preview guidance:

- Show one calm, premium preview, not a carousel.
- Preview should imply Today / Goal / Plan organization without teaching the entire app.
- Keep preview static at launch.
- Animation can be introduced later only if it improves clarity without distraction.

Primary action:

```text
Start
```

Secondary action:

```text
Explore First
```

Rules:

- Keep copy short.
- Do not describe every feature.
- Do not use hype language.
- Do not reduce Ambitions to a goal app, planner, habit tracker, or calendar wrapper.
- Do not request permissions here.

### Step 2: First Useful Input

Purpose: Let the user drop life into Ambitions.

Prompt:

```text
What do you want to organize?
```

Default example set should cover:

- Career
- Creative
- Finance
- Health
- Home
- Relationships / Family

Example inputs:

- `Get a data analyst job in 6 months`
- `Release 3 songs by August 1`
- `Pay off $5,000 of debt by December 1`
- `Get back into a consistent gym routine`
- `Build the baby crib before the due date`
- `Plan a better weekly rhythm with Alexandra`

Baby/family examples can appear later when contextually relevant. They should not dominate default onboarding.

Primary action:

```text
Organize This
```

Secondary action:

```text
Use Example
```

Rules:

- This is not a chat interface.
- The input should feel like Capture / Quiet Command Sheet.
- The user should be able to enter a goal, task, commitment, plan seed, or raw idea.
- The first input should make the user feel their life is becoming more organized.

### Step 3: Compact Clarification Only If Needed

Purpose: Ask only what is needed to route the first object.

Clarification should use 1-3 compact choices when confidence is low or medium.

Possible questions:

```text
What is this?
Goal / Task / Idea
```

```text
Where does this belong?
Career / Creative / Finance / Health / Home / Relationships / Education / Personal / Admin
```

```text
When does it matter?
Today / This week / Later / Has a deadline
```

Rules:

- Ask at most two clarification rounds before creating something usable.
- Do not expose the full domain model.
- Let Ambitions proceed with a receipt if the user chooses not to clarify.
- Life Area should be inferred when possible.
- Ask for Life Area only when Ambitions is uncertain.
- Life Area remains correctable from the receipt.

### Step 4: Create Object + Show Receipt Inside Destination

Purpose: Show where the item went and why while proving the destination is useful.

The receipt should appear inside the destination rather than as a disconnected interstitial.

Examples:

```text
Saved as Goal · Creative
Next: Shape the first milestone
Change
```

```text
Saved as Task · Career · Tuesday
Next: Add it to Plan
Change
```

```text
Saved to Needs a Place
Next: Choose Goal, Task, or Idea
```

Required anatomy:

- saved object type
- destination
- next useful action
- `Change` route option
- `Open` or `Continue` route where needed

Rules:

- Receipts establish trust.
- Avoid model/confidence language.
- Show correction affordance.
- Every item should have a place, even if the temporary place is Needs a Place.
- The object should remain visible behind or near the receipt.

### Step 5: First Next Step

Purpose: Convert the first object into action.

If first object is a Goal:

- show one proposed milestone or next step
- offer `Build First Plan` or `Add First Step`

If first object is a Task:

- offer `Add to Today`, `Schedule`, or `Keep for Later`
- suggest attach/promote only when useful, not as mandatory friction

If first object is an Idea/Seed:

- offer `Clarify Later`, `Turn Into Goal`, or `Keep in Capture`

If first object is a Waiting item:

- offer `Add Follow-Up`, `Keep Waiting`, or `Attach to Goal`

Rules:

- One primary action only.
- Avoid long plans before the user asks.
- Make the app feel useful immediately.
- Every goal should gain or point toward one clear next step.

### Step 6: Optional Later Personalization In You

Purpose: Let the user tune complexity after first value, not during onboarding.

Default:

```text
Balanced + Comfortable
```

Do not ask during first-run onboarding:

- display density
- panel size
- notification style
- calendar permission
- sync/account setup

Adjust later in `You`:

- Appearance: Dark / Light / System
- Accent selection
- Display density: Minimal / Balanced / Detailed
- Panel size: Compact / Comfortable / Large
- Notification style: Essential / Balanced / Supportive
- Rename Life Areas

Rules:

- Personalization is available, not blocking.
- Do not ask for every preference.
- Do not mention ADHD Mode; user-facing language is Focus Support.
- Renaming Life Areas should preserve internal canonical type.

### Step 7: Land In App

Destination depends on first object:

| First object | Landing destination |
| --- | --- |
| Goal | Goal Detail or Goals with receipt visible inside the destination |
| Task / One-Step Goal | Today or Plan, depending on timing, with receipt visible |
| Deadline commitment | Plan with receipt visible |
| Raw idea | Capture Needs a Place with receipt visible |
| Waiting item | Capture/Waiting route or relevant Goal Detail with receipt visible |
| User skips onboarding | Today with strong empty state and Capture action |

Required landing content:

- object is visible
- next step is visible
- receipt is visible in context
- route correction remains available
- no permission prompt appears automatically

## Progressive Permission Strategy

### Calendar

Calendar permission is Plan-owned.

Allowed triggers:

- `Make Plan calendar-aware`
- `Find real open windows`

Required rationale:

- what calendar access improves
- Plan works without access
- calendar write requires confirmation

Rules:

- Do not request calendar access during onboarding.
- Calendar access should only be requested from Plan after the user asks for calendar-aware planning.

### Notifications

Notifications should be requested only after the user sees value and chooses a reminder/notification feature.

Recommended trigger:

- setting a reminder
- enabling Essential reminders
- starting a protected block

Rules:

- Do not request notification permission during onboarding.

### Sync / Account

Sync/account setup must not block first value.

Recommended trigger:

- user opens Sync / Export
- user attempts multi-device continuity
- user chooses backup/export

## Returning-User Re-Entry

If onboarding was abandoned:

- preserve input if possible
- land in Today with a simple prompt and Capture action
- do not restart the full sequence unnecessarily

Copy example:

```text
You can start with one thing.
```

Actions:

- `Capture Something`
- `Use Example`
- `Skip for Now`

## Empty First-Run State

If the user skips setup, Today should not feel broken.

Required content:

- short explanation of what Today will do
- one action to capture or create first object
- optional example

Example:

```text
Today gets useful after you add one thing that matters.
```

Primary action:

```text
Capture Something
```

Secondary action:

```text
Use Example
```

## Accessibility And Focus Support

Requirements:

- Dynamic Type support.
- VoiceOver labels for all choices.
- No required gestures.
- No color-only choices.
- Reduced Motion support.
- Short screen copy.
- Stable primary action placement.
- Skippable setup.
- Static preview must have equivalent VoiceOver description.

## QA Acceptance Criteria

Onboarding is acceptable when:

- User can create any useful object, not only a Goal.
- A user can complete first value in under a few screens.
- User can create a Goal, Task, commitment, or idea from the same input pattern.
- A static premium preview appears without requiring animation.
- Route receipt appears inside the destination after creation.
- User can change the route from the receipt.
- Life Area is inferred when possible and asked only when uncertain.
- Life Area remains correctable.
- Default display setting is Balanced + Comfortable.
- Display density is not asked during onboarding.
- No permissions are requested before explicit value/action.
- Calendar permission is only Plan-triggered.
- Notification permission is only reminder/protected-block triggered.
- User lands somewhere useful.
- Skipping onboarding lands in Today with a safe empty state and Capture action.
- Dynamic Type and VoiceOver remain usable.
- No unverified claims appear.
- The experience proves organization, next action, and calm recovery without explaining the whole system.

## Resolved Wave 1 Questions

- Life Area is inferred/recommended and correctable, not required onboarding friction.
- Default Life Areas are Career, Creative, Finance, Health, Home, Relationships, Education, Personal, Admin.
- North Star should not be heavily exposed during onboarding.
- Goal means a meaningful outcome that may need a plan.
- Standalone action UI language is Task.

## Resolved Wave 4 Questions

- Static premium product preview at launch; animation later.
- First prompt: `What do you want to organize?`
- First object creation shows receipt inside destination.
- Display density is not asked during onboarding; default is Balanced + Comfortable.
- Life Area is inferred when possible and asked only when uncertain.
- Notifications are requested only after reminder/protected-block value.
- Calendar access is requested only from Plan after calendar-aware planning action.
- Default examples cover Career, Creative, Finance, Health, Home, and Relationships / Family.
- Baby/family examples can appear later when contextually relevant.
- Skipping onboarding lands in Today with strong empty state and Capture action.
- First-run success metric is any useful object created.

## Known Gaps / Future Questions

- Should examples be personalized after the user creates enough context?
- Should baby/family examples be triggered by user-confirmed family context or explicit Life Area selection?
- Should the static preview show Today, Goal Detail, or Plan as the hero representation?
