# 8. Block field tampering

## What to check
- Look for mass assignment: `User.create(req.body)`, `Model.update(**request.data)`, `fill($request->all())`, spread of body into DB writes.
- Check that role, isAdmin, price, ownerId, status, balance, emailVerified cannot come from the client.

## How to fix
- Allow-list writable fields per endpoint (schema `.pick`, serializer `fields`, Laravel `$fillable`, Django `fields`).
- Reject unknown keys (`.strict()`).
- Compute sensitive values server-side.

## How to verify
- Send extra fields (`role`, `isAdmin`, `price`, `owner_id`) in create/update requests: expect them ignored or rejected, DB unchanged.
