import SwiftUI

struct ProviderConfigurationForm: View {
  @Binding var providerType: ProviderType
  @Binding var alias: String
  @Binding var apiKey: String
  @Binding var endpoint: String
  @Binding var enabled: Bool
  
  var body: some View {
    Section {
      Picker("Provider Type", selection: $providerType) {
        ForEach(ProviderType.allCases, id: \.self) { type in
          Label {
            Text(type.displayName)
          } icon: {
            Image(systemName: type.iconName)
          }
          .tag(type)
        }
      }
    } header: {
      Text("Type")
    }
    
    Section {
      TextField("Alias (Optional)", text: $alias)
      
      TextField("API Key", text: $apiKey)
        .textContentType(.password)
      
      TextField("Endpoint (Optional)", text: $endpoint)
        .textContentType(.URL)
        .autocapitalization(.none)
    } header: {
      Text("Configuration")
    } footer: {
      Text("Leave endpoint empty to use default")
    }
    
    Section {
      Toggle("Enabled", isOn: $enabled)
    }
  }
}

