# Next.js

## Secrets
- Server-only env vars in `.env.local` (git-ignored) or the host's secret store. Only `NEXT_PUBLIC_*` reaches the browser: never put secrets there.
- Add `import "server-only"` to modules that read secrets.

## Auth and sessions
- Check auth in every Route Handler, Server Action, and server component data fetch. Middleware alone is not enough (matcher gaps); re-check in the handler.
- Use Auth.js, Clerk, or Supabase SSR. Cookie flags: `httpOnly: true, secure: true, sameSite: "lax", path: "/"`.
- Server Actions are public POST endpoints: validate input and authorize inside each.

## Validation
- zod: `const body = Schema.strict().parse(await req.json())`.

## Headers, HTTPS
```js
// next.config.js
module.exports = { poweredByHeader: false, async headers() { return [{ source: "/(.*)", headers: [
  { key: "Strict-Transport-Security", value: "max-age=63072000; includeSubDomains" },
  { key: "X-Content-Type-Options", value: "nosniff" },
  { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
  { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
  { key: "Content-Security-Policy", value: "default-src 'self'; frame-ancestors 'none'; object-src 'none'; base-uri 'self'" },
]}]; } };
```
- Vercel/most hosts force HTTPS by default; verify with `check-headers.sh`.

## Rate limits and uploads
- Use `@upstash/ratelimit` or middleware with a shared store. Uploads: stream to private storage (S3/R2) via presigned URLs with size and content-type conditions.

## XSS
- Avoid `dangerouslySetInnerHTML`; if needed, DOMPurify. Validate `href` schemes.
