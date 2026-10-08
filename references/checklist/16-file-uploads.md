# 16. Restrict file uploads

## What to check
- Check size limit, type allow-list by content (magic bytes), filename handling, storage location, and how files are served.
- Look for path traversal (`../`), executable extensions, SVG/HTML uploads served inline, and public buckets.

## How to fix
- Enforce max size at the proxy and the app. Allow-list types; verify content, not extension or client MIME.
- Generate random server-side names; store in private storage or outside the web root.
- Serve with `Content-Disposition: attachment` or a separate cookie-less domain, plus `X-Content-Type-Options: nosniff`.
- Strip metadata from images; scan for malware if files are shared between users.

## How to verify
- Upload on staging: a .php/.html/.svg with script, a renamed .exe as .png, a file over the limit, and a name like `../../x`: expect rejection or safe storage.
- Fetch the stored file URL: not executed, correct headers.
