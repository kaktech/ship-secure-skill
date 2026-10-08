# Example: Build mode

## Request
"Add a notes API to my Express app. Users can create, list, edit, and delete their own notes, and attach a PNG or JPG."

## What Claude does
1. Reads `references/build-rules.md` and `references/stacks/express-node.md`.
2. Writes the feature with the controls below.
3. Ends with a short note.

## Secure result (abridged)
```js
const { z } = require("zod");
const multer = require("multer");
const { fileTypeFromBuffer } = require("file-type");
const crypto = require("crypto");

const NoteBody = z.object({ title: z.string().min(1).max(120), body: z.string().max(10_000) }).strict();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 2 * 1024 * 1024, files: 1 } });

router.use(requireAuth);                                   // deny by default

router.get("/notes", async (req, res) => {
  const rows = await db.query("SELECT id, title, body, created_at FROM notes WHERE owner_id = $1", [req.user.id]);
  res.json(rows);                                          // explicit columns only
});

router.put("/notes/:id", async (req, res) => {
  const data = NoteBody.parse(req.body);                   // unknown fields rejected
  const r = await db.query(
    "UPDATE notes SET title=$1, body=$2 WHERE id=$3 AND owner_id=$4 RETURNING id, title, body",
    [data.title, data.body, req.params.id, req.user.id]);  // scoped to caller
  if (!r.rowCount) return res.sendStatus(404);
  res.json(r.rows[0]);
});

router.post("/notes/:id/attachment", upload.single("file"), async (req, res) => {
  const t = await fileTypeFromBuffer(req.file.buffer);
  if (!t || !["image/png", "image/jpeg"].includes(t.mime)) return res.sendStatus(415);
  const key = `${crypto.randomUUID()}.${t.ext}`;           // random name, never the client's
  await privateBucket.put(key, req.file.buffer, { contentType: t.mime });
  /* ...owner-scoped insert of key... */
});
```

## Closing note Claude writes
```
Security controls applied:
- Server-side auth: all /notes routes behind requireAuth (deny by default).
- IDOR/BOLA: every note query filters by owner_id = current user.
- Input validation + field allow-list: zod .strict() on create/update.
- Parameterized queries: $1..$n placeholders only.
- Response trimming: explicit columns, no raw rows.
- Upload limits: 2 MB, content sniffed as PNG/JPEG, random filename, private bucket.

Needs your action:
- Add `npm i zod file-type` and set PRIVATE_BUCKET credentials via env (not committed).
- Add a rate limiter to the upload route if the app is public.
```

## What Claude does not do
For "make the button blue", Claude changes the button and adds no security commentary.
