import TipKit

struct AdvancedOptionDoubleTapTip: Tip {
  static let instance = AdvancedOptionDoubleTapTip()
  var title: Text {
    Text("Double-Tap to Reset")
      .foregroundStyle(.indigo)
  }

  var options: [TipOption] {
    MaxDisplayCount(1)
  }
}
