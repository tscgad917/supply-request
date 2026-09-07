# 傳票耗材申請系統 — 上架說明書

一份給第一次做這件事的人的操作手冊。全程用瀏覽器點一點就好，**不需要安裝任何軟體、不需要打指令**。

照著做大約 30 分鐘會完成，做完會得到：

- 一個公開網址，分社同仁打開就能填單（手機可加到桌面，圖示是那隻鱷魚）
- 一個後台網址，輸入密碼 `5888` 可以看所有申請單、彙總、匯出 Excel
- 資料存在 Supabase 雲端資料庫，不會因為換電腦就不見

費用：GitHub 與 Supabase 的免費方案就夠用，不用付錢也不用綁信用卡。

---

## 目錄

1. [先準備兩個帳號](#step-1-先準備兩個帳號)
2. [建立 Supabase 資料庫](#step-2-建立-supabase-資料庫)
3. [建立資料表](#step-3-建立資料表)
4. [把金鑰貼進 config.js](#step-4-把金鑰貼進-configjs)
5. [上傳到 GitHub](#step-5-上傳到-github)
6. [開啟 GitHub Pages，網站就活了](#step-6-開啟-github-pages)
7. [手機加到主畫面](#step-7-手機加到主畫面)
8. [日常怎麼用](#日常怎麼用)
9. [要改東西的時候](#要改東西的時候)
10. [遇到問題](#遇到問題)

---

## Step 1 先準備兩個帳號

| 網站 | 網址 | 用途 |
|---|---|---|
| GitHub | https://github.com | 放網頁、提供網址 |
| Supabase | https://supabase.com | 存申請單資料 |

兩個都可以直接用 Google 帳號註冊，Supabase 建議**直接用 GitHub 帳號登入**，少記一組密碼。

先把兩個帳號都註冊好、都登入成功，再往下做。

---

## Step 2 建立 Supabase 資料庫

1. 登入 https://supabase.com/dashboard
2. 按 **New project**
3. 填寫：
   - **Name**：`supply-request`（隨便取，自己看得懂就好）
   - **Database Password**：按旁邊的 Generate 產生一組，**複製起來貼到記事本存好**
     （這組密碼這個系統用不到，但忘記了以後想改資料庫會很麻煩）
   - **Region**：選 `Northeast Asia (Tokyo)` 或 `Southeast Asia (Singapore)`，離台灣近、比較快
4. 按 **Create new project**，等 1～2 分鐘讓它建好（畫面會顯示 Setting up project）

> ⚠️ 免費專案如果連續 **7 天完全沒人使用**會被自動暫停。只要每週有人填單就不會發生；真的被暫停了，到 Supabase 後台按 **Restore** 就會回來，資料不會不見。

---

## Step 3 建立資料表

1. 在 Supabase 專案畫面，左邊選單點 **SQL Editor**
2. 按 **New query**
3. 打開本專案的 `supabase_setup.sql` 檔案，**整個檔案複製起來**，貼進去
4. 按右下角 **Run**（或按 Ctrl + Enter）
5. 看到 `Success. No rows returned` 就成功了

檢查一下：左邊點 **Table Editor**，應該會看到一張叫 `supply_requests` 的表，欄位有 unit_code、applicant、apply_date 等等。

---

## Step 4 把金鑰貼進 config.js

1. Supabase 左邊選單最下面點 **Settings**（齒輪）→ **API Keys**
2. 這裡有兩個東西要複製：

   | 要找的東西 | 長什麼樣子 |
   |---|---|
   | **Project URL** | `https://abcdefghijk.supabase.co` |
   | **Publishable key** | `sb_publishable_` 開頭的一長串 |

   > 如果你的專案畫面上沒有 Publishable key，只有一把寫著 **anon public** 的，那就複製那把，功能一模一樣。
   > Project URL 若不在這頁，改到 **Settings → Data API** 找。

3. 用記事本（或 VS Code）打開資料夾裡的 **`config.js`**，把兩個值貼到對應位置：

```js
const SUPABASE_URL = "https://abcdefghijk.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_xxxxxxxxxxxxxxxxx";
```

**注意**：引號 `"` 要留著，只換中間那段中文字。存檔。

> 有人會擔心金鑰貼在網頁裡會不會外洩 — 這把 key 本來就是設計成公開的，真正的防線是 Step 3 那段 SQL 設定的權限規則。

---

## Step 5 上傳到 GitHub

### 5-1 建立一個 repository

1. 登入 GitHub，右上角 **＋** → **New repository**
2. 填寫：
   - **Repository name**：`supply-request`
   - 選 **Public**（選 Private 的話免費帳號無法開放網頁）
   - 其他都不用勾，直接按 **Create repository**

### 5-2 把檔案拖上去

1. 在剛建好的空 repository 頁面，點 **uploading an existing file**
   （或走 **Add file** → **Upload files**）
2. 打開電腦上的資料夾，**把裡面所有東西一起拖進網頁的虛線框**
   - 記得連 `icons` 資料夾一起拖，圖示才會出來
   - 隱藏檔 `.nojekyll` 也要（Mac 按 `Cmd + Shift + .`、Windows 在檔案總管勾「隱藏的項目」就看得到）
3. 等所有檔名都列出來後，最下面按 **Commit changes**

上傳完應該會看到這些檔案：

```
index.html          填單頁
admin.html          後台頁
config.js           ← 你剛改過的設定檔
items.js            申請項目清單
style.css           樣式
manifest.json       手機加到桌面的設定
sw.js               離線支援
supabase_setup.sql  資料庫建表語法
.nojekyll           告訴 GitHub 不要亂處理檔案
icons/              圖示（5 個 png）
README.md           這份說明書
```

---

## Step 6 開啟 GitHub Pages

1. 在 repository 上方點 **Settings**（是 repository 的 Settings，不是頭像那個）
2. 左邊選單點 **Pages**
3. **Source** 選 `Deploy from a branch`
4. **Branch** 選 `main`，右邊資料夾選 `/ (root)`，按 **Save**
5. 等 1～3 分鐘，重新整理這一頁，最上面會出現網址：

```
https://你的帳號.github.io/supply-request/
```

點進去，如果看到綠色的鱷魚頁面就成功了。

- 填單頁：`https://你的帳號.github.io/supply-request/`
- 後台頁：`https://你的帳號.github.io/supply-request/admin.html`

### 馬上測試一次

1. 填單頁選一個單位、打名字、選日期，隨便填一個項目數量，按 **送出申請**
2. 出現「已送出，總務課收到了」
3. 打開後台，輸入 `5888`，應該看得到剛剛那張單

看得到 = 全部接通了，可以把填單頁網址發給各分社。

---

## Step 7 手機加到主畫面

網址發給同仁時，順便附上這段：

**iPhone（一定要用 Safari）**
1. Safari 打開填單網址
2. 點下方中間的「分享」圖示（往上的箭頭）
3. 往下滑，選 **加入主畫面**
4. 按右上角「新增」

**Android（Chrome）**
1. Chrome 打開填單網址
2. 右上角「⋮」
3. 選 **加到主畫面** 或 **安裝應用程式**

加完桌面上就會出現鱷魚圖示，點開直接是填單畫面，沒有網址列，跟一般 App 一樣。

---

## 日常怎麼用

### 分社填單

1. 點桌面鱷魚圖示
2. 選填單單位、輸入姓名、選日期（點日期欄會跳出小日曆）
3. 點分類展開（存款傳票／查詢單／會計傳票／＃系列表單／事務耗材），只填要的數量，其他留空
4. 表列沒有的東西寫在最下面「其他項目與備註」
5. 按 **送出申請**

底下那條會即時顯示「已填 N 項」，分類旁邊的數字也會顯示該類填了幾項。
沒填完先關掉也沒關係，內容會自動留在手機裡，下次打開還在。

### 總務課看單

進 `admin.html`，輸入 `5888`：

- **申請紀錄**：一張一張看，點開有明細，可以刪除
- **彙總表**：橫向是分社、直向是項目，跟原本 Excel 一樣的排法，最右邊有合計
- **日期區間 / 單位 / 關鍵字**都可以篩，按「查詢」更新
- **匯出 CSV**：在哪個分頁按，就匯出哪一種格式；用 Excel 開，中文不會亂碼

> 上半月（1～15 日）和下半月（16 日以後）系統會依申請日期自動標記，彙總時用日期區間篩就能分開統計。

---

## 要改東西的時候

所有修改都是同一個流程：**在 GitHub 上點開檔案 → 右上角鉛筆圖示 → 改 → Commit changes**，等 1 分鐘網站就更新了。

| 想改什麼 | 改哪個檔 | 改哪一段 |
|---|---|---|
| 後台密碼 | `config.js` | `ADMIN_PASSWORD` |
| 增減分社代號 | `config.js` | `UNITS` 陣列 |
| 增減申請項目 | `items.js` | 對應分類的 `items`，照 `{ n: "項目名", u: "本" },` 的格式加一行 |
| 新增一個分類 | `items.js` | 複製一整組 `{ id, name, hint, items }` 貼上去改 |
| 換顏色 | `style.css` | 最上面的 `:root` 那幾行色碼 |
| 換圖示 | `icons/` | 換掉同名的 png 檔即可 |

改完手機上如果還是舊畫面，把加到桌面的圖示刪掉重加一次，或在瀏覽器重新整理兩次。

---

## 遇到問題

**打開網頁出現「還沒接上資料庫」黃色提示**
`config.js` 沒改到，或改了但沒上傳到 GitHub。回 Step 4 確認，並確認 GitHub 上的 `config.js` 點開來看是新的內容。

**送出時跳紅色錯誤，寫 `relation "supply_requests" does not exist`**
Step 3 的 SQL 沒跑成功。回 Supabase SQL Editor 再貼一次、按 Run。

**送出時跳紅色錯誤，寫 `row-level security` 或 `permission denied`**
SQL 只跑了建表那段。把 `supabase_setup.sql` **整個檔案**（含最下面的 policy）重跑一次。

**後台密碼打對卻進不去**
確認 `config.js` 裡的 `ADMIN_PASSWORD` 前後有雙引號，例如 `"5888"`。

**GitHub Pages 網址打開是 404**
- 檔案要在 repository 的**最外層**，不能多包一層資料夾（點進去要直接看到 `index.html`）
- 剛設定好要等幾分鐘
- repository 必須是 Public

**圖示沒出現、樣式跑掉**
`icons` 資料夾或 `style.css` 沒上傳成功。回 GitHub 看檔案清單，缺什麼補傳什麼。

**iPhone 加到主畫面找不到選項**
一定要用 Safari，用 Chrome 或從 LINE 裡點開都不行。

---

## 給總務課的一點提醒

這個系統是內部使用的工具，安全性設定得很寬鬆：

- 後台密碼是寫在網頁檔案裡的，懂技術的人看得到，它擋的是「不小心點進去」，不是惡意入侵
- 知道網址的人都能填單、也能讀到資料

放內部通訊錄或群組公告就夠用了。如果之後需要「必須登入才能看」的等級，Supabase 有內建的帳號登入功能可以再加。

備份很簡單：後台按「全部」→「匯出 CSV」，存一份到共用資料夾就是完整備份。建議每個月做一次。
