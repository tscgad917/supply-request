-- ===================================================================
--  傳票耗材申請系統：資料表
--  用法：Supabase 後台左邊 SQL Editor → New query → 整段貼上 → Run
--
--  ※ 如果你之前跑過舊版（沒有批次功能的那版），把下面兩行的 -- 拿掉
--    再執行，會把舊的測試資料清掉重建。正式上線後就不要再動這兩行。
-- ===================================================================

-- drop table if exists public.supply_requests;
-- drop table if exists public.supply_batches;


-- ---------- 批次（每次收單＝一個批次，等於原本 Excel 的一個分頁）----------
create table if not exists public.supply_batches (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  code       text        not null unique,     -- 批次代號，例如 1150929
  route      text,                            -- 路線名稱，例如 下半月路線
  deadline   date        not null,            -- 截止日（含當天）
  units      jsonb       not null default '[]'::jsonb,  -- 這批要收哪些單位
  note       text
);

create index if not exists supply_batches_deadline_idx on public.supply_batches (deadline desc);


-- ---------- 申請單（一個單位在一個批次只會有一張，可以一直改）----------
create table if not exists public.supply_requests (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  batch_code  text        not null,           -- 屬於哪個批次
  unit_code   text        not null,           -- 填單單位（分社代號）
  applicant   text        not null,           -- 最後一次填單的人
  apply_date  date        not null,           -- 填單日期
  items       jsonb       not null default '[]'::jsonb,  -- [{name,qty,unit}]
  item_count  integer     not null default 0,
  note        text
);

-- 這條是關鍵：同一批次同一單位只能有一張單，再存就是覆蓋
create unique index if not exists supply_requests_batch_unit_uidx
  on public.supply_requests (batch_code, unit_code);

create index if not exists supply_requests_unit_idx on public.supply_requests (unit_code);


-- ---------- 權限 ----------
alter table public.supply_batches  enable row level security;
alter table public.supply_requests enable row level security;

drop policy if exists "batches read"    on public.supply_batches;
drop policy if exists "batches write"   on public.supply_batches;
drop policy if exists "requests read"   on public.supply_requests;
drop policy if exists "requests insert" on public.supply_requests;
drop policy if exists "requests update" on public.supply_requests;
drop policy if exists "requests delete" on public.supply_requests;

create policy "batches read"  on public.supply_batches for select to anon, authenticated using (true);
create policy "batches write" on public.supply_batches for all    to anon, authenticated using (true) with check (true);

create policy "requests read"   on public.supply_requests for select to anon, authenticated using (true);
create policy "requests insert" on public.supply_requests for insert to anon, authenticated with check (true);
create policy "requests update" on public.supply_requests for update to anon, authenticated using (true) with check (true);
create policy "requests delete" on public.supply_requests for delete to anon, authenticated using (true);
