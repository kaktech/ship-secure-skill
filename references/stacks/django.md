# Django

## Secrets
- `SECRET_KEY`, DB creds from env (`django-environ`). `DEBUG=False` in production. `ALLOWED_HOSTS` explicit.

## Settings
```python
SESSION_COOKIE_SECURE = True; SESSION_COOKIE_HTTPONLY = True; SESSION_COOKIE_SAMESITE = "Lax"
CSRF_COOKIE_SECURE = True; CSRF_TRUSTED_ORIGINS = ["https://example.com"]
SECURE_SSL_REDIRECT = True; SECURE_HSTS_SECONDS = 31536000; SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_CONTENT_TYPE_NOSNIFF = True; SECURE_REFERRER_POLICY = "same-origin"
X_FRAME_OPTIONS = "DENY"; SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
PASSWORD_HASHERS = ["django.contrib.auth.hashers.Argon2PasswordHasher", ...]
```
- Run `python manage.py check --deploy`.
- CSP: `django-csp`. Rate limit: `django-ratelimit` or `django-axes` for login lockout.

## Queries, validation
- ORM only. Avoid `.raw()`/`.extra()` with interpolation; use params. Forms/DRF serializers with explicit `fields` (never `__all__`) to stop mass assignment.
- IDOR: `get_object_or_404(Model, pk=pk, owner=request.user)`; DRF `get_queryset()` filtered by user.

## Templates and uploads
- Avoid `|safe`/`mark_safe` on user content. Uploads: validate with `python-magic`/Pillow, `FileExtensionValidator`, `DATA_UPLOAD_MAX_MEMORY_SIZE`, store in private storage; set `MEDIA_ROOT` outside static.
