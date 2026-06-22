import Foundation

// 画面録 — 6系統マッピング & 算出ロジック（Web版 compute() の Swift 移植）
// ★ このファイルは「Report拡張ターゲット」に含める（計算も描画も拡張内で完結させるため）。
//   集計値は拡張外へ出せないので、本体アプリ側にこのロジックを置いても意味がない。

enum Axis: String, CaseIterable {
    case phi = "PHI", cre = "CRE", out = "OUT", vit = "VIT", exp = "EXP", tec = "TEC"
    var jp: String {
        switch self {
        case .phi: return "哲学"; case .cre: return "創作"; case .out: return "発信"
        case .vit: return "体力"; case .exp: return "探究"; case .tec: return "技術"
        }
    }
    /// 六角形の並び（上から時計回り）
    static let ring: [Axis] = [.phi, .cre, .out, .vit, .exp, .tec]
}

struct Ailment: Identifiable {
    let id = UUID()
    let name: String       // 例: 無限スクロールの呪縛
    let kind: String       // 呪い / 状態異常 / 偏り
    let axis: Axis?
    let intensity: Double  // 0...1
    let skew: Bool         // 偏り（攻略=クリア判定では無視）
}

struct CatRule {
    let weights: [Axis: Double]
    let thresholdH: Double?            // 過剰閾値（時間/週）
    let ailment: (name: String, kind: String)?
}

// Apple の `category.localizedDisplayName`（英語/日本語ロケール）を正規化してマッチ。
// ※トークンからアプリ名は読めないが、カテゴリの表示名は取得できる。
enum CategoryMap {
    static func rule(for displayName: String) -> CatRule {
        let n = displayName.lowercased()
        func has(_ ks: [String]) -> Bool { ks.contains { n.contains($0) } }
        if has(["social", "ソーシャル"]) {
            return CatRule(weights: [.out: 0.8, .phi: 0.1, .exp: 0.1], thresholdH: 7,  ailment: ("無限スクロールの呪縛", "呪い"))
        } else if has(["entertain", "エンタ"]) {
            return CatRule(weights: [.vit: 0.5, .exp: 0.3, .phi: 0.2], thresholdH: 12, ailment: ("惰性のとろみ", "状態異常"))
        } else if has(["game", "ゲーム"]) {
            return CatRule(weights: [.exp: 0.6, .cre: 0.3, .vit: 0.1], thresholdH: 12, ailment: ("没入のとりつかれ", "状態異常"))
        } else if has(["creativ", "創作", "クリエ"]) {
            return CatRule(weights: [.cre: 1.0], thresholdH: nil, ailment: nil)
        } else if has(["developer", "develop", "開発"]) {
            return CatRule(weights: [.tec: 1.0], thresholdH: nil, ailment: nil)
        } else if has(["productiv", "finance", "business", "仕事", "金融"]) {
            return CatRule(weights: [.tec: 0.6, .out: 0.4], thresholdH: nil, ailment: nil)
        } else if has(["information", "reading", "news", "reference", "情報", "読書", "ニュース"]) {
            return CatRule(weights: [.phi: 0.7, .exp: 0.3], thresholdH: nil, ailment: nil)
        } else if has(["education", "教育"]) {
            return CatRule(weights: [.exp: 0.8, .phi: 0.2], thresholdH: nil, ailment: nil)
        } else if has(["health", "fitness", "健康", "フィットネス"]) {
            return CatRule(weights: [.vit: 1.0], thresholdH: nil, ailment: nil)
        } else if has(["travel", "navigation", "旅行", "ナビ"]) {
            return CatRule(weights: [.exp: 0.7, .vit: 0.3], thresholdH: nil, ailment: nil)
        } else if has(["shopping", "food", "買い物", "食"]) {
            return CatRule(weights: [.vit: 0.2], thresholdH: 6, ailment: ("浪費のうずき", "状態異常"))
        }
        return CatRule(weights: [:], thresholdH: nil, ailment: nil) // 中立（その他・ユーティリティ）
    }
}

struct RPGModel {
    var xp: [Axis: Double] = [:]
    var total: Double = 0
    var harmony: Double = 0          // 主役 Float 0...1（正規化シャノンエントロピー）
    var level: Int = 0               // ⌊総XP/847⌋（副次）
    var afflicted: Set<Axis> = []
    var ailments: [Ailment] = []
    var title: String = ""

    /// カテゴリ表示名→週合計「分」の辞書から組み立てる（1分=1XP）
    static func build(minutesByCategory: [String: Double]) -> RPGModel {
        var m = RPGModel()
        var xp: [Axis: Double] = [:]; Axis.allCases.forEach { xp[$0] = 0 }
        var totalHours = 0.0
        var ail: [Ailment] = []
        var afflicted: [Axis: Double] = [:]

        for (name, minutes) in minutesByCategory {
            let h = minutes / 60.0
            totalHours += h
            let rule = CategoryMap.rule(for: name)
            for (ax, w) in rule.weights { xp[ax, default: 0] += minutes * w }
            if let thr = rule.thresholdH, let a = rule.ailment, h > thr {
                let inten = min(1, (h - thr) / thr)
                let primary = rule.weights.max { $0.value < $1.value }?.key
                if let p = primary { afflicted[p] = max(afflicted[p] ?? 0, inten) }
                ail.append(Ailment(name: a.name, kind: a.kind, axis: primary, intensity: inten, skew: false))
            }
        }

        let total = Axis.allCases.reduce(0) { $0 + (xp[$1] ?? 0) }
        // 調和 = 正規化シャノンエントロピー H/ln6
        var hs = 0.0
        if total > 0 {
            for ax in Axis.allCases { let p = (xp[ax] ?? 0) / total; if p > 0 { hs -= p * log(p) } }
        }
        let harmony = total > 0 ? hs / log(Double(Axis.allCases.count)) : 0

        if totalHours > 56 {
            ail.append(Ailment(name: "過暴露（オーバーエクスポージャー）", kind: "状態異常", axis: nil,
                               intensity: min(1, (totalHours - 56) / 56), skew: false))
        }
        if total > 0 {
            let top = Axis.allCases.max { (xp[$0] ?? 0) < (xp[$1] ?? 0) }!
            let share = (xp[top] ?? 0) / total
            if share > 0.55 {
                ail.append(Ailment(name: "\(top.jp)への偏り", kind: "偏り", axis: top,
                                   intensity: min(1, (share - 0.55) / 0.45), skew: true))
            }
        }

        m.xp = xp; m.total = total; m.harmony = harmony
        m.level = Int(total / 847)
        m.afflicted = Set(afflicted.keys)
        m.ailments = ail
        m.title = RPGModel.title(xp: xp, total: total, harmony: harmony, ailments: ail)
        return m
    }

    /// クリア判定：調和 ≥ 0.75 かつ 状態異常（skew除く）なし
    var isClear: Bool { total > 0 && harmony >= 0.75 && ailments.allSatisfy { $0.skew } }

    static func title(xp: [Axis: Double], total: Double, harmony: Double, ailments: [Ailment]) -> String {
        if total <= 0 { return "" }
        let roles: [Axis: String] = [.phi: "思索者", .cre: "創り手", .tec: "鍛冶師", .out: "発信者", .vit: "養生家", .exp: "探究者"]
        let top = Axis.allCases.max { (xp[$0] ?? 0) < (xp[$1] ?? 0) }!
        let role = roles[top] ?? "者"
        let real = ailments.filter { !$0.skew }
        if harmony >= 0.75 && real.isEmpty { return "均衡の賢者" }
        if let worst = real.max(by: { $0.intensity < $1.intensity }), worst.intensity >= 0.5 { return "呪われし\(role)" }
        if harmony >= 0.6 { return "\(top.jp)寄りの均衡者" }
        if harmony >= 0.4 { return "\(top.jp)の\(role)" }
        return "\(top.jp)の鬼"
    }
}
