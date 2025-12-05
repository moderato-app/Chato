import SwiftUI

struct WebSearchOptionView: View {
  @Bindable var webSearch: WebSearch
  
  private let iconName = "magnifyingglass.circle"
  
  var body: some View {
    Toggle(isOn: $webSearch.enabled) {
      Label("Enabled", systemImage: iconName)
        .modifier(RippleEffect(at: .zero, trigger: webSearch.enabled))
        .selectionFeedback(webSearch.enabled)
    }
    
    VStack(alignment: .leading) {
      Label("Context Size", systemImage: iconName)
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
