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
            Text("Please set up AI provider.")
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
            Text("Allow NSChat to use wireless data")
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
      NavigationStack {
        if let provider = provider {
          ProviderView(provider: provider, mode: .Edit)
            .toolbar {
              ToolbarItem(placement: .confirmationAction) {
                Button("OK") {
                  isSettingPresented = false
                }
                .foregroundStyle(.tint)
              }
            }
        } else {
          ProviderView(provider: Provider(type: .openAI), mode: .Add)
        }
      }
    }
  }
}

#Preview {
  ErrorView("So Bad", Message.MessageErrorType.apiKey, provider: nil)
}
