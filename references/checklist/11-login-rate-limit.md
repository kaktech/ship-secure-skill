# 11. Login rate limiting

## What to check
- Check login, password reset, OTP/2FA, and signup endpoints for per-IP and per-account limits.
- Check lockout/backoff and uniform error messages (no user enumeration).

## How to fix
- Add a rate limiter (see stack file): e.g. 5 attempts per 15 min per account+IP with exponential backoff.
- Use a shared store (Redis/DB) if running multiple instances.
- Return identical responses for unknown user and wrong password.

## How to verify
- On local/staging, send 10 rapid bad logins: expect 429 after the limit.
- Compare responses for existing and non-existing users: identical body and similar timing.
