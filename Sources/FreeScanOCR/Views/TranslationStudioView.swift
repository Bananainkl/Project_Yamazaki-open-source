import AppKit
import SwiftUI
import Translation
import _Translation_SwiftUI

enum TranslationDisplayMode: String, CaseIterable, Identifiable {
  case overlay
  case splitCompare

  var id: String { rawValue }

  var title: String {
    switch self {
    case .overlay: return LocalizedText.tr(.overlayMode)
    case .splitCompare: return LocalizedText.tr(.splitCompareMode)
    }
  }

  var symbolName: String {
    switch self {
    case .overlay: return "viewfinder.rectangular"
    case .splitCompare: return "rectangle.split.2x1"
    }
  }
}

struct TranslationStudioView: View {
  let image: NSImage
  let lines: [RecognizedTextLine]
  let model: AppStateModel
  let onTargetLanguageChanged: (AppPreferences.TranslationLanguage) -> Void
  let onCopyText: (String) -> Void

  @State private var displayMode: TranslationDisplayMode = .splitCompare
  @State private var targetLanguage: AppPreferences.TranslationLanguage
  @State private var translatedLines: [UUID: String] = [:]
  @State private var hoveredLineID: UUID?
  @State private var copiedLineID: UUID?
  @State private var didCopyAll = false
  @State private var zoomScale: CGFloat = 1.0
  @State private var errorMessage: String?
  @State private var configuration: TranslationSession.Configuration?
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  init(
    image: NSImage,
    lines: [RecognizedTextLine],
    initialTargetLanguage: AppPreferences.TranslationLanguage,
    prefilledTranslations: [UUID: String] = [:],
    initialDisplayMode: TranslationDisplayMode = .splitCompare,
    model: AppStateModel,
    onTargetLanguageChanged: @escaping (AppPreferences.TranslationLanguage) -> Void,
    onCopyText: @escaping (String) -> Void
  ) {
    self.image = image
    self.lines = lines
    self.model = model
    self.onTargetLanguageChanged = onTargetLanguageChanged
    self.onCopyText = onCopyText
    _displayMode = State(initialValue: initialDisplayMode)
    _targetLanguage = State(initialValue: initialTargetLanguage)
    _translatedLines = State(initialValue: prefilledTranslations)
    _configuration = State(initialValue: prefilledTranslations.isEmpty ? TranslationSession.Configuration(
      source: nil,
      target: initialTargetLanguage.localeLanguage
    ) : nil)
  }

  private var isTranslating: Bool {
    !lines.isEmpty && translatedLines.count < lines.count && errorMessage == nil
  }

  var body: some View {
    Group {
      switch displayMode {
      case .overlay:
        overlayCanvas
      case .splitCompare:
        splitCompareCanvas
      }
    }
    .frame(minWidth: 700, idealWidth: 920, minHeight: 480, idealHeight: 600)
    .environment(\.locale, LocalizedText.locale)
    .navigationTitle(LocalizedText.tr(.translateSelection))
    .toolbar {
      ToolbarItem(placement: .navigation) {
        Picker("", selection: $displayMode) {
          ForEach(TranslationDisplayMode.allCases) { mode in
            Text(mode.title)
              .tag(mode)
          }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(width: 196)
      }

      ToolbarSpacer(.flexible)

      if isTranslating {
        ToolbarItem(placement: .automatic) {
          HStack(spacing: 6) {
            ProgressView()
              .controlSize(.small)
            Text(LocalizedText.tr(.translatingProgress, translatedLines.count, lines.count))
              .font(.system(size: 12, weight: .medium))
              .foregroundStyle(.secondary)
              .contentTransition(.numericText())
              .fixedSize()
          }
          .padding(.horizontal, DesignSpacing.xs)
        }
      }

      ToolbarItem(placement: .automatic) {
        Picker(LocalizedText.tr(.translationLanguage), selection: Binding(
          get: { targetLanguage },
          set: { newLanguage in
            guard newLanguage != targetLanguage else { return }
            targetLanguage = newLanguage
            onTargetLanguageChanged(newLanguage)
            restartTranslation(for: newLanguage)
          }
        )) {
          ForEach(AppPreferences.TranslationLanguage.allCases, id: \.self) { lang in
            Text(lang.title).tag(lang)
          }
        }
        .frame(width: 150)
      }

      ToolbarSpacer(.fixed)

      ToolbarItem(placement: .primaryAction) {
        Button {
          copyAllTranslatedText()
        } label: {
          Label(
            didCopyAll ? LocalizedText.tr(.copiedBadge) : LocalizedText.tr(.copyButton),
            systemImage: didCopyAll ? "checkmark.circle.fill" : "doc.on.doc"
          )
          .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.glassProminent)
        .disabled(lines.isEmpty)
      }
    }
    .overlay(alignment: .bottomLeading) {
      if let errorMessage {
        HStack(spacing: DesignSpacing.xs) {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundStyle(SemanticStatusKind.error.foregroundColor(scheme: colorScheme, contrast: contrast))
          Text(errorMessage)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.primary)
            .lineLimit(2)
        }
        .padding(.horizontal, DesignSpacing.md)
        .padding(.vertical, DesignSpacing.xs)
        .adaptiveGlass(in: Capsule())
        .padding(DesignSpacing.md)
      }
    }
    .animation(DesignMotion.snappy(reduceMotion: reduceMotion), value: displayMode)
    .translationTask(configuration) { session in
      await translateLines(session)
    }
  }

  private var overlayCanvas: some View {
    ZStack(alignment: .bottomTrailing) {
      GeometryReader { geometry in
        let baseRect = fittedImageRect(container: geometry.size, imageSize: image.size)
        let scaledSize = CGSize(width: baseRect.width * zoomScale, height: baseRect.height * zoomScale)
        let canvasOrigin = CGPoint(
          x: max(16, (geometry.size.width - scaledSize.width) / 2),
          y: max(16, (geometry.size.height - scaledSize.height) / 2)
        )
        let imageRect = CGRect(origin: canvasOrigin, size: scaledSize)

        ScrollView([.horizontal, .vertical]) {
          ZStack(alignment: .topLeading) {
            Color.clear
              .frame(
                width: max(geometry.size.width, scaledSize.width + 32),
                height: max(geometry.size.height, scaledSize.height + 32)
              )

            Image(nsImage: image)
              .resizable()
              .interpolation(.high)
              .frame(width: imageRect.width, height: imageRect.height)
              .clipShape(RoundedRectangle(cornerRadius: DesignRadius.sm, style: .continuous))
              .position(x: imageRect.midX, y: imageRect.midY)

            ForEach(lines) { line in
              let rect = overlayRect(for: line.box, in: imageRect)
              let isHovered = (hoveredLineID == line.id)
              let isCopied = (copiedLineID == line.id)
              TranslationOverlayPill(
                sourceText: line.text,
                translatedText: translatedLines[line.id] ?? line.text,
                isTranslated: translatedLines[line.id] != nil,
                isHovered: isHovered,
                isCopied: isCopied,
                rect: rect,
                onHoverChange: { hovering in
                  hoveredLineID = hovering ? line.id : (hoveredLineID == line.id ? nil : hoveredLineID)
                },
                onCopy: {
                  let text = translatedLines[line.id] ?? line.text
                  copySingleLine(text, id: line.id)
                }
              )
              .zIndex(isHovered ? 20 : 1)
            }
          }
        }
      }

      GlassEffectContainer(spacing: 4) {
        HStack(spacing: 4) {
          Button {
            withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
              zoomScale = max(0.6, zoomScale - 0.2)
            }
          } label: {
            Image(systemName: "minus.magnifyingglass")
          }
          .buttonStyle(.glass)
          .controlSize(.small)

          Button {
            withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
              zoomScale = 1.0
            }
          } label: {
            Text("\(Int((zoomScale * 100).rounded()))%")
              .font(.system(size: 11, weight: .semibold, design: .monospaced))
              .frame(minWidth: 42)
          }
          .buttonStyle(.glass)
          .controlSize(.small)

          Button {
            withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
              zoomScale = min(2.4, zoomScale + 0.2)
            }
          } label: {
            Image(systemName: "plus.magnifyingglass")
          }
          .buttonStyle(.glass)
          .controlSize(.small)
        }
      }
      .padding(DesignSpacing.md)
    }
  }

  private var splitCompareCanvas: some View {
    HStack(spacing: 0) {
      GeometryReader { geometry in
        let inset: CGFloat = DesignSpacing.md
        let imageRect = fittedImageRect(
          container: CGSize(
            width: max(120, geometry.size.width - inset * 2),
            height: max(120, geometry.size.height - inset * 2)
          ),
          imageSize: image.size
        ).offsetBy(dx: inset, dy: inset)

        ZStack(alignment: .topLeading) {
          Color.clear
            .frame(width: geometry.size.width, height: geometry.size.height)

          Image(nsImage: image)
            .resizable()
            .interpolation(.high)
            .frame(width: imageRect.width, height: imageRect.height)
            .clipShape(RoundedRectangle(cornerRadius: DesignRadius.sm, style: .continuous))
            .position(x: imageRect.midX, y: imageRect.midY)

          ForEach(lines) { line in
            let rect = highlightBoxRect(for: line.box, in: imageRect)
            let isHighlighted = (hoveredLineID == line.id)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
              .strokeBorder(
                isHighlighted ? Color.accentColor : Color.accentColor.opacity(0.35),
                lineWidth: isHighlighted ? 2.5 : 1
              )
              .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                  .fill(isHighlighted ? Color.accentColor.opacity(0.18) : Color.clear)
              )
              .frame(width: max(12, rect.width), height: max(12, rect.height))
              .position(x: rect.midX, y: rect.midY)
              .onTapGesture {
                let text = translatedLines[line.id] ?? line.text
                copySingleLine(text, id: line.id)
              }
          }
        }
      }
      .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)

      Divider()

      ScrollView(.vertical) {
        if lines.isEmpty {
          VStack(spacing: DesignSpacing.sm) {
            Image(systemName: "text.viewfinder")
              .font(.system(size: 28))
              .foregroundStyle(.tertiary)
            Text(LocalizedText.tr(.noTextFound))
              .font(.headline)
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, minHeight: 300)
        } else {
          LazyVStack(alignment: .leading, spacing: DesignSpacing.sm) {
            ForEach(lines) { line in
              let isHovered = (hoveredLineID == line.id)
              let isCopied = (copiedLineID == line.id)
              TranslationCompareCard(
                sourceText: line.text,
                translatedText: translatedLines[line.id],
                fontSize: CGFloat(model.resultFontSize),
                isHovered: isHovered,
                isCopied: isCopied,
                onCopy: {
                  copySingleLine(translatedLines[line.id] ?? line.text, id: line.id)
                }
              )
              .onHover { hovering in
                withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
                  hoveredLineID = hovering ? line.id : (hoveredLineID == line.id ? nil : hoveredLineID)
                }
              }
            }
          }
          .padding(DesignSpacing.md)
        }
      }
      .frame(minWidth: 340, maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  private func restartTranslation(for language: AppPreferences.TranslationLanguage) {
    errorMessage = nil
    translatedLines.removeAll()
    if var config = configuration {
      config.target = language.localeLanguage
      config.invalidate()
      configuration = config
    } else {
      configuration = TranslationSession.Configuration(source: nil, target: language.localeLanguage)
    }
  }

  private func translateLines(_ session: TranslationSession) async {
    guard !lines.isEmpty else { return }
    do {
      for line in lines {
        try Task.checkCancellation()
        let response = try await session.translate(line.text)
        await MainActor.run {
          withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
            translatedLines[line.id] = response.targetText
          }
        }
      }
    } catch is CancellationError {
      return
    } catch {
      await MainActor.run {
        errorMessage = error.localizedDescription
      }
    }
  }

  private func copyAllTranslatedText() {
    let joined = lines.map { translatedLines[$0.id] ?? $0.text }.joined(separator: "\n")
    onCopyText(joined)
    withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
      didCopyAll = true
    }
    Task { @MainActor in
      try? await Task.sleep(for: .seconds(1.4))
      withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
        didCopyAll = false
      }
    }
  }

  private func copySingleLine(_ text: String, id: UUID) {
    onCopyText(text)
    withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
      copiedLineID = id
    }
    Task { @MainActor in
      try? await Task.sleep(for: .seconds(1.2))
      if copiedLineID == id {
        withAnimation(DesignMotion.snappy(reduceMotion: reduceMotion)) {
          copiedLineID = nil
        }
      }
    }
  }

  private func fittedImageRect(container: CGSize, imageSize: CGSize) -> CGRect {
    guard imageSize.width > 0, imageSize.height > 0, container.width > 0, container.height > 0 else {
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

  private func highlightBoxRect(for box: CGRect, in imageRect: CGRect) -> CGRect {
    CGRect(
      x: imageRect.minX + box.minX * imageRect.width,
      y: imageRect.minY + (1 - box.maxY) * imageRect.height,
      width: box.width * imageRect.width,
      height: box.height * imageRect.height
    ).insetBy(dx: -3, dy: -2)
  }

  private func overlayRect(for box: CGRect, in imageRect: CGRect) -> CGRect {
    let x = imageRect.minX + box.minX * imageRect.width
    let y = imageRect.minY + (1 - box.maxY) * imageRect.height
    let width = max(48, box.width * imageRect.width)
    let height = max(20, box.height * imageRect.height * 1.4)
    return CGRect(x: x, y: y, width: width, height: height)
  }
}

private struct TranslationOverlayPill: View {
  let sourceText: String
  let translatedText: String
  let isTranslated: Bool
  let isHovered: Bool
  let isCopied: Bool
  let rect: CGRect
  let onHoverChange: (Bool) -> Void
  let onCopy: () -> Void

  var body: some View {
    let fontSize = max(11, min(20, rect.height * 0.68))
    Button(action: onCopy) {
      HStack(spacing: 4) {
        Text(translatedText)
          .font(.system(size: fontSize, weight: .semibold))
          .foregroundStyle(.primary)
          .lineLimit(isHovered ? 4 : 2)
          .minimumScaleFactor(0.62)

        if isCopied {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.green)
        }
      }
      .padding(.horizontal, 7)
      .padding(.vertical, 3)
      .frame(minWidth: rect.width, minHeight: rect.height, alignment: .leading)
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 7, style: .continuous)
          .strokeBorder(isHovered ? Color.accentColor : Color.primary.opacity(0.16), lineWidth: isHovered ? 1.5 : 1)
      )
    }
    .buttonStyle(.plain)
    .help(sourceText)
    .onHover(perform: onHoverChange)
    .position(x: rect.midX, y: rect.midY)
    .opacity(isTranslated ? 1.0 : 0.78)
  }
}

private struct TranslationCompareCard: View {
  let sourceText: String
  let translatedText: String?
  let fontSize: CGFloat
  let isHovered: Bool
  let isCopied: Bool
  let onCopy: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: DesignSpacing.xs) {
      HStack(alignment: .top) {
        Text(sourceText)
          .font(.system(size: max(11, fontSize - 2), weight: .regular))
          .foregroundStyle(.secondary)
          .textSelection(.enabled)
          .frame(maxWidth: .infinity, alignment: .leading)

        Button(action: onCopy) {
          Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(isCopied ? .green : .secondary)
            .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .help(LocalizedText.tr(.copyButton))
      }

      if let translatedText {
        Text(translatedText)
          .font(.system(size: fontSize, weight: .medium))
          .foregroundStyle(.primary)
          .textSelection(.enabled)
          .frame(maxWidth: .infinity, alignment: .leading)
      } else {
        HStack(spacing: 6) {
          ProgressView()
            .controlSize(.mini)
          Text("…")
            .font(.system(size: fontSize))
            .foregroundStyle(.tertiary)
        }
      }
    }
    .padding(DesignSpacing.sm)
    .adaptiveCard(cornerRadius: DesignRadius.md, isSelected: isHovered || isCopied)
  }
}
