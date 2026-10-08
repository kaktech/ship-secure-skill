# 17. Trim API responses

## What to check
- Review each response shape for password hashes, tokens, internal flags, emails/phones of other users, full DB rows, stack traces, and verbose errors.
- Check GraphQL introspection and over-fetching, and pagination limits.

## How to fix
- Return explicit DTOs/serializers with allow-listed fields.
- Generic client errors; log detail server-side. Disable debug mode.
- Cap page size; disable GraphQL introspection and depth-limit in production.

## How to verify
- Call each endpoint as a normal user and read the raw JSON: no extra sensitive fields.
- Trigger a server error: response has no stack trace or SQL.
