import AVFoundation
import SwiftUI
import os

fileprivate let steps = 10

fileprivate enum Role {
  case primary, secondary, ordinary
}

struct WheelPicker: View {
  @Binding var value: Double
  let start: Int
  let end: Int
  let defaultValue: Int
  let spacing: CGFloat
  let haptic: Bool
  let debounceDelay: Duration
  
  private let defaultIndex: Int
  @State private var actualIndex: Int
  @State private var localValue: Double
  @State private var loaded: Bool
  @State private var indicatorX: CGFloat = .zero
  @State private var defaultIndexX: CGFloat = .zero
  @State private var debounceTask: Task<Void, Never>?

  init(
    value: Binding<Double>,
    start: Int,
    end: Int,
    defaultValue: Int,
    spacing: CGFloat = 13,
    haptic: Bool = true,
    debounceDelay: Duration = .milliseconds(300)
  ) {
    self._value = value
    self.start = start
    self.end = end
    self.defaultValue = defaultValue
    self.spacing = spacing
    self.haptic = haptic
    self.debounceDelay = debounceDelay
    
    self.defaultIndex = Int(round((Double(defaultValue) - Double(start)) * 10))
    let initialValue = value.wrappedValue
    self._actualIndex = State(initialValue: Int(round((initialValue - Double(start)) * Double(steps))))
    self._localValue = State(initialValue: initialValue)
    self._loaded = State(initialValue: false)
  }

  var body: some View {
    GeometryReader {
      let hPadding = $0.size.width / 2

      ScrollView(.horizontal) {
        HStack(spacing: spacing) {
          let totalSteps = steps * (end - start)

          ForEach(0 ... totalSteps, id: \.self) { i in
            let role = (i % steps == 0 ? Role.primary : (i % (steps / 2) == 0 ? Role.secondary : Role.ordinary))
            let color = (role == .primary ? Color.primary : Color.secondary)
            let height = (role == .primary ? 15 : (role == .secondary ? 10 : 5))

            Rectangle()
              .fill(color)
              .frame(width: 1, height: CGFloat(height), alignment: .center)
              .frame(maxHeight: 20, alignment: .bottom)
              .overlay {
                if role == .primary {
                  Text("\(i / steps + start)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .textScale(.secondary)
                    .fixedSize()
                    .offset(y: 20)
                }
              }
              .overlay {
                if defaultIndex == i {
                  Circle()
                    .fill(actualIndex == i ? .clear : Color.primary)
                    .fontWeight(.semibold)
                    .frame(width: 6, height: 6)
                    .offset(y: -10)
                    .animation(.default, value: actualIndex)
                    .padding(3)
                    .onTapGesture { withAnimation { actualIndex = i }}
                    .onGeometryChange(for: CGFloat.self) { proxy in
                      proxy.frame(in: .global).midX
                    } action:{
                      defaultIndexX = $0
                    }

                }
              }
          }
        }
        .frame(height: 50)
        .scrollTargetLayout()
      }
      .scrollIndicators(.hidden)
      .scrollTargetBehavior(.viewAligned)
      .scrollPosition(id: .init(get: {
        let pos: Int? = loaded ? actualIndex : nil
        return pos
      }, set: { newValue in
        if let newValue {
          actualIndex = newValue
        }
      }))
      .onAppear {
        if !loaded { loaded = true }
      }
      .overlay(alignment: .center) {
        Rectangle()
          .fill(indicatorColor)
          .frame(width: 2, height: 25)
          .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.frame(in: .global).midX
          } action:{
            indicatorX = $0
          }
          .overlay(alignment: .trailing){
            if status == .bigger && indicatorX > defaultIndexX{
              Rectangle()
                .fill(indicatorColor.opacity(0.2))
                .frame(width: indicatorX - defaultIndexX + 1.5, height: 25)
            }
          }
          .overlay(alignment: .leading){
            if status == .smaller && defaultIndexX > indicatorX{
              Rectangle()
                .fill(indicatorColor.opacity(0.2))
                .frame(width: defaultIndexX - indicatorX + 1.5, height: 25)
            }
          }
          .padding(.bottom, 5)
          .allowsHitTesting(false)
      }
      .safeAreaPadding(.horizontal, hPadding)
    }
    .onChange(of: actualIndex) { _, newIndex in
      guard loaded else { return }
      
      // Update local value immediately for smooth UI
      let newValue = indexToValue(newIndex)
      localValue = newValue
      
      // Play haptic feedback
      if haptic {
        AudioServicesPlayAlertSound(SystemSoundID(1460))
      }
      
      // Debounce: cancel previous task and schedule new one
      debounceTask?.cancel()
      debounceTask = Task {
        do {
          try await Task.sleep(for: debounceDelay)
          guard !Task.isCancelled else { return }
          
          // Update external binding only after delay
          await MainActor.run {
            if !doubleEqual(value, newValue) {
              withAnimation {
                value = newValue
              }
              AppLogger.ui.debug("WheelPicker: Updated external value to \(newValue, format: .fixed(precision: 2))")
            }
          }
        } catch {
          // Task was cancelled, ignore
        }
      }
    }
    .onChange(of: value) { oldValue, newValue in
      guard loaded else { return }
      guard !doubleEqual(oldValue, newValue) else { return }
      
      // Only update if external value changed from outside
      let currentLocal = indexToValue(actualIndex)
      if !doubleEqual(currentLocal, newValue) {
        withAnimation {
          actualIndex = valueToIndex(newValue)
          localValue = newValue
        }
        AppLogger.ui.debug("WheelPicker: External value changed to \(newValue, format: .fixed(precision: 2))")
      }
    }
    .onDisappear {
      // Flush any pending changes when view disappears
      debounceTask?.cancel()
      if !doubleEqual(value, localValue) {
        value = localValue
      }
    }
  }

  var status: Status {
    let compareIndex = valueToIndex(localValue)
    if compareIndex == defaultIndex {
      return .equal
    } else if compareIndex < defaultIndex {
      return .smaller
    } else {
      return .bigger
    }
  }
  
  var indicatorColor: Color {
    switch status {
    case .bigger:
      Color.blue
    case .smaller:
      Color.orange
    case .equal:
      Color.secondary
    }
  }


  enum Status: Equatable {
    case smaller, bigger, equal
  }

  func indexToValue(_ index: Int) -> Double {
    return Double(index) / Double(steps) + Double(start)
  }

  func valueToIndex(_ value: Double) -> Int {
    return Int(round((value - Double(start)) * Double(steps)))
  }
}

#Preview("GPTWheelPicker") {
  @Previewable @State var value = 0.3
  WheelPicker(value: $value, start: -1, end: 1, defaultValue: 0)
}
