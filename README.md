MUSEMON - # The FED-OS Resistance
Shared-map pixel prototype built from the supplied handoff: invite-only email login, player presence, movement and server-issued markdown save tokens. Web frontend uses Vite + vanilla JS; backend uses Supabase; Android uses Capacitor; desktop uses Tauri 2.

Start with docs/DEPLOYMENT.md. Existing Supabase schemas require review before running the initial SQL. Nothing has been deployed or changed in your account.

Run `npm install` and `npm run dev` for local web. An offline movement demo is available on the login screen.

Set config.js AUTH_REDIRECT_URL to your actual deployed Pages index.html URL before native builds. Native callback URL import is provided as a temporary alternative to native deep links.

ZIP includes source and GitHub workflows, not compiled APK/EXE/DMG files. Payment links were not provided; no live payment widgets are invented. Original paid fonts are not bundled. Original art/audio is not provided: canvas shapes and generated icons are placeholders.

Not tested against your live Supabase project or native compilers. See docs/SECURITY.md before inviting production users.
