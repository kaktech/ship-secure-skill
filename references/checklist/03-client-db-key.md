# 3. Public/client DB key used correctly

## What to check
- Identify the client-side key: Supabase anon, Firebase web config, Algolia search-only key, etc.
- Confirm no service-role/admin key appears in client code, bundles, or public env vars.
- Confirm the public key is protected by item 4 (RLS or rules).

## How to fix
- Keep only the public key in the client. Move admin/service keys to server routes or edge functions.
- Restrict the public key where the provider allows it (allowed domains, API restrictions, bundle IDs).
- Apply item 4 before declaring this safe.

## How to verify
- Grep client code and built bundle for service-role key prefixes or JWTs with `role: service_role`.
- With the public key only, attempt to read another user's rows (staging): expect empty or denied.
