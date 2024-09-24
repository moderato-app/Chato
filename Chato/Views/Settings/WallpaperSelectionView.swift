import SwiftUI

let wallpaperImageNames = ["marine-3", "lilac-1", "chroma-1", "blossom-5", "amber-2"]

struct WallpaperSelectionView: View {
  @EnvironmentObject var pref: Pref

  var body: some View {
    TabView(selection: $pref.wallpaperIndex) {
      Color.clear
        .background(.gray.opacity(0.3).gradient)
        .tag(0)

      ForEach(wallpaperImageNames.indices, id: \.self) { index in
        pixelBuddha(wallpaperImageNames[index]).tag(index + 1)
      }
    }
    .animation(.default, value: pref.wallpaperIndex)
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    .overlay(alignment: .bottom) {
      VStack {
        if let name = pref.wallpaperName {
          Image(name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .background(.gray.opacity(0.2))
            .mask {
              Color.clear
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .overlay {
                  Text(pref.wallpaperDispaleyName)
                    .fontDesign(.rounded)
                    .padding(20)
                    .fontWeight(.bold)
                    .font(.system(size: 500))
                    .minimumScaleFactor(0.01)
                }
            }
            .animation(.snappy(duration: 0.2), value: pref.wallpaperDispaleyName)
        }
        HStack(spacing: 0) {
          ForEach(0 ... wallpaperImageNames.count, id: \.self) { tag in
            tabBarItem(tag: tag)
          }
        }
        .padding(.vertical)
        .padding(.bottom, 20)
      }
      .allowsHitTesting(false)
    }
    .ignoresSafeArea()
  }

  private func tabBarItem(tag: Int) -> some View {
    Button {
      withAnimation {
        pref.wallpaperIndex = tag
      }
    } label: {
      Circle()
        .fill(pref.wallpaperIndex == tag ? Color.white : Color.gray.opacity(0.5))
        .frame(width: 10, height: 10)
        .padding(6)
    }
  }

  private func pixelBuddha(_ name: String) -> some View {
    Color.clear
      .background(.ultraThinMaterial)
      .background(
        VStack {
          Image(name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .background(.gray.opacity(0.5).gradient)
        }
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height)
        .clipped()
      )
  }
}

struct WallpaperView: View {
  @EnvironmentObject var pref: Pref
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    if colorScheme == .dark {
      EmptyView()
    } else if pref.wallpaperIndex == 0 {
      Color.clear
        .background(.gray.opacity(0.3).gradient)
    } else {
      Color.clear
        .background(.ultraThinMaterial)
        .background(
          Image(wallpaperImageNames[pref.wallpaperIndex - 1])
            .resizable()
            .aspectRatio(contentMode: .fill)
            .background(.gray.opacity(0.5).gradient)
        )
        .ignoresSafeArea()
    }
  }
}

#Preview("Selection") {
  WallpaperSelectionView()
    .environmentObject(Pref.shared)
}
