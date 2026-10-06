-- Replace with real invited addresses; run in SQL Editor.
insert into public.invited_trainers(email,is_active) values ('replace-me@example.com',true) on conflict(email) do nothing;
