import Foundation

extension String {
  var isMeaningful: Bool {
    !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var isMeaningless: Bool {
    self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var meaningfulString: String {
    self.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
