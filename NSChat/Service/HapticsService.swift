import Haptico

struct HapticsService {
  static var shared = HapticsService()

  private init() {}

  func shake(_ hap: HapticoNotification, _ delay: Duration? = nil) {
    if Pref.shared.haptics {
      if let delay = delay {
        Task.detached {
          let nanoseconds = durationToNanoseconds(delay)
          try? await Task.sleep(nanoseconds: nanoseconds)
            Haptico.shared().generate(hap)
        }
      } else {
        Haptico.shared().generate(hap)
      }
    }
  }

  func shake(_ hap: HapticoImpact, _ delay: Duration? = nil) {
    if Pref.shared.haptics {
      if let delay = delay {
        Task.detached {
          let nanoseconds = durationToNanoseconds(delay)
          try? await Task.sleep(nanoseconds: nanoseconds)
            Haptico.shared().generate(hap)
        }
      } else {
        Haptico.shared().generate(hap)
      }
    }
  }
}

func durationToNanoseconds(_ duration: Duration) -> UInt64 {
  let totalNanoseconds = duration.components.seconds * 1_000_000_000 + duration.components.attoseconds / 1_000_000_000
  return UInt64(totalNanoseconds)
}
