import AppKit
import Foundation
import VisionOCRSupport

if let workerRequest = OCRWorkerRequest.parse(arguments: CommandLine.arguments) {
  exit(OCRService.runWorkerCLI(request: workerRequest))
}

MainActor.assumeIsolated {
  let app = NSApplication.shared
  let delegate = AppDelegate()
  app.delegate = delegate
  app.run()
}
