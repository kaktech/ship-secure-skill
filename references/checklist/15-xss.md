# 15. Escape/sanitize user content (XSS)

## What to check
- Grep for unsafe sinks: `innerHTML`, `dangerouslySetInnerHTML`, `v-html`, `document.write`, `|safe`, `{!! !!}`, `mark_safe`, `bypassSecurityTrust`.
- Check where user content renders: profiles, comments, markdown, emails, URLs in `href`/`src` (`javascript:`).
- Check CSP (item 18).

## How to fix
- Use framework auto-escaping. Render text, not HTML.
- When HTML is required, sanitize with DOMPurify (or bleach, sanitize-html) using an allow-list.
- Validate URL schemes (http/https/mailto only).
- Add a CSP without `unsafe-inline` where feasible.

## How to verify
- Store `<img src=x onerror=alert(1)>` and `javascript:alert(1)` links in each user-content field on staging; view the page: no script runs, content shows as text.
