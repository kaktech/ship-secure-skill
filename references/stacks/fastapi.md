# FastAPI

## Secrets
- `pydantic-settings` `BaseSettings` reading env; no defaults for secrets. `.env` git-ignored.

## Auth
- `Depends(get_current_user)` on every protected route; or router-level `dependencies=[Depends(...)]`. Verify JWT with `PyJWT`/`authlib`: pin algorithms (`algorithms=["RS256"]`), check `exp`, `aud`, `iss`.
- Prefer HttpOnly cookie sessions for browsers (`response.set_cookie(..., httponly=True, secure=True, samesite="lax")`).

## Validation and mass assignment
- Pydantic models with `model_config = ConfigDict(extra="forbid")`. Separate `UserCreate`, `UserUpdate`, `UserRead` models; set `response_model=UserRead` to trim output (item 17).
- IDOR: query with `Model.owner_id == user.id`.

## Middleware
- Headers: custom `@app.middleware("http")` or `secure`. `CORSMiddleware` with explicit origins. `TrustedHostMiddleware`, `HTTPSRedirectMiddleware` (behind a proxy run uvicorn with `--proxy-headers`).
- Rate limit: `slowapi` (Redis storage in production).
- Disable docs in production if private: `FastAPI(docs_url=None, redoc_url=None, openapi_url=None)`.

## DB and passwords
- SQLAlchemy bound params (`text("... :id")`), never f-strings. `passlib[argon2]` or `argon2-cffi`.

## Uploads
- `UploadFile`: check size while streaming, magic bytes via `python-magic`, random names, private storage.

## Dependencies
- `pip-audit`.
