import CoreHaptics
import os
import SwiftUI

struct TestView: View {
  @State private var engine: CHHapticEngine?

  var body: some View {
    VStack {
      Button("Click") {
        complexSuccess()
      }
      .padding(40)
      .background(.gray)
      .onAppear(perform: prepareHaptics)
    }
  }

  func prepareHaptics() {
      guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

      do {
          engine = try CHHapticEngine()
          try engine?.start()
      } catch {
          AppLogger.error.error("There was an error creating the engine: \(error.localizedDescription)")
      }
  }

  func complexSuccess() {
    // make sure that the device supports haptics
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    var events = [CHHapticEvent]()

    // create one intense, sharp tap
    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.25)
    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
    let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
    events.append(event)

    // convert those events into a pattern and play it immediately
    do {
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: 0)
    } catch {
      AppLogger.error.error("Failed to play pattern: \(error.localizedDescription)")
    }
  }
}

struct ImageView: View {
  @State var input = ""

  var body: some View {
    VStack {
      AsyncImage(url: URL(string: "https://uploads4.wikiart.org/images/william-adolphe-bouguereau/nymphs-and-satyr.jpg")) { phase in
        if let image = phase.image {
          image.resizable().scaledToFit()
        } else if let err = phase.error {
          Text("There was an error loading the image. Error: \(err.localizedDescription)")
        } else {
          ProgressView()
        }
      }
    }
  }
}

#Preview {
  TestView()
}
