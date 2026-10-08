# PRE-LAUNCH SECURITY AUDIT

Example, fictional app: Acme Notes

Date: 2026-10-08 | Stack: Next.js 14 + Supabase | Environment tested: local dev server + Supabase staging project

## 1. Hide API Keys
Status: PARTIAL
What I found: `lib/email.ts:4` hard-coded a mail API key (`re_****`). Now removed. Client bundle clean.
What I changed: Moved key to `process.env.RESEND_API_KEY`; added `.env.example`.
How I verified it: `scan-secrets.sh` shows no hits in tracked files. Built the app and grepped `.next/static` for `re_`: none. PARTIAL because the key itself must still be rotated (item 2).

## 2. Purge Git Secrets
Status: FAIL
What I found: The mail key from item 1 appears in 14 commits (first: `a1b2c3d`, file `lib/email.ts:4`). `.env` was committed in `9f8e7d6` and deleted in `4c3b2a1`.
What I changed: Nothing. History rewrite needs your approval and a force-push.
How I verified it: `scan-secrets.sh` history section. **Action: rotate the mail key and every value that was in that `.env` now.** Deleting the file does not make them safe.

## 3. Use the Public/Client DB Key Correctly
Status: PASS
What I found: Only the anon key is in `NEXT_PUBLIC_SUPABASE_ANON_KEY`. Service-role key is used only in `app/api/admin/route.ts`.
What I changed: Nothing.
How I verified it: Grepped bundle for `service_role` JWT claim: absent.

## 4. Enable Row-Level Security (RLS)
Status: PASS
What I found: `invoices` had no RLS (anyone with the anon key could read all rows).
What I changed: `supabase/migrations/20261008_rls_invoices.sql`: enabled RLS, 4 owner-scoped policies.
How I verified it: On staging with users A and B using the anon key: A reading/updating/deleting B's invoice returned 0 rows. Anonymous select returned 0 rows.

## 5. Encrypt Sensitive Data
Status: PARTIAL
What I found: TLS on. `profiles.tax_id` stored in plaintext.
What I changed: Added pgsodium column encryption migration (not applied to prod).
How I verified it: Applied on staging: stored value is ciphertext. Production migration pending your sign-off.

## 6. Enforce Server-Side Authentication/Authorization
Status: PASS
What I found: `app/api/reports/route.ts` had no auth check.
What I changed: Added `requireUser()` to that handler.
How I verified it: Unauthenticated GET: 401. Non-admin GET on `/api/admin`: 403.

## 7. Lock Down Record Access
Status: PASS
What I found: `GET /api/invoices/[id]` loaded by ID only.
What I changed: Query now `.eq("owner_id", user.id)`.
How I verified it: User A requesting B's invoice ID: 404.

## 8. Prevent/Block Field Tampering
Status: PASS
What I found: `PATCH /api/profile` spread request body into update, allowing `role`.
What I changed: zod `.pick({ name, avatar }).strict()`.
How I verified it: Sent `{"role":"admin"}`: 400, DB unchanged.

## 9. Secure Session Cookies
Status: PASS
What I found: Supabase SSR cookies default to Lax; `Secure` missing on local only.
What I changed: Explicit cookie options in `lib/supabase/server.ts`.
How I verified it: `curl -i` on staging login shows `HttpOnly; Secure; SameSite=Lax`. Old cookie after logout: 401.

## 10. Hash Passwords Securely
Status: NOT APPLICABLE (passwords are handled by Supabase Auth, which uses bcrypt; no app-level password storage found)
What I found: No custom password code.
What I changed: Nothing.
How I verified it: Grepped for hash/crypto calls: none touching passwords.

## 11. Rate-Limit Login Attempts
Status: PARTIAL
What I found: Supabase Auth has built-in limits; the custom `/api/magic-link` had none.
What I changed: Added Upstash limiter, 5 per 15 min per IP+email.
How I verified it: 10 rapid requests locally: requests 6 to 10 returned 429. Not tested under multi-instance load.

## 12. Add Bot/Abuse Protection
Status: FAIL
What I found: Signup and contact form have no CAPTCHA.
What I changed: Nothing yet.
How I verified it: Submitted form with no token: accepted. Needs a Turnstile site key from you.

## 13. Parameterize Database Queries
Status: PASS
What I found: One `supabase.rpc` wrapper built SQL with a template string (`lib/search.ts:22`).
What I changed: Switched to a parameterized RPC.
How I verified it: Sent `' OR 1=1--` as search: 0 extra rows, no error.

## 14. Validate ALL Input
Status: PASS
What I found: 3 of 11 handlers lacked schemas.
What I changed: Added zod schemas.
How I verified it: Wrong types, 1 MB string, null: all 400/422.

## 15. Escape/Sanitize User-Generated Content
Status: PASS
What I found: `dangerouslySetInnerHTML` on invoice notes (`components/Notes.tsx:31`).
What I changed: Wrapped with DOMPurify.
How I verified it: Stored `<img src=x onerror=alert(1)>`: rendered inert.

## 16. Restrict File Uploads
Status: PARTIAL
What I found: Avatar upload had no size limit or content check.
What I changed: 2 MB cap, magic-byte check, random names.
How I verified it: Renamed .html as .png: 415. Over-limit file: 413. Antivirus scanning not added.

## 17. Trim/Minimize API Responses
Status: PASS
What I found: `/api/users/me` returned the whole row.
What I changed: Explicit field select.
How I verified it: Raw JSON now has 4 fields.

## 18. Add Security Headers
Status: PASS
What I found: Only X-Powered-By present.
What I changed: `next.config.js` headers + `poweredByHeader: false`.
How I verified it: `check-headers.sh` on staging: all required present. No CSP violations in console.

## 19. Force HTTPS
Status: PASS
What I found: Host redirects by default; HSTS missing.
What I changed: HSTS header added.
How I verified it: `curl -sI http://staging...` returns 308 to https; HSTS present.

## 20. Scan and Fix Vulnerable Dependencies
Status: PARTIAL
What I found: `npm audit`: 1 critical, 3 high.
What I changed: Upgraded next, jsonwebtoken, and 2 transitive deps. One high (dev-only `ip` via a build tool) remains.
How I verified it: Re-ran audit; build and tests pass.

## Additional findings (beyond the 20 items)
- CSRF: PASS. Origin check added to cookie-authenticated mutations.
- SSRF: PASS. Link preview now blocks private IP ranges after DNS resolution.
- Privilege escalation: PASS. Invite flow cannot grant a higher role than the inviter's.
- Race conditions: PARTIAL. Coupon redemption fixed with an atomic UPDATE; credit top-up not tested under parallel load.
- Business logic: PARTIAL. Server-side pricing confirmed; refund-after-export flow needs product review.

## Critical Issues Remaining
1. Rotate the mail API key and all values from the once-committed `.env` (item 2).
2. No bot protection on signup and contact form (item 12).
3. `profiles.tax_id` encryption migration not yet applied to production (item 5).

## Files Changed
| File | Change |
|---|---|
| `lib/email.ts` | Key read from env |
| `.env.example` | New |
| `supabase/migrations/20261008_rls_invoices.sql` | RLS + policies |
| `app/api/reports/route.ts` | Auth check |
| `app/api/invoices/[id]/route.ts` | Owner scope |
| `app/api/profile/route.ts` | Field allow-list |
| `next.config.js` | Headers, HSTS |
| `components/Notes.tsx` | DOMPurify |
| `package.json`, `package-lock.json` | Dependency upgrades |

## Tests Performed
| Test | Target | Result |
|---|---|---|
| scan-secrets.sh | repo + history | 1 secret in 14 commits (masked) |
| Cross-user read/update/delete with anon key | Supabase staging | Denied |
| Unauthenticated and low-priv route sweep | local | 401/403 as expected |
| SQLi and XSS payloads | local | Inert |
| 10 rapid logins | local | 429 after 5 |
| check-headers.sh | staging | Pass |
| npm audit | repo | 1 dev-only high left |

## Final Launch Assessment
NOT READY FOR LAUNCH
A committed credential still needs rotating and signup has no abuse protection. Minimum to reach READY WITH MINOR FIXES: rotate the credentials, add Turnstile, apply the production encryption migration.

Ship Secure does not replace a professional penetration test.
