import SwiftUI

struct ProxyView: View {
  @Binding var useProxy: Bool
  @Binding var proxyHost: String

  init(_ useProxy: Binding<Bool>, _ proxyHost: Binding<String>) {
    _useProxy = useProxy
    _proxyHost = proxyHost
  }

  var body: some View {
    Form {
      Section {
        HStack {
          Label {
            Text("Use Proxy")
          } icon: {
            Image(systemName: "network")
              .foregroundColor(.accentColor)
          }
          Spacer()
          Toggle("", isOn: $useProxy)
        }
      }
      Section {
        NavigationLink {
          TextEditPageVIew(text: $proxyHost,
                           title: "Host",
                           fb: .fixed(ChatGPTContext.defulatHost),
                           description: "Set this property if you use some kind of proxy or your own server. Default is api.openai.com")
        } label: {
          LabeledContent("Proxy Host") { Text(proxyHost) }
        }.disabled(!useProxy)
      } footer: {
        VStack(alignment: .leading, spacing: 10) {
          Text(verbatim: "Currently, only a domain is supported.")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " api.openai.com")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " abc.example.com")
          Text(Image(systemName: "xmark.circle.fill")).foregroundColor(.pink) + Text(verbatim: " https://abc.example.com/v1")
          Text(Image(systemName: "xmark.circle.fill")).foregroundColor(.pink) + Text(verbatim: " http://abc.example.com")
          Text(Image(systemName: "xmark.circle.fill")).foregroundColor(.pink) + Text(verbatim: " abc.example.com/api")
        }
      }
      .textCase(.none)
    }
  }
}

#Preview {
  @Previewable @State var useProxy = false
  @Previewable @State var proxyHost = ChatGPTContext.defulatHost
  return ProxyView($useProxy, $proxyHost)
}
