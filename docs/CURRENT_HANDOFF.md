# 项目交接文档

> 本文档由 AI 编码助手（Qoder/Codex）在每次任务结束时更新，用于跨对话上下文同步。

---

## 最新更新：2026-09-17 发布 0.7.0

### 最近完成
- 使用 Xcode 27 / macOS 27 SDK 重新构建，恢复 macOS 27 的 OCR 兼容性
- 构建缓存按 SDK 版本隔离，并移到系统临时目录
- DMG 使用无扩展属性暂存区，打包前执行严格签名校验

### 当前状态
- 版本 `0.7.0`
- 公开 DMG 已验证，不包含第三方截图应用

### 下一步
- 用户重新授予屏幕录制权限后，实测框选 OCR 与框选翻译

### 阻塞/待确认
- 实际框选流程仍需用户授予 macOS 屏幕录制权限后确认

### 不可破坏的决定
- 公开发行包不得捆绑 Snipaste 或其他第三方应用
- 保持原生 Swift/AppKit/SwiftUI 菜单栏工具定位

### 涉及文件
- `VERSION`
- `Sources/FreeScanOCR/main.swift`
- `script/build_and_run.sh`
- `script/package_dmg.sh`
- `CHANGELOG.md`
- `RELEASE_NOTES.md`
- `docs/PROJECT_CONTEXT.md`

### 生产环境变更
- 无；本次仅本地构建与公开发行包

---

<!-- 以下为历史交接记录，最新的在最上面 -->
