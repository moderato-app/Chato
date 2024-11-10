import SwiftData
import SwiftUI

struct PromptRowView: View {
  @EnvironmentObject var em: EM

  var prompt: Prompt
  var showCircle: Bool
  var id: PersistentIdentifier?

  var body: some View {
    //let _ = Self.printChagesWhenDebug()
    HStack {
      // show button only if chatOption exists
      if showCircle {
        if prompt.id == id {
          Button {
            em.chatOptionPromptChangeEvent.send(nil)
          } label: {
            Image(systemName: "smallcircle.filled.circle.fill")
              .fontWeight(.medium)
              .foregroundColor(.blue)
              .padding(0)
          }
        } else {
          Button {
            em.chatOptionPromptChangeEvent.send(prompt.persistentModelID)
          } label: {
            Image(systemName: "circle")
              .fontWeight(.medium)
              .foregroundColor(.secondary)
              .padding(0)
          }
        }
      }
      VStack(alignment: .leading) {
        HStack(alignment: .firstTextBaseline) {
          Text(prompt.name)
            .fontWeight(.semibold)
            .lineLimit(1)
          Spacer()
          Image(systemName: "chevron.forward")
            .foregroundStyle(.tertiary)
            .fontWeight(.semibold)
            .imageScale(.small)
        }
        Text((prompt.messages.sorted().first(where: { !$0.content.isEmpty })?.content ?? "") + String(repeating: " ", count: 50))
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(2)
      }
    }
    .buttonStyle(.plain)
  }
}
