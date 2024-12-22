// Created for Chato in 2024

import SwiftUI

struct ModelRowView: View {
  @State private var expanding = false

  let model: ModelModel

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(model.resolvedName)
          .font(.headline)
        Spacer()
        if let readableContextLength {
          Text("\(readableContextLength)")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      if expanding {
        Text(model.modelId)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      if let info = model.info {
        Text(info)
          .font(.subheadline)
          .foregroundColor(.secondary)
          .lineLimit(expanding ? nil : 2)
      }
    }
    .overlay {
      Rectangle().fill(.gray.opacity(0.001)).onTapGesture {
        withAnimation(.easeInOut) {
          expanding.toggle()
        }
      }
    }
  }

  var readableContextLength: String? {
    guard let contextLength = model.contextLength else {
      return nil
    }

    return contextLength > 1000 ? "\(contextLength / 1000)K" : "\(contextLength)"
  }
}
