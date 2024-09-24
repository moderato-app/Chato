import SwiftData
import SwiftUI

struct TutorialView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var popOverDetent = PresentationDetent.large
  let option: ChatOption

  var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        HStack {
          Text("The context length number, set at ") +
            Text(Image(systemName: contextLengthCircle(option.contextLength, option.isBestModel))).foregroundStyle(.secondary) +
            Text(", determines how many previous messages accompany your input when sent to ChatGPT.")
        }

        Divider()

        HStack {
          Text("The circle of GPT-4 model ") +
            Text(Image(systemName: contextLengthCircle(option.contextLength, true))).foregroundStyle(.secondary) +
            Text(" is more noticeable than the circle of GPT-3.5 and GPT-4o mini models ") +
            Text(Image(systemName: contextLengthCircle(option.contextLength, false))).foregroundStyle(.secondary)
        }

        Divider()

        Label {
          Text("Send the input text to ChatGPT with no preceding messages.")
        } icon: {
          SendIconLight()
        }

        Divider()

        Label {
          Text("Send the input text to ChatGPT, with ") +
            Text(Image(systemName: contextLengthCircle(option.contextLength, option.isBestModel))).foregroundStyle(.secondary) +
            Text(" preceding messages.")
        } icon: {
          SendIcon()
        }

        Divider()

        HStack(alignment: .center) {
          Text(Image(systemName: "hand.tap")).foregroundColor(.accentColor) +
            Text(Image(systemName: "multiply")).font(.footnote).fontWeight(.semibold) +
            Text("2").fontWeight(.semibold).foregroundColor(.accentColor)
          Text("Double-tap a message to input it, and double-tap again to withdraw.")
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
      .navigationTitle("Tutorial")
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
