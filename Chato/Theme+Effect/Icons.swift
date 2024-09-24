import SwiftUI

struct ClearIcon: View {
  @Environment(\.colorScheme) var colorScheme
  let font: Font

  init(font: Font = .body) {
    self.font = font
  }

  var color: HierarchicalShapeStyle {
    colorScheme == .light ? HierarchicalShapeStyle.tertiary : HierarchicalShapeStyle.secondary
  }

  var body: some View {
    Image(systemName: "circle.fill")
      .font(font)
      .fontWeight(.light)
      .foregroundStyle(.ultraThickMaterial)
      .overlay {
        Image(systemName: "xmark.circle.fill")
          .font(font)
          .fontWeight(.light)
          .symbolRenderingMode(.palette)
          .foregroundStyle(.background, color, color)
          .tint(color)
      }
      .symbolRenderingMode(.palette)
  }
}

struct SendIconLight: View {
  @Environment(\.colorScheme) var colorScheme
  let font: Font

  init(_ font: Font = .body) {
    self.font = font
  }

  var body: some View {
    Image(systemName: "circle.fill")
      .font(font)
      .fontWeight(.light)
      .if(colorScheme == .light) { $0.foregroundStyle(.background) }
      .if(colorScheme == .dark) { $0.foregroundStyle(Color(hex:"343434")) }
      .overlay {
        Image(systemName: "arrow.up.circle")
          .font(font)
          .fontWeight(.light)
          .symbolRenderingMode(.monochrome)
          .foregroundColor(.green)
      }
  }
}

struct SendIcon: View {
  let font: Font

  init(_ font: Font = .body) {
    self.font = font
  }

  var body: some View {
    Image(systemName: "circle.fill")
      .font(font)
      .fontWeight(.light)
      .foregroundStyle(.background)
      .overlay {
        Image(systemName: "arrow.up.circle.fill")
          .font(font)
          .fontWeight(.light)
          .symbolRenderingMode(.palette)
          .tint(.green)
          .foregroundStyle(.background, .green, .green)
      }
  }
}

struct ToBottomIcon: View {
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    Image(systemName: "circle.fill")
      .font(.title)
      .fontWeight(.light)
      .foregroundStyle(.ultraThickMaterial)
      .overlay {
        Group {
          if colorScheme == .light {
            Image(systemName: "arrow.down.circle.fill")
              .font(.title)
              .fontWeight(.light)
              .symbolRenderingMode(.palette)
              .tint(.secondary)
              .foregroundStyle(.primary, .background, .background)
          } else {
            Image(systemName: "arrow.down.circle.fill")
              .font(.title)
              .fontWeight(.light)
              .tint(.white)
              .symbolRenderingMode(.palette)
              .foregroundStyle(.secondary, .quinary, .quinary)
              .brightness(0.5)
          }
        }
      }
      .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.22), radius: 5)
  }
}

struct DupButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack {
        Image(systemName: "doc.on.doc")
        Text("Duplicate")
      }
    }.tint(.teal)
  }
}

struct DeleteButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack {
        Image(systemName: "trash")
        Text("Delete")
      }
    }.tint(.red)
  }
}

struct PromptIcon: View {
  var chatOption: ChatOption?

  var body: some View {
    HStack {
      if let co = chatOption {
        if let _ = co.prompt {
          Image(systemName: "p.circle")
        } else {
          Image(systemName: "circle")
        }
      } else {
        // for homepage
        Image(systemName: "p.circle")
      }
    }
    .padding(2)
    .clipShape(Circle())
    .overlay(
      Circle().stroke(Color.clear)
    )
  }
}

struct PlusIcon: View {
  var body: some View {
    Image(systemName: "plus.circle")
      .padding(2)
      .clipShape(Circle())
      .overlay(
        Circle().stroke(Color.clear)
      )
  }
}

struct ContextLengthCircle: View {
  @Environment(\.colorScheme) var colorScheme
  let contextLength: Int
  let powerful: Bool

  init(_ contextLength: Int, _ powerful: Bool) {
    self.contextLength = contextLength
    self.powerful = powerful
  }

  var body: some View {
    if powerful {
      Image(systemName: contextLengthCircle(contextLength, powerful))
        .symbolRenderingMode(.monochrome)
        .fontWeight(.semibold)
        .tint(.secondary)
    } else {
      Image(systemName: contextLengthCircle(contextLength, powerful))
        .symbolRenderingMode(.monochrome)
        .tint(.secondary)
    }
  }
}

func contextLengthCircle(_ contextLength: Int, _ powerful: Bool) -> String {
  var name: String
  if contextLength == 0 {
    name = "circle"
  } else if contextLength > 0, contextLength <= 50 {
    name = "\(contextLength).circle"
  } else if contextLength == Int.max {
    name = "infinity.circle"
  } else {
    name = "questionmark.circle"
  }

  if powerful {
    name += ".fill"
  }

  return name
}
