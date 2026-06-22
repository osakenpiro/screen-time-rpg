# 画面録 ネイティブ版 プロト（Report拡張内hexagon）— 配線手順

> 道B（自動取得＝売れる版）のMVP骨格。Xcodeに落として組む前提のSwift一式。
> ★コア価値の最短実証＝「**スクリーンタイムを許可したら、今週の六角形が自動で出る**」。
> ⚠ コンパイル未確認の骨格。API シグネチャは iOS SDK バージョンで微調整が要る場合あり（後述）。

## ファイルと所属ターゲット

| ファイル | ターゲット | 役割 |
|---|---|---|
| `HostApp.swift` | **本体アプリ** | 認可（FamilyControls）＋ `DeviceActivityReport` 埋め込み |
| `Mapping.swift` | **Report拡張** | 6系統写像・調和・状態異常・称号（純ロジック） |
| `ReportExtension.swift` | **Report拡張** | `@main` ＋ Scene ＋ `makeConfiguration`（集計→RPGModel） |
| `ReportView.swift` | **Report拡張** | SwiftUI 六角レーダー＋バー＋調和＋称号 |

`Mapping.swift` は本体からも参照したくなるが、**集計値は拡張外に出せない**ので本体に置いても無意味。拡張ターゲットにのみ入れる。

## Xcode セットアップ（順番）

1. **iOS App** プロジェクトを作成（最低 iOS 16）。
2. ターゲット追加：**File → New → Target → Device Activity Report Extension**。
   → 自動で拡張ターゲット＋`Info.plist`＋`@main` 雛形ができる。雛形を本リポの4ファイルで置き換える。
3. **Family Controls entitlement** を本体・拡張の両方に付与：
   - Signing & Capabilities → **+ Capability → Family Controls**。
   - 配布（TestFlight/App Store）には Apple への **個別申請＝承認が必要**（`Family Controls (Distribution)`）。これが**律速**なので最初に出す。
   - 開発中（実機デバッグ）は development entitlement で動く。
4. **App Group** は本プロト不要（拡張内完結のため）。将来ユーザー主導保存を足すなら検討。
5. 本体の `Info.plist` に用途説明（`NSUserTrackingUsageDescription` ではなく Family Controls の許可は OS ダイアログが出る）。
6. 実機でビルド（**シミュレータはスクリーンタイムのデータが無い**ので実機必須）。

## データフロー（制約の再掲）

```
iOS が集計
  → DeviceActivityReport(.rpg) を本体に置く
  → 拡張の makeConfiguration がカテゴリ別 duration を受け取る（入ってくるだけ）
  → RPGModel.build() で6系統XP・調和・状態異常・称号を算出
  → RPGReportView が SwiftUI で描画
  ✗ 算出値を本体/サーバへは返せない（サンドボックス）
```

## 既知の注意・不確実点（断定しない）

- `DeviceActivityData` / `CategoryActivity` の async sequence の正確なプロパティ名・階層は SDK 版で差がある。`category.totalActivityDuration` と `category.category.localizedDisplayName` を使う前提だが、Xcode 補完で要確認。
- カテゴリ表示名はロケール依存（英語/日本語）。`CategoryMap` は両対応のキーワード一致にしてあるが、実機の実際の表示名で要調整。
- 拡張はメモリ・実行時間がタイト。重い処理は避ける（本プロトは軽い）。
- 非公式に集計値を外へ出すSDK/トリックは脆く・審査グレー＝使わない。

## このプロトで「できる／まだない」

- できる：認可フロー、週次の自動六角形、調和、状態異常、称号、Lv（副次）。
- まだない（v1+）：履歴の永続（拡張制約で要工夫）、ユーザー主導の画像保存共有、目標バランスのカスタム、課金。

## 次の一手
1. Apple Developer で **Family Controls (Distribution) entitlement 申請**（律速・先に出す）。
2. 実機で 1〜6 を通し、`RPGReportView` が出るまで（＝コア体験）を最初の山に。
3. 出たら Web版の称号・配色に寄せて仕上げ → TestFlight。
