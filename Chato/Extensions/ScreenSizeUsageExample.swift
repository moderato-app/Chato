import SwiftUI

// MARK: - Screen Size Environment Usage Examples

/// Example 1: Access screen size in any view
struct ExampleView1: View {
  @Environment(\.screenSize) var screenSize
  
  var body: some View {
    VStack {
      Text("Screen Width: \(screenSize.width)")
      Text("Screen Height: \(screenSize.height)")
      
      // Use screen size for calculations
      Rectangle()
        .frame(width: screenSize.width * 0.8, height: 100)
    }
  }
}

/// Example 2: Use convenience properties
struct ExampleView2: View {
  @Environment(\.screenWidth) var screenWidth
  @Environment(\.screenHeight) var screenHeight
  
  var body: some View {
    VStack {
      Text("Width: \(screenWidth)")
      Text("Height: \(screenHeight)")
      
      // Calculate thresholds based on screen height
      let threshold = screenHeight * 1.5
      Text("Threshold: \(threshold)")
    }
  }
}

/// Example 3: Responsive layout based on screen size
struct ExampleView3: View {
  @Environment(\.screenSize) var screenSize
  
  var isCompact: Bool {
    screenSize.width < 400
  }
  
  var body: some View {
    if isCompact {
      VStack {
        Text("Compact Layout")
      }
    } else {
      HStack {
        Text("Regular Layout")
      }
    }
  }
}

/// Key Features:
/// - Automatically responds to device rotation
/// - Available in any child view through environment
/// - No need to manually track screen changes
/// - Clean and SwiftUI-idiomatic approach

