import CoreGraphics
import Foundation
import VisionOCRSupport
import XCTest

final class OCRWorkerSupportTests: XCTestCase {
  func testWorkerRequestCLIRoundTrip() {
    let original = OCRWorkerRequest(
      imagePath: "/tmp/yamazaki-test-input.png",
      outputPath: "/tmp/yamazaki-test-output.json",
      languageMode: "chineseTraditionalEnglishJapaneseSymbols",
      textDirection: "vertical",
      ignoreWatermark: false
    )

    let argv = ["/Applications/Yamazaki.app/Contents/MacOS/Yamazaki"] + original.cliArguments()
    let parsed = OCRWorkerRequest.parse(arguments: argv)
    XCTAssertEqual(parsed, original)
  }

  func testWorkerRequestRejectsIncompleteArguments() {
    XCTAssertNil(OCRWorkerRequest.parse(arguments: ["/Applications/Yamazaki.app/Contents/MacOS/Yamazaki"]))
    XCTAssertNil(OCRWorkerRequest.parse(arguments: ["Yamazaki", "--ocr-worker", "/tmp/in.png"]))
  }

  func testResilienceCoordinatorFallsBackOnceAndSkipsPollutedInProcessRuntime() throws {
    struct SimulatedE5RTError: LocalizedError {
      var errorDescription: String? { "The operation couldn’t be completed. (TextRecognition.CRImageReaderError error 1.)" }
    }

    let coordinator = OCRResilienceCoordinator()
    var inProcessCalls = 0
    var fallbackCalls = 0
    var selfHealNotifications = 0

    let firstResult: String = try coordinator.execute(
      inProcess: {
        inProcessCalls += 1
        throw SimulatedE5RTError()
      },
      subprocessFallback: {
        fallbackCalls += 1
        return "Recovered text 1"
      },
      onSelfHealNeeded: { _ in
        selfHealNotifications += 1
      }
    )

    XCTAssertEqual(firstResult, "Recovered text 1")
    XCTAssertTrue(coordinator.isInProcessDegraded)
    XCTAssertEqual(inProcessCalls, 1)
    XCTAssertEqual(fallbackCalls, 1)
    XCTAssertEqual(selfHealNotifications, 1)

    let secondResult = try coordinator.execute(
      inProcess: {
        inProcessCalls += 1
        return "Should not run"
      },
      subprocessFallback: {
        fallbackCalls += 1
        return "Recovered text 2"
      },
      onSelfHealNeeded: { _ in
        selfHealNotifications += 1
      }
    )

    XCTAssertEqual(secondResult, "Recovered text 2")
    XCTAssertEqual(inProcessCalls, 1, "Degraded coordinator must bypass poisoned in-process OCR")
    XCTAssertEqual(fallbackCalls, 2)
    XCTAssertEqual(selfHealNotifications, 1, "Self-heal notification should fire only once")
  }

  func testResilienceCoordinatorDoesNotTriggerSelfHealWhenFallbackAlsoFails() {
    struct SimulatedFailure: Error {}

    let coordinator = OCRResilienceCoordinator()
    var selfHealNotifications = 0

    XCTAssertThrowsError(
      try coordinator.execute(
        inProcess: { () throws -> String in throw SimulatedFailure() },
        subprocessFallback: { () throws -> String in throw SimulatedFailure() },
        onSelfHealNeeded: { _ in selfHealNotifications += 1 }
      )
    )

    XCTAssertFalse(coordinator.isInProcessDegraded)
    XCTAssertEqual(selfHealNotifications, 0)
  }

  func testSubprocessRunnerDecodesPayloadAndCleansUpOutputFile() throws {
    let tempDir = FileManager.default.temporaryDirectory
    let scriptURL = tempDir.appendingPathComponent("yamazaki-mock-worker-\(UUID().uuidString).sh")
    let outputURL = tempDir.appendingPathComponent("yamazaki-mock-output-\(UUID().uuidString).json")
    defer {
      try? FileManager.default.removeItem(at: scriptURL)
      try? FileManager.default.removeItem(at: outputURL)
    }

    let script = """
    #!/bin/sh
    out=""
    while [ "$#" -gt 0 ]; do
      if [ "$1" = "--output" ]; then
        out="$2"
        shift 2
      else
        shift 1
      fi
    done
    printf '[{"text":"Yamazaki 123","x":0.1,"y":0.2,"width":0.5,"height":0.15}]' > "$out"
    """
    try script.write(to: scriptURL, atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptURL.path)

    let request = OCRWorkerRequest(
      imagePath: "/tmp/unused.png",
      outputPath: outputURL.path,
      languageMode: "globalAuto",
      textDirection: "horizontal",
      ignoreWatermark: true
    )

    let lines = try OCRSubprocessRunner.run(executableURL: scriptURL, request: request, timeout: 5)
    XCTAssertEqual(lines.count, 1)
    XCTAssertEqual(lines.first?.text, "Yamazaki 123")
    XCTAssertFalse(FileManager.default.fileExists(atPath: outputURL.path), "Runner must remove temporary output file")
  }

  func testSubprocessRunnerTerminatesOnTimeout() throws {
    let tempDir = FileManager.default.temporaryDirectory
    let scriptURL = tempDir.appendingPathComponent("yamazaki-slow-worker-\(UUID().uuidString).sh")
    let outputURL = tempDir.appendingPathComponent("yamazaki-slow-output-\(UUID().uuidString).json")
    defer {
      try? FileManager.default.removeItem(at: scriptURL)
      try? FileManager.default.removeItem(at: outputURL)
    }

    let script = """
    #!/bin/sh
    sleep 10
    """
    try script.write(to: scriptURL, atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptURL.path)

    let request = OCRWorkerRequest(
      imagePath: "/tmp/unused.png",
      outputPath: outputURL.path,
      languageMode: "globalAuto",
      textDirection: "horizontal",
      ignoreWatermark: true
    )

    XCTAssertThrowsError(
      try OCRSubprocessRunner.run(executableURL: scriptURL, request: request, timeout: 0.4)
    ) { error in
      XCTAssertEqual(error as? OCRWorkerError, .timedOut(seconds: 0.4))
    }
  }
}
