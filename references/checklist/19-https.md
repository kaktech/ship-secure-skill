# 19. Force HTTPS

## What to check
- HTTP redirects to HTTPS (301/308). HSTS present with `max-age >= 15552000`.
- Cookies `Secure`. No mixed content. App trusts the proxy's `X-Forwarded-Proto` correctly.
- DB and third-party calls use TLS.

## How to fix
- Enable platform HTTPS redirect (host setting, proxy, or framework: `SECURE_SSL_REDIRECT`, `forceHttps`, redirect middleware).
- Set HSTS; add `includeSubDomains`/preload only after confirming all subdomains support HTTPS.
- Set proxy trust settings.

## How to verify
- `curl -sI http://<staging-host>/` shows a redirect to https.
- `check-headers.sh https://<host>` shows HSTS.
