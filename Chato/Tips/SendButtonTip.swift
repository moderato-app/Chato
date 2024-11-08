import TipKit

struct SendButtonTip: Tip {
  public static let instance = SendButtonTip()
  var title: Text {
    Text("Long press")
      .foregroundStyle(.indigo)
  }

  var message: Text? {
    let glitch: LocalizedStringKey = "\nSend with a different context length."
    return Text(glitch)
      .foregroundStyle(.foreground)
  }

  var options: [TipOption] {
    MaxDisplayCount(1)
  }
}
