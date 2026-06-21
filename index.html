# orb616 untracked-backup 差分通知 → SES-616窓

- 発: SES-619継続窓（rehem）/ 2026-06-20 JST / SES-620 gate④ の処理
- 対象窓: SES-616（③0.5の魔女 / ②TSG / ①note の 3track）＋ SES-617（Mercari）
- 結果区分: **全クリア（誤検知訂正）** — 復旧作業は不要

## 結論（3行）
- `%TEMP%\orb616-untracked-backup\` の2ファイルは **origin/main とバイト完全一致**（5957B / 4066B）。未push編集なし・データ損失なし。
- SES-620 gate④の「DIVERGED＝未push編集の可能性」は **誤検知**。git の "untracked would be overwritten by merge" は*コンフリクト*であって*内容相違*ではない。
- → **backup は削除して安全**。突合（recover）作業は不要。残るのは根因の掃除だけ。

## 検証（このrehemで実走）
backup実体（host `%TEMP%\orb616-untracked-backup\`、LastWrite 12:04 / 12:06 JST）:

| ファイル | bytes | origin/main |
|---|---|---|
| `2026-06-20-cow-ses616-hems-3track-blockers.md` | 5957 | byte一致・diff=0 |
| `2026-06-20-cow-ses616-mercari-auction-optimize.md` | 4066 | byte一致・diff=0 |

- origin/main の同名handoff を GitHub API raw 取得（HTTP200・5957/4066 bytes）→ CR正規化の前後とも **内容diff=0**。サイズも完全一致＝行末含めバイト同一。
- 既知commit照合: 3track=`c52da40b` / Mercari=`c385691c`（MEMORY.md台帳と一致）。

## なぜ起きたか（根因・まだ生きてる）
- cs運用＝**API直PUTで origin へ push**。このときローカル作業コピーには同名ファイルが **未追跡(untracked) で残る**。
- orb-sync の pull が毎回この未追跡dupeに躓き（"untracked would be overwritten"）→ 非破壊で `%TEMP%` へ退避して pull、を **繰り返している**。
- backup の LastWrite(12:04/12:06) が SES-620 hem(08:34) より後＝**退避ループが継続中**の証拠。内容同一なので無害だが、毎回 temp を上書きするノイズ。

## 推奨アクション
1. **backup削除でOK**（中身=origin と同一の冗長コピー）:
   ```powershell
   Remove-Item -Recurse -Force "$env:TEMP\orb616-untracked-backup"
   ```
2. **根因を断つ（推奨）** — ローカルcsクローンの未追跡dupe 2件を掃除すれば、次回pullはtracked版で素通りし退避ループが止まる:
   ```powershell
   git -C <cs-clone> status --porcelain | Select-String 'ses616'   # 2件確認
   # 該当の未追跡ファイルを削除（または git clean -i で対話的に）
   ```
   ※cloneパス未確定。OrbSync スケジュールタスクの作業dir を使うこと。
3. 原本データは **%TEMP% backup と origin の両方に健在**（二重保全）。削除しても origin に正本が残るので復旧不能リスクなし。

## SES-620 gate④ への訂正
gate④「`%TEMP%\orb616-untracked-backup\` のローカル残骸が origin版とDIVERGED。未push編集があったか突合を」
→ **実測で内容バイト一致。突合不要・データは元から無傷**。残作業は「削除＋未追跡掃除」のみ（データ復旧ではない）。

---
*検証元: GH API raw（osakenpiro/claude-shared@main）＋ host `%TEMP%` 実ファイル。byte/内容ともに照合済み。*
