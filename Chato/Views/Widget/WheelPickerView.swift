import SwiftUI

struct WheelPickerView: View {
  let name: String
  @Binding var value: Double
  let start: Int
  let end: Int
  let defaultValue: Int
  let systemImage: String
  let spacing: CGFloat

  init(name: String, value: Binding<Double>, start: Int, end: Int, defaultValue: Int, systemImage: String, spacing: CGFloat = 13) {
    self.name = name
    self._value = value
    self.start = start
    self.end = end
    self.defaultValue = defaultValue
    self.systemImage = systemImage
    self.spacing = spacing
  }
  
  var numberType: NumberType {
    if doubleEqual(Double(defaultValue), value) {
      return NumberType.dft("\(defaultValue)")
    } else if value < Double(defaultValue) {
      return .smaller(String(format: "%.1f", value))
    } else {
      return .bigger(String(format: "%.1f", value))
    }
  }

  enum NumberType: Equatable {
    case smaller(String), bigger(String), dft(String)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Label(name, systemImage: systemImage)
          .foregroundStyle(.primary)
        Spacer()
        HStack(alignment: .lastTextBaseline, spacing: 5) {
          Group {
            switch numberType {
            case let .bigger(str):
              Text(str)
                .foregroundStyle(.blue)
            case let .smaller(str):
              Text(str)
                .foregroundStyle(.orange)
            case let .dft(str):
              Text(str) + Text(".1").foregroundStyle(.clear)
            }
          }
          .foregroundStyle(.secondary)
          .fontWeight(.semibold)
          .contentTransition(.numericText(value: value))
          .animation(.snappy(duration: 0.1), value: value)
        }
      }
      .background(Rectangle().fill(.gray.opacity(0.0001)))
      .onTapGesture(count: 2) {
        value = Double(defaultValue)
      }

      WheelPicker(value: $value, start: start, end: end, defaultValue: defaultValue,spacing: spacing)
        .frame(height: 50)
    }
    .grayscale(doubleEqual(Double(defaultValue), value) ? 1 : 0)
    .opacity(doubleEqual(Double(defaultValue), value) ? 0.35 : 1)
    .animation(.default, value: value)
  }
}

#Preview {
  @Previewable @State var value = 0.3
  Form {
    WheelPickerView(name: "Temperature", value: $value,start: -1, end: 1,defaultValue: 0, systemImage: "thermometer.medium")
  }
}

