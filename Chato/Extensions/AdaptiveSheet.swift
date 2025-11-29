// https://fatbobman.com/en/posts/in-depth-exploration-of-overlay-and-background-modifiers-in-swiftui/
import SwiftUI

struct SheetExampleView: View {
  @State var show = false
  @State var height: CGFloat = 250
  var body: some View {
    List {
      Button("Pop Sheet") {
        height = 250
        show.toggle()
      }
      Button("Pop ScrollView Sheet") {
        height = 1000
        show.toggle()
      }
    }
    .adaptiveSheet(isPresented: $show) {
      ViewThatFits(in: .vertical) {
        SheetView(height: height)
        ScrollView {
          SheetView(height: height)
        }
      }
    }
  }
}

struct SheetView: View {
  let height: CGFloat
  var body: some View {
    Text("Hi")
      .frame(maxWidth: .infinity, minHeight: height)
      .presentationBackground(.blue.gradient)
  }
}

extension View {
  func adaptiveSheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder sheetContent: () -> Content) -> some View {
    modifier(AdaptiveSheetModifier(isPresented: isPresented, sheetContent))
  }
}

struct AdaptiveSheetModifier<SheetContent: View>: ViewModifier {
  @Binding var isPresented: Bool
  @State private var subHeight: CGFloat = 0
  var sheetContent: SheetContent

  init(isPresented: Binding<Bool>, @ViewBuilder _ content: () -> SheetContent) {
    _isPresented = isPresented
    sheetContent = content()
  }

  func body(content: Content) -> some View {
    content
      .background(
        sheetContent // Get size here to prevent initial popup jitter
          .background(
            GeometryReader { proxy in
              Color.clear
                .task(id: proxy.size.height) {
                  subHeight = proxy.size.height
                }
            }
          )
          .hidden()
      )
      .sheet(isPresented: $isPresented) {
        sheetContent
          .presentationDetents([.height(subHeight)])
      }
      .id(subHeight)
  }
}

#Preview {
  
  SheetExampleView()
}
