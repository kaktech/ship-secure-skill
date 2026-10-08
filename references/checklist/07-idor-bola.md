# 7. Lock down record access (IDOR/BOLA)

## What to check
- Find every handler that takes an ID (path, query, body) and loads or changes a record.
- Each query must include the caller's scope: owner, tenant, or explicit permission check.
- Random UUIDs do not fix this.

## How to fix
- Scope the query: `WHERE id = :id AND owner_id = :current_user`, or load then check ownership before use.
- Return 404 (not 403) for objects the caller cannot see, if enumeration matters.
- Apply to nested resources and file downloads.

## How to verify
- On staging with users A and B: as A, request B's record by ID for read, update, delete: expect 403/404.
- Test list endpoints: A sees only A's records.
