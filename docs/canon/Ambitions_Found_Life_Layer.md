# Ambitions Found Life Layer
<!-- markdownlint-disable MD013 -->

Status: Active-scope source truth / product soul canon. No production Swift implementation in this file.
Date: 2026-05-05
Train: FL01-FL06 Found Life Layer

## 0. Product Soul

Ambitions exists because some people are intelligent, ambitious, fast-moving, under-guided, overloaded with life threads, and constantly losing continuity. They are not lazy. They are not low-potential. They are often operating like a sports car with no GPS: high horsepower, low life navigation.

The Found Life Layer exists to make Ambitions more than a goal execution system. It makes Ambitions a life visibility and life continuity system.

Locked product soul line:

> I am lost in life but enjoying every day. I want to be found in life and enjoy every minute while knowing that every day is going to get better because I am actively working to accomplish my goals.

Locked tagline:

> Find your life. Keep your promises. Build your future. Enjoy today.

This tagline is not decorative marketing. It is the operating promise for Ambitions and AmbitionsOS.

### FL01 Product Soul Lock

FL01 locks this section as active product-soul source truth for later FCP, PFC, AOS, LDI, and Found Life work.

The founder backstory must remain product truth, not marketing fluff:

- Ambitions serves people who can have high drive and scattered continuity at the same time.
- The "sports car with no GPS" metaphor describes high potential without enough life navigation; it must not become a narrow persona that excludes calmer or more guided users.
- The product promise is to help the user become found in life while still enjoying today, not to shame them into productivity.
- Found Life is a layer under Today, Goals, Capture, Plan, You, AmbitionsOS, and future source-grounded recall; it is never a sixth top-level tab.
- Found Life must hold context safely and reveal only what the user needs now.

No-drift rules:

- Do not turn Found Life into an all-at-once dashboard, life database, generic notes app, task dump, diary, CRM, LMS, career website, or memory chatbot.
- Do not present inferred memory, inferred commitments, career direction, relationship context, family context, health-adjacent context, or money context as fact without source, freshness, privacy, and review boundaries.
- Do not frame open loops, parked ambitions, abandoned ideas, or missed commitments as failure.
- Do not claim runtime memory, searchable recall, sync, AOS, LDI, legal/privacy compliance, App Store readiness, or release readiness from Found Life docs alone.

## 1. Core Thesis

Ambitions is not only for executing goals. Ambitions is for becoming found in life.

The app must help the user see, search, remember, protect, and act on the whole life they are carrying:

- daily responsibilities
- work obligations
- family commitments
- relationship promises
- errands
- birthdays
- events
- projects
- career uncertainty
- skills
- ideas
- hobbies
- dreams
- abandoned loops
- parked ambitions
- active goals
- future paths
- proof of progress
- pivots that still count

The app must hold the whole picture without forcing the user to stare at the whole picture every morning.

Ambitions should feel like:

> My life is held somewhere safe, and the app only shows me what I need now.

## 2. Found Life Product Job

The Found Life Layer answers:

- What am I carrying?
- What did I promise?
- What did I start?
- What did I forget?
- What still matters?
- What can be closed?
- What can be parked?
- What path am I already building without realizing it?
- What still counts if I pivot?
- What should I do today so my life gets better?

This layer must reduce the feeling of a scrambled brain without becoming a database, dashboard, surveillance system, or motivational gimmick.

## 3. Found Life Object System

### 3.1 Life Inventory

A searchable map of the user's active and parked life threads.

Life Inventory includes:

- Work
- Family
- Relationship
- Home
- Health
- Money
- Career
- Creative work
- App/company work
- Trading/investing watch items where safe
- Friends/social events
- Errands
- Birthdays
- Promises
- Projects
- Someday ideas
- Parked loops
- Abandoned loops with closure state

Life Inventory is not a new top-level tab. It is a domain layer expressed through You, Capture, Today, Goals, Plan, Memory Lens, and Search.

#### FL02 Life Inventory Object Contract

Life Inventory is the Found Life object that lets Ambitions hold what the user
is carrying without forcing the whole life map into the morning surface.

Life Inventory contains `LifeThread` records. A future implementation may name
the concrete type differently, but the product contract must preserve these
fields:

| Field | Meaning | Rule |
| --- | --- | --- |
| `threadId` | Stable local identity for the life thread. | Must not imply sync/cloud identity unless implemented. |
| `threadType` | Work, family, relationship, home, health-adjacent, money, career, creative, company/app work, friend/social, errand, birthday/event, promise, project, idea, dream, parked loop, or abandoned loop. | Must stay reviewable and correctable by the user. |
| `threadState` | Active, parked, waiting, blocked, needs review, needs recovery, intentionally dropped, ready to revive, converted to goal, converted to one-off step, completed, or archived. | No binary failure state. |
| `sourceState` | User-entered, imported, inferred candidate, source-backed, stale source, conflict, or needs review. | Inferred candidate is not fact. |
| `freshness` | Fresh, aging, stale, conflicted, or unknown. | Freshness is a review boundary, not an AI certification. |
| `privacyClass` | Standard, private, sensitive, redacted in previews, external-surface blocked, or user-only review. | Sensitive/private threads cannot surface externally by default. |
| `ownerSurface` | Today, Goals, Capture, Plan, You, Memory Lens, AmbitionsOS, or LDI. | Ownership controls where the thread is reviewed, not a new tab. |
| `reviewPath` | Where the user can correct, delete, park, convert, or close the thread. | Every thread needs a review path before it influences recommendations. |
| `proofLinks` | Optional receipt, proof, decision, source, or captured-fragment references. | Proof is evidence, not achievement. |
| `visibilityRule` | Now-only, review-only, search-only, hidden-from-previews, external-blocked, or needs-user-confirmation. | No all-at-once life database default. |

Life Inventory owner map:

| Surface | Owner responsibility |
| --- | --- |
| Today | Shows only the life thread that matters now, through Start Here / Reality Rail / recovery context. |
| Capture | Creates candidate threads from fragments without requiring perfect placement upfront. |
| Goals | Owns long arcs, option value, proof transfer, converted goals, and path pivots. |
| Plan | Owns capacity, pressure, protected time, commitments, and usable-time constraints. |
| You | Owns Life Inventory review, memory controls, privacy, correction, deletion, export/import posture, identity/direction review, and setup. |
| Memory Lens | Owns source-grounded recall/review views when implemented by a future batch. |
| AmbitionsOS | Owns typed local projection and recommendation contracts only when AOS batches implement them. |
| LDI | Owns dream/path requirements only after LDI safety/source/professional-boundary gates. |

Life Inventory privacy classes:

- `standard`: visible in normal in-app review surfaces.
- `private`: visible only in explicit user-owned review contexts.
- `sensitive`: redacted from previews and collapsed by default.
- `externalSurfaceBlocked`: cannot appear in widgets, Live Activities,
  notifications, App Intents, Spotlight, or shared storage projections by
  default.
- `userOnlyReview`: can influence nothing until the user explicitly reviews or
  confirms it.

Life Inventory must never become:

- a sixth tab
- a life dashboard
- a generic database view
- a notes archive
- a task dump
- a surveillance memory layer
- a source of hidden automation

### 3.2 Commitment Memory

A memory layer for things the user said, promised, implied, needs to remember, or should review.

Examples:

- I said I would pick something up.
- I need to follow up at work.
- A birthday is coming up.
- We made dinner plans.
- A project was started and then parked.
- A career thought should be revisited.
- A trading/news watch item should be reviewed.
- A music idea should not disappear.

Commitment Memory must distinguish:

- user-confirmed commitments
- inferred possible commitments
- imported/sourced commitments
- private commitments
- stale commitments
- completed commitments
- intentionally dropped commitments
- parked commitments
- waiting commitments

#### FL03 Commitment Memory Contract

Commitment Memory is the Found Life contract for promises, obligations,
follow-ups, and remembered life threads. It is not surveillance and not an
automatic obligation engine.

Commitment Memory records must preserve these fields:

| Field | Meaning | Rule |
| --- | --- | --- |
| `commitmentId` | Stable local identity for the remembered commitment. | Must not imply cloud identity unless implemented. |
| `commitmentKind` | Promise, errand, follow-up, birthday/event, relationship attention, family attention, work thread, home thread, money/career review, project loop, parked idea, or dream follow-up. | Must remain correctable by the user. |
| `commitmentState` | Active, parked, waiting, blocked, needs review, needs recovery, intentionally dropped, ready to revive, converted to goal, converted to one-off step, completed, or archived. | No shame or binary failure state. |
| `confirmationState` | User-confirmed, inferred candidate, imported, source-backed, rejected, or needs review. | Inferred candidate cannot become fact or mutate plans silently. |
| `sourceState` | Fresh, stale, conflicted, missing source, private source, or review required. | Source is a freshness/conflict/review boundary. |
| `privacyClass` | Standard, private, sensitive, redacted in previews, external-surface blocked, or user-only review. | Sensitive commitments cannot leak externally by default. |
| `closurePath` | Complete, park, wait, recover, drop intentionally, revive, convert to goal, convert to one-off step, or keep under review. | Closure must be receipt-backed when it changes user-visible state. |
| `receiptRequirement` | None, lightweight receipt, proof receipt, correction receipt, recovery receipt, or private receipt. | Receipts are consequence and reversibility, not notifications. |

Commitment Memory must separate:

- user-confirmed commitments
- inferred possible commitments
- imported/sourced commitments
- private commitments
- stale commitments
- completed commitments
- intentionally dropped commitments
- parked commitments
- waiting commitments
- blocked commitments
- commitments that need recovery

Future implementation rule:

No commitment may move from candidate to active, from parked to active, or from
private/sensitive to visible without explicit source/review path and a user
confirmation or batch-scoped permission model.

### 3.3 Open Loop Registry

A registry for unfinished threads.

Open loops can be:

- active
- parked
- waiting
- blocked
- needs review
- needs recovery
- no longer worth pursuing
- abandoned intentionally
- ready to revive
- converted into goal
- converted into one-off step

The registry must remove shame. Its job is closure and clarity, not guilt.

#### FL03 Open Loop Registry Contract

Open Loop Registry is the Found Life contract for unfinished threads. It helps
the user see what still exists without making every unfinished thing urgent.

Open loops can be:

- active
- parked
- waiting
- blocked
- needs review
- needs recovery
- no longer worth pursuing
- abandoned intentionally
- ready to revive
- converted into goal
- converted into one-off step
- completed
- archived

Open Loop Registry must provide a non-shaming closure ladder:

| Closure option | Meaning | Required boundary |
| --- | --- | --- |
| Complete | The loop is actually done. | Proof or user confirmation when consequential. |
| Park | The loop still matters but not now. | Review date or review reason when useful. |
| Wait | The loop depends on someone/something else. | Source or waiting reason. |
| Recover | The loop slipped but still matters. | Non-shaming recovery copy. |
| Drop intentionally | The user chooses to stop carrying it. | Reversibility or receipt when consequential. |
| Revive | A parked/dropped loop becomes relevant again. | User confirmation. |
| Convert to goal | The loop is large enough to become a goal. | Explicit confirmation; no silent upgrade. |
| Convert to one-off step | The loop is small enough for Today/Plan. | Explicit placement or review path. |
| Archive | The loop remains searchable/reviewable but inactive. | Privacy/source metadata preserved. |

Open loops must not be rendered as a feed, scorecard, overdue list, shame
ritual, or productivity-loss report. They are clarity objects. The default
surface should show only what the user can review or act on safely.

### 3.4 Option Value Engine

A path-transfer model that asks:

> What does this still count toward?

The user may pivot from one dream to another. Prior proof should not be treated as wasted. Ambitions should identify overlapping skills, evidence, requirements, and adjacent paths.

Example:

- Astronaut ambition produces proof in engineering, math, physics, fitness, aviation, software, systems thinking, research, project discipline.
- If the user pivots, the proof can map to aerospace engineering, mechanical engineering, robotics, flight software, applied physics, defense systems, technical program management, research, aviation operations, or other adjacent paths.

Option Value must not make unsafe career/legal/financial claims. It must expose source, uncertainty, and requirements.

#### FL05 Option Value / Pivot Preservation Contract

Option Value preserves proof when a user changes direction. It prevents
Ambitions from treating prior work as wasted, while also preventing the app from
claiming that a pivot is guaranteed, credentialed, legal, financially sound, or
professionally sufficient.

Option Value records need:

| Field | Meaning | Rule |
| --- | --- | --- |
| `sourcePath` | The original goal, dream, project, skill, proof, or life thread. | Must show source and freshness. |
| `targetPath` | The possible adjacent path or new direction. | Must expose uncertainty and requirements. |
| `overlapType` | Skill, proof, credential, experience, relationship, portfolio, habit-of-work, context, or constraint overlap. | Must not overstate eligibility. |
| `proofTransferState` | Directly reusable, partially reusable, inspiration only, needs evidence, conflicted, stale, or not transferable. | Proof transfer is evidence, not achievement. |
| `requirementState` | Known requirement, unknown requirement, source needed, human/professional review needed, or not applicable. | Career/education/regulated-path claims need source and review. |
| `riskBoundary` | Low risk, requires review, professional boundary, legal/financial/medical boundary, or blocked. | Boundaries must be visible before recommendation. |
| `nextReviewAction` | Research requirement, compare proof, ask user, park path, convert to goal, create one-off step, or drop. | No automatic path mutation. |

Option Value answer rules:

- Show what still counts.
- Show what does not yet count.
- Show what requirement/source is missing.
- Preserve proof across pivots only when overlap is real and source-backed.
- Keep career, education, money, health-adjacent, legal, and professional paths
  as review-bound unless a later legally reviewed implementation proves more.
- Do not claim eligibility, admission likelihood, job likelihood, income
  outcome, financial outcome, credential equivalence, legal compliance, or
  medical/health outcome.

Pivot preservation must support:

- dreams that become adjacent careers
- abandoned projects that become portfolio proof
- hobbies that become skills
- relationship/family commitments that become values or constraints
- work problems that reveal repeating strengths or risks
- proof that transfers into a new Goal only after explicit user confirmation

Option Value must never become a career website, school-admission advisor,
financial planner, professional coach with guaranteed outcomes, or generic AI
life-optimizer.

### 3.5 Weekly Life Sweep

A ritual surface that helps the user become found again.

Weekly Life Sweep asks:

- What did I forget?
- What did I promise?
- What still matters?
- What can be dropped?
- What is becoming real?
- What is noise?
- What is the next tax-bracket move?
- What relationship/family item needs attention?
- What work thread is risky?
- What future path is gaining evidence?

This ritual must be calm, non-shaming, and short enough to complete.

#### FL06 Weekly Life Sweep Ritual Contract

Weekly Life Sweep is a future product ritual contract. It is not implemented
by this canon file.

Weekly Life Sweep exists to help the user become found again without turning
life review into a dashboard, feed, scorecard, or shame loop.

Weekly Life Sweep object fields:

| Field | Meaning | Boundary |
| --- | --- | --- |
| `sweepId` | Stable identifier for the sweep session or review window. | Must not become a global life dashboard. |
| `sweepWindow` | The week or review period being considered. | A review window is not a calendar mode. |
| `promptSet` | The calm prompts shown for the sweep. | Keep the ritual short enough to finish. |
| `reviewState` | Not started, in progress, complete, parked, skipped intentionally, or needs recovery. | Skipping is not failure. |
| `sourceInputs` | Commitments, captures, receipts, proof, plans, goals, memory items, and user notes considered. | Source and privacy boundaries must remain visible. |
| `privateSummaryState` | Standard, private hidden, user-only review, or external-surface blocked. | Private details must not leak into previews, widgets, notifications, or Live Activities. |
| `outputIntents` | Start Here candidate, Reality Rail review, Life Inventory update, Option Value review, Memory Lens review, or parked loop. | Outputs are candidates until the user confirms consequential changes. |
| `receiptState` | No receipt needed, review receipt, closure receipt, recovery receipt, or correction receipt. | Receipts are consequence and reversibility, not notifications. |

Weekly Life Sweep prompts:

- What did I forget?
- What did I promise?
- What still matters?
- What can I drop?
- What is becoming real?
- What is noise?
- What is the next income or career move to review?
- What relationship or family item needs attention?
- What work thread is risky?
- What future path is gaining evidence?

Ritual pacing rules:

- Use one clear prompt at a time.
- Prefer review, park, drop intentionally, recover, or create one next step
  over bulk planning.
- Keep inferred items under review and never upgrade them silently.
- Keep private, relationship, family, work, money, health-adjacent, career,
  and dream details protected by source and privacy posture.
- Use non-shaming recovery language when the sweep is skipped, parked, or
  overloaded.
- Preserve Reduce Motion and non-visual equivalents for any sweep progress,
  stack, fold, or visual grouping.

Integration map:

| Surface or system | Weekly Life Sweep role | Boundary |
| --- | --- | --- |
| Today / Start Here | May receive one confirmed next step or review candidate. | No bulk dashboard import. |
| Today / Reality Rail | May surface the most relevant review or recovery item. | Reality Rail remains focused on now. |
| Capture | May receive unresolved fragments from the sweep. | Capture remains text-first and placement follows content. |
| Goals | May receive confirmed proof/path/option-value review. | No automatic path mutation. |
| Plan | May receive capacity and recovery signals. | Plan remains LifeShape-first, not a calendar clone. |
| You | Owns sweep setup, privacy, memory controls, and history. | You remains trust/control-first. |
| Life Inventory | Receives reviewed thread state updates. | Candidate items remain candidates. |
| Option Value | Receives proof-transfer and adjacent-path review inputs. | No career, education, income, financial, legal, or health certainty. |
| Memory Lens | Receives reviewable recall and correction paths. | Source, freshness, privacy, and deletion/correction paths are required. |
| AOS / LDI | May later use sweep signals only through typed, permissioned, source-grounded contracts. | No runtime claim is made by FL06. |

Weekly Life Sweep must never become:

- a dashboard
- a productivity score
- a shame ritual
- an inbox
- an activity feed
- a habit tracker
- a calendar clone
- a surveillance memory layer
- a generic AI life coach
- a silent automation surface

### 3.6 Identity / Direction Memory

A source-grounded memory of what the user is trying to become and what kind of life they want.

It can include:

- roles that matter this season
- desired identity
- desired career direction
- relationship/family standards
- creative ambitions
- financial/career direction
- values
- things the user is trying to escape
- things the user is trying to build
- what "found" means to the user

Identity / Direction Memory must be user-owned, reviewable, correctable, and privacy-safe.

### 3.7 Searchable Life Recall

A search/recall contract for asking Ambitions about life context.

Examples:

- What did I say I needed to buy?
- What career paths have I considered?
- What music projects did I abandon?
- What did my partner mention about this weekend?
- What work problems keep repeating?
- What have I done this month to increase income?
- What skills do I already have that map to better careers?
- What promises are open?
- What should I not forget this week?

Searchable Life Recall must show source, freshness, privacy, and review paths. It must not hallucinate life facts.

#### FL04 Searchable Life Recall Contract

Searchable Life Recall is a future review/search capability contract. It is not
implemented by this canon file.

Recall can answer only when it can show:

- source
- freshness
- privacy class
- confidence-free review state
- correction/deletion path
- whether the answer is user-confirmed, source-backed, imported, inferred
  candidate, stale, conflicted, or unavailable

Recall answer states:

| State | Meaning | Required user-facing posture |
| --- | --- | --- |
| `sourceBacked` | The answer is grounded in a captured, imported, proof, receipt, or user-confirmed source. | Show source and freshness. |
| `needsReview` | The answer has possible support but requires user review. | Ask the user to review before acting. |
| `inferredCandidate` | The answer is a possible memory derived from context. | Present as a candidate, never as fact. |
| `conflicted` | Sources disagree. | Show conflict and review path. |
| `stale` | Source may be stale. | Use `Source may be stale.` |
| `privateHidden` | Content exists but is hidden by privacy rules. | Say private details are hidden from this view. |
| `notFound` | No grounded answer exists. | Do not invent an answer. |

Recall must never:

- answer from unsupported inference as fact
- expose relationship, family, work, money, health-adjacent, career, or dream
  detail in widgets, Live Activities, notifications, App Intents, Spotlight,
  shared storage, screenshots, or previews by default
- claim AI verification, AI confidence, legal/privacy compliance, release
  readiness, or durable memory implementation
- mutate commitments, goals, plans, or receipts silently
- turn into a chatbot wrapper or life database search portal

Recall examples must preserve source/review language:

| User question | Safe answer posture |
| --- | --- |
| "What did I say I needed to buy?" | Show sourced items and review stale/private entries separately. |
| "What promises are open?" | Show confirmed promises first; keep inferred candidates under review. |
| "What career paths have I considered?" | Show source-backed thoughts and requirements/uncertainty, not certainty. |
| "What should I not forget this week?" | Show reviewable commitments, waiting loops, and private-hidden counts. |

Every recall surface needs correction, deletion, privacy, and source-review
paths before it can become user-facing implementation.

## 4. Surface Relationships

Found Life is not a sixth tab. It is expressed through the five locked tabs.

### Today

Today shows only what matters now from the larger life inventory. Start Here must be able to draw from life commitments, promises, roles, goals, work, family, and recovery state.

### Goals

Goals shows long arcs, option value, proof, pivots, and path transfer. Goals must show what still counts after a pivot.

### Capture

Capture is the entry point for life fragments. A thought, promise, errand, dream, fear, work item, career thought, relationship item, or project idea must be captured without requiring the user to decide the perfect category upfront.

### Plan

Plan shows capacity, pressure, protected time, commitments, and recovery. It must distinguish free time from truly usable time.

### You

You owns Life Inventory review, memory controls, commitment history, privacy, identity/direction memory, search controls, and Found Life setup.

## 5. AmbitionsOS Relationships

Found Life requires AmbitionsOS to support:

- Life Graph
- Source Truth Graph
- Commitment Memory
- Proof Ledger
- Option Value Engine
- Open Loop Registry
- Searchable Life Recall
- Start Here Recommendation Kernel
- Reality Drift / Bounded Reflow
- Mutation Permission System
- Receipt Layer
- Privacy Safety Kernel

## 6. LDI Relationship

Living Dream Intelligence must use Found Life as a grounding layer. Big dreams should not become vague motivational text. They must become safe, sourced, feasible paths with:

- current starting position
- requirements
- proof gaps
- source claims
- adjacent paths
- option value
- risk boundaries
- next safe action
- review receipts

## 7. ADHD / Cognitive Load Requirements

The Found Life Layer must support users who:

- forget important commitments
- start many ideas intensely and then abandon them
- struggle to keep future paths in working memory
- chase immediate reward
- feel overloaded by life threads
- lack role models or path scaffolding
- need an external brain that does not shame them

Required UX principles:

- non-shaming closure
- one clear next step
- low cognitive load by default
- full life searchable when needed
- memory is reviewable and correctable
- source/freshness is visible
- private content stays protected
- abandoned work can still count
- parked work is not failure
- recovery is normal

## 8. Trust / Privacy Rules

Found Life is sensitive. It may include relationships, family, career uncertainty, money, health-adjacent routines, child/family planning, work details, and private dreams.

Therefore:

- no hidden inference may become fact without review
- no sensitive memory may surface publicly without privacy gating
- no notifications/widgets/Live Activities may expose sensitive Found Life content by default
- no user-facing recall may omit source/freshness
- no career/education/health/legal/financial recommendation may outrun source and boundary rules
- deletion/correction/rejection must be first-class where memory is implemented
- local-only and sync boundaries must be honest

## 9. Market-Creation Positioning

Ambitions is not competing with task apps. Ambitions creates a category:

> Verified Human Progress OS.

Consumer wedge:

> Start here every day.

Long-term platform thesis:

> Turn any long-term human outcome into a trusted path, daily action, and verified proof.

Expansion vectors:

- personal life operating system
- career path operating system
- education/student progress operating system
- workforce upskilling operating system
- creator/project operating system
- family coordination operating system
- coaching/advising operating system
- verified progress ledger

These are future vectors, not immediate top-level app expansion. The first app must stay cohesive, personal, native, premium, and calm.

## 10. Forbidden Drift

Found Life must not become:

- life dashboard
- surveillance system
- diary app
- notes app
- task dump
- habit tracker
- productivity score
- social feed
- family admin SaaS
- school LMS
- career website
- generic AI memory chatbot
- generic search database
- creepy life graph
- shame engine
- quantified-self scoreboard

Found Life is not "all data shown at once." Found Life is the full life held safely underneath one clear next step.

## 11. Completion Standard

Found Life is complete only when:

- product soul and tagline are in canon
- Life Inventory object model exists
- Commitment Memory and Open Loop Registry are source-truth defined
- Searchable Life Recall contract exists
- Option Value / Pivot Preservation model exists
- Weekly Life Sweep ritual exists
- Found Life is mapped into Today, Goals, Capture, Plan, You, AOS, LDI, FCP, and PFC
- privacy/source/freshness/correction/deletion boundaries are defined
- global order inserts Found Life before Start Here, Reality Rail, Memory Lens, AOS, and LDI implementation
- Codex quality gates include Found Life drift review

No implementation claim is made by this file alone.
