import SwiftUI

struct ProxyView: View {
  @Binding var useEndpoint: Bool
  @Binding var baseURL: String

  init(_ useEndpoint: Binding<Bool>, _ baseURL: Binding<String>) {
    _useEndpoint = useEndpoint
    _baseURL = baseURL
  }

  var body: some View {
    Form {
      Section {
        HStack {
          Label {
            Text("Endpoint")
          } icon: {
            Image(systemName: "network")
              .foregroundColor(.accentColor)
          }
          Spacer()
          Toggle("", isOn: $useEndpoint)
        }
      }
      Section {
        NavigationLink {
          TextEditPageVIew(text: $baseURL,
                           title: "Base URL",
                           fb: .fixed("https://api.openai.com"),
                           description: "Set this property if you use some kind of proxy or your own server. Default is https://api.openai.com")
        } label: {
          LabeledContent("Base URL") { Text(baseURL) }
        }.disabled(!useEndpoint)
      } footer: {
        VStack(alignment: .leading, spacing: 10) {
          Text(verbatim: "Currently, only a base URL is supported.")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " https://api.openai.com")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " https://abc.example.com")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " http://192.168.0.1")
          Text(Image(systemName: "xmark.circle.fill")).foregroundColor(.pink) + Text(verbatim: " https://abc.example.com/v1")
          Text(Image(systemName: "xmark.circle.fill")).foregroundColor(.pink) + Text(verbatim: " api.openai.com")
          Text(Image(systemName: "xmark.circle.fill")).foregroundColor(.pink) + Text(verbatim: " abc.example.com")
          Text(Image(systemName: "xmark.circle.fill")).foregroundColor(.pink) + Text(verbatim: " abc.example.com/api")
        }
      }
      .textCase(.none)
    }
  }
}

#Preview {
  @Previewable @State var useEndpoint = false
  @Previewable @State var baseURL = "http://abc.com"
  ProxyView($useEndpoint, $baseURL)
}
