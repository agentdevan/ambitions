+++
spec_id = "GLOBAL-SEARCH"
title = "Search"
kind = "global"
status = "normative"
owner_domain = "global-search"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "global.search.canonical-actions",
  "global.search.command-contract",
  "global.search.first-viewport",
  "global.search.identity",
  "global.search.index-actions",
  "global.search.index-ranking",
  "global.search.placement",
  "global.search.visual-authority",
]
inherits = [
  "LAW-IA-NONROOT-001",
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
effect = "No durable mutation occurs and no Receipt is created; Inspect Receipt opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: The selected item now shows the completed change and its recorded result."
success_focus = "the Inspect Receipt destination, Trust heading, or updated results heading in Search results — Action Complete"
failure_focus = "the selected result and exact Inspect Receipt rejection, privacy, stale, or deletion reason in Search results — Action Complete"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
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
effect = "No durable mutation occurs and no Receipt is created; Undo is a handoff to the resolved object owner after re-resolving current object revision, semantic eligibility, dependencies, and proof. Search cannot execute a generic inverse. Visible evidence remains: The search result reflects a recent change. Its earlier value remains recorded in History."
success_focus = "the Undo destination, Trust heading, or updated results heading in Search results — Action Complete Undo Eligible"
failure_focus = "the selected result and exact Undo rejection, privacy, stale, or deletion reason in Search results — Action Complete Undo Eligible"
commit_boundary = "Non-mutating: Search ends at the owner-owned inverse preview; any later typed Undo command and Receipt belong to that resolved object owner."
rollback_undo = "No Search Undo is required; cancellation returns to the completed result and its History while the canonical object remains unchanged."
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
effect = "No durable mutation occurs and no Receipt is created; Inspect History opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Undo is unavailable for this changed search result. The reason is shown."
success_focus = "the Inspect History destination, Trust heading, or updated results heading in Search results — Action Complete Undo Unavailable"
failure_focus = "the selected result and exact Inspect History rejection, privacy, stale, or deletion reason in Search results — Action Complete Undo Unavailable"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
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
effect = "No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: The selected result and proposed difference are visible. The saved item is unchanged."
success_focus = "the Inspect Source destination, Trust heading, or updated results heading in Search results — Action Preview"
failure_focus = "the selected result and exact Inspect Source rejection, privacy, stale, or deletion reason in Search results — Action Preview"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

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
effect = "No durable mutation occurs and no Receipt is created; Clear Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Filters are active. The visible result count reflects the selected kinds of items and time range."
success_focus = "the Clear Filters destination, Trust heading, or updated results heading in Search results — Filtered"
failure_focus = "the selected result and exact Clear Filters rejection, privacy, stale, or deletion reason in Search results — Filtered"
commit_boundary = "Non-mutating: filter presentation and selection remain local projection state and cross no canonical commit boundary."
rollback_undo = "No Undo is required; dismissal or Clear Filters restores the prior or unfiltered query projection without changing saved objects."
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

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
effect = "No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: No local items match the current words and filters. Saved items are unchanged."
success_focus = "the Clear Search destination, Trust heading, or updated results heading in Search results — No Results"
failure_focus = "the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search results — No Results"
commit_boundary = "Non-mutating: query editing and clearing remain before any owner-owned material action or canonical commit."
rollback_undo = "No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence."
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
effect = "No durable mutation occurs and no Receipt is created; Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Matching Goals, Steps, Captures, and time items are grouped by type, with the matching text highlighted."
success_focus = "the Filters destination, Trust heading, or updated results heading in Search results — Results"
failure_focus = "the selected result and exact Filters rejection, privacy, stale, or deletion reason in Search results — Results"
commit_boundary = "Non-mutating: filter presentation and selection remain local projection state and cross no canonical commit boundary."
rollback_undo = "No Undo is required; dismissal or Clear Filters restores the prior or unfiltered query projection without changing saved objects."
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
effect = "No durable mutation occurs and no Receipt is created; the derived query projection applies the selected filters without changing any canonical object"
success_focus = "the filtered results heading or first matching result"
failure_focus = "the Apply Filters control and exact invalid filter"
commit_boundary = "Non-mutating: the command routes or selects without changing canonical state."
rollback_undo = "No Undo is required; cancellation returns to the unchanged originating state."
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
effect = "No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: One search result is selected. Its saved identity and details remain unchanged."
success_focus = "the Inspect Source destination, Trust heading, or updated results heading in Search results — Selected"
failure_focus = "the selected result and exact Inspect Source rejection, privacy, stale, or deletion reason in Search results — Selected"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

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
effect = "No durable mutation occurs and no Receipt is created; Inspect History opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: A search result change is in progress. The earlier result remains visible."
success_focus = "the Inspect History destination, Trust heading, or updated results heading in Search entry — Action Mutating"
failure_focus = "the selected result and exact Inspect History rejection, privacy, stale, or deletion reason in Search entry — Action Mutating"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
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
effect = "No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: The requested search-result change was not accepted. The saved item remains unchanged."
success_focus = "the Clear Search destination, Trust heading, or updated results heading in Search entry — Action Rejected"
failure_focus = "the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search entry — Action Rejected"
commit_boundary = "Non-mutating: query editing and clearing remain before any owner-owned material action or canonical commit."
rollback_undo = "No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence."
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
effect = "No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: A proposed search-result change is being checked. The saved item remains unchanged."
success_focus = "the Inspect Source destination, Trust heading, or updated results heading in Search entry — Action Validating"
failure_focus = "the selected result and exact Inspect Source rejection, privacy, stale, or deletion reason in Search entry — Action Validating"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
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
effect = "No durable mutation of canonical product state occurs and no Receipt is created; Rebuild Search derives a staged local index only from canonical projections. The prior valid index remains served until replacement validation succeeds; corrupt output is quarantined, and only a validated derived index swaps atomically. Visible evidence remains: The local search list cannot be read safely. Saved Goals, Steps, Captures, and time remain intact."
success_focus = "the Rebuild Search destination, Trust heading, or updated results heading in Search entry — Corrupt Index"
failure_focus = "the selected result and exact Rebuild Search rejection, privacy, stale, or deletion reason in Search entry — Corrupt Index"
commit_boundary = "Non-mutating: Search rebuild changes only a validated derived local index and never commits a canonical object, repair, or generic mutation."
rollback_undo = "No canonical Undo is required; failed or cancelled rebuild discards staged output, retains the prior valid index, and restores the prior query and filters."
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
effect = "No durable mutation occurs and no Receipt is created; Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Search has no words entered. No results are shown, and saved items are unchanged."
success_focus = "the Filters destination, Trust heading, or updated results heading in Search entry — Empty Query"
failure_focus = "the selected result and exact Filters rejection, privacy, stale, or deletion reason in Search entry — Empty Query"
commit_boundary = "Non-mutating: filter presentation and selection remain local projection state and cross no canonical commit boundary."
rollback_undo = "No Undo is required; dismissal or Clear Filters restores the prior or unfiltered query projection without changing saved objects."
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
effect = "No durable mutation occurs and no Receipt is created; Inspect Privacy opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Search shows a selected match. The matched item remains unchanged."
success_focus = "the Inspect Privacy destination, Trust heading, or updated results heading in Search entry — Inspection Handoff"
failure_focus = "the selected result and exact Inspect Privacy rejection, privacy, stale, or deletion reason in Search entry — Inspection Handoff"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
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
effect = "No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: Local search remains available without a connection."
success_focus = "the Clear Search destination, Trust heading, or updated results heading in Search entry — Offline Healthy"
failure_focus = "the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search entry — Offline Healthy"
commit_boundary = "Non-mutating: query editing and clearing remain before any owner-owned material action or canonical commit."
rollback_undo = "No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence."
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
effect = "No durable mutation occurs and no Receipt is created; Inspect Source opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Only part of the local result set is available, and the missing scope is named."
success_focus = "the Inspect Source destination, Trust heading, or updated results heading in Search entry — Partial Results"
failure_focus = "the selected result and exact Inspect Source rejection, privacy, stale, or deletion reason in Search entry — Partial Results"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
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
effect = "No durable mutation occurs and no Receipt is created; Inspect Privacy opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: A protected result cannot be shown with the current access; other local results remain available."
success_focus = "the Inspect Privacy destination, Trust heading, or updated results heading in Search entry — Permission Denied"
failure_focus = "the selected result and exact Inspect Privacy rejection, privacy, stale, or deletion reason in Search entry — Permission Denied"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
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
effect = "No durable mutation occurs and no Receipt is created; Inspect Privacy opens only privacy-authorized Trust evidence for the current canonical identity. A stale or deleted result routes safely to Search or Trash only when existence may be disclosed; privacy-suppressed identity stays hidden. Visible evidence remains: Some matches are hidden by privacy rules. Ambitions will not reveal their content in this context."
success_focus = "the Inspect Privacy destination, Trust heading, or updated results heading in Search entry — Privacy Suppressed"
failure_focus = "the selected result and exact Inspect Privacy rejection, privacy, stale, or deletion reason in Search entry — Privacy Suppressed"
commit_boundary = "Non-mutating: Trust inspection remains read-only and cannot validate, mutate, undo, reveal, or repair a canonical object."
rollback_undo = "No Undo is required; dismissal returns focus to the selected result or privacy explanation without disclosing protected content."
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
effect = "No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: Search is checking saved Goals, Steps, Captures, and time."
success_focus = "the Clear Search destination, Trust heading, or updated results heading in Search entry — Querying"
failure_focus = "the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search entry — Querying"
commit_boundary = "Non-mutating: query editing and clearing remain before any owner-owned material action or canonical commit."
rollback_undo = "No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence."
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
effect = "No durable mutation occurs and no Receipt is created; Cancel Rebuild discards only staged derived-index work. The prior valid index, canonical objects, query, and filters remain intact, and corrupt staged output stays quarantined. Visible evidence remains: Search is rebuilding its local list. Matches may be incomplete until the list is ready."
success_focus = "the Cancel Rebuild destination, Trust heading, or updated results heading in Search entry — Rebuilding"
failure_focus = "the selected result and exact Cancel Rebuild rejection, privacy, stale, or deletion reason in Search entry — Rebuilding"
commit_boundary = "Non-mutating: cancellation retains the prior valid derived index and crosses no canonical boundary."
rollback_undo = "No Undo is required; a later rebuild starts from current canonical projections and a new generation identity."
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
effect = "No durable mutation occurs and no Receipt is created; Clear Search clears only query text, recent selection, action rejection, or transient result presentation. Canonical objects, owner actions, History, privacy suppression, and the derived index remain unchanged. Visible evidence remains: Recent search words appear on this device. Saved Goals, Steps, Captures, and time remain unchanged."
success_focus = "the Clear Search destination, Trust heading, or updated results heading in Search entry — Recent"
failure_focus = "the selected result and exact Clear Search rejection, privacy, stale, or deletion reason in Search entry — Recent"
commit_boundary = "Non-mutating: query editing and clearing remain before any owner-owned material action or canonical commit."
rollback_undo = "No Undo is required; the query field regains focus and the user may re-enter text without any saved-state consequence."
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
effect = "No durable mutation occurs and no Receipt is created; Filters changes only the in-memory query projection and visible result grouping. Ranking input, canonical objects, privacy suppression, and saved local truth remain unchanged. Visible evidence remains: Earlier search words and filters are visible again. Results may still be out of date."
success_focus = "the Filters destination, Trust heading, or updated results heading in Search entry — Restored"
failure_focus = "the selected result and exact Filters rejection, privacy, stale, or deletion reason in Search entry — Restored"
commit_boundary = "Non-mutating: filter presentation and selection remain local projection state and cross no canonical commit boundary."
rollback_undo = "No Undo is required; dismissal or Clear Filters restores the prior or unfiltered query projection without changing saved objects."
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
effect = "No durable mutation of canonical product state occurs and no Receipt is created; Rebuild Search derives a staged local index only from canonical projections. The prior valid index remains served until replacement validation succeeds; corrupt output is quarantined, and only a validated derived index swaps atomically. Visible evidence remains: Search results may be out of date. Saved Goals, Steps, Captures, and time remain unchanged."
success_focus = "the Rebuild Search destination, Trust heading, or updated results heading in Search entry — Stale Index"
failure_focus = "the selected result and exact Rebuild Search rejection, privacy, stale, or deletion reason in Search entry — Stale Index"
commit_boundary = "Non-mutating: Search rebuild changes only a validated derived local index and never commits a canonical object, repair, or generic mutation."
rollback_undo = "No canonical Undo is required; failed or cancelled rebuild discards staged output, retains the prior valid index, and restores the prior query and filters."
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
effect = "No durable mutation of canonical product state occurs and no Receipt is created; Rebuild Search derives a staged local index only from canonical projections. The prior valid index remains served until replacement validation succeeds; corrupt output is quarantined, and only a validated derived index swaps atomically. Visible evidence remains: The requested search view is temporarily unavailable. Saved Goals, Steps, Captures, and time remain available."
success_focus = "the Rebuild Search destination, Trust heading, or updated results heading in Search entry — Unavailable Projection"
failure_focus = "the selected result and exact Rebuild Search rejection, privacy, stale, or deletion reason in Search entry — Unavailable Projection"
commit_boundary = "Non-mutating: Search rebuild changes only a validated derived local index and never commits a canonical object, repair, or generic mutation."
rollback_undo = "No canonical Undo is required; failed or cancelled rebuild discards staged output, retains the prior valid index, and restores the prior query and filters."
privacy_egress = "Search and its derived index remain local; suppressed or protected matches disclose no identity, Trust shows only authorized evidence, and no query or private result leaves the device."
verification_ids = ["SCENARIO-GLOBAL-SEARCH-COMMAND-CONTRACT-001"]
activation_posture = "active"
gate_requirement_ids = []

+++

# Search

Search uses `surface-v1` because it presents a full-screen Find, Act, and Inspect experience with visible result, action, state, accessibility, and visual contracts. It remains a global overlay/evolution, never a root tab or chatbot destination.

## SPEC-GLOBAL-SEARCH-IDENTITY-001 — Local Find, Act, and Inspect

- **Concept:** `global.search.identity`
- **Modality:** `MUST`
- **Scope:** Global Search presentation and behavior
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-IDENTITY-001`
- **Supersedes:** none

Search MUST be deterministic, local-first Find, Act, and Inspect across approved private projections. It MUST NOT be chatbot-first, command-line theater, a shallow utility sheet, cloud/LLM dependent, a root, or an alternate canonical store.

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
Search answers where a local object or setting is, what safe action can be taken now, and what proof/source/history/privacy context can be inspected.

<!-- canon-section: entry-exit -->
Entry comes from integrated shell/context, keyboard shortcut, deep link, or handoff. Dismissal restores exact root/depth/query-origin focus; opening a result records a return target; accepted action returns to the changed object or results predictably.

<!-- canon-section: routes-presentation -->
Search is full-screen non-root presentation. Result detail uses native depth or owner handoff; contextual Trust inspection is presented by Trust. Search never persists as a root or duplicates destination behavior.

<!-- canon-section: displayed-objects -->
Results show canonical identity, type, relevant status/date/context, privacy-safe excerpt, provenance/trust marker only when relevant, and safe actions. Grouping and ranking rationale remain plain and inspectable without exposing internals.

<!-- canon-section: resting-states -->
Required states are empty query, recent/local suggestions, querying, results, no results, filtered, selected, action preview, action complete, rebuilding, restored, and privacy-suppressed.

<!-- canon-section: loading-transitional -->
Query, filter, index refresh/rebuild, action validation, mutation, inspection handoff, and restoration are cancellable where useful and retain last valid results until deterministic replacement is ready.

<!-- canon-section: empty-degraded -->
The result-state matrix pairs each index, projection, permission, and action condition with preserved query context and repair controls.
No results offers query repair, scope/filter changes, Capture, or exact setting help without fake matches. Corrupt/stale index, unavailable projection, permission denial, partial results, offline, or action rejection states preserve query and disclose what remains searchable.

<!-- canon-section: commands-actions -->
Type/edit query, filter, select, open, complete, Start now, schedule/reschedule, add proof, pause/resume, review conflict, inspect source/receipt/history/privacy, open Capture, and open exact setting use explicit controls and canonical commands. No gesture is required.

<!-- canon-section: durable-effects -->
Queries and result views do not mutate canonical data. Accepted actions follow Command to Event to Projection to Receipt to Replay; index updates consume projections and never write canonical object copies.

<!-- canon-section: failure-rollback -->
Rejected or stale result actions re-resolve the object and leave state unchanged. Partial action/external failure preserves accepted local intent and result status. Index failure quarantines/rebuilds from canonical projections; undo routes to the canonical owner.

<!-- canon-section: offline -->
Query, ranking, filtering, result opening, approved local actions, inspection, rebuild, receipt, and replay work without account/network. Network availability cannot change core ranking authority or reveal more private content.

<!-- canon-section: privacy-data-classification -->
Index and queries are private local data, privacy-filtered at indexing and retrieval. Logs/proof redact query and content by default. Spotlight or optional external handoff uses approved minimum metadata only; Account, R2, Source Atlas, and hosted AI receive no private query/context.

<!-- canon-section: accessibility-reading-order -->
VoiceOver orders dismiss, query/scope, filters, result count/status, then ranked results with identity/value/actions. Custom actions mirror every swipe/context action; headings/rotor support groups; action preview and inspection restore focus to the originating result.

<!-- canon-section: dynamic-type -->
Query, filters, results, excerpts, state, and actions reflow vertically; no horizontal layout, truncation, or hidden context is required to identify or act safely.

<!-- canon-section: reduce-motion -->
Result insertion, ranking changes, owner handoff, and action completion use restrained fades or immediate updates while preserving announcements, selection, and focus.

<!-- canon-section: reduce-transparency -->
Search and result materials become opaque semantic surfaces with equivalent grouping, selection, action, privacy, and contrast cues.

<!-- canon-section: copy-state-language -->
Use Find, Search, Open step, Start now, Review, Source, Receipt, History, Privacy, and Undo contextually. Avoid Ask AI, confidence, runtime/index taxonomy, shame, or productivity scoring.

<!-- canon-section: visual-authority -->
The named shell package controls placement only;
Search rendering, accessibility/device evidence, implementation parity, and release proof remain separate.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Stage/` owns presentation containment; `Core/LocalRuntimeOS/Search/` owns index/ranking/rebuild; `Projections/` supplies views; `Commands/` owns actions; `Trust/` owns inspection; `Quality/` owns proof.

<!-- canon-section: tests -->
Tests cover exact/prefix/typo/date/context ranking, suppression/privacy, every object family, action safety/material preview, stale object, index corruption/rebuild, partial results, offline, replay/undo, return focus, VoiceOver order/actions/rotor, Dynamic Type, reduced effects, contrast, and scale.

<!-- canon-section: proof -->
Required proof includes declared-corpus ranking metrics, privacy/filter fixtures, action receipts/replay, corruption recovery, screenshot/accessibility matrices, scoped visual approval, exact commands/exits, environment, known gaps, and rollback. Generated index maps are not runtime proof.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Search query, ranking, action revalidation, result paging, and index rebuild MUST remain bounded and cancellable, apply explicit product-scale input/result caps, perform no query-path network gating or synchronous disk write, use no polling or unbounded background loop, and preserve foreground responsiveness during rebuild. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. Implementation authorization requires an owner-approved performance-registry record declaring device floor, OS, build configuration, representative indexed-record/query/result data scale, warm/cold state, measurement tool, percentile/maximum, rebuild resource measures, and regression threshold.

## SPEC-GLOBAL-SEARCH-PLACEMENT-001 — Global Search placement

- **Concept:** `global.search.placement`
- **Modality:** `MUST`
- **Scope:** Global Search placement
- **Status:** `normative`
- **Verification:** `REVIEW-SPEC-GLOBAL-SEARCH-PLACEMENT-001`
- **Supersedes:** none

Global Search MUST be available from root chrome, while dense owning surfaces MAY also expose scoped local search.
