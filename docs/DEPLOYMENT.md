# Start here
1. Extract the ZIP. Upload the contents of fed-os-resistance to your GitHub repository root, preserving paths.
2. GitHub Settings → Pages: select GitHub Actions. Push to main to trigger Web Pages.
3. Supabase: enable Email authentication. Set Site URL and allowed redirect URL to the actual Pages index.html URL. Keep email verification enabled.
4. Review and run supabase/migrations/001_initial_schema.sql in SQL Editor. This is an initial-schema script, NOT a migration guaranteed to fit every older schema from the conversation. Back up an existing project and inspect columns/policies first.
5. Add real invited emails with the invite template. Do not make the invite list public.
6. Set SERVER_SAVE_SECRET in function secrets. Generate it locally with `openssl rand -hex 32`. Supabase provides SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY. Do not set reserved SUPABASE_ variables manually.
7. Deploy issue-save and verify-save. They import _shared/common.ts. Use the CLI in Codespaces so the shared file is included:
```
npx supabase login
npx supabase link --project-ref fyinkxfldtfxplctztuv
npx supabase functions deploy issue-save
npx supabase functions deploy verify-save
```
JWT gateway checks are disabled in config.toml; each function explicitly validates the user JWT itself. Do not remove that validation.
8. Open the site; invited user signs in and uses Check-In. Export and upload the resulting file. Test a second account/browser to verify presence.
9. Actions → Android debug APK → Run workflow. The artifact is a debug/sideload build, not Play Store release signing.
10. Actions → Desktop bundles → Run workflow. Artifacts are not notarized or signed for commercial distribution.

Local web: `npm install`, `npm run dev`. Build: `npm run build`. No lockfile supplied; generate and commit one after dependency installation and testing.

Native login: email links currently return to the web Pages URL, not directly into the native app. To use native login, open the link and copy its complete callback URL into the native callback input described in README; native deep-link registration is future work. Do not promise seamless native onboarding.
