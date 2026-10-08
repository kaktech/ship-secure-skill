# 14. Validate all input

## What to check
- Every entry point (body, query, params, headers, cookies, uploads, webhooks) has server-side schema validation: type, length, range, format, enum.
- Check for missing size limits on JSON bodies and arrays.

## How to fix
- Add schema validation (zod, joi, pydantic, Django forms/DRF serializers, Laravel FormRequest).
- Reject unknown fields, enforce max lengths and body size.
- Validate on the server even when the client validates.

## How to verify
- Send wrong types, huge strings, nulls, arrays-for-strings, negative numbers: expect 400/422 with generic errors and no stack traces.
