# PRODUCT_DESIGN_TRUTH.md

Status: Active product/design source of truth  
Scope: Product identity, interaction model, information architecture, visual direction, object model, trust, accessibility, local-first intelligence, frontend implementation guardrails  
Applies to: Ambitions native iPhone app  
Owner posture: Product/design truth, not implementation proof  
Effective rule: This file supersedes scattered product/design canon anywhere this file is more specific, stricter, or more recent.

Frontend maturity relock: This file now incorporates the human-approved Master Frontend Maturity Implementation Bundle. All active visual, object, surface, motion, accessibility, and privacy canon in this file reflects the relocked frontend thesis. Prior visual ratios, object names, and surface models that conflict with this file are superseded.

---

## 0. Codex Operating Order

Codex must treat this file as the only active product/design truth for Ambitions implementation.

Older docs may be used only as supporting reference when they do not conflict with this file. If an older document conflicts with this file, this file wins. If an older document revives a banned term, old tab, obsolete visual direction, cloud dependency, chatbot framing, generic frontend pattern, or compatibility name, Codex must reject that older direction.

This file is intentionally strict. Ambitions is not a pile of SwiftUI screens. Ambitions is an object-first native iPhone product system.

Implementation must follow this order:

1. Product identity
2. Local-first architecture
3. Top-level IA
4. Core object model
5. Surface truth
6. State model
7. Trust / receipts / proof
8. Accessibility
9. Motion / feedback
10. Visual system
11. Anti-drift rules
12. Implementation proof

Codex must not implement UI from aesthetics first. Product object, state, source, interaction, and accessibility come first.

Hard rule:

```text
If a proposed implementation makes Ambitions look like a generic task app, calendar app, habit tracker, notes app, dashboard, chatbot, SaaS admin panel, astrology app, neon sci-fi HUD, or generic SwiftUI demo, stop and repair before continuing.
```

---

## 1. Product Design Truth Decision Matrix

| Area | Final Recommendation | Why This Is Best | Repo/Canon Influence | Benchmark Influence | Codex Guardrail |
|---|---|---|---|---|---|
| Product identity | Premium iPhone-first, local-first external brain and personal life operating system. | Broader than goals; owns life reality, planning, execution, recovery, proof, and growth. | Preserves life operating system direction while upgrading beyond goal executor. | Best apps are durable object systems, not page systems. | Never reduce Ambitions to a productivity app, task app, habit tracker, calendar clone, notes app, dashboard, SaaS dashboard, social feed, gamified XP system, web-app wrapper, or chatbot. |
| Product promise | Organize life, shape time, ground goals, adapt to reality, close loops without shame. | Covers daily through long-range use. | Preserves Capture → Shape → Start → Close → Remember. | Benchmark apps promise one clear job with deep states. | Every surface must support a real user job and state transition. |
| Target user | Ambitious, privacy-conscious iPhone user managing many life areas, commitments, ideas, constraints, pivots, and goals. | More precise than productivity user. | Aligns with personal life OS and iPhone-native canon. | Best apps support power use without widening root IA. | Build serious personal-use software, not casual gamified productivity. |
| Primary use cases | Capture, clarify, plan horizons, start what fits, recover, pivot, inspect Motion, tune system defaults. | Complete external-brain loop. | Preserves Capture input while installing Today, Goals, Time, Motion, You roles. | Durable apps convert input into stateful object journeys. | No disconnected feature that does not enter the object loop. |
| Daily emotional feel | Calm by default, warm enough to feel human, decisive only when useful. | Avoids cold system UI and hype productivity. | Preserves non-shaming recovery canon. | Flighty/Oura-like state awareness without copying visuals. | No guilt, panic, sportsbook urgency, productivity-bro copy, or fake hype. |
| Product quality bar | Market-leading native iPhone flagship quality. | Sets design/frontend expectations before implementation. | Preserves 95+/98+ quality posture. | Benchmarks are deep, fast, polished, stateful. | A screen is not done because it compiles; it must prove object depth, state, accessibility, and polish. |
| Visual/product direction | Quiet Object Instruments under a North Star Field. Priority stack: object state, native restraint, tactile instrument clarity, inspectable local runtime trust, North Star / celestial orientation, atmospheric depth. | Replaces old percentage-based visual ratio with the relocked visual canon grounded in object state and native restraint. | Preserves taste profile while aligning with local-only rule and relocked frontend maturity thesis. | Premium apps use restraint, state, and decisive action. | No AI chrome, generic dashboard, spectacle-first design, decorative celestial, or wallpaper stars. |
| What Ambitions is not | Not task app, habit tracker, calendar clone, chatbot, dashboard, SaaS, social feed, notes app, coaching app. | Negative space prevents drift. | Existing hard-red lists are strong. | Benchmark mechanics are not product direction. | Reject any screen that could ship unchanged in a generic productivity app. |
| Market category | External brain + personal life OS. | Distinct, broad, premium. | Upgrades goal-execution framing. | Great apps own category-specific object systems. | Avoid generic App Store productivity framing in architecture. |
| Reason to exist | Existing tools fragment life across tasks, calendars, notes, habits, and goals; Ambitions connects them locally. | Defines the gap. | Canon already combines time, goals, capture, trust. | Object-first apps feel deeper because objects travel across surfaces. | Every core object must connect across surfaces or justify its isolation. |
| External brain model | Remembers, relates, schedules, resolves, explains; does not chat. | External brain is infrastructure, not assistant persona. | Preserves Trust Seam, Receipts, Personal Runtime. | State and memory beat generic chat. | No chatbot as primary UI. |
| Life-improvement model | Improve life by reducing scatter, increasing fit, preserving proof, and normalizing recovery. | Sustainable and non-shaming. | Preserves Still Counts, Action Closure, Recovery. | Avoid health-score pressure while learning from reflection depth. | No life score, productivity score, streak pressure, or ranked self-worth. |
| Planning horizons | Day, Week, Month, Year, Life Range inside Time and drill-downs. | Broad without adding tabs. | Extends LifeShape and Week default. | Timeframe depth works inside one object. | Do not create separate Day/Week/Month/Year tabs. |
| Pivot/adaptation | Pivots are first-class object transitions with preview, proof transfer, and receipt. | Reality changes; product must support it elegantly. | Preserves Quiet Reflow and Proof Transfers. | Best apps show state continuity through changes. | No silent schedule mutation. |
| Personalization | Local deterministic personalization from choices, closures, timing, patterns, defaults, edits. | Useful without creepy cloud profiling. | Preserves local-first intelligence. | Benchmarks personalize through object history. | Personalization must be inspectable, editable, resettable, and local. |
| Unique instance | Each instance becomes unique through life areas, rhythms, defaults, proof history, capture patterns, and closure behavior. | Personal without theme gimmicks. | Preserves reorder/pin/hide/rename and planning defaults. | Object graphs accumulate identity. | Do not fake personalization with decorative gradients or smart labels. |
| Local-only core | Core personal data and intelligence are local-first/local-only. | Required privacy architecture. | Strengthens privacy canon. | Avoids server-driven dependence. | No feature may require external LLM, hosted account, or personal-data backend. |
| Apple sync exception | Apple account/iCloud-style sync may sync user-owned data across user devices. | Private, platform-native, user-owned. | Compatible with native iPhone direction. | Native sync should feel invisible and controlled. | Do not invent a custom hosted Ambitions account. |
| R2 exception | Cloudflare R2 may host read-only public freshness/reference packs. | Supports public dates/rules/templates without personal backend. | Extends source/freshness canon. | External data can power current-state awareness. | R2 is never a user-data backend. |
| Local-only data | Goals, captures, schedule assumptions, closures, receipts, proof, personalization, planning defaults, life areas. | These are sensitive life data. | Matches privacy classes. | State depth can be local. | Store private life graph on-device by default. |
| Apple-sync data | User-owned Ambitions data, preferences, receipts, proof, settings when user enables sync. | Sync follows ownership. | Aligns with Apple-native trust. | Portable object state can support future surfaces. | Sync must be optional/user-controlled. |
| R2 data | Public dates, regulations, requirements, rule packs, planning templates, non-personal reference metadata. | Useful freshness without personal exposure. | Extends source labels and Source Needed. | Public data can improve context. | Never upload user context to fetch R2 packs. |
| Never sent to R2 | Goals, captures, calendar, behavior, receipts, proof, profile, patterns, inferred priorities, personal context. | Prevents backend creep. | Matches privacy restraint. | Avoids server profiling. | Any R2 request must be anonymous/non-personal or blocked. |
| External/cloud LLM | Excluded from core product truth. | Required architecture. | Locked local intelligence principle. | Intelligence can be product behavior. | No OpenAI/API/cloud model path in core architecture. |
| Inspectable intelligence | Every recommendation exposes source, reason, uncertainty, control, and receipt behavior. | Trust is architecture. | Directly from Trust/Automation canon. | Premium apps explain state through context. | No black-box recommendation. |
| Deterministic personalization | Use rules, recency, defaults, completion behavior, corrections, local scoring. | Predictable and testable. | Aligns with local runtime. | Object history supports deterministic ranking. | No opaque AI confidence language. |
| User control | User can inspect, decline, adjust, reset, disable, clear learning. | Prevents creepy automation. | Existing Trust & Automation. | Power apps provide control without clutter. | Put controls in You → Trust & Automation / Personal Runtime. |
| Anti-creepy learning | Learn behaviors, not identity labels; avoid sensitive inference; explain pattern use. | Personal but not invasive. | Extends privacy classes. | Health apps show risks of over-personalization. | Never infer protected/sensitive identity attributes for recommendations. |
| Learn from Real | Deep object graph, live-ish state, compact primitives, object transformations. | Real’s strength is object depth. | Supports Signature Objects. | One object, many affordances. | Copy object-system depth, not sports/social/feed mechanics. |
| Learn from DraftKings | Persistent action context and transaction confirmation. | Bet slip equivalent becomes closure/action context, not betting. | Supports Start Here, Closure, Receipts. | Persistent transaction layer is compelling. | No odds, urgency, wagering, monetization pressure. |
| Learn from Flighty | Ambient current-state awareness, offline resilience, anxiety reduction. | Fits life reality and schedule changes. | Supports Reality Meridian and Time. | Flight state becomes orientation layer. | Make day/current-state clear without panic or notification spam. |
| Learn from TradingView | Dominant canvas with deep timeframe/detail controls. | Supports LifeShape and Reality Meridian depth. | Reinforces one-primary-object law. | Chart canvas is deep, not wide. | Do not scatter planning into many pages. |
| Learn from Strava | Durable activity/proof history and performance-conscious object history. | Ambitions needs proof without social feed. | Supports Receipts/Proof. | Activity object accumulates identity. | No follows, kudos, leaderboards, public comparison. |
| Learn from Oura/WHOOP | Headline state first, trend depth second. | Reflection without dashboard sprawl. | Supports calm review and recovery. | Dense health apps summarize before detail. | No readiness/life/productivity score as identity. |
| Learn from FotMob/Sofascore | Current event state, compact density, detail drill-down. | Today and Step states should feel current. | Supports Now/Next/Later. | Live match object handles density. | No sports-style tables or alert overload. |
| Learn from Sleeper/FanDuel/Underdog | Interaction polish, speed, persistent selections. | Useful for frontend quality bar. | Supports Dock, haptics, stateful controls. | Betting/fantasy apps are interaction-dense. | No social leagues, fantasy mechanics, or gamified pressure. |
| Must not copy | Sports data, odds, betting, social feeds, leaderboards, fantasy, health-score decoration, travel-alert styling. | Prevents category contamination. | Aligns with anti-drift. | Benchmark is quality input only. | Translate before implementation. |
| Native benchmark rules | Narrow IA, durable nouns, persistent context, current state, reusable primitives, progressive disclosure. | Durable design law. | Reinforces flagship canon. | Shared pattern across benchmark apps. | Every feature must map to object, state, source, and surface. |
| Final top-level IA | Today / Goals / Time / Motion / You. | Five tabs; broad enough, narrow enough; Capture is global input, not a destination. | Installs the Motion IA decision and supersedes the prior Capture-tab IA. | Benchmarks use narrow root IA with global actions. | Hard red for sixth tab or Plan/Capture/Calendar/Assistant/Inbox top-level as new product truth. |
| Tab decision | Keep five; Time remains capacity, Motion replaces Pulse as the approved fifth tab name, and Capture becomes a global action. | Time is broader and less calendar-clone; Motion owns returnable proof/progress/inspection; Capture stays always available without becoming a tab. | Fixes Plan drift and first-class global Capture migration. | Capacity and proof objects beat calendar pages and progress dashboards. | Plan may appear only as action/copy, Pulse only as historical/prior working-name context, Capture only as global action. |
| Tab names | Today, Goals, Time, Motion, You. | Plain, native, obvious. | Matches Motion IA canon. | Top apps use simple root nouns. | No Mission Control, Dashboard, Assistant, Calendar, Profile, Captures, Pulse, Plan, or Capture tab in active product truth. |
| Surface purpose | Today now; Goals direction; Time capacity; Motion movement; You context; Capture input. | Clean mental model. | Direct repo influence. | Object-first products make each root clear. | Each screen answers one question within three seconds; Capture access does not require tab switching. |
| One-primary-object law | One dominant living object per top-level surface. | Prevents card stacks. | Strong existing canon. | Benchmarks revolve around dominant primitives. | Top-level screen fails if it is a pile of modules. |
| Navigation depth | Shallow root, deep object drill-down. | Avoids wide IA. | Preserves drill-down model. | Benchmark pattern. | New depth must open from an object, not random menu. |
| Drill-down | Object detail, sheets, Trust Seam, receipts, horizon drill-downs. | Depth belongs in objects. | Signature Object Specs. | Benchmarks expand objects. | No disconnected detail pages. |
| Search role | No global search at top level for launch. | Search would imply database/productivity app. | You canon bans search-first. | Best root surfaces do not need search to explain value. | Do not add top-level search bars by default. |
| Inbox role | Capture management is drill-down, not top-level. | Capture remains quiet. | Existing Capture canon. | Avoid notes/inbox drift. | No Inbox tab or default capture feed. |
| You role | You is system control, not social profile. | Trust and defaults need a home. | User System Profile canon. | Native settings clarity. | No social profile, family hub, admin console. |
| Horizon model | Day/Week/Month/Year/Life inside Time; Today owns current action. | Avoids calendar clone. | Extends LifeShape Field. | Timeframe controls are primitive, not IA sprawl. | No Year tab, Review tab, Calendar tab. |
| Review role | Review lives in Today closure, Time horizon review, Goals proof, You receipts. | Review is behavior, not destination. | Preserves Close Today/Receipts. | Apps embed review in history. | Do not add Review top-level. |
| Core nouns | Day, Step, Goal, Goal Thread, Life Area, Capture Item, Held Item, Time Block, LifeShape, Closure Event, Receipt, Proof, Pivot, Recovery Thread, Personal Context, User System Profile. | Complete external-brain object graph. | Upgrades existing nouns. | Object systems need durable nouns. | Use these in models/components; avoid generic CardData. |
| Primary objects | Reality Meridian + Start Here Surface, Direction Atlas, LifeShape Field, Motion Current, Personal Runtime / Trust object (internal: User System Profile), and global Placement Field (activated layer: Atmosphere Composer). | These define the product. | Direct canon preservation plus Motion IA migration plus relocked frontend maturity. | Dominant canvas/object pattern. | Each root must be built around its primary object; Placement Field is the Capture primary object; Atmosphere Composer is the activated Capture layer; Direction Atlas is the relocked Goals primary object. Constellation Atlas and Orbital Lens are source-compatibility only. |
| Supporting objects | Trust Seam, Receipt Surface, Quiet Reflow, Orbital Lens, Continuity Dock, Context Crown, Meridian Edge. | Shared primitives create coherence. | Continuity canon. | Premium apps reuse primitives obsessively. | Do not create one-off trust/receipt/dock variants. |
| Persistent objects | Continuity Dock, Context Crown, Trust Seam, active Step/Day state, receipts. | Keeps orientation across surfaces. | Continuity Layer. | Benchmarks maintain context while drilling. | Active context must travel without becoming notification spam. |
| Transforming objects | Capture → Step/Goal/Held; Step → Closure/Receipt; Goal Thread → Recommended Step; Time Block → Open/Protected/Pressure. | Makes Ambitions feel alive. | Route reveal/reflow canon. | Benchmarks transform objects, not pages. | Model transformations explicitly. |
| Detail views | Step, Goal Thread, Life Area, Capture Item, Time Block, Receipt, Proof, Personal Runtime. | Supports depth without sprawl. | Existing drill-down direction. | Deep object canvases. | Detail view must preserve origin and return path. |
| Receipts | Step actions, plan changes, capture placement, goal-thread connections, automation changes, source failures. | Proof builds trust. | Receipt Policy. | State/history proof. | Meaningful action leaves receipt. |
| Closure objects | Steps, Day, Recovery Thread, Pivot, Waiting/Blocked states. | Closure replaces overdue. | Action Closure canon. | Better than streak failure. | No overdue/failure language. |
| Proof objects | Goals, Goal Threads, Steps, Pivots, Receipts. | Supports long-range confidence. | Proof Transfers. | Durable history retains value. | Proof must be inspectable, not decorative. |
| Capacity logic | Step, Day, Time Block, LifeShape, Start Here, Recovery Thread. | Recommendations need fit. | LifeShape/Reality Meridian. | Current-state apps show constraints. | Show visible time-fit/capacity reason when recommending. |
| Learning objects | Personal Context, Planning Defaults, Closure History, Capture Patterns, Goal Thread History. | Personalization requires stable data. | Personal Runtime. | Apps learn through repeated object use. | Learning must be local and controllable. |
| Future portability | Day, Step, Start Here, Receipt, Time Block, Goal Thread. | Enables widgets/watch/live surfaces later. | Object architecture. | Live Activity analogy. | Build objects independent of screen-only UI. |
| Today model | Reality Meridian owns day state; Start Here emerges from active node. | Flagship daily object. | Strong canon. | Live object with current state. | Today cannot become task list/calendar timeline. |
| Goals model | Equal-weight Direction Atlas with Direction Lens / Thread Focus drill-down. Constellation relationship layer is a visual/anatomy layer only. | Avoids ranking life areas. | Strong canon plus relocked frontend maturity. Constellation Atlas / Orbital Lens may remain internal/source compatibility names until migration. | Object graph plus focused detail. | No KPI dashboard, rings, ranked life score, decorative constellation, astrology map, or generic goals list. |
| Capture model | Global Placement Field + Atmosphere Composer activated layer + Open Field atmosphere; contextual surface-native entry points primary, quiet toolbar Capture fallback, bottom composer seam only after activation. Input becomes local Held Object. Route actions appear around Held Object. Correction Fold updates route and local learning. Meaningful placement leaves Receipt. | Reduces friction without spending a tab. | Strong canon plus Motion IA migration plus relocked frontend maturity. | Input object transforms after capture. | Capture is not a tab; no persistent floating Capture button; no notes feed, inbox, chat transcript, category grid, top-level plus-tab behavior, cloud classification requirement, or AI confidence language. |
| Time model | LifeShape Field shows Time Texture: pressure, cognitive load, physical energy, transition friction, protected time, recovery need, free-time quality, execution lanes, and goal load. | Time is capacity, not calendar. | Stronger than Plan. | Timeframe canvas pattern. | No calendar grid, free/busy language, productivity scoring, calendar-density score, AI scheduling score, or resource-allocation jargon as primary object. |
| Motion model | Motion Current is the returnable proof/progress/inspection surface. | Movement becomes inspectable without gamification. | Installs Motion as the approved fifth tab. | Durable progress objects retain value. | Motion is not analytics dashboard, activity feed, XP, score, streak, productivity report, generic progress chart, social timeline, dashboard card stack, or shame/guilt surface. |
| You model | User System Profile controls context, planning, trust, automation, privacy, personalization. | System control must be inspectable. | Strong canon. | Native settings clarity. | No social/admin/AI settings wall. |
| Replacement names | Keep tab labels; screen titles: Start Here, Your Direction, Shape Time, Motion Current, Your System; Capture Anything belongs to activated global Capture. | Plain tabs, expressive titles. | Vocabulary canon. | Simple root labels aid retention. | No compatibility names in active UI; Pulse is historical only. |
| Plan status | Plan does not return as tab; plan remains contextual action. | Eliminates drift and calendar-clone risk. | Newer canon says Time. | Capacity object is stronger. | Hard red if Plan appears in tab bar. |
| Start Here | Keep flagship object; never detached card. | Best daily decision surface. | Strong canon. | Persistent action layer. | Must be tied to Reality Meridian. |
| Reality Meridian | Keep central to Today; DayTimelineRail is not active term. | Proprietary and less generic. | Vocabulary purge. | Live-state spine. | Use Reality Meridian, not DayTimelineRail/Rail. |
| LifeShape | Keep LifeShape Field as Time primitive. | Distinct from calendar. | Strong canon. | Timeframe canvas. | No LifeShape Map legacy term. |
| Horizons without clutter | Scope control + drill-down + object summaries. | Deep but narrow. | Time canon. | Progressive disclosure. | Do not show all horizon data at once. |
| Persistent context | Shell carries Context Crown, Dock, Trust Seam, active state, object-origin transitions. | Orientation without banners. | Continuity Layer. | Benchmarks preserve context. | No badges, random notification counts, or assistant bubbles. |
| Recommendation | Recommended step must show source, reason, fit, control, uncertainty, receipt behavior. | Trustworthy and actionable. | Recommendation Contract. | Current-state apps ground action in data. | No generic AI suggestion cards. |
| Local intelligence | Intelligence appears through fit, reflow, routing, closure, proof. | Keeps product local and native. | Trust canon. | Apps feel intelligent through state. | No chatbot-first intelligence. |
| Trust | Trust Seam owns explanation depth. | Keeps screens dense but clean. | Strong canon. | Progressive disclosure. | Adaptive action routes to Trust Seam/equivalent. |
| Receipts | Calm proof mark, peek, open, archive; object-local 7 days or until superseded. | Proof without noise. | Receipt Policy. | History/state proof. | Receipts are not notifications, badges, or feed items. |
| Proof | Proof records meaningful progress and supports pivots. | Long-range confidence. | Proof Transfers. | Durable history. | Proof must affect future context only when inspectable. |
| Closure | Completed, Still Counts, Moved, Shortened, Waiting, Blocked, Not Needed, Needs Recovery, Needs Review, Held. | Reality-based and non-shaming. | Closure canon. | Avoid gamified failure. | Replace overdue with closure prompts. |
| Recovery | Recovery is normal, calm, lighter-plan oriented. | Supports actual life. | Recovery canon. | Better than streak pressure. | No “get back on track.” |
| Still Counts | Partial progress is valid closure with receipt. | Reduces abandonment. | Strong canon. | Completion systems need nuance. | Treat as real state, not consolation. |
| State model | Empty, manual, source available/unavailable/stale, active, pressure, protected, waiting, blocked, recovery, receipt, low confidence. | Makes UI deep. | Specs require states. | Benchmarks are state-rich. | Every object must implement non-happy paths. |
| Personal learning | Learn from closures, deferrals, durations, active times, capture corrections, protected time, accepted/rejected recommendations. | Useful and deterministic. | Planning Defaults/Personal Runtime. | Object history drives personalization. | Never learn silently without inspection/reset. |
| Completion maximization | Improve fit, reduce friction, preserve progress, reflow with consent. | Better than motivation. | Start Here + Quiet Reflow. | High-retention apps reduce decisions. | No guilt-based engagement loops. |
| Pivoting | Pivot keeps proof where valid, explains change, previews new path. | Life changes; proof should survive. | Proof Transfers. | State transition quality. | No destructive pivot without receipt/control. |
| Density | High-density but not wide. | Powerful and calm. | Luxury restraint budget. | Benchmarks are deep inside objects. | Add density inside primitives, not more tabs/cards. |
| Progressive disclosure | Top-level summary/action; depth via object tap, seam, sheet, detail. | Supports glance and power use. | Signature object model. | Benchmark pattern. | Do not expose all metadata at rest. |
| Current-state awareness | Today and Time feel aware of now, fit, source, pressure, protected time. | Makes product alive. | Reality Meridian/Time. | Real/Flighty/FotMob lessons. | Alive means state, not animation. |
| Live/pseudo-live UI | Use local timers, schedule changes, active step states, receipts; avoid fake realtime theater. | Useful without server. | Motion canon. | Live apps show meaningful current state. | Continuous animation only for genuinely live state. |
| Interaction primitives | Tap, expand, scrub horizon, open detail, resolve closure, peek receipt, open Trust Seam. | Mature interaction vocabulary. | Existing object specs. | Repeated interactions. | No random gesture per component. |
| Sheets/drawers/detail | Sheets for focused decisions; seams for trust; details for object depth. | Preserves top-level calm. | Trust Seam/Quiet Reflow. | Progressive drill-down. | No modal stack chaos. |
| Motion | Clarify origin, state, relationship, proof, reflow. | Motion does product work. | Motion canon. | Polished apps use state continuity. | No decorative particles, scans, bounce, or parallax gimmicks. |
| Haptics | Soft commit, light confirmation, minimal selection, boundary haptics. | Native and restrained. | Haptics canon. | Premium iOS feel. | Haptics never sole confirmation. |
| Gestures | Native gestures first; custom only discoverable and redundant. | Accessibility and iOS trust. | Native iPhone canon. | Best custom apps still feel native. | No hidden gesture required for primary action. |
| Feedback | Immediate, calm, receipt-backed. | User trusts changes. | Receipt Policy. | Transactional apps confirm state. | No badges/celebrations/confetti. |
| Deep not crowded | Object summaries, local expansion, compact labels, horizon controls, Trust Seam, receipts. | Density with restraint. | Luxury restraint. | Benchmark depth. | Top-level max three visible modules. |
| Visual style | Native graphite, warm dark luxury, restrained celestial orientation, precise luminous traces. | Premium and distinct. | Materials canon. | Avoids copying aesthetics. | No random gradients, fantasy space, neon HUD, generic glassmorphism. |
| Apple-native | Safe areas, SF typography, native navigation, platform motion, touch targets, accessibility APIs. | iPhone believability. | Strong repo canon. | Native-first polish. | If custom control feels non-iOS, repair. |
| Celestial role | Orientation, continuity, relationship, atmosphere only. | Keeps vibe functional. | Celestial means orientation. | Visuals must do product work. | Decorative stars are hard red. |
| Materials | Celestial Field, Graphite Recess, Luminous Trace, Quiet Glass. | Cohesive primitives. | Existing material canon. | Primitive reuse. | Use consistently; no one-off surfaces. |
| Color/contrast | Dark graphite base, restrained accents, contrast-first, no color-only state. | Premium and accessible. | Contrast canon. | Data-rich apps need hierarchy. | Color is secondary state channel. |
| Typography | SF-first, semantic Dynamic Type, compact readable hierarchy. | Native and accessible. | Accessibility canon. | Dense apps require legibility. | No tiny fake-premium metadata. |
| Spacing | Dense but breathable; thumb-zone actions; safe-area aware. | Premium iPhone feel. | Native shell rules. | Tight spatial systems. | No cramped dashboard grid. |
| Layout hierarchy | Primary object > primary action > source/trust > secondary metadata. | Prevents clutter. | One-primary-object law. | Benchmark clarity. | No equal-weight module stacks. |
| Iconography | SF Symbols where possible; custom only for proprietary semantic objects. | Native consistency. | Native canon. | Avoid icon soup. | Icons cannot carry meaning alone. |
| Data visualization | Abstract capacity/proof/state visuals only when tied to object meaning. | Avoid dashboard decoration. | LifeShape canon. | Chart works only when chart is object. | No chart unless user can act on it. |
| Non-ideal states | Empty/loading/error/recovery are calm, useful, manual-first, source-aware. | Prevents broken-feeling app. | Specs require states. | Resilience lesson. | Every primary object has these states. |
| Visual personalization | Accent, density preference, life-area order, protected time, defaults; never random themes. | Personal but coherent. | User control canon. | Object graphs beat skins. | Personalization cannot break identity. |
| Dynamic Type | Preserve primary object, action, trust path, closure path. | Accessibility is architecture. | Direct canon. | Data-rich apps must scale. | Never preserve visuals at expense of text/action. |
| VoiceOver | Object-level summaries and semantic grouping required. | Nonvisual equivalence. | Direct canon. | Dense products need semantics. | No visual-only Reality Meridian/LifeShape/Atlas meaning. |
| Reduce Motion | Static origin/state/before-after equivalents. | Meaning survives. | Direct canon. | Premium accessibility. | Motion cannot be only relationship cue. |
| Increase Contrast | Strengthen boundaries, reduce atmosphere, preserve state distinctions. | Readability first. | Direct canon. | Premium dark UI requires discipline. | No low-contrast graphite-on-graphite controls. |
| Tap targets | 44 pt minimum, 48 pt preferred primary; expanded hit areas. | Usable on iPhone. | Direct canon. | Dense apps need forgiving touch. | No precision tapping on nodes/traces. |
| Cognitive load | One question per screen, one primary action, explanation behind seam. | Calm does not mean shallow. | Direct canon. | Focused root surfaces. | No competing CTAs or AI prose dumps. |
| Non-shaming language | Reality changed, Still counts, Needs recovery, Waiting, Blocked, Not needed. | Supports real life. | Vocabulary canon. | Avoids streak/gamification harm. | Ban failed, overdue, streak broken, productivity dropped. |
| Accessibility guardrail | Primary object incomplete until VoiceOver, Dynamic Type, Reduce Motion, contrast, tap targets work. | Accessibility gates implementation. | Direct canon. | Premium apps cannot be visual-only. | Create preview/test fixtures for accessibility states. |
| Anti-generic UI | Proprietary objects only; no template productivity UI. | Protects differentiation. | Anti-drift rules. | Benchmarks feel custom because objects are specific. | If UI works unchanged for any task app, fail. |
| Anti-dashboard | No metric tile grids, KPI panels, score cards. | Ambitions is personal OS, not SaaS. | Hard red. | Dense detail is not generic dashboard. | Data lives inside objects. |
| Anti-card-stack | No vertical pile of rounded cards as top-level surface. | User has repeatedly rejected card feel. | Strong canon. | Top apps use object canvases. | Card may be subordinate only, never surface structure. |
| Anti-chatbot | No assistant tab, chat transcript, AI prompt wall. | Local intelligence is behavior. | Trust canon. | Benchmarks do not need chat to feel smart. | Chat UI cannot be primary interaction. |
| Anti-calendar-clone | Time is capacity field, not calendar grid. | Differentiates from Calendar. | LifeShape canon. | Timeframe/canvas depth. | Calendar is source/detail, not root visual model. |
| Anti-gamification | No streaks, badges, leaderboards, XP, life scores, productivity scores. | Non-shaming premium. | Existing hard reds. | Do not copy social/fantasy mechanics. | Motion/progress proof is not game reward. |
| Anti-social-feed | No follows, comments, public sharing, karma, leaderboards. | Personal external brain. | Non-goals. | Social depth is not Ambitions-native. | Proof/history are private. |
| Anti-corporate-command | Executive clarity, not admin console. | Keeps personal and premium. | Existing canon. | Density cannot become enterprise UI. | No tables/control panels as primary UI. |
| Anti-cloud-AI | No external LLM dependency, AI labels, model confidence, GPT-like UI. | Required privacy/product rule. | Locked principle. | Intelligence can be local state. | Core must run without cloud AI. |
| Anti-hosted-backend | No custom hosted account or server-side user profiling. | Prevents architecture drift. | User constraint. | Local object graph is enough. | Do not introduce auth/backend assumptions. |
| Terms to use | Start here, Recommended step, Shape Time, Still counts, Needs a Place, Receipt, Source, Why this?, Trust & Automation, Personal Runtime. | Mature language system. | Vocabulary canon. | Specific language builds identity. | Use canonical terms only in UI/canon. |
| Terms to avoid | Dashboard, Assistant, AI recommends, best next move, overdue, failed, streak, score, optimize, smart capture, Plan tab, Profile tab, DayTimelineRail, Hero Step Panel. | Blocks drift. | Vocabulary purge. | Avoid benchmark contamination. | Lint docs/UI for banned active terms. |
| Primitive library | Build reusable primitives for shells, seams, receipts, closure controls, horizon controls, source labels. | Prevents one-off frontend. | Signature Interface Architecture. | Benchmarks reuse primitives. | No duplicated custom components for same behavior. |
| Performance | Native responsiveness beats visual richness; reduce atmosphere before content. | Premium requires speed. | Performance canon. | Data-rich apps are fast. | Blur/glow/motion degrade safely. |
| Preview fixtures | Every primary object requires state fixtures. | Codex needs evidence. | Existing fixture lists. | Mature apps handle edge states. | No object implementation without fixtures. |
| Old-canon migration | This file supersedes scattered canon; old names allowed only in migration notes. | Prevents drift. | Vocabulary purge. | Consistency creates quality. | Codex must not revive legacy terms. |
| Implementation claim safety | Design truth does not prove implementation, tests, accessibility, performance, release readiness. | Avoids false confidence. | Repo docs already say docs-only. | Mature teams separate spec from proof. | No Green/release claims without evidence. |
| Final Codex posture | Build Ambitions as an object-first native iPhone product, not a collection of screens. | Core decision. | Consolidates canon. | Direct benchmark translation. | Every PR must answer: object, state, source, interaction, accessibility, anti-drift. |

---

## 2. Purpose and Authority

This file is the active product/design truth for Ambitions.

It defines what Ambitions is, what it is not, how the product is structured, which objects matter, how intelligence appears, how the interface behaves, and what Codex must not drift into while implementing the native iPhone frontend.

This file is authoritative for product and design direction. It does not prove that the app is implemented, accessible, performant, tested, production-ready, App Store-ready, or release-ready.

Where older Ambitions documents conflict with this file, this file wins.

Where older Ambitions documents contain stronger detail that does not conflict with this file, they may be used as supporting material.

Where older Ambitions documents use compatibility names, obsolete tab names, old visual concepts, or implementation-shaped assumptions, those names and assumptions are superseded.

Central implementation rule:

```text
Ambitions is an object-first native iPhone product, not a page-first productivity app.
```

---

## 3. Product Identity

Ambitions is a premium iPhone-first, local-first external brain and personal life operating system.

It helps the user organize, understand, plan, adjust, and improve life across daily, weekly, monthly, yearly, and long-range horizons.

Ambitions is broader than a long-term goal executor. Long-term goals are one major layer, but the product also manages daily reality, commitments, ideas, routines, pivots, recovery, proof, planning defaults, personal growth, and changing constraints.

Canonical product sentence:

```text
Ambitions is a premium iPhone-first, local-first external brain and personal life operating system for organizing life, shaping time, grounding goals in daily reality, adapting plans when life changes, and helping the user make meaningful progress through calm, personalized, inspectable, non-shaming support.
```

## 3b. Moat Strategy Alignment

Ambitions’ moat is a durable local graph, not a general productivity workflow.

Canonical moat hierarchy:

```text
Identity Direction
  -> Life Area
    -> Ambition
      -> Outcome
        -> Goal Thread
          -> Commitment
            -> Step
              -> Closure Event
                -> Proof
                  -> Reflection
                    -> Adaptation / Recovery
```

Proof is the retention engine.

- Progress should be validated by proof, not just completion.
- Recovery is a normal, first-class path.
- Recommendation explainability must include source, reason, uncertainty, control options, and receipt behavior.
- User control is explicit in You through Trust & Automation, Privacy, Receipts & History, and Planning Setup.

Hard Red moat failures:

- Plan as a top-level tab.
- User-facing sixth tab.
- task app/card-stack/dashboard/task-list or calendar-clone behavior.
- Shame language in closure (`overdue`, `failed`, `streak broken`, `productivity dropped`).
- hidden recommendation behavior without source and control.
- explicit external/cloud LLM or custom hosted personal-data backend as a core core dependency.

Short product thesis:

```text
Ambitions helps life make sense, then helps the user start what fits.
```

Operational spine:

```text
Today gives action.
Goals give direction.
Time gives capacity.
Motion gives movement.
You gives context.
Capture gives input.
```

Current IA law:

```text
Today is now. Goals is direction. Time is capacity. Motion is movement. You is context. Capture is input.
```

Current active top-level IA:

```text
Today / Goals / Time / Motion / You
```

Current active global action:

```text
Capture
```

The superseded prior IA, `Today / Goals / Capture / Time / You`, may appear only as stale current repo/source state, historical context, a migration target, or superseded prior canon. It is not active product truth.

Pulse is a prior working name and historical context only. Motion replaces Pulse as the approved fifth tab name.

Product flexibility law:

```text
One private life runtime. Many valid use cases.
```

Thin/deep use law:

Users should receive value without understanding the whole system. Thin use supports scheduling, reminders, chores, time blocks, basic planning, daily Steps, basic goals, basic proof, basic closure, Start Here, basic Time quality, and Capture routing. Deep use grows into long-term goals, path simulation, proof trails, Time-quality modeling, advanced recovery, automation, and life-area development.

Retention law:

Ambitions should become integral through trust, familiarity, visible life movement, and recovery without shame, not forced screen time.

Monetization law:

```text
Free gets the Ambitions loop.
Paid gets the Ambitions engine at scale.
```

The core loop, basic recovery, basic proof, basic privacy, and global Capture stay free.

---

## 4. Product Promise

Ambitions promises to help the user:

1. Capture scattered life inputs without pressure.
2. Give important inputs a place.
3. Understand what life can actually hold.
4. Connect long-range direction to daily execution.
5. Start with the step that fits current reality.
6. Adjust when reality changes.
7. Close loops without shame.
8. Preserve proof of progress.
9. Learn local patterns over time.
10. Stay in control of how the system helps.

Ambitions does not promise perfect productivity, automatic life optimization, AI coaching, total automation, or frictionless self-improvement.

Ambitions promises a calmer, more truthful relationship between intention and reality.

---

## 5. Product Quality Bar

The quality bar is market-leading flagship iPhone product quality.

Ambitions should feel comparable in quality tier to the strongest modern iPhone apps: narrow IA, deep object detail, durable primitives, responsive interaction, high information density, polished motion, strong offline/local behavior, stateful product memory, and clear drill-down.

The target quality is not a pretty prototype. It is a product system that could plausibly be built by a senior Apple / OpenAI / Meta / top-FAANG product-design team.

A screen is not complete because it compiles.

A surface is complete only when it proves:

- clear product purpose
- one dominant product object
- real state depth
- useful empty/loading/error/recovery states
- accessible nonvisual meaning
- native interaction behavior
- source/trust behavior where relevant
- no old-canon drift
- no generic productivity UI
- no release or production claims without evidence

---

## 6. Benchmark Translation

The benchmark apps are compelling because they are object systems, not page systems.

They use:

- small durable product nouns
- persistent context
- current-state awareness
- reusable primitives
- progressive disclosure
- motion that clarifies state
- deep drill-down inside narrow IA
- performance-conscious data presentation
- object transformations instead of disconnected pages

Ambitions must translate that into its own object system.

Ambitions should not copy:

- sports data presentation
- betting mechanics
- odds cells
- social feeds
- leaderboards
- fantasy mechanics
- sportsbook urgency
- monetization loops
- health-score visuals as decoration
- charting conventions as decoration
- travel-alert styling
- benchmark app aesthetics
- benchmark technical stacks as product truth

Ambitions-native benchmark laws:

1. Narrow root IA beats broad feature spread.
2. Deep objects beat many pages.
3. A current-state object is more valuable than a dashboard.
4. A persistent action context is more useful than a notification feed.
5. State changes need visible continuity.
6. Motion should explain where an object came from, what changed, and what can happen next.
7. Density belongs inside objects, not across many unrelated modules.
8. Personalization should emerge from object history, not decorative theming.
9. Trust must be inspectable.
10. No benchmark mechanic is adopted unless it becomes Ambitions-native.

---

## 7. Visual / Product Direction

Canonical thesis:

```text
Quiet Object Instruments under a North Star Field
```

Canon sentence:

```text
Ambitions is a calm native life OS made of tactile personal instruments, held inside a private North Star field: every surface helps the user orient, place, shape, start, prove, recover, and keep moving toward what matters.
```

### Priority stack

1. Object state
2. Native iPhone restraint
3. Tactile instrument clarity
4. Inspectable local runtime trust
5. North Star / celestial orientation
6. Atmospheric depth

Every visual decision must be evaluated against this stack in order. Object state and native restraint always outweigh atmosphere and celestial flavor.

### North Star Field law

Celestial flavor may appear throughout Ambitions when it expresses:

- orientation
- aspiration
- relationship
- horizon
- proof
- route
- current-state awareness
- safe placement

Celestial flavor may not exist as:

- wallpaper
- spectacle
- decoration
- celebration
- theme skin

### Celestial intensity design targets

| Level | Role | Where |
|---|---|---|
| Dust | root rest, dense states, You top object | rest-state surfaces, dense readings, Personal Runtime / Trust object |
| Compass | orientation | Today, Time, Motion orientation |
| Constellation | selected relationships | Goals selected relationships |
| North Star | major direction, proof, horizon, selected ambition | contextual major direction, proof, horizon, selected ambition |
| Open Field | activated Capture only | activated Capture atmosphere mode |

### Hard red celestial failures

- decorative stars
- astrology reading
- fantasy space art
- sci-fi HUD
- neon identity
- particle spectacle
- shooting-star celebration/gamification
- visual-only meaning

Ambitions may feel intelligent, but it must not perform AI branding. The visual system serves object state, not atmosphere.

---

## 8. Daily Use Feel

At rest, Ambitions should feel:

```text
calm
premium
human
stateful
private
organized
quietly alive
```

During active use, it should feel:

```text
decisive
specific
grounded
easy to adjust
```

During recovery, it should feel:

```text
non-shaming
practical
lighter
still worth continuing
```

During planning, it should feel:

```text
realistic
capacity-aware
editable
source-aware
```

During review, it should feel:

```text
proof-based
calm
useful
not judgmental
```

Daily feel target:

```text
Warmer than Apple.
Calmer than Real.
Less aggressive than DraftKings.
More personal than a calendar.
More grounded than a goal app.
More structured than notes.
More trustworthy than a chatbot.
```

---

## 9. Local-Only Product Architecture

Ambitions core product is local-first and local-only.

Core user data must live on-device by default, including:

- goals
- life areas
- captures
- held items
- planning defaults
- schedule assumptions
- protected time
- closure history
- receipts
- proof
- pivots
- recovery history
- personalization
- personal context
- recommendation history
- user-specific learning

### Apple account / iCloud-style sync exception

Ambitions may use Apple-native account/iCloud-style syncing for user-owned cross-device sync.

Rules:

- Sync is for the user’s own devices.
- Sync must feel Apple-native, private, and user-owned.
- Sync must not require a custom hosted Ambitions account.
- Sync must not become server-side user profiling.
- Sync must not be required for basic product value.

### Cloudflare R2 freshness-data exception

Ambitions may use Cloudflare R2 for read-only public freshness/reference data.

Allowed R2 data:

- public dates
- public deadlines
- regulations
- rules
- public requirements
- public templates
- public reference packs
- non-user-personal planning metadata

R2 must never receive:

- goals
- captures
- calendar data
- schedule assumptions
- life areas
- receipts
- proof
- closure history
- personalization data
- behavioral patterns
- inferred priorities
- private user context
- any user-identifying life graph

R2 is not a personal backend.

### External/cloud LLM exclusion

External/cloud LLMs are not part of Ambitions core architecture.

Core intelligence must be:

- local-first
- deterministic
- inspectable
- user-controlled
- expressed through product behavior
- testable without external AI services

Optional future AI/cloud/extension behavior must remain outside core product truth unless explicitly scoped later.

Hard red:

```text
No core Ambitions feature may require an external LLM, hosted AI service, custom hosted user account, server-side user profiling, or cloud personal-data backend.
```

### Third-party dependency posture

Ambitions is Apple-native and repo-owned first.

Dev, test, and build tools require dedicated issue-level install approval.

New runtime dependencies require separate explicit approval.

The following are not approved by default:

- analytics SDKs
- telemetry SDKs
- crash reporting SDKs
- cloud model SDKs
- backend SDKs
- sync SDKs outside Apple-native continuity
- payment SDKs beyond StoreKit
- UI libraries that replace native SwiftUI/product-owned primitives
- cross-platform app frameworks
- remote config SDKs
- visual animation SDKs
- calendar automation SDKs

### Diagnostics posture

Diagnostics are Apple-first only for now.

Allowed diagnostic evidence and tooling:

- MetricKit
- os.Logger
- signposts
- TestFlight crash reports when a gated TestFlight path is approved
- Xcode crash reports
- local diagnostic bundles
- user-initiated support export

No third-party telemetry, crash, or analytics SDK is approved.

---

## 10. Top-Level IA

Final top-level IA:

```text
Today
Goals
Time
Motion
You
```

No other top-level tabs are allowed.

Global action:

```text
Capture
```

Capture is always available, but it is not a tab.

Capture is the global action layer. The primary Capture object is the Placement Field. The activated Capture layer is the Atmosphere Composer. The activated Capture atmosphere mode is the Open Field.

Capture access model:

1. Contextual surface-native entry points are primary.
2. A quiet toolbar Capture action is the consistent fallback.
3. A bottom composer seam appears only after Capture is activated.
4. No persistent floating Capture button.

Motion replaces Pulse as the approved fifth tab name.

Pulse is prior working-name / historical context only and must not be presented as current product truth.

Plan is not a top-level tab.

Plan may appear only as contextual language:

- Adjust plan
- Shape week
- Review pressure
- Plan adjusted
- Planning Defaults

Hard red top-level destinations:

- Plan
- Capture
- Dashboard
- Mission Control
- Assistant
- AI
- Chat
- Calendar
- Inbox
- Captures
- Habits
- Insights
- Review
- Profile
- Settings
- any sixth tab

### Surface roles

| Top-level surface | Screen title | Product role | Primary object | Relocked anatomy | Question answered |
|---|---|---|---|---|---|
| Today | Start Here | action now | Reality Meridian + Start Here Surface | Day Compass clarity + Current Instrument tactility | What should I start with now? |
| Goals | Your Direction | meaning / direction | Direction Atlas | Constellation relationship layer + Direction Lens / Thread Focus | What is my life pointed at? |
| Time | Shape Time | capacity | LifeShape Field | capacity terrain + instrument readings + Preview Reflow | What can my life actually hold? |
| Motion | Motion Current | movement / proof / inspection | Motion Current | braided Proof / Recovery / Re-entry current | What moved, what has proof, and what can re-enter? |
| You | Your System | context / control | Personal Runtime / Trust object | native grouped settings shell with one dominant Personal Runtime / Trust object | How does Ambitions work for me? |

Goals compatibility note: Constellation Atlas / Orbital Lens may remain implementation/source compatibility names until migration, but the active relocked product object is Direction Atlas.

You compatibility note: User System Profile remains the internal/source compatibility data-model name.

| Global action | Activated title | Product role | Primary object | Activated layer | Relocked anatomy | Route states | Question answered |
|---|---|---|---|---|---|---|---|
| Capture | Capture Anything | input / safe placement | Placement Field | Atmosphere Composer | Open Field atmosphere + bottom composer seam + Held Object route transformation | Needs a Place, Ready to Place, Grow into Goal, Held for Review | Where can I safely put this? |

### One question per surface

| Surface | Question answered |
|---|---|
| Today | What should I start with now? |
| Goals | What is my life pointed at? |
| Time | What can my life actually hold? |
| Motion | What moved, what has proof, and what can re-enter? |
| You | How does Ambitions work for me? |
| Capture | Where can I safely put this? |

---

## 11. Core Product Objects

Ambitions must be built around durable product nouns.

### Domain objects

- Day
- Step
- Goal
- Goal Thread
- Life Area
- Capture Item
- Held Item
- Time Block
- Protected Block
- Planning Horizon
- LifeShape
- Closure Event
- Receipt
- Proof
- Pivot
- Recovery Thread
- Personal Context
- Planning Default
- User System Profile
- Source
- Local Inference

### Signature interface objects

Active / relocked objects:

- Runtime Root Shell / AmbitionsShell product concept
- Context Crown
- Continuity Dock
- Meridian Edge
- Trust Seam
- Receipt Surface
- Quiet Reflow
- Reality Meridian
- Start Here Surface
- Day Compass anatomy
- Direction Atlas
- Constellation relationship layer
- Direction Lens
- Thread Focus
- LifeShape Field
- Motion Current
- Personal Runtime / Trust object
- User System Profile (internal/source compatibility data-model object)
- Placement Field
- Atmosphere Composer (activated Capture layer)
- Open Field (activated Capture atmosphere mode)

Compatibility note: AmbitionsShell is a product shell concept. Do not infer that AppMeridianShell.swift is the runtime root. Packet 0R verified runtime root as AmbitionsApp → LaunchGateView → AmbitionsRootView → SwiftUI TabView. AppMeridianShell.swift is not runtime root in the verified source state. Treat AppMeridianShell.swift as AppMeridianDestinationRail / preview / compatibility support unless later repo evidence proves otherwise.

Source compatibility objects (may remain in source until migration):

- Constellation Atlas (source compatibility for Direction Atlas)
- Orbital Lens (source compatibility for Direction Lens / Thread Focus)

### Object transformation rules

Ambitions should feel alive because objects transform:

```text
Capture Item → Held Item / Step / Goal Thread
Goal Thread → Recommended Step
Step → Active Step / Closure Event / Receipt
Time Block → Open / Goal Time / Protected / Pressure
Day → Reality Meridian state
Closure Event → Proof
Pivot → Proof Transfer / Recovery Thread
Receipt → Trust history
Proof / Recovery / Change → Motion Current state
```

Codex must model these as transformations of durable objects, not disconnected view states.

---

## 12. Global Surface Model

Each top-level surface has one dominant object.

```text
TodayScreen = RuntimeRootShell + RealityMeridian + StartHereSurface + DayCompassAnatomy
GoalsScreen = RuntimeRootShell + DirectionAtlas + ConstellationRelationshipLayer + DirectionLensOrThreadFocus
TimeScreen = RuntimeRootShell + LifeShapeField
MotionScreen = RuntimeRootShell + MotionCurrent
YouScreen = RuntimeRootShell + PersonalRuntimeTrustObject + UserSystemProfileDataModel
Activated Capture = RuntimeRootShell + PlacementField + AtmosphereComposerLayer + OpenField + HeldObjectRouteTransformation
```

RuntimeRootShell refers to the verified runtime shell chain (AmbitionsApp → LaunchGateView → AmbitionsRootView → SwiftUI TabView), not a required concrete type name.

Current source-state boundary:

The live repo/source may still contain the superseded prior IA (`Today / Goals / Capture / Time / You`), `CaptureScreen` as a route, `ConstellationAtlas`, `OrbitalLens`, and `AmbitionsShell` as type names while the relocked migration is not yet implemented. That is stale current source state, not active product truth, and this file does not claim the source has migrated.

A top-level surface fails if it is primarily:

- a stack of cards
- a dashboard
- a feed
- a grid of widgets
- a generic list
- a calendar clone
- a chat screen
- a settings dump
- a visual concept with no state

At rest, a top-level surface may show:

- 1 primary object
- 1 primary action
- 1 accent/state system
- 1 active proof/receipt
- 1 open trust explanation maximum
- 3 visible modules maximum

At rest, a top-level surface may not show:

- badges
- score widgets
- decorative stars
- generic dashboard tiles
- competing CTAs
- AI prompts
- notification banners
- social feed elements

---

## 13. Navigation and Chrome

Ambitions uses a native iPhone shell with proprietary continuity.

Required chrome objects:

- Runtime Root Shell / AmbitionsShell product concept
- Context Crown
- Continuity Dock
- Meridian Edge
- Trust Seam
- Receipt Surface
- Quiet Reflow

### Shell behavior

Root shell is native and restrained at rest.

Root uses collapsed Crown essence.

Full Context Crown appears in drill-down, Trust Seam, Receipt Surface, Quiet Reflow, and activated Capture.

Continuity Dock may carry selected surface plus no more than two visible state hints total.

Meridian Edge is adaptive relationship trace, never the sole meaning channel.

Shell identity stack:

1. object-origin geometry
2. luminous relationship trace
3. quiet material depth
4. atmospheric field

Transition ladder:

1. native
2. trace
3. object-origin
4. reflow
5. full Capture stage

### Context Crown

A compact orientation line for current surface, depth, and one relevant context phrase.

It must not become a large header.

### Continuity Dock

The primary tab/navigation dock.

It should feel native, premium, state-aware, and restrained. It may carry subtle state, but it must not become a badge bar, notification strip, or animated toy.

### Meridian Edge

A subtle continuity trace for current state and object relationship.

It may not be the only source of meaning.

### Trust Seam

The place where Ambitions explains why something happened.

Trust Seam owns:

- Why this?
- Source
- Reason
- Uncertainty
- User control
- Receipt behavior
- Undo/revert when available

Trust Seam must not become:

- chatbot drawer
- AI assistant panel
- long prose wall
- notification banner
- generic alert

### Drill-down

Drill-down must originate from objects.

Approved depth forms:

- object detail view
- focused sheet
- Trust Seam
- Receipt Surface
- Quiet Reflow preview
- horizon drill-down
- native grouped settings drill-down

Unapproved depth forms:

- arbitrary modal stack
- disconnected page
- random dashboard
- hidden admin screen
- generic chatbot detail

---

## 14. High-Density But Not Wide

Ambitions should be high-density but not wide.

This means:

```text
More state inside fewer objects.
More depth inside fewer surfaces.
More useful context inside fewer controls.
```

It does not mean:

```text
More cards.
More tabs.
More metrics.
More labels.
More widgets.
More visual noise.
```

Top-level density should come from:

- object state
- compact source labels
- current capacity
- active recommendation
- proof marks
- closure affordances
- horizon summaries
- meaningful traces
- progressive disclosure

Top-level density should not come from:

- dashboards
- KPI tiles
- scroll-heavy module stacks
- social feeds
- habit rings
- calendar grids
- generic task lists
- multi-card productivity pages

Implementation rule:

```text
Before adding a new visible module, ask which existing object should absorb that state.
```

---

## 15. Persistent Context Model

Ambitions must maintain orientation across the app.

Persistent context includes:

- current Day
- active Step
- active Goal Thread
- current Planning Horizon
- recent Receipt
- source state
- automation level
- protected time
- pressure state
- held Capture Items
- current closure needs

Persistent context appears through:

- Context Crown
- Continuity Dock
- Trust Seam
- Receipt Surface
- object-origin transitions
- source labels
- subtle Meridian Edge state

Persistent context must not appear through:

- red badges
- notification counts
- urgency banners
- assistant bubbles
- gamified streaks
- social alerts
- sportsbook-style live urgency

---

## 16. Planning Across Time Horizons

Ambitions plans across:

- Day
- Week
- Month
- Year
- Life Range

These are horizons, not top-level tabs.

### Day

Day is split between Today and Time.

Today owns:

- what fits now
- what comes next
- active step
- closure
- recovery

Time owns:

- day capacity
- conflicts
- protected time
- manual shaping
- pressure

### Week

Week is Time’s default planning horizon.

Week answers:

```text
What can this week actually hold?
```

### Month

Month shows life shape, milestones, pressure periods, protected blocks, and meaningful capacity patterns.

It must not become a generic month calendar grid.

### Year

Year is directional and reflective.

It shows:

- major life areas
- goal threads
- seasonal pressure
- proof accumulation
- pivot history
- long-range commitments

### Life Range

Life Range is not a roadmap dashboard.

It is a directional view of life areas, ambitions, proof, and major arcs.

Hard red:

```text
Do not create separate root surfaces for Day, Week, Month, Year, Review, or Calendar.
```

---

## 17. Personalization and Learning

Ambitions becomes unique to the user through local learning.

It may learn from:

- explicit planning defaults
- preferred step durations
- closure choices
- time-of-day completion patterns
- protected time
- recurring commitments
- capture routing corrections
- goal-thread activity
- frequent pivots
- blocked/waiting patterns
- manual adjustments
- accepted/rejected recommendations
- recovery behavior

It must not learn through:

- server-side profiling
- cloud AI inference
- hidden psychological scoring
- protected/sensitive identity inference
- manipulative engagement loops
- social comparison
- opaque productivity scoring

### Personal Runtime

Personal Runtime is the user-visible local personalization system.

It belongs inside You.

It must expose:

- what Ambitions has learned
- where it learned it from (sources)
- whether it is active
- affected recommendations
- how to edit it
- how to reset it
- how to pause it
- how to disable it

Personalization must be:

- local
- inspectable
- editable
- reversible
- privacy-preserving
- calm
- optional where sensitive

Hard red:

```text
No hidden personalization that materially affects recommendations.
```

---

## 18. Today Surface Truth

Today's purpose:

```text
Help the user start what fits now and close what reality changed.
```

Primary object:

```text
Reality Meridian + Start Here Surface
```

### Today anatomy

Reality Meridian remains the internal day-state object.

Day Compass is the anatomy: meridian spine inside a compass-like current-state field.

Current Instrument tactility appears when state complexity rises.

Start Here is attached beside the active node normally. Under Dynamic Type, accessibility, or complex state, Start Here may move to a lower thumb-zone action but must remain visibly, semantically, and accessibly tethered to the active node.

Root user-facing language should be plain state phrases:

```text
Start here
Fits now
Pressure soon
Protected now
Still counts
Needs closure
Reality changed
```

Today should show:

- Now
- Next
- Later
- active step
- recommended step
- time fit
- goal thread connection
- closure state
- source label
- Why this?
- receipt/proof mark
- recovery/reflow when needed

Today must not show:

- full task list
- overdue list
- calendar timeline
- productivity dashboard
- habit rings
- focus widget as primary object
- hero recommendation card
- detached Start Here card
- motivational quote
- AI suggestion card
- stack of cards

### Start Here

Start Here is not a card.

Start Here is the action expression of the active Reality Meridian node.

It must be:

- visually connected to the active node
- semantically connected to the active node
- accessible as part of Today’s current state
- limited to one primary action
- source-aware
- adjustable
- receipt-aware

Approved primary CTAs:

- Start now
- Open step
- Adjust plan
- Still counts

Approved secondary actions:

- Why this?
- Move this
- Shorten
- Waiting
- Blocked
- Not needed

Forbidden Today copy:

- Begin Focus
- best next move
- next best move
- overdue
- failed
- productivity dropped
- crush your goals
- optimize your day
- AI recommends

### Today states

Codex must support:

- empty day
- manual day
- no schedule connected
- now open
- recommended step
- active step live
- next soon
- pressure soon
- protected time active
- missed but recoverable
- Still Counts
- waiting
- blocked
- needs recovery
- needs review
- receipt available
- source unavailable
- trust explanation open
- reflow preview

---

## 19. Goals Surface Truth

Goals' purpose:

```text
Show what the user's life is pointed at without ranking their life for them.
```

Primary object:

```text
Direction Atlas
```

Compatibility note: Constellation Atlas / Orbital Lens may remain implementation/source compatibility names until migration, but the active relocked product object is Direction Atlas.

### Goals anatomy

Direction Atlas is the primary object.

Constellation relationship layer is a visual/anatomy layer only, not the primary object.

Life areas remain equal-weight by default.

Active Today-feeding threads may be visible at root.

Selected inspection may show relationship traces.

Direction Lens / Thread Focus matures or replaces Orbital Lens behavior. Orbital Lens may remain internal/source compatibility only until migration.

Root user-facing language should use plain state phrases:

```text
Your Direction
Feeds Today
Proof available
Recently moved
Needs recovery
Pinned area
```

Avoid showing Direction Atlas / Constellation Atlas / Orbital Lens as active root UI labels unless in onboarding/help/internal docs.

Default life areas:

- Music
- Fitness
- Money
- Relationships
- Career
- Health
- Learning
- Home
- Creative
- Personal Growth

User controls:

- reorder
- pin
- hide
- rename
- add
- archive
- connect to Today
- open goal thread

The system must never rank life areas by default.

Goals should show:

- equal-weight life areas
- selected area
- pinned area
- active goal threads
- threads feeding Today
- proof
- pivots
- source path
- user-owned order

Goals must not show:

- KPI dashboard
- ranked life score
- productivity score
- habit rings as primary language
- astrology map
- decorative constellation
- performance portfolio
- leaderboard
- social comparison
- generic list of goals as the entire surface
- non-data relationship traces

### Direction Lens / Thread Focus

Direction Lens / Thread Focus is the focused view into one life area. It matures or replaces Orbital Lens behavior.

It must preserve wider life context.

It may show:

- selected life area
- active goal threads
- next useful step
- proof
- related capture items
- thread connected to Today
- blocked/waiting/recovery states
- Why this?

## 20. Global Capture Truth

Capture's purpose:

```text
Give the user a quiet place to put anything before it needs structure.
```

Capture law:

```text
Capture is always available, but it is not a tab.
```

Activated title:

```text
Capture Anything
```

Primary object:

```text
Placement Field
```

Activated visual/composer layer:

```text
Atmosphere Composer
```

Open Field is the activated celestial atmosphere mode.

Capture is the global action layer, not a top-level destination. The primary Capture object is the Placement Field. Atmosphere Composer is the activated Capture layer.

Capture access model:

1. Contextual surface-native entry points are primary.
2. A quiet toolbar Capture action is the consistent fallback.
3. A bottom composer seam appears only after Capture is activated.
4. No persistent floating Capture button.

### Capture anatomy

Input becomes local Held Object.

Held Object remains central by default.

Route actions appear around Held Object.

High-confidence route may trace toward Step / Goal Thread / Held Item.

Low confidence saves first as Needs a Place.

Explicit choice moments may split Held Object into route choices.

Correction Fold updates route and local learning.

Meaningful placement leaves Receipt.

Capture should show:

- Open Field atmospheric surface
- concise title: Capture Anything
- quiet prompt
- bottom composer only in the activated state
- text field
- mic action
- add action
- local saved state
- route reveal after input
- Held Object with route actions

Capture must not show by default:

- top-level tab placement
- persistent floating Capture button
- notes feed
- inbox
- chat transcript
- category grid
- task board
- AI prompt wall
- automatic classification theater
- cloud classification requirement
- AI confidence language
- top-level plus-tab behavior

### Approved route states

- Needs a Place
- Ready to Place
- Grow into Goal
- Held for Review

### Classification rules

High confidence:

- show calm route choices
- expose Why this?
- allow user correction

Low confidence:

- save first
- label Needs a Place
- avoid pretending certainty
- allow later placement

Capture must be local-first.

A captured item must never require cloud classification.

### Capture states

Codex must support:

- empty quiet field
- typing
- dictating
- keyboard visible
- captured locally
- classifying locally
- high-confidence route reveal
- low-confidence Needs a Place
- Ready to Place
- Grow into Goal
- Held for Review
- save error
- source/trust explanation
- large text
- reduce motion

---

## 21. Motion Surface Truth

The fourth tab is Motion.

Screen title:

```text
Motion Current
```

Motion’s purpose:

```text
Give the user a returnable proof/progress/inspection surface for how ambitions are becoming real.
```

Primary object:

```text
Motion Current
```

Motion law:

```text
Motion is proof/progress/inspection.
```

### Motion anatomy

Motion Current is one braided current.

Strands:

- Proof
- Recovery
- Re-entry

Root stays calm/static.

Selected strand focuses on interaction.

One primary affordance at a time:

- Inspect proof
- Review recovery
- Re-enter
- Follow to Goals
- Follow to Today
- Follow source
- Peek receipt

Motion Current shows:

- what moved
- what has proof
- what recovered
- what stalled but can re-enter
- what changed
- what life areas are developing
- how ambitions are becoming real

Motion must not become:

- analytics dashboard
- activity feed
- XP
- score
- streak
- productivity report
- generic progress chart
- social timeline
- dashboard card stack
- shame/guilt surface

Pulse is a prior working name and historical context only. Pulse is not the current tab or active product truth.

Motion must preserve:

- source and receipt paths
- proof inspection
- recovery without shame
- re-entry for stalled work
- life-area development context
- local-first deterministic runtime behavior

## 21A. Time / Planning Surface Truth

The third tab is Time.

Screen title:

```text
Shape Time
```

Time’s purpose:

```text
Show what the user’s life can actually hold across planning horizons.
```

Primary object:

```text
LifeShape Field
```

Time law:

```text
Time is not empty space. Time has texture.
```

Time is LifeShape Field. It distinguishes availability from capacity.

Time Texture includes:

- pressure
- cognitive load
- physical energy
- transition friction
- protected time
- recovery need
- free-time quality
- execution lanes
- goal load

### Time anatomy

LifeShape Field is capacity terrain plus instrument readings.

Week is the default horizon.

Day / Week / Month are primary scope controls. Year / Life Range exist as drill-down.

Native controls first.

Direct manipulation only if redundant and accessible.

Preview Reflow is required before meaningful plan/capacity mutation.

Receipt is required after accepted meaningful change.

Normal Preview Reflow uses ghost preview over current terrain.

Reduce Motion / high Dynamic Type uses before/after panels or native confirmation sheet.

Time should show:

- Day / Week / Month scope
- Week by default
- open time
- goal time
- protected time
- pressure
- cognitive load
- physical energy
- transition friction
- recovery need
- free-time quality
- execution lanes
- goal load
- planning horizon
- reflow preview
- source state
- capacity truth
- shaping actions

Time may drill into Year and Life Range when needed.

Time must not show:

- generic calendar grid as primary UI
- free/busy calendar language as primary semantics
- agenda clone
- schedule dashboard
- KPI tiles
- heatmap-first analytics
- business charts
- productivity score
- calendar-density score
- AI scheduling score
- resource-allocation jargon
- red warning system

### Capacity language

Preferred pattern:

```text
This week can hold:
3 focused blocks
2 light steps
1 protected recovery window
```

### Time actions

Approved actions:

- Shape week
- Review pressure
- Adjust plan
- Protect this block
- Move this
- Shorten
- Open time
- Goal time

### Time states

Codex must support:

- week default
- day pressure
- month shaping
- year overview
- life range overview
- open capacity
- low capacity
- protected blocks
- pressure cluster
- source unavailable
- calendar denied
- calendar granted
- manual-only planning
- reflow preview
- plan adjusted receipt
- source conflict
- empty plan
- loading capacity
- error reading schedule

Calendar may support Time.

Calendar must not define Time.

---

## 22. You / Profile / System Surface Truth

The fifth tab is You.

Screen title:

```text
Your System
```

You’s purpose:

```text
Give the user control over how Ambitions plans, explains, remembers, personalizes, and asks.
```

Primary object:

```text
Personal Runtime / Trust object
```

Internal/source compatibility data-model name: User System Profile.

### You anatomy

Shell: native grouped settings.

Dense lists have no celestial atmosphere.

Top Personal Runtime / Trust object may use Dust-level field only.

You should feel closest to premium iOS Settings with one dominant Personal Runtime / Trust object.

Trust & Automation hub progressively contains:

- automation level
- Personal Runtime learning
- source permissions
- calendar state
- receipts/history
- privacy controls
- reset/disable controls

Required structure:

### Planning Setup

- Schedule & Availability
- Planning Defaults
- Vacation / Away Time
- Trust & Automation
- Personal Runtime

### Account & Preferences

- Notifications
- Capture Preferences
- Session Defaults
- Appearance
- Privacy

### History & Trust

- Receipts & History
- Proof
- Source Settings
- Local Data Controls

### Support / System

- Help
- About Ambitions

You must not become:

- social profile
- generic profile page
- family hub
- admin console
- AI settings wall
- dashboard
- search-first surface
- motivational identity page
- settings dump without dominant Personal Runtime / Trust object

### Trust & Automation

Must expose:

- current automation level
- what Ambitions can do
- source permissions
- calendar state
- recommendation behavior
- Preview Reflow setting
- approved defaults when later available
- receipt history
- privacy controls
- clear/reset controls

Launch automation levels:

1. Manual
2. Suggest
3. Preview Reflow

No higher automation level is core launch truth.

---

## 23. Action Closure Truth

Ambitions does not treat unfinished life as failure.

Closure replaces overdue.

Closure states:

- Completed
- Still Counts
- Moved
- Shortened
- Waiting
- Blocked
- Not Needed
- Needs Recovery
- Needs Review
- Held

Closure must be:

- calm
- reversible where appropriate
- receipt-backed
- source-aware when relevant
- accessible
- free of shame language

Forbidden closure language:

- failed
- overdue
- missed again
- streak broken
- productivity dropped
- get back on track
- you should have
- behind

Preferred closure language:

- Needs closure
- Still counts
- Reality changed
- Move this
- Make today lighter
- Waiting
- Blocked
- Not needed
- Review when ready

### Still Counts

Still Counts is a real closure state.

It applies when progress happened but does not match binary completion.

Still Counts should:

- validate partial progress
- preserve proof
- avoid consolation tone
- allow plan adjustment
- leave a receipt where meaningful

### Recovery

Recovery is normal.

Recovery should help the user reduce load, preserve what matters, and continue.

Recovery should not punish, shame, or dramatize.

---

## 24. Receipts, Proof, and Trust Truth

### Receipts

Receipts are calm proof that something meaningful happened.

Receipts are not:

- notifications
- achievements
- badges
- streaks
- feed items
- alerts

Receipt required when Ambitions:

- moves a step
- adjusts a plan
- places a capture
- marks Still Counts
- connects a goal thread
- preserves protected time
- changes automation settings
- applies user-approved defaults
- records a meaningful source unavailable state
- creates a pivot
- transfers proof

Every receipt includes:

- action taken
- affected object
- source when relevant
- time/reference
- inspect control
- undo/revert when available
- archive route when needed

Receipt levels:

- Compact
- Peek
- Open
- Archive

Recent object-local receipts remain visible for 7 days or until superseded, whichever is calmer.

Receipt archive lives in:

```text
You → Receipts & History
```

### Proof

Proof is durable evidence of progress, closure, pivot, or meaningful action.

Proof should support:

- goal threads
- pivots
- long-range direction
- recovery
- personal learning
- future recommendations

Proof must not become:

- points
- score
- streak
- public achievement
- leaderboard
- motivational badge

### Trust

Trust is earned through:

- source labels
- Why this?
- receipts
- preview before meaningful change
- user control
- undo/revert where possible
- permission clarity
- privacy restraint
- calm uncertainty language
- visible Trust & Automation controls

---

## 25. Intelligence and Local-First Product Truth

Ambitions intelligence is embedded product behavior.

It appears through:

- recommended step fit
- local routing
- source labels
- time-fit proof
- capacity awareness
- closure prompts
- recovery suggestions
- reflow previews
- proof transfers
- planning defaults
- local personalization
- Personal Runtime

It does not appear through:

- chatbot
- assistant persona
- AI coach
- AI suggestion cards
- model confidence
- cloud LLM calls
- GPT-like UI
- server-side profile
- opaque automation

Every recommendation must expose:

1. recommended action
2. reason
3. source category
4. uncertainty when relevant
5. user control
6. adjustment path
7. receipt behavior after meaningful action

Approved source labels:

- You entered
- Calendar
- Planning default
- Goal thread
- Recent capture
- Protected block
- Manual adjustment
- Automation setting
- Local inference
- Public reference

Forbidden source labels:

- AI knows
- Smart recommendation
- Optimized by Ambitions
- Best next move engine
- Productivity model
- Life score

---

## 26. State Model

Ambitions must be state-rich.

Every primary object must define:

- empty state
- loading state
- error state
- recovery state
- manual state
- source unavailable state
- source stale state
- low-confidence state
- active state
- completed state where relevant
- receipt state
- accessible summary

Global states include:

- Manual
- Suggest
- Preview Reflow
- Calendar not requested
- Calendar denied
- Calendar limited
- Calendar granted
- Calendar stale
- Source Needed
- Local-only
- Sync available
- Sync disabled
- R2 freshness available
- R2 freshness unavailable
- Protected
- Pressure
- Waiting
- Blocked
- Needs Recovery
- Needs Review
- Held

Hard red:

```text
No primary object may ship with only happy-path state.
```

---

## 27. Motion, Gestures, and Feedback

Motion signature:

```text
Object-to-trace-to-receipt continuity
```

Canon sequence:

1. tactile object-state transformation
2. object-origin movement
3. luminous relationship trace
4. QuietGlass / GraphiteRecess material settle
5. Trust Seam or Receipt confirmation

Motion must clarify:

- object origin
- state change
- relationship
- receipt/proof
- reflow preview
- capture/composer focus

Allowed motion families:

- active-node breathing only for genuinely live state
- subtle trace draw for new relationship
- object-origin expansion
- Trust Seam opening
- LifeShape morph
- Capture composer rise
- Quiet Reflow preview
- ambient state tint shift

Forbidden motion:

- bounce
- excessive pulse
- dramatic zoom
- neon scan
- particle celebration
- parallax gimmick
- animation without product meaning
- chatbot typing animation

### Trace rules

Trace is allowed for:

- relationship
- proof
- reflow
- route
- receipt resolve
- active-node tether
- static origin

Trace is not ambient brand texture.

LuminousTrace must not be visual-only meaning.

Reduce Motion requires static origin markers, labels, before/after summaries, or native navigation equivalents.

### Reduce Motion

Reduce Motion must preserve meaning.

Use:

- static origin indicators
- native push/sheet/fade
- before/after summaries
- text labels
- non-motion state markers

### Haptics

System-default restrained at launch.

Future preference lives in You → Accessibility / Motion & Feedback if that section exists later.

Use haptics sparingly:

- soft commit for Start now
- light confirmation for receipt
- medium-soft confirmation for accepted reflow
- soft boundary for Waiting / Blocked
- minimal selection for tab changes

Haptics may never be the only confirmation.

---

## 28. Visual System Rules

Visual system:

```text
dark graphite
soft black
warm low-light atmosphere
restrained luminous traces
native material depth
celestial only as orientation
```

Core materials:

- Celestial Field
- Graphite Recess
- Luminous Trace
- Quiet Glass

### Celestial Field

Role: atmospheric orientation surface.

Design targets: may support Dust / Compass / Constellation / North Star / Open Field intensity levels.

Must not become fantasy space wallpaper.

### Graphite Recess

Role: embedded depth, instrument bed, atlas ground, held pocket, grouped settings.

Must not become generic cards.

### Luminous Trace

Role: state, proof, continuity, relationship, route, reflow, receipt resolve.

Must not become neon HUD or ambient brand texture.

### Quiet Glass

Role: restrained touch/control material.

Design targets: action, object bed, receipt, Trust Seam, composer roles.

Must not become generic glassmorphism.

### Primitive approval boundary

No new primitive is approved by truth alone:

- no new glass system
- no new particle engine
- no new Canvas primitive
- no Metal shader
- no NorthStarField primitive
- no ObjectInstrumentFrame
- no PlacementFieldCanvas
- no DirectionAtlasCanvas

unless a later implementation packet proves missing capability, fallback behavior, accessibility behavior, performance concern, ownership, and rollback.

Visual hard reds:

- random gradients
- decorative stars
- astrology look
- fantasy space art
- sci-fi HUD
- neon traces
- generic glassmorphism
- low-contrast graphite controls
- card stacks
- fake premium emptiness
- decorative-only atmosphere

Every visual detail must do product work.

---

## 29. Typography, Layout, and Hierarchy Rules

Typography should be SF-first and Dynamic Type aware.

Layout hierarchy:

1. Primary object
2. Primary action
3. Current state
4. Source/trust
5. Secondary metadata
6. Drill-down detail

Rules:

- primary action must remain visible when action is expected
- text wraps before shrinking below readability
- atmosphere recedes before content becomes illegible
- secondary metadata collapses before primary meaning
- large headers are used sparingly
- top-level surfaces should not rely on thick page headers
- thumb-zone actions matter
- native spacing matters
- dense does not mean cramped

Hard red:

```text
A surface that looks minimal because it lacks state is not premium.
A surface that looks dense because it is cluttered is not premium.
```

---

## 30. Accessibility Rules

Accessibility is product architecture.

Every Signature Object must work nonvisually.

Required:

- object-level VoiceOver summaries for every primary object
- semantic grouping
- accessible actions
- Dynamic Type support
- Reduce Motion support
- Increase Contrast support
- Reduce Transparency support
- Differentiate Without Color support
- 44 pt minimum tap targets, 48 pt preferred primary
- expanded invisible hit areas for small nodes/proof marks/traces
- larger fallback controls where needed
- source/trust path accessible
- closure/recovery accessible
- non-color state indicators

### Dynamic Type collapse order

```text
atmosphere → decorative trace → secondary metadata → dense readings → optional labels
```

Never collapse first:

- primary object
- primary action
- source/trust
- closure/recovery
- route state
- receipt
- manual fallback

### Reduce Transparency

QuietGlass extension only, not new glass material.

### Increase Contrast

Reduce atmosphere, strengthen boundaries, add labels, reduce trace intensity, add non-color indicators.

### Differentiate Without Color

Shape + label + grouping globally.

Pattern/texture + label for Time/Motion where meaningful.

No state may rely only on:

- glow
- tint
- trace
- constellation position
- animation
- haptic
- color

Hard red:

```text
If a user cannot understand or complete the primary flow without visual interpretation, the object is not complete.
```

---

## 31. Personalization Rules

Personalization may affect:

- recommended step order
- suggested durations
- planning defaults
- recovery suggestions
- capture routing
- goal-thread surfacing
- protected-time suggestions
- closure prompts
- horizon summaries
- interface density preference
- accent restraint
- notification posture

Personalization may not affect:

- core accessibility
- privacy controls
- truth/source visibility
- ability to decline recommendations
- ability to use Manual mode
- basic app navigation
- data ownership
- non-shaming tone

Personalization must be:

- local
- inspectable
- editable
- resettable
- source-aware
- non-creepy
- non-manipulative

User correction is product data.

If the user changes a route, moves a step, marks Still Counts, protects a block, or rejects a suggestion, Ambitions should learn locally and explain where that learning lives.

---

## 32. Empty, Loading, Error, and Recovery States

Ambitions non-ideal states must feel calm and useful.

### Empty states

Should explain what the surface can hold or do.

They must not imply failure.

### Loading states

Should be native, brief, and non-theatrical.

No AI thinking animation.

### Error states

Should explain what is unavailable and what still works.

Preferred pattern:

```text
Source unavailable.
Manual planning is still available.
```

### Recovery states

Should help the user continue with less burden.

Preferred patterns:

```text
Reality changed.
This still has a path.
```

```text
Make today lighter.
```

```text
Needs closure.
Still counts, move it, or let it go.
```

Hard red:

- blocking Capture because calendar is unavailable
- blocking Goals because permissions are denied
- shaming user for missed steps
- hiding manual fallback
- presenting source failure as user failure

---

## 32A. State / Preview / Proof Matrix

Every top-level surface and global Capture must support:

- standard
- empty
- loading
- error
- recovery
- source unavailable
- low confidence
- receipt
- Default Dynamic Type
- Large Dynamic Type
- Accessibility Extra Extra Large
- Reduce Motion
- Increase Contrast
- Reduce Transparency
- Differentiate Without Color notes
- tap-target notes

Screenshots are proof artifacts only and do not prove accessibility, performance, privacy, device behavior, TestFlight readiness, App Store readiness, or release readiness.

---

## 33. Anti-Generic UI Rules

Codex must never produce:

- generic card stacks
- dashboard layouts
- shallow tab screens
- random gradients
- template productivity UI
- generic AI suggestion cards
- ungrounded chatbot surfaces
- bloated navigation
- disconnected features
- decorative-only celestial visuals
- social-feed mechanics
- gamified streak pressure
- sportsbook-style urgency
- old-canon drift
- implementation claims disguised as design truth
- release claims disguised as design truth
- low-density screens pretending to be premium
- high-density screens that are just clutter
- one-off components that should be primitives
- inconsistent terminology
- non-native iOS interactions
- inaccessible visual patterns
- cloud AI dependency
- custom hosted personal backend assumptions
- R2 misuse as user-data backend

Three-second screenshot failure:

```text
If a screenshot reads as task app, calendar app, notes app, dashboard, habit tracker, chatbot, SaaS admin panel, astrology app, sci-fi HUD, or generic SwiftUI demo, the surface fails.
```

---

## 34. Codex Frontend Guardrails

Before implementing any frontend object, Codex must answer:

1. What product object is this?
2. Which surface owns it?
3. Which user job does it serve?
4. What states does it support?
5. What is the empty state?
6. What is the loading state?
7. What is the error state?
8. What is the recovery state?
9. What source/trust behavior is required?
10. What receipt behavior is required?
11. What closure behavior is required?
12. What accessibility summary is required?
13. What Reduce Motion equivalent is required?
14. What Dynamic Type behavior is required?
15. What anti-patterns must be avoided?
16. Which primitive should be reused?
17. Does this create a new component that should be a primitive?
18. Does this revive obsolete canon?
19. Does this require cloud AI or hosted personal backend?
20. Does this still feel native on iPhone?

Hard red implementation failures:

- object implemented as static mock
- no state model
- no accessibility semantics
- no trust/source path
- no receipt path where meaningful
- generic card-stack structure
- old names in active UI
- cloud dependency introduced
- calendar required for basic use
- top-level IA changed
- release-ready or production-ready claim without proof

---

## 35. Codex PR Acceptance Checklist

Every implementation PR touching product/frontend must include evidence for the relevant items below.

### Required for every top-level surface PR

- Surface keeps final top-level IA.
- Surface has exactly one primary object.
- Surface does not read as a dashboard, card stack, feed, calendar clone, chatbot, or generic SwiftUI demo.
- Surface has empty/loading/error/recovery states.
- Surface has VoiceOver summary behavior.
- Surface supports Dynamic Type without losing the primary action.
- Surface supports Reduce Motion without losing meaning.
- Surface supports Increase Contrast / Differentiate Without Color.
- Surface has native tap targets.
- Surface uses approved terminology.
- Surface does not use banned copy.
- Surface does not introduce cloud dependency.
- Surface does not require calendar permission for basic value.

### Required for every recommendation PR

- Source label exists.
- Why this? path exists.
- User can decline or adjust.
- Uncertainty is represented when relevant.
- Meaningful action leaves receipt.
- Recommendation is deterministic/local unless explicitly stubbed as future.
- No AI-branded copy appears.

### Required for every personalization PR

- Learning source is visible.
- User can edit/reset/disable.
- Behavior is local-first.
- No sensitive identity inference.
- No hidden ranking of life areas.
- No server-side profiling.

### Required for every visual-system PR

- Visual effect does product work.
- Celestial material is not decorative-only.
- Contrast is adequate.
- Motion has Reduce Motion equivalent.
- No random gradients or neon HUD.
- No generic glassmorphism.
- No low-contrast graphite-on-graphite controls.

A PR without this evidence is Yellow at best. A PR violating hard reds is Red and must be repaired before continuing.

---

## 36. Terminology: Use / Avoid

### Use

- Start here
- Recommended step
- Start now
- Open step
- Adjust plan
- Why this?
- Still counts
- Shape Time
- Motion Current
- Time Texture
- global Capture
- Capture Anything
- Saved locally
- Saved safely
- Shape week
- Review pressure
- Open time
- Goal time
- Protected
- Pressure
- Needs a Place
- Ready to Place
- Grow into Goal
- Held item
- Held Object
- Held for Review
- Trust & Automation
- Privacy
- Receipt
- Receipts & History
- Source
- Manual mode
- Preview Reflow
- Waiting
- Blocked
- Needs recovery
- Needs review
- Make today lighter
- Reality changed
- Close Today
- Personal Runtime
- Proof
- Proof Transfers
- Source Needed
- Correction Fold
- This week can hold
- Your Direction
- Your System

### Internal / product-object names

- Runtime Root Shell
- AmbitionsShell product concept
- Context Crown
- Continuity Dock
- Meridian Edge
- Trust Seam
- Receipt Surface
- Quiet Reflow
- Reality Meridian
- Start Here Surface
- Day Compass anatomy
- Direction Atlas
- Constellation relationship layer
- Direction Lens
- Thread Focus
- LifeShape Field
- Motion Current
- Personal Runtime / Trust object
- User System Profile as internal/source compatibility
- Placement Field
- Atmosphere Composer as activated layer
- Open Field

Source compatibility names (may remain in source until migration):

- Constellation Atlas
- Orbital Lens
- AmbitionsShell as type name

### Avoid / banned in active UI

- Dashboard
- Assistant
- AI assistant
- AI coach
- Chatbot
- AI recommends
- AI decided
- best next move
- next best move
- optimize your day
- optimize your life
- maximize productivity
- crush your goals
- get back on track
- overdue
- failed
- streak broken
- habit score
- life score
- productivity score
- XP
- score
- streak
- smart capture
- AI-powered
- GPT
- GPT-like
- model confidence
- confidence percentage
- AI confidence
- classification theater
- DayTimelineRail
- Reality Rail
- Day Rail
- Hero Step Panel
- Hero Step Module
- Plan tab
- Capture tab
- Pulse tab
- Pulse as current product truth
- Profile tab
- Captures tab
- Calendar tab
- Inbox tab
- Direction Atlas as root UI label unless onboarding/help/internal
- Constellation Atlas as active root UI label
- Orbital Lens as active root UI label
- Atmosphere Composer as ordinary user-facing label
- Placement Field as ordinary user-facing label unless onboarding/help/internal
- North Star Field as a code primitive name
- decorative stars
- astrology map

Legacy terms may appear only in migration notes, archive docs, or cleanup reports.

---

## 37. Non-Goals

Ambitions is not building, as core truth:

- generic task manager
- generic calendar app
- notes app
- habit tracker
- streak app
- life score system
- productivity score system
- AI chatbot assistant
- AI coach persona
- hosted SaaS backend
- custom hosted user account system
- server-side personal profiling
- social feed
- leaderboards
- family/social layer
- public sharing
- team collaboration
- betting/fantasy/social mechanics
- dashboard analytics product
- generic web-first cross-platform compromise
- external LLM-dependent planning agent
- automatic scheduling agent without preview/receipts/control
- R2-backed personal data storage

Future extensions may exist only when separately scoped and must not violate this file.

---

## 38. Release, Screenshot, and Proof Boundaries

Archive and readiness preparation may be product/design work when scoped.

The following are separate gated approvals:

- upload to internal TestFlight
- external TestFlight
- App Review
- public App Store release

build success is not release readiness.

Screenshots are proof artifacts.

Baselines are contracts.

Screenshot baseline policy:

- no silent visual diff acceptance
- no bulk baseline updates
- human review required for flagship surfaces
- human review required for release-facing screenshots
- screenshot updates must be tied to the intended product/design change
- screenshot evidence does not prove accessibility, performance, privacy, TestFlight readiness, App Store readiness, or release approval by itself

## 39. What This File Does Not Prove

This file does not prove:

- implementation exists
- implementation is correct
- test coverage exists
- accessibility has been validated
- VoiceOver has been validated
- Dynamic Type has been validated
- Reduce Motion has been validated
- Increase Contrast has been validated
- performance has been validated
- data persistence has been validated
- iCloud sync exists
- R2 freshness packs exist
- local intelligence exists
- App Store readiness
- production readiness
- release readiness

This file is product/design truth.

Proof requires code, previews, tests, device validation, accessibility validation, performance validation, and explicit evidence.

---

## 40. Final Red-Line Summary

Codex must stop and repair if any of these happen:

1. A sixth top-level tab appears.
2. Plan returns as a top-level tab.
3. Capture becomes a top-level tab, inbox, notes feed, chatbot, category grid, persistent floating button, plus-tab utility, or cloud classification theater.
4. Today becomes a task list, calendar timeline, focus widget, stack of cards, or detached Start Here card.
5. Goals becomes KPI dashboard, ranked score, habit ring system, astrology map, decorative constellation, or generic goals list.
6. Time becomes a calendar clone, agenda clone, free/busy calendar surface, heatmap dashboard, productivity scoring surface, calendar-density score, AI scheduling score, resource-allocation model, or analytics surface.
7. Motion becomes analytics dashboard, activity feed, XP, score, streak, productivity report, generic progress chart, social timeline, dashboard card stack, or shame/guilt surface.
8. You becomes social profile, admin console, AI settings wall, generic profile page, or settings dump without Personal Runtime / Trust object.
9. Visual celestial flavor becomes wallpaper/spectacle/decoration.
10. Trace becomes ambient brand shimmer.
11. Meaning relies only on color, glow, trace, position, motion, haptic, or constellation geometry.
12. Meaningful change lacks receipt.
13. Recommendation lacks source/reason/control/uncertainty/receipt behavior.
14. External/cloud LLM becomes required.
15. Hosted personal-data backend appears.
16. R2 receives user-private data.
17. Product docs claim implementation/readiness without evidence.

Final implementation law:

```text
Build fewer things deeper. Make every object stateful, local, inspectable, accessible, native, and unmistakably Ambitions.
```
