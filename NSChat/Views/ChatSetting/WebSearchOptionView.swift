import SwiftUI

struct WebSearchOptionView: View {
  @Bindable var webSearch: WebSearch
  

  var body: some View {
    Toggle(isOn: $webSearch.enabled) {
      Label("Enabled", systemImage: "globe")
        .modifier(RippleEffect(at: .zero, trigger: webSearch.enabled))
        .selectionFeedback(webSearch.enabled)
    }
    
    VStack(alignment: .leading) {
      Label("Context Size", systemImage: "square.3.layers.3d.down.left")
      Picker("Context Size", selection: $webSearch.contextSize) {
        ForEach(WebSearchContextSize.allCases, id: \.self) { size in
          Text(size.title)
            .tag(size)
        }
      }
      .pickerStyle(.segmented)
      .labelsHidden()
      .selectionFeedback(webSearch.contextSize)
      .disabled(!webSearch.enabled)
    }
  }
}
