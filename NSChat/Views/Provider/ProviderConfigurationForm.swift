import SwiftUI

struct ProviderConfigurationForm: View {
  @Binding var providerType: ProviderType
  @Binding var alias: String
  @Binding var apiKey: String
  @Binding var endpoint: String
  @Binding var enabled: Bool

  @State private var isPasswordVisible = false

  var body: some View {
    Section {
      Picker("Provider", selection: $providerType) {
        ForEach(ProviderType.allCases, id: \.self) { type in
          Text(type.displayName)
            .tag(type)
        }
      }
    } header: {
      Text("Type")
    }

    Section("Name") {
      TextField(providerType.displayName, text: $alias).textContentType(.name)
    }
    Section {
      if isPasswordVisible {
        TextField(providerType.displayName, text: $apiKey).textContentType(.password)
      } else {
        SecureField(providerType.displayName, text: $apiKey).textContentType(.password)
      }
    } header: {
      HStack {
        Text("API Key")
        Spacer()
        Button(action: {
          isPasswordVisible.toggle()
        }) {
          Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
            .foregroundColor(.secondary)
            .contentTransition(.symbolEffect(.replace))
            .symbolEffect(.bounce, value: isPasswordVisible)
        }
        .buttonStyle(.plain)
        .controlSize(.small)
      }
    }
    Section("Endpoint") {
      TextField("Endpoint (Optional)", text: $endpoint)
        .textContentType(.URL)
        .autocapitalization(.none)
    }

    Section {
      Toggle("Enabled", isOn: $enabled)
    }
  }
}
