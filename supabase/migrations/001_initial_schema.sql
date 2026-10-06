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
  creature_level          int not null default 1,
  creature_xp             bigint not null default 0,
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
  last_y                  int not null default 1,
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

alter table invited_trainers enable row level security;
alter table player_profiles  enable row level security;
alter table save_revisions   enable row level security;
alter table ban_requests     enable row level security;
alter table active_bans      enable row level security;

drop policy if exists "read own invite" on invited_trainers;
create policy "read own invite" on invited_trainers for select
  using (auth.jwt() ->> 'email' = email);

drop policy if exists "read own profile" on player_profiles;
create policy "read own profile" on player_profiles for select
  using (auth.jwt() ->> 'email' = email);

revoke update on public.player_profiles from authenticated;
grant update (last_x, last_y, map_id) on public.player_profiles to authenticated;

drop policy if exists "read own revisions" on save_revisions;
create policy "read own revisions" on save_revisions for select
  using (player_id in (select id from player_profiles
                       where email = auth.jwt() ->> 'email'));

drop policy if exists "root admin reads bans" on ban_requests;
create policy "root admin reads bans" on ban_requests for select
  using (auth.jwt() ->> 'email' = 'museai@fedpromptly.com');

drop policy if exists "root admin reads active bans" on active_bans;
create policy "root admin reads active bans" on active_bans for select
  using (auth.jwt() ->> 'email' = 'museai@fedpromptly.com');
create or replace function commit_save(p_player_id uuid,p_payload jsonb,p_hash text,p_signature text)
returns integer language plpgsql security definer set search_path=public as $$
declare r integer;
begin
perform 1 from player_profiles where id=p_player_id for update;
if not found then raise exception 'Missing profile'; end if;
select coalesce(max(revision_no),0)+1 into r from save_revisions where player_id=p_player_id;
insert into save_revisions(player_id,revision_no,payload_hash,signature) values(p_player_id,r,p_hash,p_signature);
update player_profiles set last_server_sync=now(),save_timestamp=(p_payload->>'save_timestamp')::bigint where id=p_player_id;
return r;
end;$$;
revoke all on function commit_save(uuid,jsonb,text,text) from public,anon,authenticated;
grant execute on function commit_save(uuid,jsonb,text,text) to service_role;
revoke insert,update,delete on invited_trainers,player_profiles,save_revisions,ban_requests,active_bans from anon,authenticated;
grant select on invited_trainers,player_profiles,save_revisions,ban_requests,active_bans to authenticated;
