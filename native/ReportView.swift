import SwiftUI

// 画面録 配色（colors_and_type.css 準拠：void + gold 単一暖色、状態異常のみ warn）
private let osVoid = Color(red: 0.04, green: 0.04, blue: 0.06)
private let osGold = Color(red: 0.831, green: 0.659, blue: 0.325)
private let osWarn = Color(red: 0.851, green: 0.482, blue: 0.424)
private let osInk2 = Color(red: 0.722, green: 0.690, blue: 0.627)

// ── ステータス画面（拡張内で描画する実体） ──
struct RPGReportView: View {
    let model: RPGModel
    var body: some View {
        ZStack {
            osVoid.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text("調和  HARMONY").font(.caption).tracking(3).foregroundColor(osInk2)
                    Text(model.total > 0 ? String(format: "%.2f", model.harmony) : "—")
                        .font(.system(size: 54, weight: .bold, design: .monospaced))
                        .foregroundColor(osGold)
                    if model.isClear {
                        Text("✦ バランス・クリア").font(.caption).foregroundColor(osGold)
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .overlay(Capsule().stroke(osGold.opacity(0.6)))
                    }
                    if !model.title.isEmpty {
                        VStack(spacing: 2) {
                            Text("称号 TITLE").font(.system(size: 9)).tracking(3).foregroundColor(.gray)
                            Text(model.title).font(.title2).italic().foregroundColor(.white)
                        }
                    }

                    HexRadarView(model: model).frame(height: 260).padding(.vertical, 4)
                    BarsView(model: model)

                    if model.total > 0 {
                        Text("今週の鍛錬量 Lv \(model.level)　・　多ければいいわけじゃない")
                            .font(.caption2).foregroundColor(osInk2)
                    }
                    ForEach(model.ailments) { a in
                        Text("\(a.kind)「\(a.name)」　強度 \(String(format: "%.2f", a.intensity))")
                            .font(.caption).foregroundColor(osWarn)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(osWarn.opacity(0.5)))
                    }
                }
                .padding()
            }
        }
    }
}

// ── 六角レーダー（正六角形に近いほどバランス良） ──
struct HexRadarView: View {
    let model: RPGModel
    var body: some View {
        GeometryReader { geo in
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let R = min(geo.size.width, geo.size.height) / 2 - 26
            let axes = Axis.ring
            let maxv = max(axes.map { model.xp[$0] ?? 0 }.max() ?? 1, 1)
            func pt(_ i: Int, _ r: CGFloat) -> CGPoint {
                let a = (-90.0 + 60.0 * Double(i)) * .pi / 180
                return CGPoint(x: c.x + r * CGFloat(cos(a)), y: c.y + r * CGFloat(sin(a)))
            }
            ZStack {
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { g in
                    Path { p in
                        for i in 0..<axes.count {
                            let q = pt(i, R * CGFloat(g)); i == 0 ? p.move(to: q) : p.addLine(to: q)
                        }; p.closeSubpath()
                    }.stroke(Color.white.opacity(0.10), lineWidth: 1)
                }
                let dataPath = Path { p in
                    for i in 0..<axes.count {
                        let r = R * CGFloat((model.xp[axes[i]] ?? 0) / maxv)
                        let q = pt(i, r); i == 0 ? p.move(to: q) : p.addLine(to: q)
                    }; p.closeSubpath()
                }
                dataPath.fill(osGold.opacity(0.16))
                dataPath.stroke(osGold, lineWidth: 2)
                ForEach(0..<axes.count, id: \.self) { i in
                    Text(axes[i].jp).font(.caption2).foregroundColor(osInk2).position(pt(i, R + 16))
                }
            }
        }
    }
}

// ── 系統別バー（miharashi グラマー流用） ──
struct BarsView: View {
    let model: RPGModel
    var body: some View {
        let maxv = max(Axis.allCases.map { model.xp[$0] ?? 0 }.max() ?? 1, 1)
        VStack(spacing: 6) {
            ForEach(Axis.ring, id: \.self) { ax in
                HStack(spacing: 8) {
                    Text("\(ax.rawValue) \(ax.jp)").font(.caption2).foregroundColor(osInk2)
                        .frame(width: 76, alignment: .leading)
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.06))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(model.afflicted.contains(ax) ? osWarn : osGold)
                                .frame(width: g.size.width * CGFloat((model.xp[ax] ?? 0) / maxv))
                        }
                    }.frame(height: 8)
                    Text("\(Int(model.xp[ax] ?? 0))").font(.caption2.monospaced())
                        .foregroundColor(osGold).frame(width: 50, alignment: .trailing)
                }
            }
        }
    }
}
