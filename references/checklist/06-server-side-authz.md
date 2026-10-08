# 6. Server-side authN/authZ

## What to check
- List all routes, server actions, API handlers, and RPC functions. Mark each public or protected.
- Each protected one checks identity AND permission on the server. Hiding a button is not a control.
- Check middleware coverage gaps (path matchers, method handling, webhooks).

## How to fix
- Add a central auth guard; deny by default; opt routes into public access explicitly.
- Check role/permission on each privileged action, not only at login.
- Re-validate on the server for any client-claimed identity.

## How to verify
- Call every protected route with no credentials: expect 401. With a low-privilege user on admin routes: expect 403.
- Keep a route table (route, auth required, result) in the report.
