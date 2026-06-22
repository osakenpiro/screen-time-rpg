# Family Controls (Distribution) entitlement 申請文面

> 申請先：Apple Developer → Contact → Request the Family Controls (Distribution) capability
> （`developer.apple.com/contact/request/family-controls-distribution`）。
> Apple は英語審査。下の **EN** をフォームに貼る。**JP** は自分用の対訳。

---

## EN（フォーム貼り付け用）

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
