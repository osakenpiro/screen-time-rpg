# 待ち登録の宛先 — 方針メモ＋昇格手順

## 決定（2026-06-22 rehem）
**当面 mailto 維持。Worker は「準備だけ」して未デプロイ。**

理由：
- 待ち登録が向かう先＝**まだ存在しないネイティブ版**（entitlement 未承認・Mac 未確保で数ヶ月先）。需要は未証明。
- ゼロ署名の段階で Worker＋D1 を常時運用するのは、見返りのない摩擦（ゼロメンテ原則に反する）。
- 現状の `index.html` mailto は動作済み・スクレイプ避け（実行時組立）・失敗時も握りつぶさない。受信は自分の Gmail で十分捌ける量。

## 昇格トリガ（このどれかが起きたら Worker に切替）
- mailto 経由の登録が**実際に複数届く**（手で管理がだるくなる）
- ネイティブ版が **TestFlight 目前**で、整ったリストが要る
- スマホで「メールアプリが開かない」系の取りこぼしが気になり出した

## 昇格手順（Windows / host PS で完結・ゼロコスト枠）
1. `wrangler d1 create gamenroku_waitlist` → 返った `database_id` を `wrangler.toml` に貼る
2. `wrangler d1 execute gamenroku_waitlist --file=schema.sql`（テーブル作成）
3. `wrangler deploy` → 払い出された `https://gamenroku-waitlist.<sub>.workers.dev` を控える
4. **`index.html` の `ENDPOINT='' ` にその URL を入れる（=これだけで切替・mailto は fallback として残る）**
5. デプロイ（Contents API・blob==PUT sha 検証）→ Live で1件テスト投稿 → D1 に入ったか確認

> Cloudflare は host OAuth 済（wrangler whoami＝Account 表示）。D1/Workers は host PS 直 deploy 実績あり。

## 登録の取り出し（昇格後）
```
wrangler d1 execute gamenroku_waitlist --command \
  "SELECT email, datetime(ts/1000,'unixepoch','+9 hours') AS jst FROM waitlist WHERE tool='gamenroku' ORDER BY ts DESC"
```

## 構成
- `waitlist-worker.js` — POST受け口（CORS＝Pages originのみ／email検証／重複は INSERT OR IGNORE）
- `wrangler.toml` — D1 binding（database_id は create 後に貼る）
- `schema.sql` — `waitlist(email, tool, ts, ua)` ＋ UNIQUE(email,tool)
- 受けるのは **email のみ**。スクリーンタイム等の端末データは一切受けない（プライバシー訴求と一致）。
