# Family Controls (Distribution) entitlement 申請文面

> **🅢 ステータス（2026-06-22 SES-669）**: Apple Developer Program **未加入**を確認＝entitlement提出は **¥12,980/年の加入が前提**（無料アカウント不可・抜け道なし）。本人判断で **当面見送り**、Web版を入口に維持。加入トリガ＝(a)mailto待ち登録に反応／(b)Mac確保／(c)iOS複数本の意思固め。会費はアカウント全体（全iOSアプリ共通）。加入後はこのパケットで即提出可。

> 申請先：Apple Developer → Contact → Request the Family Controls (Distribution) capability
> （`developer.apple.com/contact/request/family-controls-distribution`）。
> Apple は英語審査。下の **EN** をフォームに貼る。**JP** は自分用の対訳。

---

## 🚀 提出パケット v1（2026-06-22 確定・これを上から実行）

**まとめ（3行）**
- entitlement は **アプリ単位ではなく bundle ID 単位**で承認される（Apple 明記）。→ **本体アプリ**と **DeviceActivityReport 拡張**で **2 回**出す。
- 全部 **Windows で完結**：Developer portal で App ID 登録 →このフォーム提出。**Mac は不要**（Mac が要るのは後の実機ビルドだけ／「実機ビルドは Mac 確保後」は提出には掛からない）。
- 律速タスクなので**先に出して審査を回す**。承認は数日〜数週間、落ちても理由が返って再申請可。

**提出手順**
1. Developer portal → Certificates, Identifiers & Profiles → **Identifiers** で App ID を 2 つ登録し、両方に **Family Controls** capability を ON：
   - 本体：`com.osakenpiro.gamenroku`（※実際に使う bundle ID に合わせる。ドメイン未所有なら `com.osakenpiro.*` で可）
   - 拡張：`com.osakenpiro.gamenroku.RPGReport`（本体 ID の子・命名は任意）
2. このフォーム（`developer.apple.com/contact/request/family-controls-distribution`・要ログイン）を **bundle ID ごとに 1 回ずつ＝計 2 回**提出。各回で下の該当ブロックを貼る。
3. 承認後、Mac/Xcode で Signing & Capabilities → Family Controls を両ターゲットに紐付け（ここで初めて Mac）。

**フォームで訊かれる項目（実物で要確認・2026 時点の想定）**：氏名 / Developer 連絡先メール・Team、App 名、**App の Bundle ID**、配布形態（App Store）、**Family Controls を使う理由の説明**。説明欄に下の EN を貼る。

### ▶ 提出①：本体アプリ（host app）
- **Bundle ID:** `com.osakenpiro.gamenroku`（自分の実 ID に置換）
- **Reason / description（説明欄に貼る EN）:**

> Gamenroku (画面録) — Screen Time RPG. This is the **host app**. It requests **individual** Family Controls authorization (`AuthorizationCenter.requestAuthorization(for: .individual)`) so the user can opt in to visualizing **their own** Screen Time, and it embeds a `DeviceActivityReport(.rpg, filter:)` view. The app reframes the user's own device-activity as a balanced six-stat RPG sheet whose goal is *balance* (a harmony score), not minimizing usage. It is **not** a parental-control or third-party-monitoring product and never observes another person's device. No Screen Time data leaves the device; the app has no backend or account system. Distribution: App Store (Health & Fitness / Lifestyle).

### ▶ 提出②：DeviceActivityReport 拡張（report extension）
- **Bundle ID:** `com.osakenpiro.gamenroku.RPGReport`（自分の実 ID に置換）
- **Reason / description（説明欄に貼る EN）:**

> DeviceActivityReport extension for Gamenroku (画面録) — Screen Time RPG. This `DeviceActivityReportExtension` receives the user's own weekly per-category usage via `makeConfiguration(representing:)` and renders a hexagonal RPG visualization (six stats + a harmony score) **entirely inside the extension sandbox**. The aggregated data is processed only on-device and is **never** transmitted off the device, to the host app, or to any server — consistent with the extension's sandbox. Uses **individual** authorization; not a parental-control or monitoring product. Distribution: App Store.

### ✅ 提出前チェック
- [ ] App ID を 2 つ portal 登録済み・両方 Family Controls capability ON
- [ ] 「**individual** authorization・自分の端末・他者監視ではない」を両ブロックで明言（審査の最重要ポイント）
- [ ] 「データは端末外に出ない／拡張サンドボックス内完結」を明言（設計と一致＝説得力）
- [ ] **本体・拡張の 2 件**を別々に提出（per bundle ID）
- [ ] 配布形態 = App Store

> 出典：Apple は「Screen Time API の拡張（Device Activity Report 等）を使う場合は各拡張についても同じ申請が要る／申請は **app 単位ではなく bundle ID 単位**」と案内（[Requesting the Family Controls entitlement](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement)）。フォームの正確な項目はログイン後の実画面で最終確認すること。

---

## EN（フォーム貼り付け用 / 詳細版・参考）

**App name:** Gamenroku (画面録) — Screen Time RPG

**What the app does:**
Gamenroku is a personal digital-wellbeing app. It reframes the user's *own* Screen Time as a balanced RPG character sheet: the time spent in each app category becomes XP across six stats, and the goal the app rewards is *balance* (a "harmony" score), not minimizing or maximizing numbers. Over-use of any one category surfaces as a gentle "status ailment." The aim is to reduce the guilt/shame framing of typical screen-time dashboards and encourage a balanced, intentional relationship with the device.

**Why Family Controls is required:**
The app displays a custom visualization (a hexagonal radar of the six stats) of the user's own device-activity data. This requires the **DeviceActivityReport** API, which is only available with the Family Controls entitlement. We use **individual authorization** (the user authorizes their own device); the app is **not** a parental-control or third-party-monitoring product and does not manage or observe anyone else's device.

**APIs used:**
- `FamilyControls` — individual authorization (`AuthorizationCenter.requestAuthorization(for: .individual)`).
- `DeviceActivity` — `DeviceActivityReport` + a `DeviceActivityReportExtension` that aggregates the user's weekly category usage and renders the RPG visualization entirely on-device.
- (No `ManagedSettings` shielding/blocking in v1.)

**Data handling / privacy:**
All Screen Time data is processed **only inside the on-device report extension** and is **never** transmitted off the device or to any server. The app has no backend and no account system. This privacy guarantee is a core selling point of the product.

**Distribution:** App Store, consumer Health & Fitness / Lifestyle category.

---

## JP（対訳・自分用）

- アプリ名：画面録（Gamenroku）— Screen Time RPG
- 何をする：自分のスクリーンタイムを6系統のRPGステータスに読み替える個人向けウェルビーイングアプリ。報酬軸は「調和（バランス）」で、数字の最小化/最大化ではない。過剰は「状態異常」としてやさしく提示。罪悪感ベースの既存ダッシュボードへのアンチテーゼ。
- なぜ必要：自分の端末の使用状況を独自可視化（六角レーダー）するため `DeviceActivityReport` を使う＝Family Controls entitlement 必須。**individual 認可**（自分の端末を自分で許可）。**ペアレンタルコントロール/他者監視ではない**。
- 使用API：FamilyControls（individual認可）／DeviceActivity（Report拡張で週次集計＋描画を端末内完結）。v1で ManagedSettings のブロックは未使用。
- データ：集計は**端末内のReport拡張だけ**で処理し、**外部/サーバへ一切送信しない**。バックエンドもアカウントも無し。プライバシーが売り。
- 配布：App Store、健康/ライフスタイル系。

## 申請のコツ
- 「individual authorization・自分の端末・他者監視でない」を明言（審査が気にする点）。
- 「データは端末外に出ない」を強調（拡張サンドボックスの設計と一致＝説得力）。
- 落ちたら理由が返るので、用途を具体化して再申請可。**律速なので開発開始前に出す**。
- **ターゲットごとに申請**：本体アプリだけでなく、**DeviceActivityReport 拡張ターゲット**にも Family Controls capability を付ける。Apple は「family-control を使う各ターゲット」を見るので、拡張についても同様の用途説明を添える。
- **開発用は申請不要**：`com.apple.developer.family-controls`（Development）は無申請で即使える。App Store 配布に要るのが今回の **Distribution** 版（このフォーム）。
- entitlement キー：`com.apple.developer.family-controls`。Xcode の Signing & Capabilities で **Family Controls** を本体＋拡張の両ターゲットに追加。
