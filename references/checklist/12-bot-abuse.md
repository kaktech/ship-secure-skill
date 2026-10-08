# 12. Bot/abuse protection

## What to check
- Check signup, contact/forms, password reset, comments, and costly endpoints (email, SMS, AI calls, exports).
- Look for CAPTCHA/Turnstile/hCaptcha, rate limits, email verification, disposable-domain checks, per-user quotas.

## How to fix
- Add a CAPTCHA or Turnstile with server-side token verification on public forms.
- Add per-IP and per-user rate limits and quotas on costly calls.
- Add honeypot fields and email verification where fitting.

## How to verify
- Submit the form without a token or with a bad one: expect rejection.
- Burst-call a costly endpoint on staging: expect 429.
