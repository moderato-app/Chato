import SwiftData
import SwiftUI

struct ErrorView: View {
  let errorInfo: String
  let errorType: Message.MessageErrorType
  let provider: Provider?

  @State private var isSettingPresented = false

  init(_ errorInfo: String, _ errorType: Message.MessageErrorType, provider: Provider? = nil) {
    self.errorInfo = errorInfo
    self.errorType = errorType
    self.provider = provider
  }

  var body: some View {
    Label {
      VStack(alignment: .leading) {
        Text(errorInfo)
          .font(.footnote)
        switch errorType {
        case .unknown:
          EmptyView()
        case .apiKey:
          Button {
            isSettingPresented.toggle()
          } label: {
            Text("Please enter your API key.")
              .font(.footnote)
              .foregroundColor(.accentColor)
          }
          .softFeedback(isSettingPresented)
        case .network:
          Button {
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
              if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
              }
            }
          } label: {
            Text("Allow ChatO to use wireless data")
              .font(.footnote)
              .foregroundColor(.accentColor)
          }
        }
      }
    } icon: {
      Image(systemName: "exclamationmark.circle.fill")
        .foregroundColor(.orange)
    }
    .sheet(isPresented: $isSettingPresented) {
      if let provider = provider {
        NavigationStack {
          ProviderDetailView(provider: provider)
        }
        .presentationDetents([.large])
      }
    }
  }
}

#Preview {
  ErrorView("So Bad", Message.MessageErrorType.apiKey, provider: nil)
}
