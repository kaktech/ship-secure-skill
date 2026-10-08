# Mobile app + backend API

## Secrets
- Anything inside the app binary (including `EXPO_PUBLIC_*`, `.env` bundled via build) is extractable. Ship no private keys or third-party secrets. Proxy third-party calls through your backend.

## Auth and storage
- OAuth2/OIDC with PKCE. Short-lived access token, rotating refresh token. Store tokens in Keychain / Keystore (`expo-secure-store`, `react-native-keychain`), not AsyncStorage/SharedPreferences/UserDefaults.
- Backend authorizes every call server-side (items 6-8); never trust client-side role or premium flags. Validate purchase receipts server-side.

## Transport
- HTTPS only: iOS ATS on, Android `usesCleartextTraffic=false` with a network security config. Consider certificate pinning with a rotation plan.

## API hardening
- Token auth means CSRF is mostly N/A (confirm no cookie auth). Rate limit per user and device. Version the API and support forced upgrade. App attestation (App Attest / Play Integrity) for abuse-prone endpoints.
- Trim responses (item 17); mobile clients often get over-fetched data.

## Deep links and WebViews
- Validate deep-link params as untrusted input; require auth for sensitive intents. Disable JavaScript bridges and file access in WebViews unless needed; allow-list URLs.

## Release
- Disable debug flags and logging of tokens/PII; strip source maps from public builds; run `npm audit`/`pod`/Gradle dependency checks.

## Verify
- Inspect the built APK/IPA with `strings`/jadx for keys; proxy traffic through a local proxy on a test device and confirm tokens are not sent over HTTP.
