import SwiftData
import SwiftUI

struct TutorialView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var popOverDetent = PresentationDetent.medium
  let option: ChatOption

  var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        Text("The context length number ") +
          Text(Image(systemName: contextLengthCircle(option.contextLength, option.isBestModel))).foregroundStyle(.secondary) +
          Text(" determines how many previous messages accompany your input when sent to ChatGPT.")

        Divider()

        Text("The circle ") +
          Text(Image(systemName: contextLengthCircle(option.contextLength, true))).foregroundStyle(.secondary) +
          Text(" of best models(GPT-4o, o1-preview and o1-mini) is more noticeable than the circle ") +
          Text(Image(systemName: contextLengthCircle(option.contextLength, false))).foregroundStyle(.secondary) +
          Text(" of other models.")

        Divider()

        Label {
          Text("Send your input to ChatGPT without previous messages.")
        } icon: {
          SendIconLight()
        }

        Divider()

        Label {
          Text("Send your input to ChatGPT, with ") +
            Text(Image(systemName: contextLengthCircle(option.contextLength, option.isBestModel))).foregroundStyle(.secondary) +
            Text(" previous messages.")
        } icon: {
          SendIcon()
        }

        Spacer()
      }
      .padding(.horizontal)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .navigationTitle("Help")
      .navigationBarTitleDisplayMode(.inline)
    }
    .presentationDetents(
      [.medium, .large],
      selection: $popOverDetent
    )
  }
}

#Preview {
  TutorialView(option: ChatSample.manyMessages.option)
}
