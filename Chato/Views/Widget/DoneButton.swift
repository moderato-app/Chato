import SwiftUI

struct DoneButton: View {
  @Environment(\.dismiss) private var dismiss

  let name: String

  init(_ name: String = "Done") {
    self.name = name
  }

  var body: some View {
    Button(name) {
      dismiss()
    }
    .fontWeight(.semibold)
    .padding()
  }
}

struct CloseButton: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    Button {
      dismiss()
    } label: {
      Image(systemName: "xmark.circle.fill")
        .resizable()
        .scaledToFill()
    }
    .frame(width: 35, height: 35)
    .foregroundStyle(.secondary)
    .background(Circle().fill(.background))
    .padding()
  }
}

#Preview {
  VStack {
    Spacer()
    DoneButton()
      .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
    CloseButton()
      .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
    Spacer()
  }.overlay(alignment: .topTrailing){
    DoneButton()
    CloseButton()
  }
}
