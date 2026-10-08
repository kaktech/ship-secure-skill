# Firebase

## Keys
- Web config (apiKey, projectId) is public by design; protection comes from Security Rules and App Check. Admin SDK credentials (service-account JSON) are server-only and never committed.
- Restrict the browser API key by HTTP referrer and API in Google Cloud console.

## Firestore rules (item 4)
```
rules_version = '2';
service cloud.firestore { match /databases/{db}/documents {
  match /users/{uid} { allow read, write: if request.auth != null && request.auth.uid == uid
      && !(request.resource.data.keys().hasAny(['role','isAdmin'])); }
  match /notes/{id} {
    allow read, delete: if request.auth != null && resource.data.ownerId == request.auth.uid;
    allow create: if request.auth != null && request.resource.data.ownerId == request.auth.uid;
    allow update: if request.auth != null && resource.data.ownerId == request.auth.uid
      && request.resource.data.ownerId == resource.data.ownerId;
  }
}}
```
- Never ship `allow read, write: if true` or test-mode rules. Same for Realtime Database (`.read`/`.write`) and Storage rules (check `request.resource.size` and `contentType`).
- Roles via custom claims set by Admin SDK, not client-writable docs.

## Auth, sessions
- Server-side: verify ID tokens with Admin SDK (`verifyIdToken`); use session cookies (`createSessionCookie`) with `httpOnly`, `secure`, `sameSite`. Enable App Check, email enumeration protection, and blocking functions where needed.

## Cloud Functions
- Validate input; check `context.auth`; keep secrets in Secret Manager (`defineSecret`).

## Hosting
- `firebase.json` headers block for CSP/HSTS etc. HTTPS is enforced by Hosting.

## Verify
- Run the Rules Playground and the emulator with unit tests (`@firebase/rules-unit-testing`): unauthenticated and cross-user access must fail.
