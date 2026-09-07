// 讓網站可以「加到主畫面」，並在斷線時仍打得開表單外框。
const CACHE = "supply-v3";

// config.js 故意不放進來：設定改了要馬上生效，不能被快取住。
const ASSETS = [
  "./", "./index.html", "./admin.html", "./style.css",
  "./items.js", "./manifest.json",
  "./icons/icon-192.png", "./icons/icon-512.png", "./icons/apple-touch-icon.png"
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((ks) => Promise.all(ks.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);
  if (e.request.method !== "GET") return;
  if (url.origin !== location.origin) return;      // Supabase / CDN 一律走網路

  // 設定檔永遠拿最新的，連快取都不寫
  if (url.pathname.endsWith("/config.js")) {
    e.respondWith(fetch(e.request, { cache: "no-store" }).catch(() => caches.match(e.request)));
    return;
  }

  // 其餘：網路優先，沒網路才用快取
  e.respondWith(
    fetch(e.request)
      .then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(e.request, copy));
        return res;
      })
      .catch(() => caches.match(e.request).then((r) => r || caches.match("./index.html")))
  );
});
