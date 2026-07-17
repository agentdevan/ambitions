+++
spec_id = "GLOBAL-SEARCH"
title = "Search"
kind = "global"
status = "normative"
owner_domain = "global-search"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "global.search.answer-evidence",
  "global.search.ask",
  "global.search.ask-activation-gate",
  "global.search.ask-command-contract",
  "global.search.canonical-actions",
  "global.search.capture-handoff",
  "global.search.command-contract",
  "global.search.find",
  "global.search.first-viewport",
  "global.search.identity",
  "global.search.input",
  "global.search.index-actions",
  "global.search.index-ranking",
  "global.search.inspect",
  "global.search.placement",
  "global.search.presentation",
  "global.search.session-history",
  "global.search.visual-authority",
]
inherits = [
  "LAW-IA-NONROOT-001",
  "LAW-SEARCH-PRIVATE-COMMAND-LAYER-001",
  "LAW-LOCAL-AUTHORITY-001",
  "CONST-RUNTIME-MUTATION-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION"]
source_owners = [
  "Native/Ambitions/Stage/",
  "Native/Ambitions/Core/LocalRuntimeOS/Search/",
  "Native/Ambitions/Core/LocalRuntimeOS/Projections/",
  "Native/Ambitions/Core/LocalRuntimeOS/Commands/",
  "Native/Ambitions/Trust/",
  "Native/Ambitions/Quality/",
]
[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-ACTION-COMPLETE"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Inspect Receipt => destination: the contextual Trust Receipt inspection for the re-resolved canonical result from Search results — Action Complete; effect: No durable mutation occurs and no Receipt is created; Inspect Receipt opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: The selected item now shows the completed change and its recorded result.; focus: the Inspect Receipt destination, Trust heading, or updated results heading in Search results — Action Complete."
durable_effect = "Exact local Find, Act, and Inspect consequences: Inspect Receipt: No durable mutation occurs and no Receipt is created; Inspect Receipt opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: The selected item now shows the completed change and its recorded result. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: The selected item now shows the completed change and its recorded result."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Inspect Receipt: No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content. The prior valid index stays available until replacement validation. Recovery preserves: The selected item now shows the completed change and its recorded result."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: The selected item now shows the completed change and its recorded result."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Inspect Receipt announces result and consequence; success focuses the Inspect Receipt destination, Trust heading, or updated results heading in Search results — Action Complete; rejection focuses the selected result and exact Inspect Receipt rejection, privacy, stale, or deletion reason in Search results — Action Complete. Dynamic Type stacks results and previews. The announcement first communicates: The selected item now shows the completed change and its recorded result."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-ACTION-COMPLETE-001"
label = "Inspect Receipt"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the contextual Trust Receipt inspection for the re-resolved canonical result from Search results — Action Complete"
destination_id = "DEST-SEARCH-RESULTS-ACTION-COMPLETE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect Receipt opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: The selected item now shows the completed change and its recorded result."
success_focus = "the Inspect Receipt destination, Trust heading, or updated results heading in Search results — Action Complete"
success_focus_id = "FOCUS-SEARCH-RESULTS-ACTION-COMPLETE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Inspect Receipt rejection, privacy, stale, or deletion reason in Search results — Action Complete"
failure_focus_id = "FOCUS-SEARCH-RESULTS-ACTION-COMPLETE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
recovery_id = "RECOVERY-SEARCH-RESULTS-ACTION-COMPLETE-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-ELIGIBLE"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Undo => destination: the resolved object owner’s current-revision Undo consequence preview from Search results — Action Complete Undo Eligible; effect: No durable mutation occurs and no Receipt is created; Undo is a handoff to the resolved object owner after re-resolving current object revision, semantic eligibility, dependencies, and proof. Search cannot execute a generic inverse. Visible evidence remains: The search result reflects a recent change. Its earlier value remains recorded in History.; focus: the Undo destination, Trust heading, or updated results heading in Search results — Action Complete Undo Eligible."
durable_effect = "Exact local Find, Act, and Inspect consequences: Undo: No durable mutation occurs and no Receipt is created; Undo is a handoff to the resolved object owner after re-resolving current object revision, semantic eligibility, dependencies, and proof. Search cannot execute a generic inverse. Visible evidence remains: The search result reflects a recent change. Its earlier value remains recorded in History. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: The search result reflects a recent change. Its earlier value remains recorded in History."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Undo: No Search Undo is required; cancellation returns to the completed result and its History while the canonical object remains unchanged. The prior valid index stays available until replacement validation. Recovery preserves: The search result reflects a recent change. Its earlier value remains recorded in History."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: The search result reflects a recent change. Its earlier value remains recorded in History."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Undo announces result and consequence; success focuses the Undo destination, Trust heading, or updated results heading in Search results — Action Complete Undo Eligible; rejection focuses the selected result and exact Undo rejection, privacy, stale, or deletion reason in Search results — Action Complete Undo Eligible. Dynamic Type stacks results and previews. The announcement first communicates: The search result reflects a recent change. Its earlier value remains recorded in History."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-ELIGIBLE-001"
label = "Undo"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "Search has no authority to execute or synthesize the inverse command", "The current query, filters, index generation, route, and privacy authorization have been revalidated", "The resolved object owner confirms semantic inverse eligibility and all later dependencies"]
destination = "the resolved object owner’s current-revision Undo consequence preview from Search results — Action Complete Undo Eligible"
destination_id = "DEST-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-ELIGIBLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Undo is a handoff to the resolved object owner after re-resolving current object revision, semantic eligibility, dependencies, and proof. Search cannot execute a generic inverse. Visible evidence remains: The search result reflects a recent change. Its earlier value remains recorded in History."
success_focus = "the Undo destination, Trust heading, or updated results heading in Search results — Action Complete Undo Eligible"
success_focus_id = "FOCUS-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-ELIGIBLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Undo rejection, privacy, stale, or deletion reason in Search results — Action Complete Undo Eligible"
failure_focus_id = "FOCUS-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-ELIGIBLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Search ends at the owner-owned inverse preview; any later typed Undo command and Receipt belong to that resolved object owner."
rollback_undo = "No Search Undo is required; cancellation returns to the completed result and its History while the canonical object remains unchanged."
recovery_id = "RECOVERY-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-ELIGIBLE-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-UNAVAILABLE"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Inspect History => destination: the contextual Trust History inspection for the re-resolved canonical result from Search results — Action Complete Undo Unavailable; effect: No durable mutation occurs and no Receipt is created; Inspect History opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Undo is unavailable for this changed search result. The reason is shown.; focus: the Inspect History destination, Trust heading, or updated results heading in Search results — Action Complete Undo Unavailable."
durable_effect = "Exact local Find, Act, and Inspect consequences: Inspect History: No durable mutation occurs and no Receipt is created; Inspect History opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Undo is unavailable for this changed search result. The reason is shown. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Undo is unavailable for this changed search result. The reason is shown."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Inspect History: No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content. The prior valid index stays available until replacement validation. Recovery preserves: Undo is unavailable for this changed search result. The reason is shown."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Undo is unavailable for this changed search result. The reason is shown."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Inspect History announces result and consequence; success focuses the Inspect History destination, Trust heading, or updated results heading in Search results — Action Complete Undo Unavailable; rejection focuses the selected result and exact Inspect History rejection, privacy, stale, or deletion reason in Search results — Action Complete Undo Unavailable. Dynamic Type stacks results and previews. The announcement first communicates: Undo is unavailable for this changed search result. The reason is shown."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-UNAVAILABLE-001"
label = "Inspect History"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the contextual Trust History inspection for the re-resolved canonical result from Search results — Action Complete Undo Unavailable"
destination_id = "DEST-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-UNAVAILABLE-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect History opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Undo is unavailable for this changed search result. The reason is shown."
success_focus = "the Inspect History destination, Trust heading, or updated results heading in Search results — Action Complete Undo Unavailable"
success_focus_id = "FOCUS-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-UNAVAILABLE-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Inspect History rejection, privacy, stale, or deletion reason in Search results — Action Complete Undo Unavailable"
failure_focus_id = "FOCUS-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-UNAVAILABLE-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
recovery_id = "RECOVERY-SEARCH-RESULTS-ACTION-COMPLETE-UNDO-UNAVAILABLE-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-ACTION-PREVIEW"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Inspect Source => destination: the contextual Trust Source inspection for the re-resolved canonical result from Search results — Action Preview; effect: No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: The selected result and proposed difference are visible. The saved item is unchanged.; focus: the Inspect Source destination, Trust heading, or updated results heading in Search results — Action Preview."
durable_effect = "Exact local Find, Act, and Inspect consequences: Inspect Source: No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: The selected result and proposed difference are visible. The saved item is unchanged. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: The selected result and proposed difference are visible. The saved item is unchanged."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Inspect Source: No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content. The prior valid index stays available until replacement validation. Recovery preserves: The selected result and proposed difference are visible. The saved item is unchanged."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: The selected result and proposed difference are visible. The saved item is unchanged."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Inspect Source announces result and consequence; success focuses the Inspect Source destination, Trust heading, or updated results heading in Search results — Action Preview; rejection focuses the selected result and exact Inspect Source rejection, privacy, stale, or deletion reason in Search results — Action Preview. Dynamic Type stacks results and previews. The announcement first communicates: The selected result and proposed difference are visible. The saved item is unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-ACTION-PREVIEW-001"
label = "Inspect Source"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the contextual Trust Source inspection for the re-resolved canonical result from Search results — Action Preview"
destination_id = "DEST-SEARCH-RESULTS-ACTION-PREVIEW-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: The selected result and proposed difference are visible. The saved item is unchanged."
success_focus = "the Inspect Source destination, Trust heading, or updated results heading in Search results — Action Preview"
success_focus_id = "FOCUS-SEARCH-RESULTS-ACTION-PREVIEW-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Inspect Source rejection, privacy, stale, or deletion reason in Search results — Action Preview"
failure_focus_id = "FOCUS-SEARCH-RESULTS-ACTION-PREVIEW-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
recovery_id = "RECOVERY-SEARCH-RESULTS-ACTION-PREVIEW-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-FAILED"
requirement_id = "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]
transition_exit = "Retry Ask => destination: in-place on-device synthesis progress for the unchanged query and deterministic result set; effect: No durable mutation occurs and no Receipt is created; Retry Ask revalidates privacy authorization and reruns only optional on-device synthesis while deterministic local results remain visible.; focus: the synthesis progress status, then the grounded answer heading, or the unchanged local results if synthesis remains unavailable."
durable_effect = "Deterministic local results remain visible after optional synthesis fails; no question, answer, proposal, or canonical object is persisted. Retry reruns only on-device synthesis against the current privacy-authorized query context."
recovery_rollback = "Retry revalidates the current query, source access, and on-device availability; cancellation returns to unchanged deterministic results. No Search Undo is required."
offline_behavior = "Find, Act, and Inspect remain available from local projections offline. Ask stays unavailable until on-device synthesis can run, without hiding local results."
accessibility_focus = "VoiceOver announces that optional Ask failed, deterministic results remain available, and Retry Ask is optional; focus stays on the failure explanation or first local result."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-ASK-FAILED-001"
label = "Retry Ask"
canonical_owner = "global.search.ask-command-contract"
preconditions = ["Privacy authorization and on-device synthesis eligibility are revalidated", "The current query and deterministic result generation are still available"]
destination = "in-place on-device synthesis progress for the unchanged query and deterministic result set"
destination_id = "DEST-SEARCH-RESULTS-ASK-FAILED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Retry Ask revalidates privacy authorization and reruns only optional on-device synthesis while deterministic local results remain visible."
success_focus = "the synthesis progress status, then the grounded answer heading, or the unchanged local results if synthesis remains unavailable"
success_focus_id = "FOCUS-SEARCH-RESULTS-ASK-FAILED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the concise Ask-unavailable explanation with the first unchanged deterministic result still reachable"
failure_focus_id = "FOCUS-SEARCH-RESULTS-ASK-FAILED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Retry Ask reruns optional session-local synthesis and cannot create, save, or mutate a canonical object."
rollback_undo = "No Search Undo is required; cancellation or repeated failure returns to the unchanged deterministic results and current query."
recovery_id = "RECOVERY-SEARCH-RESULTS-ASK-FAILED-001"
recovery_posture = "current"
recovery_owner = "global.search.ask-command-contract"
privacy_egress = "The query, deterministic results, synthesis context, and supporting objects remain on device; no private query, answer, or private life graph leaves the device."
verification_ids = ["SCENARIO-SEARCH-ASK-UNAVAILABLE-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-INTERRUPTED"
requirement_id = "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]
transition_exit = "Resume Ask => destination: resumed in-place synthesis for the same session-local query and evidence scope; effect: No durable mutation occurs and no Receipt is created; Resume Ask revalidates the current query, privacy authorization, supporting-object availability, and on-device synthesis eligibility before continuing.; focus: the resumed synthesis status, grounded answer heading, or interruption explanation if revalidation fails."
durable_effect = "Interruption pauses optional synthesis in memory while preserving the visible deterministic results, query, and authorized evidence scope. It creates no saved conversation, History item, or canonical object."
recovery_rollback = "Resume revalidates current local facts before continuing; dismissal discards only the session-local synthesis checkpoint and preserves deterministic results. No Search Undo is required."
offline_behavior = "An interruption never removes offline Find, Act, or Inspect. Resume uses on-device resources only and otherwise returns to the visible deterministic fallback."
accessibility_focus = "VoiceOver announces that Ask paused, that local results remain usable, and that Resume Ask is optional; focus remains at the interruption status before the unchanged result list."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-ASK-INTERRUPTED-001"
label = "Resume Ask"
canonical_owner = "global.search.ask-command-contract"
preconditions = ["Current privacy authorization and supporting-object revisions can be revalidated", "The session-local query checkpoint still belongs to the current Search presentation"]
destination = "resumed in-place synthesis for the same session-local query and evidence scope"
destination_id = "DEST-SEARCH-RESULTS-ASK-INTERRUPTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Resume Ask revalidates the current query, privacy authorization, supporting-object availability, and on-device synthesis eligibility before continuing."
success_focus = "the resumed synthesis status, grounded answer heading, or interruption explanation if revalidation fails"
success_focus_id = "FOCUS-SEARCH-RESULTS-ASK-INTERRUPTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the interruption explanation with deterministic results still visible and no protected supporting object disclosed"
failure_focus_id = "FOCUS-SEARCH-RESULTS-ASK-INTERRUPTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Resume Ask continues only optional session-local synthesis after current-state revalidation."
rollback_undo = "No Search Undo is required; dismissal or failed resumption discards the synthesis checkpoint and returns to unchanged deterministic results."
recovery_id = "RECOVERY-SEARCH-RESULTS-ASK-INTERRUPTED-001"
recovery_posture = "current"
recovery_owner = "global.search.ask-command-contract"
privacy_egress = "The session checkpoint, query, evidence scope, and resumed synthesis remain on device; no private query, answer, or private life graph leaves the device."
verification_ids = ["SCENARIO-SEARCH-SESSION-HISTORY-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RECOVERED"
requirement_id = "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]
transition_exit = "Inspect Source => destination: contextual supporting-object and approved-source evidence for the recovered answer; effect: No durable mutation occurs and no Receipt is created; Inspect Source opens privacy-authorized evidence for the current answer and keeps its assumptions and uncertainty attached.; focus: the supporting Source heading or the exact unavailable-evidence explanation, then back to the recovered answer."
durable_effect = "A recovered grounded answer replaces only the failed progressive enhancement and leaves deterministic results and canonical objects unchanged. Supporting objects, assumptions, uncertainty, and source links remain visible."
recovery_rollback = "Inspection dismissal returns to the recovered answer and its source markers; if evidence becomes stale or unavailable, the answer is relabeled or withheld while deterministic results remain. No Search Undo is required."
offline_behavior = "The recovered answer and its authorized local evidence remain inspectable offline; missing approved reference material is labeled without reducing deterministic Find, Act, or Inspect."
accessibility_focus = "VoiceOver announces Ask recovered, then the answer, retrieved and inferred distinctions, assumptions, uncertainty, and Inspect Source; focus returns to the answer heading after inspection."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-ASK-RECOVERED-001"
label = "Inspect Source"
canonical_owner = "global.search.ask-command-contract"
preconditions = ["Source evidence remains privacy-authorized for contextual inspection", "The recovered answer is still bound to the current query and supporting-object revisions"]
destination = "contextual supporting-object and approved-source evidence for the recovered answer"
destination_id = "DEST-SEARCH-RESULTS-ASK-RECOVERED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect Source opens privacy-authorized evidence for the current answer and keeps its assumptions and uncertainty attached."
success_focus = "the supporting Source heading or the exact unavailable-evidence explanation, then back to the recovered answer"
success_focus_id = "FOCUS-SEARCH-RESULTS-ASK-RECOVERED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the recovered answer’s source marker and exact stale, suppressed, or unavailable evidence reason"
failure_focus_id = "FOCUS-SEARCH-RESULTS-ASK-RECOVERED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: contextual Source inspection is read-only and cannot persist the answer or alter its supporting objects."
rollback_undo = "No Search Undo is required; dismissal returns to the recovered answer, and evidence failure preserves deterministic results with an explicit limitation."
recovery_id = "RECOVERY-SEARCH-RESULTS-ASK-RECOVERED-001"
recovery_posture = "current"
recovery_owner = "global.search.ask-command-contract"
privacy_egress = "The answer and its supporting-object evidence remain on device; Source inspection discloses only current privacy-authorized local or approved reference material."
verification_ids = ["SCENARIO-SEARCH-ANSWER-EVIDENCE-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-RESUMED"
requirement_id = "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]
transition_exit = "Cancel Ask => destination: the unchanged deterministic result list and current query after resumed synthesis stops; effect: No durable mutation occurs and no Receipt is created; Cancel Ask discards only in-progress session-local synthesis and preserves the query, filters, deterministic results, and privacy suppression.; focus: the deterministic result-count heading or current query field with a concise Ask-cancelled announcement."
durable_effect = "Resumed synthesis continues only in memory after current-state revalidation. The current query and deterministic results remain primary, and no partial answer or checkpoint becomes canonical state."
recovery_rollback = "Cancel discards incomplete resumed synthesis and returns to unchanged local results; interruption may create a new session-local checkpoint only while Search remains active. No Search Undo is required."
offline_behavior = "Resumed Ask uses on-device resources only. If those resources become unavailable, Search stops synthesis and retains offline deterministic results and inspection."
accessibility_focus = "VoiceOver announces that Ask resumed while local results remain available, exposes Cancel Ask, and moves focus to the bounded answer only when evidence is ready."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-ASK-RESUMED-001"
label = "Cancel Ask"
canonical_owner = "global.search.ask-command-contract"
preconditions = ["Optional synthesis resumed from a revalidated session-local checkpoint", "The current query and deterministic results remain available independently"]
destination = "the unchanged deterministic result list and current query after resumed synthesis stops"
destination_id = "DEST-SEARCH-RESULTS-ASK-RESUMED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Cancel Ask discards only in-progress session-local synthesis and preserves the query, filters, deterministic results, and privacy suppression."
success_focus = "the deterministic result-count heading or current query field with a concise Ask-cancelled announcement"
success_focus_id = "FOCUS-SEARCH-RESULTS-ASK-RESUMED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the resumed synthesis status with an explicit cancellation failure and deterministic results still reachable"
failure_focus_id = "FOCUS-SEARCH-RESULTS-ASK-RESUMED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Cancel Ask ends only optional session-local synthesis and preserves all canonical objects."
rollback_undo = "No Search Undo is required; cancellation returns to deterministic results, while cancellation failure retains the current query and allows dismissal."
recovery_id = "RECOVERY-SEARCH-RESULTS-ASK-RESUMED-001"
recovery_posture = "current"
recovery_owner = "global.search.ask-command-contract"
privacy_egress = "Resumed synthesis and its checkpoint remain on device; cancellation emits no private content or private life graph data."
verification_ids = ["SCENARIO-SEARCH-SESSION-HISTORY-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK"
requirement_id = "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]
transition_exit = "Inspect Privacy => destination: contextual privacy explanation for Ask unavailability and the still-active local Search scope; effect: No durable mutation occurs and no Receipt is created; Inspect Privacy explains the local eligibility or protected-data boundary without revealing suppressed objects or enabling hosted synthesis.; focus: the Privacy heading or exact unavailable explanation, then back to the deterministic result list."
durable_effect = "Ask unavailability changes no local object or result. Immediate deterministic matches, safe owner action proposals, and contextual inspection remain available, with the unavailable capability named separately."
recovery_rollback = "Privacy inspection returns to the same query and deterministic results; a later Ask attempt must revalidate on-device eligibility and current source authorization. No Search Undo is required."
offline_behavior = "Offline Search remains fully useful through deterministic Find, Act, and Inspect. Ask is labeled unavailable rather than delaying, replacing, or hiding local results."
accessibility_focus = "VoiceOver announces Ask unavailable, why only when disclosure is safe, and that local results remain complete; focus proceeds to the deterministic result count before optional Inspect Privacy."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK-001"
label = "Inspect Privacy"
canonical_owner = "global.search.ask-command-contract"
preconditions = ["Deterministic local Search remains available for the current query", "The privacy explanation can be shown without revealing a suppressed object or protected fact"]
destination = "contextual privacy explanation for Ask unavailability and the still-active local Search scope"
destination_id = "DEST-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect Privacy explains the local eligibility or protected-data boundary without revealing suppressed objects or enabling hosted synthesis."
success_focus = "the Privacy heading or exact unavailable explanation, then back to the deterministic result list"
success_focus_id = "FOCUS-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Ask-unavailable label with deterministic results still visible and no suppressed identity disclosed"
failure_focus_id = "FOCUS-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Privacy inspection cannot enable Ask, reveal suppressed facts, or mutate any canonical object."
rollback_undo = "No Search Undo is required; dismissal or inspection failure returns to the same deterministic results and unavailable label."
recovery_id = "RECOVERY-SEARCH-RESULTS-ASK-UNAVAILABLE-OFFLINE-FALLBACK-001"
recovery_posture = "current"
recovery_owner = "global.search.ask-command-contract"
privacy_egress = "The query, eligibility explanation, and results remain on device; no private context is transferred to a hosted model, profiler, or external service."
verification_ids = ["SCENARIO-SEARCH-ASK-UNAVAILABLE-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-CAPTURE-HANDOFF"
requirement_id = "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]
transition_exit = "Open Capture => destination: Capture with the accepted user-entered creation intent and privacy-authorized source context; effect: No durable mutation occurs and no Receipt is created; Open Capture transfers only the in-memory intent and permitted source references, while Capture independently owns draft durability, type, consequences, confirmation, save, Receipt, and Undo.; focus: the Capture composer field containing the transferred intent or the Search handoff explanation if Capture cannot open."
durable_effect = "Search preserves the current query and return context while transferring creation intent to Capture. Search creates no draft, canonical object, Receipt, or parallel composition policy."
recovery_rollback = "Capture cancellation returns to the same Search query and source context without a new object; failed handoff retains the intent in Search for retry or dismissal. No Search Undo is required."
offline_behavior = "The handoff works locally without an account or network. Capture applies its own offline draft and save policy after it opens."
accessibility_focus = "VoiceOver announces that creation will continue in Capture, names the preserved intent, and moves focus to the Capture composer; cancellation restores focus to the originating Search proposal."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-CAPTURE-HANDOFF-001"
label = "Open Capture"
canonical_owner = "global.search.ask-command-contract"
preconditions = ["Only privacy-authorized source context is eligible for transfer to Capture", "The current Search input expresses creation intent rather than an existing-object mutation"]
destination = "Capture with the accepted user-entered creation intent and privacy-authorized source context"
destination_id = "DEST-SEARCH-RESULTS-CAPTURE-HANDOFF-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Open Capture transfers only the in-memory intent and permitted source references, while Capture independently owns draft durability, type, consequences, confirmation, save, Receipt, and Undo."
success_focus = "the Capture composer field containing the transferred intent or the Search handoff explanation if Capture cannot open"
success_focus_id = "FOCUS-SEARCH-RESULTS-CAPTURE-HANDOFF-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the original Search creation proposal with the entered intent preserved and the handoff failure explained"
failure_focus_id = "FOCUS-SEARCH-RESULTS-CAPTURE-HANDOFF-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Search ends at the Capture presentation handoff and cannot create or save the proposed object."
rollback_undo = "No Search Undo is required; Capture cancellation or handoff failure returns to the preserved Search intent without creating a draft."
recovery_id = "RECOVERY-SEARCH-RESULTS-CAPTURE-HANDOFF-001"
recovery_posture = "current"
recovery_owner = "global.search.ask-command-contract"
privacy_egress = "Transferred intent and source references remain local and privacy-authorized; no query, draft, or private life graph data leaves the device."
verification_ids = ["SCENARIO-SEARCH-CAPTURE-HANDOFF-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-FILTERED"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Clear Filters => destination: the unfiltered local results heading from Search results — Filtered; effect: No durable mutation occurs and no Receipt is created; Clear Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Filters are active. The visible result count reflects the selected kinds of items and time range.; focus: the Clear Filters destination, Trust heading, or updated results heading in Search results — Filtered."
durable_effect = "Exact local Find, Act, and Inspect consequences: Clear Filters: No durable mutation occurs and no Receipt is created; Clear Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Filters are active. The visible result count reflects the selected kinds of items and time range. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Filters are active. The visible result count reflects the selected kinds of items and time range."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Clear Filters: No Undo is required; dismissal or Clear Filters restores the prior or unfiltered query projection without changing saved objects. The prior valid index stays available until replacement validation. Recovery preserves: Filters are active. The visible result count reflects the selected kinds of items and time range."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Filters are active. The visible result count reflects the selected kinds of items and time range."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Clear Filters announces result and consequence; success focuses the Clear Filters destination, Trust heading, or updated results heading in Search results — Filtered; rejection focuses the selected result and exact Clear Filters rejection, privacy, stale, or deletion reason in Search results — Filtered. Dynamic Type stacks results and previews. The announcement first communicates: Filters are active. The visible result count reflects the selected kinds of items and time range."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-FILTERED-001"
label = "Clear Filters"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the unfiltered local results heading from Search results — Filtered"
destination_id = "DEST-SEARCH-RESULTS-FILTERED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Clear Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Filters are active. The visible result count reflects the selected kinds of items and time range."
success_focus = "the Clear Filters destination, Trust heading, or updated results heading in Search results — Filtered"
success_focus_id = "FOCUS-SEARCH-RESULTS-FILTERED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Clear Filters rejection, privacy, stale, or deletion reason in Search results — Filtered"
failure_focus_id = "FOCUS-SEARCH-RESULTS-FILTERED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: filter presentation and selection remain local projection state and cross no canonical commit boundary."
rollback_undo = "No Undo is required; dismissal or Clear Filters restores the prior or unfiltered query projection without changing saved objects."
recovery_id = "RECOVERY-SEARCH-RESULTS-FILTERED-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-GROUNDED-ANSWER"
requirement_id = "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]
transition_exit = "Inspect Source => destination: contextual supporting objects and approved sources for the bounded grounded answer; effect: No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized evidence and keeps retrieved facts, inferred interpretation, proposed changes, assumptions, and uncertainty visibly distinct.; focus: the supporting Source heading or exact unavailable-evidence explanation, then back to the answer heading."
durable_effect = "The bounded answer remains session-local and grounded in the visible supporting objects and approved sources. Retrieved facts, inferred interpretation, proposed changes, material assumptions, and uncertainty stay distinctly labeled without becoming saved truth."
recovery_rollback = "Inspection dismissal returns to the same bounded answer; stale, contradictory, missing, or suppressed evidence relabels or withholds only the affected inference while preserving deterministic results. No Search Undo is required."
offline_behavior = "The grounded answer uses only on-device synthesis and locally available authorized evidence. If synthesis or a reference is unavailable, deterministic results and contextual inspection remain usable."
accessibility_focus = "VoiceOver reads the bounded answer after deterministic results, announces retrieved, inferred, and proposed labels, then supporting objects, sources, assumptions, uncertainty, and Inspect Source in that order."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-GROUNDED-ANSWER-001"
label = "Inspect Source"
canonical_owner = "global.search.ask-command-contract"
preconditions = ["The bounded answer remains attached to the current query and supporting-object revisions", "The requested supporting evidence is privacy-authorized for contextual inspection"]
destination = "contextual supporting objects and approved sources for the bounded grounded answer"
destination_id = "DEST-SEARCH-RESULTS-GROUNDED-ANSWER-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized evidence and keeps retrieved facts, inferred interpretation, proposed changes, assumptions, and uncertainty visibly distinct."
success_focus = "the supporting Source heading or exact unavailable-evidence explanation, then back to the answer heading"
success_focus_id = "FOCUS-SEARCH-RESULTS-GROUNDED-ANSWER-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the answer’s source marker with the exact stale, missing, contradictory, or privacy-suppressed evidence reason"
failure_focus_id = "FOCUS-SEARCH-RESULTS-GROUNDED-ANSWER-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Source inspection cannot save the answer, promote inference to fact, or alter a supporting object."
rollback_undo = "No Search Undo is required; dismissal returns to the answer, and evidence failure preserves deterministic results with the affected inference labeled or withheld."
recovery_id = "RECOVERY-SEARCH-RESULTS-GROUNDED-ANSWER-001"
recovery_posture = "current"
recovery_owner = "global.search.ask-command-contract"
privacy_egress = "The answer, supporting objects, approved reference artifacts, assumptions, and uncertainty remain on device and reveal only privacy-authorized evidence."
verification_ids = ["SCENARIO-SEARCH-ANSWER-EVIDENCE-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-NO-RESULTS"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Clear Search => destination: the local query field and safely re-resolved results from Search results — No Results; effect: No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: No local items match the current words and filters. Saved items are unchanged.; focus: the Clear Search destination, Trust heading, or updated results heading in Search results — No Results."
durable_effect = "Exact local Find, Act, and Inspect consequences: Clear Search: No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: No local items match the current words and filters. Saved items are unchanged. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: No local items match the current words and filters. Saved items are unchanged."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Clear Search: No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence. The prior valid index stays available until replacement validation. Recovery preserves: No local items match the current words and filters. Saved items are unchanged."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: No local items match the current words and filters. Saved items are unchanged."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Clear Search announces result and consequence; success focuses the Clear Search destination, Trust heading, or updated results heading in Search results — No Results; rejection focuses the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search results — No Results. Dynamic Type stacks results and previews. The announcement first communicates: No local items match the current words and filters. Saved items are unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-NO-RESULTS-001"
label = "Clear Search"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the local query field and safely re-resolved results from Search results — No Results"
destination_id = "DEST-SEARCH-RESULTS-NO-RESULTS-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: No local items match the current words and filters. Saved items are unchanged."
success_focus = "the Clear Search destination, Trust heading, or updated results heading in Search results — No Results"
success_focus_id = "FOCUS-SEARCH-RESULTS-NO-RESULTS-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search results — No Results"
failure_focus_id = "FOCUS-SEARCH-RESULTS-NO-RESULTS-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: query editing and clearing remain before any owner-owned material action or canonical commit."
rollback_undo = "No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence."
recovery_id = "RECOVERY-SEARCH-RESULTS-NO-RESULTS-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-RESULTS"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Filters => destination: the local Search filter controls from Search results — Results; effect: No durable mutation occurs and no Receipt is created; Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Matching Goals, Steps, Captures, and time items are grouped by type, with the matching text highlighted.; focus: the Filters destination, Trust heading, or updated results heading in Search results — Results.\nApply Filters => destination: the filtered local Search results for the current query; effect: No durable mutation occurs and no Receipt is created; the derived query projection applies the selected filters without changing any canonical object; focus: the filtered results heading or first matching result."
durable_effect = "Exact local Find, Act, and Inspect consequences: Filters: No durable mutation occurs and no Receipt is created; Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Matching Goals, Steps, Captures, and time items are grouped by type, with the matching text highlighted. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Matching Goals, Steps, Captures, and time items are grouped by type, with the matching text highlighted."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Filters: No Undo is required; dismissal or Clear Filters restores the prior or unfiltered query projection without changing saved objects. The prior valid index stays available until replacement validation. Recovery preserves: Matching Goals, Steps, Captures, and time items are grouped by type, with the matching text highlighted."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Matching Goals, Steps, Captures, and time items are grouped by type, with the matching text highlighted."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Filters announces result and consequence; success focuses the Filters destination, Trust heading, or updated results heading in Search results — Results; rejection focuses the selected result and exact Filters rejection, privacy, stale, or deletion reason in Search results — Results. Dynamic Type stacks results and previews. The announcement first communicates: Matching Goals, Steps, Captures, and time items are grouped by type, with the matching text highlighted."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-RESULTS-001"
label = "Filters"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the local Search filter controls from Search results — Results"
destination_id = "DEST-SEARCH-RESULTS-RESULTS-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Matching Goals, Steps, Captures, and time items are grouped by type, with the matching text highlighted."
success_focus = "the Filters destination, Trust heading, or updated results heading in Search results — Results"
success_focus_id = "FOCUS-SEARCH-RESULTS-RESULTS-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Filters rejection, privacy, stale, or deletion reason in Search results — Results"
failure_focus_id = "FOCUS-SEARCH-RESULTS-RESULTS-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: filter presentation and selection remain local projection state and cross no canonical commit boundary."
rollback_undo = "No Undo is required; dismissal or Clear Filters restores the prior or unfiltered query projection without changing saved objects."
recovery_id = "RECOVERY-SEARCH-RESULTS-RESULTS-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-RESULTS-002"
label = "Apply Filters"
canonical_owner = "global.search.command-contract"
preconditions = ["A changed filter draft is present", "The current local index revision remains valid", "The query and filter values disclose no data outside the device"]
destination = "the filtered local Search results for the current query"
destination_id = "DEST-SEARCH-RESULTS-RESULTS-002"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; the derived query projection applies the selected filters without changing any canonical object"
success_focus = "the filtered results heading or first matching result"
success_focus_id = "FOCUS-SEARCH-RESULTS-RESULTS-002-SUCCESS"
success_focus_posture = "current"
failure_focus = "the Apply Filters control and exact invalid filter"
failure_focus_id = "FOCUS-SEARCH-RESULTS-RESULTS-002-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
recovery_id = "RECOVERY-SEARCH-RESULTS-RESULTS-002"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "No egress occurs; private object content, History, Proof, and Receipts remain local."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-SELECTED"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Inspect Source => destination: the contextual Trust Source inspection for the re-resolved canonical result from Search results — Selected; effect: No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: One search result is selected. Its saved identity and details remain unchanged.; focus: the Inspect Source destination, Trust heading, or updated results heading in Search results — Selected."
durable_effect = "Exact local Find, Act, and Inspect consequences: Inspect Source: No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: One search result is selected. Its saved identity and details remain unchanged. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: One search result is selected. Its saved identity and details remain unchanged."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Inspect Source: No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content. The prior valid index stays available until replacement validation. Recovery preserves: One search result is selected. Its saved identity and details remain unchanged."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: One search result is selected. Its saved identity and details remain unchanged."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Inspect Source announces result and consequence; success focuses the Inspect Source destination, Trust heading, or updated results heading in Search results — Selected; rejection focuses the selected result and exact Inspect Source rejection, privacy, stale, or deletion reason in Search results — Selected. Dynamic Type stacks results and previews. The announcement first communicates: One search result is selected. Its saved identity and details remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-SELECTED-001"
label = "Inspect Source"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the contextual Trust Source inspection for the re-resolved canonical result from Search results — Selected"
destination_id = "DEST-SEARCH-RESULTS-SELECTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: One search result is selected. Its saved identity and details remain unchanged."
success_focus = "the Inspect Source destination, Trust heading, or updated results heading in Search results — Selected"
success_focus_id = "FOCUS-SEARCH-RESULTS-SELECTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Inspect Source rejection, privacy, stale, or deletion reason in Search results — Selected"
failure_focus_id = "FOCUS-SEARCH-RESULTS-SELECTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
recovery_id = "RECOVERY-SEARCH-RESULTS-SELECTED-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS"
requirement_id = "SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001"
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]
transition_exit = "Cancel Ask => destination: the unchanged deterministic results and current query while optional synthesis stops; effect: No durable mutation occurs and no Receipt is created; Cancel Ask discards only in-progress session-local synthesis and preserves the query, filters, deterministic results, selected object, and privacy suppression.; focus: the deterministic result-count heading or current query field with a concise Ask-cancelled announcement."
durable_effect = "Optional on-device synthesis progresses beside already-visible deterministic results. Partial answer text is not presented as substantive output, saved, or promoted to canonical fact."
recovery_rollback = "Cancel discards incomplete synthesis and preserves the query and deterministic results; interruption retains only a session-local checkpoint eligible for current-state revalidation. No Search Undo is required."
offline_behavior = "Synthesis runs only when on-device capability and authorized local evidence are available. Otherwise it stops cleanly while offline Find, Act, and Inspect continue unchanged."
accessibility_focus = "VoiceOver announces that optional Ask is working while deterministic results remain usable, exposes Cancel Ask, and does not repeatedly announce partial tokens or shift focus."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS-001"
label = "Cancel Ask"
canonical_owner = "global.search.ask-command-contract"
preconditions = ["Deterministic results remain independently available and privacy-filtered", "Optional on-device synthesis is in progress for the current query"]
destination = "the unchanged deterministic results and current query while optional synthesis stops"
destination_id = "DEST-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Cancel Ask discards only in-progress session-local synthesis and preserves the query, filters, deterministic results, selected object, and privacy suppression."
success_focus = "the deterministic result-count heading or current query field with a concise Ask-cancelled announcement"
success_focus_id = "FOCUS-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the bounded synthesis status with deterministic results still reachable and cancellation failure explained"
failure_focus_id = "FOCUS-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Cancel Ask changes only session-local synthesis state and cannot alter a canonical object or result projection."
rollback_undo = "No Search Undo is required; cancellation returns to deterministic results, while cancellation failure retains the current query and permits dismissal."
recovery_id = "RECOVERY-SEARCH-RESULTS-SYNTHESIS-IN-PROGRESS-001"
recovery_posture = "current"
recovery_owner = "global.search.ask-command-contract"
privacy_egress = "The query, result context, evidence, and partial synthesis remain on device; cancellation sends no private content off device."
verification_ids = ["SCENARIO-SEARCH-ASK-GROUNDING-001"]
activation_posture = "future_gated"
gate_requirement_ids = ["SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001"]

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-ACTION-MUTATING"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Inspect History => destination: the contextual Trust History inspection for the re-resolved canonical result from Search entry — Action Mutating; effect: No durable mutation occurs and no Receipt is created; Inspect History opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: A search result change is in progress. The earlier result remains visible.; focus: the Inspect History destination, Trust heading, or updated results heading in Search entry — Action Mutating."
durable_effect = "Exact local Find, Act, and Inspect consequences: Inspect History: No durable mutation occurs and no Receipt is created; Inspect History opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: A search result change is in progress. The earlier result remains visible. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: A search result change is in progress. The earlier result remains visible."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Inspect History: No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content. The prior valid index stays available until replacement validation. Recovery preserves: A search result change is in progress. The earlier result remains visible."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: A search result change is in progress. The earlier result remains visible."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Inspect History announces result and consequence; success focuses the Inspect History destination, Trust heading, or updated results heading in Search entry — Action Mutating; rejection focuses the selected result and exact Inspect History rejection, privacy, stale, or deletion reason in Search entry — Action Mutating. Dynamic Type stacks results and previews. The announcement first communicates: A search result change is in progress. The earlier result remains visible."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-ACTION-MUTATING-001"
label = "Inspect History"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the contextual Trust History inspection for the re-resolved canonical result from Search entry — Action Mutating"
destination_id = "DEST-SEARCH-ROOT-ACTION-MUTATING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect History opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: A search result change is in progress. The earlier result remains visible."
success_focus = "the Inspect History destination, Trust heading, or updated results heading in Search entry — Action Mutating"
success_focus_id = "FOCUS-SEARCH-ROOT-ACTION-MUTATING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Inspect History rejection, privacy, stale, or deletion reason in Search entry — Action Mutating"
failure_focus_id = "FOCUS-SEARCH-ROOT-ACTION-MUTATING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
recovery_id = "RECOVERY-SEARCH-ROOT-ACTION-MUTATING-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-ACTION-REJECTED"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Clear Search => destination: the local query field and safely re-resolved results from Search entry — Action Rejected; effect: No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: The requested search-result change was not accepted. The saved item remains unchanged.; focus: the Clear Search destination, Trust heading, or updated results heading in Search entry — Action Rejected."
durable_effect = "Exact local Find, Act, and Inspect consequences: Clear Search: No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: The requested search-result change was not accepted. The saved item remains unchanged. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: The requested search-result change was not accepted. The saved item remains unchanged."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Clear Search: No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence. The prior valid index stays available until replacement validation. Recovery preserves: The requested search-result change was not accepted. The saved item remains unchanged."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: The requested search-result change was not accepted. The saved item remains unchanged."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Clear Search announces result and consequence; success focuses the Clear Search destination, Trust heading, or updated results heading in Search entry — Action Rejected; rejection focuses the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search entry — Action Rejected. Dynamic Type stacks results and previews. The announcement first communicates: The requested search-result change was not accepted. The saved item remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-ACTION-REJECTED-001"
label = "Clear Search"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the local query field and safely re-resolved results from Search entry — Action Rejected"
destination_id = "DEST-SEARCH-ROOT-ACTION-REJECTED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: The requested search-result change was not accepted. The saved item remains unchanged."
success_focus = "the Clear Search destination, Trust heading, or updated results heading in Search entry — Action Rejected"
success_focus_id = "FOCUS-SEARCH-ROOT-ACTION-REJECTED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search entry — Action Rejected"
failure_focus_id = "FOCUS-SEARCH-ROOT-ACTION-REJECTED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: query editing and clearing remain before any owner-owned material action or canonical commit."
rollback_undo = "No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence."
recovery_id = "RECOVERY-SEARCH-ROOT-ACTION-REJECTED-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-ACTION-VALIDATING"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Inspect Source => destination: the contextual Trust Source inspection for the re-resolved canonical result from Search entry — Action Validating; effect: No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: A proposed search-result change is being checked. The saved item remains unchanged.; focus: the Inspect Source destination, Trust heading, or updated results heading in Search entry — Action Validating."
durable_effect = "Exact local Find, Act, and Inspect consequences: Inspect Source: No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: A proposed search-result change is being checked. The saved item remains unchanged. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: A proposed search-result change is being checked. The saved item remains unchanged."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Inspect Source: No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content. The prior valid index stays available until replacement validation. Recovery preserves: A proposed search-result change is being checked. The saved item remains unchanged."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: A proposed search-result change is being checked. The saved item remains unchanged."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Inspect Source announces result and consequence; success focuses the Inspect Source destination, Trust heading, or updated results heading in Search entry — Action Validating; rejection focuses the selected result and exact Inspect Source rejection, privacy, stale, or deletion reason in Search entry — Action Validating. Dynamic Type stacks results and previews. The announcement first communicates: A proposed search-result change is being checked. The saved item remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-ACTION-VALIDATING-001"
label = "Inspect Source"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the contextual Trust Source inspection for the re-resolved canonical result from Search entry — Action Validating"
destination_id = "DEST-SEARCH-ROOT-ACTION-VALIDATING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: A proposed search-result change is being checked. The saved item remains unchanged."
success_focus = "the Inspect Source destination, Trust heading, or updated results heading in Search entry — Action Validating"
success_focus_id = "FOCUS-SEARCH-ROOT-ACTION-VALIDATING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Inspect Source rejection, privacy, stale, or deletion reason in Search entry — Action Validating"
failure_focus_id = "FOCUS-SEARCH-ROOT-ACTION-VALIDATING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
recovery_id = "RECOVERY-SEARCH-ROOT-ACTION-VALIDATING-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-CORRUPT-INDEX"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Rebuild Search => destination: the staged local-index rebuild progress and restored query results from Search entry — Corrupt Index; effect: No durable mutation of canonical product state occurs and no Receipt is created; Rebuild Search derives a staged local index only from canonical projections. The prior valid index remains served until replacement validation succeeds; corrupt output is quarantined, and only a validated derived index swaps atomically. Visible evidence remains: The local search list cannot be read safely. Saved Goals, Steps, Captures, and time remain intact.; focus: the Rebuild Search destination, Trust heading, or updated results heading in Search entry — Corrupt Index."
durable_effect = "Exact local Find, Act, and Inspect consequences: Rebuild Search: No durable mutation of canonical product state occurs and no Receipt is created; Rebuild Search derives a staged local index only from canonical projections. The prior valid index remains served until replacement validation succeeds; corrupt output is quarantined, and only a validated derived index swaps atomically. Visible evidence remains: The local search list cannot be read safely. Saved Goals, Steps, Captures, and time remain intact. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: The local search list cannot be read safely. Saved Goals, Steps, Captures, and time remain intact."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Rebuild Search: No canonical Undo is required; failed or cancelled rebuild discards staged output, retains the prior valid index, and restores the prior query and filters. The prior valid index stays available until replacement validation. Recovery preserves: The local search list cannot be read safely. Saved Goals, Steps, Captures, and time remain intact."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: The local search list cannot be read safely. Saved Goals, Steps, Captures, and time remain intact."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Rebuild Search announces result and consequence; success focuses the Rebuild Search destination, Trust heading, or updated results heading in Search entry — Corrupt Index; rejection focuses the selected result and exact Rebuild Search rejection, privacy, stale, or deletion reason in Search entry — Corrupt Index. Dynamic Type stacks results and previews. The announcement first communicates: The local search list cannot be read safely. Saved Goals, Steps, Captures, and time remain intact."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-CORRUPT-INDEX-001"
label = "Rebuild Search"
canonical_owner = "global.search.command-contract"
preconditions = ["A prior valid index remains available until a staged replacement validates", "Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "Canonical projections remain the only rebuild input and cannot be repaired or mutated by Search", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the staged local-index rebuild progress and restored query results from Search entry — Corrupt Index"
destination_id = "DEST-SEARCH-ROOT-CORRUPT-INDEX-001"
destination_posture = "current"
effect = "No durable mutation of canonical product state occurs and no Receipt is created; Rebuild Search derives a staged local index only from canonical projections. The prior valid index remains served until replacement validation succeeds; corrupt output is quarantined, and only a validated derived index swaps atomically. Visible evidence remains: The local search list cannot be read safely. Saved Goals, Steps, Captures, and time remain intact."
success_focus = "the Rebuild Search destination, Trust heading, or updated results heading in Search entry — Corrupt Index"
success_focus_id = "FOCUS-SEARCH-ROOT-CORRUPT-INDEX-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Rebuild Search rejection, privacy, stale, or deletion reason in Search entry — Corrupt Index"
failure_focus_id = "FOCUS-SEARCH-ROOT-CORRUPT-INDEX-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Search rebuild changes only a validated derived local index and never commits a canonical object, repair, or generic mutation."
rollback_undo = "No canonical Undo is required; failed or cancelled rebuild discards staged output, retains the prior valid index, and restores the prior query and filters."
recovery_id = "RECOVERY-SEARCH-ROOT-CORRUPT-INDEX-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-EMPTY-QUERY"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Filters => destination: the local Search filter controls from Search entry — Empty Query; effect: No durable mutation occurs and no Receipt is created; Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Search has no words entered. No results are shown, and saved items are unchanged.; focus: the Filters destination, Trust heading, or updated results heading in Search entry — Empty Query."
durable_effect = "Exact local Find, Act, and Inspect consequences: Filters: No durable mutation occurs and no Receipt is created; Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Search has no words entered. No results are shown, and saved items are unchanged. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Search has no words entered. No results are shown, and saved items are unchanged."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Filters: No Undo is required; dismissal or Clear Filters restores the prior or unfiltered query projection without changing saved objects. The prior valid index stays available until replacement validation. Recovery preserves: Search has no words entered. No results are shown, and saved items are unchanged."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Search has no words entered. No results are shown, and saved items are unchanged."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Filters announces result and consequence; success focuses the Filters destination, Trust heading, or updated results heading in Search entry — Empty Query; rejection focuses the selected result and exact Filters rejection, privacy, stale, or deletion reason in Search entry — Empty Query. Dynamic Type stacks results and previews. The announcement first communicates: Search has no words entered. No results are shown, and saved items are unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-EMPTY-QUERY-001"
label = "Filters"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the local Search filter controls from Search entry — Empty Query"
destination_id = "DEST-SEARCH-ROOT-EMPTY-QUERY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Search has no words entered. No results are shown, and saved items are unchanged."
success_focus = "the Filters destination, Trust heading, or updated results heading in Search entry — Empty Query"
success_focus_id = "FOCUS-SEARCH-ROOT-EMPTY-QUERY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Filters rejection, privacy, stale, or deletion reason in Search entry — Empty Query"
failure_focus_id = "FOCUS-SEARCH-ROOT-EMPTY-QUERY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: filter presentation and selection remain local projection state and cross no canonical commit boundary."
rollback_undo = "No Undo is required; dismissal or Clear Filters restores the prior or unfiltered query projection without changing saved objects."
recovery_id = "RECOVERY-SEARCH-ROOT-EMPTY-QUERY-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-INSPECTION-HANDOFF"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Inspect Privacy => destination: the contextual Trust Privacy inspection for the re-resolved canonical result from Search entry — Inspection Handoff; effect: No durable mutation occurs and no Receipt is created; Inspect Privacy opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Search shows a selected match. The matched item remains unchanged.; focus: the Inspect Privacy destination, Trust heading, or updated results heading in Search entry — Inspection Handoff."
durable_effect = "Exact local Find, Act, and Inspect consequences: Inspect Privacy: No durable mutation occurs and no Receipt is created; Inspect Privacy opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Search shows a selected match. The matched item remains unchanged. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Search shows a selected match. The matched item remains unchanged."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Inspect Privacy: No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content. The prior valid index stays available until replacement validation. Recovery preserves: Search shows a selected match. The matched item remains unchanged."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Search shows a selected match. The matched item remains unchanged."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Inspect Privacy announces result and consequence; success focuses the Inspect Privacy destination, Trust heading, or updated results heading in Search entry — Inspection Handoff; rejection focuses the selected result and exact Inspect Privacy rejection, privacy, stale, or deletion reason in Search entry — Inspection Handoff. Dynamic Type stacks results and previews. The announcement first communicates: Search shows a selected match. The matched item remains unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-INSPECTION-HANDOFF-001"
label = "Inspect Privacy"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the contextual Trust Privacy inspection for the re-resolved canonical result from Search entry — Inspection Handoff"
destination_id = "DEST-SEARCH-ROOT-INSPECTION-HANDOFF-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect Privacy opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Search shows a selected match. The matched item remains unchanged."
success_focus = "the Inspect Privacy destination, Trust heading, or updated results heading in Search entry — Inspection Handoff"
success_focus_id = "FOCUS-SEARCH-ROOT-INSPECTION-HANDOFF-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Inspect Privacy rejection, privacy, stale, or deletion reason in Search entry — Inspection Handoff"
failure_focus_id = "FOCUS-SEARCH-ROOT-INSPECTION-HANDOFF-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
recovery_id = "RECOVERY-SEARCH-ROOT-INSPECTION-HANDOFF-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-OFFLINE-HEALTHY"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Clear Search => destination: the local query field and safely re-resolved results from Search entry — Offline Healthy; effect: No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: Local search remains available without a connection.; focus: the Clear Search destination, Trust heading, or updated results heading in Search entry — Offline Healthy."
durable_effect = "Exact local Find, Act, and Inspect consequences: Clear Search: No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: Local search remains available without a connection. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Local search remains available without a connection."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Clear Search: No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence. The prior valid index stays available until replacement validation. Recovery preserves: Local search remains available without a connection."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Local search remains available without a connection."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Clear Search announces result and consequence; success focuses the Clear Search destination, Trust heading, or updated results heading in Search entry — Offline Healthy; rejection focuses the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search entry — Offline Healthy. Dynamic Type stacks results and previews. The announcement first communicates: Local search remains available without a connection."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-OFFLINE-HEALTHY-001"
label = "Clear Search"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the local query field and safely re-resolved results from Search entry — Offline Healthy"
destination_id = "DEST-SEARCH-ROOT-OFFLINE-HEALTHY-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: Local search remains available without a connection."
success_focus = "the Clear Search destination, Trust heading, or updated results heading in Search entry — Offline Healthy"
success_focus_id = "FOCUS-SEARCH-ROOT-OFFLINE-HEALTHY-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search entry — Offline Healthy"
failure_focus_id = "FOCUS-SEARCH-ROOT-OFFLINE-HEALTHY-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: query editing and clearing remain before any owner-owned material action or canonical commit."
rollback_undo = "No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence."
recovery_id = "RECOVERY-SEARCH-ROOT-OFFLINE-HEALTHY-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-PARTIAL-RESULTS"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Inspect Source => destination: the contextual Trust Source inspection for the re-resolved canonical result from Search entry — Partial Results; effect: No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Only part of the local result set is available, and the missing scope is named.; focus: the Inspect Source destination, Trust heading, or updated results heading in Search entry — Partial Results."
durable_effect = "Exact local Find, Act, and Inspect consequences: Inspect Source: No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Only part of the local result set is available, and the missing scope is named. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Only part of the local result set is available, and the missing scope is named."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Inspect Source: No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content. The prior valid index stays available until replacement validation. Recovery preserves: Only part of the local result set is available, and the missing scope is named."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Only part of the local result set is available, and the missing scope is named."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Inspect Source announces result and consequence; success focuses the Inspect Source destination, Trust heading, or updated results heading in Search entry — Partial Results; rejection focuses the selected result and exact Inspect Source rejection, privacy, stale, or deletion reason in Search entry — Partial Results. Dynamic Type stacks results and previews. The announcement first communicates: Only part of the local result set is available, and the missing scope is named."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-PARTIAL-RESULTS-001"
label = "Inspect Source"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the contextual Trust Source inspection for the re-resolved canonical result from Search entry — Partial Results"
destination_id = "DEST-SEARCH-ROOT-PARTIAL-RESULTS-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Only part of the local result set is available, and the missing scope is named."
success_focus = "the Inspect Source destination, Trust heading, or updated results heading in Search entry — Partial Results"
success_focus_id = "FOCUS-SEARCH-ROOT-PARTIAL-RESULTS-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Inspect Source rejection, privacy, stale, or deletion reason in Search entry — Partial Results"
failure_focus_id = "FOCUS-SEARCH-ROOT-PARTIAL-RESULTS-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
recovery_id = "RECOVERY-SEARCH-ROOT-PARTIAL-RESULTS-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-PERMISSION-DENIED"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Inspect Privacy => destination: the contextual Trust Privacy inspection for the re-resolved canonical result from Search entry — Permission Denied; effect: No durable mutation occurs and no Receipt is created; Inspect Privacy opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: A protected result cannot be shown with the current access; other local results remain available.; focus: the Inspect Privacy destination, Trust heading, or updated results heading in Search entry — Permission Denied."
durable_effect = "Exact local Find, Act, and Inspect consequences: Inspect Privacy: No durable mutation occurs and no Receipt is created; Inspect Privacy opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: A protected result cannot be shown with the current access; other local results remain available. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: A protected result cannot be shown with the current access; other local results remain available."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Inspect Privacy: No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content. The prior valid index stays available until replacement validation. Recovery preserves: A protected result cannot be shown with the current access; other local results remain available."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: A protected result cannot be shown with the current access; other local results remain available."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Inspect Privacy announces result and consequence; success focuses the Inspect Privacy destination, Trust heading, or updated results heading in Search entry — Permission Denied; rejection focuses the selected result and exact Inspect Privacy rejection, privacy, stale, or deletion reason in Search entry — Permission Denied. Dynamic Type stacks results and previews. The announcement first communicates: A protected result cannot be shown with the current access; other local results remain available."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-PERMISSION-DENIED-001"
label = "Inspect Privacy"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the contextual Trust Privacy inspection for the re-resolved canonical result from Search entry — Permission Denied"
destination_id = "DEST-SEARCH-ROOT-PERMISSION-DENIED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect Privacy opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: A protected result cannot be shown with the current access; other local results remain available."
success_focus = "the Inspect Privacy destination, Trust heading, or updated results heading in Search entry — Permission Denied"
success_focus_id = "FOCUS-SEARCH-ROOT-PERMISSION-DENIED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Inspect Privacy rejection, privacy, stale, or deletion reason in Search entry — Permission Denied"
failure_focus_id = "FOCUS-SEARCH-ROOT-PERMISSION-DENIED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
recovery_id = "RECOVERY-SEARCH-ROOT-PERMISSION-DENIED-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-PRIVACY-SUPPRESSED"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Inspect Privacy => destination: the contextual Trust Privacy inspection for the re-resolved canonical result from Search entry — Privacy Suppressed; effect: No durable mutation occurs and no Receipt is created; Inspect Privacy opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Some matches are hidden by privacy rules. Ambitions will not reveal their content in this context.; focus: the Inspect Privacy destination, Trust heading, or updated results heading in Search entry — Privacy Suppressed."
durable_effect = "Exact local Find, Act, and Inspect consequences: Inspect Privacy: No durable mutation occurs and no Receipt is created; Inspect Privacy opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Some matches are hidden by privacy rules. Ambitions will not reveal their content in this context. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Some matches are hidden by privacy rules. Ambitions will not reveal their content in this context."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Inspect Privacy: No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content. The prior valid index stays available until replacement validation. Recovery preserves: Some matches are hidden by privacy rules. Ambitions will not reveal their content in this context."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Some matches are hidden by privacy rules. Ambitions will not reveal their content in this context."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Inspect Privacy announces result and consequence; success focuses the Inspect Privacy destination, Trust heading, or updated results heading in Search entry — Privacy Suppressed; rejection focuses the selected result and exact Inspect Privacy rejection, privacy, stale, or deletion reason in Search entry — Privacy Suppressed. Dynamic Type stacks results and previews. The announcement first communicates: Some matches are hidden by privacy rules. Ambitions will not reveal their content in this context."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-PRIVACY-SUPPRESSED-001"
label = "Inspect Privacy"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the contextual Trust Privacy inspection for the re-resolved canonical result from Search entry — Privacy Suppressed"
destination_id = "DEST-SEARCH-ROOT-PRIVACY-SUPPRESSED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Inspect Privacy opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Some matches are hidden by privacy rules. Ambitions will not reveal their content in this context."
success_focus = "the Inspect Privacy destination, Trust heading, or updated results heading in Search entry — Privacy Suppressed"
success_focus_id = "FOCUS-SEARCH-ROOT-PRIVACY-SUPPRESSED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Inspect Privacy rejection, privacy, stale, or deletion reason in Search entry — Privacy Suppressed"
failure_focus_id = "FOCUS-SEARCH-ROOT-PRIVACY-SUPPRESSED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
recovery_id = "RECOVERY-SEARCH-ROOT-PRIVACY-SUPPRESSED-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-QUERYING"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Clear Search => destination: the local query field and safely re-resolved results from Search entry — Querying; effect: No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: Search is checking saved Goals, Steps, Captures, and time.; focus: the Clear Search destination, Trust heading, or updated results heading in Search entry — Querying."
durable_effect = "Exact local Find, Act, and Inspect consequences: Clear Search: No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: Search is checking saved Goals, Steps, Captures, and time. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Search is checking saved Goals, Steps, Captures, and time."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Clear Search: No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence. The prior valid index stays available until replacement validation. Recovery preserves: Search is checking saved Goals, Steps, Captures, and time."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Search is checking saved Goals, Steps, Captures, and time."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Clear Search announces result and consequence; success focuses the Clear Search destination, Trust heading, or updated results heading in Search entry — Querying; rejection focuses the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search entry — Querying. Dynamic Type stacks results and previews. The announcement first communicates: Search is checking saved Goals, Steps, Captures, and time."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-QUERYING-001"
label = "Clear Search"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the local query field and safely re-resolved results from Search entry — Querying"
destination_id = "DEST-SEARCH-ROOT-QUERYING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: Search is checking saved Goals, Steps, Captures, and time."
success_focus = "the Clear Search destination, Trust heading, or updated results heading in Search entry — Querying"
success_focus_id = "FOCUS-SEARCH-ROOT-QUERYING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search entry — Querying"
failure_focus_id = "FOCUS-SEARCH-ROOT-QUERYING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: query editing and clearing remain before any owner-owned material action or canonical commit."
rollback_undo = "No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence."
recovery_id = "RECOVERY-SEARCH-ROOT-QUERYING-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-REBUILDING"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Cancel Rebuild => destination: the prior valid index with the restored query and filters from Search entry — Rebuilding; effect: No durable mutation occurs and no Receipt is created; Cancel Rebuild discards only staged derived-index work. The prior valid index, canonical objects, query, and filters remain intact, and corrupt staged output stays quarantined. Visible evidence remains: Search is rebuilding its local list. Matches may be incomplete until the list is ready.; focus: the Cancel Rebuild destination, Trust heading, or updated results heading in Search entry — Rebuilding."
durable_effect = "Exact local Find, Act, and Inspect consequences: Cancel Rebuild: No durable mutation occurs and no Receipt is created; Cancel Rebuild discards only staged derived-index work. The prior valid index, canonical objects, query, and filters remain intact, and corrupt staged output stays quarantined. Visible evidence remains: Search is rebuilding its local list. Matches may be incomplete until the list is ready. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Search is rebuilding its local list. Matches may be incomplete until the list is ready."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Cancel Rebuild: No Undo is required; a later rebuild starts from current canonical projections and a new generation identity. The prior valid index stays available until replacement validation. Recovery preserves: Search is rebuilding its local list. Matches may be incomplete until the list is ready."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Search is rebuilding its local list. Matches may be incomplete until the list is ready."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Cancel Rebuild announces result and consequence; success focuses the Cancel Rebuild destination, Trust heading, or updated results heading in Search entry — Rebuilding; rejection focuses the selected result and exact Cancel Rebuild rejection, privacy, stale, or deletion reason in Search entry — Rebuilding. Dynamic Type stacks results and previews. The announcement first communicates: Search is rebuilding its local list. Matches may be incomplete until the list is ready."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-REBUILDING-001"
label = "Cancel Rebuild"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the prior valid index with the restored query and filters from Search entry — Rebuilding"
destination_id = "DEST-SEARCH-ROOT-REBUILDING-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Cancel Rebuild discards only staged derived-index work. The prior valid index, canonical objects, query, and filters remain intact, and corrupt staged output stays quarantined. Visible evidence remains: Search is rebuilding its local list. Matches may be incomplete until the list is ready."
success_focus = "the Cancel Rebuild destination, Trust heading, or updated results heading in Search entry — Rebuilding"
success_focus_id = "FOCUS-SEARCH-ROOT-REBUILDING-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Cancel Rebuild rejection, privacy, stale, or deletion reason in Search entry — Rebuilding"
failure_focus_id = "FOCUS-SEARCH-ROOT-REBUILDING-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: cancellation retains the prior valid derived index and crosses no canonical boundary."
rollback_undo = "No Undo is required; a later rebuild starts from current canonical projections and a new generation identity."
recovery_id = "RECOVERY-SEARCH-ROOT-REBUILDING-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-RECENT"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Clear Search => destination: the local query field and safely re-resolved results from Search entry — Recent; effect: No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: Recent search words appear on this device. Saved Goals, Steps, Captures, and time remain unchanged.; focus: the Clear Search destination, Trust heading, or updated results heading in Search entry — Recent."
durable_effect = "Exact local Find, Act, and Inspect consequences: Clear Search: No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: Recent search words appear on this device. Saved Goals, Steps, Captures, and time remain unchanged. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Recent search words appear on this device. Saved Goals, Steps, Captures, and time remain unchanged."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Clear Search: No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence. The prior valid index stays available until replacement validation. Recovery preserves: Recent search words appear on this device. Saved Goals, Steps, Captures, and time remain unchanged."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Recent search words appear on this device. Saved Goals, Steps, Captures, and time remain unchanged."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Clear Search announces result and consequence; success focuses the Clear Search destination, Trust heading, or updated results heading in Search entry — Recent; rejection focuses the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search entry — Recent. Dynamic Type stacks results and previews. The announcement first communicates: Recent search words appear on this device. Saved Goals, Steps, Captures, and time remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-RECENT-001"
label = "Clear Search"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the local query field and safely re-resolved results from Search entry — Recent"
destination_id = "DEST-SEARCH-ROOT-RECENT-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: Recent search words appear on this device. Saved Goals, Steps, Captures, and time remain unchanged."
success_focus = "the Clear Search destination, Trust heading, or updated results heading in Search entry — Recent"
success_focus_id = "FOCUS-SEARCH-ROOT-RECENT-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search entry — Recent"
failure_focus_id = "FOCUS-SEARCH-ROOT-RECENT-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: query editing and clearing remain before any owner-owned material action or canonical commit."
rollback_undo = "No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence."
recovery_id = "RECOVERY-SEARCH-ROOT-RECENT-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-RESTORED"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Filters => destination: the local Search filter controls from Search entry — Restored; effect: No durable mutation occurs and no Receipt is created; Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Earlier search words and filters are visible again. Results may still be out of date.; focus: the Filters destination, Trust heading, or updated results heading in Search entry — Restored."
durable_effect = "Exact local Find, Act, and Inspect consequences: Filters: No durable mutation occurs and no Receipt is created; Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Earlier search words and filters are visible again. Results may still be out of date. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Earlier search words and filters are visible again. Results may still be out of date."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Filters: No Undo is required; dismissal or Clear Filters restores the prior or unfiltered query projection without changing saved objects. The prior valid index stays available until replacement validation. Recovery preserves: Earlier search words and filters are visible again. Results may still be out of date."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Earlier search words and filters are visible again. Results may still be out of date."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Filters announces result and consequence; success focuses the Filters destination, Trust heading, or updated results heading in Search entry — Restored; rejection focuses the selected result and exact Filters rejection, privacy, stale, or deletion reason in Search entry — Restored. Dynamic Type stacks results and previews. The announcement first communicates: Earlier search words and filters are visible again. Results may still be out of date."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-RESTORED-001"
label = "Filters"
canonical_owner = "global.search.command-contract"
preconditions = ["Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the local Search filter controls from Search entry — Restored"
destination_id = "DEST-SEARCH-ROOT-RESTORED-001"
destination_posture = "current"
effect = "No durable mutation occurs and no Receipt is created; Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Earlier search words and filters are visible again. Results may still be out of date."
success_focus = "the Filters destination, Trust heading, or updated results heading in Search entry — Restored"
success_focus_id = "FOCUS-SEARCH-ROOT-RESTORED-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Filters rejection, privacy, stale, or deletion reason in Search entry — Restored"
failure_focus_id = "FOCUS-SEARCH-ROOT-RESTORED-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: filter presentation and selection remain local projection state and cross no canonical commit boundary."
rollback_undo = "No Undo is required; dismissal or Clear Filters restores the prior or unfiltered query projection without changing saved objects."
recovery_id = "RECOVERY-SEARCH-ROOT-RESTORED-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-STALE-INDEX"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Rebuild Search => destination: the staged local-index rebuild progress and restored query results from Search entry — Stale Index; effect: No durable mutation of canonical product state occurs and no Receipt is created; Rebuild Search derives a staged local index only from canonical projections. The prior valid index remains served until replacement validation succeeds; corrupt output is quarantined, and only a validated derived index swaps atomically. Visible evidence remains: Search results may be out of date. Saved Goals, Steps, Captures, and time remain unchanged.; focus: the Rebuild Search destination, Trust heading, or updated results heading in Search entry — Stale Index."
durable_effect = "Exact local Find, Act, and Inspect consequences: Rebuild Search: No durable mutation of canonical product state occurs and no Receipt is created; Rebuild Search derives a staged local index only from canonical projections. The prior valid index remains served until replacement validation succeeds; corrupt output is quarantined, and only a validated derived index swaps atomically. Visible evidence remains: Search results may be out of date. Saved Goals, Steps, Captures, and time remain unchanged. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: Search results may be out of date. Saved Goals, Steps, Captures, and time remain unchanged."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Rebuild Search: No canonical Undo is required; failed or cancelled rebuild discards staged output, retains the prior valid index, and restores the prior query and filters. The prior valid index stays available until replacement validation. Recovery preserves: Search results may be out of date. Saved Goals, Steps, Captures, and time remain unchanged."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: Search results may be out of date. Saved Goals, Steps, Captures, and time remain unchanged."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Rebuild Search announces result and consequence; success focuses the Rebuild Search destination, Trust heading, or updated results heading in Search entry — Stale Index; rejection focuses the selected result and exact Rebuild Search rejection, privacy, stale, or deletion reason in Search entry — Stale Index. Dynamic Type stacks results and previews. The announcement first communicates: Search results may be out of date. Saved Goals, Steps, Captures, and time remain unchanged."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-STALE-INDEX-001"
label = "Rebuild Search"
canonical_owner = "global.search.command-contract"
preconditions = ["A prior valid index remains available until a staged replacement validates", "Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "Canonical projections remain the only rebuild input and cannot be repaired or mutated by Search", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the staged local-index rebuild progress and restored query results from Search entry — Stale Index"
destination_id = "DEST-SEARCH-ROOT-STALE-INDEX-001"
destination_posture = "current"
effect = "No durable mutation of canonical product state occurs and no Receipt is created; Rebuild Search derives a staged local index only from canonical projections. The prior valid index remains served until replacement validation succeeds; corrupt output is quarantined, and only a validated derived index swaps atomically. Visible evidence remains: Search results may be out of date. Saved Goals, Steps, Captures, and time remain unchanged."
success_focus = "the Rebuild Search destination, Trust heading, or updated results heading in Search entry — Stale Index"
success_focus_id = "FOCUS-SEARCH-ROOT-STALE-INDEX-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Rebuild Search rejection, privacy, stale, or deletion reason in Search entry — Stale Index"
failure_focus_id = "FOCUS-SEARCH-ROOT-STALE-INDEX-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Search rebuild changes only a validated derived local index and never commits a canonical object, repair, or generic mutation."
rollback_undo = "No canonical Undo is required; failed or cancelled rebuild discards staged output, retains the prior valid index, and restores the prior query and filters."
recovery_id = "RECOVERY-SEARCH-ROOT-STALE-INDEX-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

[[state_command_contracts]]
state_id = "UX-STATE-VARIANT-SEARCH-ROOT-UNAVAILABLE-PROJECTION"
requirement_id = "SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001"
activation_posture = "active"
gate_requirement_ids = []
transition_exit = "Rebuild Search => destination: the staged local-index rebuild progress and restored query results from Search entry — Unavailable Projection; effect: No durable mutation of canonical product state occurs and no Receipt is created; Rebuild Search derives a staged local index only from canonical projections. The prior valid index remains served until replacement validation succeeds; corrupt output is quarantined, and only a validated derived index swaps atomically. Visible evidence remains: The requested search view is temporarily unavailable. Saved Goals, Steps, Captures, and time remain available.; focus: the Rebuild Search destination, Trust heading, or updated results heading in Search entry — Unavailable Projection."
durable_effect = "Exact local Find, Act, and Inspect consequences: Rebuild Search: No durable mutation of canonical product state occurs and no Receipt is created; Rebuild Search derives a staged local index only from canonical projections. The prior valid index remains served until replacement validation succeeds; corrupt output is quarantined, and only a validated derived index swaps atomically. Visible evidence remains: The requested search view is temporarily unavailable. Saved Goals, Steps, Captures, and time remain available. Result actions re-resolve current object revision and route to resolved object owners; Search owns no generic mutation. Rebuild affects only a validated derived index. Current visible status: The requested search view is temporarily unavailable. Saved Goals, Steps, Captures, and time remain available."
recovery_rollback = "Exact stale, deleted, partial, privacy-suppressed, corrupt-index, rebuild, owner-Undo, and inspection recovery: Rebuild Search: No canonical Undo is required; failed or cancelled rebuild discards staged output, retains the prior valid index, and restores the prior query and filters. The prior valid index stays available until replacement validation. Recovery preserves: The requested search view is temporarily unavailable. Saved Goals, Steps, Captures, and time remain available."
offline_behavior = "Local query, filters, canonical projections, prior valid index, Trust evidence, and owner routes remain available offline. Search never needs a network or cloud service; unavailable protected facts stay suppressed. Offline evidence remains: The requested search view is temporarily unavailable. Saved Goals, Steps, Captures, and time remain available."
accessibility_focus = "VoiceOver announces query state, result group and count, match text, owner, privacy suppression, action consequence, and Trust destination without color dependence: Rebuild Search announces result and consequence; success focuses the Rebuild Search destination, Trust heading, or updated results heading in Search entry — Unavailable Projection; rejection focuses the selected result and exact Rebuild Search rejection, privacy, stale, or deletion reason in Search entry — Unavailable Projection. Dynamic Type stacks results and previews. The announcement first communicates: The requested search view is temporarily unavailable. Saved Goals, Steps, Captures, and time remain available."

[[state_command_contracts.commands]]
command_id = "CMD-SEARCH-ROOT-UNAVAILABLE-PROJECTION-001"
label = "Rebuild Search"
canonical_owner = "global.search.command-contract"
preconditions = ["A prior valid index remains available until a staged replacement validates", "Any selected result is re-resolved by resolved object owner, stable identity, current object revision, deletion posture, and disclosure eligibility", "Canonical projections remain the only rebuild input and cannot be repaired or mutated by Search", "The current query, filters, index generation, route, and privacy authorization have been revalidated"]
destination = "the staged local-index rebuild progress and restored query results from Search entry — Unavailable Projection"
destination_id = "DEST-SEARCH-ROOT-UNAVAILABLE-PROJECTION-001"
destination_posture = "current"
effect = "No durable mutation of canonical product state occurs and no Receipt is created; Rebuild Search derives a staged local index only from canonical projections. The prior valid index remains served until replacement validation succeeds; corrupt output is quarantined, and only a validated derived index swaps atomically. Visible evidence remains: The requested search view is temporarily unavailable. Saved Goals, Steps, Captures, and time remain available."
success_focus = "the Rebuild Search destination, Trust heading, or updated results heading in Search entry — Unavailable Projection"
success_focus_id = "FOCUS-SEARCH-ROOT-UNAVAILABLE-PROJECTION-001-SUCCESS"
success_focus_posture = "current"
failure_focus = "the selected result and exact Rebuild Search rejection, privacy, stale, or deletion reason in Search entry — Unavailable Projection"
failure_focus_id = "FOCUS-SEARCH-ROOT-UNAVAILABLE-PROJECTION-001-FAILURE"
failure_focus_posture = "current"
commit_boundary = "Non-mutating: Search rebuild changes only a validated derived local index and never commits a canonical object, repair, or generic mutation."
rollback_undo = "No canonical Undo is required; failed or cancelled rebuild discards staged output, retains the prior valid index, and restores the prior query and filters."
recovery_id = "RECOVERY-SEARCH-ROOT-UNAVAILABLE-PROJECTION-001"
recovery_posture = "current"
recovery_owner = "global.search.command-contract"
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

+++

# Search

Search uses `surface-v1` because it presents one full-screen Find, Ask, Act, and Inspect experience with visible result, answer, evidence, proposal, action, state, accessibility, and visual contracts. It remains a global overlay/evolution, never a root tab or generic AI destination.

## SPEC-GLOBAL-SEARCH-PRIVATE-COMMAND-LAYER-001 — Unified local Find, Ask, Act, and Inspect

- **Concept:** `global.search.identity`
- **Modality:** `MUST`
- **Scope:** Global Search presentation and behavior
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-PRIVATE-COMMAND-LAYER-001`
- **Supersedes:** `CLAIM-LFT-0163`, `CLAIM-LFT-0182`, `CLAIM-STB-0306`, `SPEC-GLOBAL-SEARCH-IDENTITY-001`

Search MUST be one unified, local-first Find / Ask / Act / Inspect surface. Search offline degradation MUST return gracefully to deterministic Find / Act / Inspect behavior, and Search MUST remain fully useful without conversational intelligence. Search MUST NOT use hosted AI, MUST NOT perform cloud profiling, and MUST NOT transfer the private life graph. It is not command-line theater, a shallow utility sheet, a root, an alternate canonical store, or a generic AI destination.

## SPEC-GLOBAL-SEARCH-FIND-001 — Immediate deterministic local retrieval

- **Concept:** `global.search.find`
- **Modality:** `MUST`
- **Scope:** Exact and natural-language retrieval before optional synthesis
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-FIND-001`, `TEST-SEARCH-RANKING-001`
- **Supersedes:** none

Find MUST provide immediate, deterministic, offline retrieval across privacy-authorized local objects and projections while the user types. Exact, prefix, typo-tolerant, date, status, context, and approved semantic matches remain projection-fed, measurable, privacy-filtered, and useful without Ask, an account, a network, or a model.

## SPEC-GLOBAL-SEARCH-ASK-001 — Optional grounded on-device synthesis

- **Concept:** `global.search.ask`
- **Modality:** `MAY`
- **Scope:** Conversational interpretation and synthesis inside Global Search
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-ASK-GROUNDING-001`, `SCENARIO-SEARCH-ASK-UNAVAILABLE-001`
- **Supersedes:** none

Ask MAY provide conversational, on-device synthesis grounded only in privacy-authorized Ambitions data and approved reference sources. Every substantive answer MUST expose its supporting objects, sources, assumptions, and uncertainty through the answer-evidence contract. Ask MUST remain optional: when conversational intelligence is unavailable, Search continues through deterministic Find / Act / Inspect without withholding local results, safe actions, or Trust inspection.

## SPEC-GLOBAL-SEARCH-ASK-COMMAND-CONTRACT-001 — Ask controls preserve deterministic Search and owner boundaries

- **Concept:** `global.search.ask-command-contract`
- **Modality:** `MUST`
- **Scope:** Optional on-device synthesis, interruption, fallback, evidence inspection, and Capture transition
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-ASK-GROUNDING-001`, `SCENARIO-SEARCH-ASK-UNAVAILABLE-001`, `SCENARIO-SEARCH-CAPTURE-HANDOFF-001`, `SCENARIO-SEARCH-SESSION-HISTORY-001`
- **Supersedes:** none

Ask state controls MUST remain local, session-bound, non-mutating, and subordinate to already-available deterministic results. Search exposes `Retry Ask`, `Resume Ask`, and `Cancel Ask` only for optional on-device synthesis. One applicable contextual Inspect route MUST keep `Source`, `Privacy`, `History`, `Proof`, and `Receipts` available as read-only sections without forcing an unnecessary context exit; state-specific `Inspect Source` and `Inspect Privacy` controls may open that route at the relevant section. `Open Capture` transfers accepted creation intent and privacy-authorized source context without creating or mutating a canonical object in Search. Failure, cancellation, interruption, and offline unavailability preserve the current query and deterministic Find / Act / Inspect results. Every Ask and Search-to-Capture handoff control remains future-gated by `SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001`; this target contract authorizes no current implementation behavior.

## SPEC-GLOBAL-SEARCH-ASK-ACTIVATION-GATE-001 — Ask remains non-authorizing until exact proof is current

- **Concept:** `global.search.ask-activation-gate`
- **Modality:** `MUST`
- **Scope:** Current implementation authorization for Ask and Search-to-Capture handoff state commands
- **Status:** `normative`
- **Verification:** `AUDIT-SEARCH-ASK-ACTIVATION-GATE-001`
- **Supersedes:** none

Ask and Search-to-Capture handoff states and commands MUST remain future-gated and non-authorizing. A posture transition is invalid unless a closed, base-owned evidence registry and verifier is already merged; every affected command has nonempty exact command dependency bindings to that base-owned evidence; current source and runtime proof, no-egress and privacy proof, grounding and deterministic-fallback proof, accessibility and visual proof, and performance proof are all current for the same canon revision and source revision; and the owner has explicitly approved the exact final Figma frame IDs. Intended canon, state mappings, command metadata, generated projections, unverified dependency text, or visual candidates MUST NOT satisfy this gate. The Search amendment creates no evidence registry, verifier, dependency kind, authorization policy, or Task 24/25 implementation. Until the base-owned mechanism and every named proof class exist and pass, deterministic Find, Act, and Inspect remain the only active Search command contract.

## SPEC-GLOBAL-SEARCH-INPUT-001 — One input, immediate results, progressive enhancement

- **Concept:** `global.search.input`
- **Modality:** `MUST`
- **Scope:** Query entry, exact retrieval, questions, action intent, and progressive answer presentation
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-UNIFIED-INPUT-001`
- **Supersedes:** none

The same input MUST support exact search, natural-language questions, and action intent. Deterministic results appear immediately while the user types; optional conversational synthesis MAY progressively enhance those results without delaying or replacing them. Answers use inline Ambitions objects, evidence, and action proposals and MUST NOT become an endless transcript.

## SPEC-GLOBAL-SEARCH-ANSWER-EVIDENCE-001 — Retrieved, inferred, and proposed states remain distinct

- **Concept:** `global.search.answer-evidence`
- **Modality:** `MUST`
- **Scope:** Every result, substantive answer, interpretation, and action proposal
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-ANSWER-EVIDENCE-001`, `PROOF-SEARCH-ANSWER-ACCESSIBILITY-001`
- **Supersedes:** none

Users MUST always be able to distinguish a retrieved fact, an inferred interpretation, and a proposed change. Each substantive answer binds supporting objects and approved sources, states material assumptions and uncertainty, and routes contextual Trust inspection without presenting inference as saved fact. Visual, Dynamic Type, non-color, and VoiceOver presentation MUST preserve these distinctions and their source links.

## SPEC-GLOBAL-SEARCH-SESSION-HISTORY-001 — Conversational history is ephemeral by default

- **Concept:** `global.search.session-history`
- **Modality:** `MUST`
- **Scope:** Questions, answers, proposals, derived objects, dismissal, interruption, and explicit persistence
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-SESSION-HISTORY-001`
- **Supersedes:** none

Conversational history MUST remain session-local by default. Persisting any question, answer, proposal, or derived object requires explicit user action and an identified canonical owner; dismissal, interruption, or ordinary session expiry MUST NOT silently create a Note, Capture, History entry, profile, training record, or canonical object.

## SPEC-GLOBAL-SEARCH-INSPECT-001 — Contextual trust inspection

- **Concept:** `global.search.inspect`
- **Modality:** `MUST`
- **Scope:** Search results, answers, interpretations, and action proposals
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-INSPECT-001`
- **Supersedes:** none

Inspect MUST allow the user to examine Source, Privacy, History, Proof, and Receipts without leaving the relevant context unnecessarily. Inspection remains read-only, privacy-authorized, focus-restoring, and explicit about unavailable, stale, inferred, or suppressed evidence.

## SPEC-GLOBAL-SEARCH-CAPTURE-HANDOFF-001 — Creation belongs to Capture

- **Concept:** `global.search.capture-handoff`
- **Modality:** `MUST`
- **Scope:** Any Search input, result, answer, or proposal that expresses creation intent
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-CAPTURE-HANDOFF-001`
- **Supersedes:** none

Creation intent MUST hand off seamlessly to Capture with the accepted source context and user-entered intent preserved. Search MUST NOT duplicate Capture's creation policy and MUST NOT become a parallel composer; Capture remains responsible for type, draft durability, consequences, confirmation, canonical-owner routing, Receipt, and Undo.

## SPEC-GLOBAL-SEARCH-PRESENTATION-001 — Ambitions-native understanding, not generic AI theater

- **Concept:** `global.search.presentation`
- **Modality:** `MUST NOT`
- **Scope:** Search layout, answer composition, conversation affordances, branding, and interaction rhythm
- **Status:** `normative`
- **Verification:** `REVIEW-SEARCH-PRESENTATION-001`, `PROOF-SEARCH-PRESENTATION-ACCESSIBILITY-001`
- **Supersedes:** none

The experience MUST NOT resemble a generic AI chatbot, chatbot bubble stream, or branded AI destination. It presents Ambitions' private understanding and command layer as object-led, source-linked, calm, concise, inspectable, and native to iPhone; progressive answers remain bounded around the current objects and user intent rather than accumulating an engagement transcript.

## SPEC-GLOBAL-SEARCH-FIRST-VIEWPORT-001 — Query and useful local results first

- **Concept:** `global.search.first-viewport`
- **Modality:** `MUST`
- **Scope:** Search first visible and semantic viewport
- **Status:** `normative`
- **Verification:** `PROOF-SEARCH-FIRST-VIEWPORT-001`
- **Supersedes:** none

The first viewport MUST foreground the query field, privacy-safe scope, useful recent or exact local results when appropriate, result identity/state, and contextual safe actions. Empty-query content remains calm and bounded; it MUST NOT become a recommendation feed, dashboard, or exposed behavioral dossier.

Time search MUST be local and object-first.

Search MUST index labels, synonyms, and relevant object state.

## SPEC-GLOBAL-SEARCH-INDEX-ACTIONS-001 — One index, canonical actions

- **Concept:** `global.search.index-actions`
- **Modality:** `MUST`
- **Scope:** Index, ranking, result presentation, actions, and inspection
- **Status:** `normative`
- **Verification:** `TEST-SEARCH-RANKING-001`, `SCENARIO-SEARCH-ACTION-001`
- **Supersedes:** none

Search index and canonical actions MUST remain separate child contracts: SPEC-GLOBAL-SEARCH-INDEX-001 owns local indexing and ranking; SPEC-GLOBAL-SEARCH-ACTIONS-001 owns validated canonical actions.

## SPEC-GLOBAL-SEARCH-VISUAL-AUTHORITY-001 — Search mapping is a scoped gap

- **Concept:** `global.search.visual-authority`
- **Modality:** `MUST`
- **Scope:** Search overlay, results, actions, and inspection visuals
- **Status:** `normative`
- **Verification:** `PROOF-SEARCH-VISUAL-MAPPING-001`
- **Supersedes:** none

Visual references MUST use stable external IDs and distinguish shell placement authority, dedicated overlay authority, and implementation proof. Owner-approved VSP-01 shell `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:87:2` governs Search placement only.

## SPEC-GLOBAL-SEARCH-INDEX-001 — Search index and ranking

- **Concept:** `global.search.index-ranking`
- **Modality:** `MUST`
- **Scope:** Local search index
- **Status:** `normative`
- **Verification:** `TEST-SEARCH-RANKING-001`
- **Supersedes:** none

Search MUST index approved local object identity, state, synonyms, and privacy-safe fields; ranking, filtering, grouping, refresh, and rebuild MUST be deterministic, measurable, local, and nonauthoritative.

## SPEC-GLOBAL-SEARCH-ACTIONS-001 — Canonical search actions

- **Concept:** `global.search.canonical-actions`
- **Modality:** `MUST`
- **Scope:** Search result actions
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-ACTION-001`
- **Supersedes:** none

Search MUST only propose actions. Search MUST NOT silently mutate canonical state and MUST NOT own a generic mutation path. Every material action MUST route through the relevant canonical owner with current-state validation, a visible consequence preview, explicit confirmation, and applicable History, Receipt, and Undo behavior; accepted commands preserve return context and refresh the same stable result identity.

Search actions MUST resolve the current canonical object, validate through its owner, preview material consequences, commit through canonical commands, and preserve Receipt, undo, and return context.

## SPEC-GLOBAL-SEARCH-COMMAND-CONTRACT-001 — Search commands preserve owner authority and derived-index safety

- **Concept:** `global.search.command-contract`
- **Modality:** `MUST`
- **Scope:** Local query, filters, selection, owner action preview, Trust inspection, stale/deleted/privacy-suppressed results, derived-index rebuild, semantic Undo handoff, focus, offline use, and accessibility
- **Status:** `normative`
- **Verification:** `SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001`
- **Supersedes:** none

Search MUST remain a local full-screen Find, Act, and Inspect overlay. It exposes query editing, `Clear Search`, `Filters`, `Apply Filters`, `Clear Filters`, result selection, owner-provided safe actions, `Inspect Source`, `Inspect Privacy`, `Inspect History`, `Inspect Receipt`, `Rebuild Search`, `Cancel Rebuild`, and owner-provided `Undo`.

Querying, filtering, selection, and action preview are non-mutating. Selecting a result routes to its canonical owner. A material action routes to an owner-owned preview, re-resolves current object revision, then commits only through that owner’s typed command. Search MUST NOT own a generic mutation path.

`Rebuild Search` may rebuild only the derived local index from canonical projections. It MUST NOT repair or mutate canonical objects. The prior valid index remains available until replacement validation succeeds; corrupt output is quarantined. Cancel retains the prior valid index.

## Completeness contract

<!-- canon-section: purpose-user-question -->
Search answers where a local object or setting is, what a privacy-authorized local fact means, what safe action can be proposed now, and what Proof, Source, History, Receipt, Privacy, assumption, or uncertainty context can be inspected.

<!-- canon-section: entry-exit -->
Entry comes from integrated shell/context, keyboard shortcut, deep link, or handoff. Dismissal restores exact root/depth/query-origin focus; opening a result records a return target; accepted action returns to the changed object or results predictably.

<!-- canon-section: routes-presentation -->
Search is full-screen non-root presentation. Result detail uses native depth or owner handoff; contextual Trust inspection is presented by Trust. Search never persists as a root or duplicates destination behavior.

<!-- canon-section: displayed-objects -->
Results show canonical identity, type, relevant status/date/context, privacy-safe excerpt, provenance/trust marker only when relevant, and safe actions. Grouping and ranking rationale remain plain and inspectable without exposing internals.

<!-- canon-section: resting-states -->
Required states are empty query, recent/local suggestions, querying, results, no results, filtered, selected, Ask unavailable with deterministic offline fallback, synthesis in progress, a bounded grounded answer with supporting objects, sources, assumptions, and uncertainty, Ask failure, interruption, resume, recovery, Capture handoff, action preview, action complete, rebuilding, restored, and privacy-suppressed.

<!-- canon-section: loading-transitional -->
Query, filter, index refresh/rebuild, optional on-device synthesis, supporting-evidence resolution, action validation, mutation, inspection handoff, and restoration are cancellable where useful and retain last valid deterministic results until replacement or progressive enhancement is ready.

<!-- canon-section: empty-degraded -->
The result-state matrix pairs each index, projection, permission, and action condition with preserved query context and repair controls.
No results offers query repair, scope/filter changes, Capture, or exact setting help without fake matches. Corrupt/stale index, unavailable projection, permission denial, partial results, offline, Ask unavailable, or action rejection states preserve query and disclose what remains searchable. Ask failure returns to the current deterministic Find / Act / Inspect results without implying loss of local capability.

<!-- canon-section: commands-actions -->
Type/edit query, filter, select, open, ask, inspect supporting object/source/assumption/uncertainty, propose complete, Start now, schedule/reschedule, add Proof, pause/resume, review conflict, inspect Source/Receipt/History/Proof/Privacy, open Capture, and open exact setting use explicit controls and canonical commands. No gesture is required.

<!-- canon-section: durable-effects -->
Queries, answers, interpretations, proposals, and result views do not mutate canonical data. Accepted owner actions follow Command to Event to Projection to Receipt to Replay; explicit persistence routes a question, answer, proposal, or derived object to its identified canonical owner; index updates consume projections and never write canonical object copies.

<!-- canon-section: failure-rollback -->
Rejected or stale result actions re-resolve the object and leave state unchanged. Partial action/external failure preserves accepted local intent and result status. Missing, stale, private, or contradictory grounding withholds or labels the affected inference and preserves deterministic results. Index failure quarantines/rebuilds from canonical projections; Undo routes to the canonical owner.

<!-- canon-section: offline -->
Query, ranking, filtering, result opening, approved local action proposals, inspection, rebuild, Receipt, and replay work without account/network. On-device Ask MAY enhance this path but is never required; when unavailable, Search degrades to deterministic Find / Act / Inspect. Network availability cannot change core ranking authority or reveal more private content.

<!-- canon-section: privacy-data-classification -->
Index, queries, session history, supporting-object selection, answers, assumptions, uncertainty, and proposals are private local data, privacy-filtered at indexing, retrieval, and synthesis. Logs/proof redact query and content by default. Spotlight or optional external handoff uses approved minimum metadata only; Account, R2, hosted AI, cloud profiling, and external models receive no private query/context or private-life-graph data. Approved Source Atlas reference artifacts may be read locally but receive no query or private context.

<!-- canon-section: accessibility-reading-order -->
VoiceOver orders dismiss, query/scope, filters, deterministic result count/status, ranked results, bounded answer, supporting objects/sources/assumptions/uncertainty, proposed actions, then inspection. It announces retrieved, inferred, and proposed state explicitly; custom actions mirror every swipe/context action; headings/rotor support groups; action preview and inspection restore focus to the originating result.

<!-- canon-section: dynamic-type -->
Query, filters, results, excerpts, bounded answers, supporting objects/sources/assumptions/uncertainty, state, and action proposals reflow vertically; no horizontal layout, truncation, or hidden context is required to identify, understand, or act safely.

<!-- canon-section: reduce-motion -->
Result insertion, ranking changes, progressive answer enhancement, owner handoff, and action completion use restrained fades or immediate updates while preserving announcements, retrieved/inferred/proposed distinctions, selection, and focus.

<!-- canon-section: reduce-transparency -->
Search, result, answer, supporting-evidence, and proposal materials become opaque semantic surfaces with equivalent grouping, retrieved/inferred/proposed labels, selection, action, privacy, and contrast cues.

<!-- canon-section: copy-state-language -->
Use Find, Ask, Search, Open step, Start now, Review, Source, Proof, Receipt, History, Privacy, assumption, uncertainty, and Undo contextually. Avoid Ask AI, model confidence, runtime/index taxonomy, shame, or productivity scoring.

<!-- canon-section: visual-authority -->
The named shell package controls placement only;
Search rendering, accessibility/device evidence, implementation parity, and release proof remain separate.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Stage/` owns presentation containment; the existing `Core/LocalRuntimeOS/Search/` owner owns index/ranking/rebuild and any future on-device Ask synthesis; `Projections/` supplies views; `Commands/` owns actions; `Trust/` owns inspection; `Quality/` owns proof. This ownership statement creates no new architecture path or Swift source and does not assert that Ask is implemented.

<!-- canon-section: tests -->
Tests cover exact/prefix/typo/date/context ranking, immediate while-typing results, suppression/privacy, every object family, optional Ask grounding and unavailable fallback, approved-reference use, supporting objects/sources/assumptions/uncertainty, retrieved/inferred/proposed distinction, session-local history, explicit persistence routing, Capture handoff, action safety/material preview, stale object, index corruption/rebuild, partial results, offline, replay/Undo, return focus, VoiceOver order/actions/rotor, Dynamic Type, reduced effects, contrast, and scale.

<!-- canon-section: proof -->
Required proof includes declared-corpus ranking metrics, privacy/filter fixtures, on-device and no-egress evidence, Ask-grounding and unavailable-fallback fixtures, session-expiry/persistence proof, Capture handoff, action Receipts/replay, corruption recovery, screenshot/accessibility matrices, scoped visual approval, exact commands/exits, environment, known gaps, and rollback. Current posture is canon-and-mapping-only: generated index maps, normative Ask wording, target source ownership, and state contracts do not prove or implement on-device Ask, rendered Search UI, accessibility behavior, or runtime performance.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Search query, ranking, on-device synthesis, supporting-evidence resolution, action revalidation, result paging, and index rebuild MUST remain bounded and cancellable, apply explicit product-scale input/result/answer/context caps, perform no query-path network gating or synchronous disk write, use no polling or unbounded background loop, preserve immediate deterministic results while optional synthesis runs, and preserve foreground responsiveness during rebuild. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. Implementation authorization requires an owner-approved performance-registry record declaring device floor, OS, build configuration, representative indexed-record/query/result/answer/context data scale, warm/cold state, measurement tool, percentile/maximum, synthesis and rebuild resource measures, and regression threshold.

## SPEC-GLOBAL-SEARCH-PLACEMENT-001 — Global Search placement

- **Concept:** `global.search.placement`
- **Modality:** `MUST`
- **Scope:** Global Search placement
- **Status:** `normative`
- **Verification:** `REVIEW-SPEC-GLOBAL-SEARCH-PLACEMENT-001`
- **Supersedes:** none

Global Search MUST be available from root chrome, while dense owning surfaces MAY also expose scoped local search.
