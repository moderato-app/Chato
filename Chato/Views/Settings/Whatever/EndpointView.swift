import SwiftUI

struct EndpointView: View {
  @Binding var useEndpoint: Bool
  @Binding var endpoint: String

  init(_ useEndpoint: Binding<Bool>, _ endpoint: Binding<String>) {
    _useEndpoint = useEndpoint
    _endpoint = endpoint
  }

  func validateUrl(_ url: String) -> (String, Error?) {
    do {
      let (base, path) = try parseURL(url)
      if let path {
        return ("\(base)/\(path)", nil)
      } else {
        return (base, nil)
      }
    } catch {
      return ("", error)
    }
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
          TextEditPageVIew(text: $endpoint,
                           title: "Endpoint",
                           fb: .fixed("https://api.openai.com"),
                           description: "Set this property if you use some kind of proxy or your own server. Default is https://api.openai.com")
        } label: {
          LabeledContent("Endpoint") { Text(endpoint) }
        }.disabled(!useEndpoint)
      } header: {
        if useEndpoint {
          let res = validateUrl(endpoint)
          if let err = res.1 {
            Text("Oops! \(err.localizedDescription)").foregroundStyle(.orange)
              .padding(.bottom, 10)
          } else {
            Text("✅ \(res.0) is a valid endpoint.")
          }
        }
      } footer: {
        VStack(alignment: .leading, spacing: 10) {
          Text(verbatim: "For example")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " https://api.openai.com")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " https://abc.example.com")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " http://192.168.0.1")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " https://abc.example.com/path")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " api.openai.com")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " 192.168.0.1")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " abc.example.com/api")
          Text(Image(systemName: "checkmark.circle.fill")).foregroundColor(.green) + Text(verbatim: " mydomain")
          Text(Image(systemName: "xmark.circle.fill")).foregroundColor(.pink) + Text(verbatim: " /api")
        }
      }
      .textCase(.none)
    }
  }
}

#Preview {
  @Previewable @State var useEndpoint = false
  @Previewable @State var endpoint = "http://abc.com"
  EndpointView($useEndpoint, $endpoint)
}
