# Train Family Precedence Ledger

Status: Active precedence ledger for planned train/source-family extraction

Precedence order: `docs/truth/*` first, then active repo evidence, then the broad all-train inventory, then legacy or historical train families. MRI and HBI remain supported entries inside the broader map, not the only overlays.

| Train Family | Display Name | Precedence Rank | Recency Confidence | Primary Conflict | Open Question |
|---|---|---:|---|---|---|
| `pk` | PK | 1 | high | current implementation never outranks intended final-state direction | Which PK sub-batches remain validation-only? |
| `mri` | MRI | 2 | high | MRI is one entry in the broader all-train map, not the only overlay lane | How much MRI language should stay visible after broader extraction? |
| `hbi` | HBI | 2 | high | HBI is one entry inside the broader source-family system | Which recovery surfaces should explicitly surface HBI comparison? |
| `lid` | LID | 1 | medium | LID stays subordinate to local-first privacy rules | Which LID labels are user-facing versus internal? |
| `aos` | AOS | 1 | high | AOS does not authorize hosted AI or chatbot posture | Which AOS terms are surface-ready versus internal-only? |
| `rec` | REC | 1 | high | receipt/proof language should not become generic transaction or gambling language | Which receipt surfaces remain transient versus persistent canon? |
| `si` | SI | 1 | high | SI is a primitive and language system, not a new tab | Which future primitives become active canon versus supporting semantics only? |
| `pd` | PD | 1 | high | Plan remains contextual/internal, not a top-level destination | Which PD nouns should stay user-facing versus internal-only? |
| `moat_runtime` | Moat Runtime | 1 | medium | Moat runtime is not product hype or release proof | Which moat prompts remain final-state direction versus history only? |
| `runtime` | Runtime | 2 | medium | Runtime is a source family, not an app-mode promise | Which runtime labels are user-facing versus internal diagnostics only? |
| `visual_canon` | Visual Canon | 1 | high | Visual canon is subordinate to active truth and not proof of implementation | How much visual canon should be front-door versus trace-only? |
| `planning` | Planning | 1 | high | Plan as top-level is not allowed | Which planning terms are still compatibility seams? |
| `capture` | Capture | 1 | high | No top-level Inbox or Tasks tab | Which capture routes remain planned versus already locked in canon? |
| `time` | Time | 1 | high | Plan is contextual, not a top-level Time successor | Which Time depth surfaces remain unresolved versus canonical? |
| `today` | Today | 1 | high | Today must not degrade into a task list or dashboard | Which Today detail surfaces are still unresolved or directional? |
| `goals` | Goals | 1 | high | Goals should never become a KPI dashboard or ranked score surface | How much historical language should remain visible in Goals detail? |
| `you` | You | 1 | high | You is not a social profile or admin console | Which You controls need explicit source-freshness indicators? |
| `accessibility` | Accessibility | 2 | high | No color-only meaning or visual-only proof claims | Which accessibility notes need separate proof before release claims? |
| `privacy` | Privacy | 2 | high | Privacy cannot become hosted-data or hidden-profile behavior | Which privacy affordances are final-state canon versus proof backlog? |
| `qa_validation` | QA / validation | 2 | high | QA is not release proof and not implementation proof | Which validation docs are still advisory versus gate-bearing? |
| `onboarding_first_run` | Onboarding / First Run | 2 | high | Onboarding must not request calendar permission as part of the initial trust gate | Which first-run states stay intentionally unresolved? |
| `supporting_programs` | Supporting Programs | 3 | medium | supporting programs do not claim product runtime or top-level IA | Which supporting-program labels should remain active in front-door docs? |
| `historical_programs` | Historical Programs | 4 | low | historical programs never outrank active product truth | Should any historical program family remain linked from active frontend docs? |

Lower ranks are higher priority for intended final-state direction. Higher-numbered rows are kept for traceability and should not outrank active truth.
