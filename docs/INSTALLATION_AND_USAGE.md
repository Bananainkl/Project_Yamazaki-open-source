# Yamazaki 安装与使用说明

## DMG 内容

- `Yamazaki.app`：本地 OCR 与截图翻译菜单栏工具。
- `Applications`：macOS 应用程序文件夹快捷方式。

Yamazaki 不再内置截图编辑功能，也不会在公开发行包中捆绑第三方截图工具。

## 安装

1. 打开 DMG。
2. 将 `Yamazaki.app` 拖入 `Applications`。
3. 从 `/Applications/Yamazaki.app` 打开 Yamazaki。
4. 首次使用框选识别或截图翻译时，按系统提示授予 Yamazaki 屏幕录制权限。

Yamazaki 是菜单栏工具，默认不常驻 Dock。打开后请从屏幕右上角菜单栏图标进入设置或开始识别。

## 基本使用

- 框选文字识别：默认快捷键 `Command + E`，框选屏幕区域后，识别文字会复制到剪贴板。
- 框选截图翻译：默认快捷键 `Command + Shift + E`，框选屏幕区域后按设置中的目标语言翻译。
- 识别剪贴板图片：从 Yamazaki 菜单栏菜单选择 `识别剪贴板图片`。
- 设置快捷键：从菜单栏打开 Yamazaki 设置，在 `快捷键` 中重新录制快捷键。
- 开机自动启动：从 `通用` 设置中打开 `开机自动启动`。
- 异常退出自动重启：从 `通用` 设置中打开 `退出后自动重启`。

## 截图与标注

Yamazaki 已移除自带截图编辑功能。如需截图、贴图或标注，可自行从 [Snipaste 官网](https://www.snipaste.com/) 安装 Snipaste，或选择其他工具。第三方工具不属于 Yamazaki，也不随本项目分发。

Snipaste 首次使用截图时，也可能需要屏幕录制权限。请在：

`系统设置 > 隐私与安全性 > 屏幕录制 / 屏幕与系统音频录制`

中为 `Snipaste` 打开权限。

## 反复弹出权限窗口的处理

如果已经给过权限，但 Yamazaki 每次识别仍然提示授权，通常是 macOS 记录了旧版本、旧路径或旧签名的权限。处理步骤：

1. 完全退出 Yamazaki。
2. 打开 `终端`，执行：

```bash
tccutil reset ScreenCapture com.itou.yamazaki
```

3. 重新打开 `/Applications/Yamazaki.app`。
4. 再次触发框选识别，并在系统设置中重新允许 Yamazaki 的屏幕录制权限。

## 权限说明

macOS 有时会把提示写成“录制此电脑的屏幕和音频”。Yamazaki 只使用该权限读取你框选的屏幕区域，不录音，也不会后台录屏。

## 建议

- 固定使用 `/Applications/Yamazaki.app`，不要反复打开 DMG 或 `dist-native` 中的开发版本。
- 每次升级后，如果系统再次询问屏幕录制权限，按提示重新授权即可。
- 如果出现权限状态异常，再使用上面的 `tccutil reset ScreenCapture com.itou.yamazaki` 重置。
