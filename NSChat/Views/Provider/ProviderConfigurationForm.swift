import SwiftUI

struct ProviderConfigurationForm: View {
  @Bindable var provider: Provider
  let mode: ProviderViewMode

  @State private var isPasswordVisible = false

  var body: some View {
    Section {
      Picker("Provider", selection: $provider.type) {
        ForEach(ProviderType.allCases, id: \.self) { type in
          Text(type.displayName)
            .tag(type)
        }
      }
    } header: {
      Text("Type")
    }

    Section("Name") {
      TextField(provider.type.displayName, text: $provider.alias).textContentType(.name)
    }
    Section {
      if isPasswordVisible {
        TextField(provider.type.displayName, text: $provider.apiKey).textContentType(.password)
      } else {
        SecureField(provider.type.displayName, text: $provider.apiKey).textContentType(.password)
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
      TextField("Endpoint (Optional)", text: $provider.endpoint)
        .textContentType(.URL)
        .autocapitalization(.none)
    }

    if mode == .Edit {
      Section {
        Toggle("Enabled", isOn: $provider.enabled)
      }
    }
  }
}
