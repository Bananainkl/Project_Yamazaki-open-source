import AppKit
import Carbon.HIToolbox
import Combine
import CoreGraphics
import SwiftUI
import Translation
import _Translation_SwiftUI
import UniformTypeIdentifiers
import Vision

enum ProductInfo {
  static let appName = "Yamazaki"
}

enum LocalizedKey: String {
  case waitingForShortcut
  case openSettings
  case captureWithShortcut
  case translateWithShortcut
  case captureEditor
  case recognizeClipboard
  case quitApp
  case shortcutEnabled
  case pressNewShortcut
  case invalidShortcut
  case recognitionLanguageSet
  case textDirectionSet
  case resultLayoutSet
  case appSettings
  case subtitle
  case general
  case hotKey
  case textDirection
  case resultLayout
  case statusModeOn
  case statusModeCaption
  case startAtLogin
  case startAtLoginCaption
  case startAtLoginEnabled
  case startAtLoginDisabled
  case autoRestart
  case autoRestartCaption
  case autoRestartEnabled
  case autoRestartDisabled
  case muteSuccessSound
  case ignoreWatermarkText
  case ignoreWatermarkCaption
  case uiLanguage
  case recognitionLanguage
  case languageNote
  case shortcutHintIdle
  case shortcutHintRecording
  case successCaption
  case setShortcut
  case captureSelection
  case translateSelection
  case translationLanguage
  case translationLanguageSet
  case horizontalScan
  case horizontalSubtitle
  case verticalScan
  case verticalSubtitle
  case smartLayout
  case smartSubtitle
  case lineLayout
  case lineSubtitle
  case resultFontSize
  case primaryWorkflow
  case ocrPrivacyCaption
  case advancedTools
  case advancedToolsCaption
  case languagePrivacy
  case translationPrivacyCaption
  case behavior
  case shortcutConflictHint
  case captureEditorCaption
  case captureEditorFeatureToolbar
  case captureEditorFeatureOutput
  case captureEditorFeatureAssist
  case startCaptureEditor
  case copyButton
  case translationRequiresMacOS15
  case copiedScreenshot
  case savedScreenshot
  case quickSavedScreenshot
  case style
  case color
  case lineWidth
  case opacity
  case undo
  case redo
  case copyCurrentColor
  case previousImage
  case nextImage
  case copyImage
  case save
  case saveAs
  case quickSave
  case close
  case addText
  case ok
  case cancel
  case colorPickHint
  case pointerTool
  case rectangleTool
  case ellipseTool
  case arrowTool
  case penTool
  case textTool
  case mosaicTool
  case blurTool
  case needPermissionStatus
  case permissionTitle
  case permissionMessage
  case noClipboardImage
  case recognizingText
  case noTextFound
  case copiedText
  case recognitionFailed
}

enum LocalizedText {
  static func tr(_ key: LocalizedKey, _ args: CVarArg...) -> String {
    let template = translations[languageCode]?[key.rawValue] ?? translations["en"]?[key.rawValue] ?? key.rawValue
    return args.isEmpty ? template : String(format: template, locale: Locale(identifier: languageCode), arguments: args)
  }

  private static var languageCode: String {
    switch AppPreferences.uiLanguage {
    case .system:
      let preferred = Locale.preferredLanguages.first ?? "en"
      if preferred.hasPrefix("zh-Hant") || preferred.hasPrefix("zh-HK") || preferred.hasPrefix("zh-TW") { return "zh-Hant" }
      if preferred.hasPrefix("zh") { return "zh-Hans" }
      return String(preferred.prefix(2))
    case .english: return "en"
    case .simplifiedChinese: return "zh-Hans"
    case .traditionalChinese: return "zh-Hant"
    case .japanese: return "ja"
    case .korean: return "ko"
    case .french: return "fr"
    case .portuguese: return "pt"
    case .spanish: return "es"
    case .german: return "de"
    case .thai: return "th"
    }
  }

  private static let translations: [String: [String: String]] = [
    "en": [
      "waitingForShortcut": "Waiting for shortcut",
      "openSettings": "Open Settings...",
      "captureWithShortcut": "%@ Capture Selection",
      "translateWithShortcut": "%@ Translate Selection",
      "captureEditor": "Screenshot Editor",
      "recognizeClipboard": "Recognize Clipboard Image",
      "quitApp": "Quit %@",
      "shortcutEnabled": "%@ enabled",
      "pressNewShortcut": "Press a new shortcut",
      "invalidShortcut": "This shortcut is unavailable or already used by the system, another app, or Yamazaki.",
      "recognitionLanguageSet": "Recognition language: %@",
      "textDirectionSet": "Text direction: %@",
      "resultLayoutSet": "Result layout: %@",
      "appSettings": "%@ Settings",
      "subtitle": "Menu bar OCR: press %@, select an area, and copy multilingual text to the clipboard.",
      "general": "General",
      "hotKey": "Hot Key",
      "textDirection": "Text Direction",
      "resultLayout": "Result Layout",
      "statusModeOn": "Menu bar mode is on",
      "statusModeCaption": "%@ stays out of the Dock. Open settings from the menu bar icon.",
      "startAtLogin": "Start at login",
      "startAtLoginCaption": "Open Yamazaki automatically after you sign in to macOS.",
      "startAtLoginEnabled": "Start at login enabled",
      "startAtLoginDisabled": "Start at login disabled",
      "autoRestart": "Auto restart if the app exits",
      "autoRestartCaption": "Keeps a user LaunchAgent active so the menu bar tool reopens after an unexpected exit.",
      "autoRestartEnabled": "Auto restart enabled",
      "autoRestartDisabled": "Auto restart disabled",
      "muteSuccessSound": "Mute success shutter",
      "ignoreWatermarkText": "Ignore watermark text",
      "ignoreWatermarkCaption": "Filters repeated, low-contrast, or unusually large background text before copying OCR results.",
      "uiLanguage": "Interface language",
      "recognitionLanguage": "Recognition language",
      "languageNote": "Recognizes common global languages. Clear handwriting may work, but printed text is most reliable.",
      "shortcutHintIdle": "Click Set Shortcut, then press a new combination",
      "shortcutHintRecording": "Press a new shortcut",
      "successCaption": "After recognition, a quiet shutter sound plays and text is copied to the clipboard.",
      "setShortcut": "Set Shortcut",
      "captureSelection": "Capture Selection",
      "translateSelection": "Translate Selection",
      "translationLanguage": "Screenshot translate to",
      "translationLanguageSet": "Screenshot translation target: %@",
      "horizontalScan": "Horizontal scan",
      "horizontalSubtitle": "For webpages, articles, tables, and mixed-language text.",
      "verticalScan": "Vertical scan",
      "verticalSubtitle": "For vertical Chinese, Japanese, and book images.",
      "smartLayout": "Smart layout",
      "smartSubtitle": "Merges natural paragraphs for articles and long sentences.",
      "lineLayout": "Line by line",
      "lineSubtitle": "Keeps OCR line breaks for tables, code, and short text.",
      "resultFontSize": "Result font size",
      "primaryWorkflow": "Primary workflow",
      "ocrPrivacyCaption": "OCR uses Apple Vision to read the selected image and write text to the clipboard. Translation services are only used when you choose screenshot translation.",
      "advancedTools": "Advanced tools",
      "advancedToolsCaption": "Screenshot editing is an advanced tool. Everyday OCR stays separate from annotation so the core workflow remains fast.",
      "languagePrivacy": "Language & Privacy",
      "translationPrivacyCaption": "Screenshot translation uses the macOS Translation framework. Available languages and offline behavior depend on system support.",
      "behavior": "Behavior",
      "shortcutConflictHint": "Yamazaki checks for duplicate shortcuts inside the app and tests whether macOS can register the combination. Command + Option or Command + Shift combinations are recommended.",
      "captureEditorCaption": "After selecting an area, Yamazaki opens a floating editor for annotation, color picking, copy, save, and quick save.",
      "captureEditorFeatureToolbar": "Floating toolbar: rectangle, ellipse, arrow, pen, text, mosaic, and blur",
      "captureEditorFeatureOutput": "Output: copy to clipboard, save PNG, or quick save to ~/Pictures/Yamazaki",
      "captureEditorFeatureAssist": "Assist: context menu, capture history, magnifier, HEX color pick, press C to copy color",
      "startCaptureEditor": "Start Screenshot Editor",
      "copyButton": "Copy",
      "translationRequiresMacOS15": "Translation requires macOS 15 or later",
      "copiedScreenshot": "Copied screenshot to clipboard",
      "savedScreenshot": "Saved screenshot",
      "quickSavedScreenshot": "Quick-saved screenshot",
      "style": "Style",
      "color": "Color",
      "lineWidth": "Line width",
      "opacity": "Opacity",
      "undo": "Undo",
      "redo": "Redo",
      "copyCurrentColor": "Copy current color",
      "previousImage": "Previous image",
      "nextImage": "Next image",
      "copyImage": "Copy image",
      "save": "Save",
      "saveAs": "Save As...",
      "quickSave": "Quick Save",
      "close": "Close",
      "addText": "Add Text",
      "ok": "OK",
      "cancel": "Cancel",
      "colorPickHint": "Pick color C",
      "pointerTool": "Pointer",
      "rectangleTool": "Rectangle",
      "ellipseTool": "Ellipse",
      "arrowTool": "Arrow",
      "penTool": "Pen",
      "textTool": "Text",
      "mosaicTool": "Mosaic",
      "blurTool": "Blur",
      "needPermissionStatus": "Screen Recording permission required",
      "permissionTitle": "Enable Screen Recording",
      "permissionMessage": "%@ only uses this permission to read the selected screen area. It does not record audio. After granting permission, reopen the app.",
      "noClipboardImage": "No image found in the clipboard",
      "recognizingText": "Recognizing text",
      "noTextFound": "No text found",
      "copiedText": "Copied recognized text to clipboard",
      "recognitionFailed": "Recognition failed: %@"
    ],
    "zh-Hans": [
      "waitingForShortcut": "等待快捷键",
      "openSettings": "打开设置…",
      "captureWithShortcut": "%@ 框选识别",
      "translateWithShortcut": "%@ 框选翻译",
      "captureEditor": "截图编辑",
      "recognizeClipboard": "识别剪切板图片",
      "quitApp": "退出 %@",
      "shortcutEnabled": "%@ 已启用",
      "pressNewShortcut": "请按下新的快捷键组合",
      "invalidShortcut": "这个快捷键不可用，可能已被系统、其他 App 或 Yamazaki 内部功能占用",
      "recognitionLanguageSet": "识别语言已设为 %@",
      "textDirectionSet": "文字方向：%@",
      "resultLayoutSet": "结果排版：%@",
      "appSettings": "%@ 设置",
      "subtitle": "状态栏 OCR 工具：按 %@ 框选识别，多语言文字复制到剪切板。",
      "general": "通用",
      "hotKey": "快捷键",
      "textDirection": "文字方向",
      "resultLayout": "结果排版",
      "statusModeOn": "状态栏模式已开启",
      "statusModeCaption": "%@ 不常驻 Dock，可从菜单栏图标打开设置。",
      "startAtLogin": "开机自动启动",
      "startAtLoginCaption": "登录 macOS 后自动打开 Yamazaki 菜单栏工具。",
      "startAtLoginEnabled": "已开启开机自动启动",
      "startAtLoginDisabled": "已关闭开机自动启动",
      "autoRestart": "退出后自动重启",
      "autoRestartCaption": "启用用户级 LaunchAgent，软件异常退出后会自动重新打开。",
      "autoRestartEnabled": "已启用自动重启",
      "autoRestartDisabled": "已关闭自动重启",
      "muteSuccessSound": "静音识别成功快门声",
      "ignoreWatermarkText": "忽略水印文字",
      "ignoreWatermarkCaption": "复制识别结果前，过滤重复、低对比度或异常大的背景水印文字。",
      "uiLanguage": "界面语言",
      "recognitionLanguage": "识别语言",
      "languageNote": "支持常见世界语言。清晰手写可尝试，但印刷体最稳定。",
      "shortcutHintIdle": "点击设置后录制新快捷键",
      "shortcutHintRecording": "请按下新的组合键",
      "successCaption": "识别完成后会播放轻微快门声，并把文字写入剪切板。",
      "setShortcut": "设置快捷键",
      "captureSelection": "框选识别",
      "translateSelection": "框选翻译",
      "translationLanguage": "截图翻译为",
      "translationLanguageSet": "截图翻译目标：%@",
      "horizontalScan": "横向扫描",
      "horizontalSubtitle": "适合网页、文章、表格和多语言混排。",
      "verticalScan": "竖向扫描",
      "verticalSubtitle": "适合竖排中文、日文和书籍图片。",
      "smartLayout": "智能排版",
      "smartSubtitle": "尽量合并自然段，适合文章和长句。",
      "lineLayout": "逐行输出",
      "lineSubtitle": "保留 OCR 行结构，适合表格、代码和短句。",
      "resultFontSize": "结果字体大小",
      "primaryWorkflow": "主要工作流",
      "ocrPrivacyCaption": "OCR 使用 Apple Vision 读取你框选的图像并写入剪切板。除非你主动使用截图翻译，识别流程不会调用翻译服务。",
      "advancedTools": "进阶工具",
      "advancedToolsCaption": "截图编辑属于进阶工具。常规 OCR 与标注功能分开，避免干扰快速识别。",
      "languagePrivacy": "语言与隐私",
      "translationPrivacyCaption": "截图翻译使用 macOS 系统 Translation 框架；可用语言和离线能力取决于系统支持。",
      "behavior": "行为",
      "shortcutConflictHint": "录制快捷键时会检查 Yamazaki 内部重复，并尝试检测 macOS 是否能注册该组合。建议优先使用 Command + Option 或 Command + Shift 组合。",
      "captureEditorCaption": "框选截图后进入悬浮编辑模式，可直接标注、取色、复制、保存和快速保存。",
      "captureEditorFeatureToolbar": "悬浮工具条：矩形、椭圆、箭头、画笔、文字、马赛克、模糊",
      "captureEditorFeatureOutput": "输出：复制到剪切板、保存 PNG、快速保存到 ~/Pictures/Yamazaki",
      "captureEditorFeatureAssist": "辅助：右键菜单、截图历史、放大预览、HEX 取色，按 C 可复制颜色",
      "startCaptureEditor": "开始截图编辑",
      "copyButton": "复制",
      "translationRequiresMacOS15": "截图翻译需要 macOS 15 或更高版本",
      "copiedScreenshot": "已复制截图到剪切板",
      "savedScreenshot": "已保存截图",
      "quickSavedScreenshot": "已快速保存截图",
      "style": "样式",
      "color": "颜色",
      "lineWidth": "线宽",
      "opacity": "透明度",
      "undo": "撤销",
      "redo": "重做",
      "copyCurrentColor": "复制当前颜色",
      "previousImage": "上一张",
      "nextImage": "下一张",
      "copyImage": "复制图像",
      "save": "保存",
      "saveAs": "保存为…",
      "quickSave": "快速保存",
      "close": "关闭",
      "addText": "添加文字",
      "ok": "确定",
      "cancel": "取消",
      "colorPickHint": "取色 C",
      "pointerTool": "指针",
      "rectangleTool": "矩形",
      "ellipseTool": "椭圆",
      "arrowTool": "箭头",
      "penTool": "画笔",
      "textTool": "文字",
      "mosaicTool": "马赛克",
      "blurTool": "模糊",
      "needPermissionStatus": "需要授予屏幕录制权限",
      "permissionTitle": "需要开启屏幕录制权限",
      "permissionMessage": "%@ 只用这个权限读取你框选的屏幕区域，不会录音。授权后请重新打开 App。",
      "noClipboardImage": "剪切板里没有图片",
      "recognizingText": "正在识别文字",
      "noTextFound": "未识别到文字",
      "copiedText": "已复制识别文字到剪切板",
      "recognitionFailed": "识别失败：%@"
    ],
    "zh-Hant": [
      "waitingForShortcut": "等待快捷鍵",
      "openSettings": "開啟設定…",
      "captureWithShortcut": "%@ 框選識別",
      "translateWithShortcut": "%@ 框選翻譯",
      "captureEditor": "截圖編輯",
      "recognizeClipboard": "識別剪貼簿圖片",
      "quitApp": "結束 %@",
      "shortcutEnabled": "%@ 已啟用",
      "pressNewShortcut": "請按下新的快捷鍵組合",
      "invalidShortcut": "這個快捷鍵不可用，可能已被系統、其他 App 或 Yamazaki 內部功能佔用",
      "recognitionLanguageSet": "識別語言已設為 %@",
      "textDirectionSet": "文字方向：%@",
      "resultLayoutSet": "結果排版：%@",
      "appSettings": "%@ 設定",
      "subtitle": "選單列 OCR 工具：按 %@ 框選識別，多語文字複製到剪貼簿。",
      "general": "通用",
      "hotKey": "快捷鍵",
      "textDirection": "文字方向",
      "resultLayout": "結果排版",
      "statusModeOn": "選單列模式已開啟",
      "statusModeCaption": "%@ 不常駐 Dock，可從選單列圖示開啟設定。",
      "startAtLogin": "開機自動啟動",
      "startAtLoginCaption": "登入 macOS 後自動開啟 Yamazaki 選單列工具。",
      "startAtLoginEnabled": "已開啟開機自動啟動",
      "startAtLoginDisabled": "已關閉開機自動啟動",
      "autoRestart": "結束後自動重啟",
      "autoRestartCaption": "啟用使用者級 LaunchAgent，軟體異常結束後會自動重新開啟。",
      "autoRestartEnabled": "已啟用自動重啟",
      "autoRestartDisabled": "已關閉自動重啟",
      "muteSuccessSound": "靜音識別成功快門聲",
      "ignoreWatermarkText": "忽略水印文字",
      "ignoreWatermarkCaption": "複製識別結果前，過濾重複、低對比度或異常大的背景水印文字。",
      "uiLanguage": "介面語言",
      "recognitionLanguage": "識別語言",
      "languageNote": "支援常見世界語言。清晰手寫可嘗試，但印刷體最穩定。",
      "shortcutHintIdle": "點擊設定後錄製新快捷鍵",
      "shortcutHintRecording": "請按下新的組合鍵",
      "successCaption": "識別完成後會播放輕微快門聲，並把文字寫入剪貼簿。",
      "setShortcut": "設定快捷鍵",
      "captureSelection": "框選識別",
      "translateSelection": "框選翻譯",
      "translationLanguage": "截圖翻譯為",
      "translationLanguageSet": "截圖翻譯目標：%@",
      "horizontalScan": "橫向掃描",
      "horizontalSubtitle": "適合網頁、文章、表格和多語混排。",
      "verticalScan": "直向掃描",
      "verticalSubtitle": "適合直排中文、日文和書籍圖片。",
      "smartLayout": "智慧排版",
      "smartSubtitle": "盡量合併自然段，適合文章和長句。",
      "lineLayout": "逐行輸出",
      "lineSubtitle": "保留 OCR 行結構，適合表格、程式碼和短句。",
      "resultFontSize": "結果字體大小",
      "primaryWorkflow": "主要工作流程",
      "ocrPrivacyCaption": "OCR 使用 Apple Vision 讀取你框選的圖像並寫入剪貼簿。除非你主動使用截圖翻譯，識別流程不會呼叫翻譯服務。",
      "advancedTools": "進階工具",
      "advancedToolsCaption": "截圖編輯屬於進階工具。日常 OCR 與標註功能分開，避免干擾快速識別。",
      "languagePrivacy": "語言與私隱",
      "translationPrivacyCaption": "截圖翻譯使用 macOS 系統 Translation 框架；可用語言和離線能力取決於系統支援。",
      "behavior": "行為",
      "shortcutConflictHint": "錄製快捷鍵時會檢查 Yamazaki 內部重複，並嘗試檢測 macOS 是否能註冊該組合。建議優先使用 Command + Option 或 Command + Shift 組合。",
      "captureEditorCaption": "框選截圖後進入浮動編輯模式，可直接標註、取色、複製、儲存和快速儲存。",
      "captureEditorFeatureToolbar": "浮動工具列：矩形、橢圓、箭咀、畫筆、文字、馬賽克、模糊",
      "captureEditorFeatureOutput": "輸出：複製到剪貼簿、儲存 PNG、快速儲存到 ~/Pictures/Yamazaki",
      "captureEditorFeatureAssist": "輔助：右鍵選單、截圖歷史、放大預覽、HEX 取色，按 C 可複製顏色",
      "startCaptureEditor": "開始截圖編輯",
      "copyButton": "複製",
      "translationRequiresMacOS15": "截圖翻譯需要 macOS 15 或更高版本",
      "copiedScreenshot": "已複製截圖到剪貼簿",
      "savedScreenshot": "已儲存截圖",
      "quickSavedScreenshot": "已快速儲存截圖",
      "style": "樣式",
      "color": "顏色",
      "lineWidth": "線寬",
      "opacity": "透明度",
      "undo": "還原",
      "redo": "重做",
      "copyCurrentColor": "複製目前顏色",
      "previousImage": "上一張",
      "nextImage": "下一張",
      "copyImage": "複製圖像",
      "save": "儲存",
      "saveAs": "另存為…",
      "quickSave": "快速儲存",
      "close": "關閉",
      "addText": "加入文字",
      "ok": "確定",
      "cancel": "取消",
      "colorPickHint": "取色 C",
      "pointerTool": "指標",
      "rectangleTool": "矩形",
      "ellipseTool": "橢圓",
      "arrowTool": "箭咀",
      "penTool": "畫筆",
      "textTool": "文字",
      "mosaicTool": "馬賽克",
      "blurTool": "模糊",
      "needPermissionStatus": "需要授予螢幕錄製權限",
      "permissionTitle": "需要開啟螢幕錄製權限",
      "permissionMessage": "%@ 只用這個權限讀取你框選的螢幕區域，不會錄音。授權後請重新開啟 App。",
      "noClipboardImage": "剪貼簿裡沒有圖片",
      "recognizingText": "正在識別文字",
      "noTextFound": "未識別到文字",
      "copiedText": "已複製識別文字到剪貼簿",
      "recognitionFailed": "識別失敗：%@"
    ],
    "ja": [
      "appSettings": "%@ 設定",
      "subtitle": "メニューバー OCR：%@ を押して範囲を選択し、多言語テキストをクリップボードへコピーします。",
      "general": "一般",
      "hotKey": "ショートカット",
      "textDirection": "文字方向",
      "resultLayout": "結果レイアウト",
      "captureEditor": "スクリーンショット編集",
      "openSettings": "設定を開く…",
      "recognizeClipboard": "クリップボード画像を認識",
      "quitApp": "%@ を終了",
      "waitingForShortcut": "ショートカット待機中",
      "shortcutEnabled": "%@ 有効",
      "captureWithShortcut": "%@ 範囲認識",
      "translateWithShortcut": "%@ 範囲翻訳",
      "invalidShortcut": "このショートカットはシステム、他のアプリ、または Yamazaki で使用されています。",
      "uiLanguage": "表示言語",
      "recognitionLanguage": "認識言語",
      "translationLanguage": "翻訳先",
      "languageNote": "主要な世界言語に対応。きれいな手書きは試せますが、印刷文字が最も安定します。",
      "setShortcut": "ショートカット設定",
      "captureSelection": "範囲を認識",
      "translateSelection": "範囲を翻訳",
      "primaryWorkflow": "主なワークフロー",
      "ocrPrivacyCaption": "OCR は Apple Vision で選択画像を読み取り、テキストをクリップボードへ書き込みます。翻訳はスクリーンショット翻訳を選んだ場合のみ使われます。",
      "advancedTools": "高度なツール",
      "advancedToolsCaption": "スクリーンショット編集は高度なツールです。通常の OCR と注釈を分け、素早い認識を保ちます。",
      "languagePrivacy": "言語とプライバシー",
      "translationPrivacyCaption": "スクリーンショット翻訳は macOS Translation フレームワークを使用します。利用可能な言語とオフライン動作はシステムに依存します。",
      "behavior": "動作",
      "startAtLogin": "ログイン時に起動",
      "startAtLoginCaption": "macOS へのサインイン後に Yamazaki を自動的に開きます。",
      "startAtLoginEnabled": "ログイン時起動を有効化しました",
      "startAtLoginDisabled": "ログイン時起動を無効化しました",
      "autoRestart": "終了後に自動再起動",
      "autoRestartCaption": "予期しない終了後にメニューバーツールを再度開きます。",
      "muteSuccessSound": "成功シャッター音を消音",
      "ignoreWatermarkText": "透かし文字を無視",
      "ignoreWatermarkCaption": "コピー前に、繰り返し・低コントラスト・大きすぎる背景文字を除外します。",
      "shortcutConflictHint": "Yamazaki 内の重複を確認し、macOS が登録できる組み合わせかをテストします。Command + Option または Command + Shift を推奨します。",
      "successCaption": "認識後、静かなシャッター音を鳴らし、テキストをクリップボードへコピーします。",
      "horizontalScan": "横書きスキャン",
      "horizontalSubtitle": "Web、記事、表、混在言語向け。",
      "verticalScan": "縦書きスキャン",
      "verticalSubtitle": "縦書き中国語、日本語、書籍画像向け。",
      "smartLayout": "スマート整形",
      "smartSubtitle": "記事や長文の自然な段落を結合します。",
      "lineLayout": "行ごと",
      "lineSubtitle": "表、コード、短いテキスト向けに行構造を保持します。",
      "resultFontSize": "結果の文字サイズ",
      "captureEditorCaption": "範囲選択後、注釈、色取得、コピー、保存、クイック保存用のフローティング編集画面を開きます。",
      "captureEditorFeatureToolbar": "フローティングツールバー：矩形、楕円、矢印、ペン、文字、モザイク、ぼかし",
      "captureEditorFeatureOutput": "出力：クリップボードへコピー、PNG 保存、~/Pictures/Yamazaki へクイック保存",
      "captureEditorFeatureAssist": "補助：コンテキストメニュー、履歴、拡大表示、HEX 色取得、C で色をコピー",
      "startCaptureEditor": "編集を開始",
      "copyButton": "コピー",
      "translationRequiresMacOS15": "翻訳には macOS 15 以降が必要です",
      "copiedScreenshot": "スクリーンショットをクリップボードへコピーしました",
      "savedScreenshot": "スクリーンショットを保存しました",
      "quickSavedScreenshot": "スクリーンショットをクイック保存しました",
      "style": "スタイル",
      "color": "色",
      "lineWidth": "線幅",
      "opacity": "不透明度",
      "undo": "取り消す",
      "redo": "やり直す",
      "copyCurrentColor": "現在の色をコピー",
      "previousImage": "前の画像",
      "nextImage": "次の画像",
      "copyImage": "画像をコピー",
      "save": "保存",
      "saveAs": "別名で保存…",
      "quickSave": "クイック保存",
      "close": "閉じる",
      "addText": "テキストを追加",
      "ok": "OK",
      "cancel": "キャンセル",
      "colorPickHint": "色取得 C"
    ],
    "ko": [
      "appSettings": "%@ 설정",
      "subtitle": "메뉴 막대 OCR: %@ 키로 영역을 선택하고 다국어 텍스트를 클립보드에 복사합니다.",
      "general": "일반",
      "hotKey": "단축키",
      "textDirection": "텍스트 방향",
      "resultLayout": "결과 레이아웃",
      "captureEditor": "스크린샷 편집",
      "openSettings": "설정 열기…",
      "recognizeClipboard": "클립보드 이미지 인식",
      "quitApp": "%@ 종료",
      "waitingForShortcut": "단축키 대기 중",
      "shortcutEnabled": "%@ 활성화",
      "captureWithShortcut": "%@ 영역 인식",
      "translateWithShortcut": "%@ 영역 번역",
      "invalidShortcut": "이 단축키는 시스템, 다른 앱 또는 Yamazaki에서 사용 중일 수 있습니다.",
      "uiLanguage": "인터페이스 언어",
      "recognitionLanguage": "인식 언어",
      "translationLanguage": "번역 대상",
      "languageNote": "주요 세계 언어를 지원합니다. 선명한 손글씨는 시도할 수 있지만 인쇄체가 가장 안정적입니다.",
      "setShortcut": "단축키 설정",
      "captureSelection": "영역 인식",
      "translateSelection": "영역 번역",
      "primaryWorkflow": "주요 작업 흐름",
      "ocrPrivacyCaption": "OCR은 Apple Vision으로 선택한 이미지를 읽고 텍스트를 클립보드에 씁니다. 번역은 스크린샷 번역을 선택한 경우에만 사용됩니다.",
      "advancedTools": "고급 도구",
      "advancedToolsCaption": "스크린샷 편집은 고급 도구입니다. 일반 OCR과 주석 기능을 분리해 빠른 인식을 유지합니다.",
      "languagePrivacy": "언어 및 개인 정보",
      "translationPrivacyCaption": "스크린샷 번역은 macOS Translation 프레임워크를 사용합니다. 지원 언어와 오프라인 동작은 시스템 지원에 따라 달라집니다.",
      "behavior": "동작",
      "startAtLogin": "로그인 시 시작",
      "startAtLoginCaption": "macOS 로그인 후 Yamazaki 메뉴 막대 도구를 자동으로 엽니다.",
      "startAtLoginEnabled": "로그인 시 시작이 켜졌습니다",
      "startAtLoginDisabled": "로그인 시 시작이 꺼졌습니다",
      "autoRestart": "종료 후 자동 재시작",
      "autoRestartCaption": "예기치 않은 종료 후 메뉴 막대 도구를 다시 엽니다.",
      "muteSuccessSound": "성공 셔터음 음소거",
      "ignoreWatermarkText": "워터마크 텍스트 무시",
      "ignoreWatermarkCaption": "복사하기 전에 반복되거나 대비가 낮거나 비정상적으로 큰 배경 텍스트를 걸러냅니다.",
      "shortcutConflictHint": "Yamazaki 내부 중복을 확인하고 macOS가 해당 조합을 등록할 수 있는지 테스트합니다. Command + Option 또는 Command + Shift 조합을 권장합니다.",
      "successCaption": "인식 후 조용한 셔터음이 재생되고 텍스트가 클립보드에 복사됩니다.",
      "horizontalScan": "가로 스캔",
      "horizontalSubtitle": "웹, 기사, 표, 혼합 언어 텍스트에 적합합니다.",
      "verticalScan": "세로 스캔",
      "verticalSubtitle": "세로 중국어, 일본어, 책 이미지에 적합합니다.",
      "smartLayout": "스마트 정리",
      "smartSubtitle": "기사와 긴 문장의 자연스러운 문단을 병합합니다.",
      "lineLayout": "줄 단위",
      "lineSubtitle": "표, 코드, 짧은 텍스트에 맞게 OCR 줄바꿈을 유지합니다.",
      "resultFontSize": "결과 글자 크기",
      "captureEditorCaption": "영역 선택 후 주석, 색상 추출, 복사, 저장, 빠른 저장을 위한 플로팅 편집기를 엽니다.",
      "captureEditorFeatureToolbar": "플로팅 도구 막대: 사각형, 타원, 화살표, 펜, 텍스트, 모자이크, 흐림",
      "captureEditorFeatureOutput": "출력: 클립보드 복사, PNG 저장, ~/Pictures/Yamazaki 빠른 저장",
      "captureEditorFeatureAssist": "보조: 컨텍스트 메뉴, 캡처 기록, 확대 미리보기, HEX 색상 추출, C로 색상 복사",
      "startCaptureEditor": "편집 시작",
      "copyButton": "복사",
      "translationRequiresMacOS15": "번역에는 macOS 15 이상이 필요합니다",
      "copiedScreenshot": "스크린샷을 클립보드에 복사했습니다",
      "savedScreenshot": "스크린샷을 저장했습니다",
      "quickSavedScreenshot": "스크린샷을 빠르게 저장했습니다",
      "style": "스타일",
      "color": "색상",
      "lineWidth": "선 두께",
      "opacity": "불투명도",
      "undo": "실행 취소",
      "redo": "다시 실행",
      "copyCurrentColor": "현재 색상 복사",
      "previousImage": "이전 이미지",
      "nextImage": "다음 이미지",
      "copyImage": "이미지 복사",
      "save": "저장",
      "saveAs": "다른 이름으로 저장…",
      "quickSave": "빠른 저장",
      "close": "닫기",
      "addText": "텍스트 추가",
      "ok": "확인",
      "cancel": "취소",
      "colorPickHint": "색상 추출 C"
    ],
    "fr": [
      "appSettings": "Réglages %@",
      "subtitle": "OCR de barre de menus : appuyez sur %@, sélectionnez une zone et copiez le texte multilingue.",
      "general": "Général",
      "hotKey": "Raccourci",
      "textDirection": "Direction",
      "resultLayout": "Mise en page",
      "captureEditor": "Éditeur de capture",
      "openSettings": "Ouvrir les réglages…",
      "recognizeClipboard": "Reconnaître l’image du presse-papiers",
      "quitApp": "Quitter %@",
      "waitingForShortcut": "En attente du raccourci",
      "shortcutEnabled": "%@ activé",
      "captureWithShortcut": "%@ Capturer",
      "translateWithShortcut": "%@ Traduire",
      "invalidShortcut": "Ce raccourci est indisponible ou déjà utilisé par le système, une autre app ou Yamazaki.",
      "uiLanguage": "Langue de l’interface",
      "recognitionLanguage": "Langue OCR",
      "translationLanguage": "Traduire vers",
      "languageNote": "Reconnaît les langues courantes. L’écriture manuscrite claire peut fonctionner, mais le texte imprimé est plus fiable.",
      "setShortcut": "Définir le raccourci",
      "captureSelection": "Reconnaître la zone",
      "translateSelection": "Traduire la zone",
      "primaryWorkflow": "Flux principal",
      "ocrPrivacyCaption": "L’OCR utilise Apple Vision pour lire l’image sélectionnée et copier le texte. La traduction n’est utilisée que si vous lancez la traduction de capture.",
      "advancedTools": "Outils avancés",
      "advancedToolsCaption": "L’édition de capture est avancée. L’OCR quotidien reste séparé des annotations pour garder le flux rapide.",
      "languagePrivacy": "Langue et confidentialité",
      "translationPrivacyCaption": "La traduction de capture utilise le framework Translation de macOS. Les langues et le mode hors ligne dépendent du système.",
      "behavior": "Comportement",
      "startAtLogin": "Ouvrir à la connexion",
      "startAtLoginCaption": "Ouvre Yamazaki automatiquement après la connexion à macOS.",
      "startAtLoginEnabled": "Ouverture à la connexion activée",
      "startAtLoginDisabled": "Ouverture à la connexion désactivée",
      "autoRestart": "Redémarrer après fermeture",
      "autoRestartCaption": "Rouvre l’outil de barre de menus après une fermeture inattendue.",
      "muteSuccessSound": "Couper le son de réussite",
      "ignoreWatermarkText": "Ignorer le filigrane",
      "ignoreWatermarkCaption": "Filtre les textes répétés, peu contrastés ou anormalement grands avant la copie.",
      "shortcutConflictHint": "Yamazaki vérifie les doublons internes et teste si macOS peut enregistrer la combinaison. Command + Option ou Command + Shift est recommandé.",
      "successCaption": "Après reconnaissance, un son discret est joué et le texte est copié.",
      "horizontalScan": "Scan horizontal",
      "horizontalSubtitle": "Pour pages web, articles, tableaux et textes multilingues.",
      "verticalScan": "Scan vertical",
      "verticalSubtitle": "Pour chinois vertical, japonais et images de livres.",
      "smartLayout": "Mise en page intelligente",
      "smartSubtitle": "Fusionne les paragraphes naturels pour les articles et longues phrases.",
      "lineLayout": "Ligne par ligne",
      "lineSubtitle": "Conserve les sauts de ligne OCR pour tableaux, code et textes courts.",
      "resultFontSize": "Taille du texte du résultat",
      "captureEditorCaption": "Après la sélection, ouvre un éditeur flottant pour annoter, prélever une couleur, copier et enregistrer.",
      "captureEditorFeatureToolbar": "Barre flottante : rectangle, ellipse, flèche, stylo, texte, mosaïque et flou",
      "captureEditorFeatureOutput": "Sortie : copier, enregistrer PNG ou sauvegarde rapide dans ~/Pictures/Yamazaki",
      "captureEditorFeatureAssist": "Aide : menu contextuel, historique, loupe, couleur HEX, C pour copier la couleur",
      "startCaptureEditor": "Démarrer l’éditeur",
      "copyButton": "Copier",
      "translationRequiresMacOS15": "La traduction nécessite macOS 15 ou ultérieur",
      "copiedScreenshot": "Capture copiée dans le presse-papiers",
      "savedScreenshot": "Capture enregistrée",
      "quickSavedScreenshot": "Capture enregistrée rapidement",
      "style": "Style",
      "color": "Couleur",
      "lineWidth": "Épaisseur",
      "opacity": "Opacité",
      "undo": "Annuler",
      "redo": "Rétablir",
      "copyCurrentColor": "Copier la couleur actuelle",
      "previousImage": "Image précédente",
      "nextImage": "Image suivante",
      "copyImage": "Copier l’image",
      "save": "Enregistrer",
      "saveAs": "Enregistrer sous…",
      "quickSave": "Sauvegarde rapide",
      "close": "Fermer",
      "addText": "Ajouter du texte",
      "ok": "OK",
      "cancel": "Annuler",
      "colorPickHint": "Couleur C"
    ],
    "pt": [
      "appSettings": "Ajustes do %@",
      "subtitle": "OCR na barra de menus: pressione %@, selecione uma área e copie texto multilíngue.",
      "general": "Geral",
      "hotKey": "Atalho",
      "textDirection": "Direção",
      "resultLayout": "Layout",
      "captureEditor": "Editor de captura",
      "openSettings": "Abrir ajustes…",
      "recognizeClipboard": "Reconhecer imagem da área de transferência",
      "quitApp": "Sair do %@",
      "waitingForShortcut": "Aguardando atalho",
      "shortcutEnabled": "%@ ativado",
      "captureWithShortcut": "%@ Capturar",
      "translateWithShortcut": "%@ Traduzir",
      "invalidShortcut": "Este atalho não está disponível ou já é usado pelo sistema, outro app ou Yamazaki.",
      "uiLanguage": "Idioma da interface",
      "recognitionLanguage": "Idioma OCR",
      "translationLanguage": "Traduzir para",
      "languageNote": "Reconhece idiomas comuns. Escrita manual nítida pode funcionar, mas texto impresso é mais confiável.",
      "setShortcut": "Definir atalho",
      "captureSelection": "Reconhecer seleção",
      "translateSelection": "Traduzir seleção",
      "primaryWorkflow": "Fluxo principal",
      "ocrPrivacyCaption": "O OCR usa Apple Vision para ler a imagem selecionada e copiar o texto. Tradução só é usada quando você escolhe traduzir captura.",
      "advancedTools": "Ferramentas avançadas",
      "advancedToolsCaption": "A edição de captura é avançada. OCR diário fica separado das anotações para manter o fluxo rápido.",
      "languagePrivacy": "Idioma e privacidade",
      "translationPrivacyCaption": "A tradução de captura usa o framework Translation do macOS. Idiomas e uso offline dependem do sistema.",
      "behavior": "Comportamento",
      "startAtLogin": "Abrir ao iniciar sessão",
      "startAtLoginCaption": "Abre o Yamazaki automaticamente após iniciar sessão no macOS.",
      "startAtLoginEnabled": "Abertura ao iniciar sessão ativada",
      "startAtLoginDisabled": "Abertura ao iniciar sessão desativada",
      "autoRestart": "Reiniciar após sair",
      "autoRestartCaption": "Reabre a ferramenta da barra de menus após uma saída inesperada.",
      "muteSuccessSound": "Silenciar som de sucesso",
      "ignoreWatermarkText": "Ignorar marca-d’água",
      "ignoreWatermarkCaption": "Filtra texto de fundo repetido, de baixo contraste ou grande demais antes de copiar.",
      "shortcutConflictHint": "Yamazaki verifica duplicatas internas e testa se o macOS pode registrar a combinação. Command + Option ou Command + Shift é recomendado.",
      "successCaption": "Após reconhecer, um som discreto toca e o texto é copiado.",
      "horizontalScan": "Varredura horizontal",
      "horizontalSubtitle": "Para páginas, artigos, tabelas e texto multilíngue.",
      "verticalScan": "Varredura vertical",
      "verticalSubtitle": "Para chinês vertical, japonês e imagens de livros.",
      "smartLayout": "Layout inteligente",
      "smartSubtitle": "Mescla parágrafos naturais para artigos e frases longas.",
      "lineLayout": "Linha por linha",
      "lineSubtitle": "Mantém quebras OCR para tabelas, código e textos curtos.",
      "resultFontSize": "Tamanho do texto do resultado",
      "captureEditorCaption": "Após selecionar uma área, abre um editor flutuante para anotar, escolher cor, copiar e salvar.",
      "captureEditorFeatureToolbar": "Barra flutuante: retângulo, elipse, seta, caneta, texto, mosaico e desfoque",
      "captureEditorFeatureOutput": "Saída: copiar, salvar PNG ou salvar rápido em ~/Pictures/Yamazaki",
      "captureEditorFeatureAssist": "Ajuda: menu contextual, histórico, lupa, cor HEX, C para copiar cor",
      "startCaptureEditor": "Iniciar editor",
      "copyButton": "Copiar",
      "translationRequiresMacOS15": "A tradução exige macOS 15 ou posterior",
      "copiedScreenshot": "Captura copiada para a área de transferência",
      "savedScreenshot": "Captura salva",
      "quickSavedScreenshot": "Captura salva rapidamente",
      "style": "Estilo",
      "color": "Cor",
      "lineWidth": "Espessura",
      "opacity": "Opacidade",
      "undo": "Desfazer",
      "redo": "Refazer",
      "copyCurrentColor": "Copiar cor atual",
      "previousImage": "Imagem anterior",
      "nextImage": "Próxima imagem",
      "copyImage": "Copiar imagem",
      "save": "Salvar",
      "saveAs": "Salvar como…",
      "quickSave": "Salvar rápido",
      "close": "Fechar",
      "addText": "Adicionar texto",
      "ok": "OK",
      "cancel": "Cancelar",
      "colorPickHint": "Cor C"
    ],
    "es": [
      "appSettings": "Ajustes de %@",
      "subtitle": "OCR en la barra de menús: pulsa %@, selecciona un área y copia texto multilingüe.",
      "general": "General",
      "hotKey": "Atajo",
      "textDirection": "Dirección",
      "resultLayout": "Diseño",
      "captureEditor": "Editor de captura",
      "openSettings": "Abrir ajustes…",
      "recognizeClipboard": "Reconocer imagen del portapapeles",
      "quitApp": "Salir de %@",
      "waitingForShortcut": "Esperando atajo",
      "shortcutEnabled": "%@ activado",
      "captureWithShortcut": "%@ Capturar",
      "translateWithShortcut": "%@ Traducir",
      "invalidShortcut": "Este atajo no está disponible o ya lo usa el sistema, otra app o Yamazaki.",
      "uiLanguage": "Idioma de la interfaz",
      "recognitionLanguage": "Idioma OCR",
      "translationLanguage": "Traducir a",
      "languageNote": "Reconoce idiomas comunes. La escritura clara puede funcionar, pero el texto impreso es más fiable.",
      "setShortcut": "Definir atajo",
      "captureSelection": "Reconocer selección",
      "translateSelection": "Traducir selección",
      "primaryWorkflow": "Flujo principal",
      "ocrPrivacyCaption": "El OCR usa Apple Vision para leer la imagen seleccionada y copiar el texto. La traducción solo se usa al traducir una captura.",
      "advancedTools": "Herramientas avanzadas",
      "advancedToolsCaption": "La edición de captura es avanzada. El OCR diario queda separado de las anotaciones para mantener rapidez.",
      "languagePrivacy": "Idioma y privacidad",
      "translationPrivacyCaption": "La traducción de capturas usa el framework Translation de macOS. Los idiomas y el modo sin conexión dependen del sistema.",
      "behavior": "Comportamiento",
      "startAtLogin": "Abrir al iniciar sesión",
      "startAtLoginCaption": "Abre Yamazaki automáticamente después de iniciar sesión en macOS.",
      "startAtLoginEnabled": "Apertura al iniciar sesión activada",
      "startAtLoginDisabled": "Apertura al iniciar sesión desactivada",
      "autoRestart": "Reiniciar al salir",
      "autoRestartCaption": "Reabre la herramienta de la barra de menús tras una salida inesperada.",
      "muteSuccessSound": "Silenciar sonido de éxito",
      "ignoreWatermarkText": "Ignorar texto de marca de agua",
      "ignoreWatermarkCaption": "Filtra texto de fondo repetido, de bajo contraste o demasiado grande antes de copiar.",
      "shortcutConflictHint": "Yamazaki revisa duplicados internos y prueba si macOS puede registrar la combinación. Se recomienda Command + Option o Command + Shift.",
      "successCaption": "Tras reconocer, suena un aviso discreto y el texto se copia.",
      "horizontalScan": "Escaneo horizontal",
      "horizontalSubtitle": "Para webs, artículos, tablas y texto multilingüe.",
      "verticalScan": "Escaneo vertical",
      "verticalSubtitle": "Para chino vertical, japonés e imágenes de libros.",
      "smartLayout": "Diseño inteligente",
      "smartSubtitle": "Une párrafos naturales en artículos y frases largas.",
      "lineLayout": "Línea por línea",
      "lineSubtitle": "Mantiene saltos OCR para tablas, código y textos cortos.",
      "resultFontSize": "Tamaño del resultado",
      "captureEditorCaption": "Tras seleccionar un área, abre un editor flotante para anotar, tomar color, copiar y guardar.",
      "captureEditorFeatureToolbar": "Barra flotante: rectángulo, elipse, flecha, lápiz, texto, mosaico y desenfoque",
      "captureEditorFeatureOutput": "Salida: copiar, guardar PNG o guardado rápido en ~/Pictures/Yamazaki",
      "captureEditorFeatureAssist": "Ayuda: menú contextual, historial, lupa, color HEX, C para copiar color",
      "startCaptureEditor": "Iniciar editor",
      "copyButton": "Copiar",
      "translationRequiresMacOS15": "La traducción requiere macOS 15 o posterior",
      "copiedScreenshot": "Captura copiada al portapapeles",
      "savedScreenshot": "Captura guardada",
      "quickSavedScreenshot": "Captura guardada rápidamente",
      "style": "Estilo",
      "color": "Color",
      "lineWidth": "Grosor",
      "opacity": "Opacidad",
      "undo": "Deshacer",
      "redo": "Rehacer",
      "copyCurrentColor": "Copiar color actual",
      "previousImage": "Imagen anterior",
      "nextImage": "Imagen siguiente",
      "copyImage": "Copiar imagen",
      "save": "Guardar",
      "saveAs": "Guardar como…",
      "quickSave": "Guardado rápido",
      "close": "Cerrar",
      "addText": "Añadir texto",
      "ok": "OK",
      "cancel": "Cancelar",
      "colorPickHint": "Color C"
    ],
    "de": [
      "appSettings": "%@ Einstellungen",
      "subtitle": "Menüleisten-OCR: %@ drücken, Bereich auswählen und mehrsprachigen Text kopieren.",
      "general": "Allgemein",
      "hotKey": "Kurzbefehl",
      "textDirection": "Textrichtung",
      "resultLayout": "Layout",
      "captureEditor": "Screenshot-Editor",
      "openSettings": "Einstellungen öffnen…",
      "recognizeClipboard": "Zwischenablagebild erkennen",
      "quitApp": "%@ beenden",
      "waitingForShortcut": "Warte auf Kurzbefehl",
      "shortcutEnabled": "%@ aktiviert",
      "captureWithShortcut": "%@ Erfassen",
      "translateWithShortcut": "%@ Übersetzen",
      "invalidShortcut": "Dieser Kurzbefehl ist nicht verfügbar oder wird vom System, einer anderen App oder Yamazaki verwendet.",
      "uiLanguage": "Oberflächensprache",
      "recognitionLanguage": "OCR-Sprache",
      "translationLanguage": "Übersetzen nach",
      "languageNote": "Erkennt gängige Weltsprachen. Klare Handschrift kann funktionieren, gedruckter Text ist am zuverlässigsten.",
      "setShortcut": "Kurzbefehl setzen",
      "captureSelection": "Bereich erkennen",
      "translateSelection": "Bereich übersetzen",
      "primaryWorkflow": "Hauptablauf",
      "ocrPrivacyCaption": "OCR nutzt Apple Vision, um den gewählten Bildbereich zu lesen und Text zu kopieren. Übersetzung wird nur bei Screenshot-Übersetzung genutzt.",
      "advancedTools": "Erweiterte Werkzeuge",
      "advancedToolsCaption": "Screenshot-Bearbeitung ist erweitert. Normales OCR bleibt getrennt von Annotationen, damit der Ablauf schnell bleibt.",
      "languagePrivacy": "Sprache und Datenschutz",
      "translationPrivacyCaption": "Screenshot-Übersetzung nutzt das macOS Translation-Framework. Sprachen und Offline-Verhalten hängen vom System ab.",
      "behavior": "Verhalten",
      "startAtLogin": "Beim Anmelden öffnen",
      "startAtLoginCaption": "Öffnet Yamazaki nach der Anmeldung bei macOS automatisch.",
      "startAtLoginEnabled": "Beim Anmelden öffnen aktiviert",
      "startAtLoginDisabled": "Beim Anmelden öffnen deaktiviert",
      "autoRestart": "Nach Beenden neu starten",
      "autoRestartCaption": "Öffnet das Menüleistenwerkzeug nach unerwartetem Beenden erneut.",
      "muteSuccessSound": "Erfolgston stummschalten",
      "ignoreWatermarkText": "Wasserzeichen ignorieren",
      "ignoreWatermarkCaption": "Filtert wiederholten, kontrastarmen oder ungewöhnlich großen Hintergrundtext vor dem Kopieren.",
      "shortcutConflictHint": "Yamazaki prüft interne Dopplungen und ob macOS die Kombination registrieren kann. Command + Option oder Command + Shift wird empfohlen.",
      "successCaption": "Nach der Erkennung ertönt ein leiser Ton und der Text wird kopiert.",
      "horizontalScan": "Horizontal scannen",
      "horizontalSubtitle": "Für Webseiten, Artikel, Tabellen und mehrsprachigen Text.",
      "verticalScan": "Vertikal scannen",
      "verticalSubtitle": "Für vertikales Chinesisch, Japanisch und Buchbilder.",
      "smartLayout": "Intelligentes Layout",
      "smartSubtitle": "Fügt natürliche Absätze für Artikel und lange Sätze zusammen.",
      "lineLayout": "Zeile für Zeile",
      "lineSubtitle": "Behält OCR-Zeilenumbrüche für Tabellen, Code und kurzen Text bei.",
      "resultFontSize": "Ergebnis-Schriftgröße",
      "captureEditorCaption": "Nach der Auswahl öffnet ein schwebender Editor für Markierungen, Farbpipette, Kopieren und Speichern.",
      "captureEditorFeatureToolbar": "Schwebende Leiste: Rechteck, Ellipse, Pfeil, Stift, Text, Mosaik und Weichzeichnen",
      "captureEditorFeatureOutput": "Ausgabe: kopieren, PNG speichern oder schnell nach ~/Pictures/Yamazaki speichern",
      "captureEditorFeatureAssist": "Hilfe: Kontextmenü, Verlauf, Lupe, HEX-Farbe, C kopiert Farbe",
      "startCaptureEditor": "Editor starten",
      "copyButton": "Kopieren",
      "translationRequiresMacOS15": "Übersetzung erfordert macOS 15 oder neuer",
      "copiedScreenshot": "Screenshot in die Zwischenablage kopiert",
      "savedScreenshot": "Screenshot gespeichert",
      "quickSavedScreenshot": "Screenshot schnell gespeichert",
      "style": "Stil",
      "color": "Farbe",
      "lineWidth": "Linienbreite",
      "opacity": "Deckkraft",
      "undo": "Widerrufen",
      "redo": "Wiederholen",
      "copyCurrentColor": "Aktuelle Farbe kopieren",
      "previousImage": "Vorheriges Bild",
      "nextImage": "Nächstes Bild",
      "copyImage": "Bild kopieren",
      "save": "Sichern",
      "saveAs": "Sichern unter…",
      "quickSave": "Schnell sichern",
      "close": "Schließen",
      "addText": "Text hinzufügen",
      "ok": "OK",
      "cancel": "Abbrechen",
      "colorPickHint": "Farbe C"
    ],
    "th": [
      "appSettings": "การตั้งค่า %@",
      "subtitle": "OCR บนแถบเมนู: กด %@ เลือกพื้นที่ แล้วคัดลอกข้อความหลายภาษา",
      "general": "ทั่วไป",
      "hotKey": "ปุ่มลัด",
      "textDirection": "ทิศทางข้อความ",
      "resultLayout": "รูปแบบผลลัพธ์",
      "captureEditor": "แก้ไขภาพหน้าจอ",
      "openSettings": "เปิดการตั้งค่า…",
      "recognizeClipboard": "อ่านข้อความจากคลิปบอร์ด",
      "quitApp": "ออกจาก %@",
      "waitingForShortcut": "รอปุ่มลัด",
      "shortcutEnabled": "เปิดใช้ %@",
      "captureWithShortcut": "%@ อ่านพื้นที่",
      "translateWithShortcut": "%@ แปลพื้นที่",
      "invalidShortcut": "ปุ่มลัดนี้ใช้ไม่ได้ หรือถูกใช้โดยระบบ แอปอื่น หรือ Yamazaki",
      "uiLanguage": "ภาษาอินเทอร์เฟซ",
      "recognitionLanguage": "ภาษา OCR",
      "translationLanguage": "แปลเป็น",
      "languageNote": "รองรับภาษาทั่วโลกที่ใช้บ่อย ลายมือที่ชัดเจนอาจใช้ได้ แต่ตัวพิมพ์เสถียรกว่า",
      "setShortcut": "ตั้งค่าปุ่มลัด",
      "captureSelection": "อ่านข้อความ",
      "translateSelection": "แปลข้อความ",
      "primaryWorkflow": "งานหลัก",
      "ocrPrivacyCaption": "OCR ใช้ Apple Vision อ่านภาพที่เลือกและคัดลอกข้อความ การแปลจะใช้เมื่อคุณเลือกแปลภาพหน้าจอเท่านั้น",
      "advancedTools": "เครื่องมือขั้นสูง",
      "advancedToolsCaption": "การแก้ไขภาพหน้าจอเป็นเครื่องมือขั้นสูง แยกออกจาก OCR หลักเพื่อให้ใช้งานเร็ว",
      "languagePrivacy": "ภาษาและความเป็นส่วนตัว",
      "translationPrivacyCaption": "การแปลภาพหน้าจอใช้กรอบงาน Translation ของ macOS ภาษาและโหมดออฟไลน์ขึ้นกับระบบ",
      "behavior": "พฤติกรรม",
      "startAtLogin": "เปิดเมื่อเข้าสู่ระบบ",
      "startAtLoginCaption": "เปิด Yamazaki อัตโนมัติหลังเข้าสู่ระบบ macOS",
      "startAtLoginEnabled": "เปิดใช้การเริ่มเมื่อเข้าสู่ระบบแล้ว",
      "startAtLoginDisabled": "ปิดการเริ่มเมื่อเข้าสู่ระบบแล้ว",
      "autoRestart": "เปิดใหม่หลังออก",
      "autoRestartCaption": "เปิดเครื่องมือแถบเมนูใหม่หลังแอปปิดโดยไม่คาดคิด",
      "muteSuccessSound": "ปิดเสียงสำเร็จ",
      "ignoreWatermarkText": "ละเว้นข้อความลายน้ำ",
      "ignoreWatermarkCaption": "กรองข้อความพื้นหลังที่ซ้ำ คอนทราสต์ต่ำ หรือใหญ่ผิดปกติก่อนคัดลอก",
      "shortcutConflictHint": "Yamazaki ตรวจปุ่มลัดซ้ำภายในแอปและทดสอบว่า macOS ลงทะเบียนได้หรือไม่ แนะนำ Command + Option หรือ Command + Shift",
      "successCaption": "หลังอ่านสำเร็จ จะมีเสียงเบา ๆ และคัดลอกข้อความไปยังคลิปบอร์ด",
      "horizontalScan": "สแกนแนวนอน",
      "horizontalSubtitle": "เหมาะกับเว็บ บทความ ตาราง และหลายภาษา",
      "verticalScan": "สแกนแนวตั้ง",
      "verticalSubtitle": "เหมาะกับจีนแนวตั้ง ญี่ปุ่น และภาพหนังสือ",
      "smartLayout": "จัดรูปแบบอัจฉริยะ",
      "smartSubtitle": "รวมย่อหน้าแบบธรรมชาติสำหรับบทความและประโยคยาว",
      "lineLayout": "ทีละบรรทัด",
      "lineSubtitle": "เก็บบรรทัด OCR สำหรับตาราง โค้ด และข้อความสั้น",
      "resultFontSize": "ขนาดข้อความผลลัพธ์",
      "captureEditorCaption": "หลังเลือกพื้นที่ จะเปิดตัวแก้ไขลอยสำหรับทำเครื่องหมาย เลือกสี คัดลอก และบันทึก",
      "captureEditorFeatureToolbar": "แถบลอย: สี่เหลี่ยม วงรี ลูกศร ปากกา ข้อความ โมเสก และเบลอ",
      "captureEditorFeatureOutput": "ส่งออก: คัดลอก บันทึก PNG หรือบันทึกด่วนไปยัง ~/Pictures/Yamazaki",
      "captureEditorFeatureAssist": "ช่วยเหลือ: เมนูคลิกขวา ประวัติ แว่นขยาย สี HEX กด C เพื่อคัดลอกสี",
      "startCaptureEditor": "เริ่มแก้ไข",
      "copyButton": "คัดลอก",
      "translationRequiresMacOS15": "การแปลต้องใช้ macOS 15 หรือใหม่กว่า",
      "copiedScreenshot": "คัดลอกภาพหน้าจอไปยังคลิปบอร์ดแล้ว",
      "savedScreenshot": "บันทึกภาพหน้าจอแล้ว",
      "quickSavedScreenshot": "บันทึกภาพหน้าจอด่วนแล้ว",
      "style": "สไตล์",
      "color": "สี",
      "lineWidth": "ความหนาเส้น",
      "opacity": "ความทึบ",
      "undo": "เลิกทำ",
      "redo": "ทำซ้ำ",
      "copyCurrentColor": "คัดลอกสีปัจจุบัน",
      "previousImage": "ภาพก่อนหน้า",
      "nextImage": "ภาพถัดไป",
      "copyImage": "คัดลอกภาพ",
      "save": "บันทึก",
      "saveAs": "บันทึกเป็น…",
      "quickSave": "บันทึกด่วน",
      "close": "ปิด",
      "addText": "เพิ่มข้อความ",
      "ok": "ตกลง",
      "cancel": "ยกเลิก",
      "colorPickHint": "เลือกสี C"
    ]
  ]
}

final class AppDelegate: NSObject, NSApplicationDelegate {
  private var hotKeyRef: EventHotKeyRef?
  private var translateHotKeyRef: EventHotKeyRef?
  private var editorHotKeyRef: EventHotKeyRef?
  private var eventHandlerRef: EventHandlerRef?
  private var statusItem: NSStatusItem?
  private var window: NSWindow?
  private var translationWindow: NSWindow?
  private var editorWindows: [NSWindow] = []
  private var editorControllers: [CaptureEditorController] = []
  private var captureHistory: [NSImage] = []
  private var captureMenuItem: NSMenuItem?
  private var translateMenuItem: NSMenuItem?
  private var hotKey = HotKeyPreference.load()
  private var translateHotKey = HotKeyPreference.loadTranslation()
  private var editorHotKey = HotKeyPreference.loadEditor()
  private let ocrService = OCRService()
  private let settingsModel = SettingsViewModel()
  private var isRunningCapture = false
  private var isShowingPermissionAlert = false
  private let statusMenuItem = NSMenuItem(title: LocalizedText.tr(.waitingForShortcut), action: nil, keyEquivalent: "")

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)
    settingsModel.shortcutText = hotKey.displayText
    settingsModel.translationShortcutText = translateHotKey.displayText
    settingsModel.status = LocalizedText.tr(.shortcutEnabled, hotKey.displayText)
    settingsModel.uiLanguage = AppPreferences.uiLanguage
    settingsModel.startAtLogin = AppPreferences.startAtLogin
    if AppPreferences.startAtLogin || AppPreferences.autoRestart {
      LaunchAgentService.refreshLaunchAgent()
    }
    configureStatusItem()
    registerHotKey()
  }

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    showMainWindow()
    return true
  }

  func applicationWillTerminate(_ notification: Notification) {
    if let hotKeyRef {
      UnregisterEventHotKey(hotKeyRef)
    }
    if let translateHotKeyRef {
      UnregisterEventHotKey(translateHotKeyRef)
    }
    if let editorHotKeyRef {
      UnregisterEventHotKey(editorHotKeyRef)
    }
    if let eventHandlerRef {
      RemoveEventHandler(eventHandlerRef)
    }
  }

  private func configureStatusItem() {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    statusItem.button?.image = statusBarImage(named: "viewfinder")
    statusItem.button?.toolTip = "\(ProductInfo.appName) - \(LocalizedText.tr(.captureWithShortcut, hotKey.displayText))"

    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: LocalizedText.tr(.openSettings), action: #selector(openWindowFromMenu), keyEquivalent: ""))
    menu.items.last?.target = self
    menu.addItem(NSMenuItem.separator())
    let captureMenuItem = NSMenuItem(title: LocalizedText.tr(.captureWithShortcut, hotKey.displayText), action: #selector(captureSelectionFromMenu), keyEquivalent: "")
    captureMenuItem.target = self
    self.captureMenuItem = captureMenuItem
    menu.addItem(captureMenuItem)
    let translateItem = NSMenuItem(title: translationMenuTitle(), action: #selector(translateSelectionFromMenu), keyEquivalent: "")
    translateItem.target = self
    self.translateMenuItem = translateItem
    menu.addItem(translateItem)
    menu.addItem(NSMenuItem(title: LocalizedText.tr(.recognizeClipboard), action: #selector(recognizeClipboardFromMenu), keyEquivalent: ""))
    menu.items.last?.target = self
    menu.addItem(NSMenuItem.separator())
    statusMenuItem.isEnabled = false
    menu.addItem(statusMenuItem)
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: LocalizedText.tr(.quitApp, ProductInfo.appName), action: #selector(quit), keyEquivalent: "q"))
    menu.items.last?.target = self

    statusItem.menu = menu
    self.statusItem = statusItem
  }

  private func showMainWindow() {
    if let window {
      refreshSettingsModel()
      window.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
      return
    }

    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 920, height: 600),
      styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )
    window.title = ProductInfo.appName
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
    window.isMovableByWindowBackground = true
    window.backgroundColor = .clear
    window.hasShadow = true
    window.center()
    window.isReleasedWhenClosed = false
    refreshSettingsModel()
    window.contentView = NSHostingView(rootView: FreeScanSettingsView(
      model: settingsModel,
      actions: SettingsActions(
        startShortcutRecording: { [weak self] in self?.updateStatus(LocalizedText.tr(.pressNewShortcut)) },
        startTranslationShortcutRecording: { [weak self] in self?.updateStatus(LocalizedText.tr(.pressNewShortcut)) },
        setShortcut: { [weak self] shortcut in self?.setHotKey(shortcut) },
        setTranslationShortcut: { [weak self] shortcut in self?.setTranslationHotKey(shortcut) },
        invalidShortcut: { [weak self] in self?.updateStatus(LocalizedText.tr(.invalidShortcut)) },
        captureSelection: { [weak self] in self?.captureSelection() },
        translateSelection: { [weak self] in self?.captureTranslationSelection() },
        setMuteSound: { isMuted in
          AppPreferences.muteSuccessSound = isMuted
        },
        setIgnoreWatermarkText: { [weak self] isEnabled in
          AppPreferences.ignoreWatermarkText = isEnabled
          self?.settingsModel.ignoreWatermarkText = isEnabled
        },
        setStartAtLogin: { [weak self] isEnabled in
          LaunchAgentService.setStartAtLoginEnabled(isEnabled)
          self?.settingsModel.startAtLogin = isEnabled
          self?.updateStatus(LocalizedText.tr(isEnabled ? .startAtLoginEnabled : .startAtLoginDisabled))
        },
        setAutoRestart: { [weak self] isEnabled in
          LaunchAgentService.setAutoRestartEnabled(isEnabled)
          self?.settingsModel.autoRestart = isEnabled
          self?.updateStatus(LocalizedText.tr(isEnabled ? .autoRestartEnabled : .autoRestartDisabled))
        },
        setLanguageMode: { [weak self] mode in
          AppPreferences.languageMode = mode
          self?.settingsModel.languageMode = mode
          self?.updateStatus(LocalizedText.tr(.recognitionLanguageSet, mode.title))
        },
        setTranslationLanguage: { [weak self] language in
          AppPreferences.translationLanguage = language
          self?.settingsModel.translationLanguage = language
          self?.updateStatus(LocalizedText.tr(.translationLanguageSet, language.title))
        },
        setUILanguage: { [weak self] language in
          AppPreferences.uiLanguage = language
          self?.settingsModel.uiLanguage = language
          self?.refreshLocalizedChrome()
        },
        setTextDirection: { [weak self] direction in
          AppPreferences.textDirection = direction
          self?.settingsModel.textDirection = direction
          self?.updateStatus(LocalizedText.tr(.textDirectionSet, direction.title))
        },
        setResultLayout: { [weak self] layout in
          AppPreferences.resultLayout = layout
          self?.settingsModel.resultLayout = layout
          self?.updateStatus(LocalizedText.tr(.resultLayoutSet, layout.title))
        },
        setResultFontSize: { size in
          AppPreferences.resultFontSize = max(10, min(28, size))
        }
      )
    ))
    self.window = window
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  private func refreshSettingsModel() {
    settingsModel.shortcutText = hotKey.displayText
    settingsModel.translationShortcutText = translateHotKey.displayText
    settingsModel.status = statusMenuItem.title
    settingsModel.uiLanguage = AppPreferences.uiLanguage
    settingsModel.muteSuccessSound = AppPreferences.muteSuccessSound
    settingsModel.ignoreWatermarkText = AppPreferences.ignoreWatermarkText
    settingsModel.startAtLogin = AppPreferences.startAtLogin
    settingsModel.autoRestart = AppPreferences.autoRestart
    settingsModel.languageMode = AppPreferences.languageMode
    settingsModel.translationLanguage = AppPreferences.translationLanguage
    settingsModel.textDirection = AppPreferences.textDirection
    settingsModel.resultLayout = AppPreferences.resultLayout
    settingsModel.resultFontSize = AppPreferences.resultFontSize
  }

  private func refreshLocalizedChrome() {
    statusMenuItem.title = settingsModel.status
    captureMenuItem?.title = LocalizedText.tr(.captureWithShortcut, hotKey.displayText)
    translateMenuItem?.title = translationMenuTitle()
    statusItem?.button?.toolTip = "\(ProductInfo.appName) - \(LocalizedText.tr(.captureWithShortcut, hotKey.displayText))"
    if let window {
      window.title = ProductInfo.appName
    }
  }

  private func translationMenuTitle() -> String {
    LocalizedText.tr(.translateWithShortcut, translateHotKey.displayText)
  }

  private func registerHotKey() {
    if let hotKeyRef {
      UnregisterEventHotKey(hotKeyRef)
      self.hotKeyRef = nil
    }
    if let translateHotKeyRef {
      UnregisterEventHotKey(translateHotKeyRef)
      self.translateHotKeyRef = nil
    }
    if let editorHotKeyRef {
      UnregisterEventHotKey(editorHotKeyRef)
      self.editorHotKeyRef = nil
    }

    if eventHandlerRef == nil {
      var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
      let selfPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

      InstallEventHandler(
        GetApplicationEventTarget(),
        { _, event, userData in
          guard let userData else { return noErr }
          var hotKeyID = EventHotKeyID()
          GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
          )

          if hotKeyID.id == 1 {
            let appDelegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()
            DispatchQueue.main.async {
              appDelegate.captureSelection()
            }
          } else if hotKeyID.id == 2 {
            let appDelegate = Unmanaged<AppDelegate>.fromOpaque(userData).takeUnretainedValue()
            DispatchQueue.main.async {
              appDelegate.captureTranslationSelection()
            }
          }
          return noErr
        },
        1,
        &eventType,
        selfPointer,
        &eventHandlerRef
      )
    }

    let hotKeyID = EventHotKeyID(signature: fourCharacterCode("FSOC"), id: 1)
    let status = RegisterEventHotKey(
      UInt32(hotKey.keyCode),
      UInt32(hotKey.carbonModifiers),
      hotKeyID,
      GetApplicationEventTarget(),
      0,
      &hotKeyRef
    )

    if status == noErr {
      updateStatus(LocalizedText.tr(.shortcutEnabled, hotKey.displayText))
      statusItem?.button?.toolTip = "\(ProductInfo.appName) - \(LocalizedText.tr(.captureWithShortcut, hotKey.displayText))"
    } else {
      updateStatus(LocalizedText.tr(.invalidShortcut))
    }

    let translateHotKeyID = EventHotKeyID(signature: fourCharacterCode("FSTR"), id: 2)
    let translateStatus = RegisterEventHotKey(
      UInt32(translateHotKey.keyCode),
      UInt32(translateHotKey.carbonModifiers),
      translateHotKeyID,
      GetApplicationEventTarget(),
      0,
      &translateHotKeyRef
    )

    if status == noErr && translateStatus != noErr {
      updateStatus(LocalizedText.tr(.invalidShortcut))
    }

  }

  private func canRegisterHotKey(_ shortcut: HotKeyPreference, signature: String, id: UInt32) -> Bool {
    var temporaryRef: EventHotKeyRef?
    let hotKeyID = EventHotKeyID(signature: fourCharacterCode(signature), id: id)
    let status = RegisterEventHotKey(
      UInt32(shortcut.keyCode),
      UInt32(shortcut.carbonModifiers),
      hotKeyID,
      GetApplicationEventTarget(),
      0,
      &temporaryRef
    )
    if let temporaryRef {
      UnregisterEventHotKey(temporaryRef)
    }
    return status == noErr
  }

  @objc private func openWindowFromMenu() {
    showMainWindow()
  }

  private func setHotKey(_ shortcut: HotKeyPreference) {
    guard shortcut != hotKey else { return }
    guard shortcut != translateHotKey else {
      updateStatus(LocalizedText.tr(.invalidShortcut))
      return
    }
    guard canRegisterHotKey(shortcut, signature: "FSOC", id: 1) else {
      updateStatus(LocalizedText.tr(.invalidShortcut))
      return
    }
    hotKey = shortcut
    hotKey.save()
    settingsModel.shortcutText = shortcut.displayText
    captureMenuItem?.title = LocalizedText.tr(.captureWithShortcut, shortcut.displayText)
    registerHotKey()
  }

  private func setTranslationHotKey(_ shortcut: HotKeyPreference) {
    guard shortcut != translateHotKey else { return }
    guard shortcut != hotKey else {
      updateStatus(LocalizedText.tr(.invalidShortcut))
      return
    }
    guard canRegisterHotKey(shortcut, signature: "FSTR", id: 2) else {
      updateStatus(LocalizedText.tr(.invalidShortcut))
      return
    }
    translateHotKey = shortcut
    translateHotKey.saveTranslation()
    settingsModel.translationShortcutText = shortcut.displayText
    translateMenuItem?.title = translationMenuTitle()
    registerHotKey()
  }

  @objc private func captureSelectionFromMenu() {
    captureSelection()
  }

  @objc private func translateSelectionFromMenu() {
    captureTranslationSelection()
  }

  @objc private func recognizeClipboardFromMenu() {
    recognizeClipboardImage()
  }

  @objc private func quit() {
    NSApp.terminate(nil)
  }

  private func captureSelection() {
    captureScreenSelection { [weak self] image in
      self?.recognizeImageToClipboard(image)
    }
  }

  private func captureTranslationSelection() {
    captureScreenSelection { [weak self] image in
      self?.presentTranslationPreview(for: image)
    }
  }

  private func captureScreenSelection(completion: @escaping (NSImage) -> Void) {
    guard !isRunningCapture else { return }
    guard ensureScreenCapturePermission() else { return }
    isRunningCapture = true
    updateStatus(LocalizedText.tr(.captureSelection))

    DispatchQueue.global(qos: .userInitiated).async {
      let captureURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("yamazaki-capture-\(UUID().uuidString)")
        .appendingPathExtension("png")
      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
      process.arguments = ["-i", "-x", captureURL.path]

      do {
        try process.run()
        process.waitUntilExit()
      } catch {
        DispatchQueue.main.async {
          self.isRunningCapture = false
          self.updateStatus(LocalizedText.tr(.recognitionFailed, error.localizedDescription))
        }
        return
      }

      let capturedImage: NSImage?
      if process.terminationStatus == 0,
         let data = try? Data(contentsOf: captureURL) {
        capturedImage = NSImage(data: data)
      } else {
        capturedImage = nil
      }
      try? FileManager.default.removeItem(at: captureURL)

      DispatchQueue.main.async {
        self.isRunningCapture = false
        if process.terminationStatus == 0 {
          if let image = capturedImage {
            completion(image)
          } else {
            self.updateStatus(LocalizedText.tr(.noClipboardImage))
          }
        } else {
          self.updateStatus(LocalizedText.tr(.waitingForShortcut))
        }
      }
    }
  }

  private func ensureScreenCapturePermission() -> Bool {
    if CGPreflightScreenCaptureAccess() {
      return true
    }

    updateStatus(LocalizedText.tr(.needPermissionStatus))

    if !AppPreferences.didRequestScreenCapturePermission {
      AppPreferences.didRequestScreenCapturePermission = true
      if CGRequestScreenCaptureAccess() {
        return true
      }
    }

    showScreenCapturePermissionAlert()
    return false
  }

  private func showScreenCapturePermissionAlert() {
    guard !isShowingPermissionAlert else { return }
    isShowingPermissionAlert = true
    NSApp.activate(ignoringOtherApps: true)

    let alert = NSAlert()
    alert.messageText = LocalizedText.tr(.permissionTitle)
    alert.informativeText = LocalizedText.tr(.permissionMessage, ProductInfo.appName)
    alert.alertStyle = .informational
    alert.addButton(withTitle: LocalizedText.tr(.openSettings))
    alert.addButton(withTitle: LocalizedText.tr(.ok))

    let response = alert.runModal()
    isShowingPermissionAlert = false
    if response == .alertFirstButtonReturn,
       let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
      NSWorkspace.shared.open(url)
    }
  }

  private func recognizeClipboardImage() {
    guard let image = NSPasteboard.general.readObjects(forClasses: [NSImage.self])?.first as? NSImage else {
      updateStatus(LocalizedText.tr(.noClipboardImage))
      return
    }
    recognizeImageToClipboard(image)
  }

  private func recognizeImageToClipboard(_ image: NSImage) {
    updateStatus(LocalizedText.tr(.recognizingText))
    statusItem?.button?.image = statusBarImage(named: "text.viewfinder")

    Task.detached(priority: .userInitiated) {
      do {
        let text = try self.ocrService.recognizeText(in: image)
        await MainActor.run {
          if text.isEmpty {
            self.updateStatus(LocalizedText.tr(.noTextFound))
          } else {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
            self.updateStatus(LocalizedText.tr(.copiedText))
            self.playSuccessSound()
            self.flashSuccessIcon()
          }
          if text.isEmpty {
            self.statusItem?.button?.image = self.statusBarImage(named: "viewfinder")
          }
        }
      } catch {
        await MainActor.run {
          self.updateStatus(LocalizedText.tr(.recognitionFailed, error.localizedDescription))
          self.statusItem?.button?.image = self.statusBarImage(named: "exclamationmark.triangle")
        }
      }
    }
  }

  private func presentTranslationPreview(for image: NSImage) {
    if #available(macOS 15.0, *) {
      updateStatus(LocalizedText.tr(.recognizingText))
      Task.detached(priority: .userInitiated) {
        do {
          let lines = try self.ocrService.recognizePositionedText(in: image)
          await MainActor.run {
            self.showTranslationWindow(image: image, lines: lines)
            self.updateStatus(LocalizedText.tr(.translateSelection))
          }
        } catch {
          await MainActor.run {
            self.updateStatus(LocalizedText.tr(.recognitionFailed, error.localizedDescription))
          }
        }
      }
    } else {
      updateStatus(LocalizedText.tr(.translationRequiresMacOS15))
    }
  }

  @available(macOS 15.0, *)
  private func showTranslationWindow(image: NSImage, lines: [RecognizedTextLine]) {
    let imageSize = image.size.width > 0 && image.size.height > 0 ? image.size : NSSize(width: 900, height: 600)
    let maxWidth: CGFloat = 980
    let maxHeight: CGFloat = 720
    let scale = min(maxWidth / imageSize.width, maxHeight / imageSize.height, 1)
    let windowSize = NSSize(width: max(520, imageSize.width * scale), height: max(360, imageSize.height * scale))

    let window = NSWindow(
      contentRect: NSRect(origin: .zero, size: windowSize),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered,
      defer: false
    )
    window.title = LocalizedText.tr(.translateSelection)
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
    window.backgroundColor = .clear
    window.hasShadow = true
    window.center()
    window.contentView = NSHostingView(rootView: TranslationPreviewView(
      image: image,
      lines: lines,
      targetLanguage: AppPreferences.translationLanguage
    ))
    translationWindow = window
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  private func showCaptureEditor(for image: NSImage) {
    addCaptureToHistory(image)
    let editor = CaptureEditorController(
      image: image,
      historyProvider: { [weak self] in self?.captureHistory ?? [] },
      onHistoryImage: { [weak self] historyImage in
        self?.showCaptureEditor(for: historyImage)
      },
      onComplete: { [weak self] outputImage, action in
        self?.addCaptureToHistory(outputImage)
        switch action {
        case .copy:
          NSPasteboard.general.clearContents()
          NSPasteboard.general.writeObjects([outputImage])
          self?.updateStatus(LocalizedText.tr(.copiedScreenshot))
        case .save(let url):
          self?.writeImage(outputImage, to: url)
          self?.updateStatus(LocalizedText.tr(.savedScreenshot))
        case .quickSave:
          let url = CaptureEditorController.quickSaveURL()
          self?.writeImage(outputImage, to: url)
          self?.updateStatus(LocalizedText.tr(.quickSavedScreenshot))
        }
        self?.playSuccessSound()
        self?.flashSuccessIcon()
      }
    )
    let window = editor.window
    editor.onWindowClose = { [weak self, weak editor, weak window] in
      guard let self else { return }
      if let editor {
        self.editorControllers.removeAll { $0 === editor }
      }
      if let window {
        self.editorWindows.removeAll { $0 === window }
      }
    }
    editorControllers.append(editor)
    editorWindows.append(window)
    window.delegate = editor
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  private func addCaptureToHistory(_ image: NSImage) {
    captureHistory.append(image)
    if captureHistory.count > 20 {
      captureHistory.removeFirst(captureHistory.count - 20)
    }
  }

  private func writeImage(_ image: NSImage, to url: URL) {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let data = bitmap.representation(using: .png, properties: [:]) else { return }
    try? FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    try? data.write(to: url)
  }

  private func updateStatus(_ status: String) {
    statusMenuItem.title = status
    settingsModel.status = status
  }

  private func playSuccessSound() {
    guard !AppPreferences.muteSuccessSound else { return }
    let candidates = [
      "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/Shutter.aif",
      "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/Screen Capture.aif",
      "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/Grab.aif"
    ]
    let sound = candidates.lazy.compactMap { path in
      NSSound(contentsOfFile: path, byReference: true)
    }.first ?? NSSound(named: NSSound.Name("Pop"))
    guard let sound else { return }
    sound.volume = 0.36
    sound.play()
  }

  private func flashSuccessIcon() {
    statusItem?.button?.image = statusBarImage(named: "checkmark.circle")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
      self.statusItem?.button?.image = self.statusBarImage(named: "viewfinder")
    }
  }

  private func statusBarImage(named symbolName: String) -> NSImage? {
    let fallback = "viewfinder"
    let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: ProductInfo.appName)
      ?? NSImage(systemSymbolName: fallback, accessibilityDescription: ProductInfo.appName)
    image?.isTemplate = true
    return image
  }

}

final class SettingsViewModel: ObservableObject {
  @Published var shortcutText: String = HotKeyPreference.load().displayText
  @Published var translationShortcutText: String = HotKeyPreference.loadTranslation().displayText
  @Published var status: String = LocalizedText.tr(.waitingForShortcut)
  @Published var muteSuccessSound: Bool = AppPreferences.muteSuccessSound
  @Published var ignoreWatermarkText: Bool = AppPreferences.ignoreWatermarkText
  @Published var startAtLogin: Bool = AppPreferences.startAtLogin
  @Published var autoRestart: Bool = AppPreferences.autoRestart
  @Published var uiLanguage: AppPreferences.UILanguage = AppPreferences.uiLanguage
  @Published var languageMode: AppPreferences.LanguageMode = AppPreferences.languageMode
  @Published var translationLanguage: AppPreferences.TranslationLanguage = AppPreferences.translationLanguage
  @Published var textDirection: AppPreferences.TextDirection = AppPreferences.textDirection
  @Published var resultLayout: AppPreferences.ResultLayout = AppPreferences.resultLayout
  @Published var resultFontSize: Int = AppPreferences.resultFontSize
}

struct SettingsActions {
  let startShortcutRecording: () -> Void
  let startTranslationShortcutRecording: () -> Void
  let setShortcut: (HotKeyPreference) -> Void
  let setTranslationShortcut: (HotKeyPreference) -> Void
  let invalidShortcut: () -> Void
  let captureSelection: () -> Void
  let translateSelection: () -> Void
  let setMuteSound: (Bool) -> Void
  let setIgnoreWatermarkText: (Bool) -> Void
  let setStartAtLogin: (Bool) -> Void
  let setAutoRestart: (Bool) -> Void
  let setLanguageMode: (AppPreferences.LanguageMode) -> Void
  let setTranslationLanguage: (AppPreferences.TranslationLanguage) -> Void
  let setUILanguage: (AppPreferences.UILanguage) -> Void
  let setTextDirection: (AppPreferences.TextDirection) -> Void
  let setResultLayout: (AppPreferences.ResultLayout) -> Void
  let setResultFontSize: (Int) -> Void
}

struct FreeScanSettingsView: View {
  @ObservedObject var model: SettingsViewModel
  let actions: SettingsActions
  @State private var selectedSection: SettingsSection = .general
  @State private var isRecordingShortcut = false
  @State private var isRecordingTranslationShortcut = false
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    ZStack {
      LiquidWindowBackground()

      VStack(alignment: .leading, spacing: 18) {
        header

        HStack(alignment: .top, spacing: 16) {
          settingsSidebar
          content
        }
      }
      .padding(.horizontal, 32)
      .padding(.top, 30)
      .padding(.bottom, 28)
    }
    .frame(width: 920, height: 600)
    .foregroundStyle(.primary)
  }

  private var header: some View {
    HStack {
      VStack(alignment: .leading, spacing: 7) {
        Text(LocalizedText.tr(.appSettings, ProductInfo.appName))
          .font(.system(size: 29, weight: .bold))
        Text(LocalizedText.tr(.subtitle, model.shortcutText))
          .font(.system(size: 14, weight: .regular))
          .foregroundStyle(.secondary)
      }
      Spacer()
    }
  }

  private var settingsSidebar: some View {
    VStack(alignment: .leading, spacing: 7) {
      ForEach(SettingsSection.allCases, id: \.self) { section in
        Button {
          let selection = {
            selectedSection = section
          }
          if reduceMotion {
            selection()
          } else {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
              selection()
            }
          }
        } label: {
          HStack(spacing: 10) {
            Image(systemName: section.symbolName)
              .font(.system(size: 13, weight: .semibold))
              .frame(width: 18)
            Text(section.title)
              .font(.system(size: 14, weight: selectedSection == section ? .semibold : .medium))
              .lineLimit(1)
              .minimumScaleFactor(0.82)
            Spacer(minLength: 0)
          }
          .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
          .padding(.horizontal, 12)
          .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(SettingsSidebarButtonStyle(isSelected: selectedSection == section))
        .focusable(false)
      }

      Spacer(minLength: 0)
    }
    .padding(8)
    .frame(width: 190)
    .frame(maxHeight: .infinity, alignment: .topLeading)
    .liquidGlass(cornerRadius: 26, shadow: .soft)
  }

  @ViewBuilder
  private var content: some View {
    Group {
      switch selectedSection {
      case .general:
        GeneralSettingsPane(model: model, actions: actions)
      case .hotKey:
        HotKeySettingsPane(
          model: model,
          isRecordingShortcut: $isRecordingShortcut,
          isRecordingTranslationShortcut: $isRecordingTranslationShortcut,
          actions: actions
        )
      case .textDirection:
        TextDirectionPane(model: model, actions: actions)
      case .resultLayout:
        ResultLayoutPane(model: model, actions: actions)
      }
    }
    .id(selectedSection)
    .transition(.asymmetric(
      insertion: .opacity.combined(with: .move(edge: .bottom)).combined(with: .scale(scale: 0.985)),
      removal: .opacity.combined(with: .move(edge: .top))
    ))
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .padding(22)
    .liquidGlass(cornerRadius: 30, shadow: .deep)
    .animation(reduceMotion ? nil : .spring(response: 0.36, dampingFraction: 0.86), value: selectedSection)
  }
}

struct GeneralSettingsPane: View {
  @ObservedObject var model: SettingsViewModel
  let actions: SettingsActions

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(alignment: .leading, spacing: 14) {
        VStack(alignment: .leading, spacing: 14) {
          Text(LocalizedText.tr(.languagePrivacy))
            .font(.system(size: 16, weight: .bold))

          SettingsPickerRow(title: LocalizedText.tr(.uiLanguage)) {
            Picker("", selection: Binding(
              get: { model.uiLanguage },
              set: { language in
                model.uiLanguage = language
                actions.setUILanguage(language)
              }
            )) {
              ForEach(AppPreferences.UILanguage.allCases, id: \.self) { language in
                Text(language.title).tag(language)
              }
          }
            .labelsHidden()
            .frame(width: 300, alignment: .leading)
            .focusable(false)
          }

          SettingsPickerRow(title: LocalizedText.tr(.recognitionLanguage)) {
            Picker("", selection: Binding(
              get: { model.languageMode },
              set: { mode in
                withAnimation(.easeOut(duration: 0.18)) {
                  model.languageMode = mode
                }
                actions.setLanguageMode(mode)
              }
            )) {
              ForEach(AppPreferences.LanguageMode.allCases, id: \.self) { mode in
                Text(mode.title).tag(mode)
              }
            }
            .labelsHidden()
            .frame(width: 300, alignment: .leading)
            .focusable(false)
          }

          SettingsPickerRow(title: LocalizedText.tr(.translationLanguage)) {
            Picker("", selection: Binding(
              get: { model.translationLanguage },
              set: { language in
                model.translationLanguage = language
                actions.setTranslationLanguage(language)
              }
            )) {
              ForEach(AppPreferences.TranslationLanguage.allCases, id: \.self) { language in
                Text(language.title).tag(language)
              }
            }
            .labelsHidden()
            .frame(width: 300, alignment: .leading)
            .focusable(false)
          }

          Text("\(LocalizedText.tr(.languageNote)) \(LocalizedText.tr(.translationPrivacyCaption))")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(cornerRadius: 22, shadow: .soft)

        VStack(alignment: .leading, spacing: 12) {
          Text(LocalizedText.tr(.behavior))
            .font(.system(size: 16, weight: .bold))

          Toggle(isOn: Binding(
            get: { model.muteSuccessSound },
            set: { value in
              model.muteSuccessSound = value
              actions.setMuteSound(value)
            }
          )) {
            BehaviorToggleLabel(
              title: LocalizedText.tr(.muteSuccessSound),
              systemImage: "speaker.slash"
            )
          }
          .toggleStyle(.checkbox)
          .focusable(false)

          Toggle(isOn: Binding(
            get: { model.ignoreWatermarkText },
            set: { value in
              model.ignoreWatermarkText = value
              actions.setIgnoreWatermarkText(value)
            }
          )) {
            BehaviorToggleLabel(
              title: LocalizedText.tr(.ignoreWatermarkText),
              caption: LocalizedText.tr(.ignoreWatermarkCaption),
              systemImage: "eye.slash"
            )
          }
          .toggleStyle(.checkbox)
          .focusable(false)

          Toggle(isOn: Binding(
            get: { model.startAtLogin },
            set: { value in
              model.startAtLogin = value
              actions.setStartAtLogin(value)
            }
          )) {
            BehaviorToggleLabel(
              title: LocalizedText.tr(.startAtLogin),
              caption: LocalizedText.tr(.startAtLoginCaption),
              systemImage: "power"
            )
          }
          .toggleStyle(.checkbox)
          .focusable(false)

          Toggle(isOn: Binding(
            get: { model.autoRestart },
            set: { value in
              model.autoRestart = value
              actions.setAutoRestart(value)
            }
          )) {
            BehaviorToggleLabel(
              title: LocalizedText.tr(.autoRestart),
              caption: LocalizedText.tr(.autoRestartCaption),
              systemImage: "arrow.clockwise.circle"
            )
          }
          .toggleStyle(.checkbox)
          .focusable(false)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(cornerRadius: 22, shadow: .none)

        Spacer(minLength: 0)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

struct BehaviorToggleLabel: View {
  let title: String
  var caption: String?
  let systemImage: String

  var body: some View {
    HStack(alignment: caption == nil ? .center : .top, spacing: 10) {
      Image(systemName: systemImage)
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(.secondary)
        .frame(width: 22, height: 20, alignment: .center)
        .padding(.top, caption == nil ? 0 : 1)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.system(size: 14, weight: .semibold))
          .lineLimit(1)
          .fixedSize(horizontal: true, vertical: false)

        if let caption {
          Text(caption)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
    }
  }
}

struct SettingsPickerRow<Content: View>: View {
  let title: String
  let content: Content

  init(title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  var body: some View {
    HStack(spacing: 16) {
      Text(title)
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(.primary)
        .frame(width: 152, alignment: .leading)
      content
        .frame(width: 300, alignment: .leading)
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct HotKeySettingsPane: View {
  @ObservedObject var model: SettingsViewModel
  @Binding var isRecordingShortcut: Bool
  @Binding var isRecordingTranslationShortcut: Bool
  let actions: SettingsActions

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 5) {
        Text(LocalizedText.tr(.hotKey))
          .font(.system(size: 17, weight: .bold))
        Text(LocalizedText.tr(.shortcutConflictHint))
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding(.bottom, 4)

      VStack(spacing: 10) {
        ShortcutSettingCard(
          title: LocalizedText.tr(.captureSelection),
          shortcutText: model.shortcutText,
          isRecording: $isRecordingShortcut,
          iconName: "viewfinder",
          startRecording: actions.startShortcutRecording,
          onShortcut: actions.setShortcut,
          onInvalidShortcut: actions.invalidShortcut,
          testAction: actions.captureSelection
        )

        ShortcutSettingCard(
          title: LocalizedText.tr(.translateSelection),
          shortcutText: model.translationShortcutText,
          isRecording: $isRecordingTranslationShortcut,
          iconName: "translate",
          startRecording: actions.startTranslationShortcutRecording,
          onShortcut: actions.setTranslationShortcut,
          onInvalidShortcut: actions.invalidShortcut,
          testAction: actions.translateSelection
        )
      }

      Text(LocalizedText.tr(.successCaption))
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(.secondary)
        .padding(.top, 2)

      Spacer()
    }
  }
}

struct ShortcutSettingCard: View {
  let title: String
  let shortcutText: String
  @Binding var isRecording: Bool
  let iconName: String
  let startRecording: () -> Void
  let onShortcut: (HotKeyPreference) -> Void
  let onInvalidShortcut: () -> Void
  let testAction: () -> Void

  var body: some View {
    ZStack(alignment: .leading) {
      HStack(spacing: 12) {
        Image(systemName: iconName)
          .font(.system(size: 17, weight: .semibold))
          .foregroundStyle(.blue)
          .frame(width: 36, height: 36)
          .liquidGlass(cornerRadius: 13, shadow: .none)

        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(.system(size: 14, weight: .semibold))
            .lineLimit(1)

          Text(isRecording ? LocalizedText.tr(.shortcutHintRecording) : " ")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }

        Spacer(minLength: 8)

        Text(shortcutText)
          .font(.system(size: 22, weight: .semibold, design: .monospaced))
          .foregroundStyle(.primary)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
          .frame(width: 86, height: 38)
          .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
          .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
              .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
          )

        Button {
          isRecording = true
          startRecording()
        } label: {
          Label(LocalizedText.tr(.setShortcut), systemImage: "keyboard")
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(LiquidActionButtonStyle(prominent: false))
        .frame(width: 126)

        Button {
          testAction()
        } label: {
          Label(title, systemImage: iconName)
            .lineLimit(1)
            .minimumScaleFactor(0.76)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(LiquidActionButtonStyle(prominent: true))
        .frame(width: 126)
      }
      .padding(.horizontal, 14)
      .frame(height: 74)
      .liquidGlass(cornerRadius: 20, shadow: .none)

      ShortcutRecorderRepresentable(
        isRecording: $isRecording,
        onShortcut: onShortcut,
        onInvalidShortcut: onInvalidShortcut
      )
      .frame(width: 1, height: 1)
      .opacity(0.01)
      .accessibilityHidden(true)
    }
  }
}

struct TextDirectionPane: View {
  @ObservedObject var model: SettingsViewModel
  let actions: SettingsActions

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      OptionGlassCard(
        title: LocalizedText.tr(.horizontalScan),
        subtitle: LocalizedText.tr(.horizontalSubtitle),
        systemImage: "text.alignleft",
        isSelected: model.textDirection == .horizontal
      ) {
        model.textDirection = .horizontal
        actions.setTextDirection(.horizontal)
      }

      OptionGlassCard(
        title: LocalizedText.tr(.verticalScan),
        subtitle: LocalizedText.tr(.verticalSubtitle),
        systemImage: "textformat.abc.dottedunderline",
        isSelected: model.textDirection == .vertical
      ) {
        model.textDirection = .vertical
        actions.setTextDirection(.vertical)
      }

      Spacer()
    }
  }
}

struct ResultLayoutPane: View {
  @ObservedObject var model: SettingsViewModel
  let actions: SettingsActions

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      OptionGlassCard(
        title: LocalizedText.tr(.smartLayout),
        subtitle: LocalizedText.tr(.smartSubtitle),
        systemImage: "text.word.spacing",
        isSelected: model.resultLayout == .smart
      ) {
        model.resultLayout = .smart
        actions.setResultLayout(.smart)
      }

      OptionGlassCard(
        title: LocalizedText.tr(.lineLayout),
        subtitle: LocalizedText.tr(.lineSubtitle),
        systemImage: "list.bullet.rectangle",
        isSelected: model.resultLayout == .lines
      ) {
        model.resultLayout = .lines
        actions.setResultLayout(.lines)
      }

      HStack(spacing: 18) {
        Text(LocalizedText.tr(.resultFontSize))
          .font(.system(size: 15, weight: .semibold))
        Stepper(value: Binding(
          get: { model.resultFontSize },
          set: { value in
            model.resultFontSize = value
            actions.setResultFontSize(value)
          }
        ), in: 10...28) {
          Text("\(model.resultFontSize)")
            .font(.system(size: 15, weight: .semibold))
            .frame(width: 36)
        }
        .frame(width: 132)
      }
      .padding(.top, 8)

      Spacer()
    }
  }
}

struct OptionGlassCard: View {
  let title: String
  let subtitle: String
  let systemImage: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 15) {
        Image(systemName: systemImage)
          .font(.system(size: 21, weight: .semibold))
          .foregroundStyle(isSelected ? .white : .blue)
          .frame(width: 38, height: 38)
          .background(isSelected ? Color.white.opacity(0.18) : Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

        VStack(alignment: .leading, spacing: 5) {
          Text(title)
            .font(.system(size: 16, weight: .semibold))
          Text(subtitle)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(isSelected ? .white.opacity(0.82) : .secondary)
        }

        Spacer()
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 18, weight: .semibold))
          .foregroundStyle(isSelected ? .white : .secondary)
      }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
    .buttonStyle(OptionGlassButtonStyle(isSelected: isSelected))
    .focusable(false)
  }
}

struct ShortcutRecorderRepresentable: NSViewRepresentable {
  @Binding var isRecording: Bool
  let onShortcut: (HotKeyPreference) -> Void
  let onInvalidShortcut: () -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  func makeNSView(context: Context) -> ShortcutRecorderView {
    let view = ShortcutRecorderView()
    view.onShortcut = { shortcut in
      context.coordinator.parent.isRecording = false
      context.coordinator.parent.onShortcut(shortcut)
    }
    view.onInvalidShortcut = {
      context.coordinator.parent.onInvalidShortcut()
    }
    return view
  }

  func updateNSView(_ nsView: ShortcutRecorderView, context: Context) {
    context.coordinator.parent = self
    if isRecording && !context.coordinator.didStartRecording {
      context.coordinator.didStartRecording = true
      DispatchQueue.main.async {
        nsView.beginRecording()
      }
    } else if !isRecording {
      context.coordinator.didStartRecording = false
    }
  }

  final class Coordinator {
    var parent: ShortcutRecorderRepresentable
    var didStartRecording = false

    init(parent: ShortcutRecorderRepresentable) {
      self.parent = parent
    }
  }
}

struct LiquidWindowBackground: View {
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    Rectangle()
      .fill(.ultraThinMaterial)
      .overlay(
        LinearGradient(
          colors: [
            Color.white.opacity(colorScheme == .dark ? 0.08 : 0.24),
            Color.accentColor.opacity(colorScheme == .dark ? 0.10 : 0.07),
            Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.02)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .overlay(
        LinearGradient(
          colors: [Color.white.opacity(colorScheme == .dark ? 0.08 : 0.20), .clear],
          startPoint: .top,
          endPoint: .center
        )
        .blendMode(.plusLighter)
      )
      .ignoresSafeArea()
  }
}

enum LiquidShadow {
  case none
  case soft
  case deep
}

struct LiquidGlassModifier: ViewModifier {
  let cornerRadius: CGFloat
  let shadow: LiquidShadow

  func body(content: Content) -> some View {
    content
      .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .strokeBorder(
            LinearGradient(
              colors: [Color.white.opacity(0.46), Color.white.opacity(0.14), Color.black.opacity(0.06)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 1
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .fill(
            LinearGradient(
              colors: [Color.white.opacity(0.16), Color.white.opacity(0.015)],
              startPoint: .top,
              endPoint: .center
            )
          )
          .blendMode(.plusLighter)
          .allowsHitTesting(false)
      )
      .shadow(color: .black.opacity(shadow == .deep ? 0.12 : shadow == .soft ? 0.06 : 0), radius: shadow == .deep ? 24 : 12, x: 0, y: shadow == .deep ? 12 : 6)
  }
}

extension View {
  func liquidGlass(cornerRadius: CGFloat, shadow: LiquidShadow) -> some View {
    modifier(LiquidGlassModifier(cornerRadius: cornerRadius, shadow: shadow))
  }
}

struct SettingsSidebarButtonStyle: ButtonStyle {
  let isSelected: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(0.86))
      .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(isSelected ? Color.accentColor.opacity(0.84) : Color.white.opacity(configuration.isPressed ? 0.14 : 0.001))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .strokeBorder(isSelected ? Color.white.opacity(0.34) : Color.white.opacity(0.10), lineWidth: 1)
      )
      .shadow(color: isSelected ? Color.accentColor.opacity(0.20) : .clear, radius: 10, x: 0, y: 5)
      .scaleEffect(configuration.isPressed ? 0.98 : 1)
      .animation(.spring(response: 0.24, dampingFraction: 0.72), value: configuration.isPressed)
      .animation(.spring(response: 0.32, dampingFraction: 0.82), value: isSelected)
  }
}

struct LiquidActionButtonStyle: ButtonStyle {
  let prominent: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 14, weight: .semibold))
      .foregroundStyle(prominent ? .white : .primary)
      .padding(.horizontal, 18)
      .frame(height: 40)
      .background(
        Capsule()
          .fill(prominent ? Color.accentColor.opacity(0.86) : Color.white.opacity(0.10))
      )
      .background(.ultraThinMaterial, in: Capsule())
      .overlay(Capsule().strokeBorder(Color.white.opacity(prominent ? 0.36 : 0.22), lineWidth: 1))
      .shadow(color: prominent ? Color.accentColor.opacity(0.20) : Color.black.opacity(0.05), radius: prominent ? 12 : 8, x: 0, y: 6)
      .scaleEffect(configuration.isPressed ? 0.96 : 1)
      .animation(.spring(response: 0.24, dampingFraction: 0.7), value: configuration.isPressed)
  }
}

struct OptionGlassButtonStyle: ButtonStyle {
  let isSelected: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundStyle(isSelected ? .white : .primary)
      .background(
        RoundedRectangle(cornerRadius: 22, style: .continuous)
          .fill(isSelected ? Color.accentColor.opacity(0.88) : Color.white.opacity(0.08))
      )
      .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 22, style: .continuous)
          .strokeBorder(Color.white.opacity(isSelected ? 0.42 : 0.2), lineWidth: 1)
      )
      .shadow(color: isSelected ? Color.accentColor.opacity(0.22) : Color.black.opacity(0.06), radius: isSelected ? 18 : 10, x: 0, y: isSelected ? 9 : 5)
      .scaleEffect(configuration.isPressed ? 0.985 : 1)
      .animation(.spring(response: 0.24, dampingFraction: 0.78), value: configuration.isPressed)
      .animation(.spring(response: 0.34, dampingFraction: 0.84), value: isSelected)
  }
}

@available(macOS 15.0, *)
struct TranslationPreviewView: View {
  let image: NSImage
  let lines: [RecognizedTextLine]
  let targetLanguage: AppPreferences.TranslationLanguage

  @State private var translatedLines: [UUID: String] = [:]
  @State private var errorMessage: String?
  @State private var configuration: TranslationSession.Configuration?

  init(image: NSImage, lines: [RecognizedTextLine], targetLanguage: AppPreferences.TranslationLanguage) {
    self.image = image
    self.lines = lines
    self.targetLanguage = targetLanguage
    _configuration = State(initialValue: TranslationSession.Configuration(
      source: nil,
      target: targetLanguage.localeLanguage
    ))
  }

  var body: some View {
    ZStack(alignment: .topLeading) {
      Color.black.opacity(0.72).ignoresSafeArea()

      GeometryReader { geometry in
        let imageRect = fittedImageRect(container: geometry.size, imageSize: image.size)

        Image(nsImage: image)
          .resizable()
          .scaledToFit()
          .frame(width: geometry.size.width, height: geometry.size.height)
          .opacity(0.56)

        ForEach(lines) { line in
          let rect = overlayRect(for: line.box, in: imageRect)
          TranslationLineOverlay(
            text: translatedLines[line.id] ?? line.text,
            rect: rect
          )
        }
      }

      HStack(spacing: 10) {
        Label(targetLanguage.title, systemImage: "translate")
        if translatedLines.count < lines.count && errorMessage == nil {
          ProgressView()
            .controlSize(.small)
        }
        Spacer()
        Button {
          copyTranslatedText()
        } label: {
          Label(LocalizedText.tr(.copyButton), systemImage: "doc.on.doc")
        }
        .buttonStyle(.borderedProminent)
      }
      .font(.system(size: 13, weight: .semibold))
      .padding(12)
      .background(.ultraThinMaterial, in: Capsule())
      .padding(16)

      if let errorMessage {
        Text(errorMessage)
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(.white)
          .padding(12)
          .background(.red.opacity(0.78), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
          .padding(16)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
      }
    }
    .translationTask(configuration) { session in
      await translateLines(session)
    }
  }

  private func translateLines(_ session: TranslationSession) async {
    guard !lines.isEmpty else { return }
    do {
      for line in lines {
        let response = try await session.translate(line.text)
        await MainActor.run {
          translatedLines[line.id] = response.targetText
        }
      }
    } catch {
      await MainActor.run {
        errorMessage = error.localizedDescription
      }
    }
  }

  private func copyTranslatedText() {
    let text = lines.map { line in
      translatedLines[line.id] ?? line.text
    }.joined(separator: "\n")
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(text, forType: .string)
  }

  private func fittedImageRect(container: CGSize, imageSize: CGSize) -> CGRect {
    guard imageSize.width > 0, imageSize.height > 0 else {
      return CGRect(origin: .zero, size: container)
    }
    let scale = min(container.width / imageSize.width, container.height / imageSize.height)
    let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    return CGRect(
      x: (container.width - size.width) / 2,
      y: (container.height - size.height) / 2,
      width: size.width,
      height: size.height
    )
  }

  private func overlayRect(for box: CGRect, in imageRect: CGRect) -> CGRect {
    let x = imageRect.minX + box.minX * imageRect.width
    let y = imageRect.minY + (1 - box.maxY) * imageRect.height
    let width = box.width * imageRect.width
    let height = max(18, box.height * imageRect.height * 1.55)
    return CGRect(x: x, y: y, width: width, height: height)
  }
}

@available(macOS 15.0, *)
struct TranslationLineOverlay: View {
  let text: String
  let rect: CGRect

  var body: some View {
    let fontSize = max(10, min(22, rect.height * 0.74))
    Text(text)
      .font(.system(size: fontSize, weight: .semibold))
      .foregroundStyle(.white)
      .lineLimit(3)
      .minimumScaleFactor(0.5)
      .padding(.horizontal, 5)
      .padding(.vertical, 3)
      .frame(width: max(40, rect.width), height: max(18, rect.height), alignment: .leading)
      .background(.black.opacity(0.58), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
      .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(.white.opacity(0.18), lineWidth: 1))
      .position(x: rect.midX, y: rect.midY)
  }
}

enum CaptureEditorSaveAction {
  case copy
  case save(URL)
  case quickSave
}

enum CaptureEditorTool: String, CaseIterable {
  case pointer = "指针"
  case rectangle = "矩形"
  case ellipse = "椭圆"
  case arrow = "箭头"
  case pen = "画笔"
  case text = "文字"
  case mosaic = "马赛克"
  case blur = "模糊"

  var symbolName: String {
    switch self {
    case .pointer: return "cursorarrow"
    case .rectangle: return "rectangle"
    case .ellipse: return "circle"
    case .arrow: return "arrow.up.right"
    case .pen: return "pencil.tip"
    case .text: return "textformat"
    case .mosaic: return "checkerboard.rectangle"
    case .blur: return "drop"
    }
  }

  var title: String {
    switch self {
    case .pointer: return LocalizedText.tr(.pointerTool)
    case .rectangle: return LocalizedText.tr(.rectangleTool)
    case .ellipse: return LocalizedText.tr(.ellipseTool)
    case .arrow: return LocalizedText.tr(.arrowTool)
    case .pen: return LocalizedText.tr(.penTool)
    case .text: return LocalizedText.tr(.textTool)
    case .mosaic: return LocalizedText.tr(.mosaicTool)
    case .blur: return LocalizedText.tr(.blurTool)
    }
  }
}

struct CaptureAnnotation {
  enum Kind {
    case rectangle
    case ellipse
    case arrow
    case pen
    case text(String)
    case mosaic
    case blur
  }

  var kind: Kind
  var rect: CGRect
  var points: [CGPoint]
  var color: NSColor
  var lineWidth: CGFloat
  var alpha: CGFloat
}

final class CaptureEditorController: NSObject, NSWindowDelegate {
  let window: NSWindow
  var onWindowClose: (() -> Void)?
  private let canvas: CaptureCanvasView
  private var toolButtons: [CaptureEditorTool: NSButton] = [:]
  private var stylePopover: NSPopover?
  private let paletteColors: [NSColor] = [
    .systemBlue,
    .systemRed,
    .systemOrange,
    .systemYellow,
    .systemGreen,
    .systemMint,
    .systemPurple,
    .white,
    .black
  ]
  private var historyIndex: Int
  private let historyProvider: () -> [NSImage]
  private let onHistoryImage: (NSImage) -> Void
  private let onComplete: (NSImage, CaptureEditorSaveAction) -> Void

  init(
    image: NSImage,
    historyProvider: @escaping () -> [NSImage],
    onHistoryImage: @escaping (NSImage) -> Void,
    onComplete: @escaping (NSImage, CaptureEditorSaveAction) -> Void
  ) {
    self.historyProvider = historyProvider
    self.onHistoryImage = onHistoryImage
    self.onComplete = onComplete
    self.historyIndex = max(0, historyProvider().count - 1)
    self.canvas = CaptureCanvasView(image: image)

    let visibleFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1280, height: 800)
    let canvasSize = canvas.canvasSize(fitting: NSSize(width: visibleFrame.width - 96, height: visibleFrame.height - 150))
    let windowSize = NSSize(width: max(520, canvasSize.width + 48), height: max(320, canvasSize.height + 94))
    self.window = NSWindow(
      contentRect: NSRect(origin: .zero, size: windowSize),
      styleMask: [.borderless, .resizable],
      backing: .buffered,
      defer: false
    )
    super.init()
    canvas.frame = NSRect(origin: .zero, size: canvasSize)
    canvas.onCopy = { [weak self] in self?.copyImage() }
    canvas.onSave = { [weak self] in self?.saveImage() }
    canvas.onQuickSave = { [weak self] in self?.quickSaveImage() }
    canvas.onClose = { [weak self] in self?.closeEditor() }

    window.title = "Yamazaki Screenshot"
    window.isOpaque = false
    window.backgroundColor = .clear
    window.hasShadow = false
    window.level = .floating
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    window.isMovableByWindowBackground = false
    window.center()
    window.minSize = NSSize(width: 460, height: 300)
    window.contentView = makeContentView()
  }

  func windowWillClose(_ notification: Notification) {
    onWindowClose?()
  }

  static func quickSaveURL() -> URL {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd-HHmmss"
    return FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent("Pictures/Yamazaki")
      .appendingPathComponent("Yamazaki-\(formatter.string(from: Date())).png")
  }

  private func makeContentView() -> NSView {
    let root = NSView()
    root.wantsLayer = true
    root.layer?.backgroundColor = NSColor.clear.cgColor

    let toolbar = makeFloatingToolbar()
    let toolbarContainer = NSView()
    toolbarContainer.translatesAutoresizingMaskIntoConstraints = false
    toolbar.translatesAutoresizingMaskIntoConstraints = false
    toolbarContainer.addSubview(toolbar)

    canvas.translatesAutoresizingMaskIntoConstraints = false

    root.addSubview(canvas)
    root.addSubview(toolbarContainer)
    NSLayoutConstraint.activate([
      canvas.centerXAnchor.constraint(equalTo: root.centerXAnchor),
      canvas.topAnchor.constraint(equalTo: root.topAnchor, constant: 18),
      canvas.widthAnchor.constraint(equalToConstant: canvas.frame.width),
      canvas.heightAnchor.constraint(equalToConstant: canvas.frame.height),

      toolbarContainer.centerXAnchor.constraint(equalTo: root.centerXAnchor),
      toolbarContainer.topAnchor.constraint(equalTo: canvas.bottomAnchor, constant: 10),
      toolbarContainer.bottomAnchor.constraint(lessThanOrEqualTo: root.bottomAnchor, constant: -8),
      toolbar.leadingAnchor.constraint(equalTo: toolbarContainer.leadingAnchor),
      toolbar.trailingAnchor.constraint(equalTo: toolbarContainer.trailingAnchor),
      toolbar.topAnchor.constraint(equalTo: toolbarContainer.topAnchor),
      toolbar.bottomAnchor.constraint(equalTo: toolbarContainer.bottomAnchor)
    ])
    return root
  }

  private func makeFloatingToolbar() -> NSView {
    let toolbar = NSVisualEffectView()
    toolbar.material = .hudWindow
    toolbar.blendingMode = .withinWindow
    toolbar.state = .active
    toolbar.wantsLayer = true
    toolbar.layer?.cornerRadius = 15
    toolbar.layer?.cornerCurve = .continuous
    toolbar.layer?.borderWidth = 1
    toolbar.layer?.borderColor = NSColor.white.withAlphaComponent(0.24).cgColor

    let stack = NSStackView()
    stack.orientation = .horizontal
    stack.spacing = 4
    stack.alignment = .centerY
    stack.edgeInsets = NSEdgeInsets(top: 7, left: 9, bottom: 7, right: 9)
    stack.translatesAutoresizingMaskIntoConstraints = false
    toolbar.addSubview(stack)

    for tool in CaptureEditorTool.allCases {
      let button = toolButton(tool: tool)
      button.identifier = NSUserInterfaceItemIdentifier(tool.rawValue)
      toolButtons[tool] = button
      stack.addArrangedSubview(button)
    }

    stack.addArrangedSubview(separator())
    stack.addArrangedSubview(iconButton(symbolName: "slider.horizontal.3", tooltip: LocalizedText.tr(.style), action: #selector(showStylePopover(_:)), isProminent: true))

    stack.addArrangedSubview(separator())
    stack.addArrangedSubview(iconButton(symbolName: "arrow.uturn.backward", tooltip: LocalizedText.tr(.undo), action: #selector(undo)))
    stack.addArrangedSubview(iconButton(symbolName: "arrow.uturn.forward", tooltip: LocalizedText.tr(.redo), action: #selector(redo)))
    stack.addArrangedSubview(iconButton(symbolName: "eyedropper", tooltip: LocalizedText.tr(.copyCurrentColor), action: #selector(copyColor)))
    stack.addArrangedSubview(iconButton(symbolName: "chevron.left", tooltip: LocalizedText.tr(.previousImage), action: #selector(previousHistory)))
    stack.addArrangedSubview(iconButton(symbolName: "chevron.right", tooltip: LocalizedText.tr(.nextImage), action: #selector(nextHistory)))
    stack.addArrangedSubview(separator())
    stack.addArrangedSubview(iconButton(symbolName: "doc.on.doc", tooltip: LocalizedText.tr(.copyImage), action: #selector(copyImage), isProminent: true))
    stack.addArrangedSubview(iconButton(symbolName: "square.and.arrow.down", tooltip: LocalizedText.tr(.save), action: #selector(saveImage)))
    stack.addArrangedSubview(iconButton(symbolName: "tray.and.arrow.down", tooltip: LocalizedText.tr(.quickSave), action: #selector(quickSaveImage)))
    stack.addArrangedSubview(iconButton(symbolName: "xmark", tooltip: LocalizedText.tr(.close), action: #selector(closeEditor)))

    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
      stack.topAnchor.constraint(equalTo: toolbar.topAnchor),
      stack.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor)
    ])
    updateToolSelection()
    return toolbar
  }

  private func makeStylePopoverContent() -> NSView {
    let root = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 286, height: 174))
    root.material = .popover
    root.blendingMode = .withinWindow
    root.state = .active
    root.wantsLayer = true
    root.layer?.cornerRadius = 16
    root.layer?.cornerCurve = .continuous

    let stack = NSStackView()
    stack.orientation = .vertical
    stack.alignment = .leading
    stack.spacing = 12
    stack.edgeInsets = NSEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
    stack.translatesAutoresizingMaskIntoConstraints = false
    root.addSubview(stack)

    let title = NSTextField(labelWithString: LocalizedText.tr(.style))
    title.font = .systemFont(ofSize: 13, weight: .semibold)
    title.textColor = .labelColor
    stack.addArrangedSubview(title)

    let colorRow = NSStackView()
    colorRow.orientation = .horizontal
    colorRow.alignment = .centerY
    colorRow.spacing = 8
    colorRow.addArrangedSubview(rowLabel(LocalizedText.tr(.color)))

    let colorWell = NSColorWell()
    colorWell.color = canvas.strokeColor
    colorWell.target = self
    colorWell.action = #selector(changeColor(_:))
    colorWell.controlSize = .small
    colorWell.widthAnchor.constraint(equalToConstant: 34).isActive = true
    colorRow.addArrangedSubview(colorWell)

    for (index, color) in paletteColors.enumerated() {
      let button = NSButton(title: "", target: self, action: #selector(selectPaletteColor(_:)))
      button.isBordered = false
      button.tag = index
      button.toolTip = LocalizedText.tr(.color)
      button.wantsLayer = true
      button.layer?.cornerRadius = 7
      button.layer?.backgroundColor = color.cgColor
      button.layer?.borderWidth = 1
      button.layer?.borderColor = NSColor.white.withAlphaComponent(0.42).cgColor
      button.widthAnchor.constraint(equalToConstant: 15).isActive = true
      button.heightAnchor.constraint(equalToConstant: 15).isActive = true
      colorRow.addArrangedSubview(button)
    }
    stack.addArrangedSubview(colorRow)

    stack.addArrangedSubview(sliderRow(title: LocalizedText.tr(.lineWidth), value: Double(canvas.lineWidth), min: 1, max: 16, action: #selector(changeLineWidth(_:))))
    stack.addArrangedSubview(sliderRow(title: LocalizedText.tr(.opacity), value: Double(canvas.alpha), min: 0.2, max: 1, action: #selector(changeAlpha(_:))))

    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: root.trailingAnchor),
      stack.topAnchor.constraint(equalTo: root.topAnchor),
      stack.bottomAnchor.constraint(equalTo: root.bottomAnchor)
    ])
    return root
  }

  private func rowLabel(_ title: String) -> NSTextField {
    let label = NSTextField(labelWithString: title)
    label.font = .systemFont(ofSize: 12, weight: .medium)
    label.textColor = .secondaryLabelColor
    label.widthAnchor.constraint(equalToConstant: 44).isActive = true
    return label
  }

  private func sliderRow(title: String, value: Double, min: Double, max: Double, action: Selector) -> NSView {
    let row = NSStackView()
    row.orientation = .horizontal
    row.alignment = .centerY
    row.spacing = 10
    row.addArrangedSubview(rowLabel(title))

    let slider = NSSlider(value: value, minValue: min, maxValue: max, target: self, action: action)
    slider.controlSize = .small
    slider.widthAnchor.constraint(equalToConstant: 198).isActive = true
    row.addArrangedSubview(slider)
    return row
  }

  private func toolButton(tool: CaptureEditorTool) -> NSButton {
    let button = iconButton(symbolName: tool.symbolName, tooltip: tool.title, action: #selector(selectTool(_:)))
    return button
  }

  private func iconButton(symbolName: String, tooltip: String, action: Selector, isProminent: Bool = false, title: String = "") -> NSButton {
    let button = NSButton(title: title, target: self, action: action)
    let configuration = NSImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
    button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: tooltip)?
      .withSymbolConfiguration(configuration)
    button.imagePosition = title.isEmpty ? .imageOnly : .imageLeading
    button.isBordered = false
    button.toolTip = tooltip
    button.font = .systemFont(ofSize: 12, weight: .semibold)
    button.wantsLayer = true
    button.layer?.cornerRadius = 8
    button.layer?.cornerCurve = .continuous
    button.layer?.backgroundColor = isProminent ? NSColor.controlAccentColor.withAlphaComponent(0.32).cgColor : NSColor.white.withAlphaComponent(0.001).cgColor
    button.contentTintColor = isProminent ? .controlAccentColor : .labelColor
    if title.isEmpty {
      button.widthAnchor.constraint(equalToConstant: 26).isActive = true
    }
    button.heightAnchor.constraint(equalToConstant: 26).isActive = true
    return button
  }

  private func separator() -> NSView {
    let view = NSView()
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.separatorColor.withAlphaComponent(0.36).cgColor
    view.widthAnchor.constraint(equalToConstant: 1).isActive = true
    view.heightAnchor.constraint(equalToConstant: 20).isActive = true
    return view
  }

  private func updateToolSelection() {
    for (tool, button) in toolButtons {
      let selected = tool == canvas.currentTool
      button.layer?.backgroundColor = selected
        ? NSColor.controlAccentColor.withAlphaComponent(0.28).cgColor
        : NSColor.white.withAlphaComponent(0.001).cgColor
      button.contentTintColor = selected ? .controlAccentColor : .labelColor
    }
  }

  @objc private func selectTool(_ sender: NSButton) {
    guard let raw = sender.identifier?.rawValue,
          let tool = CaptureEditorTool(rawValue: raw) else { return }
    canvas.currentTool = tool
    updateToolSelection()
  }

  @objc private func changeColor(_ sender: NSColorWell) {
    canvas.strokeColor = sender.color
  }

  @objc private func showStylePopover(_ sender: NSButton) {
    if let stylePopover, stylePopover.isShown {
      stylePopover.close()
      self.stylePopover = nil
      return
    }

    let popover = NSPopover()
    let controller = NSViewController()
    controller.view = makeStylePopoverContent()
    popover.contentViewController = controller
    popover.contentSize = NSSize(width: 286, height: 174)
    popover.behavior = .transient
    popover.animates = true
    popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
    stylePopover = popover
  }

  @objc private func selectPaletteColor(_ sender: NSButton) {
    guard paletteColors.indices.contains(sender.tag) else { return }
    canvas.strokeColor = paletteColors[sender.tag]
  }

  @objc private func changeLineWidth(_ sender: NSSlider) {
    canvas.lineWidth = CGFloat(sender.doubleValue)
  }

  @objc private func changeAlpha(_ sender: NSSlider) {
    canvas.alpha = CGFloat(sender.doubleValue)
  }

  @objc private func undo() { canvas.undo() }
  @objc private func redo() { canvas.redo() }
  @objc private func copyColor() { canvas.copyCurrentColor() }

  @objc private func previousHistory() {
    let history = historyProvider()
    guard !history.isEmpty else { return }
    historyIndex = max(0, historyIndex - 1)
    onHistoryImage(history[historyIndex])
  }

  @objc private func nextHistory() {
    let history = historyProvider()
    guard !history.isEmpty else { return }
    historyIndex = min(history.count - 1, historyIndex + 1)
    onHistoryImage(history[historyIndex])
  }

  @objc private func copyImage() {
    onComplete(canvas.renderedImage(), .copy)
  }

  @objc private func saveImage() {
    let panel = NSSavePanel()
    panel.allowedContentTypes = [.png]
    panel.nameFieldStringValue = CaptureEditorController.quickSaveURL().lastPathComponent
    panel.beginSheetModal(for: window) { [weak self] response in
      guard response == .OK, let url = panel.url else { return }
      self?.onComplete(self?.canvas.renderedImage() ?? NSImage(), .save(url))
    }
  }

  @objc private func quickSaveImage() {
    onComplete(canvas.renderedImage(), .quickSave)
  }

  @objc private func closeEditor() {
    window.close()
  }
}

final class CaptureCanvasView: NSView {
  let image: NSImage
  var currentTool: CaptureEditorTool = .pointer
  var strokeColor: NSColor = .systemBlue
  var lineWidth: CGFloat = 4
  var alpha: CGFloat = 0.9
  var onCopy: (() -> Void)?
  var onSave: (() -> Void)?
  var onQuickSave: (() -> Void)?
  var onClose: (() -> Void)?
  var preferredCanvasSize: NSSize {
    canvasSize(fitting: NSSize(width: 1400, height: 1000))
  }

  func canvasSize(fitting maxSize: NSSize) -> NSSize {
    let size = image.size.width > 0 && image.size.height > 0 ? image.size : NSSize(width: 900, height: 600)
    let scale = min(maxSize.width / max(size.width, 1), maxSize.height / max(size.height, 1), 1)
    return NSSize(width: size.width * scale, height: size.height * scale)
  }

  private var annotations: [CaptureAnnotation] = []
  private var redoStack: [CaptureAnnotation] = []
  private var draft: CaptureAnnotation?
  private var startPoint: CGPoint?
  private var mousePoint: CGPoint?
  private var sampledColorText: String = ""

  init(image: NSImage) {
    self.image = image
    super.init(frame: .zero)
    wantsLayer = true
    layer?.backgroundColor = NSColor.black.cgColor
    addTrackingArea(NSTrackingArea(
      rect: .zero,
      options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect],
      owner: self
    ))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var acceptsFirstResponder: Bool { true }
  override var mouseDownCanMoveWindow: Bool { false }

  override func draw(_ dirtyRect: NSRect) {
    NSColor.black.setFill()
    bounds.fill()
    image.draw(in: bounds)
    for annotation in annotations {
      draw(annotation)
    }
    if let draft {
      draw(draft)
    }
    drawSelectionChrome()
    if currentTool == .pointer, NSEvent.modifierFlags.contains(.option) {
      drawHUD()
    }
  }

  override func mouseDown(with event: NSEvent) {
    window?.makeFirstResponder(self)
    let point = convert(event.locationInWindow, from: nil)
    mousePoint = point
    updateSampledColor(at: point)

    if currentTool == .pointer {
      needsDisplay = true
      return
    }

    startPoint = point
    redoStack.removeAll()

    if currentTool == .text {
      promptForText(at: point)
      return
    }

    draft = makeAnnotation(from: point, to: point)
    needsDisplay = true
  }

  override func mouseDragged(with event: NSEvent) {
    let point = convert(event.locationInWindow, from: nil)
    mousePoint = point
    guard currentTool != .pointer else {
      updateSampledColor(at: point)
      needsDisplay = true
      return
    }
    guard let startPoint else { return }
    if currentTool == .pen {
      if draft == nil {
        draft = makeAnnotation(from: startPoint, to: point)
      }
      draft?.points.append(point)
    } else {
      draft = makeAnnotation(from: startPoint, to: point)
    }
    updateSampledColor(at: point)
    needsDisplay = true
  }

  override func mouseUp(with event: NSEvent) {
    defer {
      draft = nil
      startPoint = nil
      needsDisplay = true
    }
    guard let draft, shouldKeep(draft) else { return }
    annotations.append(draft)
  }

  override func mouseMoved(with event: NSEvent) {
    let point = convert(event.locationInWindow, from: nil)
    mousePoint = point
    updateSampledColor(at: point)
    needsDisplay = true
  }

  override func keyDown(with event: NSEvent) {
    if event.keyCode == 53 {
      onClose?()
      return
    }
    if event.modifierFlags.contains(.command),
       event.charactersIgnoringModifiers?.lowercased() == "c" {
      onCopy?()
      return
    }
    if event.modifierFlags.contains(.command),
       event.charactersIgnoringModifiers?.lowercased() == "s" {
      if event.modifierFlags.contains(.shift) {
        onQuickSave?()
      } else {
        onSave?()
      }
      return
    }
    if event.keyCode == 36 {
      onCopy?()
      return
    }
    if event.modifierFlags.contains(.command), event.charactersIgnoringModifiers == "z" {
      if event.modifierFlags.contains(.shift) {
        redo()
      } else {
        undo()
      }
      return
    }
    if event.charactersIgnoringModifiers?.lowercased() == "c",
       !event.modifierFlags.contains(.command) {
      copyCurrentColor()
      return
    }
    super.keyDown(with: event)
  }

  override func rightMouseDown(with event: NSEvent) {
    let menu = NSMenu()
    menu.addItem(contextItem(LocalizedText.tr(.copyImage), "doc.on.doc", #selector(copyFromContextMenu)))
    menu.addItem(contextItem(LocalizedText.tr(.saveAs), "square.and.arrow.down", #selector(saveFromContextMenu)))
    menu.addItem(contextItem(LocalizedText.tr(.quickSave), "tray.and.arrow.down", #selector(quickSaveFromContextMenu)))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(contextItem(LocalizedText.tr(.undo), "arrow.uturn.backward", #selector(undoFromContextMenu)))
    menu.addItem(contextItem(LocalizedText.tr(.redo), "arrow.uturn.forward", #selector(redoFromContextMenu)))
    menu.addItem(contextItem(LocalizedText.tr(.copyCurrentColor), "eyedropper", #selector(copyColorFromContextMenu)))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(contextItem(LocalizedText.tr(.close), "xmark", #selector(closeFromContextMenu)))
    NSMenu.popUpContextMenu(menu, with: event, for: self)
  }

  private func contextItem(_ title: String, _ symbolName: String, _ action: Selector) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
    item.target = self
    item.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: title)
    return item
  }

  @objc private func copyFromContextMenu() { onCopy?() }
  @objc private func saveFromContextMenu() { onSave?() }
  @objc private func quickSaveFromContextMenu() { onQuickSave?() }
  @objc private func undoFromContextMenu() { undo() }
  @objc private func redoFromContextMenu() { redo() }
  @objc private func copyColorFromContextMenu() { copyCurrentColor() }
  @objc private func closeFromContextMenu() { onClose?() }

  private func shouldKeep(_ annotation: CaptureAnnotation) -> Bool {
    switch annotation.kind {
    case .pen:
      return annotation.points.count > 3
    case .arrow:
      guard let start = annotation.points.first, let end = annotation.points.last else { return false }
      return hypot(end.x - start.x, end.y - start.y) > 8
    case .text:
      return true
    default:
      return annotation.rect.width > 6 || annotation.rect.height > 6
    }
  }

  func undo() {
    guard let last = annotations.popLast() else { return }
    redoStack.append(last)
    needsDisplay = true
  }

  func redo() {
    guard let next = redoStack.popLast() else { return }
    annotations.append(next)
    needsDisplay = true
  }

  func copyCurrentColor() {
    guard !sampledColorText.isEmpty else { return }
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(sampledColorText, forType: .string)
  }

  func renderedImage() -> NSImage {
    let output = NSImage(size: bounds.size)
    output.lockFocus()
    image.draw(in: bounds)
    for annotation in annotations {
      draw(annotation)
    }
    output.unlockFocus()
    return output
  }

  private func makeAnnotation(from start: CGPoint, to end: CGPoint) -> CaptureAnnotation {
    let rect = CGRect(
      x: min(start.x, end.x),
      y: min(start.y, end.y),
      width: abs(end.x - start.x),
      height: abs(end.y - start.y)
    )
    let kind: CaptureAnnotation.Kind
    switch currentTool {
    case .pointer: kind = .rectangle
    case .rectangle: kind = .rectangle
    case .ellipse: kind = .ellipse
    case .arrow: kind = .arrow
    case .pen: kind = .pen
    case .text: kind = .text("")
    case .mosaic: kind = .mosaic
    case .blur: kind = .blur
    }
    return CaptureAnnotation(
      kind: kind,
      rect: rect,
      points: currentTool == .pen ? [start, end] : [start, end],
      color: strokeColor,
      lineWidth: lineWidth,
      alpha: alpha
    )
  }

  private func draw(_ annotation: CaptureAnnotation) {
    let color = annotation.color.withAlphaComponent(annotation.alpha)
    color.setStroke()
    color.setFill()

    switch annotation.kind {
    case .rectangle:
      drawGlassRoundedRectangle(in: annotation.rect, width: annotation.lineWidth, color: annotation.color, alpha: annotation.alpha)
    case .ellipse:
      let path = NSBezierPath(ovalIn: annotation.rect)
      path.lineWidth = annotation.lineWidth
      path.stroke()
    case .arrow:
      guard let start = annotation.points.first, let end = annotation.points.last else { return }
      drawGlassArrow(from: start, to: end, width: annotation.lineWidth, color: annotation.color, alpha: annotation.alpha)
    case .pen:
      let path = NSBezierPath()
      for (index, point) in annotation.points.enumerated() {
        if index == 0 { path.move(to: point) } else { path.line(to: point) }
      }
      path.lineCapStyle = .round
      path.lineJoinStyle = .round
      path.lineWidth = annotation.lineWidth
      path.stroke()
    case .text(let text):
      let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: max(14, annotation.lineWidth * 5), weight: .semibold),
        .foregroundColor: color
      ]
      text.draw(in: annotation.rect.insetBy(dx: 4, dy: 4), withAttributes: attrs)
    case .mosaic:
      drawMosaic(in: annotation.rect, color: color)
    case .blur:
      NSColor.white.withAlphaComponent(0.22).setFill()
      annotation.rect.fill()
      let path = NSBezierPath(rect: annotation.rect)
      path.lineWidth = max(1, annotation.lineWidth * 0.5)
      color.setStroke()
      path.stroke()
    }
  }

  private func drawSelectionChrome() {
    let selectionRect = bounds.insetBy(dx: 0.5, dy: 0.5)
    let accent = NSColor.controlAccentColor

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = accent.withAlphaComponent(0.30)
    shadow.shadowBlurRadius = 8
    shadow.shadowOffset = .zero
    shadow.set()
    accent.withAlphaComponent(0.92).setStroke()
    let border = NSBezierPath(rect: selectionRect)
    border.lineWidth = 1.8
    border.stroke()
    NSGraphicsContext.restoreGraphicsState()

    NSColor.white.withAlphaComponent(0.52).setStroke()
    let innerBorder = NSBezierPath(rect: selectionRect.insetBy(dx: 1.2, dy: 1.2))
    innerBorder.lineWidth = 0.8
    innerBorder.stroke()

    let handles = [
      CGPoint(x: selectionRect.minX, y: selectionRect.minY),
      CGPoint(x: selectionRect.midX, y: selectionRect.minY),
      CGPoint(x: selectionRect.maxX, y: selectionRect.minY),
      CGPoint(x: selectionRect.maxX, y: selectionRect.midY),
      CGPoint(x: selectionRect.maxX, y: selectionRect.maxY),
      CGPoint(x: selectionRect.midX, y: selectionRect.maxY),
      CGPoint(x: selectionRect.minX, y: selectionRect.maxY),
      CGPoint(x: selectionRect.minX, y: selectionRect.midY)
    ]

    for point in handles {
      let handleRect = CGRect(x: point.x - 3.5, y: point.y - 3.5, width: 7, height: 7)
      NSColor.white.setFill()
      NSBezierPath(roundedRect: handleRect, xRadius: 2, yRadius: 2).fill()
      accent.setStroke()
      let outline = NSBezierPath(roundedRect: handleRect, xRadius: 2, yRadius: 2)
      outline.lineWidth = 1
      outline.stroke()
    }

    let sizeText = "\(Int(image.size.width)) x \(Int(image.size.height))"
    let attrs: [NSAttributedString.Key: Any] = [
      .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .semibold),
      .foregroundColor: NSColor.white
    ]
    let badgeSize = NSSize(width: max(86, sizeText.size(withAttributes: attrs).width + 14), height: 22)
    let badgeRect = CGRect(x: selectionRect.minX + 8, y: selectionRect.maxY - badgeSize.height - 8, width: badgeSize.width, height: badgeSize.height)
    NSColor.black.withAlphaComponent(0.56).setFill()
    NSBezierPath(roundedRect: badgeRect, xRadius: 6, yRadius: 6).fill()
    sizeText.draw(in: badgeRect.insetBy(dx: 7, dy: 4), withAttributes: attrs)
  }

  private func drawGlassRoundedRectangle(in rect: CGRect, width: CGFloat, color: NSColor, alpha: CGFloat) {
    let radius = min(22, max(8, min(rect.width, rect.height) * 0.16))
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    let glowPath = NSBezierPath(roundedRect: rect.insetBy(dx: -1.5, dy: -1.5), xRadius: radius + 1.5, yRadius: radius + 1.5)
    let highlightPath = NSBezierPath(roundedRect: rect.insetBy(dx: 1.4, dy: 1.4), xRadius: max(4, radius - 1.4), yRadius: max(4, radius - 1.4))

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.18 * alpha)
    shadow.shadowBlurRadius = 12
    shadow.shadowOffset = NSSize(width: 0, height: -2)
    shadow.set()
    color.withAlphaComponent(0.10 * alpha).setFill()
    path.fill()
    NSGraphicsContext.restoreGraphicsState()

    color.withAlphaComponent(0.12 * alpha).setFill()
    path.fill()

    glowPath.lineCapStyle = .round
    glowPath.lineJoinStyle = .round
    glowPath.lineWidth = width + 5
    color.withAlphaComponent(0.20 * alpha).setStroke()
    glowPath.stroke()

    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    path.lineWidth = width
    color.withAlphaComponent(0.78 * alpha).setStroke()
    path.stroke()

    highlightPath.lineWidth = 1.2
    NSColor.white.withAlphaComponent(0.42 * alpha).setStroke()
    highlightPath.stroke()
  }

  private func drawGlassArrow(from start: CGPoint, to end: CGPoint, width: CGFloat, color: NSColor, alpha: CGFloat) {
    let angle = atan2(end.y - start.y, end.x - start.x)
    let distance = hypot(end.x - start.x, end.y - start.y)
    guard distance > 4 else { return }

    let unit = CGPoint(x: cos(angle), y: sin(angle))
    let normal = CGPoint(x: -sin(angle), y: cos(angle))
    let headLength = min(max(18, width * 5.2), max(18, distance * 0.34))
    let headWidth = max(13, width * 3.9)
    let shaftEnd = CGPoint(
      x: end.x - unit.x * headLength * 0.42,
      y: end.y - unit.y * headLength * 0.42
    )
    let headBase = CGPoint(
      x: end.x - unit.x * headLength,
      y: end.y - unit.y * headLength
    )
    let headLeft = CGPoint(
      x: headBase.x + normal.x * headWidth * 0.5,
      y: headBase.y + normal.y * headWidth * 0.5
    )
    let headRight = CGPoint(
      x: headBase.x - normal.x * headWidth * 0.5,
      y: headBase.y - normal.y * headWidth * 0.5
    )

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.20 * alpha)
    shadow.shadowBlurRadius = 10
    shadow.shadowOffset = NSSize(width: 0, height: -1.5)
    shadow.set()
    let shaft = NSBezierPath()
    shaft.move(to: start)
    shaft.line(to: shaftEnd)
    shaft.lineCapStyle = .round
    shaft.lineJoinStyle = .round
    shaft.lineWidth = width + 5
    color.withAlphaComponent(0.16 * alpha).setStroke()
    shaft.stroke()
    NSGraphicsContext.restoreGraphicsState()

    let glowShaft = NSBezierPath()
    glowShaft.move(to: start)
    glowShaft.line(to: shaftEnd)
    glowShaft.lineCapStyle = .round
    glowShaft.lineJoinStyle = .round
    glowShaft.lineWidth = width + 6
    color.withAlphaComponent(0.18 * alpha).setStroke()
    glowShaft.stroke()

    shaft.lineWidth = width + 1.5
    color.withAlphaComponent(0.70 * alpha).setStroke()
    shaft.stroke()

    let highlight = NSBezierPath()
    highlight.move(to: CGPoint(x: start.x + normal.x * 0.7, y: start.y + normal.y * 0.7))
    highlight.line(to: CGPoint(x: shaftEnd.x + normal.x * 0.7, y: shaftEnd.y + normal.y * 0.7))
    highlight.lineCapStyle = .round
    highlight.lineWidth = max(1, width * 0.28)
    NSColor.white.withAlphaComponent(0.48 * alpha).setStroke()
    highlight.stroke()

    let head = NSBezierPath()
    head.move(to: end)
    head.line(to: headLeft)
    head.line(to: CGPoint(x: headBase.x + unit.x * headLength * 0.22, y: headBase.y + unit.y * headLength * 0.22))
    head.line(to: headRight)
    head.close()
    color.withAlphaComponent(0.64 * alpha).setFill()
    head.fill()
    color.withAlphaComponent(0.82 * alpha).setStroke()
    head.lineJoinStyle = .round
    head.lineWidth = max(1.4, width * 0.55)
    head.stroke()

    let headHighlight = NSBezierPath()
    headHighlight.move(to: CGPoint(x: end.x - unit.x * 2 + normal.x * 0.6, y: end.y - unit.y * 2 + normal.y * 0.6))
    headHighlight.line(to: CGPoint(x: headLeft.x * 0.58 + end.x * 0.42, y: headLeft.y * 0.58 + end.y * 0.42))
    NSColor.white.withAlphaComponent(0.42 * alpha).setStroke()
    headHighlight.lineWidth = 1.1
    headHighlight.lineCapStyle = .round
    headHighlight.stroke()
  }

  private func drawMosaic(in rect: CGRect, color: NSColor) {
    let cell: CGFloat = 10
    var y = rect.minY
    while y < rect.maxY {
      var x = rect.minX
      while x < rect.maxX {
        let shade = CGFloat(Int((x + y).truncatingRemainder(dividingBy: 50)) + 45) / 100
        color.withAlphaComponent(min(1, alpha * shade)).setFill()
        CGRect(x: x, y: y, width: cell - 1, height: cell - 1).fill()
        x += cell
      }
      y += cell
    }
  }

  private func promptForText(at point: CGPoint) {
    let alert = NSAlert()
    alert.messageText = LocalizedText.tr(.addText)
    alert.addButton(withTitle: LocalizedText.tr(.ok))
    alert.addButton(withTitle: LocalizedText.tr(.cancel))
    let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 28))
    alert.accessoryView = input
    guard alert.runModal() == .alertFirstButtonReturn else { return }
    let text = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else { return }
    let annotation = CaptureAnnotation(
      kind: .text(text),
      rect: CGRect(x: point.x, y: point.y - 28, width: 260, height: 56),
      points: [point],
      color: strokeColor,
      lineWidth: lineWidth,
      alpha: alpha
    )
    annotations.append(annotation)
    needsDisplay = true
  }

  private func drawHUD() {
    guard let point = mousePoint, bounds.contains(point) else { return }
    let hudRect = CGRect(x: max(8, point.x + 18), y: max(8, point.y + 18), width: 156, height: 92)
    NSColor.black.withAlphaComponent(0.68).setFill()
    NSBezierPath(roundedRect: hudRect, xRadius: 10, yRadius: 10).fill()

    let sourceRect = CGRect(x: point.x - 10, y: point.y - 10, width: 20, height: 20)
    let previewRect = CGRect(x: hudRect.minX + 10, y: hudRect.minY + 32, width: 52, height: 52)
    image.draw(in: previewRect, from: sourceRect, operation: .sourceOver, fraction: 1)
    NSColor.white.withAlphaComponent(0.75).setStroke()
    NSBezierPath(rect: previewRect).stroke()

    let attrs: [NSAttributedString.Key: Any] = [
      .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium),
      .foregroundColor: NSColor.white
    ]
    sampledColorText.draw(in: CGRect(x: hudRect.minX + 70, y: hudRect.minY + 50, width: 78, height: 18), withAttributes: attrs)
    LocalizedText.tr(.colorPickHint).draw(in: CGRect(x: hudRect.minX + 70, y: hudRect.minY + 30, width: 78, height: 18), withAttributes: attrs)
  }

  private func updateSampledColor(at point: CGPoint) {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
          let provider = cgImage.dataProvider,
          let data = provider.data,
          let bytes = CFDataGetBytePtr(data) else { return }

    let x = min(max(Int(point.x / max(bounds.width, 1) * CGFloat(cgImage.width)), 0), cgImage.width - 1)
    let y = min(max(Int((bounds.height - point.y) / max(bounds.height, 1) * CGFloat(cgImage.height)), 0), cgImage.height - 1)
    let bytesPerPixel = max(1, cgImage.bitsPerPixel / 8)
    let offset = y * cgImage.bytesPerRow + x * bytesPerPixel
    guard offset + 2 < CFDataGetLength(data) else { return }
    let r = bytes[offset]
    let g = bytes[offset + 1]
    let b = bytes[offset + 2]
    sampledColorText = String(format: "#%02X%02X%02X", r, g, b)
  }
}

enum SettingsSection: CaseIterable, Hashable {
  case general
  case hotKey
  case textDirection
  case resultLayout

  var title: String {
    switch self {
    case .general: return LocalizedText.tr(.general)
    case .hotKey: return LocalizedText.tr(.hotKey)
    case .textDirection: return LocalizedText.tr(.textDirection)
    case .resultLayout: return LocalizedText.tr(.resultLayout)
    }
  }

  var symbolName: String {
    switch self {
    case .general: return "slider.horizontal.3"
    case .hotKey: return "keyboard"
    case .textDirection: return "textformat"
    case .resultLayout: return "text.alignleft"
    }
  }

}

struct HotKeyPreference: Equatable {
  private static let keyCodeKey = "HotKeyKeyCode"
  private static let modifierKey = "HotKeyModifiers"
  private static let translationKeyCodeKey = "TranslationHotKeyKeyCode"
  private static let translationModifierKey = "TranslationHotKeyModifiers"
  private static let editorKeyCodeKey = "EditorHotKeyKeyCode"
  private static let editorModifierKey = "EditorHotKeyModifiers"

  let keyCode: UInt32
  let modifiers: NSEvent.ModifierFlags

  var carbonModifiers: UInt32 {
    var result: UInt32 = 0
    if modifiers.contains(.command) { result |= UInt32(cmdKey) }
    if modifiers.contains(.option) { result |= UInt32(optionKey) }
    if modifiers.contains(.control) { result |= UInt32(controlKey) }
    if modifiers.contains(.shift) { result |= UInt32(shiftKey) }
    return result
  }

  var displayText: String {
    modifierDisplay + keyDisplayName(for: keyCode)
  }

  private var modifierDisplay: String {
    var text = ""
    if modifiers.contains(.control) { text += "⌃" }
    if modifiers.contains(.option) { text += "⌥" }
    if modifiers.contains(.shift) { text += "⇧" }
    if modifiers.contains(.command) { text += "⌘" }
    return text
  }

  static func load() -> HotKeyPreference {
    let defaults = UserDefaults.standard
    if defaults.object(forKey: keyCodeKey) != nil {
      let preference = HotKeyPreference(
        keyCode: UInt32(defaults.integer(forKey: keyCodeKey)),
        modifiers: NSEvent.ModifierFlags(rawValue: UInt(defaults.integer(forKey: modifierKey)))
      )
      if preference.isValid {
        return preference
      }
    }

    return HotKeyPreference(keyCode: UInt32(kVK_ANSI_E), modifiers: [.command])
  }

  static func loadTranslation() -> HotKeyPreference {
    let defaults = UserDefaults.standard
    if defaults.object(forKey: translationKeyCodeKey) != nil {
      let preference = HotKeyPreference(
        keyCode: UInt32(defaults.integer(forKey: translationKeyCodeKey)),
        modifiers: NSEvent.ModifierFlags(rawValue: UInt(defaults.integer(forKey: translationModifierKey)))
      )
      if preference.isValid {
        return preference
      }
    }

    return defaultTranslationShortcut()
  }

  static func loadEditor() -> HotKeyPreference {
    let defaults = UserDefaults.standard
    if defaults.object(forKey: editorKeyCodeKey) != nil {
      let preference = HotKeyPreference(
        keyCode: UInt32(defaults.integer(forKey: editorKeyCodeKey)),
        modifiers: NSEvent.ModifierFlags(rawValue: UInt(defaults.integer(forKey: editorModifierKey)))
      )
      if preference.isValid {
        return preference
      }
    }

    return defaultEditorShortcut()
  }

  var isValid: Bool {
    !modifiers.isEmpty && !isReservedSystemShortcut
  }

  private var isReservedSystemShortcut: Bool {
    let modifierSet = modifiers.intersection([.command, .option, .control, .shift])
    guard modifierSet == [.command] else { return false }
    return [
      UInt32(kVK_ANSI_Q),
      UInt32(kVK_ANSI_W),
      UInt32(kVK_ANSI_H),
      UInt32(kVK_ANSI_M),
      UInt32(kVK_ANSI_Comma)
    ].contains(keyCode)
  }

  static func defaultShortcut() -> HotKeyPreference {
    HotKeyPreference(keyCode: UInt32(kVK_ANSI_E), modifiers: [.command])
  }

  static func defaultTranslationShortcut() -> HotKeyPreference {
    HotKeyPreference(keyCode: UInt32(kVK_ANSI_E), modifiers: [.command, .shift])
  }

  static func defaultEditorShortcut() -> HotKeyPreference {
    HotKeyPreference(keyCode: UInt32(kVK_ANSI_E), modifiers: [.command, .option])
  }

  func save() {
    UserDefaults.standard.set(Int(keyCode), forKey: Self.keyCodeKey)
    UserDefaults.standard.set(Int(modifiers.rawValue), forKey: Self.modifierKey)
  }

  func saveTranslation() {
    UserDefaults.standard.set(Int(keyCode), forKey: Self.translationKeyCodeKey)
    UserDefaults.standard.set(Int(modifiers.rawValue), forKey: Self.translationModifierKey)
  }

  func saveEditor() {
    UserDefaults.standard.set(Int(keyCode), forKey: Self.editorKeyCodeKey)
    UserDefaults.standard.set(Int(modifiers.rawValue), forKey: Self.editorModifierKey)
  }

  static func from(event: NSEvent) -> HotKeyPreference? {
    let modifiers = event.modifierFlags.intersection([.command, .option, .control, .shift])
    guard !modifiers.isEmpty else { return nil }
    guard event.keyCode != UInt16(kVK_Escape) else { return nil }
    let preference = HotKeyPreference(keyCode: UInt32(event.keyCode), modifiers: modifiers)
    guard preference.isValid else { return nil }
    return preference
  }
}

enum AppPreferences {
  enum UILanguage: String, CaseIterable {
    case system
    case english
    case simplifiedChinese
    case traditionalChinese
    case japanese
    case korean
    case french
    case portuguese
    case spanish
    case german
    case thai

    var title: String {
      switch self {
      case .system: return "System / 系统"
      case .english: return "English"
      case .simplifiedChinese: return "简体中文"
      case .traditionalChinese: return "繁體中文"
      case .japanese: return "日本語"
      case .korean: return "한국어"
      case .french: return "Français"
      case .portuguese: return "Português"
      case .spanish: return "Español"
      case .german: return "Deutsch"
      case .thai: return "ไทย"
      }
    }
  }

  enum LanguageMode: String, CaseIterable {
    case globalAuto
    case latinAuto
    case chineseTraditionalEnglishJapaneseSymbols
    case eastAsianMixed
    case simplified
    case traditional
    case japanese
    case korean
    case thai
    case portuguese
    case french
    case spanish
    case german
    case italian
    case dutch
    case swedish
    case polish
    case turkish
    case russian
    case ukrainian
    case arabic
    case hindi
    case vietnamese
    case indonesian
    case english

    var title: String {
      switch self {
      case .globalAuto: return "Global Auto / 全球自动"
      case .latinAuto: return "Latin Auto / 拉丁语系自动"
      case .chineseTraditionalEnglishJapaneseSymbols: return "中/繁/英/日/数字/符号"
      case .eastAsianMixed: return "CJK Auto / 中日韩自动"
      case .simplified: return "简体中文和英文"
      case .traditional: return "繁体中文和英文"
      case .japanese: return "日语和英文"
      case .korean: return "韩语和英文"
      case .thai: return "ไทย + English"
      case .portuguese: return "Português + English"
      case .french: return "Français + English"
      case .spanish: return "Español + English"
      case .german: return "Deutsch + English"
      case .italian: return "Italiano + English"
      case .dutch: return "Nederlands + English"
      case .swedish: return "Svenska + English"
      case .polish: return "Polski + English"
      case .turkish: return "Türkçe + English"
      case .russian: return "Русский + English"
      case .ukrainian: return "Українська + English"
      case .arabic: return "العربية + English"
      case .hindi: return "हिन्दी + English"
      case .vietnamese: return "Tiếng Việt + English"
      case .indonesian: return "Bahasa Indonesia + English"
      case .english: return "仅英文"
      }
    }

    var recognitionLanguages: [String] {
      switch self {
      case .globalAuto:
        return ["en-US", "zh-Hans", "zh-Hant", "ja-JP", "ko-KR", "th-TH", "pt-BR", "fr-FR", "es-ES", "de-DE", "it-IT", "nl-NL", "sv-SE", "pl-PL", "tr-TR", "ru-RU", "uk-UA", "ar-SA", "hi-IN", "vi-VN", "id-ID"]
      case .latinAuto:
        return ["en-US", "pt-BR", "fr-FR", "es-ES", "de-DE", "it-IT", "nl-NL", "sv-SE", "pl-PL", "tr-TR"]
      case .chineseTraditionalEnglishJapaneseSymbols:
        return ["zh-Hans", "zh-Hant", "en-US", "ja-JP"]
      case .eastAsianMixed: return ["zh-Hans", "zh-Hant", "ja-JP", "ko-KR", "en-US"]
      case .simplified: return ["zh-Hans", "en-US"]
      case .traditional: return ["zh-Hant", "en-US"]
      case .japanese: return ["ja-JP", "en-US"]
      case .korean: return ["ko-KR", "en-US"]
      case .thai: return ["th-TH", "en-US"]
      case .portuguese: return ["pt-BR", "en-US"]
      case .french: return ["fr-FR", "en-US"]
      case .spanish: return ["es-ES", "en-US"]
      case .german: return ["de-DE", "en-US"]
      case .italian: return ["it-IT", "en-US"]
      case .dutch: return ["nl-NL", "en-US"]
      case .swedish: return ["sv-SE", "en-US"]
      case .polish: return ["pl-PL", "en-US"]
      case .turkish: return ["tr-TR", "en-US"]
      case .russian: return ["ru-RU", "en-US"]
      case .ukrainian: return ["uk-UA", "en-US"]
      case .arabic: return ["ar-SA", "en-US"]
      case .hindi: return ["hi-IN", "en-US"]
      case .vietnamese: return ["vi-VN", "en-US"]
      case .indonesian: return ["id-ID", "en-US"]
      case .english: return ["en-US"]
      }
    }

    var preservesSymbols: Bool {
      self == .chineseTraditionalEnglishJapaneseSymbols
    }
  }

  enum TranslationLanguage: String, CaseIterable {
    case english
    case simplifiedChinese
    case traditionalChinese
    case japanese
    case korean
    case french
    case portuguese
    case spanish
    case german
    case italian
    case russian
    case thai

    var title: String {
      switch self {
      case .english: return "English"
      case .simplifiedChinese: return "简体中文"
      case .traditionalChinese: return "繁體中文"
      case .japanese: return "日本語"
      case .korean: return "한국어"
      case .french: return "Français"
      case .portuguese: return "Português"
      case .spanish: return "Español"
      case .german: return "Deutsch"
      case .italian: return "Italiano"
      case .russian: return "Русский"
      case .thai: return "ไทย"
      }
    }

    var localeLanguage: Locale.Language {
      switch self {
      case .english: return Locale.Language(identifier: "en")
      case .simplifiedChinese: return Locale.Language(identifier: "zh-Hans")
      case .traditionalChinese: return Locale.Language(identifier: "zh-Hant")
      case .japanese: return Locale.Language(identifier: "ja")
      case .korean: return Locale.Language(identifier: "ko")
      case .french: return Locale.Language(identifier: "fr")
      case .portuguese: return Locale.Language(identifier: "pt")
      case .spanish: return Locale.Language(identifier: "es")
      case .german: return Locale.Language(identifier: "de")
      case .italian: return Locale.Language(identifier: "it")
      case .russian: return Locale.Language(identifier: "ru")
      case .thai: return Locale.Language(identifier: "th")
      }
    }
  }

  enum TextDirection: String {
    case horizontal
    case vertical

    var title: String {
      switch self {
      case .horizontal: return LocalizedText.tr(.horizontalScan)
      case .vertical: return LocalizedText.tr(.verticalScan)
      }
    }
  }

  enum ResultLayout: String {
    case smart
    case lines

    var title: String {
      switch self {
      case .smart: return LocalizedText.tr(.smartLayout)
      case .lines: return LocalizedText.tr(.lineLayout)
      }
    }
  }

  private enum Key {
    static let muteSuccessSound = "MuteSuccessSound"
    static let ignoreWatermarkText = "IgnoreWatermarkText"
    static let startAtLogin = "StartAtLogin"
    static let autoRestart = "AutoRestart"
    static let uiLanguage = "UILanguage"
    static let languageMode = "LanguageMode"
    static let translationLanguage = "TranslationLanguage"
    static let textDirection = "TextDirection"
    static let resultLayout = "ResultLayout"
    static let resultFontSize = "ResultFontSize"
    static let didRequestScreenCapturePermission = "DidRequestScreenCapturePermission"
  }

  static var muteSuccessSound: Bool {
    get { UserDefaults.standard.bool(forKey: Key.muteSuccessSound) }
    set { UserDefaults.standard.set(newValue, forKey: Key.muteSuccessSound) }
  }

  static var ignoreWatermarkText: Bool {
    get {
      if UserDefaults.standard.object(forKey: Key.ignoreWatermarkText) == nil {
        return true
      }
      return UserDefaults.standard.bool(forKey: Key.ignoreWatermarkText)
    }
    set { UserDefaults.standard.set(newValue, forKey: Key.ignoreWatermarkText) }
  }

  static var startAtLogin: Bool {
    get { UserDefaults.standard.bool(forKey: Key.startAtLogin) }
    set { UserDefaults.standard.set(newValue, forKey: Key.startAtLogin) }
  }

  static var autoRestart: Bool {
    get { UserDefaults.standard.bool(forKey: Key.autoRestart) }
    set { UserDefaults.standard.set(newValue, forKey: Key.autoRestart) }
  }

  static var uiLanguage: UILanguage {
    get {
      guard let raw = UserDefaults.standard.string(forKey: Key.uiLanguage),
            let value = UILanguage(rawValue: raw) else { return .system }
      return value
    }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: Key.uiLanguage) }
  }

  static var languageMode: LanguageMode {
    get {
      guard let raw = UserDefaults.standard.string(forKey: Key.languageMode),
            let value = LanguageMode(rawValue: raw) else { return .globalAuto }
      return value
    }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: Key.languageMode) }
  }

  static var translationLanguage: TranslationLanguage {
    get {
      guard let raw = UserDefaults.standard.string(forKey: Key.translationLanguage),
            let value = TranslationLanguage(rawValue: raw) else { return .english }
      return value
    }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: Key.translationLanguage) }
  }

  static var textDirection: TextDirection {
    get {
      guard let raw = UserDefaults.standard.string(forKey: Key.textDirection),
            let value = TextDirection(rawValue: raw) else { return .horizontal }
      return value
    }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: Key.textDirection) }
  }

  static var resultLayout: ResultLayout {
    get {
      guard let raw = UserDefaults.standard.string(forKey: Key.resultLayout),
            let value = ResultLayout(rawValue: raw) else { return .smart }
      return value
    }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: Key.resultLayout) }
  }

  static var resultFontSize: Int {
    get {
      let value = UserDefaults.standard.integer(forKey: Key.resultFontSize)
      return value == 0 ? 14 : value
    }
    set { UserDefaults.standard.set(newValue, forKey: Key.resultFontSize) }
  }

  static var didRequestScreenCapturePermission: Bool {
    get { UserDefaults.standard.bool(forKey: Key.didRequestScreenCapturePermission) }
    set { UserDefaults.standard.set(newValue, forKey: Key.didRequestScreenCapturePermission) }
  }
}

enum LaunchAgentService {
  private static let label = "com.itou.yamazaki.keepalive"

  private static var agentURL: URL {
    FileManager.default.homeDirectoryForCurrentUser
      .appendingPathComponent("Library/LaunchAgents/\(label).plist")
  }

  private static var launchdDomain: String {
    "gui/\(getuid())"
  }

  static func setStartAtLoginEnabled(_ isEnabled: Bool) {
    AppPreferences.startAtLogin = isEnabled
    refreshLaunchAgent(loadNow: AppPreferences.autoRestart)
  }

  static func setAutoRestartEnabled(_ isEnabled: Bool) {
    AppPreferences.autoRestart = isEnabled
    refreshLaunchAgent(loadNow: isEnabled)
  }

  static func refreshAutoRestartAgent() {
    refreshLaunchAgent()
  }

  static func refreshLaunchAgent() {
    refreshLaunchAgent(loadNow: false)
  }

  private static func refreshLaunchAgent(loadNow: Bool) {
    guard AppPreferences.startAtLogin || AppPreferences.autoRestart else {
      unloadAndRemove()
      return
    }

    if loadNow {
      installAndLoad()
      return
    }

    writePlist()
  }

  private static func installAndLoad() {
    guard writePlist() else { return }
    runLaunchctl(arguments: ["bootout", launchdDomain, agentURL.path])
    runLaunchctl(arguments: ["bootstrap", launchdDomain, agentURL.path])
  }

  @discardableResult
  private static func writePlist() -> Bool {
    guard let executablePath = preferredExecutablePath() else { return false }
    let plist: [String: Any] = [
      "Label": label,
      "ProgramArguments": [executablePath],
      "RunAtLoad": true,
      "KeepAlive": AppPreferences.autoRestart,
      "LimitLoadToSessionType": "Aqua",
      "ProcessType": "Interactive"
    ]

    do {
      let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
      try FileManager.default.createDirectory(
        at: agentURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      try data.write(to: agentURL, options: .atomic)
      return true
    } catch {
      NSLog("Failed to install auto-restart LaunchAgent: \(error.localizedDescription)")
      return false
    }
  }

  private static func unloadAndRemove() {
    runLaunchctl(arguments: ["bootout", launchdDomain, agentURL.path])
    try? FileManager.default.removeItem(at: agentURL)
  }

  private static func preferredExecutablePath() -> String? {
    let installedPath = "/Applications/\(ProductInfo.appName).app/Contents/MacOS/Yamazaki"
    if FileManager.default.isExecutableFile(atPath: installedPath) {
      return installedPath
    }
    return Bundle.main.executablePath
  }

  private static func runLaunchctl(arguments: [String]) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
    process.arguments = arguments
    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      NSLog("launchctl failed: \(error.localizedDescription)")
    }
  }
}

final class ShortcutRecorderView: NSView {
  var onShortcut: ((HotKeyPreference) -> Void)?
  var onInvalidShortcut: (() -> Void)?
  private var isRecording = false

  override var acceptsFirstResponder: Bool { true }

  func beginRecording() {
    isRecording = true
    window?.makeFirstResponder(self)
    needsDisplay = true
  }

  override func keyDown(with event: NSEvent) {
    guard isRecording else {
      super.keyDown(with: event)
      return
    }

    if event.keyCode == UInt16(kVK_Escape) {
      isRecording = false
      needsDisplay = true
      return
    }

    guard let shortcut = HotKeyPreference.from(event: event) else {
      NSSound.beep()
      onInvalidShortcut?()
      return
    }

    isRecording = false
    needsDisplay = true
    onShortcut?(shortcut)
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    guard isRecording else { return }

    NSColor.controlAccentColor.withAlphaComponent(0.18).setFill()
    bounds.fill()

    let strokePath = NSBezierPath(roundedRect: bounds.insetBy(dx: 1.5, dy: 1.5), xRadius: 28, yRadius: 28)
    strokePath.lineWidth = 3
    NSColor.controlAccentColor.withAlphaComponent(0.55).setStroke()
    strokePath.stroke()
  }
}

private func keyDisplayName(for keyCode: UInt32) -> String {
  let names: [UInt32: String] = [
    UInt32(kVK_ANSI_A): "A",
    UInt32(kVK_ANSI_B): "B",
    UInt32(kVK_ANSI_C): "C",
    UInt32(kVK_ANSI_D): "D",
    UInt32(kVK_ANSI_E): "E",
    UInt32(kVK_ANSI_F): "F",
    UInt32(kVK_ANSI_G): "G",
    UInt32(kVK_ANSI_H): "H",
    UInt32(kVK_ANSI_I): "I",
    UInt32(kVK_ANSI_J): "J",
    UInt32(kVK_ANSI_K): "K",
    UInt32(kVK_ANSI_L): "L",
    UInt32(kVK_ANSI_M): "M",
    UInt32(kVK_ANSI_N): "N",
    UInt32(kVK_ANSI_O): "O",
    UInt32(kVK_ANSI_P): "P",
    UInt32(kVK_ANSI_Q): "Q",
    UInt32(kVK_ANSI_R): "R",
    UInt32(kVK_ANSI_S): "S",
    UInt32(kVK_ANSI_T): "T",
    UInt32(kVK_ANSI_U): "U",
    UInt32(kVK_ANSI_V): "V",
    UInt32(kVK_ANSI_W): "W",
    UInt32(kVK_ANSI_X): "X",
    UInt32(kVK_ANSI_Y): "Y",
    UInt32(kVK_ANSI_Z): "Z",
    UInt32(kVK_ANSI_0): "0",
    UInt32(kVK_ANSI_1): "1",
    UInt32(kVK_ANSI_2): "2",
    UInt32(kVK_ANSI_3): "3",
    UInt32(kVK_ANSI_4): "4",
    UInt32(kVK_ANSI_5): "5",
    UInt32(kVK_ANSI_6): "6",
    UInt32(kVK_ANSI_7): "7",
    UInt32(kVK_ANSI_8): "8",
    UInt32(kVK_ANSI_9): "9",
    UInt32(kVK_Space): "Space",
    UInt32(kVK_Return): "Return",
    UInt32(kVK_Tab): "Tab",
    UInt32(kVK_F1): "F1",
    UInt32(kVK_F2): "F2",
    UInt32(kVK_F3): "F3",
    UInt32(kVK_F4): "F4",
    UInt32(kVK_F5): "F5",
    UInt32(kVK_F6): "F6",
    UInt32(kVK_F7): "F7",
    UInt32(kVK_F8): "F8",
    UInt32(kVK_F9): "F9",
    UInt32(kVK_F10): "F10",
    UInt32(kVK_F11): "F11",
    UInt32(kVK_F12): "F12"
  ]

  return names[keyCode] ?? "Key \(keyCode)"
}

struct RecognizedTextLine: Identifiable {
  let id = UUID()
  let text: String
  let box: CGRect
}

final class OCRService {
  private struct OCRLine {
    let text: String
    let box: CGRect
    let confidence: Float
  }

  private struct OCRResult {
    let lines: [OCRLine]
    let languageProfile: [String]

    var text: String {
      lines.map(\.text).joined(separator: "\n")
    }

    var averageConfidence: Float {
      guard !lines.isEmpty else { return 0 }
      return lines.map(\.confidence).reduce(0, +) / Float(lines.count)
    }
  }

  func recognizeText(in image: NSImage) throws -> String {
    let lines = try recognizePositionedText(in: image).map { OCRLine(text: $0.text, box: $0.box, confidence: 1) }

    if AppPreferences.resultLayout == .lines {
      return lines
        .map(\.text)
        .joined(separator: "\n")
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    return smartFormat(lines).trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func recognizePositionedText(in image: NSImage) throws -> [RecognizedTextLine] {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
      throw OCRError.invalidImage
    }
    let rotatedImage = AppPreferences.textDirection == .vertical ? rotatedClockwise(cgImage) : nil
    let imageForRecognition = rotatedImage ?? cgImage

    let lines: [OCRLine]
    if AppPreferences.languageMode == .globalAuto {
      lines = try recognizeGlobalAuto(in: imageForRecognition).lines
    } else {
      lines = try recognizeLines(
        in: imageForRecognition,
        languages: AppPreferences.languageMode.recognitionLanguages,
        preservesSymbols: AppPreferences.languageMode.preservesSymbols
      )
    }
    var outputLines = rotatedImage == nil
      ? lines
      : lines.map { line in
        OCRLine(
          text: line.text,
          box: mapClockwiseRotatedBoxBackToOriginal(line.box),
          confidence: line.confidence
        )
      }
    if AppPreferences.ignoreWatermarkText {
      outputLines = filterWatermarkLines(outputLines, in: cgImage)
    }
    return outputLines.map { RecognizedTextLine(text: $0.text, box: $0.box) }
  }

  private func filterWatermarkLines(_ lines: [OCRLine], in image: CGImage) -> [OCRLine] {
    guard lines.count > 1 else { return lines }

    let medianHeight = median(lines.map(\.box.height))
    let keys = lines.map { normalizedWatermarkKey($0.text) }
    let repeatCounts = Dictionary(keys.filter { !$0.isEmpty }.map { ($0, 1) }, uniquingKeysWith: +)
    let bitmap = NSBitmapImageRep(cgImage: image)

    let filtered = lines.enumerated().filter { index, line in
      let key = keys[index]
      let repeatCount = key.isEmpty ? 1 : repeatCounts[key, default: 1]
      let contrast = localLuminanceContrast(for: line.box, in: bitmap) ?? 1
      return !isLikelyWatermark(
        line: line,
        repeatCount: repeatCount,
        contrast: contrast,
        medianHeight: medianHeight
      )
    }.map(\.element)

    return filtered.isEmpty ? lines : filtered
  }

  private func isLikelyWatermark(
    line: OCRLine,
    repeatCount: Int,
    contrast: CGFloat,
    medianHeight: CGFloat
  ) -> Bool {
    let box = line.box.standardized
    let area = box.width * box.height
    let lowContrast = contrast < 0.18
    let veryLowContrast = contrast < 0.11
    let wide = box.width > 0.42
    let tall = box.height > max(medianHeight * 1.55, 0.045)
    let huge = area > 0.10 || box.width > 0.68 || box.height > 0.16
    let lowConfidence = line.confidence < 0.55

    if repeatCount >= 3 && (lowContrast || tall || wide || lowConfidence) {
      return true
    }
    if repeatCount >= 2 && lowContrast && (wide || tall || line.confidence < 0.75) {
      return true
    }
    if veryLowContrast && (huge || (wide && tall)) {
      return true
    }
    if lowContrast && huge && line.confidence < 0.80 {
      return true
    }
    return false
  }

  private func normalizedWatermarkKey(_ text: String) -> String {
    let folded = text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
    let scalars = folded.unicodeScalars.filter { scalar in
      CharacterSet.alphanumerics.contains(scalar) || isCJKScalar(scalar)
    }
    let key = String(String.UnicodeScalarView(scalars))
    return key.unicodeScalars.count < 3 ? "" : key
  }

  private func localLuminanceContrast(for normalizedBox: CGRect, in bitmap: NSBitmapImageRep) -> CGFloat? {
    let width = bitmap.pixelsWide
    let height = bitmap.pixelsHigh
    guard width > 0, height > 0 else { return nil }

    var rect = pixelRect(for: normalizedBox, width: width, height: height)
    let padX = max(2, rect.width * 0.08)
    let padY = max(2, rect.height * 0.20)
    rect = rect.insetBy(dx: -padX, dy: -padY)
      .intersection(CGRect(x: 0, y: 0, width: width, height: height))

    guard !rect.isNull, rect.width >= 2, rect.height >= 2 else { return nil }

    let sampleColumns = min(18, max(4, Int(rect.width / 4)))
    let sampleRows = min(18, max(4, Int(rect.height / 4)))
    var values: [CGFloat] = []
    values.reserveCapacity(sampleColumns * sampleRows)

    for row in 0..<sampleRows {
      for column in 0..<sampleColumns {
        let x = Int(rect.minX + (CGFloat(column) + 0.5) * rect.width / CGFloat(sampleColumns))
        let y = Int(rect.minY + (CGFloat(row) + 0.5) * rect.height / CGFloat(sampleRows))
        let clampedX = min(max(x, 0), width - 1)
        let clampedY = min(max(y, 0), height - 1)
        guard let color = bitmap.colorAt(x: clampedX, y: clampedY)?.usingColorSpace(.deviceRGB) else {
          continue
        }
        values.append(0.2126 * color.redComponent + 0.7152 * color.greenComponent + 0.0722 * color.blueComponent)
      }
    }

    guard values.count >= 4 else { return nil }
    values.sort()
    let lowIndex = max(0, min(values.count - 1, Int(Double(values.count - 1) * 0.10)))
    let highIndex = max(0, min(values.count - 1, Int(Double(values.count - 1) * 0.90)))
    return values[highIndex] - values[lowIndex]
  }

  private func pixelRect(for normalizedBox: CGRect, width: Int, height: Int) -> CGRect {
    let imageWidth = CGFloat(width)
    let imageHeight = CGFloat(height)
    let box = normalizedBox.standardized
    return CGRect(
      x: box.minX * imageWidth,
      y: (1 - box.maxY) * imageHeight,
      width: box.width * imageWidth,
      height: box.height * imageHeight
    )
  }

  private func isCJKScalar(_ scalar: UnicodeScalar) -> Bool {
    (0x4E00...0x9FFF).contains(scalar.value) ||
      (0x3400...0x4DBF).contains(scalar.value) ||
      (0x3040...0x30FF).contains(scalar.value) ||
      (0xAC00...0xD7AF).contains(scalar.value)
  }

  private func recognizeGlobalAuto(in image: CGImage) throws -> OCRResult {
    let profiles = [
      ["zh-Hans", "zh-Hant", "en-US"],
      AppPreferences.LanguageMode.chineseTraditionalEnglishJapaneseSymbols.recognitionLanguages,
      ["zh-Hans", "zh-Hant", "ja-JP", "ko-KR", "en-US"],
      AppPreferences.LanguageMode.latinAuto.recognitionLanguages,
      ["th-TH", "vi-VN", "id-ID", "en-US"],
      ["ru-RU", "uk-UA", "ar-SA", "hi-IN", "en-US"]
    ]

    let results = try profiles.map { profile in
      OCRResult(lines: try recognizeLines(in: image, languages: profile), languageProfile: profile)
    }

    return results.max { lhs, rhs in
      score(lhs) < score(rhs)
    } ?? OCRResult(lines: [], languageProfile: [])
  }

  private func score(_ result: OCRResult) -> Double {
    let text = result.text
    let scalarCount = text.unicodeScalars.filter { !$0.properties.isWhitespace }.count
    let cjkCount = text.unicodeScalars.filter { scalar in
      (0x4E00...0x9FFF).contains(scalar.value) ||
      (0x3400...0x4DBF).contains(scalar.value) ||
      (0x3040...0x30FF).contains(scalar.value) ||
      (0xAC00...0xD7AF).contains(scalar.value)
    }.count
    let nonLatinCount = text.unicodeScalars.filter { scalar in
      scalar.value > 0x024F && !scalar.properties.isWhitespace
    }.count

    return Double(scalarCount)
      + Double(result.averageConfidence) * 24
      + Double(cjkCount) * 1.8
      + Double(nonLatinCount) * 0.65
  }

  private func recognizeLines(in image: CGImage, languages: [String], preservesSymbols: Bool = false) throws -> [OCRLine] {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = !preservesSymbols
    let requestedLanguages = languages
    let supportedLanguages = (try? request.supportedRecognitionLanguages()) ?? requestedLanguages
    let filteredLanguages = requestedLanguages.filter { supportedLanguages.contains($0) }
    request.recognitionLanguages = filteredLanguages.isEmpty ? ["en-US"] : filteredLanguages
    request.customWords = [
      "Yamazaki",
      "OCR",
      "PDF",
      "Command",
      "剪切板",
      "快捷键",
      "识别",
      "識別",
      "クリップボード",
      "ショートカット",
      "認識",
      "클립보드",
      "단축키",
      "인식"
    ]

    let handler = VNImageRequestHandler(cgImage: image, options: [:])
    try handler.perform([request])

    let observations = request.results ?? []
    return orderedLines(from: observations)
  }

  private func orderedLines(from observations: [VNRecognizedTextObservation]) -> [OCRLine] {
    observations
      .compactMap { observation -> OCRLine? in
        guard let candidate = observation.topCandidates(1).first,
          !candidate.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
        return OCRLine(text: text, box: observation.boundingBox, confidence: candidate.confidence)
      }
      .sorted { lhs, rhs in
        let rowTolerance = max(lhs.box.height, rhs.box.height) * 0.55
        if abs(lhs.box.midY - rhs.box.midY) > rowTolerance {
          return lhs.box.midY > rhs.box.midY
        }
        return lhs.box.minX < rhs.box.minX
      }
  }

  private func smartFormat(_ lines: [OCRLine]) -> String {
    var output = ""
    let medianHeight = median(lines.map(\.box.height))

    for (index, line) in lines.enumerated() {
      let trimmed = line.text.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else { continue }

      if output.isEmpty {
        output = trimmed
        continue
      }

      let previous = lines[index - 1]
      if shouldBreakLine(previous: previous, next: line, medianHeight: medianHeight) {
        output += "\n" + trimmed
      } else {
        output += joinSeparator(previous: previous.text, next: trimmed) + trimmed
      }
    }
    return output
  }

  private func shouldBreakLine(previous: OCRLine, next: OCRLine, medianHeight: CGFloat) -> Bool {
    let verticalGap = max(0, previous.box.minY - next.box.maxY)
    if verticalGap > max(medianHeight * 0.9, 0.018) {
      return true
    }

    let previousText = previous.text.trimmingCharacters(in: .whitespacesAndNewlines)
    let nextText = next.text.trimmingCharacters(in: .whitespacesAndNewlines)
    if endsParagraph(previousText) { return true }
    if looksLikeListItem(nextText) { return true }

    return false
  }

  private func joinSeparator(previous: String, next: String) -> String {
    guard let last = previous.last else { return "" }
    guard let first = next.first else { return "" }

    if last == "-" {
      return ""
    }
    if isCJK(last) || isCJK(first) {
      return ""
    }
    return " "
  }

  private func endsParagraph(_ text: String) -> Bool {
    guard let last = text.last else { return false }
    return "。！？!?；;".contains(last)
  }

  private func looksLikeListItem(_ text: String) -> Bool {
    text.range(of: #"^(\d+[\.\)]|[一二三四五六七八九十]+[、．.]|[-•●])\s*"#, options: .regularExpression) != nil
  }

  private func isCJK(_ character: Character) -> Bool {
    character.unicodeScalars.contains { scalar in
      (0x4E00...0x9FFF).contains(scalar.value) ||
      (0x3400...0x4DBF).contains(scalar.value) ||
      (0x3040...0x30FF).contains(scalar.value) ||
      (0xAC00...0xD7AF).contains(scalar.value)
    }
  }

  private func median(_ values: [CGFloat]) -> CGFloat {
    guard !values.isEmpty else { return 0.02 }
    let sorted = values.sorted()
    let middle = sorted.count / 2
    if sorted.count.isMultiple(of: 2) {
      return (sorted[middle - 1] + sorted[middle]) / 2
    }
    return sorted[middle]
  }

  private func rotatedClockwise(_ image: CGImage) -> CGImage? {
    let width = image.width
    let height = image.height
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
      data: nil,
      width: height,
      height: width,
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    context.translateBy(x: CGFloat(height), y: 0)
    context.rotate(by: .pi / 2)
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    return context.makeImage()
  }

  private func mapClockwiseRotatedBoxBackToOriginal(_ box: CGRect) -> CGRect {
    CGRect(
      x: box.minY,
      y: 1 - box.maxX,
      width: box.height,
      height: box.width
    )
  }
}

enum OCRError: LocalizedError {
  case invalidImage

  var errorDescription: String? {
    switch self {
    case .invalidImage:
      return "无法读取截图图片"
    }
  }
}

private func fourCharacterCode(_ string: String) -> OSType {
  var result: OSType = 0
  for scalar in string.unicodeScalars.prefix(4) {
    result = (result << 8) + OSType(scalar.value)
  }
  return result
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
