# SwiftUI 版本说明

该目录目前提供 `SwiftUI` 可构建最小工程，包含：

- 首页
- 个股详情页
- 自选页
- 统一模型
- 本地 mock 仓储
- `StockAnalysisApp.xcodeproj`

已验证：

- `swiftc -typecheck` 通过
- `xcodebuild -project StockAnalysisApp.xcodeproj -scheme StockAnalysisApp -destination 'generic/platform=iOS Simulator' ... build` 通过
