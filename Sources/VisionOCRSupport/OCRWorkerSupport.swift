import CoreGraphics
import Foundation

public struct OCRWorkerLinePayload: Codable, Equatable, Sendable {
  public let text: String
  public let x: Double
  public let y: Double
  public let width: Double
  public let height: Double

  public init(text: String, box: CGRect) {
    self.text = text
    self.x = Double(box.origin.x)
    self.y = Double(box.origin.y)
    self.width = Double(box.size.width)
    self.height = Double(box.size.height)
  }

  public var boundingBox: CGRect {
    CGRect(x: x, y: y, width: width, height: height)
  }
}

public struct OCRWorkerRequest: Equatable, Sendable {
  public static let workerFlag = "--ocr-worker"
  public static let outputFlag = "--output"
  public static let languageModeFlag = "--language-mode"
  public static let textDirectionFlag = "--text-direction"
  public static let ignoreWatermarkFlag = "--ignore-watermark"

  public let imagePath: String
  public let outputPath: String
  public let languageMode: String
  public let textDirection: String
  public let ignoreWatermark: Bool

  public init(
    imagePath: String,
    outputPath: String,
    languageMode: String,
    textDirection: String,
    ignoreWatermark: Bool
  ) {
    self.imagePath = imagePath
    self.outputPath = outputPath
    self.languageMode = languageMode
    self.textDirection = textDirection
    self.ignoreWatermark = ignoreWatermark
  }

  public func cliArguments() -> [String] {
    [
      Self.workerFlag, imagePath,
      Self.outputFlag, outputPath,
      Self.languageModeFlag, languageMode,
      Self.textDirectionFlag, textDirection,
      Self.ignoreWatermarkFlag, ignoreWatermark ? "1" : "0"
    ]
  }

  public static func parse(arguments: [String]) -> OCRWorkerRequest? {
    guard let workerIndex = arguments.firstIndex(of: workerFlag),
          workerIndex + 1 < arguments.count else {
      return nil
    }

    let imagePath = arguments[workerIndex + 1]
    var outputPath: String?
    var languageMode = "globalAuto"
    var textDirection = "horizontal"
    var ignoreWatermark = true

    var index = workerIndex + 2
    while index < arguments.count {
      let flag = arguments[index]
      let nextIndex = index + 1
      guard nextIndex < arguments.count else { break }
      let value = arguments[nextIndex]
      switch flag {
      case outputFlag:
        outputPath = value
      case languageModeFlag:
        languageMode = value
      case textDirectionFlag:
        textDirection = value
      case ignoreWatermarkFlag:
        ignoreWatermark = (value == "1" || value.lowercased() == "true")
      default:
        break
      }
      index += 2
    }

    guard let resolvedOutputPath = outputPath, !resolvedOutputPath.isEmpty, !imagePath.isEmpty else {
      return nil
    }

    return OCRWorkerRequest(
      imagePath: imagePath,
      outputPath: resolvedOutputPath,
      languageMode: languageMode,
      textDirection: textDirection,
      ignoreWatermark: ignoreWatermark
    )
  }
}

public enum OCRWorkerError: Error, LocalizedError, Equatable {
  case executableUnavailable
  case imageEncodingFailed
  case timedOut(seconds: TimeInterval)
  case workerFailed(exitCode: Int32, stderr: String)
  case invalidWorkerOutput(String)

  public var errorDescription: String? {
    switch self {
    case .executableUnavailable:
      return "OCR worker executable is unavailable."
    case .imageEncodingFailed:
      return "Failed to encode screenshot for OCR worker."
    case .timedOut(let seconds):
      return "OCR worker timed out after \(Int(seconds))s."
    case .workerFailed(let exitCode, let stderr):
      return stderr.isEmpty
        ? "OCR worker exited with status \(exitCode)."
        : stderr
    case .invalidWorkerOutput(let detail):
      return "OCR worker produced invalid output: \(detail)"
    }
  }
}

public final class OCRResilienceCoordinator {
  private let lock = NSLock()
  private var degraded = false

  public init() {}

  public var isInProcessDegraded: Bool {
    lock.lock()
    defer { lock.unlock() }
    return degraded
  }

  public func execute<T>(
    inProcess: () throws -> T,
    subprocessFallback: () throws -> T,
    onSelfHealNeeded: ((Error) -> Void)? = nil
  ) throws -> T {
    if isInProcessDegraded {
      return try subprocessFallback()
    }

    do {
      return try inProcess()
    } catch let primaryError {
      let fallbackResult = try subprocessFallback()
      let shouldNotifySelfHeal: Bool = {
        lock.lock()
        defer { lock.unlock() }
        let wasHealthy = !degraded
        degraded = true
        return wasHealthy
      }()
      if shouldNotifySelfHeal {
        onSelfHealNeeded?(primaryError)
      }
      return fallbackResult
    }
  }
}

public enum OCRSubprocessRunner {
  public static func run(
    executableURL: URL,
    request: OCRWorkerRequest,
    timeout: TimeInterval = 60,
    registerProcess: ((Process?) -> Void)? = nil
  ) throws -> [OCRWorkerLinePayload] {
    guard FileManager.default.isExecutableFile(atPath: executableURL.path) else {
      throw OCRWorkerError.executableUnavailable
    }

    defer {
      try? FileManager.default.removeItem(atPath: request.outputPath)
    }

    let process = Process()
    process.executableURL = executableURL
    process.arguments = request.cliArguments()
    process.standardInput = FileHandle.nullDevice
    process.standardOutput = FileHandle.nullDevice

    let stderrPipe = Pipe()
    process.standardError = stderrPipe

    var stderrData = Data()
    let stderrGroup = DispatchGroup()
    stderrGroup.enter()
    DispatchQueue.global(qos: .utility).async {
      stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
      stderrGroup.leave()
    }

    let timeoutLock = NSLock()
    var didTimeOut = false
    let timeoutItem = DispatchWorkItem {
      timeoutLock.lock()
      didTimeOut = true
      timeoutLock.unlock()
      if process.isRunning {
        process.terminate()
      }
    }

    registerProcess?(process)
    defer {
      timeoutItem.cancel()
      registerProcess?(nil)
    }

    DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + timeout, execute: timeoutItem)

    try process.run()
    process.waitUntilExit()
    timeoutItem.cancel()
    stderrGroup.wait()

    timeoutLock.lock()
    let timedOut = didTimeOut
    timeoutLock.unlock()
    if timedOut {
      throw OCRWorkerError.timedOut(seconds: timeout)
    }

    guard process.terminationStatus == 0 else {
      let stderrMessage = (String(data: stderrData, encoding: .utf8) ?? "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
      throw OCRWorkerError.workerFailed(exitCode: process.terminationStatus, stderr: stderrMessage)
    }

    let outputURL = URL(fileURLWithPath: request.outputPath)
    let data: Data
    do {
      data = try Data(contentsOf: outputURL)
    } catch {
      throw OCRWorkerError.invalidWorkerOutput(error.localizedDescription)
    }

    do {
      return try JSONDecoder().decode([OCRWorkerLinePayload].self, from: data)
    } catch {
      throw OCRWorkerError.invalidWorkerOutput(error.localizedDescription)
    }
  }
}
