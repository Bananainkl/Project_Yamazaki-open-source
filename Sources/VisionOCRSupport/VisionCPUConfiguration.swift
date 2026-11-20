import CoreML
import Vision

public enum VisionCPUConfiguration {
  public static func useCPU(for request: VNRequest) throws {
    for (stage, devices) in try request.supportedComputeStageDevices {
      guard let cpu = devices.first(where: { device in
        if case .cpu = device { return true }
        return false
      }) else {
        throw ConfigurationError.cpuUnavailable(stage: String(describing: stage))
      }
      request.setComputeDevice(cpu, for: stage)
    }
  }

  public enum ConfigurationError: Error, LocalizedError {
    case cpuUnavailable(stage: String)

    public var errorDescription: String? {
      switch self {
      case .cpuUnavailable(let stage):
        return "Vision does not offer CPU compute for stage \(stage)."
      }
    }
  }
}
