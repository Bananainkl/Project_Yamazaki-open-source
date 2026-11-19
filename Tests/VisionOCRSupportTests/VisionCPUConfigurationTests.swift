import AppKit
import CoreText
import XCTest
import Vision
import VisionOCRSupport

final class VisionCPUConfigurationTests: XCTestCase {
  func testExplicitCPUComputeRecognizesText() throws {
    let image = try makeTextImage("OCR TEST 123")
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.recognitionLanguages = ["en-US"]
    request.usesLanguageCorrection = false

    try VisionCPUConfiguration.useCPU(for: request)
    try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])

    let recognizedText = request.results?.compactMap { $0.topCandidates(1).first?.string } ?? []
    XCTAssertTrue(recognizedText.contains("OCR TEST 123"), "Recognized: \(recognizedText)")
  }

  func testProductionLanguageProfileRecognizesNarrowCaptureOnCPU() throws {
    let image = try makeTextImage("Yamazaki OCR 123 - Mixed text", width: 860, height: 70, fontSize: 22)
    for attempt in 1...5 {
      let request = VNRecognizeTextRequest()
      request.recognitionLevel = .accurate
      request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US", "ja-JP"]
      request.usesLanguageCorrection = false
      request.customWords = ["Yamazaki", "OCR", "Command", "快捷键", "認識"]

      try VisionCPUConfiguration.useCPU(for: request)
      try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])

      let recognizedText = request.results?.compactMap { $0.topCandidates(1).first?.string } ?? []
      XCTAssertTrue(
        recognizedText.contains(where: { $0.contains("Yamazaki") }),
        "Attempt \(attempt) recognized: \(recognizedText)"
      )
    }
  }

  private func makeTextImage(_ text: String, width: Int = 640, height: Int = 160, fontSize: CGFloat = 48) throws -> CGImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
      data: nil,
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
      throw ImageFixtureError.cannotCreateContext
    }

    context.setFillColor(NSColor.white.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    let font = CTFontCreateWithName("Arial" as CFString, fontSize, nil)
    let attributedText = NSAttributedString(string: text, attributes: [
      kCTFontAttributeName as NSAttributedString.Key: font,
      kCTForegroundColorAttributeName as NSAttributedString.Key: NSColor.black.cgColor
    ])
    context.textPosition = CGPoint(x: 24, y: max(8, (CGFloat(height) - fontSize) / 2))
    CTLineDraw(CTLineCreateWithAttributedString(attributedText), context)
    guard let image = context.makeImage() else { throw ImageFixtureError.cannotCreateImage }
    return image
  }

  private enum ImageFixtureError: Error {
    case cannotCreateContext
    case cannotCreateImage
  }
}
