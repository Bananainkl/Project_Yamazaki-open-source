import AppKit
import Carbon.HIToolbox
import Foundation
import Observation

enum SettingsSection: String, CaseIterable, Identifiable {
  case general
  case hotKey
  case textDirection
  case resultLayout

  var id: String { rawValue }

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
    case .general: return "gearshape"
    case .hotKey: return "command"
    case .textDirection: return "text.viewfinder"
    case .resultLayout: return "text.alignleft"
    }
  }
}

struct RecognizedTextLine: Identifiable, Equatable, Sendable {
  let id = UUID()
  let text: String
  let box: CGRect
}

enum CaptureSourceKind: String, Sendable {
  case regionOCR
  case clipboardOCR
  case translation

  var symbolName: String {
    switch self {
    case .regionOCR: return "viewfinder"
    case .clipboardOCR: return "doc.on.clipboard"
    case .translation: return "translate"
    }
  }
}

struct OCRHistoryItem: Identifiable, Equatable, Sendable {
  let id: UUID
  let text: String
  let characterCount: Int
  let createdAt: Date
  let sourceKind: CaptureSourceKind

  init(text: String, sourceKind: CaptureSourceKind, createdAt: Date = Date()) {
    self.id = UUID()
    self.text = text
    self.characterCount = text.unicodeScalars.filter { !$0.properties.isWhitespace }.count
    self.createdAt = createdAt
    self.sourceKind = sourceKind
  }

  var singleLinePreview: String {
    let collapsed = text
      .replacingOccurrences(of: "\n", with: " ")
      .replacingOccurrences(of: "  ", with: " ")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    if collapsed.count <= 80 {
      return collapsed
    }
    return String(collapsed.prefix(80)) + "…"
  }
}

enum HUDPresentationState: Equatable, Sendable {
  case hidden
  case recognizing
  case copied(charCount: Int, preview: String, eventID: UUID)
  case emptyResult(eventID: UUID)
  case permissionRequired(eventID: UUID)
  case failed(message: String, eventID: UUID)
}

@Observable
@MainActor
final class AppStateModel {
  var shortcutText: String = HotKeyPreference.load().displayText
  var translationShortcutText: String = HotKeyPreference.loadTranslation().displayText
  var status: String = LocalizedText.tr(.waitingForShortcut)
  var statusKind: SemanticStatusKind = .ready
  var statusEventCounter: Int = 0

  var muteSuccessSound: Bool = AppPreferences.muteSuccessSound
  var showFloatingHUD: Bool = AppPreferences.showFloatingHUD
  var ignoreWatermarkText: Bool = AppPreferences.ignoreWatermarkText
  var startAtLogin: Bool = AppPreferences.startAtLogin
  var autoRestart: Bool = AppPreferences.autoRestart
  var uiLanguage: AppPreferences.UILanguage = AppPreferences.uiLanguage
  var languageMode: AppPreferences.LanguageMode = AppPreferences.languageMode
  var translationLanguage: AppPreferences.TranslationLanguage = AppPreferences.translationLanguage
  var textDirection: AppPreferences.TextDirection = AppPreferences.textDirection
  var resultLayout: AppPreferences.ResultLayout = AppPreferences.resultLayout
  var resultFontSize: Int = AppPreferences.resultFontSize

  var recentHistory: [OCRHistoryItem] = []
  var hudState: HUDPresentationState = .hidden
  var uiRefreshToken: UUID = UUID()

  func recordHistory(text: String, sourceKind: CaptureSourceKind) {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    if let first = recentHistory.first, first.text == trimmed {
      return
    }
    let item = OCRHistoryItem(text: trimmed, sourceKind: sourceKind)
    recentHistory.insert(item, at: 0)
    if recentHistory.count > 15 {
      recentHistory.removeLast(recentHistory.count - 15)
    }
  }

  func clearHistory() {
    recentHistory.removeAll()
  }

  func removeHistoryItem(id: UUID) {
    recentHistory.removeAll { $0.id == id }
  }
}

struct SettingsActions {
  let startShortcutRecording: () -> Void
  let startTranslationShortcutRecording: () -> Void
  let cancelShortcutRecording: () -> Void
  let setShortcut: (HotKeyPreference) -> Void
  let setTranslationShortcut: (HotKeyPreference) -> Void
  let resetDefaultShortcut: () -> Void
  let resetDefaultTranslationShortcut: () -> Void
  let invalidShortcut: () -> Void
  let captureSelection: () -> Void
  let translateSelection: () -> Void
  let recognizeClipboard: () -> Void
  let openSettings: () -> Void
  let openPermissionSettings: () -> Void
  let quitApp: () -> Void
  let setMuteSound: (Bool) -> Void
  let setShowFloatingHUD: (Bool) -> Void
  let setIgnoreWatermarkText: (Bool) -> Void
  let setStartAtLogin: (Bool) -> Void
  let setAutoRestart: (Bool) -> Void
  let setLanguageMode: (AppPreferences.LanguageMode) -> Void
  let setTranslationLanguage: (AppPreferences.TranslationLanguage) -> Void
  let setUILanguage: (AppPreferences.UILanguage) -> Void
  let setTextDirection: (AppPreferences.TextDirection) -> Void
  let setResultLayout: (AppPreferences.ResultLayout) -> Void
  let setResultFontSize: (Int) -> Void
  let copyTextToPasteboard: (String) -> Void
}

struct HotKeyPreference: Equatable {
  private static let keyCodeKey = "HotKeyKeyCode"
  private static let modifierKey = "HotKeyModifiers"
  private static let translationKeyCodeKey = "TranslationHotKeyKeyCode"
  private static let translationModifierKey = "TranslationHotKeyModifiers"

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
    return defaultShortcut()
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

  func save() {
    UserDefaults.standard.set(Int(keyCode), forKey: Self.keyCodeKey)
    UserDefaults.standard.set(Int(modifiers.rawValue), forKey: Self.modifierKey)
  }

  func saveTranslation() {
    UserDefaults.standard.set(Int(keyCode), forKey: Self.translationKeyCodeKey)
    UserDefaults.standard.set(Int(modifiers.rawValue), forKey: Self.translationModifierKey)
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
      case .system: return "System / 跟随系统"
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
      case .simplified: return "简体中文 + English"
      case .traditional: return "繁體中文 + English"
      case .japanese: return "日本語 + English"
      case .korean: return "한국어 + English"
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
      case .english: return "English Only"
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

  enum TextDirection: String, CaseIterable {
    case horizontal
    case vertical

    var title: String {
      switch self {
      case .horizontal: return LocalizedText.tr(.horizontalScan)
      case .vertical: return LocalizedText.tr(.verticalScan)
      }
    }
  }

  enum ResultLayout: String, CaseIterable {
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
    static let showFloatingHUD = "ShowFloatingHUD"
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

  static var showFloatingHUD: Bool {
    get {
      if UserDefaults.standard.object(forKey: Key.showFloatingHUD) == nil {
        return true
      }
      return UserDefaults.standard.bool(forKey: Key.showFloatingHUD)
    }
    set { UserDefaults.standard.set(newValue, forKey: Key.showFloatingHUD) }
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

func keyDisplayName(for keyCode: UInt32) -> String {
  let names: [UInt32: String] = [
    UInt32(kVK_ANSI_A): "A", UInt32(kVK_ANSI_B): "B", UInt32(kVK_ANSI_C): "C",
    UInt32(kVK_ANSI_D): "D", UInt32(kVK_ANSI_E): "E", UInt32(kVK_ANSI_F): "F",
    UInt32(kVK_ANSI_G): "G", UInt32(kVK_ANSI_H): "H", UInt32(kVK_ANSI_I): "I",
    UInt32(kVK_ANSI_J): "J", UInt32(kVK_ANSI_K): "K", UInt32(kVK_ANSI_L): "L",
    UInt32(kVK_ANSI_M): "M", UInt32(kVK_ANSI_N): "N", UInt32(kVK_ANSI_O): "O",
    UInt32(kVK_ANSI_P): "P", UInt32(kVK_ANSI_Q): "Q", UInt32(kVK_ANSI_R): "R",
    UInt32(kVK_ANSI_S): "S", UInt32(kVK_ANSI_T): "T", UInt32(kVK_ANSI_U): "U",
    UInt32(kVK_ANSI_V): "V", UInt32(kVK_ANSI_W): "W", UInt32(kVK_ANSI_X): "X",
    UInt32(kVK_ANSI_Y): "Y", UInt32(kVK_ANSI_Z): "Z",
    UInt32(kVK_ANSI_0): "0", UInt32(kVK_ANSI_1): "1", UInt32(kVK_ANSI_2): "2",
    UInt32(kVK_ANSI_3): "3", UInt32(kVK_ANSI_4): "4", UInt32(kVK_ANSI_5): "5",
    UInt32(kVK_ANSI_6): "6", UInt32(kVK_ANSI_7): "7", UInt32(kVK_ANSI_8): "8",
    UInt32(kVK_ANSI_9): "9",
    UInt32(kVK_Space): "Space", UInt32(kVK_Return): "↩", UInt32(kVK_Tab): "⇥",
    UInt32(kVK_F1): "F1", UInt32(kVK_F2): "F2", UInt32(kVK_F3): "F3",
    UInt32(kVK_F4): "F4", UInt32(kVK_F5): "F5", UInt32(kVK_F6): "F6",
    UInt32(kVK_F7): "F7", UInt32(kVK_F8): "F8", UInt32(kVK_F9): "F9",
    UInt32(kVK_F10): "F10", UInt32(kVK_F11): "F11", UInt32(kVK_F12): "F12"
  ]
  return names[keyCode] ?? "Key \(keyCode)"
}

func fourCharacterCode(_ string: String) -> OSType {
  var result: OSType = 0
  for scalar in string.unicodeScalars.prefix(4) {
    result = (result << 8) + OSType(scalar.value)
  }
  return result
}
