# Ambitions Onboarding Spec

Status: Active canon consolidation layer.

Purpose: Define the first-run experience clearly enough for product design, implementation, and QA. This document extracts existing onboarding doctrine from the Design Constitution and external-surface contracts and turns it into a screen-level spec.

## Onboarding Thesis

Onboarding should get the user to one useful life object quickly.

Ambitions should not start by asking for permissions, forcing a giant setup questionnaire, or explaining the whole operating system. The first session should prove the product promise:

```text
My life feels more organized, and I know the next concrete step.
```

## First-Run Success Definition

A first-run session succeeds when the user has:

1. Created one useful object.
2. Seen where it went.
3. Understood the next step.
4. Been shown that Ambitions can organize life without requiring calendar, sync, notifications, or account setup upfront.

## Non-Negotiable Rules

- No upfront calendar permission request.
- No upfront notification permission request.
- No sync/account dependency for first value.
- No chat-first AI framing.
- No giant preference questionnaire.
- No dense explanation of the full app model.
- No unverified accessibility, sync, automation, or memory claims.
- User can skip or exit setup and still land in a safe usable app state.

## Default Onboarding Flow

### Step 1: Opening Promise

Purpose: Establish what Ambitions does in plain language.

Primary content:

```text
Organize what matters.
Turn goals, tasks, plans, and real life into clear next steps.
```

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

### Step 2: First Useful Input

Purpose: Let the user drop life into Ambitions.

Prompt:

```text
What do you want to organize?
```

Input examples:

- `Release 3 songs by August 1`
- `Build the baby crib before the due date`
- `Create spreadsheet and send it to Kaylee by EOD Tuesday`
- `Get a data analyst job in 6 months`
- `Pay off $5,000 of debt by December 1`

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

### Step 3: Compact Clarification

Purpose: Ask only what is needed to route the first object.

Clarification should use 1-3 compact choices when confidence is low or medium.

Possible questions:

```text
What is this?
Goal / Task / Idea
```

```text
Where does this belong?
Career / Creative / Home / Finance / Personal
```

```text
When does it matter?
Today / This week / Later / Has a deadline
```

Rules:

- Ask at most two clarification rounds before creating something usable.
- Do not expose the full domain model.
- Let Ambitions proceed with a receipt if the user chooses not to clarify.

### Step 4: Route Receipt

Purpose: Show where the item went and why.

Examples:

```text
Saved as Goal · Creative
Next: Shape the first milestone
Change
```

```text
Saved as Task · Work · Tuesday
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
- `Open` or `Continue` route

Rules:

- Receipts establish trust.
- Avoid model/confidence language.
- Show correction affordance.

### Step 5: First Next Step

Purpose: Convert the first object into action.

If first object is a Goal:

- show one proposed milestone or next step
- offer `Build First Plan` or `Add First Step`

If first object is a Task:

- offer `Add to Today`, `Schedule`, or `Keep for Later`

If first object is an Idea/Seed:

- offer `Clarify Later`, `Turn Into Goal`, or `Keep in Capture`

If first object is a Waiting item:

- offer `Add Follow-Up`, `Keep Waiting`, or `Attach to Goal`

Rules:

- One primary action only.
- Avoid long plans before the user asks.
- Make the app feel useful immediately.

### Step 6: Light Personalization

Purpose: Let the user tune complexity without delaying first value.

Ask after first object is created.

Recommended controls:

```text
How much detail do you want by default?
Minimal / Balanced / Detailed
```

```text
Panel size
Compact / Comfortable / Large
```

Default:

```text
Balanced + Comfortable
```

Optional later:

- Appearance: Dark / Light / System
- Accent selection
- Notification style: Essential / Balanced / Supportive

Rules:

- Personalization is skippable.
- Do not ask for every preference.
- Do not mention ADHD Mode; user-facing language is Focus Support.

### Step 7: Land In App

Destination depends on first object:

| First object | Landing destination |
| --- | --- |
| Goal | Goal Detail or Goals with receipt visible |
| Task / One-Step Goal | Today or Plan, depending on timing |
| Deadline commitment | Plan with receipt visible |
| Raw idea | Capture Needs a Place |
| Waiting item | Capture/Waiting route or relevant Goal Detail |

Required landing content:

- object is visible
- next step is visible
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

### Notifications

Notifications should be requested only after the user sees value and chooses a reminder/notification feature.

Recommended trigger:

- setting a reminder
- enabling Essential reminders
- starting a protected block

### Sync / Account

Sync/account setup must not block first value.

Recommended trigger:

- user opens Sync / Export
- user attempts multi-device continuity
- user chooses backup/export

## Returning-User Re-Entry

If onboarding was abandoned:

- preserve input if possible
- land in Capture or Today with a simple prompt
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

## QA Acceptance Criteria

Onboarding is acceptable when:

- A user can complete first value in under a few screens.
- User can create a Goal, Task, commitment, or idea from the same input pattern.
- Route receipt appears after creation.
- User can change the route.
- No permissions are requested before explicit value/action.
- User lands somewhere useful.
- Skipping onboarding produces a safe empty state.
- Dynamic Type and VoiceOver remain usable.
- No unverified claims appear.

## Known Gaps / Future Questions

- Should onboarding show one animated product preview or stay entirely input-first?
- Should Life Area be required during onboarding, optional, or inferred?
- Should first object creation default to Capture receipt or directly to Goal/Plan detail?
- Should appearance setup happen during onboarding or only in You?
- Should examples be personalized by selected Life Area?
- Should onboarding include pregnancy/family, career, creative, finance, health, and home examples by default?
