import SwiftUI

extension SettingView {
  func CoffeeIcons(_ count: Int) -> [String] {
    return (0 ..< count).map { i in
      if i % 2 == 0 {
        return "cup.and.saucer"
      } else {
        return "cup.and.saucer.fill"
      }
    }
  }

  func randomColor(_ i: Int) -> Color {
    let colors = [Color.primary,
                  Color.secondary,
                  Color.blue,
                  Color.pink,
                  Color.green,
                  Color.yellow,
                  Color.teal,
                  Color.indigo,
                  Color.yellow,
                  Color.purple,
                  Color.cyan]
    return colors[i % colors.count]
  }
}

