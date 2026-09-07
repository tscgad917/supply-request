-- ===================================================================
--  傳票耗材申請系統：資料表
--  用法：Supabase 後台左邊 SQL Editor → New query → 整段貼上 → Run
-- ===================================================================

create table if not exists public.supply_requests (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  unit_code   text        not null,          -- 填單單位（分社代號）
  applicant   text        not null,          -- 填單人
  apply_date  date        not null,          -- 申請日期
  period      text,                          -- 上半月 / 下半月
  items       jsonb       not null default '[]'::jsonb,  -- [{name,qty,unit}]
  item_count  integer     not null default 0,
  note        text                            -- 其他項目與備註
);

create index if not exists supply_requests_date_idx on public.supply_requests (apply_date desc);
create index if not exists supply_requests_unit_idx on public.supply_requests (unit_code);

-- 開啟資料列安全性
alter table public.supply_requests enable row level security;

-- 重複執行時先清掉舊規則，避免報錯
drop policy if exists "anyone can insert"  on public.supply_requests;
drop policy if exists "anyone can select"  on public.supply_requests;
drop policy if exists "anyone can delete"  on public.supply_requests;

-- 分社填單：允許新增
create policy "anyone can insert" on public.supply_requests
  for insert to anon, authenticated with check (true);

-- 後台查詢與彙總：允許讀取
create policy "anyone can select" on public.supply_requests
  for select to anon, authenticated using (true);

-- 後台刪單：允許刪除
create policy "anyone can delete" on public.supply_requests
  for delete to anon, authenticated using (true);

-- ===================================================================
--  想關掉「任何人都能刪」的話，把上面 delete 那段整個刪掉再重跑一次，
--  後台的刪除鈕就會失效（畫面還在，但按了會出現錯誤訊息）。
-- ===================================================================
