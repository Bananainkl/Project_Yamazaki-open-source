import Foundation

enum ProductInfo {
  static let appName = "Yamazaki"
}

enum LocalizedKey: String {
  case waitingForShortcut
  case openSettings
  case captureWithShortcut
  case translateWithShortcut
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
  case startAtLogin
  case startAtLoginCaption
  case startAtLoginEnabled
  case startAtLoginDisabled
  case autoRestart
  case autoRestartCaption
  case autoRestartEnabled
  case autoRestartDisabled
  case muteSuccessSound
  case muteSuccessSoundCaption
  case showFloatingHUD
  case showFloatingHUDCaption
  case ignoreWatermarkText
  case ignoreWatermarkCaption
  case uiLanguage
  case recognitionLanguage
  case languageNote
  case shortcutHintIdle
  case shortcutHintRecording
  case successCaption
  case setShortcut
  case resetDefault
  case testShortcut
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
  case livePreviewTitle
  case livePreviewSampleLine1
  case livePreviewSampleLine2
  case livePreviewSampleLine3
  case ocrPrivacyCaption
  case languagePrivacy
  case translationPrivacyCaption
  case behavior
  case shortcutConflictHint
  case copyButton
  case copiedBadge
  case needPermissionStatus
  case permissionTitle
  case permissionMessage
  case grantPermissionButton
  case noClipboardImage
  case recognizingText
  case noTextFound
  case copiedText
  case copiedCharsCount
  case recognitionFailed
  case recentCaptures
  case clearHistory
  case emptyHistoryTitle
  case emptyHistorySubtitle
  case quickSettings
  case overlayMode
  case splitCompareMode
  case sourceTextLabel
  case translatedTextLabel
  case translatingProgress
  case charactersUnit
  case justNow
  case cancelRecordingHint
  case ok
}

enum LocalizedText {
  static var locale: Locale {
    Locale(identifier: languageCode)
  }

  static func relativeTime(since date: Date, now: Date = Date()) -> String {
    let delta = now.timeIntervalSince(date)
    if abs(delta) < 10 {
      return tr(.justNow)
    }
    let formatter = RelativeDateTimeFormatter()
    formatter.locale = locale
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: date, relativeTo: now)
  }

  static func tr(_ key: LocalizedKey, _ args: CVarArg...) -> String {
    let code = languageCode
    let template = translations[code]?[key.rawValue]
      ?? translations["en"]?[key.rawValue]
      ?? key.rawValue
    return args.isEmpty ? template : String(format: template, locale: Locale(identifier: code), arguments: args)
  }

  static var languageCode: String {
    switch AppPreferences.uiLanguage {
    case .system:
      let preferred = Locale.preferredLanguages.first ?? "en"
      if preferred.hasPrefix("zh-Hant") || preferred.hasPrefix("zh-HK") || preferred.hasPrefix("zh-TW") { return "zh-Hant" }
      if preferred.hasPrefix("zh") { return "zh-Hans" }
      let prefix = String(preferred.prefix(2))
      return translations[prefix] != nil ? prefix : "en"
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
      "waitingForShortcut": "Ready",
      "openSettings": "Settings…",
      "captureWithShortcut": "%@ Capture Text",
      "translateWithShortcut": "%@ Translate Area",
      "recognizeClipboard": "Recognize Clipboard",
      "quitApp": "Quit %@",
      "shortcutEnabled": "%@ Ready",
      "pressNewShortcut": "Press shortcut keys…",
      "invalidShortcut": "Unavailable or already used by macOS, another app, or Yamazaki.",
      "recognitionLanguageSet": "OCR language: %@",
      "textDirectionSet": "Scan direction: %@",
      "resultLayoutSet": "Layout: %@",
      "appSettings": "%@ Settings",
      "subtitle": "Press %@ anywhere to capture and copy multilingual text locally.",
      "general": "General",
      "hotKey": "Shortcuts",
      "textDirection": "Scan Direction",
      "resultLayout": "Typography & Layout",
      "startAtLogin": "Start at login",
      "startAtLoginCaption": "Launch Yamazaki automatically in the menu bar when signing in.",
      "startAtLoginEnabled": "Start at login enabled",
      "startAtLoginDisabled": "Start at login disabled",
      "autoRestart": "Keep alive in background",
      "autoRestartCaption": "Automatically reopen Yamazaki via LaunchAgent if it exits unexpectedly.",
      "autoRestartEnabled": "Auto-restart enabled",
      "autoRestartDisabled": "Auto-restart disabled",
      "muteSuccessSound": "Mute shutter sound",
      "muteSuccessSoundCaption": "Silence the subtle audio cue played when text is copied.",
      "showFloatingHUD": "Show floating HUD capsule",
      "showFloatingHUDCaption": "Display a non-intrusive Liquid Glass pill at the top of the screen during OCR.",
      "ignoreWatermarkText": "Filter background watermarks",
      "ignoreWatermarkCaption": "Automatically omit repeated, low-contrast, or oversized watermark text.",
      "uiLanguage": "Interface language",
      "recognitionLanguage": "Recognition profile",
      "languageNote": "All OCR runs 100% locally via Apple Vision with isolated worker recovery.",
      "shortcutHintIdle": "Click Record, then press a modifier combination",
      "shortcutHintRecording": "Listening… Press Esc to cancel",
      "successCaption": "Recognized text is copied immediately to your clipboard.",
      "setShortcut": "Record",
      "resetDefault": "Reset Default",
      "testShortcut": "Try Now",
      "captureSelection": "Capture Text",
      "translateSelection": "Translate Area",
      "translationLanguage": "Translate target",
      "translationLanguageSet": "Translate to: %@",
      "horizontalScan": "Horizontal Reading",
      "horizontalSubtitle": "Optimized for web pages, documents, code, tables, and mixed CJK/Latin lines.",
      "verticalScan": "Vertical Columns",
      "verticalSubtitle": "Optimized for vertical Traditional Chinese, Japanese books, and manga.",
      "smartLayout": "Smart Paragraphs",
      "smartSubtitle": "Reflows natural sentences into clean paragraphs while preserving list items.",
      "lineLayout": "Preserve Line Breaks",
      "lineSubtitle": "Keeps exact line-by-line structure for code snippets, receipts, and tables.",
      "resultFontSize": "Preview & Studio font size",
      "livePreviewTitle": "Live Output Preview",
      "livePreviewSampleLine1": "Yamazaki runs native on-device Vision OCR",
      "livePreviewSampleLine2": "with automatic E5RT worker isolation.",
      "livePreviewSampleLine3": "1. Instant clipboard output  •  2. Zero cloud upload",
      "ocrPrivacyCaption": "Screen captures are processed in memory and never leave your Mac.",
      "languagePrivacy": "Language & Engine",
      "translationPrivacyCaption": "Translation uses the macOS system Translation framework.",
      "behavior": "Interaction & Startup",
      "shortcutConflictHint": "Yamazaki validates shortcuts against system and app bindings. Command + Shift or Command + Option combinations are recommended.",
      "copyButton": "Copy All",
      "copiedBadge": "Copied",
      "needPermissionStatus": "Screen Recording permission needed",
      "permissionTitle": "Allow Screen Recording",
      "permissionMessage": "%@ reads only the region you select for local OCR. No audio or background screen video is ever recorded.",
      "grantPermissionButton": "Authorize…",
      "noClipboardImage": "No image on clipboard",
      "recognizingText": "Recognizing text…",
      "noTextFound": "No text detected in selection",
      "copiedText": "Copied to clipboard",
      "copiedCharsCount": "Copied %d chars",
      "recognitionFailed": "Recognition failed: %@",
      "recentCaptures": "Recent Captures",
      "clearHistory": "Clear",
      "emptyHistoryTitle": "No Recent Captures",
      "emptyHistorySubtitle": "Press %@ to select any region on screen. Recognized snippets stay in memory for quick copy.",
      "quickSettings": "Profile",
      "overlayMode": "In-Place Overlay",
      "splitCompareMode": "Side-by-Side",
      "sourceTextLabel": "Original",
      "translatedTextLabel": "Translation",
      "translatingProgress": "Translating %d/%d…",
      "charactersUnit": "%d chars",
      "justNow": "Just now",
      "cancelRecordingHint": "Esc to cancel",
      "ok": "OK"
    ],
    "zh-Hans": [
      "waitingForShortcut": "就绪",
      "openSettings": "设置…",
      "captureWithShortcut": "%@ 框选识别",
      "translateWithShortcut": "%@ 框选翻译",
      "recognizeClipboard": "识别剪贴板图片",
      "quitApp": "退出 %@",
      "shortcutEnabled": "%@ 已就绪",
      "pressNewShortcut": "请按下快捷键组合…",
      "invalidShortcut": "该组合键已被系统、其他应用或 Yamazaki 占用",
      "recognitionLanguageSet": "识别引擎：%@",
      "textDirectionSet": "扫描方向：%@",
      "resultLayoutSet": "排版模式：%@",
      "appSettings": "%@ 设置",
      "subtitle": "随时按下 %@ 框选屏幕区域，本地离线识别多语言文字并直达剪贴板。",
      "general": "通用",
      "hotKey": "快捷键",
      "textDirection": "扫描方向",
      "resultLayout": "排版与字号",
      "startAtLogin": "登录时自动启动",
      "startAtLoginCaption": "进入 macOS 桌面后自动在菜单栏驻留 Yamazaki。",
      "startAtLoginEnabled": "已开启登录自启",
      "startAtLoginDisabled": "已关闭登录自启",
      "autoRestart": "后台守护自动恢复",
      "autoRestartCaption": "通过用户级 LaunchAgent 守护，异常退出时自动静默拉起。",
      "autoRestartEnabled": "已开启后台守护",
      "autoRestartDisabled": "已关闭后台守护",
      "muteSuccessSound": "静音成功提示音",
      "muteSuccessSoundCaption": "关闭识别文字写入剪贴板时的轻快门音效。",
      "showFloatingHUD": "显示屏幕灵动反馈胶囊",
      "showFloatingHUDCaption": "识别与复制完成时，在屏幕顶部非抢焦点展示 Liquid Glass 状态胶囊。",
      "ignoreWatermarkText": "自动过滤背景水印",
      "ignoreWatermarkCaption": "复制前自动剔除重复、低对比度或超大字号的背景斜向水印。",
      "uiLanguage": "界面语言",
      "recognitionLanguage": "识别语言配置",
      "languageNote": "识别全程基于 Apple Vision 本地离线完成，内置子进程隔离与自动自愈。",
      "shortcutHintIdle": "点击录制后直接按下新组合键",
      "shortcutHintRecording": "正在监听按键… 按 Esc 取消",
      "successCaption": "框选松手即自动完成识别并写入系统剪贴板，可直接 ⌘V 粘贴。",
      "setShortcut": "录制快捷键",
      "resetDefault": "恢复默认",
      "testShortcut": "立即试按",
      "captureSelection": "框选识别",
      "translateSelection": "框选翻译",
      "translationLanguage": "截图翻译目标语言",
      "translationLanguageSet": "翻译目标：%@",
      "horizontalScan": "横向阅读扫描",
      "horizontalSubtitle": "适用于网页、论文、代码、表格及中英日多语混排界面。",
      "verticalScan": "竖排古籍与日漫扫描",
      "verticalSubtitle": "适用于竖排繁体古籍、日文书刊、漫画对白与竖向标牌。",
      "smartLayout": "智能自然段合并",
      "smartSubtitle": "自动拼接跨行长句并保留列表编号与句末分段，适合阅读与摘录。",
      "lineLayout": "严格逐行保留",
      "lineSubtitle": "原样保留每一行换行结构，适合代码片段、票据与表格数据。",
      "resultFontSize": "对照工作台与预览字号",
      "livePreviewTitle": "实时排版效果预览",
      "livePreviewSampleLine1": "Yamazaki 采用 macOS 27 原生 Vision 离线识别引擎，",
      "livePreviewSampleLine2": "内置子进程隔离与空闲自愈机制，持久运行依然稳健。",
      "livePreviewSampleLine3": "1. 框选即入剪贴板  •  2. 零云端上传保护隐私",
      "ocrPrivacyCaption": "所有框选图像仅在本地内存处理后即时销毁，绝不上传网络。",
      "languagePrivacy": "语言与离线引擎",
      "translationPrivacyCaption": "截图翻译调用 macOS 原生 Translation 框架。",
      "behavior": "交互反馈与启动",
      "shortcutConflictHint": "录制时会自动检测内部与系统热键占用。推荐使用 Command + 数字 或 Command + Shift 组合。",
      "copyButton": "复制全部译文",
      "copiedBadge": "已复制",
      "needPermissionStatus": "需开启屏幕录制权限",
      "permissionTitle": "需要屏幕录制权限",
      "permissionMessage": "%@ 仅读取你手动框选的屏幕区域用于本地文字识别，绝不录音或后台录屏。",
      "grantPermissionButton": "前往授权…",
      "noClipboardImage": "剪贴板中暂无图片",
      "recognizingText": "正在识别文字…",
      "noTextFound": "所选区域未检测到文字",
      "copiedText": "已复制识别结果",
      "copiedCharsCount": "已复制 %d 字",
      "recognitionFailed": "识别失败：%@",
      "recentCaptures": "最近识别记录",
      "clearHistory": "清空",
      "emptyHistoryTitle": "暂无最近识别记录",
      "emptyHistorySubtitle": "按下 %@ 框选屏幕任意文字，识别结果会自动复制并暂存于此（仅内存保留）。",
      "quickSettings": "识别模式",
      "overlayMode": "原图定位",
      "splitCompareMode": "双栏对照",
      "sourceTextLabel": "识别原文",
      "translatedTextLabel": "目标译文",
      "translatingProgress": "正在翻译 %d/%d…",
      "charactersUnit": "%d 字",
      "justNow": "刚刚",
      "cancelRecordingHint": "按 Esc 取消",
      "ok": "好"
    ],
    "zh-Hant": [
      "waitingForShortcut": "就緒",
      "openSettings": "設定…",
      "captureWithShortcut": "%@ 框選識別",
      "translateWithShortcut": "%@ 框選翻譯",
      "recognizeClipboard": "識別剪貼簿圖片",
      "quitApp": "結束 %@",
      "shortcutEnabled": "%@ 已就緒",
      "pressNewShortcut": "請按下快捷鍵組合…",
      "invalidShortcut": "此組合鍵已被系統、其他軟件或 Yamazaki 佔用",
      "recognitionLanguageSet": "識別引擎：%@",
      "textDirectionSet": "掃描方向：%@",
      "resultLayoutSet": "排版模式：%@",
      "appSettings": "%@ 設定",
      "subtitle": "隨時按下 %@ 框選畫面區域，本機離線識別多語文字並直達剪貼簿。",
      "general": "一般",
      "hotKey": "快捷鍵",
      "textDirection": "掃描方向",
      "resultLayout": "排版與字級",
      "startAtLogin": "登入時自動啟動",
      "startAtLoginCaption": "登入 macOS 後自動在選單列常駐 Yamazaki。",
      "startAtLoginEnabled": "已開啟登入自啟",
      "startAtLoginDisabled": "已關閉登入自啟",
      "autoRestart": "背景守護自動恢復",
      "autoRestartCaption": "透過用戶級 LaunchAgent 守護，異常結束時自動靜默重開。",
      "autoRestartEnabled": "已開啟背景守護",
      "autoRestartDisabled": "已關閉背景守護",
      "muteSuccessSound": "靜音成功提示音",
      "muteSuccessSoundCaption": "關閉文字寫入剪貼簿時的輕快門音效。",
      "showFloatingHUD": "顯示畫面靈動提示膠囊",
      "showFloatingHUDCaption": "識別與複製完成時，在畫面頂部非搶焦點展示 Liquid Glass 狀態膠囊。",
      "ignoreWatermarkText": "自動過濾背景水印",
      "ignoreWatermarkCaption": "複製前自動剔除重複、低對比度或超大字級的背景水印文字。",
      "uiLanguage": "介面語言",
      "recognitionLanguage": "識別語言設定",
      "languageNote": "識別全程基於 Apple Vision 本機離線完成，內置子進程隔離與自動自癒。",
      "shortcutHintIdle": "點擊錄製後直接按下新組合鍵",
      "shortcutHintRecording": "正在監聽按鍵… 按 Esc 取消",
      "successCaption": "框選放開即自動完成識別並寫入剪貼簿，可直接 ⌘V 貼上。",
      "setShortcut": "錄製快捷鍵",
      "resetDefault": "還原預設",
      "testShortcut": "立即試按",
      "captureSelection": "框選識別",
      "translateSelection": "框選翻譯",
      "translationLanguage": "截圖翻譯目標語言",
      "translationLanguageSet": "翻譯目標：%@",
      "horizontalScan": "橫向閱讀掃描",
      "horizontalSubtitle": "適用於網頁、文件、程式碼、表格及中英日多語混排畫面。",
      "verticalScan": "直排書籍與日漫掃描",
      "verticalSubtitle": "適用於直排繁體書刊、日文文庫本與漫畫對白。",
      "smartLayout": "智慧自然段合併",
      "smartSubtitle": "自動拼接跨行長句並保留清單編號與句末分段，適合閱讀與摘錄。",
      "lineLayout": "嚴格逐行保留",
      "lineSubtitle": "原樣保留每一行換行結構，適合程式碼片段、單據與表格資料。",
      "resultFontSize": "對照工作台與預覽字級",
      "livePreviewTitle": "即時排版效果預覽",
      "livePreviewSampleLine1": "Yamazaki 採用 macOS 27 原生 Vision 離線識別引擎，",
      "livePreviewSampleLine2": "內置子進程隔離與空閒自癒機制，長時間運作依然穩健。",
      "livePreviewSampleLine3": "1. 框選即入剪貼簿  •  2. 零雲端上傳保障私隱",
      "ocrPrivacyCaption": "所有框選圖像僅在本機記憶體裏處理後即時銷毀，絕不上傳網絡。",
      "languagePrivacy": "語言與離線引擎",
      "translationPrivacyCaption": "截圖翻譯呼叫 macOS 原生 Translation 框架。",
      "behavior": "互動回饋與啟動",
      "shortcutConflictHint": "錄製時會自動檢測內部與系統熱鍵佔用。建議使用 Command + 數字 或 Command + Shift 組合。",
      "copyButton": "複製全部譯文",
      "copiedBadge": "已複製",
      "needPermissionStatus": "需開啟螢幕錄製權限",
      "permissionTitle": "需要螢幕錄製權限",
      "permissionMessage": "%@ 只讀取你手動框選的畫面區域作本機文字識別，絕不錄音或背景錄影。",
      "grantPermissionButton": "前往授權…",
      "noClipboardImage": "剪貼簿裏沒有圖片",
      "recognizingText": "正在識別文字…",
      "noTextFound": "所選區域未偵測到文字",
      "copiedText": "已複製識別結果",
      "copiedCharsCount": "已複製 %d 字",
      "recognitionFailed": "識別失敗：%@",
      "recentCaptures": "最近識別紀錄",
      "clearHistory": "清空",
      "emptyHistoryTitle": "暫無最近識別紀錄",
      "emptyHistorySubtitle": "按下 %@ 框選畫面任意文字，識別結果會自動複製並暫存於此（僅記憶體保留）。",
      "quickSettings": "識別模式",
      "overlayMode": "原圖定位",
      "splitCompareMode": "雙欄對照",
      "sourceTextLabel": "識別原文",
      "translatedTextLabel": "目標譯文",
      "translatingProgress": "正在翻譯 %d/%d…",
      "charactersUnit": "%d 字",
      "justNow": "剛剛",
      "cancelRecordingHint": "按 Esc 取消",
      "ok": "確定"
    ],
    "ja": [
      "waitingForShortcut": "準備完了",
      "openSettings": "設定…",
      "captureWithShortcut": "%@ 範囲認識",
      "translateWithShortcut": "%@ 範囲翻訳",
      "recognizeClipboard": "クリップボード画像を認識",
      "quitApp": "%@ を終了",
      "shortcutEnabled": "%@ 有効",
      "appSettings": "%@ 設定",
      "general": "一般",
      "hotKey": "ショートカット",
      "textDirection": "スキャン方向",
      "resultLayout": "レイアウト",
      "captureSelection": "範囲を認識",
      "translateSelection": "範囲を翻訳",
      "copyButton": "すべてコピー",
      "copiedBadge": "コピー済み",
      "recognizingText": "テキストを認識中…",
      "noTextFound": "テキストが見つかりません",
      "copiedText": "クリップボードにコピーしました",
      "copiedCharsCount": "%d 文字をコピー",
      "recentCaptures": "最近の認識履歴",
      "clearHistory": "消去",
      "overlayMode": "画像オーバーレイ",
      "splitCompareMode": "2列比較"
    ],
    "ko": [
      "waitingForShortcut": "준비됨",
      "openSettings": "설정…",
      "captureWithShortcut": "%@ 영역 인식",
      "translateWithShortcut": "%@ 영역 번역",
      "recognizeClipboard": "클립보드 이미지 인식",
      "quitApp": "%@ 종료",
      "shortcutEnabled": "%@ 활성화",
      "appSettings": "%@ 설정",
      "general": "일반",
      "hotKey": "단축키",
      "textDirection": "스캔 방향",
      "resultLayout": "레이아웃",
      "captureSelection": "영역 인식",
      "translateSelection": "영역 번역",
      "copyButton": "전체 복사",
      "copiedBadge": "복사됨",
      "recognizingText": "텍스트 인식 중…",
      "copiedCharsCount": "%d자 복사됨",
      "recentCaptures": "최근 인식 기록",
      "clearHistory": "지우기",
      "overlayMode": "원본 오버레이",
      "splitCompareMode": "나란히 보기"
    ],
    "fr": [
      "waitingForShortcut": "Prêt",
      "openSettings": "Réglages…",
      "captureSelection": "Reconnaître la zone",
      "translateSelection": "Traduire la zone",
      "recognizeClipboard": "Image du presse-papiers",
      "quitApp": "Quitter %@",
      "general": "Général",
      "hotKey": "Raccourcis",
      "textDirection": "Direction",
      "resultLayout": "Mise en page",
      "copyButton": "Tout copier",
      "copiedBadge": "Copié",
      "recentCaptures": "Captures récentes"
    ],
    "pt": [
      "waitingForShortcut": "Pronto",
      "openSettings": "Ajustes…",
      "captureSelection": "Reconhecer área",
      "translateSelection": "Traduzir área",
      "recognizeClipboard": "Imagem copiada",
      "quitApp": "Sair do %@",
      "general": "Geral",
      "hotKey": "Atalhos",
      "textDirection": "Direção",
      "resultLayout": "Layout",
      "copyButton": "Copiar tudo",
      "copiedBadge": "Copiado",
      "recentCaptures": "Recentes"
    ],
    "es": [
      "waitingForShortcut": "Listo",
      "openSettings": "Ajustes…",
      "captureSelection": "Reconocer área",
      "translateSelection": "Traducir área",
      "recognizeClipboard": "Imagen del portapapeles",
      "quitApp": "Salir de %@",
      "general": "General",
      "hotKey": "Atajos",
      "textDirection": "Dirección",
      "resultLayout": "Diseño",
      "copyButton": "Copiar todo",
      "copiedBadge": "Copiado",
      "recentCaptures": "Recientes"
    ],
    "de": [
      "waitingForShortcut": "Bereit",
      "openSettings": "Einstellungen…",
      "captureSelection": "Bereich erkennen",
      "translateSelection": "Bereich übersetzen",
      "recognizeClipboard": "Zwischenablage erkennen",
      "quitApp": "%@ beenden",
      "general": "Allgemein",
      "hotKey": "Kurzbefehle",
      "textDirection": "Leserichtung",
      "resultLayout": "Layout",
      "copyButton": "Alles kopieren",
      "copiedBadge": "Kopiert",
      "recentCaptures": "Verlauf"
    ],
    "th": [
      "waitingForShortcut": "พร้อมใช้งาน",
      "openSettings": "การตั้งค่า…",
      "captureSelection": "สแกนข้อความ",
      "translateSelection": "แปลพื้นที่",
      "recognizeClipboard": "รูปในคลิปบอร์ด",
      "quitApp": "ออกจาก %@",
      "general": "ทั่วไป",
      "hotKey": "ปุ่มลัด",
      "textDirection": "ทิศทาง",
      "resultLayout": "การจัดหน้า",
      "copyButton": "คัดลอกทั้งหมด",
      "copiedBadge": "คัดลอกแล้ว",
      "recentCaptures": "ประวัติล่าสุด"
    ]
  ]
}
