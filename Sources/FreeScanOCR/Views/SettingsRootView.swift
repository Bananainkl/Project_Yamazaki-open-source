import AppKit
import Carbon.HIToolbox
import SwiftUI

struct SettingsRootView: View {
  let model: AppStateModel
  let actions: SettingsActions
  var initialSection: SettingsSection = .general

  @State private var selectedSection: SettingsSection
  @State private var isRecordingShortcut = false
  @State private var isRecordingTranslationShortcut = false
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  init(model: AppStateModel, actions: SettingsActions, initialSection: SettingsSection = .general) {
    self.model = model
    self.actions = actions
    self.initialSection = initialSection
    _selectedSection = State(initialValue: initialSection)
  }

  var body: some View {
    let _ = model.uiRefreshToken
    NavigationSplitView(columnVisibility: .constant(.all)) {
      List(SettingsSection.allCases, selection: $selectedSection) { section in
        Label(section.title, systemImage: section.symbolName)
          .tag(section)
      }
      .listStyle(.sidebar)
      .navigationSplitViewColumnWidth(min: 185, ideal: 205, max: 230)
    } detail: {
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
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .navigationTitle(selectedSection.title)
      .toolbar {
        ToolbarItem(placement: .automatic) {
          HStack(spacing: 6) {
            Image(systemName: model.statusKind.symbolName)
              .font(.system(size: 12, weight: .semibold))
              .foregroundStyle(model.statusKind.foregroundColor(scheme: colorScheme, contrast: contrast))
              .contentTransition(.symbolEffect(.replace))
            Text(model.status)
              .font(.system(size: 12, weight: .medium))
              .foregroundStyle(.secondary)
              .lineLimit(1)
          }
          .padding(.horizontal, DesignSpacing.xs)
        }

        ToolbarSpacer(.fixed)

        ToolbarItem(placement: .primaryAction) {
          Button {
            actions.captureSelection()
          } label: {
            Label(LocalizedText.tr(.captureSelection), systemImage: "viewfinder")
          }
          .help(LocalizedText.tr(.captureWithShortcut, model.shortcutText))
        }
      }
    }
    .frame(minWidth: 760, idealWidth: 840, minHeight: 540, idealHeight: 620)
    .environment(\.locale, LocalizedText.locale)
    .animation(DesignMotion.snappy(reduceMotion: reduceMotion), value: selectedSection)
  }
}

private struct GeneralSettingsPane: View {
  let model: AppStateModel
  let actions: SettingsActions

  var body: some View {
    Form {
      Section {
        Picker(LocalizedText.tr(.uiLanguage), selection: Binding(
          get: { model.uiLanguage },
          set: { lang in
            model.uiLanguage = lang
            actions.setUILanguage(lang)
          }
        )) {
          ForEach(AppPreferences.UILanguage.allCases, id: \.self) { language in
            Text(language.title).tag(language)
          }
        }

        Picker(LocalizedText.tr(.recognitionLanguage), selection: Binding(
          get: { model.languageMode },
          set: { mode in
            model.languageMode = mode
            actions.setLanguageMode(mode)
          }
        )) {
          ForEach(AppPreferences.LanguageMode.allCases, id: \.self) { mode in
            Text(mode.title).tag(mode)
          }
        }

        Picker(LocalizedText.tr(.translationLanguage), selection: Binding(
          get: { model.translationLanguage },
          set: { lang in
            model.translationLanguage = lang
            actions.setTranslationLanguage(lang)
          }
        )) {
          ForEach(AppPreferences.TranslationLanguage.allCases, id: \.self) { language in
            Text(language.title).tag(language)
          }
        }
      } header: {
        Text(LocalizedText.tr(.languagePrivacy))
      } footer: {
        Text("\(LocalizedText.tr(.languageNote)) \(LocalizedText.tr(.ocrPrivacyCaption))")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }

      Section {
        SettingsToggleRow(
          title: LocalizedText.tr(.showFloatingHUD),
          subtitle: LocalizedText.tr(.showFloatingHUDCaption),
          systemImage: "menubar.dock.rectangle",
          isOn: Binding(
            get: { model.showFloatingHUD },
            set: { value in
              model.showFloatingHUD = value
              actions.setShowFloatingHUD(value)
            }
          )
        )

        SettingsToggleRow(
          title: LocalizedText.tr(.muteSuccessSound),
          subtitle: LocalizedText.tr(.muteSuccessSoundCaption),
          systemImage: "speaker.slash",
          isOn: Binding(
            get: { model.muteSuccessSound },
            set: { value in
              model.muteSuccessSound = value
              actions.setMuteSound(value)
            }
          )
        )

        SettingsToggleRow(
          title: LocalizedText.tr(.ignoreWatermarkText),
          subtitle: LocalizedText.tr(.ignoreWatermarkCaption),
          systemImage: "eye.slash",
          isOn: Binding(
            get: { model.ignoreWatermarkText },
            set: { value in
              model.ignoreWatermarkText = value
              actions.setIgnoreWatermarkText(value)
            }
          )
        )

        SettingsToggleRow(
          title: LocalizedText.tr(.startAtLogin),
          subtitle: LocalizedText.tr(.startAtLoginCaption),
          systemImage: "power",
          isOn: Binding(
            get: { model.startAtLogin },
            set: { value in
              model.startAtLogin = value
              actions.setStartAtLogin(value)
            }
          )
        )

        SettingsToggleRow(
          title: LocalizedText.tr(.autoRestart),
          subtitle: LocalizedText.tr(.autoRestartCaption),
          systemImage: "arrow.trianglehead.2.clockwise.rotate.90",
          isOn: Binding(
            get: { model.autoRestart },
            set: { value in
              model.autoRestart = value
              actions.setAutoRestart(value)
            }
          )
        )
      } header: {
        Text(LocalizedText.tr(.behavior))
      }
    }
    .formStyle(.grouped)
  }
}

private struct SettingsToggleRow: View {
  let title: String
  let subtitle: String
  let systemImage: String
  @Binding var isOn: Bool

  var body: some View {
    Toggle(isOn: $isOn) {
      HStack(alignment: .top, spacing: DesignSpacing.sm) {
        Image(systemName: systemImage)
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(.secondary)
          .frame(width: 20, height: 20)
          .padding(.top, 1)

        VStack(alignment: .leading, spacing: 3) {
          Text(title)
            .font(.body.weight(.medium))
            .foregroundStyle(.primary)
          Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
    }
    .toggleStyle(.switch)
  }
}

private struct HotKeySettingsPane: View {
  let model: AppStateModel
  @Binding var isRecordingShortcut: Bool
  @Binding var isRecordingTranslationShortcut: Bool
  let actions: SettingsActions

  var body: some View {
    Form {
      Section {
        ShortcutBindingRow(
          title: LocalizedText.tr(.captureSelection),
          subtitle: LocalizedText.tr(.successCaption),
          iconName: "viewfinder",
          shortcutText: model.shortcutText,
          defaultShortcutText: HotKeyPreference.defaultShortcut().displayText,
          isRecording: $isRecordingShortcut,
          onStartRecording: {
            isRecordingTranslationShortcut = false
            actions.startShortcutRecording()
          },
          onCancelRecording: {
            isRecordingShortcut = false
          },
          onShortcut: actions.setShortcut,
          onInvalidShortcut: actions.invalidShortcut,
          onResetDefault: actions.resetDefaultShortcut,
          onTest: actions.captureSelection
        )

        ShortcutBindingRow(
          title: LocalizedText.tr(.translateSelection),
          subtitle: LocalizedText.tr(.translationPrivacyCaption),
          iconName: "translate",
          shortcutText: model.translationShortcutText,
          defaultShortcutText: HotKeyPreference.defaultTranslationShortcut().displayText,
          isRecording: $isRecordingTranslationShortcut,
          onStartRecording: {
            isRecordingShortcut = false
            actions.startTranslationShortcutRecording()
          },
          onCancelRecording: {
            isRecordingTranslationShortcut = false
          },
          onShortcut: actions.setTranslationShortcut,
          onInvalidShortcut: actions.invalidShortcut,
          onResetDefault: actions.resetDefaultTranslationShortcut,
          onTest: actions.translateSelection
        )
      } header: {
        Text(LocalizedText.tr(.hotKey))
      } footer: {
        Text(LocalizedText.tr(.shortcutConflictHint))
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
    }
    .formStyle(.grouped)
  }
}

private struct ShortcutBindingRow: View {
  let title: String
  let subtitle: String
  let iconName: String
  let shortcutText: String
  let defaultShortcutText: String
  @Binding var isRecording: Bool
  let onStartRecording: () -> Void
  let onCancelRecording: () -> Void
  let onShortcut: (HotKeyPreference) -> Void
  let onInvalidShortcut: () -> Void
  let onResetDefault: () -> Void
  let onTest: () -> Void

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    VStack(alignment: .leading, spacing: DesignSpacing.sm) {
      HStack(alignment: .center, spacing: DesignSpacing.sm) {
        Image(systemName: iconName)
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(Color.accentColor)
          .frame(width: 32, height: 32)
          .adaptiveCard(cornerRadius: DesignRadius.xs)

        VStack(alignment: .leading, spacing: 3) {
          Text(title)
            .font(.body.weight(.semibold))
            .foregroundStyle(.primary)
          Text(isRecording ? LocalizedText.tr(.shortcutHintRecording) : subtitle)
            .font(.subheadline)
            .foregroundStyle(isRecording ? Color.accentColor : .secondary)
            .lineLimit(2)
        }

        Spacer(minLength: DesignSpacing.sm)

        if isRecording {
          HStack(spacing: 6) {
            Circle()
              .fill(Color.accentColor)
              .frame(width: 7, height: 7)
            Text(LocalizedText.tr(.cancelRecordingHint))
              .font(.system(size: 12, weight: .semibold))
              .foregroundStyle(Color.accentColor)
          }
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .adaptiveCard(cornerRadius: DesignRadius.xs, isSelected: true)
        } else {
          KeycapBadgesView(shortcutText: shortcutText)
        }
      }

      GlassEffectContainer(spacing: DesignSpacing.xs) {
        HStack(spacing: DesignSpacing.xs) {
          Button {
            withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
              if isRecording {
                onCancelRecording()
              } else {
                isRecording = true
                onStartRecording()
              }
            }
          } label: {
            Label(
              isRecording ? LocalizedText.tr(.cancelRecordingHint) : LocalizedText.tr(.setShortcut),
              systemImage: isRecording ? "xmark.circle" : "keyboard"
            )
          }
          .buttonStyle(.glass)
          .controlSize(.small)

          if shortcutText != defaultShortcutText {
            Button(LocalizedText.tr(.resetDefault)) {
              onCancelRecording()
              onResetDefault()
            }
            .buttonStyle(.glass)
            .controlSize(.small)
          }

          Spacer()

          Button {
            onCancelRecording()
            onTest()
          } label: {
            Label(LocalizedText.tr(.testShortcut), systemImage: iconName)
          }
          .buttonStyle(.glassProminent)
          .controlSize(.small)
        }
      }
    }
    .padding(.vertical, DesignSpacing.xxs)
    .background(
      ShortcutRecorderRepresentable(
        isRecording: $isRecording,
        onShortcut: onShortcut,
        onInvalidShortcut: onInvalidShortcut,
        onCancel: onCancelRecording
      )
      .frame(width: 1, height: 1)
      .opacity(0.01)
      .accessibilityHidden(true)
    )
  }
}

private struct TextDirectionPane: View {
  let model: AppStateModel
  let actions: SettingsActions

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    Form {
      Section {
        HStack(spacing: DesignSpacing.md) {
          VisualModeOptionCard(
            title: LocalizedText.tr(.horizontalScan),
            subtitle: LocalizedText.tr(.horizontalSubtitle),
            systemImage: "text.alignleft",
            isSelected: model.textDirection == .horizontal,
            diagram: .horizontalLines
          ) {
            withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
              model.textDirection = .horizontal
              actions.setTextDirection(.horizontal)
            }
          }

          VisualModeOptionCard(
            title: LocalizedText.tr(.verticalScan),
            subtitle: LocalizedText.tr(.verticalSubtitle),
            systemImage: "text.word.spacing",
            isSelected: model.textDirection == .vertical,
            diagram: .verticalColumns
          ) {
            withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
              model.textDirection = .vertical
              actions.setTextDirection(.vertical)
            }
          }
        }
        .padding(.vertical, DesignSpacing.xs)
      } header: {
        Text(LocalizedText.tr(.textDirection))
      }
    }
    .formStyle(.grouped)
  }
}

private struct ResultLayoutPane: View {
  let model: AppStateModel
  let actions: SettingsActions

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private var previewFormattedText: String {
    let l1 = LocalizedText.tr(.livePreviewSampleLine1)
    let l2 = LocalizedText.tr(.livePreviewSampleLine2)
    let l3 = LocalizedText.tr(.livePreviewSampleLine3)
    if model.resultLayout == .lines {
      return [l1, l2, l3].joined(separator: "\n")
    }
    let joiner = LocalizedText.languageCode.hasPrefix("zh") || LocalizedText.languageCode == "ja" ? "" : " "
    return "\(l1)\(joiner)\(l2)\n\(l3)"
  }

  var body: some View {
    Form {
      Section {
        HStack(spacing: DesignSpacing.md) {
          VisualModeOptionCard(
            title: LocalizedText.tr(.smartLayout),
            subtitle: LocalizedText.tr(.smartSubtitle),
            systemImage: "text.justify.left",
            isSelected: model.resultLayout == .smart,
            diagram: .smartParagraph
          ) {
            withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
              model.resultLayout = .smart
              actions.setResultLayout(.smart)
            }
          }

          VisualModeOptionCard(
            title: LocalizedText.tr(.lineLayout),
            subtitle: LocalizedText.tr(.lineSubtitle),
            systemImage: "list.bullet.rectangle.portrait",
            isSelected: model.resultLayout == .lines,
            diagram: .strictLines
          ) {
            withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
              model.resultLayout = .lines
              actions.setResultLayout(.lines)
            }
          }
        }
        .padding(.vertical, DesignSpacing.xs)

        HStack(spacing: DesignSpacing.md) {
          Text(LocalizedText.tr(.resultFontSize))
            .font(.body.weight(.medium))
          Spacer()
          Slider(
            value: Binding(
              get: { Double(model.resultFontSize) },
              set: { newVal in
                let clamped = Int(newVal.rounded())
                model.resultFontSize = clamped
                actions.setResultFontSize(clamped)
              }
            ),
            in: 10...28,
            step: 1
          )
          .frame(width: 220)

          Text("\(model.resultFontSize) pt")
            .font(.system(size: 13, weight: .semibold, design: .monospaced))
            .foregroundStyle(.secondary)
            .contentTransition(.numericText())
            .frame(width: 48, alignment: .trailing)
        }
      } header: {
        Text(LocalizedText.tr(.resultLayout))
      }

      Section {
        Text(previewFormattedText)
          .font(.system(size: CGFloat(model.resultFontSize), weight: .regular))
          .foregroundStyle(.primary)
          .lineSpacing(4)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, DesignSpacing.xs)
          .animation(DesignMotion.snappy(reduceMotion: reduceMotion), value: model.resultLayout)
          .animation(DesignMotion.snappy(reduceMotion: reduceMotion), value: model.resultFontSize)
      } header: {
        Text(LocalizedText.tr(.livePreviewTitle))
      }
    }
    .formStyle(.grouped)
  }
}

private enum CardDiagramKind {
  case horizontalLines
  case verticalColumns
  case smartParagraph
  case strictLines
}

private struct VisualModeOptionCard: View {
  let title: String
  let subtitle: String
  let systemImage: String
  let isSelected: Bool
  let diagram: CardDiagramKind
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: DesignSpacing.sm) {
        HStack {
          Image(systemName: systemImage)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(isSelected ? Color.accentColor : .secondary)

          Spacer()

          Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.5))
            .contentTransition(.symbolEffect(.replace))
        }

        diagramPreview
          .frame(height: 44)
          .frame(maxWidth: .infinity)
          .padding(.horizontal, DesignSpacing.xs)
          .adaptiveCard(cornerRadius: DesignRadius.xs)

        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.primary)
          Text(subtitle)
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(3)
        }
      }
      .padding(DesignSpacing.md)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .adaptiveCard(cornerRadius: DesignRadius.md, isSelected: isSelected)
      .contentShape(RoundedRectangle(cornerRadius: DesignRadius.md, style: .continuous))
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }

  @ViewBuilder
  private var diagramPreview: some View {
    let barColor = isSelected ? Color.accentColor.opacity(0.65) : Color.secondary.opacity(0.32)
    switch diagram {
    case .horizontalLines:
      VStack(alignment: .leading, spacing: 6) {
        Capsule().fill(barColor).frame(width: 110, height: 4)
        Capsule().fill(barColor).frame(width: 140, height: 4)
        Capsule().fill(barColor).frame(width: 82, height: 4)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

    case .verticalColumns:
      HStack(alignment: .top, spacing: 10) {
        Capsule().fill(barColor).frame(width: 4, height: 28)
        Capsule().fill(barColor).frame(width: 4, height: 32)
        Capsule().fill(barColor).frame(width: 4, height: 22)
        Capsule().fill(barColor).frame(width: 4, height: 30)
      }
      .frame(maxWidth: .infinity, alignment: .center)

    case .smartParagraph:
      VStack(alignment: .leading, spacing: 5) {
        Capsule().fill(barColor).frame(maxWidth: .infinity).frame(height: 4)
        Capsule().fill(barColor).frame(width: 120, height: 4)
        Capsule().fill(barColor.opacity(0.65)).frame(width: 96, height: 4).padding(.top, 3)
      }

    case .strictLines:
      VStack(alignment: .leading, spacing: 6) {
        HStack(spacing: 6) {
          Circle().fill(barColor).frame(width: 4, height: 4)
          Capsule().fill(barColor).frame(width: 90, height: 4)
        }
        HStack(spacing: 6) {
          Circle().fill(barColor).frame(width: 4, height: 4)
          Capsule().fill(barColor).frame(width: 116, height: 4)
        }
        HStack(spacing: 6) {
          Circle().fill(barColor).frame(width: 4, height: 4)
          Capsule().fill(barColor).frame(width: 74, height: 4)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

struct ShortcutRecorderRepresentable: NSViewRepresentable {
  @Binding var isRecording: Bool
  let onShortcut: (HotKeyPreference) -> Void
  let onInvalidShortcut: () -> Void
  let onCancel: () -> Void

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
    view.onCancel = {
      context.coordinator.parent.isRecording = false
      context.coordinator.parent.onCancel()
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
      nsView.stopRecording()
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

final class ShortcutRecorderView: NSView {
  var onShortcut: ((HotKeyPreference) -> Void)?
  var onInvalidShortcut: (() -> Void)?
  var onCancel: (() -> Void)?
  private var isRecording = false

  override var acceptsFirstResponder: Bool { true }

  func beginRecording() {
    isRecording = true
    window?.makeFirstResponder(self)
  }

  func stopRecording() {
    isRecording = false
  }

  override func keyDown(with event: NSEvent) {
    guard isRecording else {
      super.keyDown(with: event)
      return
    }

    if event.keyCode == UInt16(kVK_Escape) {
      isRecording = false
      onCancel?()
      return
    }

    guard let shortcut = HotKeyPreference.from(event: event) else {
      NSSound.beep()
      onInvalidShortcut?()
      return
    }

    isRecording = false
    onShortcut?(shortcut)
  }
}
