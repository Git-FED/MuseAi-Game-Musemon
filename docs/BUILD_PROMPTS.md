FED-OS RESISTANCE — COMPLETE BUILD HANDOFF
1. Project facts
Supabase URL: https://fyinkxfldtfxplctztuv.supabase.co

Supabase publishable: sb_publishable__jeIxN8d_CCHS-HNKQNbtg_UOC0wubY

Root admin email: museai@fedpromptly.com

Target: invite-only pixel MMO, browser + Android + desktop

Stack: vanilla JS (ES modules), HTML5 canvas, Supabase, Capacitor, Tauri

2. File tree
text
fed-os-resistance/
├── .github/workflows/deploy.yml
├── .github/funding.yml
├── .gitignore
├── assets/css/terminal.css
├── assets/js/supabase-client.js
├── assets/js/auth_gate.js
├── assets/js/multiplayer.js
├── assets/js/game.js
├── assets/js/save_handler.js
├── assets/js/native_bridge.js
├── supabase/migrations/001_initial_schema.sql
├── supabase/functions/verify-save/index.ts
├── supabase/functions/issue-save/index.ts
├── src-tauri/Cargo.toml
├── src-tauri/tauri.conf.json
├── src-tauri/src/main.rs
├── docs/save_format.md
├── index.html
├── game.html
├── landing.html
├── config.js
├── package.json
├── capacitor.config.json
├── README.md
├── LICENSE
└── .gitignore
3. Prompts for every file (paste into Claude Code / Cursor in order)
P01 — config.js

text
Create config.js. Export CONFIG with:
- SUPABASE_URL = "https://fyinkxfldtfxplctztuv.supabase.co"
- SUPABASE_PUBLISHABLE = "sb_publishable__jeIxN8d_CCHS-HNKQNbtg_UOC0wubY"
- GAME_VERSION = "1.0.0"
Attach to window.CONFIG.
P02 — docs/save_format.md

text
Create docs/save_format.md. Define:
- Canonical save JSON with fixed key order.
- Hashed fields = every field except server_signature and revision_no.
- Server-authoritative fields overwritten on issue-save: creature_level,
  creature_xp, cap_unlocked, creature_stats, creature_moves,
  creature_primary_type, creature_secondary_type, faction,
  suspicion_index, memory_integrity, hubs_cleared.
- Client-authoritative: map_id, x_coord, y_coord, inventory, intrusive_logs.
- First-save request: { first_save: true, starting_wing }.
- Response shape from verify-save: { ok, status, revision_no, player, save }.
- Response shape from issue-save: { ok, revision_no, payload_hash,
  server_signature, normalized_payload }.
- Markdown wrapper template for the .md file.
P03 — assets/js/supabase-client.js

text
Create assets/js/supabase-client.js. Import createClient from
https://esm.sh/@supabase/supabase-js@2. Initialize window.supabase from
window.CONFIG with auth.persistSession, autoRefreshToken,
detectSessionInUrl. Expose window.edgeFn(name).
P04 — assets/css/terminal.css

text
Create assets/css/terminal.css. Dark theme: bg #121214, fg #e1e1e6,
accent #04d361. Monospace. Centered login container, dashed drop zone,
canvas styling with image-rendering: pixelated. Style for .wing-card
buttons on the check-in screen.
P05 — index.html

text
Create index.html — login terminal. Email input, "Send Magic Link"
button, drop zone for .md (hidden until session), "Boot Game Engine"
button (hidden until session), Check-In screen with three wing cards
(IoT / Lounge / Mainframe) shown only on first-save. Link
assets/css/terminal.css. Load config.js, assets/js/supabase-client.js,
assets/js/auth_gate.js as ES modules.
P06 — assets/js/auth_gate.js

text
Create assets/js/auth_gate.js. Behaviors:
1. Send Magic Link via supabase.auth.signInWithOtp with emailRedirectTo.
2. onAuthStateChange reveals drop zone + boot button.
3. Parse ```json block from uploaded .md.
4. POST to verify-save with Authorization: Bearer <jwt> and apikey header.
5. On result.ok=false, alert appropriate message.
6. On result.ok=true, store result.save → sessionStorage "fedos_save",
   result.player → "fedos_profile", redirect to game.html.
7. FIRST-SAVE: if no .md uploaded but session valid, show Check-In with
   3 wing cards. On card click, POST to issue-save with
   { first_save: true, starting_wing: "iot"|"lounge"|"mainframe" }.
   Download returned normalized_payload as muse_save_<email>.md.
   Then redirect to game.html.
All shapes follow docs/save_format.md.
P07 — game.html

text
Create game.html. 640x480 canvas id="gameCanvas", HUD div, link
assets/css/terminal.css. Load in this order as ES modules: config.js,
assets/js/supabase-client.js, assets/js/multiplayer.js,
assets/js/native_bridge.js, assets/js/save_handler.js, assets/js/game.js.
P08 — assets/js/multiplayer.js

text
Create assets/js/multiplayer.js. Supabase Realtime:
- Join channel `map:${mapId}` on load.
- Presence tracks joins/leaves. window.remotePlayers keyed by id:
  { name, x, y, dir }.
- Broadcast movement queued, max 10/sec, coalescing intermediate steps.
- Interpolate remote positions in game.js.
- Leave channel and clear remotePlayers on beforeunload and map change.
- Publish initial position on join.
- Expose window.publishMove(x, y, dir).
P09 — assets/js/game.js

text
Create assets/js/game.js. 20x15 map, 32px tiles = 640x480 canvas exact.
WASD movement, 140ms per step. Esc opens save menu (calls
window.onSaveGame). Do NOT use S for save. Read sessionStorage
fedos_save + fedos_profile, redirect to index.html if missing. Populate
window.gameState. Render local player + all window.remotePlayers with
name tags. Camera scroll clamped at map edges (canvas == map, so no
scroll needed — draw whole map). On each step call
window.publishMove(x, y, dir). On Esc call window.onSaveGame.
P10 — assets/js/save_handler.js

text
Create assets/js/save_handler.js.
- Build payload per docs/save_format.md.
- POST to issue-save with Authorization: Bearer <jwt>, apikey header.
- Response has normalized_payload. Download that (not client payload)
  as muse_save_<email>.md with markdown wrapper.
- Attach to window.onSaveGame.
- Delegate download to native_bridge.js if running on Android/desktop.
P11 — assets/js/native_bridge.js

text
Create assets/js/native_bridge.js. Detect:
- window.Capacitor?.Plugins?.Filesystem → Android → write to Documents
  via Filesystem.writeFile, then Filesystem.getUri, then Share.share.
- window.__TAURI__ → Desktop → writeTextFile to AppLocalData, then
  open the folder via shell.open.
- Else → browser download via Blob + <a download>.
Expose window.saveFile(name, content) that routes appropriately.
P12 — supabase/migrations/001_initial_schema.sql

Paste this exactly:

sql
create extension if not exists pgcrypto;

create table if not exists invited_trainers (
  id          uuid primary key default gen_random_uuid(),
  email       text unique not null,
  invited_by  text references invited_trainers(email) on delete set null,
  is_active   boolean not null default true,
  ban_reason  text,
  banned_at   timestamptz,
  created_at  timestamptz not null default timezone('utc', now())
);

insert into invited_trainers (email, is_active)
values ('museai@fedpromptly.com', true)
on conflict (email) do nothing;

create table if not exists player_profiles (
  id                      uuid primary key default gen_random_uuid(),
  email                   text unique not null references invited_trainers(email) on delete cascade,
  trainer_name            text not null default 'Guest',
  creature_name           text not null default 'Root-Companion',
  creature_primary_type   text not null default 'C++',
  creature_secondary_type text,
  creature_level          int not null default 12,
  creature_xp             bigint not null default 15000,
  creature_moves          text[] not null default '{}',
  creature_stats          jsonb not null default '{"hp":60,"atk":65,"def":60,"spd":70}'::jsonb,
  faction                 text not null default 'HACKER'
                          check (faction in ('HACKER','BUILDER')),
  account_status          text not null default 'ACTIVE'
                          check (account_status in ('ACTIVE','BANNED','PURGED')),
  cap_unlocked            int not null default 10,
  suspicion_index         int not null default 0,
  memory_integrity        int not null default 100,
  hubs_cleared            text[] not null default '{}',
  map_id                  text not null default 'meta_hotel_lobby_f1',
  last_x                  int not null default 8,
  last_y                  int not null default 12,
  last_server_sync        timestamptz not null default timezone('utc', now()),
  save_timestamp          bigint not null default 0,
  created_at              timestamptz not null default timezone('utc', now()),
  updated_at              timestamptz not null default timezone('utc', now())
);

create table if not exists save_revisions (
  id            uuid primary key default gen_random_uuid(),
  player_id     uuid not null references player_profiles(id) on delete cascade,
  revision_no   int  not null,
  payload_hash  text not null,
  signature     text not null,
  created_at    timestamptz not null default timezone('utc', now()),
  unique (player_id, revision_no)
);

create index if not exists idx_save_revisions_player
  on save_revisions (player_id, revision_no desc);

create table if not exists ban_requests (
  id             uuid primary key default gen_random_uuid(),
  player_email   text not null,
  reason         text not null,
  evidence       jsonb not null default '{}'::jsonb,
  reviewed_by    uuid references invited_trainers(id),
  reviewed_at    timestamptz,
  created_at     timestamptz not null default timezone('utc', now())
);

create table if not exists active_bans (
  id          uuid primary key default gen_random_uuid(),
  email       text not null,
  scope       text not null check (scope in ('USER','BRANCH')),
  reason      text not null,
  banned_by   uuid references invited_trainers(id),
  banned_at   timestamptz not null default timezone('utc', now())
);

create or replace function latest_revision(p_player_id uuid)
returns int as $$
  select coalesce(max(revision_no), 0)
  from save_revisions
  where player_id = p_player_id;
$$ language sql stable;

create or replace function bump_revision(p_player_id uuid)
returns int as $$
declare
  next_rev int;
begin
  select coalesce(max(revision_no), 0) + 1 into next_rev
  from save_revisions where player_id = p_player_id;
  return next_rev;
end;
$$ language plpgsql;

alter table invited_trainers enable row level security;
alter table player_profiles  enable row level security;
alter table save_revisions   enable row level security;
alter table ban_requests     enable row level security;
alter table active_bans      enable row level security;

create policy "read own invite" on invited_trainers for select
  using (auth.jwt() ->> 'email' = email);

create policy "read own profile" on player_profiles for select
  using (auth.jwt() ->> 'email' = email);

revoke update on public.player_profiles from authenticated;
grant update (last_x, last_y, map_id) on public.player_profiles to authenticated;

create policy "read own revisions" on save_revisions for select
  using (player_id in (select id from player_profiles
                       where email = auth.jwt() ->> 'email'));

create policy "root admin reads bans" on ban_requests for select
  using (auth.jwt() ->> 'email' = 'museai@fedpromptly.com');

create policy "root admin reads active bans" on active_bans for select
  using (auth.jwt() ->> 'email' = 'museai@fedpromptly.com');
P13 — supabase/functions/verify-save/index.ts

Paste this exactly:

typescript
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS"
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status, headers: { "Content-Type": "application/json", ...CORS }
  });
}

async function sha256Hex(input: string) {
  const buf = new TextEncoder().encode(input);
  const d = await crypto.subtle.digest("SHA-256", buf);
  return [...new Uint8Array(d)].map(b => b.toString(16).padStart(2, "0")).join("");
}

async function hmacHex(secret: string, msg: string) {
  const k = await crypto.subtle.importKey(
    "raw", new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" }, false, ["sign"]
  );
  const s = await crypto.subtle.sign("HMAC", k, new TextEncoder().encode(msg));
  return [...new Uint8Array(s)].map(b => b.toString(16).padStart(2, "0")).join("");
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: CORS });
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  const jwt = req.headers.get("Authorization")?.replace("Bearer ", "");
  if (!jwt) return json({ error: "No bearer" }, 401);

  const admin = createClient(SUPABASE_URL, SERVICE_KEY);
  const { data: u } = await admin.auth.getUser(jwt);
  if (!u?.user?.email) return json({ error: "Invalid session" }, 401);
  const sessionEmail = u.user.email;

  const { payload } = await req.json();
  if (!payload) return json({ error: "payload required" }, 400);
  if (payload.email?.toLowerCase() !== sessionEmail.toLowerCase())
    return json({ ok: false, status: "EMAIL_MISMATCH" });

  const { data: player } = await admin.from("player_profiles")
    .select("id,email,account_status,creature_level,cap_unlocked,faction,last_server_sync")
    .eq("email", sessionEmail).single();
  if (!player) return json({ ok: false, status: "NO_PROFILE" });
  if (player.account_status !== "ACTIVE")
    return json({ ok: false, status: player.account_status });

  const { data: banned } = await admin.from("active_bans")
    .select("id").eq("email", sessionEmail).maybeSingle();
  if (banned) return json({ ok: false, status: "BANNED" });

  const { data: latest } = await admin.from("save_revisions")
    .select("revision_no,payload_hash,signature")
    .eq("player_id", player.id)
    .order("revision_no", { ascending: false })
    .limit(1).maybeSingle();
  if (!latest) return json({ ok: false, status: "NO_REVISIONS" });

  const clean = { ...payload };
  delete clean.server_signature;
  delete clean.revision_no;
  const hash = await sha256Hex(JSON.stringify(clean));

  if (hash !== latest.payload_hash) {
    await admin.from("ban_requests").insert({
      player_email: sessionEmail,
      reason: "REVISION_HASH_MISMATCH",
      evidence: { hash, expected: latest.payload_hash }
    });
    return json({ ok: false, status: "TAMPER_SUSPECTED" });
  }

  const SERVER_SECRET = Deno.env.get("SERVER_SAVE_SECRET")!;
  const sig = await hmacHex(SERVER_SECRET, hash);
  if (sig !== payload.server_signature) {
    await admin.from("ban_requests").insert({
      player_email: sessionEmail,
      reason: "SIGNATURE_MISMATCH"
    });
    return json({ ok: false, status: "TAMPER_SUSPECTED" });
  }

  return json({
    ok: true, status: "GRANTED",
    revision_no: latest.revision_no,
    player: { id: player.id, email: player.email,
              creature_level: player.creature_level,
              cap_unlocked: player.cap_unlocked,
              faction: player.faction },
    save: payload
  });
});
P14 — supabase/functions/issue-save/index.ts

Paste this exactly:

typescript
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL  = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY   = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const SERVER_SECRET = Deno.env.get("SERVER_SAVE_SECRET")!;

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS"
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status, headers: { "Content-Type": "application/json", ...CORS }
  });
}

async function sha256Hex(input: string) {
  const buf = new TextEncoder().encode(input);
  const d = await crypto.subtle.digest("SHA-256", buf);
  return [...new Uint8Array(d)].map(b => b.toString(16).padStart(2, "0")).join("");
}

async function hmacHex(secret: string, msg: string) {
  const k = await crypto.subtle.importKey(
    "raw", new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" }, false, ["sign"]
  );
  const s = await crypto.subtle.sign("HMAC", k, new TextEncoder().encode(msg));
  return [...new Uint8Array(s)].map(b => b.toString(16).padStart(2, "0")).join("");
}

const WING_STARTS = {
  iot:       { map_id: "hotel_iot_f1",       x: 8,  y: 15 },
  lounge:    { map_id: "hotel_lounge_f2",    x: 14, y: 22 },
  mainframe: { map_id: "hotel_mainframe_f4", x: 4,  y: 12 }
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: CORS });
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  const jwt = req.headers.get("Authorization")?.replace("Bearer ", "");
  if (!jwt) return json({ error: "No bearer" }, 401);

  const admin = createClient(SUPABASE_URL, SERVICE_KEY);
  const { data: u } = await admin.auth.getUser(jwt);
  if (!u?.user?.email) return json({ error: "Invalid session" }, 401);
  const sessionEmail = u.user.email;

  const body = await req.json();
  const isFirst = body.first_save === true;
  const starting_wing = body.starting_wing ?? "iot";

  let profile = (await admin.from("player_profiles")
    .select("id,email,creature_level,creature_xp,creature_stats,creature_moves,creature_primary_type,creature_secondary_type,cap_unlocked,faction,suspicion_index,memory_integrity,hubs_cleared,map_id,last_x,last_y")
    .eq("email", sessionEmail).maybeSingle()).data;

  if (isFirst && !profile) {
    const w = WING_STARTS[starting_wing] ?? WING_STARTS.iot;
    const { data: created } = await admin.from("player_profiles").insert({
      email: sessionEmail,
      trainer_name: sessionEmail.split("@")[0],
      map_id: w.map_id, last_x: w.x, last_y: w.y
    }).select().single();
    profile = created;
  }

  if (!profile) return json({ error: "Profile missing" }, 500);

  const clientPayload = isFirst ? {} : (body.payload ?? {});
  const merged = {
    email: profile.email,
    game_version: clientPayload.game_version ?? "1.0.0",
    stats: {
      lvl: profile.creature_level,
      xp: profile.creature_xp,
      cap_unlocked: profile.cap_unlocked,
      map_id: clientPayload.stats?.map_id ?? profile.map_id,
      x_coord: clientPayload.stats?.x_coord ?? profile.last_x,
      y_coord: clientPayload.stats?.y_coord ?? profile.last_y
    },
    player_profile: {
      trainer_name: profile.email.split("@")[0],
      faction: profile.faction,
      suspicion_index: profile.suspicion_index,
      memory_integrity: profile.memory_integrity,
      hubs_cleared: profile.hubs_cleared,
      intrusive_logs: clientPayload.player_profile?.intrusive_logs ?? []
    },
    creature_data: {
      name: clientPayload.creature_data?.name ?? "Root-Companion",
      primary_syntax: profile.creature_primary_type,
      secondary_syntax: profile.creature_secondary_type,
      active_moveset: profile.creature_moves,
      stats: profile.creature_stats
    },
    inventory: clientPayload.inventory ?? {},
    save_timestamp: Date.now()
  };

  const hash = await sha256Hex(JSON.stringify(merged));
  const sig = await hmacHex(SERVER_SECRET, hash);

  const { data: rev } = await admin.rpc("bump_revision", { p_player_id: profile.id });
  const revision_no = rev ?? 1;

  await admin.from("save_revisions").insert({
    player_id: profile.id,
    revision_no,
    payload_hash: hash,
    signature: sig
  });

  await admin.from("player_profiles").update({
    last_server_sync: new Date().toISOString(),
    save_timestamp: Date.now()
  }).eq("id", profile.id);

  const normalized = { ...merged, revision_no, server_signature: sig };

  return json({
    ok: true,
    revision_no,
    payload_hash: hash,
    server_signature: sig,
    normalized_payload: normalized
  });
});
P15 — package.json

text
Create package.json for a static site with Capacitor + Tauri.
name fed-os-resistance, version 1.0.0, private true.
Scripts: "web": "npx serve .", "android": "npx cap sync android && npx cap open android",
"desktop": "npx tauri build". Dependencies: @capacitor/core,
@capacitor/filesystem, @capacitor/share. DevDependencies:
@capacitor/cli, @tauri-apps/cli.
P16 — capacitor.config.json

text
Create capacitor.config.json. appId "com.fedpromptly.resistance",
appName "FED-OS Resistance", webDir ".". Server androidScheme "https".
P17 — src-tauri/tauri.conf.json

text
Create tauri.conf.json for Tauri v2. productName "FED-OS Resistance",
identifier "com.fedpromptly.resistance", build.frontendDist "../",
app.windows[0] { title, width 960, height 720, resizable true }.
P18 — src-tauri/Cargo.toml

text
Create Cargo.toml. package name fed-os-resistance, version 1.0.0,
edition 2021. Tauri v2 dependencies. Build dependencies tauri-build.
P19 — src-tauri/src/main.rs

text
Create main.rs. fn main() calls fed_os_resistance_lib::run().
P20 — .github/workflows/deploy.yml

text
Create GitHub Actions workflow: on push to main, deploy root to GitHub
Pages using actions/upload-pages-artifact and actions/deploy-pages.
P21 — .github/workflows/android.yml

text
Create workflow: on push to main, setup Java 17, Node 20, run
npm install, npx cap sync android, cd android && ./gradlew assembleRelease,
upload apk as artifact.
P22 — .github/workflows/desktop.yml

text
Create workflow: matrix on macos-latest, ubuntu-latest, windows-latest.
On push to main, setup Rust, Node 20, npm install, npx tauri build,
upload bundles as artifacts.
P23 — landing.html

text
Create landing.html — promotional page. Deep obsidian background
#07070a, neon cyan #00f0ff, violet #7000ff mesh gradients. Plus
Jakarta Sans + Inter. Hero section, feature cards with
glassmorphism, sticky nav. Payments section behind an 18+ age gate
(localStorage flag). Payment embeds: PayPal subscription button,
Stripe buy button, Ko-fi widget, Buy Me a Coffee. All link
assets/css/main.css and assets/js/app.js.
P24 — README.md

text
One paragraph: invite-only pixel MMO, players walk a shared grid map,
see each other via Supabase Realtime, save progress as a signed .md
file. Tech stack: vanilla JS, Supabase, Capacitor, Tauri. Setup
steps: run migration, set SERVER_SAVE_SECRET, deploy both functions,
enable Email auth, seed invites, enable GitHub Pages.
P25 — .gitignore

text
Ignore node_modules, .env*, .DS_Store, Thumbs.db, .vscode, .idea,
dist, src-tauri/target, android/, ios/, any .md except README.md and
docs/*.md.
4. Non-file setup — do these in the browser
Supabase dashboard:

Authentication → Providers → Email → Enable. Turn OFF "Confirm email".

Authentication → URL Configuration → Site URL = your GitHub Pages URL. Add redirects: https://yourname.github.io/repo/ and https://yourname.github.io/repo/game.html.

SQL Editor → paste migration from P12 → Run.

SQL Editor → seed your 100 invites:

sql
insert into invited_trainers (email, is_active)
values ('friend1@example.com', true), ('friend2@example.com', true)
on conflict (email) do nothing;
Edge Functions → New Function → name verify-save → paste P13 → Deploy.

Edge Functions → New Function → name issue-save → paste P14 → Deploy.

Project Settings → Edge Functions → Secrets → add SERVER_SAVE_SECRET with 64 random hex chars.

GitHub:

Push all files.

Settings → Pages → Source: main / root → Save.

5. Android build (after web works)
bash
npm install
npx cap add android
npx cap sync
npx cap open android
Android Studio opens. Build → Build Bundle(s)/APK(s) → Build APK(s). APK is at android/app/build/outputs/apk/debug/app-debug.apk.

6. Desktop build
bash
npm install
npx tauri build
Output at src-tauri/target/release/bundle/. .exe on Windows, .dmg on Mac, .AppImage on Linux.

7. Test order
Deploy Supabase → run migration → deploy functions

Push client files → enable Pages

Open Pages URL → enter museai@fedpromptly.com → magic link → click

Should see Check-In screen with 3 wing cards

Click any wing → .md downloads

Upload that .md → should land in game.html with a moving sprite

Open in second browser with second invited email → should see both sprites

When step 7 works, you're live. Ship.

That's the whole thing. 25 prompts, 2 code files verbatim, migration verbatim, ~30 minutes of setup. Take it to Claude Code or Cursor, feed prompts in order, commit, push, deploy.
