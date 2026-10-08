# 9. Secure session cookies

## What to check
- Inspect Set-Cookie on login: `HttpOnly`, `Secure`, `SameSite=Lax|Strict`, scoped `Path`/`Domain`, bounded `Max-Age`.
- Session ID rotated at login; invalidated at logout and password change; signed or server-stored.
- Tokens not kept in localStorage if cookie sessions are viable.
- Session secret strong and not default.

## How to fix
- Set cookie flags in the framework session config (see stack file).
- Regenerate session ID on login and privilege change; destroy server-side on logout.
- Use a long random secret from env.

## How to verify
- `curl -i` the login endpoint (local/staging) and read Set-Cookie flags.
- Reuse the old session cookie after logout: expect 401.
