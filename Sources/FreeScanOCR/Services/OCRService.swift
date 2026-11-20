import AppKit
import CoreGraphics
import Foundation
import ImageIO
import OSLog
import Vision
import VisionOCRSupport

enum OCRError: LocalizedError {
  case invalidImage

  var errorDescription: String? {
    switch self {
    case .invalidImage:
      return "无法读取截图图片"
    }
  }
}

final class OCRService {
  private let logger = Logger(subsystem: "com.itou.yamazaki", category: "OCR")
  private let resilience = OCRResilienceCoordinator()
  private let workerProcessLock = NSLock()
  private var activeWorkerProcess: Process?
  var onSelfHealNeeded: ((Error) -> Void)?

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

  func cancelActiveWorker() {
    workerProcessLock.lock()
    let process = activeWorkerProcess
    activeWorkerProcess = nil
    workerProcessLock.unlock()

    if let process, process.isRunning {
      process.terminate()
    }
  }

  private func setActiveWorkerProcess(_ process: Process?) {
    workerProcessLock.lock()
    activeWorkerProcess = process
    workerProcessLock.unlock()
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
    guard let cgImage = normalizedCGImage(from: image) else {
      throw OCRError.invalidImage
    }

    let languageMode = AppPreferences.languageMode
    let textDirection = AppPreferences.textDirection
    let ignoreWatermarkText = AppPreferences.ignoreWatermarkText

    return try resilience.execute(
      inProcess: {
        try recognizePositionedTextInCurrentProcess(
          cgImage: cgImage,
          languageMode: languageMode,
          textDirection: textDirection,
          ignoreWatermarkText: ignoreWatermarkText
        )
      },
      subprocessFallback: {
        logger.info("Running isolated OCR worker subprocess after in-process failure or degradation")
        return try recognizePositionedTextInSubprocess(
          cgImage: cgImage,
          languageMode: languageMode,
          textDirection: textDirection,
          ignoreWatermarkText: ignoreWatermarkText
        )
      },
      onSelfHealNeeded: { [weak self] error in
        self?.onSelfHealNeeded?(error)
      }
    )
  }

  func recognizePositionedTextInCurrentProcess(
    cgImage: CGImage,
    languageMode: AppPreferences.LanguageMode,
    textDirection: AppPreferences.TextDirection,
    ignoreWatermarkText: Bool
  ) throws -> [RecognizedTextLine] {
    let rotatedImage = textDirection == .vertical ? rotatedClockwise(cgImage) : nil
    let imageForRecognition = rotatedImage ?? cgImage

    let lines: [OCRLine]
    do {
      lines = try recognize(in: imageForRecognition, languageMode: languageMode, usesCPUOnly: true)
    } catch {
      logger.error("Primary OCR request failed: \(error.localizedDescription, privacy: .public)")
      do {
        lines = try recognize(in: imageForRecognition, languageMode: languageMode, usesCPUOnly: false)
        logger.info("OCR alternate compute path succeeded")
      } catch {
        logger.error("OCR alternate compute path failed: \(error.localizedDescription, privacy: .public)")
        throw error
      }
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
    if ignoreWatermarkText {
      outputLines = filterWatermarkLines(outputLines, in: cgImage)
    }
    return outputLines.map { RecognizedTextLine(text: $0.text, box: $0.box) }
  }

  private func recognizePositionedTextInSubprocess(
    cgImage: CGImage,
    languageMode: AppPreferences.LanguageMode,
    textDirection: AppPreferences.TextDirection,
    ignoreWatermarkText: Bool
  ) throws -> [RecognizedTextLine] {
    guard let executableURL = Self.resolveCurrentExecutableURL() else {
      throw OCRWorkerError.executableUnavailable
    }

    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
      throw OCRWorkerError.imageEncodingFailed
    }

    let token = UUID().uuidString
    let tempDir = FileManager.default.temporaryDirectory
    let inputURL = tempDir.appendingPathComponent("yamazaki-ocr-worker-\(token).png")
    let outputURL = tempDir.appendingPathComponent("yamazaki-ocr-worker-\(token).json")

    try pngData.write(to: inputURL, options: .atomic)
    defer {
      try? FileManager.default.removeItem(at: inputURL)
    }

    let workerRequest = OCRWorkerRequest(
      imagePath: inputURL.path,
      outputPath: outputURL.path,
      languageMode: languageMode.rawValue,
      textDirection: textDirection.rawValue,
      ignoreWatermark: ignoreWatermarkText
    )

    let payloads = try OCRSubprocessRunner.run(
      executableURL: executableURL,
      request: workerRequest,
      timeout: 60,
      registerProcess: { [weak self] process in
        self?.setActiveWorkerProcess(process)
      }
    )

    return payloads.map { RecognizedTextLine(text: $0.text, box: $0.boundingBox) }
  }

  private static func resolveCurrentExecutableURL() -> URL? {
    if let bundleExec = Bundle.main.executableURL,
       FileManager.default.isExecutableFile(atPath: bundleExec.path) {
      return bundleExec
    }
    if let arg0 = CommandLine.arguments.first {
      let url = URL(fileURLWithPath: arg0)
      if FileManager.default.isExecutableFile(atPath: url.path) {
        return url
      }
    }
    return nil
  }

  static func runWorkerCLI(request: OCRWorkerRequest) -> Int32 {
    let service = OCRService()
    let imageURL = URL(fileURLWithPath: request.imagePath)

    guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
          let rawCGImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil),
          let cgImage = service.normalizedCGImage(fromCGImage: rawCGImage) else {
      let message = "Failed to load OCR worker input image.\n"
      if let data = message.data(using: .utf8) {
        FileHandle.standardError.write(data)
      }
      return 1
    }

    let languageMode = AppPreferences.LanguageMode(rawValue: request.languageMode) ?? .globalAuto
    let textDirection = AppPreferences.TextDirection(rawValue: request.textDirection) ?? .horizontal

    do {
      let lines = try service.recognizePositionedTextInCurrentProcess(
        cgImage: cgImage,
        languageMode: languageMode,
        textDirection: textDirection,
        ignoreWatermarkText: request.ignoreWatermark
      )
      let payloads = lines.map { OCRWorkerLinePayload(text: $0.text, box: $0.box) }
      let encoded = try JSONEncoder().encode(payloads)
      try encoded.write(to: URL(fileURLWithPath: request.outputPath), options: .atomic)
      return 0
    } catch {
      let message = "\(error.localizedDescription)\n"
      if let data = message.data(using: .utf8) {
        FileHandle.standardError.write(data)
      }
      return 1
    }
  }

  private func recognize(
    in image: CGImage,
    languageMode: AppPreferences.LanguageMode,
    usesCPUOnly: Bool
  ) throws -> [OCRLine] {
    if languageMode == .globalAuto {
      return try recognizeGlobalAuto(in: image, usesCPUOnly: usesCPUOnly).lines
    }
    return try recognizeLines(
      in: image,
      languages: languageMode.recognitionLanguages,
      preservesSymbols: languageMode.preservesSymbols,
      usesCPUOnly: usesCPUOnly
    )
  }

  private func normalizedCGImage(from image: NSImage, maxDimension: Int? = nil) -> CGImage? {
    guard let source = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
    return normalizedCGImage(fromCGImage: source, maxDimension: maxDimension)
  }

  func normalizedCGImage(fromCGImage source: CGImage, maxDimension: Int? = nil) -> CGImage? {
    let sourceWidth = source.width
    let sourceHeight = source.height
    guard sourceWidth > 0, sourceHeight > 0 else { return nil }

    let limit = maxDimension ?? max(sourceWidth, sourceHeight)
    let scale = min(1, CGFloat(limit) / CGFloat(max(sourceWidth, sourceHeight)))
    let width = max(1, Int((CGFloat(sourceWidth) * scale).rounded()))
    let height = max(1, Int((CGFloat(sourceHeight) * scale).rounded()))
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
      data: nil,
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: width * 4,
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    context.interpolationQuality = .high
    context.setFillColor(gray: 1, alpha: 1)
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
    return context.makeImage()
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

    if repeatCount >= 3 && (lowContrast || tall || wide || lowConfidence) { return true }
    if repeatCount >= 2 && lowContrast && (wide || tall || line.confidence < 0.75) { return true }
    if veryLowContrast && (huge || (wide && tall)) { return true }
    if lowContrast && huge && line.confidence < 0.80 { return true }
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
        guard let color = bitmap.colorAt(x: clampedX, y: clampedY)?.usingColorSpace(.deviceRGB) else { continue }
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

  private func recognizeGlobalAuto(in image: CGImage, usesCPUOnly: Bool) throws -> OCRResult {
    let profiles = [
      ["zh-Hans", "zh-Hant", "en-US"],
      AppPreferences.LanguageMode.chineseTraditionalEnglishJapaneseSymbols.recognitionLanguages,
      ["zh-Hans", "zh-Hant", "ja-JP", "ko-KR", "en-US"],
      AppPreferences.LanguageMode.latinAuto.recognitionLanguages,
      ["th-TH", "vi-VN", "id-ID", "en-US"],
      ["ru-RU", "uk-UA", "ar-SA", "hi-IN", "en-US"]
    ]

    let results = try profiles.map { profile in
      OCRResult(lines: try recognizeLines(in: image, languages: profile, usesCPUOnly: usesCPUOnly), languageProfile: profile)
    }

    return results.max { score($0) < score($1) } ?? OCRResult(lines: [], languageProfile: [])
  }

  private func score(_ result: OCRResult) -> Double {
    let text = result.text
    let scalarCount = text.unicodeScalars.filter { !$0.properties.isWhitespace }.count
    let cjkCount = text.unicodeScalars.filter { isCJKScalar($0) }.count
    let nonLatinCount = text.unicodeScalars.filter { $0.value > 0x024F && !$0.properties.isWhitespace }.count

    return Double(scalarCount)
      + Double(result.averageConfidence) * 24
      + Double(cjkCount) * 1.8
      + Double(nonLatinCount) * 0.65
  }

  private func recognizeLines(
    in image: CGImage,
    languages: [String],
    preservesSymbols: Bool = false,
    usesCPUOnly: Bool = false
  ) throws -> [OCRLine] {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = !preservesSymbols
    let supportedLanguages = (try? request.supportedRecognitionLanguages()) ?? languages
    let filteredLanguages = languages.filter { supportedLanguages.contains($0) }
    request.recognitionLanguages = filteredLanguages.isEmpty ? ["en-US"] : filteredLanguages
    request.customWords = [
      "Yamazaki", "OCR", "PDF", "Command",
      "剪切板", "剪贴板", "快捷键", "识别", "識別",
      "クリップボード", "ショートカット", "認識",
      "클립보드", "단축키", "인식"
    ]

    if usesCPUOnly {
      try VisionCPUConfiguration.useCPU(for: request)
    }

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
    if verticalGap > max(medianHeight * 0.9, 0.018) { return true }

    let previousText = previous.text.trimmingCharacters(in: .whitespacesAndNewlines)
    let nextText = next.text.trimmingCharacters(in: .whitespacesAndNewlines)
    if endsParagraph(previousText) { return true }
    if looksLikeListItem(nextText) { return true }
    return false
  }

  private func joinSeparator(previous: String, next: String) -> String {
    guard let last = previous.last, let first = next.first else { return "" }
    if last == "-" { return "" }
    if isCJK(last) || isCJK(first) { return "" }
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
    character.unicodeScalars.contains { isCJKScalar($0) }
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
