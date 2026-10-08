# Express / Node

## Secrets
- `dotenv` for local only; production from host env/secret manager. Fail fast if required vars are missing.

## Session and cookies
```js
app.set("trust proxy", 1);
app.use(session({ name: "sid", secret: process.env.SESSION_SECRET, resave: false, saveUninitialized: false,
  cookie: { httpOnly: true, secure: true, sameSite: "lax", maxAge: 1000*60*60*8 }, store: redisStore }));
req.session.regenerate(cb) // on login
```

## Middleware
- `helmet()` for headers (configure CSP explicitly). `app.disable("x-powered-by")`.
- Rate limit: `express-rate-limit` (+ `rate-limit-redis` for multi-instance), stricter on `/login`, `/reset`.
- CSRF for cookie auth: `csurf` is deprecated; use `csrf-csrf` or SameSite + Origin check.
- Body limit: `express.json({ limit: "100kb" })`.
- CORS: `cors({ origin: [allowList], credentials: true })`.

## Validation and queries
- zod/joi on every route. `pg`/`mysql2` placeholders (`$1`), Prisma/Knex builders; avoid `$queryRawUnsafe`. Sanitize Mongo input (`express-mongo-sanitize`).

## Passwords
- `argon2` or `bcrypt` (cost 12).

## Uploads
- `multer` with `limits.fileSize`, `fileFilter`, memory or temp storage, random names, magic-byte check (`file-type`), store outside `public/`.

## HTTPS
- Terminate TLS at the proxy; redirect when `req.headers["x-forwarded-proto"] !== "https"`; HSTS via helmet.
