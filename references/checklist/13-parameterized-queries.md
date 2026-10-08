# 13. Parameterized queries

## What to check
- Grep for string-built SQL: template literals or concatenation in `query(`, `execute(`, `raw(`, `$queryRawUnsafe`, `.extra(`, `DB::raw`.
- Check NoSQL operator injection (`{"$ne": ...}` from JSON bodies) and shell/command building from input (`exec`, `system`, `subprocess` with `shell=True`).
- Check dynamic ORDER BY / column names.

## How to fix
- Use placeholders/bind params or the ORM's safe API.
- Allow-list dynamic identifiers (sort columns).
- Cast/validate NoSQL inputs to primitives. Use argument arrays for subprocess, not shell strings.

## How to verify
- On local/staging, send `' OR '1'='1` and `'; SELECT pg_sleep(5)--` in each input: expect no behavior change or delay.
- Grep again: no unsafe raw calls with interpolation remain.
