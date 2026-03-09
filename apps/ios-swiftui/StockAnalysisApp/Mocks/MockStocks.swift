import Foundation

enum MockStocks {
    static let all: [Stock] = [
        Stock(
            code: "600519",
            name: "贵州茅台",
            totalScore: 82,
            fundamentalsScore: 31,
            newsScore: 20,
            technicalsScore: 18,
            sentimentScore: 13,
            verdict: "基本面稳健，近期情绪温和走强，适合继续跟踪。",
            riskWarning: "短期累计涨幅不低，追高风险偏大。",
            scoreTrend: .up,
            fundamentalsReasons: ["盈利能力稳定", "现金流质量较好"],
            newsReasons: ["近期公告整体中性偏多", "无明显突发利空"],
            technicalsReasons: ["趋势仍在上行通道", "量能没有明显失真"],
            sentimentReasons: ["市场关注度回升", "讨论热度未见过热"]
        ),
        Stock(
            code: "300750",
            name: "宁德时代",
            totalScore: 76,
            fundamentalsScore: 28,
            newsScore: 18,
            technicalsScore: 17,
            sentimentScore: 13,
            verdict: "行业地位稳固，消息面偏稳，适合继续观察节奏。",
            riskWarning: "赛道情绪波动较大，阶段性回撤风险仍在。",
            scoreTrend: .flat,
            fundamentalsReasons: ["龙头地位稳定", "盈利能力保持韧性"],
            newsReasons: ["行业信息偏中性"],
            technicalsReasons: ["价格结构中性"],
            sentimentReasons: ["热度保持中位"]
        )
    ]
}

