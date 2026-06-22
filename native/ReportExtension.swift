import DeviceActivity
import SwiftUI

// ── DeviceActivityReport 拡張ターゲットの @main ──
// ★最重要：ここで「集計 → 6系統XP算出 → SwiftUI描画」まで完結させる。
//   このサンドボックスから集計値を本体アプリ/サーバへ渡すことはできない
//   （App Group / 共有UserDefaults / 共有ファイル いずれも不可）。
//   だから「ステータス画面」そのものを拡張の View として作り、本体は埋め込むだけにする。

extension DeviceActivityReport.Context {
    static let rpg = Self("RPG Status")
}

@main
struct ScreenTimeRPGReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        RPGScene()
    }
}

struct RPGScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .rpg
    let content: (RPGModel) -> RPGReportView = { model in RPGReportView(model: model) }

    // data は async sequence。category 単位で週合計 duration を集計し、分に直して RPGModel へ。
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> RPGModel {
        var minutesByCategory: [String: Double] = [:]
        for await datum in data {
            for await segment in datum.activitySegments {
                for await category in segment.categories {
                    let name = category.category.localizedDisplayName ?? "Other"
                    let seconds = category.totalActivityDuration   // TimeInterval
                    minutesByCategory[name, default: 0] += seconds / 60.0
                }
            }
        }
        return RPGModel.build(minutesByCategory: minutesByCategory)
    }
}
