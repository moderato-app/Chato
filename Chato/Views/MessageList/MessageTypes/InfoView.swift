import SwiftUI

struct InfoView: View {
  @Environment(\.colorScheme) var colorScheme
  let message: Message

  var body: some View {
    VStack {
      HStack {
        Text("INFO").selectable()
          .foregroundStyle(.secondary)
        Spacer()
//        Button("Copy") {

//        }
//        .buttonStyle(.plain)
//        .foregroundStyle(.tint)
      }

      Divider()
      if let meta = message.meta {
        HStack(alignment: .firstTextBaseline) {
          Text("Model").foregroundStyle(.secondary).selectable()
          Spacer()
          Text(meta.model).fontWeight(.light).selectable()
        }

        HStack(alignment: .firstTextBaseline) {
          Text("Context Length").foregroundStyle(.secondary).selectable()
          Spacer()
          Text("\(meta.contextLength)").fontWeight(.light).selectable()
        }

        if let promptTokens = meta.promptTokens{
          HStack(alignment: .firstTextBaseline) {
            Text("Prompt Tokens").foregroundStyle(.secondary).selectable()
            Spacer()
            Text("\(promptTokens)").fontWeight(.light).selectable()
          }
        }

        if let completionTokens = meta.completionTokens{
          HStack(alignment: .firstTextBaseline) {
            Text("Completion Tokens").foregroundStyle(.secondary).selectable()
            Spacer()
            Text("\(completionTokens)").fontWeight(.light).selectable()
          }
        }

        if let s = meta.startedAt , let e = meta.endedAt{
          let d = e.timeIntervalSince(s)
          HStack(alignment: .firstTextBaseline) {
            Text("Duration").selectable()
              .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 2) {
              Text(String(format: "%.1f", d)).fontWeight(.light).selectable()
              Text("s").fontWeight(.light).foregroundStyle(.secondary).selectable()
            }
          }
        }

        if let startedAt = meta.startedAt{
          HStack(alignment: .firstTextBaseline) {
            Text("Start").selectable()
              .foregroundStyle(.secondary)
            Spacer()
            Text(startedAt, format: Date.FormatStyle(date: .long, time: .omitted)).selectable()
              .fontWeight(.light)
              .foregroundStyle(.secondary)
            Text(startedAt, format: Date.FormatStyle(date: .omitted, time: .shortened)).selectable()
              .fontWeight(.light)
          }
        }

        if let endedAt = meta.endedAt {
          HStack(alignment: .firstTextBaseline) {
            Text("End").selectable()
              .foregroundStyle(.secondary)
            Spacer()
            Text(endedAt, format: Date.FormatStyle(date: .long, time: .omitted)).selectable()
              .fontWeight(.light)
              .foregroundStyle(.secondary)
            Text(endedAt, format: Date.FormatStyle(date: .omitted, time: .shortened)).selectable()
              .fontWeight(.light)
          }
        }
      }
    }
  }
}

#Preview {
//  InfoView(message: )
}
