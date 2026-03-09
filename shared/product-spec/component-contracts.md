# 组件职责说明

三端统一的组件职责如下：

## SearchBar

负责输入股票代码或名称，并把查询词上抛给页面层。

## StockListItem

负责列表项展示，只展示摘要信息，不做复杂业务判断。

## ScoreSummaryCard

负责展示总分、一句话判断和风险提示。

## DimensionScoreCard

负责展示某个维度的分数、趋势和核心原因。

## ReasonList

负责展示详细依据列表。

## TrendBadge

负责展示分数趋势，不负责计算趋势。

