import SwiftUI

struct ErrorView: View {
  @Environment(NavigationContext.self) private var navigationContext
  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject var pref: Pref

  let errorInfo: String
  let errorType: Message.MessageErrorType
  @State private var isSettingPresented = false

  init(_ errorInfo: String, _ errorType: Message.MessageErrorType) {
    self.errorInfo = errorInfo
    self.errorType = errorType
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
            Text("Provide your API key")
              .font(.footnote)
              .foregroundColor(.accentColor)
          }
          .if(pref.haptics) {
            $0.sensoryFeedback(.impact(flexibility: .soft), trigger: isSettingPresented)
          }
          .sheet(isPresented: $isSettingPresented) {
            ChatGPTSettingView()
              .environment(navigationContext)
              .modelContainer(modelContext.container)
              .presentationDetents([.medium])
          }
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
  }
}

#Preview {
  ErrorView("So Bad", .apiKey)
}
