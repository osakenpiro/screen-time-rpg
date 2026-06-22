import SwiftUI
import FamilyControls
import DeviceActivity

// ── 本体アプリ（メインターゲット） ──
// 役割：FamilyControls の認可を取り、ステータス画面（＝Report拡張の View）を埋め込むだけ。
// 生の集計数値は本体に来ない。表示は DeviceActivityReport が拡張へ橋渡しする。

@main
struct GamenrokuApp: App {
    var body: some Scene { WindowGroup { ContentView() } }
}

struct ContentView: View {
    @State private var status = AuthorizationCenter.shared.authorizationStatus

    private var filter: DeviceActivityFilter {
        let now = Date()
        let week = Calendar.current.dateInterval(of: .weekOfYear, for: now)
            ?? DateInterval(start: now.addingTimeInterval(-7 * 86_400), end: now)
        return DeviceActivityFilter(
            segment: .weekly(during: week),
            users: .all,
            devices: .init([.iPhone])
        )
    }

    var body: some View {
        Group {
            if status == .approved {
                // ★ ステータス画面の実体は Report拡張の View。本体は context を指定して埋め込むだけ。
                DeviceActivityReport(.rpg, filter: filter)
            } else {
                VStack(spacing: 16) {
                    Text("画面録").font(.largeTitle).italic()
                    Text("スクリーンタイムを許可すると、今週のステータスが立ち上がる。\nデータは端末の中だけ。どこにも送られない。")
                        .font(.callout).multilineTextAlignment(.center).foregroundColor(.secondary)
                    Button("スクリーンタイムを許可") {
                        Task {
                            try? await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                            status = AuthorizationCenter.shared.authorizationStatus
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}
