        # Dependency Clients

        Status: Active trace ledger

        This document defines Ambitions-native dependency boundaries and keeps them free of third-party architecture frameworks.

        | Client | Responsibility | Forbidden |
        | --- | --- | --- |
        | Calendar | schedule access and permission boundaries | generic calendar clone behavior |
| Notification | local notification triggers | hidden automation |
| Persistence | SwiftData/local persistence boundaries | hosted data backend assumptions |
| Local runtime | inspectable local logic and learning | cloud LLM core dependency |
| Widget snapshot | widget render and snapshot contract | release proof claims |
| Source freshness | fresh/stale/missing checks | silent stale data |

        These are architecture boundaries only; they do not change production source by themselves.
