# 画面録（がめんろく） / Screen Time RPG

**スクリーンタイムを「浪費の罪悪感」ではなく「すでに鍛えているステータス」として読むツール。**

LIVE → https://osakenpiro.github.io/screen-time-rpg/

iOS設定アプリのスクリーンタイム（カテゴリ別の週合計）を手入力すると、画面の前で過ごした時間が
**6系統のXP**（哲学 PHI／創作 CRE／技術 TEC／発信 OUT／体力 VIT／探究 EXP）になり、六角レーダーと系統別バーで描画される。

- **過剰は状態異常に**：SNS過多＝「無限スクロールの呪縛」など。閾値を超えたぶんだけ連続値で濃くなる（Boolean→Float）。
- **攻略は数字じゃなく調和**：6系統のバランス（正規化シャノンエントロピー）が主役の Float 0.00–1.00。
  調和 ≥ 0.75 かつ状態異常なし＝「バランス・クリア」。
- **Lv＝⌊総XP/847⌋** は副次表示（鍛錬量ログ）。多ければいい設計にはしていない。
- **数字で煽らない**：攻略ヒントは「多い軸を削れ」ではなく「手つかずの軸を足せ」を基本に。

## 設計

- 単一HTML / localStorage 永続化 / API不要・完全クライアントサイド（**入力は端末から出ない**）。
- ゼロコスト・ゼロメンテ（GitHub Pages）。配色は osakenpiro design system（gold単一・void＋stars）。
- 詳細は [`concept-v0.md`](./concept-v0.md)。

## v0 の限界

iOS Screen Time API は非公開のため自動取得は不可。v0 は手入力MVP。
v1 以降で iOS Shortcuts による CSV 書き出し取り込み、週次履歴、目標バランスのカスタムを検討。

---

#全人類UX改善 ／ Visionium・アイデア苗床 ／ 設計思想：Boolean→Float
