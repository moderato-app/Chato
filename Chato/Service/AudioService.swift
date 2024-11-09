import AVFoundation
import Foundation


struct AudioService {
  static var shared = AudioService()
  private var audioPlayer: AVAudioPlayer?

  private init() {
    // Load sound file
    if let soundURL = Bundle.main.url(forResource: "wheel_sound", withExtension: "m4a") {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading sound file: \(error)")
        }
    }
  }

  // Play the audio when called
  private func playSound() {
      audioPlayer?.play()
  }
}
