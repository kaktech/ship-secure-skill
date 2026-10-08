# 18. Security headers

## What to check
- Run `bash scripts/check-headers.sh <url>` against local/staging.
- Required: Content-Security-Policy, Strict-Transport-Security, X-Content-Type-Options: nosniff, frame protection (CSP frame-ancestors or X-Frame-Options), Referrer-Policy, Permissions-Policy.
- Remove `Server` and `X-Powered-By` banners.

## How to fix
- Add headers via framework middleware (helmet, Next.js headers(), Django SecurityMiddleware, Laravel middleware) or the reverse proxy.
- Start CSP strict, test, and loosen only with evidence.
- Set CORS to an explicit origin allow-list; never `*` with credentials.

## How to verify
- Re-run the header script: no missing headers.
- Load the app in a browser and check the console for CSP violations.
