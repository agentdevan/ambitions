# Task 21 transitive-complete pack semantic response

Model assignment: Ultra. Work read-only. Do not edit files, commit, run network tools, read benchmark expected fixtures, use the legacy truth path, or inspect unrelated source. Use only the eight exact JSON/Markdown pack pairs in `.codex/canon-semantic-review/`. The corpus compiler-input SHA-256 is `654e4701084520ef2058fbd20473a7a2bd91005900369356d4396ab90917fd5b`; evaluation base commit is `a9e4b7d1efc390d41bc4bb5a227c44fe7f91836c`. The compiler-input SHA is independently recomputable from the 16 files: sort by UTF-8 filename, then hash for each file the 8-byte big-endian filename length, filename bytes, 8-byte big-endian content length, and exact content bytes. Verify the compiler-input SHA and every pack file SHA-256 before responding:

- today-swiftui: md `3d063e72cadf52f06e931d8890c7dee62aa6d43e5ae586e36c847fbdf7170764`; json `3e5a8e0e37183a5fcdae096d81affdb4ba8f96b184bcd278c0b6a3a460066c46`
- time-recurrence: md `d40c7c9aeae32da4492474de16c08d11cc2b6002bbcdd9d3462678a1136a59a0`; json `4315a2264779b48ed90ae91ed414633da00b1a44799132b18fb050b864705b32`
- capture-proposal: md `503792a922fa403fce179e564730011dc8f37d75f13787331563ad7257685f1d`; json `5480e268c6ce1a4072f5bc71b83af48c7218c11909498d3cb5c868418aaf2bde`
- local-runtime-mutation: md `6594dea43d47bc9881d81bfa61df7150ca18d42180fd496f7040e82577c1acd5`; json `825af17c26246120211363b9cd1d07a0f20c96a997f3ad77dad55aa3adbe8a8a`
- cloudkit-continuity: md `f78c486b35a943d13b3e32c64bb0f24511a1174090ec3f73c05e9f3c6eaedcee`; json `98e95316a5e3a98a3d8cd0afe4201ed664a2ed4a2cce35a7854b57d357495bd5`
- source-atlas-boundary: md `358eb217f8251ae50a839d7e76e796707ba0d03514051e9766bb59bba51643c4`; json `af8c1ed7405186d844af1cc21c8d7028efe4e4f2611ba04a528683e3540f640f`
- accessibility-repair: md `fe56de71d29560e5e5fac4b44933eb514c3c32fc316ad0237674df10616e5f31`; json `1397c9a4f194a95347c05f6f4c19c39dc066e02c8fcda9a8f1117c8a62f1c620`
- release-proof-claim: md `f0f052710c5c7de5a799e14474322d8819079a4e991a201850ba3c98b08bbbc7`; json `aaf314d4cb75485cace85d3ee9ae1bf411ed0bcf163e21f35438043b29f2f829`

For each scenario, return one compact JSON object with exact keys: `scenario_id`, `applicable_requirement_ids`, `applicable_laws`, `source_owners`, `required_validation`, `required_proof`, `forbidden_changes`, `claim_ceiling`, `assumptions`, `contradictions`. Use the semantic scenario ID above, not an issue ID. Set `applicable_requirement_ids` to the exact full array from the pack JSON field of that name, including every document/specification/standard ID; do not infer, filter, summarize, rename, or omit any item. Set `applicable_laws` to the exact `constitutional_laws` array. Copy exact IDs and paths supplied by the pack. Never upgrade intended law, source existence, tests, external links, or shadow status into current proof or source-edit authorization.

Return a JSON object with reviewer `task_21_transitive_final_new_pack_eval`, model `Ultra`, this prompt SHA, compiler-input/evaluation metadata, verified pack hashes, `scenarios` in the order above, and one bounded proof ceiling.
