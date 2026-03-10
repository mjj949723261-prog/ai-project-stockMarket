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
            fundamentalsReasons: ["盈利能力稳定", "现金流质量较好", "估值处于历史中高位但未失控"],
            newsReasons: ["近期公告整体中性偏多", "无明显突发利空"],
            technicalsReasons: ["趋势仍在上行通道", "量能没有明显失真"],
            sentimentReasons: ["市场关注度回升", "讨论热度未见过热"]
        ),
        Stock(
            code: "300308",
            name: "中际旭创",
            totalScore: 80,
            fundamentalsScore: 27,
            newsScore: 22,
            technicalsScore: 18,
            sentimentScore: 13,
            verdict: "龙头属性明确，资讯催化与情绪强度共振。",
            riskWarning: "高弹性品种波动大，分歧时回撤也更快。",
            scoreTrend: .up,
            fundamentalsReasons: ["订单预期支撑较强", "行业景气维持高位"],
            newsReasons: ["算力链催化不断", "板块关注度居高"],
            technicalsReasons: ["趋势延续", "资金抱团明显"],
            sentimentReasons: ["情绪活跃", "热度保持高位"]
        ),
        Stock(
            code: "300394",
            name: "天孚通信",
            totalScore: 77,
            fundamentalsScore: 26,
            newsScore: 20,
            technicalsScore: 18,
            sentimentScore: 13,
            verdict: "高弹性特征明显，更适合顺势跟踪。",
            riskWarning: "估值和情绪对波动放大较敏感。",
            scoreTrend: .up,
            fundamentalsReasons: ["盈利能力修复", "景气链条稳定"],
            newsReasons: ["板块催化正向", "市场关注度较高"],
            technicalsReasons: ["趋势改善", "成交活跃"],
            sentimentReasons: ["热度偏高", "弹性较强"]
        ),
        Stock(
            code: "603019",
            name: "中科曙光",
            totalScore: 75,
            fundamentalsScore: 25,
            newsScore: 19,
            technicalsScore: 18,
            sentimentScore: 13,
            verdict: "核心设备属性强化，适合放在方向页继续观察。",
            riskWarning: "节奏偏事件驱动，持续性需要验证。",
            scoreTrend: .flat,
            fundamentalsReasons: ["设备端逻辑扎实", "业绩韧性尚可"],
            newsReasons: ["算力方向受关注", "政策预期仍在"],
            technicalsReasons: ["短期结构中性偏强", "量价尚可"],
            sentimentReasons: ["资金关注稳定", "热度处于高位"]
        ),
        Stock(
            code: "002475",
            name: "立讯精密",
            totalScore: 79,
            fundamentalsScore: 30,
            newsScore: 18,
            technicalsScore: 17,
            sentimentScore: 14,
            verdict: "龙头地位稳，消费电子景气修复逻辑清晰。",
            riskWarning: "若外需扰动放大，板块修复会受影响。",
            scoreTrend: .up,
            fundamentalsReasons: ["龙头地位稳定", "盈利韧性较强"],
            newsReasons: ["新品周期催化", "出口修复改善预期"],
            technicalsReasons: ["趋势逐步修复", "量价结构平稳"],
            sentimentReasons: ["关注度升温", "情绪偏正面"]
        ),
        Stock(
            code: "300433",
            name: "蓝思科技",
            totalScore: 74,
            fundamentalsScore: 27,
            newsScore: 18,
            technicalsScore: 16,
            sentimentScore: 13,
            verdict: "景气修复受益，但更适合顺势观察。",
            riskWarning: "板块分歧扩大时弹性标的回撤更快。",
            scoreTrend: .flat,
            fundamentalsReasons: ["修复逻辑在兑现", "成本端改善"],
            newsReasons: ["消费电子方向回暖", "新品催化预期仍在"],
            technicalsReasons: ["趋势中性", "修复确认中"],
            sentimentReasons: ["关注度回升", "情绪温和"]
        ),
        Stock(
            code: "601138",
            name: "工业富联",
            totalScore: 78,
            fundamentalsScore: 28,
            newsScore: 20,
            technicalsScore: 17,
            sentimentScore: 13,
            verdict: "资金关注稳定，适合放在核心观察名单。",
            riskWarning: "消息面走弱时板块扩散会同步减速。",
            scoreTrend: .up,
            fundamentalsReasons: ["制造龙头属性稳", "盈利预期平稳"],
            newsReasons: ["算力与消费电子双主题受益", "资金偏好较高"],
            technicalsReasons: ["结构平稳偏强", "趋势改善"],
            sentimentReasons: ["关注度维持高位", "情绪理性偏多"]
        ),
        Stock(
            code: "000002",
            name: "万科A",
            totalScore: 68,
            fundamentalsScore: 22,
            newsScore: 18,
            technicalsScore: 14,
            sentimentScore: 14,
            verdict: "板块修复交易中仍是高辨识度标的。",
            riskWarning: "基本面不确定性仍高，适合谨慎跟踪。",
            scoreTrend: .flat,
            fundamentalsReasons: ["行业地位仍在", "修复弹性存在"],
            newsReasons: ["政策博弈加强", "地产链情绪改善"],
            technicalsReasons: ["结构修复中", "趋势确认一般"],
            sentimentReasons: ["关注度高", "分歧较大"]
        ),
        Stock(
            code: "001979",
            name: "招商蛇口",
            totalScore: 70,
            fundamentalsScore: 24,
            newsScore: 18,
            technicalsScore: 14,
            sentimentScore: 14,
            verdict: "稳健属性更强，适合在板块内做中性观察。",
            riskWarning: "修复行情中弹性不如高波动品种。",
            scoreTrend: .flat,
            fundamentalsReasons: ["稳健属性较强", "央企背景稳定"],
            newsReasons: ["政策信号偏修复", "板块催化仍在"],
            technicalsReasons: ["走势中性", "趋势等待确认"],
            sentimentReasons: ["板块热度带动", "关注度回升"]
        ),
        Stock(
            code: "600048",
            name: "保利发展",
            totalScore: 71,
            fundamentalsScore: 24,
            newsScore: 19,
            technicalsScore: 14,
            sentimentScore: 14,
            verdict: "核心央企属性使其在板块里更具稳健辨识度。",
            riskWarning: "地产链整体分化仍会压制持续性。",
            scoreTrend: .flat,
            fundamentalsReasons: ["央企属性提供稳定性", "区域布局较广"],
            newsReasons: ["板块修复受益", "政策预期提供支撑"],
            technicalsReasons: ["修复节奏一般", "趋势确认待补强"],
            sentimentReasons: ["关注度仍高", "情绪偏观察"]
        )
    ]

    static let sectors: [HotSector] = [
        HotSector(
            id: "ai-compute",
            name: "算力",
            aliases: ["算力服务", "人工智能算力", "服务器", "通信设备", "计算机设备", "软件开发"],
            heat: .high,
            status: "政策和订单预期共同抬升，龙头带动明显。",
            summary: "当前更适合从龙头和高弹性标的里筛选，而不是盲目追整个板块。",
            highlights: ["龙头带动", "高弹性", "订单预期"],
            stocks: [
                SectorStock(code: "300308", name: "中际旭创", tag: "龙头"),
                SectorStock(code: "300394", name: "天孚通信", tag: "高弹性"),
                SectorStock(code: "603019", name: "中科曙光", tag: "核心设备")
            ]
        ),
        HotSector(
            id: "consumer-electronics",
            name: "消费电子",
            aliases: ["电子消费", "智能终端"],
            heat: .warming,
            status: "新品周期与出口修复共振，情绪正在升温。",
            summary: "更适合沿着龙头和景气修复链找机会，阶段上不宜只看题材热度。",
            highlights: ["景气修复", "新品周期", "出口改善"],
            stocks: [
                SectorStock(code: "002475", name: "立讯精密", tag: "龙头"),
                SectorStock(code: "300433", name: "蓝思科技", tag: "景气修复"),
                SectorStock(code: "601138", name: "工业富联", tag: "资金关注")
            ]
        ),
        HotSector(
            id: "real-estate",
            name: "房地产",
            aliases: ["房地产开发", "地产开发", "房地产服务", "银行Ⅱ"],
            heat: .diverging,
            status: "政策预期与销售恢复并存，板块修复与分化同时出现。",
            summary: "更适合从财务稳健和区域优势明显的标的里筛选，不宜把板块反弹等同于全面反转。",
            highlights: ["政策博弈", "区域分化", "修复交易"],
            stocks: [
                SectorStock(code: "000002", name: "万科A", tag: "龙头"),
                SectorStock(code: "001979", name: "招商蛇口", tag: "稳健"),
                SectorStock(code: "600048", name: "保利发展", tag: "核心央企")
            ]
        )
    ]

    static let news: [NewsEntry] = [
        NewsEntry(
            id: "reuters-20260310-ai-demand",
            title: "AI 服务器需求继续抬升",
            summary: "北美算力资本开支预期上修，通信设备和计算机设备链条持续受益。",
            source: "Reuters",
            sourceURL: "https://www.reuters.com",
            publishedAt: "2026-03-10 09:30",
            region: .global,
            impact: .positive,
            urgency: .high,
            sectors: ["通信设备", "计算机设备", "软件开发"],
            scoreEffect: "消息面 +2，情绪面 +1",
            stockCode: nil,
            stockName: nil
        ),
        NewsEntry(
            id: "bloomberg-20260310-consumer-cycle",
            title: "消费电子进入新品催化窗口",
            summary: "供应链反馈终端拉货边际改善，消费电子板块关注度明显升温。",
            source: "Bloomberg",
            sourceURL: "https://www.bloomberg.com",
            publishedAt: "2026-03-10 10:10",
            region: .global,
            impact: .positive,
            urgency: .medium,
            sectors: ["消费电子"],
            scoreEffect: "消息面 +1",
            stockCode: nil,
            stockName: nil
        ),
        NewsEntry(
            id: "domestic-20260310-property-policy",
            title: "房地产开发政策预期再升温",
            summary: "地产链修复交易强化，房地产开发与银行Ⅱ方向出现联动。",
            source: "东方财富",
            sourceURL: "https://www.eastmoney.com",
            publishedAt: "2026-03-10 11:20",
            region: .domestic,
            impact: .neutral,
            urgency: .medium,
            sectors: ["房地产开发", "银行Ⅱ"],
            scoreEffect: "消息面 +1，情绪面 +1",
            stockCode: nil,
            stockName: nil
        ),
        NewsEntry(
            id: "domestic-20260310-medical-service",
            title: "医疗服务与医疗器械板块分化加大",
            summary: "医疗服务、医疗器械和化学制药方向受政策节奏影响，市场更偏向结构化选择。",
            source: "财联社",
            sourceURL: "https://www.cls.cn",
            publishedAt: "2026-03-10 13:00",
            region: .domestic,
            impact: .neutral,
            urgency: .low,
            sectors: ["医疗服务", "医疗器械", "化学制药"],
            scoreEffect: "暂不计分",
            stockCode: nil,
            stockName: nil
        )
    ]
}
