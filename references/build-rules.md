# Build-mode rules

## Contents
- How to apply
- Rules by area
- Closing note format

## How to apply
Apply only the areas the task touches. Match the project's framework and style. If the stack file has a ready pattern, use it. Do not add libraries when the framework already has the control.

## Rules by area

### Secrets and config (items 1-3)
- Read secrets from server-side env vars. Never hard-code, never log, never ship in client bundles. Public-prefixed vars (`NEXT_PUBLIC_`, `VITE_`, `REACT_APP_`, `EXPO_PUBLIC_`) hold only non-secret values.
- Add `.env*` to `.gitignore`. Provide `.env.example` with names only.
- Client DB key (anon/publishable) is the only key allowed in the client. Service-role keys stay on the server.

### Database access (items 4, 5, 7, 13)
- Parameterized queries or ORM only. Never concatenate user input into SQL, shell, or NoSQL operators.
- New table reachable from a client key: enable RLS and write per-operation policies in the same change.
- Every fetch/update/delete by ID is scoped to the caller: `WHERE id = ? AND owner_id = ?`.
- Encrypt sensitive columns at rest. Never log them.

### Auth and sessions (items 6, 9, 10, 11)
- Check identity and permission on the server for every route and action. Deny by default.
- Hash passwords with argon2id (or bcrypt cost 12+). Never roll custom crypto.
- Session cookies: `HttpOnly; Secure; SameSite=Lax` (or Strict), bounded lifetime, rotate on login, destroy on logout.
- Rate-limit login, signup, reset, and OTP. Return the same message for unknown user and wrong password.

### APIs and forms (items 8, 12, 14, 15, 17)
- Validate body, query, params with a schema (zod, joi, pydantic, Django forms, Laravel FormRequest). Reject unknown fields.
- Allow-list writable fields. Never take `role`, `isAdmin`, `price`, `ownerId`, or `status` from the client.
- Return explicit response shapes (DTOs). Never return raw DB rows. Errors are generic to the client, detailed in server logs.
- Encode output by default. Avoid `innerHTML`, `dangerouslySetInnerHTML`, `v-html`, `|safe`, `{!! !!}`. If unavoidable, sanitize with DOMPurify or equivalent.
- State-changing routes using cookie auth need CSRF protection or SameSite plus an origin check.

### File uploads (item 16)
- Limit size. Allow-list types by content sniffing, not by extension or the client MIME type.
- Generate random filenames. Store outside the web root or in private storage. Serve with `Content-Disposition` and `X-Content-Type-Options: nosniff`.

### Payments
- Compute price and amounts on the server from your own catalog. Verify webhooks by signature. Make handlers idempotent. Never trust client-sent totals or "paid" flags.

### Outbound requests
- Fetching user-supplied URLs: allow-list hosts, block private/link-local/metadata IP ranges after DNS resolution, disable redirects or re-validate them.

### Deployment (items 18, 19, 20)
- Set security headers, force HTTPS with HSTS, disable debug mode, no default credentials.
- Commit lockfiles. Run the dependency audit before release.

## Closing note format
End the response with:
```
Security controls applied:
- <control>: <where>
```
One line each. Only list what was applied. Add "Needs your action:" for anything the user must do (rotate a key, set an env var, enable RLS in the dashboard).
