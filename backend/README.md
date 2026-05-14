# Backend

Status: Active backend portal
Authority: subordinate to `docs/truth/*`

Ambitions does not currently claim a hosted personal-data backend.

The backend-equivalent lives in the native app source and local runtime layers:

- [`Native/Ambitions/Domain/`](../Native/Ambitions/Domain/)
- [`Native/Ambitions/Services/`](../Native/Ambitions/Services/)
- [`Native/Ambitions/Persistence/`](../Native/Ambitions/Persistence/)
- [`project.yml`](../project.yml)
- [`Package.swift`](../Package.swift)

This portal exists to keep the repo honest about the current posture:

- local-first / on-device-first
- no active hosted user-data backend architecture
- no implied Supabase/Firebase/account backend unless `docs/truth/*` explicitly says otherwise
