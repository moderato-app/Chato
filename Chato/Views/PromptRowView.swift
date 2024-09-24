import SwiftData
import SwiftUI

struct PromptRowView: View {
  @EnvironmentObject var em: EM

  var prompt: Prompt
  var showCircle: Bool
  var id: PersistentIdentifier?

  var body: some View {
    //let _ = Self.printChagesWhenDebug()
    print("prompt.id: \(prompt.id)")
    return HStack {
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
        Text(prompt.name)
          .font(.headline)
        Text((prompt.messages.sorted().first(where: { !$0.content.isEmpty })?.content ?? "") + String(repeating: " ", count: 50))
          .foregroundColor(.secondary)
          .lineLimit(3)
      }
    }
    .buttonStyle(.plain)
  }
}
