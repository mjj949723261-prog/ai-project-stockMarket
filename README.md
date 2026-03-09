# 股市资讯 App

一个面向 A 股的单股票综合评分助手，多端实现包括：

- `Vue3 H5`
- `SwiftUI`
- `Flutter`

## 目录

- `shared/product-spec`: 三端统一产品协议
- `apps/web-vue3`: H5 版本
- `apps/ios-swiftui`: iOS SwiftUI 版本源码骨架
- `apps/flutter-app`: Flutter 版本源码骨架

## 当前状态

- `Vue3 H5`：已具备可安装依赖并构建的本地 mock MVP
- `SwiftUI`：已完成组件化源码骨架
- `Flutter`：已完成组件化源码骨架

## 本地运行

- H5：`npm --prefix apps/web-vue3 install` 后执行 `npm --prefix apps/web-vue3 run dev`
- H5 构建：`npm --prefix apps/web-vue3 run build`
- iOS：用 Xcode 打开 `apps/ios-swiftui` 后继续补完整工程文件
- Flutter：本机安装 Flutter SDK 后进入 `apps/flutter-app` 继续运行

