import SwiftUI

struct StateView: View {
  var msg: Message

  var body: some View {
    HStack(spacing: 2) {
      Text(formatAgo(from: msg.createdAt))
      if msg.status == .sending {
        SendingStatusView()
          .modifier(StatusModifier(msg.role))
      }
      if msg.status == .sent || msg.status == .received {
        DoneStatusView()
          .modifier(StatusModifier(msg.role))
      }
    }
    .foregroundColor(msg.role == .assistant ? .secondary : Color(hex: "#e5e5e5"))
    .font(.footnote)
  }
}

#Preview {
  StateView(msg: ChatSample.manyMessages.messages.last!)
}
