# Laravel

## Secrets
- `.env` outside web root and git-ignored; `APP_DEBUG=false`, `APP_ENV=production`; `php artisan config:cache`. Rotate `APP_KEY` if leaked (invalidates sessions/encrypted data).

## Sessions
- `config/session.php`: `'secure' => true, 'http_only' => true, 'same_site' => 'lax'`; `SESSION_DRIVER=redis|database`. `$request->session()->regenerate()` on login.

## Middleware
- Rate limit: `RateLimiter::for('login', fn($r) => Limit::perMinute(5)->by($r->input('email').$r->ip()))` and `throttle:login`; Fortify/Breeze include it.
- CSRF is on by default for web routes: do not add routes to `$except` without need.
- Headers: custom middleware or `bepsvpt/secure-headers`. HTTPS: `URL::forceScheme('https')`, `TrustProxies`.

## Validation and mass assignment
- `FormRequest` classes; use `$request->validated()`. Define `$fillable` (never `$guarded = []`).
- IDOR: Policies + `$this->authorize()`, or scope: `$request->user()->posts()->findOrFail($id)`.

## Queries and output
- Eloquent/query builder bindings; avoid `DB::raw`/`whereRaw` with interpolation (use bindings). Blade `{{ }}` escapes; avoid `{!! !!}` on user input.

## Passwords, uploads
- `Hash::make` (bcrypt/argon2 via `config/hashing.php`). Uploads: `mimes:`/`image` rules + size, `store()` on a private disk, `Storage::temporaryUrl` for access.

## Dependencies
- `composer audit`.
