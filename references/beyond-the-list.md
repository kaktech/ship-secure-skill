# Beyond the 20 items

## Contents
- Auth and authz bypass
- CSRF
- SSRF
- Privilege escalation
- Race conditions
- Business-logic flaws

For each: what to check, how to fix, how to verify. Test locally or on staging only.

## Auth and authz bypass
- Check: routes missing an auth middleware; admin routes guarded only in the UI; middleware matchers that skip paths (`/api/..` variants, trailing slashes, case); method confusion (GET allowed, POST guarded); JWT `alg: none`, unverified signatures, no expiry; password reset tokens that are guessable, reusable, or never expire.
- Fix: deny by default, central guard, verify JWT signature and `exp`/`aud`/`iss`, single-use short-lived reset tokens.
- Verify: request each route unauthenticated and as a low-privilege user; expect 401/403.

## CSRF
- Check: cookie-authenticated state-changing routes (POST/PUT/PATCH/DELETE) with no CSRF token, no `SameSite`, no Origin check; state changes on GET.
- Fix: framework CSRF middleware, or `SameSite=Lax/Strict` plus Origin/Referer validation; never mutate on GET. Bearer-token APIs are not CSRF-prone.
- Verify: replay a state-changing request with a foreign `Origin` and no token; expect rejection.

## SSRF
- Check: any feature that fetches a user-supplied URL (webhooks, link previews, image import, PDF render, OAuth metadata).
- Fix: allow-list schemes (https) and hosts; resolve DNS and block loopback, RFC1918, link-local (169.254.169.254), and IPv6 equivalents; pin the resolved IP; limit redirects, size, and time.
- Verify: submit `http://127.0.0.1`, `http://169.254.169.254/`, and a hostname resolving to a private IP; expect rejection.

## Privilege escalation
- Check: users able to set their own role or plan via profile update; invite or org flows that grant higher roles than the inviter's; role stored in a client-editable JWT claim or `user_metadata`; admin endpoints reachable by tenant admins across tenants.
- Fix: roles live server-side only; inviter role >= granted role; tenant scope on every admin query.
- Verify: send `{"role":"admin"}` in profile update and invite requests as a normal user; expect no change.

## Race conditions
- Check: check-then-act on balances, coupons, stock, rate limits, one-time tokens, and "first user wins" flows without a lock or unique constraint.
- Fix: DB transactions with row locks or atomic updates (`UPDATE ... WHERE balance >= ?`), unique constraints, idempotency keys.
- Verify: fire 20 parallel requests redeeming one coupon on staging; expect exactly one success.

## Business-logic flaws
- Check: negative or fractional quantities; client-supplied prices or discounts; skipping steps in multi-step flows (checkout, KYC, email verification); unlimited free-trial or referral abuse; enumeration through verbose errors; refund/cancel after fulfilment.
- Fix: server-side state machine, server-side pricing, bounds checks, uniform error messages.
- Verify: replay flows out of order and with edge values; expect rejection.
